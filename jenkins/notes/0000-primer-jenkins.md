---
last_verified: 2026-08-11
tool_version: n/a
sources: []
---

# Jenkins — quick primer

> First-day notes for someone who's never used Jenkins. Personal voice, plain language.

## What is it?

Jenkins is an automation server that lets me schedule and run jobs — the classic example being "build and test my code every time someone pushes a commit." I'd heard it called a CI/CD server, but really the core of it is simpler than that: you tell Jenkins about jobs, define what each job should run (download code, run tests, package an artifact), and Jenkins runs them for you, on a schedule or on a trigger, and records the results.

If Git is to code what a filing cabinet is to documents — a place to store and track them — Jenkins is more like an assembly line: it picks up inputs, runs the steps you've configured, and hands you the output (and a log showing each step). It's the "boring worker robot" of the toolchain: it does the tedious build steps exactly the same every time, which is the whole point.

## What does it do?

It has a web UI where I can create and watch jobs, a server that runs those jobs on worker machines, and a place to store build history, console output, and artifacts after each run. You define jobs either through the UI or as a `Jenkinsfile` checked into your repository, and Jenkins executes them step by step. It plugs into version control systems, containers, cloud platforms, and dozens of other tools via plugins.

## Why does it exist?

Before automation servers existed, building software usually meant a human running commands on their own computer — "works on my machine" was the joke and the problem. Someone would have to remember every step, do them in the right order, and keep consistent. Jenkins (and its ancestor Hudson) solved that by moving those known steps onto a server that runs them on every trigger, so the build happened in a clean, repeatable way instead of on someone's laptop. The "it builds on my machine" excuse disappears when the machine is the server. Teams use it daily to catch broken commits early instead of finding the break at release time.

## Key terminology

- **Job** — a single unit of work you've defined for Jenkins to run. Example: "build the backend, run the unit tests."
- **Pipeline** — a job defined as code in a `Jenkinsfile`, describing stages like checkout → build → test → deploy. Example: a `pipeline { stages { … } }` block.
- **Node** — a machine Jenkins can run jobs on. Example: the main Jenkins server, or a separate agent you connect to it.
- **Executor** — a slot on a node for running one job step at a time. Example: a node with 2 executors can run 2 jobs concurrently.
- **Plugin** — an add-on that gives Jenkins new capabilities (Git integration, Docker, Slack notifications). Example: the "Git plugin" that lets a job clone a repo.
- **Workspace** — the folder on a node where Jenkins checks out the code for a job and runs the steps. Example: `…/workspace/<job-name>/src/`.
- **Build** — one execution of a job. Example: "build #42" is the 42nd time the job ran.
- **Trigger** — what causes a build to start. Example: a webhook fired when a commit is pushed, or a cron schedule.
- **Console output** — the full log of what a build printed while running. Example: checking this when a test fails to see the failure message.
- **Jenkinsfile** — the pipeline-as-code file living in the repo so job definitions are versioned. Example: `Jenkinsfile` at the root of a project.

## A tiny example

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building my first pipeline'
            }
        }
    }
}
```

> A minimal declarative pipeline: Jenkins runs the single "Build" stage on any available node and echoes one line. Paste it into a pipeline job's script box and hit **Build Now** to see a run appear in history.

## What I'll cover next

My plan after this primer is to get Jenkins running locally — install it, open the web UI for the first time, and create a hello-world pipeline job from this example — then start wiring up a job that actually checks out code from a repo. That gets me from "Jenkins is a robot that runs jobs" to my first real build.