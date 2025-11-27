export function stringify(j) {
  return JSON.stringify(j);
}

export function stringifyWithIndent(i) {
  return function (j) {
    return JSON.stringify(j, null, i);
  };
}
