# Project
SwingTimerFader: a WoW **Forever** addon (Interface `16001`, Lua 5.1) that fades the built-in swing timer bars (`SwingTimerMainHandFrame`, `SwingTimerOffHandFrame`, `SwingTimerRangedFrame`) while they aren't in use. Melee and ranged groups fade independently.

- Files load in `.toc` order: Logger, Util, Config, Frames, Fader, Events, Slash, Options. A file may only use `ns.*` members from files above it at load time.
- Files share state through the addon namespace (`local ADDON, ns = ...`). No new globals beyond `STF_DB`, `STF_DB_CHAR` and `SLASH_*`.
- Never replace Blizzard methods or Show/Hide Blizzard frames (taint). Only `SetAlpha` on the outer frame, and observe with `hooksecurefunc`.
- Values from the game may be secret: check with `ns.IsSecret` and wrap risky API calls in `pcall`.
- Chat output goes through `ns.logger` (`Say` for players, `LogDebug/Info/Warning/Error` for diagnostics). Never call `print` directly.
- Allowed setting ranges live only in `ns.LIMITS`. Fade states live only in `ns.PHASE`.
- Blizzard UI source is not on disk. Learn client APIs from other addons in `..\` (e.g. FadeAnything, ForeverAuras, HunggysRing). Read only; don't copy their code (FadeAnything is GPL).
- Releases: GitHub Actions "Create Release" (`.github/workflows/release.yml`) stamps `## Version` into the `.toc` and zips the addon.

# Working rules
- Make the smallest change that solves the problem, but don't sacrifice clarity for conciseness
- Follow SOLID, DRY, KISS and YAGNI principles
- Reuse existing helpers and `ns` members before adding new ones. No new abstractions, data structures, files, or config options unless I ask. If you think one is needed, ask first.
- Explain changes in plain language: what changed, why, and its size (files/lines), but don't sacrifice clarity for conciseness.
- There is no build, lint or test suite. Re-read changed code for syntax errors and check every `ns.*` reference exists and loads earlier. Then give me the in-game steps to verify (`/console scriptErrors 1`, `/reload`, `/stf status`, what to try).
- If an in-game error I report looks unrelated to your change, stop and tell me before fixing it.
- If you try a fix and it fails once, stop and tell me before trying again.
- **NEVER commit.** Staging (`git add`) and read-only git commands (status, diff, log, show) are fine. Suggest a commit message instead.
- When a change affects commands, settings or behavior, update README.md in the same change.
- .claude/work/ is git-ignored.
- Research and plan files are task-specific. {taskId} is a unique ID you generate, e.g. a short slug plus hash.
- When continuing a task, ask me for the taskId or list .claude/work/.
- Keep code comments minimal: only explain non-obvious WoW behavior (taint, secret values, event meanings, why a guard exists).

# Workflow
For simple tasks such as typos, single functions, simple refactoring, straightforward bug fixes implement the change directly. For other more complex work, follow the Research, Plan and Implement (RPI) methodology, with the following extra instructions:
- First grilling session: interview me about the task before any planning or coding. Find extra instructions in Grill section.
- Research the code to better understand the requested change. Find extra instructions in Research section.
- Second grilling session: If necessary grill me about code details of the requested change. Find extra instructions in Grill section.
- Plan the change before doing anything and present me with a plan. Find extra instructions in Plan section.
- Finally, implement the approved plan-{taskId}.md, phase by phase if it has phases.

# Grill
Interview me about this task before any planning or coding.

Rules:
- Read the relevant code first so you don't ask things you can answer yourself.
- Ask ONE question at a time, with your recommended answer.
- Walk the decision tree: requirements, edge cases (melee vs ranged, dual wield, no off hand, combat lockdown, /reload mid-fight, death, disabled addon), constraints, what "done" means, what's explicitly out of scope.
- Stop when nothing material is ambiguous, then summarize the agreed requirements in a short list and ask me to confirm. Do not write code.
- Create/append the results of the grilling to .claude/work/research-{taskId}.md

# Research
Explore the codebase and write findings to .claude/work/research-{taskId}.md (append): relevant files and functions (with paths), how the current behavior works, existing helpers/`ns` members that could be reused, client APIs/events involved (and which addon in `..\` shows their use), and risks (taint, secret values, load order). Facts only, no proposals. Do not edit source code.

# Plan
Read .claude/work/research-{taskId}.md and write .claude/work/plan-{taskId}.md. (Overwrite)

Start with an honest size estimate (e.g. "3-line change in one file"). Then list exact changes per file. Every new function, file, or abstraction needs a one-line reason and the existing alternative you rejected. Include how to verify in game. Do not edit source code. Stop and wait for my review. If the change is too big, split the plan into multiple phases. After each phase first stop to ask for my feedback and review. After review is confirmed, ask for permission to launch next phase. Also remind me about the changes in the next phase.
