# kudo-claude-config

A drop-in config for [Claude Code](https://claude.com/claude-code) that makes Claude a sharper, more disciplined collaborator on any project.

## The four pillars

This config teaches Claude to work a specific way. Four ideas, in order of importance:

### 1. Do the homework
Before Claude answers, it should read the files, trace the paths, and check the edge cases. Effort goes into *investigating*, not into sounding thorough.

### 2. Say what matters
Short, direct responses. No filler, no hedging, no recaps of what you already know. The output should feel like a senior engineer's Slack reply — terse and useful.

### 3. Teach when it helps
When a decision is non-obvious, or when you ask *why*, Claude explains. Otherwise it just does the thing. You decide when you want a lesson.

### 4. Right-size the work
A typo fix shouldn't trigger a research phase. A new feature shouldn't skip planning. The config picks the right amount of process for each request automatically.

---

## Install

Open Claude Code in the project you want to configure, then paste this:

> Install the kudo-claude-config template into this project. The repo is https://github.com/zacdu/kudo-claude-config. Clone it somewhere, detect this project's language / build command / source directory from its config files, then run `init.sh -y` with the matching flags. When done, fill in the Architecture section of `CLAUDE.md` with the real source tree. Summarize what you installed.

Claude will do the rest.

For manual install or flag reference: `./init.sh --help` after cloning the repo.

---

## What you get

**A CLAUDE.md** at the project root (loaded automatically every session) plus a `.claude/` folder with four workflow skills — `small-feature`, `large-feature`, `debug`, `review` — that route automatically based on what you ask for. "Fix this typo" gets the quick path; "design a plugin system" gets the full research → plan → implement pipeline.

**Fresh-context phases for big work.** When Claude hits a large task, it doesn't try to hold the whole job in one session. It splits into phases — research, plan, implement — and runs each in its own brand-new Claude session. Each phase reads a file the previous phase wrote, does its job, and writes a file for the next one. You get to read and approve those files between phases. The payoff: long sessions drift and forget; fresh sessions stay sharp, and you stay in control of what gets handed forward.

**Caveman mode** (via a [Session Start hook](.claude/hooks/caveman-ultra.sh)) flips Claude into a heavily compressed communication style — fragments, abbreviations, arrows for cause-and-effect. It's not cute; it's a 50–75% token cut on every response. Faster, cheaper, same accuracy. (Requires the [caveman plugin](https://github.com/Jacck/caveman); remove the hook if you don't want it.)

**A knowledge wiki** that grows with your project, so Claude starts each session already knowing the architecture and past decisions instead of re-deriving them every time.

---

## Credits

Extracted from [pi-kudo](https://github.com/zacdu/pi-kudo), where these patterns were developed and validated.
