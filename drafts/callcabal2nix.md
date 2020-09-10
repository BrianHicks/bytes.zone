---
{
  "type": "post",
  "title": "callCabal2nix",
  "summary": "you don't have to run cabal2nix all the time. There's a function to do it for you!",
  "published": "2020-08-31T00:00:00-05:00",
}
---

When you're setting up a Haskell project in Nix, most advice says "call `cabal init` and then `cabal2nix . > default.nix` to get a bunch of Nix stuff."

But it turns out you don't have to run `cabal2nix` by hand or keep it up to date at all.
[`pkgs.haskellPackages.callCabal2nix`](https://github.com/NixOS/nixpkgs/blob/34f475f5eae13d18b4e4b8a17aa7a772d8619b0b/pkgs/development/haskell-modules/make-package-set.nix#L216) produces the same thing, and you can use it in all the same ways.
It's not documented at all, so this post is more a reference for what's possible while the official docs don't mention the thing.
If you need to figure out more, [diving into the source is your best bet](https://github.com/NixOS/nixpkgs/blob/34f475f5eae13d18b4e4b8a17aa7a772d8619b0b/pkgs/development/haskell-modules/make-package-set.nix#L216).

The basic usage: give the project name, path to the project source, and a set of options to `callCabal2nix` (note the lowercase `n`.)

If you want something similar to the `default.nix` produced by the [`cabal2nix` instructions in the nixpkgs manual](TODO), put this in `default.nix`:

```
{ pkgs ? import <nixpkgs> { }; }:
pkgs.haskellPackages.callCabal2nix "name-of-your-haskell-project" ./. { }
```

The attrset in the final position there is args which are [finally passed to `callPackage`](https://github.com/NixOS/nixpkgs/blob/34f475f5eae13d18b4e4b8a17aa7a772d8619b0b/pkgs/development/haskell-modules/make-package-set.nix#L158).
Use those if you need to override some dependency or configuration.

If you were previously calling `cabal2nix` with command-line options, you can instead use [`callCabal2nixWithOptions`](https://github.com/NixOS/nixpkgs/blob/34f475f5eae13d18b4e4b8a17aa7a772d8619b0b/pkgs/development/haskell-modules/make-package-set.nix#L201-L214) (note again the lowercase `n`.)
The command-line arguments are just [a string which eventually get passed to `cabal2nix`](https://github.com/NixOS/nixpkgs/blob/34f475f5eae13d18b4e4b8a17aa7a772d8619b0b/pkgs/development/haskell-modules/make-package-set.nix#L136).

Oh and one final note: all the code links in this post are links to specific lines the repo as of the time of writing.
If you are trying to find more information in the future, you may want to switch to the `master` branch of nixpkgs and sniff around for `callCabal2nix` to get the most up-to-date view.
