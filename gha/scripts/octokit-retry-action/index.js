// last_verified: 2026-10-02 · gha n/a
'use strict';

const { Octokit } = require('@octokit/rest');

const readInput = (name, required = true) => {
  const envKey = `INPUT_${name.replace(/-/g, '_').toUpperCase()}`;
  const value = (process.env[envKey] || '').trim();
  if (required && !value) {
    throw new Error(`Required input '${name}' is empty.`);
  }
  return value;
};

const parseJsonInput = (name, required = false) => {
  const raw = readInput(name, required);
  if (!raw) return {};
  try {
    return JSON.parse(raw);
  } catch (e) {
    throw new Error(`Input '${name}' must be valid JSON: ${e.message}`);
  }
};

const sanitizeRepository = (repository) => {
  if (!/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(repository)) {
    throw new Error("Input 'repository' must use owner/name format.");
  }
  return repository;
};

const sanitizeEventType = (eventType) => {
  if (!/^[A-Za-z][A-Za-z0-9_-]*$/.test(eventType)) {
    throw new Error("Input 'event-type' must start with a letter and contain only alphanumeric, underscore, or hyphen characters.");
  }
  return eventType;
};

const parseIntInput = (name, value, min, max) => {
  const parsed = parseInt(value, 10);
  if (Number.isNaN(parsed) || parsed < min || parsed > max) {
    throw new Error(`Input '${name}' must be an integer between ${min} and ${max}.`);
  }
  return parsed;
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const isRetryableError = (error) => {
  if (!error.status) return false;
  return error.status === 403 && /rate limit/i.test(error.message) ||
         error.status === 408 ||
         error.status === 429 ||
         error.status >= 500;
};

const writeOutput = (name, value) => {
  const outputPath = process.env.GITHUB_OUTPUT;
  if (!outputPath) {
    throw new Error('GITHUB_OUTPUT is not set.');
  }
  const delimiter = `ghadelimiter_${Date.now()}_${Math.random().toString(36).slice(2)}`;
  const fs = require('fs');
  fs.appendFileSync(
    outputPath,
    `${name}<<${delimiter}\n${String(value)}\n${delimiter}\n`,
    'utf8',
  );
};

const main = async () => {
  const token = readInput('token');
  const repository = sanitizeRepository(readInput('repository'));
  const eventType = sanitizeEventType(readInput('event-type'));
  const clientPayload = parseJsonInput('client-payload');
  const maxRetries = parseIntInput('max-retries', readInput('max-retries', false) || '3', 0, 10);
  const baseDelayMs = parseIntInput('base-delay-ms', readInput('base-delay-ms', false) || '1000', 100, 60000);

  const [owner, repo] = repository.split('/');

  const octokit = new Octokit({
    auth: token,
    request: {
      fetch: fetch,
    },
  });

  let attempt = 0;
  let lastError;

  while (attempt <= maxRetries) {
    try {
      const response = await octokit.repos.createDispatchEvent({
        owner,
        repo,
        event_type: eventType,
        client_payload: clientPayload,
      });

      writeOutput('dispatch-id', String(response.data.id || ''));
      writeOutput('status', 'success');
      console.log(`Repository dispatch created successfully for ${repository} (event: ${eventType}).`);
      return;
    } catch (error) {
      lastError = error;
      if (!isRetryableError(error) || attempt === maxRetries) {
        break;
      }
      const delay = baseDelayMs * Math.pow(2, attempt);
      console.warn(`Attempt ${attempt + 1} failed with retryable error (${error.status}): ${error.message}. Retrying in ${delay}ms...`);
      await sleep(delay);
      attempt++;
    }
  }

  let status = 'failed';
  if (lastError && lastError.status === 403 && /rate limit/i.test(lastError.message)) {
    status = 'rate-limited';
  }
  writeOutput('dispatch-id', '');
  writeOutput('status', status);
  console.error(`Repository dispatch failed after ${attempt + 1} attempt(s): ${lastError?.message || 'Unknown error'}`);
  process.exitCode = 1;
};

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});