// last_verified: 2026-09-25 · gha n/a
'use strict';

const fs = require('fs');

const readInput = (name, required = true) => {
  const value = (process.env[`INPUT_${name.toUpperCase()}`] || '').trim();
  if (required && !value) {
    throw new Error(`Required input '${name}' is empty.`);
  }
  return value;
};

const validateInputs = () => {
  const repository = readInput('repository');
  const token = readInput('token');
  const label = readInput('label');
  const state = readInput('state', false) || 'open';

  if (!/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(repository)) {
    throw new Error("Input 'repository' must use owner/name format.");
  }
  if (!token) {
    throw new Error("Input 'token' is required.");
  }
  if (!label) {
    throw new Error("Input 'label' is required.");
  }
  if (!['open', 'closed', 'all'].includes(state)) {
    throw new Error("Input 'state' must be 'open', 'closed', or 'all'.");
  }

  return { repository, token, label, state };
};

const writeOutput = (name, value) => {
  const outputPath = process.env.GITHUB_OUTPUT;
  if (!outputPath) {
    throw new Error('GITHUB_OUTPUT is not set.');
  }

  const delimiter = `ghadelimiter_${Date.now()}_${Math.random().toString(36).slice(2)}`;
  fs.appendFileSync(
    outputPath,
    `${name}<<${delimiter}\n${String(value)}\n${delimiter}\n`,
    'utf8',
  );
};

const requestJson = async (apiBase, token, path) => {
  const response = await fetch(`${apiBase}${path}`, {
    headers: {
      accept: 'application/vnd.github+json',
      authorization: `Bearer ${token}`,
      'user-agent': 'custom-js-action',
    },
  });

  if (!response.ok) {
    let detail = '';
    try {
      detail = await response.text();
    } catch {
      detail = 'response body unavailable';
    }
    throw new Error(`GitHub API request failed for ${path} with status ${response.status}: ${detail}`);
  }

  return response.json();
};

const main = async () => {
  const { repository, token, label, state } = validateInputs();
  const apiBase = (process.env.GITHUB_API_URL || '').replace(/\/+$/, '');
  if (!apiBase) {
    throw new Error('GITHUB_API_URL is not set.');
  }

  await requestJson(apiBase, token, `/repos/${repository}`);
  const query = new URLSearchParams({
    labels: label,
    per_page: '100',
    state,
  });
  const issues = await requestJson(apiBase, token, `/repos/${repository}/issues?${query}`);
  const issueUrls = issues
    .map((issue) => issue.html_url)
    .filter((url) => typeof url === 'string');

  writeOutput('count', String(issues.length));
  writeOutput('issue-urls', issueUrls.join('\n'));
  writeOutput('issues-json', JSON.stringify(issues, null, 2));
  console.log(`Found ${issues.length} issues labeled '${label}' in ${repository}.`);
};

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});
