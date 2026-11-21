---
name: headless-antigravity-quota
description: Log a headless Linux agent into Antigravity CLI with a Google AI Pro account and offload text work to Gemini on the subscription quota. Use when an agent on a server or cloud VM needs to spend a Pro subscription instead of API credits.
---

# Headless Antigravity Quota

## Sort out the accounts first

- Tell the user plainly that a Google AI Pro subscription and the Gemini API are two separate bills. Calls made with an AI Studio API key never spend subscription quota.

- Tell the user that the Gemini CLI stopped serving personal accounts and AI Pro and Ultra subscribers on 2026-06-18. Treat any tutorial that promises 1000 free requests a day for a Google sign-in as out of date.

- Point the user at Antigravity CLI, the `agy` command, as the supported route for a Pro subscription. Expect two quota pools, one for Gemini models and one for Claude and GPT models, each with a five hour refresh and a weekly cap on Pro plans.

- Prefer a dedicated Google account that belongs to the agent for the login. Keep the user's personal account out of it so quota and privacy stay separate.

## Install and check the machine

- Check the basics with `muse.exec` before installing anything. Confirm `node -v` reports version 20 or later, `which tmux` finds tmux, and the machine is Linux or macOS on a supported architecture.

- Install Antigravity CLI with the official script `curl -fsSL https://antigravity.google/cli/install.sh | bash`. Read the first lines of the script before running it when the user wants to see what it does.

- Verify the install with `~/.local/bin/agy --version` and keep the version number for the report. Write the verified version and date into any notes, because the login screens change between releases.

## Log in through tmux

- Start the login inside tmux so the interactive screen survives between chat turns. Run `tmux new-session -d -s agy-login -x 120 -y 40 "$HOME/.local/bin/agy"` and give it a few seconds to draw.

- Read the screen with `tmux capture-pane -t agy-login -p` before every keystroke. Send one key with `tmux send-keys -t agy-login Enter` or `Down`, then read the screen again. Never replay a memorised key sequence, because a new release can add or remove a screen.

- Choose Google OAuth on the login screen. Wait until the screen shows an accounts.google.com address and a field asking for an authorization code.

- Rebuild the full OAuth address before sending it to the user. The terminal wraps the long address across several lines, so capture the pane and join the wrapped fragments in order, then check the joined string contains `client_id`, `code_challenge` and `state` with no spaces inside them.

- Send the rebuilt address to the user as a link and name the exact account to sign in with. Ask the user to finish the Google consent on their phone and send back the authorization code shown on the antigravity.google callback page.

- Paste the code into the tmux screen with `tmux send-keys -t agy-login -l "<code>"`, then send Enter. Never write the code into memory, a skill, a log file or a repository.

- Confirm the login from the CLI log under `~/.gemini/antigravity-cli/log/` instead of trusting the spinner. Look for a line that says it authenticated successfully as the expected account.

## Set the safety switches during first run

- Untick the data sharing checkbox on the terms screen before pressing Done. The box starts ticked and lets Google collect interaction data, and the user can turn it back on later in settings.

- Refuse the offer to trust the agent's home directory as the workspace. Exit that run, create a dedicated empty directory such as `~/agy-workspace`, and run `agy` from there from then on.

- Leave AI credit overages off. Check with `agy -p "/credits"` and expect a balance of 0, so a busy week ends with waiting for a refresh instead of a bill.

- Lock the token store down after login with `chmod -R 700 ~/.gemini`. Treat everything under that directory as a credential.

## Verify before promising anything

- Run `~/.local/bin/agy models` from the dedicated directory and read the real model list back to the user. Expect Gemini models plus separate Claude and GPT entries on a Pro login.

- Run one harmless test prompt through `agy -p` and show the user the actual answer. Report how long it took, because the high reasoning models can take minutes on a long prompt.

- Run `agy -p "/usage"` and report both pools with their remaining percentages and reset times. Treat a five hour pool as the sign of a Pro tier login, since free accounts only get the weekly refresh.

## Call Gemini for real work

- Call `agy` through a wrapper that changes into the dedicated directory, sets a timeout, strips ANSI escape codes and names the model on every call. Keep a copy of the wrapper beside this skill when one exists.

- Name the model explicitly with `--model` on every headless call. Leave the default alone and a configuration drift can quietly spend the smaller Claude and GPT pool.

- Pick the model by the job. Use a Flash tier model for summaries, translation and other quick text work, and save the Argon high model for reviews and hard reasoning.

- Wrap every headless call in a timeout of 180 seconds or less. A call that hits an expired token can fall back to the login screen and hang forever instead of failing.

- Check the output for sign-in complaints before trusting an empty or odd answer. When a call times out or reports a login problem, stop and ask the user to redo the tmux OAuth login instead of retrying in a loop.

- Run the usage check before a big batch of offloaded work. Pause the offloading and tell the user when a pool drops under 10 percent.

## Available connectors

- Use `muse.connector_search` to find other connectors and `muse.skill_search` to find related skills.

- If nothing here fits, look on the web for a maintained API or MCP server and set it up with the custom connector setup skill, or build a custom connector.

## Alternatives for better results

- Fall back to an AI Studio API key when the user has no AI Pro subscription. Explain first that this spends API quota or money, never the subscription.

- Fall back to asking Gemini in the browser at gemini.google.com when the user only has a one-off question and does not want anything installed. Expect this to be slow and to break whenever the login state changes.
