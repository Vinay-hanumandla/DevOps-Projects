---
last_verified: 2026-09-22
tool_version: n/a
---

# What tripped me up setting up my first Jenkins controller

I got a fresh Jenkins controller running this week and tried to turn it into something I could actually build with: a few plugins, one agent, and credentials that a pipeline can use. The install itself was fine. Everything after that took longer than I expected.

## Following the setup wizard and picking plugins

I went through the setup wizard and picked the suggested plugins to start. That gave me a working dashboard quickly, and I could create a freestyle job that echoed hello. So far so good.

Then I tried to add the plugins I actually wanted for pipelines and Git checkout. I installed them from Manage Jenkins → Plugins → Available plugins, and Jenkins asked me to restart. I did not expect that some plugins need a restart while others apply immediately, so my first attempt at using a just-installed pipeline step failed with a "not found" style error. Restarting from the UI fixed it, and after that the new steps showed up.

What I would do differently: install the full plugin set I need up front, restart once, and only then start writing jobs. Installing one plugin at a time with a restart between each one wasted a lot of cycles.

## Got stuck on agents

I assumed the controller could just run everything itself, and for a toy job it can. But the docs I was following kept saying to add an agent, so I tried adding a permanent agent from Manage Jenkins → Nodes. I created the node, and Jenkins showed it as offline with a launch command I did not understand at first.

It took me a while to realize the agent is a separate process that has to connect back to the controller — creating the node entry is only half the job. I ran the launch command on the agent machine, and the node flipped to online. After that I could tie a pipeline to it with `agent { label 'my-agent' }` and watch the build actually run there instead of on the controller.

The confusing part was labels. I named the node one thing and used a slightly different label in the Jenkinsfile, so the build just sat in the queue saying it was waiting for an executor. Matching the label string exactly fixed it. The queue message does tell you what label it is waiting for, but I did not read it carefully the first time.

## Got stuck on credential stores

Next I tried to check out a private repo, which needs credentials. I went to Manage Jenkins → Credentials, added a username/password entry in the global store, and gave it an ID. Then in my pipeline I referenced that ID in a `checkout` step.

My first attempt failed because I typed the credentials ID from memory and got one character wrong. The error message said the credentials could not be found, which at least pointed at the right place. I copied the ID from the credentials page instead of retyping it, and the checkout worked.

The other thing that surprised me: credentials are scoped to stores, and a pipeline can only see the ones in scope for its job. Keeping everything in the global store while I am learning avoids that problem. I can see why folder-scoped stores exist for teams, but for a first controller the global store is simpler.

## What worked

Once the agent was online and the credentials ID matched, a small declarative pipeline checked out my repo and ran on the agent. Seeing the build log show the agent name instead of the built-in node was the moment it clicked — the controller schedules, the agent executes.

## What I'd try next

I want to move the Jenkinsfile into the repo itself and let Jenkins pick it up from source control instead of pasting script into the job config. I also want to try a token-style credential for the Git host rather than a password, since that seems to be the recommended pattern. Small steps from here.
