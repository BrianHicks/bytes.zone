---
{
  "type": "post",
  "title": "Bang Shortcuts",
  "summary": "stop typing things twice in the shell by using ! shortcuts",
  "published": "2020-08-31T00:00:00-05:00",
}
---

Another you-get-to-join-the-[lucky-ten-thousand](https://xkcd.com/1053/) post here!

There are a bunch of shortcuts involving exclamation marks that shells will automatically expand.
There are so many things you can do with these!
([See the "History Expansion" section of the Bash manual page](https://linux.die.net/man/1/bash))
I just want to highlight a few of the ones I use every day:

- `!!` expands to the same command you just typed.
  For example, entering `!!` will just re-run your last command.
  You can use this to fix goof-ups.
  For example, `sudo !!` will re-run the last command with `sudo` prepended.
  Perfect for when you `apt-get install` something as your login user instead of `root`.

- `!$` expands to the last argument of the last command
  I mostly use this to perform several operations on the same file.
  For example, I `mv config/database.yml.sample config/database.yml`, then `kak !$` to edit it to customize.
  I also use this frequently to preview something that I've just generated.
  For example, `make dist/index.json` and then `less !$` (or `jq . !$` to pretty-print JSON!)

- `!*` expands to all the arguments of the last command
  I don't use this one as much, but it's helpful when I misspell a command.
  For example, I use a tool called `aide` at work.
  I often misspell it (e.g. `aid build monolith`), say "ah shoot, again?" and then correct with `aide !*`.

Some shells (ZSH at least) will automatically expand these for you if you hit tab after typing them so you can see what you're in for before you commit.
