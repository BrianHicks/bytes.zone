---
{
  "type": "post",
  "title": "tmux-session",
  "summary": "tmux-session, a little script to create and fast-switch between tmux sessions",
  "published": "2020-04-16T00:00:00",
}
---

I wrote a little script to create and fast-switch between different [tmux](https://github.com/tmux/tmux/wiki) sessions, and thought I'd share it real quick so others can use it too.
It's got two composable components you can use in your own stuff:

## The Script Itself

If I'm not running the right tmux session, I run `tmux-session`.
If I'm not in a tmux client (that is, just in a plain shell) it creates a session with a nice name and opens it.
If such a session already exists, it switches to it instead.
This works inside a client too!
The point is for it to always do the right thing so I don't have to think about the four cases: outside and inside a client, with the target session existing or not.

The session names are based on git checkouts, when possible.
If you invoke the script from within a git checkout, it'll find the root of the project (the directory containing `.git`) and name the session after it.
If you're outside a git checkout, it'll name the session after the current directory.

Here's the commented shell script that you can stick somewhere in your `$PATH`:

```sh
#!/usr/bin/env bash
set -euo pipefail

# find the project root directory by examining each parent starting from the
# current directory. If you use a different VCS, you can change `$ROOT/.git`
# below to something else: for example, Mercurial would use `$ROOT/.hg`.
ROOT="${1:-$(pwd)}"
while ! test -d "$ROOT/.git" && test "$ROOT" != "/"; do
  ROOT=$(dirname $ROOT)
done

# if we walked all the way up and hit the root directory, just name the
# session after the current directory. Handy for creating sessions when
# you're working in directories like ~/Downloads that won't be tracked
# with git.
if test "$ROOT" = "/"; then
  ROOT=$(pwd)
fi

# tmux doesn't allow dots in session names, so we replace them with
# dashes. This shows up surprisingly often in my life! For example, my dotfiles
# repo is named `dotfiles.nix`, which gets normalized to `dotfiles-nix`. This
# is close enough to the actual name that I know what I'm selecting when I
# switch to it.
SESSION=$(basename $ROOT | sed 's/\./-/g')

# are we in a tmux client already? If we are, `$TMUX` will be set.
if test -z "${TMUX:-}"; then
  # ah, we're not in a client? Create a session and enter it! Some quirk in
  # my installation make the TMUX_TMPDIR and -u2 necessary when starting
  # the server; you may not need it.
  exec env TMUX_TMPDIR=/tmp tmux -u2 new-session -As "$SESSION" -c "$ROOT"
else
  # we're already in a client? Neat. Let's make a new session with the
  # target name in the background...
  if ! tmux has-session -t "$SESSION" > /dev/null; then
    tmux new-session -ds "$SESSION" -c "$ROOT"
  fi
  # ... and then switch our current client to it!
  exec tmux switch-client -t "$SESSION"
fi
```

## The Quick Jumper

I like to be able to jump between project directories quickly by just typing a couple letters of their name.
[`fzf`](https://github.com/junegunn/fzf) helps a lot here!

Here's the commented ZSH source (but I *think* this would work in bash as well!)

Note that this assumes my own checkout pattern (I check out all repos like `~/code/owner/project` and have some git aliases to manage that for me.)
You could just as easily adapt it to your own checkout patterns, or just a commonly used projects list that you keep as a file (just pipe that into fzf!)

```sh
tmux_jump() {
    # starting in ~/code...
    BASE="$HOME/code"
    # ... look for directories exactly two levels deep (`~/code/owner/project`)
    # and match them with fzf. In this case we break ties by favoring matches
    # on the project name instead of the owner name (implementaion means
    # favoring matches closer to the end of the string.) This is simplified a
    # little bit with the `--select-1 --query="$1"` line: if there's only one
    # match for the argument passed in as the first argument to this function,
    # we select immediately instead of asking for an interactive selection.
    SELECTED=$(find "$BASE" -mindepth 2 -maxdepth 2 -type d | sed "s|$BASE/||g" | fzf --tiebreak=end --select-1 --query="$1")

    # fzf will exit with a non-zero code if you ctrl-c or ctrl-g out of
    # it. We use this as a signal that we don't want to jump after all.
    if [[ "$?" != 0 ]]; then echo "cancelling!"; return 1; fi

    # call tmux-session on the *full* path to the matched project!
    tmux-session "$BASE/$SELECTED"
}

# and alias this so I can just do `t bytes.zone` instead of having to type
# tmux_jump every time.
alias t=tmux_jump
```

And... that's it!
Hope you enjoy it!
