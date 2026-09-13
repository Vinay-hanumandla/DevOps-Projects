# last_verified: 2026-09-13 · python n/a
"""CLI entry point using Click."""

from __future__ import annotations

import click


@click.group()
@click.version_option(package_name="my-cli-tool")
def cli() -> None:
    """my-cli-tool — a scaffold for Python CLI projects."""


@cli.command()
@click.argument("name")
def greet(name: str) -> None:
    """Greet someone by name."""
    click.echo(f"Hello, {name}!")


@cli.command()
def status() -> None:
    """Print tool status."""
    click.echo("my-cli-tool is running.")


if __name__ == "__main__":
    cli()
