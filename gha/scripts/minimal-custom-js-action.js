// last_verified: 2026-09-19 · gha n/a
'use strict';

const fs = require('fs');

const name = process.env.INPUT_NAME || 'World';
const greeting = `Hello, ${name}!`;
const outputPath = process.env.GITHUB_OUTPUT;

if (!outputPath) {
  throw new Error('GITHUB_OUTPUT is not set');
}

const escapeOutput = (value) => value
  .replace(/%/g, '%25')
  .replace(/\r/g, '%0D')
  .replace(/\n/g, '%0A');

fs.appendFileSync(outputPath, `greeting=${escapeOutput(greeting)}\n`, 'utf8');
console.log(greeting);
