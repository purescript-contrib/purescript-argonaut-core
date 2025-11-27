export function _jsonParser(fail, succ, s) {
  try {
    return succ(JSON.parse(s));
  }
  catch (e) {
    return fail(e.message);
  }
}

function mkReviver(mkNumber, isNothing, fromJust) {
  return (key, value, context) => {
    if (typeof context === "undefined") {
      throw new Error("Reviver context not available, try upgrading your JavaScript runtime");
    }
    if (!context.source) return value;
    if (typeof value !== "number") {
      return value;
    }
    const mbDecoded = mkNumber(context.source);
    if (isNothing(mbDecoded)) {
      throw new Error("Could not decode with custom numeral parser: " + context.source);
    } else {
      return fromJust(mbDecoded);
    }
  };
}

export function _customJsonParser(mkNumber, isNothing, fromJust, fail, succ, s) {
  try {
    return succ(JSON.parse(s, mkReviver(mkNumber, isNothing, fromJust)));
  }
  catch (e) {
    return fail(e.message);
  }
}
