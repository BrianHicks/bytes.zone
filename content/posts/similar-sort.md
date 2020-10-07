---
{
  "type": "post",
  "title": "Fuzzy Finding with Levenstein Distance",
  "summary": "fuzzy find other files based on names most similar to the one you're editing",
  "published": "2020-10-06T08:18:00"
}
---

When I'm navigating around a codebase I know, I prefer to use a fuzzy file finder instead of browsing a directory tree.
Lowering the barrier to navigating between files is really helpful for me to move around a codebase quickly and get work done.
Ideally, I type a few characters and end up in the file that I was thinking of, quick as that.

But in late 2019, I got fed up trying to fuzzy-find files in my main repo at work.
It has something like 8,000 checked-in files and 170,000 untracked files (bundled gems, `node_modules`, etc.) so it took a long time to load all the files.
To add to that, `fzf`'s default configuration favors short matches near the beginning of the string.
When I'm deep in the project hierarchy, I want long matches with my term near the end first!

In short: my fuzzy matches became both *slow* and *irrelevant*.
Not a good combination for a tool meant to save me time!

Both of these things are fairly easy fixes on their own (I could sub in `git ls-files` for `find` to get matches and configure fzf to sort by long/end instead of short/beginning.)
But I decided that I wanted to improve my experience: in addition to end-of-filename matching, I want to favor matches for equivalent test files.
If I'm in a file and I type "spec" or "test" (depending on the language conventions) I should ideally get to the relevant test code.

Given that most test files have some name symmetry to the files they test (e.g. `app/models/user.rb`, `spec/models/user_spec.rb`), what I want is files that are named similarly to the file I'm currently editing.
Enter Levenshtein distance, an algorithm which calculates the amount of edits you'd have to change to change a string into another string.
For example:

- `a` to `ab` has an edit distance of 1, because you add `b`.
- `ab` to `a` also has an edit distance of 1, because you remove `b`.
- `a` to `b`, on the other hand, has an edit distance of... 1! The first time I looked at this, I thought it was 2 (add 1, remove 1) but replacements also count as a single operation!
- ok, more complex: `grammar` to `programmer` is 4. (add `pro`, replace `a` with `e`)

You can do this with any two strings, although it requires more calculations as the strings get longer.
Let's apply this to filenames!
Starting from `app/models/user.rb`, `spec/models/user_spec.rb` has an edit distance of 8, but a less similarly-named file, `app/controllers/admin_controller.rb`, has an edit distance of 22.

If we sort our candidate files by their edit distance from the source string, we can tell `fzf` that the input files are already in preference order (`--tiebreak=index`) and get exactly the editing experience I was after!

So, does this work?
I'm happy to report that it totally does!
I've been using similar-sort for about a year and a half now with no modifications, and I anticipate being able to use it as long as I need!

And now you can grab it as well at [git.bytes.zone/brian/similar-sort](https://git.bytes.zone/brian/similar-sort).
That repo includes instructions for building and installing, as well as integration with Kakoune and Vim.

It's licensed CC BY-SA 4.0 (since that's the license for the implementation of the Levenshtein distance implementation I grabbed from Wikipedia.)

Enjoy, and let me know if you use it!
