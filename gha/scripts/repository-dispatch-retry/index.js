// last_verified: 2026-10-02 · gha n/a
'use strict';

/**
 * Repository dispatch with retry.
 *
 * The Actions JavaScript runtime provides the Node runtime and nothing else: no
 * node_modules, no package resolution beyond the action directory, no bundler. An
 * action that `require()`s a third-party package therefore dies on MODULE_NOT_FOUND
 * unless the dependency is vendored or pre-bundled into the action folder. This
 * entrypoint deliberately ships zero dependencies and issues the REST call through
 * the runtime's built-in `fetch`, so the action directory is the whole deployment
 * unit.
 */

const fs = require('fs');

/** Status codes worth a second attempt: transient server and transport failures. */
const RETRYABLE_STATUS = new Set([408, 500, 502, 503, 504]);

/** Upper bound on any single backoff sleep, regardless of Retry-After. */
const MAX_BACKOFF_MS = 60000;

/**
 * Environment variable names a given action input can arrive under.
 *
 * An input declared as `event-type` is exported by the runner with its name
 * preserved and only upper-cased, i.e. `INPUT_EVENT-TYPE`; runners and wrappers
 * that normalise the hyphen instead produce `INPUT_EVENT_TYPE`. Probing both
 * spellings keeps the action working instead of failing a required input on an
 * environment-variable naming detail.
 */
const inputEnvKeys = (name) => {
  const upper = name.toUpperCase();
  return [`INPUT_${upper}`, `INPUT_${upper.replace(/-/g, '_')}`];
};

const readInput = (name, { required = true, fallback = '' } = {}) => {
  const keys = inputEnvKeys(name);
  for (const key of keys) {
    const value = (process.env[key] || '').trim();
    if (value) {
      return value;
    }
  }
  if (required) {
    throw new Error(`Input '${name}' is required but empty (checked ${keys.join(' and ')}).`);
  }
  return fallback;
};

const readRepository = () => {
  const repository = readInput('repository');
  if (!/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(repository)) {
    throw new Error(`Input 'repository' must be owner/name, got '${repository}'.`);
  }
  return repository;
};

const readEventType = () => {
  const eventType = readInput('event-type');
  if (!/^[A-Za-z][A-Za-z0-9_-]*$/.test(eventType)) {
    throw new Error(
      `Input 'event-type' must start with a letter and contain only letters, digits, underscores or hyphens, got '${eventType}'.`,
    );
  }
  return eventType;
};

const readClientPayload = () => {
  const raw = readInput('client-payload', { required: false, fallback: '{}' });
  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch (error) {
    throw new Error(`Input 'client-payload' must be valid JSON: ${error.message}`);
  }
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error("Input 'client-payload' must be a JSON object, e.g. '{\"ref\": \"main\"}'.");
  }
  return parsed;
};

const readBoundedInt = (name, fallback, min, max) => {
  const raw = readInput(name, { required: false, fallback: String(fallback) });
  if (!/^-?\d+$/.test(raw)) {
    throw new Error(`Input '${name}' must be an integer, got '${raw}'.`);
  }
  const value = Number.parseInt(raw, 10);
  if (value < min || value > max) {
    throw new Error(`Input '${name}' must be between ${min} and ${max}, got ${value}.`);
  }
  return value;
};

const readApiUrl = () => {
  const apiUrl = (process.env.GITHUB_API_URL || '').trim().replace(/\/+$/, '');
  if (!apiUrl) {
    throw new Error('GITHUB_API_URL is not set; the action cannot address the API.');
  }
  if (!/^[a-z][a-z0-9+.-]*:\/\/[^\s]+$/i.test(apiUrl)) {
    throw new Error(`GITHUB_API_URL must be an absolute URL, got '${apiUrl}'.`);
  }
  return apiUrl;
};

/**
 * Publish every action output in a single append to $GITHUB_OUTPUT.
 *
 * Single-line values use the `name=value` form; multi-line values use the heredoc
 * form with a per-run delimiter that cannot appear in the payload.
 */
const writeOutputs = (entries) => {
  const target = process.env.GITHUB_OUTPUT;
  if (!target) {
    throw new Error('GITHUB_OUTPUT is not set; outputs cannot be published.');
  }
  const stamp = `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 8)}`;
  const block = Object.entries(entries)
    .map(([name, value]) => {
      const text = String(value);
      if (!/[\r\n]/.test(text)) {
        return `${name}=${text}\n`;
      }
      const delimiter = `gha_dispatch_${stamp}_${name.replace(/[^A-Za-z0-9_]/g, '_')}`;
      return `${name}<<${delimiter}\n${text}\n${delimiter}\n`;
    })
    .join('');
  fs.appendFileSync(target, block, 'utf8');
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * POST the dispatch and report what came back. The body is only read on failure —
 * a successful create returns 204 No Content with an empty body, so there is no
 * payload to parse and no dispatch identifier to publish.
 */
const attemptDispatch = async (endpoint, token, eventType, clientPayload) => {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      accept: 'application/vnd.github+json',
      authorization: `Bearer ${token}`,
      'content-type': 'application/json',
      'user-agent': 'repository-dispatch-retry',
    },
    body: JSON.stringify({ event_type: eventType, client_payload: clientPayload }),
  });

  const headers = {
    retryAfter: response.headers.get('retry-after'),
    rateLimitRemaining: response.headers.get('x-ratelimit-remaining'),
  };
  const body = response.ok ? '' : await response.text().catch(() => '');
  return { status: response.status, ok: response.ok, body, ...headers };
};

const isRateLimited = ({ status, rateLimitRemaining, body }) =>
  status === 429 ||
  (status === 403 && (rateLimitRemaining === '0' || /rate limit/i.test(body || '')));

/** Status 0 stands for a request that never produced a response (transport error). */
const isRetryable = (result) =>
  result.status === 0 || isRateLimited(result) || RETRYABLE_STATUS.has(result.status);

const describe = (result) => {
  if (result.status === 0) {
    return `no response (${result.body || 'transport error'})`;
  }
  const detail = (result.body || '').replace(/\s+/g, ' ').trim().slice(0, 300);
  return detail ? `HTTP ${result.status}: ${detail}` : `HTTP ${result.status}`;
};

/** Seconds to wait before retrying, from Retry-After when the server sent one. */
const retryAfterMs = (result) => {
  if (!result.retryAfter) {
    return 0;
  }
  const seconds = Number.parseInt(result.retryAfter, 10);
  if (Number.isNaN(seconds)) {
    const when = Date.parse(result.retryAfter);
    return Number.isNaN(when) ? 0 : Math.max(0, when - Date.now());
  }
  return seconds * 1000;
};

const backoffMs = (attempt, baseDelayMs, result) => {
  const exponential = Math.min(MAX_BACKOFF_MS, baseDelayMs * 2 ** attempt);
  const jittered = Math.round(exponential * (0.5 + Math.random() * 0.5));
  return Math.min(MAX_BACKOFF_MS, Math.max(jittered, retryAfterMs(result)));
};

const main = async () => {
  const token = readInput('token');
  const repository = readRepository();
  const eventType = readEventType();
  const clientPayload = readClientPayload();
  const maxRetries = readBoundedInt('max-retries', 3, 0, 10);
  const baseDelayMs = readBoundedInt('base-delay-ms', 1000, 100, 60000);
  const [owner, repo] = repository.split('/');
  const endpoint = `${readApiUrl()}/repos/${owner}/${repo}/dispatches`;

  let result = null;
  let attemptsMade = 0;
  for (let attempt = 0; attempt <= maxRetries; attempt += 1) {
    try {
      result = await attemptDispatch(endpoint, token, eventType, clientPayload);
    } catch (error) {
      result = {
        status: 0,
        ok: false,
        body: error instanceof Error ? error.message : String(error),
        retryAfter: null,
        rateLimitRemaining: null,
      };
    }
    attemptsMade = attempt + 1;
    if (result.ok) {
      writeOutputs({
        status: 'success',
        'http-status': String(result.status),
        attempts: String(attemptsMade),
      });
      console.log(
        `Dispatched '${eventType}' to ${repository} on attempt ${attempt + 1} (HTTP ${result.status}, no response body).`,
      );
      return;
    }
    if (!isRetryable(result) || attempt === maxRetries) {
      break;
    }
    const wait = backoffMs(attempt, baseDelayMs, result);
    console.log(
      `Attempt ${attempt + 1} failed — ${describe(result)}. Retrying in ${wait}ms (${maxRetries - attempt} left).`,
    );
    await sleep(wait);
  }

  const failure = result;
  const status = isRateLimited(failure) ? 'rate-limited' : 'failed';
  writeOutputs({
    status,
    'http-status': String(failure.status),
    attempts: String(attemptsMade),
  });
  throw new Error(
    `Dispatch of '${eventType}' to ${repository} gave up after ${attemptsMade} attempt(s): ${describe(failure)}.`,
  );
};

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});
