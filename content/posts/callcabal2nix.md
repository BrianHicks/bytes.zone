---
{
  "type": "post",
  "title": "callCabal2nix",
  "summary": "you don't have to run cabal2nix all the time. There's a function to do it for you!",
  "published": "2020-09-22T11:04:00-05:00",
}
---

When you're setting up a Haskell project in Nix, most advice says "call `cabal init` and then `cabal2nix . > default.nix` to get a buildable Haskell project."

But it turns out you don't have to run `cabal2nix` by hand to keep it up to date!
[`pkgs.haskellPackages.callCabal2nix`](https://github.com/NixOS/nixpkgs/blob/34f475f5eae13d18b4e4b8a17aa7a772d8619b0b/pkgs/development/haskell-modules/make-package-set.nix#L216) does the same thing as `cabal2nix`, but without writing a file.
The nixpkgs manual doesn't mention it since it uses import-from-derivation, [which can cause some problems with Hydra](https://github.com/NixOS/nixpkgs/issues/16130#issuecomment-229939552) but I've found it super helpful so I'm writing it up!
If you need more detail than what I've written here, [diving into the source is probably your best bet](https://github.com/NixOS/nixpkgs/blob/34f475f5eae13d18b4e4b8a17aa7a772d8619b0b/pkgs/development/haskell-modules/make-package-set.nix#L216).

The basic usage: call `pkgs.haskellPackages.callCabal2nix` (note the lowercase `n` in `nix`) with...

1. the project name
2. the path to the project source
3. the set of options you'd normally provide to a call to the stuff `cabal2nix` generates

If you want something similar to the `default.nix` produced by the [`cabal2nix` instructions in the nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/#haskell), put this in `default.nix`:

```nix
{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.haskellPackages.callCabal2nix "name-of-your-haskell-project" ./. { }
```

`callCabal2nix` is always a sibling of `ghcWithPackages`, so you can pin your compiler version in the same way:

```nix
{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.haskell.packages.ghc865.callCabal2nix "name-of-your-haskell-project" ./. { }
```

If you rely on getting a build environment with `cabal2nix`, the output `callCabal2nix` has a `.env` which you can provide to a `mkShell`'s `inputsFrom` stanza:

```nix
{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.mkShell {
  inputsFrom = [ (pkgs.haskellPackages.callCabal2nix "project" ./. { }).env ];
}
```

If you were previously calling `cabal2nix` with command-line options, you can instead use [`callCabal2nixWithOptions`](https://github.com/NixOS/nixpkgs/blob/34f475f5eae13d18b4e4b8a17aa7a772d8619b0b/pkgs/development/haskell-modules/make-package-set.nix#L201-L214) (again, note the lowercase `n` in `nix`.)
This form adds a string before the final argument [which is eventually used literally in a call to `cabal2nix`](https://github.com/NixOS/nixpkgs/blob/34f475f5eae13d18b4e4b8a17aa7a772d8619b0b/pkgs/development/haskell-modules/make-package-set.nix#L136).

That's it!
Enjoy not having to write `make` rules to call `cabal2nix`!

Oh and one final note: all the code links in this post are links to specific lines the repo as of the time of writing.
If you are trying to find more information in the future, you may want to switch to the `master` branch of nixpkgs and sniff around for `callCabal2nix` to get the most up-to-date view.
