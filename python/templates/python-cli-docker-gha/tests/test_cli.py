# last_verified: 2026-09-13 · python n/a
"""Basic tests for the CLI."""

from __future__ import annotations

from click.testing import CliRunner

from cli.main import cli


def test_greet() -> None:
    runner = CliRunner()
    result = runner.invoke(cli, ["greet", "World"])
    assert result.exit_code == 0
    assert "Hello, World!" in result.output


def test_status() -> None:
    runner = CliRunner()
    result = runner.invoke(cli, ["status"])
    assert result.exit_code == 0
    assert "running" in result.output


def test_help() -> None:
    runner = CliRunner()
    result = runner.invoke(cli, ["--help"])
    assert result.exit_code == 0
    assert "scaffold" in result.output.lower()
