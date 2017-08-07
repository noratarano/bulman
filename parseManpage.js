// man(1) outputs text that contains deletion characters to produce styles.
// For example, _^Ha should be styled as <u>a</u>; and z^Hz should be styled as <b>z</b>

// 1. we need a library for constructing a virtual DOM
const VDOM = {
  /**
   * construct a new virtual dom node
   * tagName: HTML element type to create
   * children: either a string or an array of Vnodes
   */
  node: function(tagName, children) {
    return {
      tagName: tagName,
      props: {},
      children: children,
    }
  },

  /**
   * Join the children of two nodes together into a single children item.
   * Given that children can be either strings or arrays, handles both cases.
   */
  joinChildren: function(children1, children2) {
    if (typeof children1 === 'string' && typeof children2 === 'string') {
      return children1 + children2;
    }

    if (typeof children1 === 'string') {
      return [children1].concat(children2);
    }

    return children1.concat(children2);
  },

  /**
   * toDom converts a vdom node or child into a DOM node.
   * Requires `window.document` to exist.
   */
  toDom: function(vnode) {
    if (Array.isArray(vnode)) {
      return vnode.map(VDOM.toDom);
    }

    if (typeof vnode === 'string') {
      return window.document.createTextNode(vnode);
    }

    const node = window.document.createElement(vnode.tagName);
    const children = VDOM.toDom(vnode.children);

    if (Array.isArray(children)) {
      children.forEach(function(child) {
        node.appendChild(child);
      });
    } else {
      node.appendChild(children);
    }
    return node;
  },

  /**
   * Mount the given vnode into the DOM as the only child of target, a DOM
   * node.
   */
  mount: function(target, vnode) {
    const dom = VDOM.toDom(vnode);
    target.innerHTML = '';
    target.appendChild(dom);
  },
}

// 2. we need a way to parse out the delete-styled-characters from the rest of
// the text. The delete characters each match a regexp, but JS's existing
// regexp APIs don't provide a way to get ALL the data about a complete match
// of a regexp against a text, preserving all ordering.
//
// So, we need a function that does that:

/*
 * chunk string using the given regex.
 * the return value is an array of the original string in order, split into chunks.
 * chunks that did not match the regex are literal strings
 * chunks that matched the regex are the match objects themselves.
 */
function chunkRegex(string, regex) {
  if (regex.flags.indexOf('g') !== -1) throw new Error('no global regex allowed')
  const result = [];
  let remaining = string;
  let match;
  while (match = remaining.match(regex)) {
    if (match.index > 0) {
      result.push(remaining.slice(0, match.index))
    }
    result.push(match)
    remaining = remaining.slice(match.index + match[0].length)
  }
  if (remaining.length) result.push(remaining);
  return result;
}

// 3. now that we can extract the specially-styled characters, we need a way to
// produce a styled DOM from them.
function parseDeleteStyles(string) {
  const deletion = new RegExp("(.)\b(.)");
  const parts = chunkRegex(string, deletion);
  const result = [];

  function matchToSpan(match) {
    const style = match[1];
    const content = match[2];
    if (style === content) {
      return VDOM.node('B', content);
    }

    if (style === '_') {
      return VDOM.node('U', content);
    }

    console.log("Unknown delete style", match)
    return VDOM.node('SPAN', content);
  }

  for (let i = 0; i < parts.length; i++) {
    const part = parts[i];
    const lastResult = result[result.length - 1];

    if (typeof part === 'string') {
      result.push(part);
      continue;
    }

    // otherwise parts are regexp matches
    const span = matchToSpan(part);
    if (lastResult.tagName === span.tagName) {
      lastResult.children = VDOM.joinChildren(lastResult.children, span.children);
      continue;
    }
    result.push(span)
  }
  return result;
}

function test() {
  //const fs = require('fs');
  //const data = fs.readFileSync('example.txt', 'utf8');
  //console.log(parseDeleteStyles(data));
  let corpus = 'hello_\b, n\bno\bor\bra\ba';
  let regex = new RegExp('(.)\b(.)')
  console.log('corpus', [corpus])
  console.log('match ', corpus.match(regex));
  console.log('exec  ', regex.exec(corpus));
  console.log('chunk ', chunkRegex(corpus, regex));
  console.log('parse ', parseDeleteStyles(corpus));
}

function main() {
  const target = document.getElementById("main");
  const children = parseDeleteStyles(target.textContent);
  const node = { tagName: 'DIV', children: children };
  VDOM.mount(target, node);
}


if (typeof window !== 'undefined') {
  main();
} else {
  test();
}
