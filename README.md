# Wombat - WIP

Wombat is a "proving" project for me. While I have built many chatbots and agentic systems, this project is to
combat my imposter syndrome by doing.

## Expectations

### What to expect

This project is something I am working on while job searching.
The final outcome is not to have a commercial grade harness, but a harness that is easily readable,
that demonstrates a knowledge of the principles and building blocks that comprises one.

### Why Ruby? Doesnt everyone use python?

Ruby is my first real Language Love. Its a simple language and anyone should be able to read this codebase and follow it.
Python is great for gluing together AI primitives/libraries, but we are not the AI here, we are just calling it.

### When will it be finished?

This is to keep me relevant and have a code project to ensure my skills are not becoming stale.
There is no deadline, and profesionally I would find that mortifying, but its oddly motivating not having one for something personal.
I sure do want to finish this, but if it never does get finished I am also ok with that.

### Are you writting this by hand? Are you mad?

Yes I am! This isnt a commercial product, this is for my own benefit.
In this instance I dont want to offload the experience.

## Getting Started

Currently the project assumes you are running ollama locally.
I intend to update the compose file soon to have ollama run as a service.
In the meantime ensure ollama is accessible on port 11434 at localhost.

To run the harness, run
```bash
docker-compose run harness
```

Note: I personally use podman so all compose features are currently podman compatible.

