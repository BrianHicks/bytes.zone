const puppeteer = require("puppeteer");

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

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  out = {};
  for (file of process.argv.slice(2)) {
    await page.goto("file://" + file);

    const fileOut = await page.evaluate(function() {
      // this has to be redefined in this function since the contents here are
      // run within the browser's JS execution context. It doesn't know about
      // stuff in this source file!
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
        let node = todo.shift();

        for (var i = 0; i < node.childNodes.length; i++) {
          todo.push(node.childNodes[i]);
        }

        if (node.nodeName === "#text") {
          let styles = window.getComputedStyle(node.parentElement);

          if (styles.display === "none") {
            continue;
          }

          for (let face of styles.fontFamily.split(", ")) {
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
        }
      }
      return out;
    });

    for (let key in fileOut) {
      if (out[key]) {
        out[key].chars = uniqChars(out[key].chars + fileOut[key].chars);
      } else {
        out[key] = fileOut[key];
      }
    }
  }

  let outArray = [];
  for (let key in out) {
    outArray.push(out[key]);
  }
  console.log(JSON.stringify(outArray));

  await browser.close();
})();
