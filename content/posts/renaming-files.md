---
{
  "type": "post",
  "title": "Renaming Files with Braces",
  "summary": "shell syntax to make renaming or moving files much easier",
  "published": "2020-10-19T09:46:00-05:00",
}
---

This has been well-documented elsewhere, but in the interests of helping someone else join [the lucky ten thousand](https://xkcd.com/1053/) today:
Bash, ZSH, and other shells will expand comma-sepated arguments surrounded by braces into positional arguments.

As an altogether contrived example, imagine you want to echo "cat car can" in the terminal.
You could write `echo cat car can`, right?
But then you'd be writing `ca` twice.
That won't do!
We must be **maximally efficient**!

We can use brace expansion to only write `ca` once: `echo ca{t,r,n}`.
The shell will expand that to your original "cat car can."
Ta-da!

Next, say you want to add "bat bar ban" to the output.
Good news: the shell will expand more than one set of braces in the same word!
`echo {c,b}a{t,r,n}` will get you "cat car can bat bar ban".
Sweet!

So, back to real life... when is this actually useful?
Well, I use it all the time for renaming or moving files!

- `mv someFile.txt{,.bak}` expands to `mv someFile.txt someFile.txt.bak`, adding the `.bak` extension
- conversely, `mv someFile.txt{.bak,}` removes the `.bak`
- `mv config/database.yml{.sample,}` expands to `mv config/database.yml.sample config/database.yml`
- `cp {src,dist}/index.js` works great in `Makefile`s too!

Some shells (ZSH at least) will even expand that if you hit `tab` so you can see what you're going to execute before you hit commit.
Handy!
