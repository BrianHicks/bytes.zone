---
{
  "type": "post",
  "title": "Renaming Files with Braces",
  "summary": "a quick shell trick to save having to open finder",
  "published": "2020-08-31T00:00:00-05:00",
}
---

This has been well-documented elsewhere, but in the interests of helping someone else join [the lucky ten thousand](https://xkcd.com/1053/) today:
Bash, ZSH, and other shells often will expand text in braces into positional arguments.

For example, if you want to echo "cat car can" in the terminal, you could write `echo ca{t,r,n}`.
Some shells (ZSH at least) will even expand that if you hit `tab` so you can see what you're going to execute before you hit commit.

I find this most useful for renaming files:

- `mv someFile.txt{,.bak}` expands to `mv someFile.txt someFile.txt.bak`, adding the `.bak` extension
- conversely, `mv someFile.txt{.bak,}` removes the `.bak`
- `mv config/database.yml{.sample,}` expands to `mv config/database.yml.sample config/database.yml`
