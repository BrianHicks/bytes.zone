---
{
  "type": "post",
  "title": "Bang Shortcuts",
  "summary": "stop typing things twice in the shell by using ! shortcuts",
  "published": "2020-08-31T00:00:00-05:00",
}
---

Another you-get-to-join-the-[lucky-ten-thousand](https://xkcd.com/1053/) post here!

There are a bunch of shortcuts involving exclamation marks that shells like Bash and ZSH will automatically expand.
There are so many things you can do with these ([see the "History Expansion" section of the Bash manual page](https://linux.die.net/man/1/bash)) so I just want to highlight a few of the ones I use every day:

- `!!` expands to the same command you just typed.
  For example, entering `!!` will just re-run your last command.
  More commonly, I have to do `sudo !!` to re-run the last command with `sudo`.
- `!$` expands to the last argument of the last command
  I use this pretty commonly to preview something that I've just generated, for example by doing `make dist/index.json` and then `jq . !$`.
- `!*` expand to all the arguments of the last command
  I use this one much less commonly, but it's helpful when I misspell a command, for example by typing `aid build monolith` at work, saying "ah shoot, again?" and then typing `aide !*`.

Some shells (ZSH at least) will automatically expand these for you if you hit tab after typing them so you can see what you're in for before you commit.
