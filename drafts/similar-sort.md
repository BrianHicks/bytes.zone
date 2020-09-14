---
{
  "type": "post",
  "title": "Fuzzy Finding with Levenstein Distance",
  "summary": "fuzzy find files based on names most similar to the one you're editing",
  "published": "2020-08-31T00:00:00-05:00",
}
---

When I'm navigating around a codebase, I prefer to use the fuzzy file finder in my editor to just jump to the filename I mean.
I find it a lot quicker than using a directory hierarchy once I know a codebase.

But, late last year, I got fed up trying to fuzzy-find files in my main work repo.
It has something like 8,000 checked-in files and 170,000 untracked files (bundled gems, `node_modules`, etc.)
This mean that it took a long time to load all the files in my fuzzy finder!
To add to that, `fzf.vim`'s default configuration favored short matches near the beginning of the string.
When I'm deep in the project hierarchy, I want long matches with my term near the end first!

Both of these things are fairly easy fixes on their own (I could search over `git ls-files` and configure fzf to sort by long/end instead of short/beginning.)
But I decided that I wanted to improve my experience... because in addition to end-of-filename matching, I want to match spec files easily.
if I'm in a file and I match on "spec" or "test" (depending on the language conventions) I should ideally get to the relevant spec.

So, how would I do that?
Levenshtein distance!
Basically, the Levenshtein distance is the amount of edits (additions, deletions, and replacements) you'd have to change to get from string `a` to string `b`.
Some samples may make this clearer:

- `a` to `ab` has an edit distance of 1, because you add `b`.
- `ab` to `a` also has an edit distance of 1, because you remove `b`.
- `a` to `b`, on the other hand, has an edit distance of... 1!
  The first time you look at this, you might think it's 2 (add 1, remove 1) but replacements count as a single operation!
- ok, more complex: `grammar` to `programmer` is 4.
  (add `pro`, replace `a` with `e`)

You can do this with any two strings, although the time complexity gets worse as the strings get longer.

The code to do this is not too to be, but to be honest, I wanted to explore how it felt to do fuzzy finding this way more than I wanted to spend time learning the intricacies of the Levenshtein algorithm.
So I just grabbed some [code off of WikiBooks](https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Go) and released the resulting package under the same license (CC BY-SA 3.0.)

And now the tool that I use is available for everyone!
You can grab it at [git.bytes.zone/brian/similar-sort](https://git.bytes.zone/brian/similar-sort).
That repo includes instructions for building and installing, as well as integration with `vim` and `kak`.

Enjoy, and let me know if you use it!
