// man(1) outputs text that contains deletion characters to produce styles.
// For example, _^Ha should be styled as <u>a</u>; and z^Hz should be styled as <b>z</b>
var body = document.getElementById("main");
// given some text node, split that node apart at each delete character, and
// style appropriately.
function applyDeleteStyles(inTextNode) {
  const del = "\b";
  const text = inTextNode.wholeText;
  var delAt = inTextNode.wholeText.indexOf(del);
  // no delete chars; nothing to interpret
  if (delAt === -1) {
    console.log("No deletes in", text);
    return;
  }
  // delete character is first, so we can't see the style character.
  // give up.
  if (delAt === 0) {
    console.log("Cant interpret text starting with delete");
    return;
  }

  const styleChar = text[delAt - 1];
  const contentChar = text[delAt + 1];

  const styleTagName = styleChar === "_" ? "U" : "B";

  // if the preceding element is the right kind of style element, append it
  // there.
}
