---
{
  "type": "post",
  "title": "Fuzzy Finding with Levenstein Distance",
  "summary": "fuzzy find files based on names most similar to the one you're editing",
  "published": "2020-08-31T00:00:00-05:00",
}
---

When I'm navigating around a codebase, I prefer to use a fuzzy file finder instead of browsing a directory tree.

But, late last year, I got fed up trying to fuzzy-find files in my main work repo.
It has something like 8,000 checked-in files and 170,000 untracked files (bundled gems, `node_modules`, etc.) so it took a long time to load all the files.
To add to that, `fzf.vim`'s default configuration favored short matches near the beginning of the string.
When I'm deep in the project hierarchy, I want long matches with my term near the end first!

Both of these things are fairly easy fixes on their own (I could search over `git ls-files` and configure fzf to sort by long/end instead of short/beginning.)
But I decided that I wanted to improve my experience: in addition to end-of-filename matching, I want to favor matches for equivalent test files.
if I'm in a file and I match on "spec" or "test" (depending on the language conventions) I should ideally get to the relevant test code.

So, how would I do that?
Levenshtein distance!
Basically, the Levenshtein distance shows the amount of edits (additions, deletions, and replacements) you'd have to change to get from string `a` to string `b`.
Some samples may make this clearer:

- `a` to `ab` has an edit distance of 1, because you add `b`.
- `ab` to `a` also has an edit distance of 1, because you remove `b`.
- `a` to `b`, on the other hand, has an edit distance of... 1!
  The first time you look at this, you might think it's 2 (add 1, remove 1) but replacements also count as a single operation!
- ok, more complex: `grammar` to `programmer` is 4.
  (add `pro`, replace `a` with `e`)

You can do this with any two strings, although it requires more calculations as the strings get longer.

TODO: did it work? Yes!

The code to do this is not too bad either, but to be honest, I wanted to explore how it felt to do fuzzy finding this way more than I wanted to spend time learning the intricacies of the Levenshtein algorithm, so I just grabbed some [code off of WikiBooks](https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Go) and released the resulting package under the same license (CC BY-SA 3.0.)
You can grab it at [git.bytes.zone/brian/similar-sort](https://git.bytes.zone/brian/similar-sort).
That repo includes instructions for building and installing, as well as integration with `vim` and `kak`.

Enjoy, and let me know if you use it!
