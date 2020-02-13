---
{
  "type": "post",
  "title": "Reducing Asset Size With Subsetting",
  "published": "2020-02-06T22:14:00",
}
---

When I was building this site, I noticed that my web fonts were kind of big:

```
52K	fonts/OpenSans.woff2
48K	fonts/Exo2-BoldItalic.woff2
24K	fonts/Jetbrains-Mono.woff2
48K	fonts/OpenSans-Italic.woff2
48K	fonts/Exo2-Regular.woff2
48K	fonts/Exo2-Bold.woff2
48K	fonts/OpenSans-BoldItalic.woff2
52K	fonts/OpenSans-Bold.woff2
368K	total
```

If you happened to load all the fonts with a cold cache, you'd be downloading a bit over a third of a megabyte.
These were by far the heaviest part of the site, especially compared to the HTML files.
Those are something like 12kb each, a quarter of the size of even one font.
I don't like that difference, so let's see if we can make them smaller!

But what's in those files anyway?
Why are they so big?
Consider [Exo 2](https://github.com/NDISCOVER/Exo-2.0), my heading font: in addition to the normal ASCII characters, it has a ton of Greek, Cyrillyic, and Vietnamese characters.
This is great!
Tons of people speaking all kinds of languages can use this font to communicate… but I never use those characters on *my* site, so why should I serve them?

Fortunately, this is a known problem, and we can solve it with something called [subsetting](https://en.wikipedia.org/wiki/Subsetting).
Subsetting, in general, is where you retrieve only the parts you need from a large data set.
In fonts, this means removing all the glpyhs you don't need from a font before you serve it.
Sounds like a plan!
But how?

## Breaking it Down

Well, since this is a static site, all the content is known in advance.
Hypothetically, that means that I can examine all the markdown files and figure out what characters I need to render it.
But when I thought about this more, I realized it wouldn't work: what about the navigation and footer?
I also render headers and code samples in different fonts than I do the body copy.

Well, again, static site!
I can surely just inspect the output, right?
But another challenge there: the exact font—including things like bold and italic—is set with CSS.
Since normal, bold, and italic live in separate files, I need to calculate the style rules the way a browser would to be able to make the smallest possible subsets.

But that means… oh… I should probably just drive a headless browser, huh?

Sigh.

### Accepting the Inevitable

I really didn't want to set up a headless browser for this.
I had some bad experiences in the past trying to automate things with Selenium, not to mention all the pain I feel writing Capybara tests at work…
I felt like it would be slow, error-prone, and be hard to set up in [Netlify](https://www.netlify.com).

Well, good news if you're in the same boat: the [Puppeteer](https://pptr.dev) project makes this way easier than it used to be!
I evaluated several options (including Servo and jsdom) before settling on it, and I was happily surprised!

## Get the Data, Already!

The basic strategy here looks like:

1. start a headless Chrome instance with puppeteer
2. load an HTML page
3. find all the visible text nodes
4. remember their content and computed style

That's it; let's go!
First we start the browser and load a page:

```javascript
(async () => {
  const puppeteer = require("puppeteer");
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  // in the real script I'm looping over the files in process.argv.slice(2)
  await page.goto("file://" + __dirname + "dist/index.html");
  
  // the rest of our script (next code block)
})();
```

Aside: I don't know if these should be `const` or `let`... I've heard both but the puppeteer docs use `const` so I'm going to, too

Then let's walk the DOM to find all the text nodes:

```javascript
const fileOut = await page.evaluate(function() {
  // we have to define everything we need inline here, since `page.evaluate`
  // runs everything in the browser context.
  function uniqChars(text) {
    let out = [];
    for (let char of text) {
      if (!out.includes(char)) {
        out.push(char);
      }
    }
    out.sort();
    return out.join("");
  }
  
  todo = [window.document];
  out = {};
  while (todo.length !== 0) {
    let node = todo.shift()
    
    for (var i = 0; i < node.childNodes.length; i++) {
      todo.push(node.childNodes[i]);
    }
    
    if (node.nodeName === "#text") {
      // the rest of our script (next code block)
    }
  }
});
```

And finally we can accumulate our calculated styles.
I do this in an object with the style information as the key so we can add characters to it easily:

```javascript
let styles = window.getComputedStyle(node.parentElement);

// we don't want to include text in invisible nodes (things like the guts of
// <script> or <style> tags.) Just skip 'em!
if (styles.display === "none") {
  continue;
}

for (let face of styles.fontFamily.split(", ")) {
  // fonts with spaces in the name get quoted, so we need to remove those.
  face = face.replace(/"/g, "", -1);
  
  let info = {
    face: face,
    weight: styles.fontWeight,
    style: styles.fontStyle
  };
  let key = JSON.stringify(info);
  
  if (out[key]) {
    out[key].chars = uniqChars(out[key].chars + node.textContent);
  } else {
    out[key] = {
      font: info,
      chars: uniqChars(node.textContent)
    };
  }
}
```

Finally, after analyzing each file, we combine the objects into a list.
(I haven't shown this but you can see it [in the source as of this writing](https://git.bytes.zone/bytes.zone/bytes.zone/src/commit/7d957f13a7801ecbf1a5f663d263538214e44990/script/faces.js))

When the script returns, we end up with a JSON blob like this.
This is just [the homepage](/) and I've removed all the fallback fonts:

```json
[
  {
    "font": {
      "face": "Exo 2",
      "weight": "700",
      "style": "normal"
    },
    "chars": " .HTbehnorstyz👋"
  },
  {
    "font": {
      "face": "Exo 2",
      "weight": "400",
      "style": "normal"
    },
    "chars": "acdeklopst"
  },
  {
    "font": {
      "face": "Open Sans",
      "weight": "400",
      "style": "normal"
    },
    "chars": " !',-.04:ABCDEHIJLMNORSTYabcdefghiklmnoprstuvwyz❤️"
  }
]
```

There are some interesting things happening here.
First, I mentioned that I only was using ASCII… well, that's a bit of a lie; I'm also using a few emoji.
The script found and included these.
Second, I'm not even using *all* the ASCII characters; `q` and `x` are absent from Open Sans (my body font.)

True, this is just for one page, but it holds across the rest of the content: each font ends up only needing to include well under 100 glyphs to be able to render everything on the whole site.

## Subsetting, for Real

After all that analysis, how do we actually subset the fonts?

I'm using a tool called `pyftsubset`, available in the [fonttools](https://github.com/fonttools/fonttools) Python package.
Put simply, to subset a font, you need to call `pyftsubset {input font} --unicodes={code points}`.
There are a few more flags in the actual script I use, but that's basically it.

[The script itself](https://git.bytes.zone/bytes.zone/bytes.zone/src/commit/7d957f13a7801ecbf1a5f663d263538214e44990/script/subset.py) is not terribly exciting, so I'm not going to show much of it here.
It basically slurps down the output of the face-finding script, calls `pyftsubset` on the result, and prints some statistics about the filesize difference:

```
Finding subsets of 8 fonts on 10 pages
Subset ./dist/fonts/Exo2-Bold.woff2 from 46656 to 5608 bytes (12.02% of original size, 61 glyphs)
Subset ./dist/fonts/OpenSans.woff2 from 50116 to 8240 bytes (16.44% of original size, 81 glyphs)
Subset ./dist/fonts/Exo2-Regular.woff2 from 46300 to 3440 bytes (7.43% of original size, 35 glyphs)
Subset ./dist/fonts/Jetbrains-Mono.woff2 from 22368 to 10564 bytes (47.23% of original size, 87 glyphs)
Subset ./dist/fonts/OpenSans-Italic.woff2 from 48148 to 3668 bytes (7.62% of original size, 18 glyphs)
Subset ./dist/fonts/OpenSans-Bold.woff2 from 51932 to 4548 bytes (8.76% of original size, 27 glyphs)
```

And looking at the final font sizes, I feel much better aabout shipping these to people's browsers.
With this result, I can load all the glyphs in all the fonts I need in less size than just one of the original font files:

```
12K	dist/fonts/OpenSans.woff2
12K	dist/fonts/Jetbrains-Mono.woff2
4.0K	dist/fonts/OpenSans-Italic.woff2
4.0K	dist/fonts/Exo2-Regular.woff2
8.0K	dist/fonts/Exo2-Bold.woff2
8.0K	dist/fonts/OpenSans-Bold.woff2
48K	total
```

Aside: I also have some uncompressed-but-unused files in the output of my site, but they aren't ever referenced, so a browser shouldn't ever load them.
I'm not counting those towards the filesize total here.

## Success!

In the end, I reduced the size of my font files by about 87%, going from 386K to 48K.
The final subsets have about 300 total characters to render my site.
While this will grow over time as I add more content, it should level out pretty quickly.

In short: it worked!

So, in writing about this, would I recommend you do it too?
Solid **maybe**!

I think it makes sense to do this on a site where:

1. **You're using custom fonts.** If you're using generic font names (like `sans-serif` or `monospace`) or your font stack is a mix of built-ins and system fonts (e.g. `Helvetica, Arial, sans-serif`), there's no need to save on bandwidth here; your readers already have the whole font!
2. **All your content is known in advance.** If you have anything that's dynamically loaded, you'll get really weird results where some—but not all—of your characters will be replaced by the fallback font.
3. **Fonts are actually the largest asset class.** If you're serving a 10mb JPEG as a background image, compressing that is a lot easier and will be a much better experience for your readers than figuring out a subsetting pipeline for your site. My framework, [elm-pages](https://elm-pages.com), takes care of this for me. If yours doesn't, searching around for image optimization tools will probably net you some easy wins.

If your site meets all those conditions, give it a try!
I've linked to the source of my scripts in the page above, and you can check out the full latest source for this site at [git.bytes.zone/bytes.zone/bytes.zone](https://git.bytes.zone/bytes.zone/bytes.zone). (is it just me or is it echoing in here?)

Have fun!
