# bytes.zone

This is the code to produce [bytes.zone](https://bytes.zone).

## Working Locally

1. have `nix` installed (it's available for MacOS and Linux)
2. have `direnv` installed
3. `git clone`, `cd` into it, and run `direnv allow` to get the base dependencies
4. `npm install` to get the node dependencies
5. run `elm-pages develop` and start making changes.

## Deploying to Netlify

`git push` deploys to Netlify by default.
Configuration lives in `netlify.toml`.
Netlify *should* take care of all dependency installation, but it may need some massaging on a case-by-case basis.
