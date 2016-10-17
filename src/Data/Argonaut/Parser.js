"use strict";

exports._jsonParser = function (fail, succ, s) {
  try {
    return succ(JSON.parse(s));
  }
  catch (e) {
    return fail(e.message);
  }
};
