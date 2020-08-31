---
{
  "type": "post",
  "title": git root"",
  "summary": "getting back to the root of a project quickly",
  "published": "2020-08-31T00:00:00-05:00",
}
---

I sometimes find myself in a situation where I've `cd`'d several levels into a project and don't remember exactly where I am, but I want to get back to the root for my next command.
This doesn't come up for me *alllll* the time, but the last time it did I decided to do something about it.

To cut this short: if you run `git rev-parse --show-toplevel`, `git` will print out the place where the repo is checked out into.
So I've just added a `root = "rev-parse --show-toplevel"` to my aliases and now I can do `git root` or `cd $(git root)`.
That makes this problem much less annoying for me!

Someone pointed out to me that I can probably also add an alias in my shell like `alias cdroot='cd $(git root)'` to make this even easier, but I haven't felt the need for that as urgently yet.
