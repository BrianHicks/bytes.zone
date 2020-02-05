const puppeteer = require("puppeteer");

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto("file://" + __dirname + "/../dist/index.html");

  const out = await page.evaluate(function() {
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
  console.log(out);

  await browser.close();
})();
