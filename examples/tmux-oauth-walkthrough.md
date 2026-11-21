# tmux OAuth walkthrough - what the screens actually said

Sanitized snapshots from a real login on 2026-11-21, Antigravity CLI 1.5.14.
The email, the authorization code and the OAuth state values are replaced
with placeholders. Use these screens to decide your next keypress. Do not
replay a fixed key sequence - read the screen, then press.

## Screen 1 - login method

```
 Welcome to the Antigravity CLI. You are currently not signed in.

 Select login method:
 > 1. Google OAuth
   2. Use a Google Cloud project

   up/down Navigate - enter Select
```

The cursor starts on Google OAuth. One Enter is enough.

## Screen 2 - authorization link and code field

```
 Your browser should open automatically. If not:

 https://accounts.google.com/o/oauth2/auth?access_type=offline&client_id=<client-id>
 .apps.googleusercontent.com&code_challenge=<challenge>&code_challenge_method=S256&prom
 pt=consent&redirect_uri=https%3A%2F%2Fantigravity.google%2Foauth-callback&response_type=code&scope=...

 If you aren't automatically redirected, paste the authorization code below:

 authorization code...
```

Notes from the night this was recorded:

- The address is about 700 characters and arrives wrapped over 6 lines.
- `tmux capture-pane -p -J` did NOT rejoin these lines. The CLI wraps the
  text itself, so tmux sees hard line breaks. Join the fragments by hand
  in order, then check the result contains client_id, code_challenge and
  state with no spaces inside them.
- Widening the tmux window before starting (`-x 200` or more) reduces the
  number of fragments you have to join.

## Screen 3 - signing in

```
 Signing in...
```

The spinner can sit here for 20 seconds or more. Do not type into it.
Check the log instead:

```
grep "authenticated successfully" ~/.gemini/antigravity-cli/log/cli-*.log
```

Expect a line naming the account you intended, for example
`consumerOAuth: authenticated successfully as <dedicated-account>`.

## Screen 4 - color scheme

A first-run-only screen. The default (terminal) is fine. Enter moves on.

## Screen 5 - terms and data sharing

The checkbox "Yes, I agree to help improve Antigravity CLI by allowing
Google to collect and use my Interactions data" starts TICKED.

- Press Enter once to untick it. Read the screen again to confirm it
  shows `[ ]` and not `[x]`.
- Press Down to reach the Previous / Done row, then Right to land on
  Done, then Enter.

## Screen 6 - workspace trust

```
Accessing workspace:

<your current directory>

Do you trust the contents of this project?
Antigravity CLI requires permission to read, edit, and execute files here.

> Yes, I trust this folder
  No, exit
```

If this directory is your home directory, pick "No, exit" (Down, Enter).
Create a dedicated empty directory, start agy from inside it, and trust
only that directory.
