/* eslint-disable no-eq-null, eqeqeq */
function id(x) {
  return x;
}

export {id as fromBoolean};
export {id as fromNumber};
export {id as fromString};
export {id as fromArray};
export {id as fromObject};
export const jsonNull = null;

class CustomNumber {
  // This tag is the point of the class
  // It allows us to distinguish the custom type from regular objects in JSON
  get [Symbol.toStringTag]() {
    return "Data.Argonaut.Parser.CustomNumber";
  }
  constructor(wrapped) {
    this.wrapped = wrapped;
  }
}

export function customNumberContent(customNumber) {
  return customNumber.wrapped;
}

export function mkCustomNumber(wrapped) {
  return new CustomNumber(wrapped);
}

function isNumber(a) {
  return (((typeof a) === "number")
    || Object.prototype.toString.call(a)
        === "[object Data.Argonaut.Parser.CustomNumber]");
}

function mkReplacer(encodeNumber) {
  return function(key, value) {
    if (isNumber(value)) {
      return JSON.rawJSON(encodeNumber(value));
    } else {
      return value;
    }
  };
}

export function _stringify(left) {
  return function (right) {
    return function (encodeNumber) {
      return function (j) {
        try {
          return right(JSON.stringify(j, mkReplacer(encodeNumber)));
        } catch (e) {
          // rawJSON can throw when passed invalid JSON
          return left(e.message);
        }
      };
    };
  };
}

export function _stringifyWithIndent(left) {
  return function (right) {
    return function (encodeNumber) {
      return function (indent) {
        return function (j) {
          try {
            return right(JSON.stringify(j, mkReplacer(left, right, encodeNumber), indent));
          } catch (e) {
            return left(e.message);
          }
        };
      };
    };
  };
}

function isArray(a) {
  return Object.prototype.toString.call(a) === "[object Array]";
}

function isObject(a) {
  return Object.prototype.toString.call(a) === "[object Object]";
}

export function _caseJson(isNull, isBool, isNum, isStr, isArr, isObj, j) {
  if (j == null) return isNull();
  else if (typeof j === "boolean") return isBool(j);
  else if (isNumber(j)) return isNum(j);
  else if (typeof j === "string") return isStr(j);
  else if (isArray(j)) return isArr(j);
  else return isObj(j);
}

export function _compare(EQ, GT, LT, a, b, compareNumber) {
  if (a == null) {
    if (b == null) return EQ;
    else return LT;
  } else if (typeof a === "boolean") {
    if (typeof b === "boolean") {
      // boolean / boolean
      if (a === b) return EQ;
      else if (a === false) return LT;
      else return GT;
    } else if (b == null) return GT;
    else return LT;
  } else if (isNumber(a)) {
    if (isNumber(b)) {
      return compareNumber(a, b);
    } else if (b == null) return GT;
    else if (typeof b === "boolean") return GT;
    else return LT;
  } else if (typeof a === "string") {
    if (typeof b === "string") {
      if (a === b) return EQ;
      else if (a < b) return LT;
      else return GT;
    } else if (b == null) return GT;
    else if (typeof b === "boolean") return GT;
    else if (isNumber(b)) return GT;
    else return LT;
  } else if (isArray(a)) {
    if (isArray(b)) {
      for (var i = 0; i < Math.min(a.length, b.length); i++) {
        var ca = _compare(EQ, GT, LT, a[i], b[i], compareNumber);
        if (ca !== EQ) return ca;
      }
      if (a.length === b.length) return EQ;
      else if (a.length < b.length) return LT;
      else return GT;
    } else if (b == null) return GT;
    else if (typeof b === "boolean") return GT;
    else if (isNumber(b)) return GT;
    else if (typeof b === "string") return GT;
    else return LT;
  } else {
    if (b == null) return GT;
    else if (typeof b === "boolean") return GT;
    else if (isNumber(b)) return GT;
    else if (typeof b === "string") return GT;
    else if (isArray(b)) return GT;
    else {
      var akeys = Object.keys(a);
      var bkeys = Object.keys(b);
      if (akeys.length < bkeys.length) return LT;
      else if (akeys.length > bkeys.length) return GT;
      var keys = akeys.concat(bkeys).sort();
      for (var j = 0; j < keys.length; j++) {
        var k = keys[j];
        if (a[k] === undefined) return LT;
        else if (b[k] === undefined) return GT;
        var ck = _compare(EQ, GT, LT, a[k], b[k], compareNumber);
        if (ck !== EQ) return ck;
      }
      return EQ;
    }
  }
}
