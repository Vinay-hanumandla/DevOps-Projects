# last_verified: 2026-09-19 · gha n/a
#
# Minimal custom JavaScript action for GitHub Actions.
#
# This is the `main` entrypoint referenced by action.yml (`runs.using: 'node20'`).
# It is the smallest possible custom action: read two inputs, build a greeting,
# and expose two outputs back to the calling workflow through $GITHUB_OUTPUT.
#
# In a real repo this file lives next to its action.yml and a package.json that
# lists @actions/core as a dependency:
#   npm install @actions/core
# The action runs on the runner's Node 20 runtime, so no transpilation step
# is needed — plain CommonJS works.

const fs = require('fs');
const path = require('path');

// @actions/core is the official SDK for writing actions. It wraps the
// GITHUB_OUTPUT file and the exit-code conventions so you don't have to.
const core = require('@actions/core');

function readFileInput(name) {
  // Inputs arrive as string environment variables set by the runner.
  // Fall back to the action.yml default when the caller omitted the input.
  return core.getInput(name, { required: false }) || '';
}

function main() {
  try {
    const greeting = readFileInput('greeting') || 'Hello';
    const name = readFileInput('name') || 'world';

    const message = `${greeting}, ${name}!`;

    // core.setOutput writes to $GITHUB_OUTPUT; downstream steps read it back
    // as ${{ steps.<id>.outputs.message }}.
    core.setOutput('message', message);
    core.setOutput('length', String(message.length));

    core.info(`Action produced: "${message}" (${message.length} chars)`);
  } catch (err) {
    // setFailed prints the error and exits non-zero so the job is marked
    // failed — never let an action die with a zero exit code and no trace.
    core.setFailed(`minimal-custom-js-action failed: ${err.message}`);
  }
}

main();