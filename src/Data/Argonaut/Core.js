// module Data.Argonaut.Core

function id(x) {
    return x;
}
    

exports.fromNull = function() {
    return null;
};

exports.fromBoolean = id;
exports.fromNumber = id;
exports.fromString = id;
exports.fromArray = id;
exports.fromObject = id;

exports.jsonNull = null;

exports._stringify = function(j) {
    return JSON.stringify(j);
};

exports._foldJson = function(isNull, isBool, isNum, isStr, isArr, isObj, j) {
    if (j == null) return isNull(null);
    else if (typeof j === 'boolean') return isBool(j);
    else if (typeof j === 'number') return isNum(j);
    else if (typeof j === 'string') return isStr(j);
    else if (Object.prototype.toString.call(j) === '[object Array]')
        return isArr(j);
    else return isObj(j);
};

function _compare(EQ, GT, LT, a, b) {
    function isArray(a) {
        return Object.prototype.toString.call(a) === '[object Array]';
    }
    function keys(o) {
        var a = [];
        for (var k in o) {
            a.push(k);
        }
        return a;
    }

    if (a == null) {
        if (b == null) return EQ;
        else return LT;
    } else if (typeof a === 'boolean') {
        if (typeof b === 'boolean') {
            // boolean / boolean
            if (a === b) return EQ;
            else if (a == false) return LT;
            else return GT;
        } else if (b == null) return GT;
        else return LT;
    } else if (typeof a === 'number') {
        if (typeof b === 'number') {
            if (a === b) return EQ;
            else if (a < b) return LT;
            else return GT;
        } else if (b == null) return GT;
        else if (typeof b === 'boolean') return GT;
        else return LT;
    } else if (typeof a === 'string') {
        if (typeof b === 'string') {
            if (a === b) return EQ;
            else if (a < b) return LT;
            else return GT;
        } else if (b == null) return GT;
        else if (typeof b === 'boolean') return GT;
        else if (typeof b === 'number') return GT;
        else return LT;
    } else if (isArray(a)) {
        if (isArray(b)) {
            for (var i = 0; i < Math.min(a.length, b.length); i++) {
                var c = _compare(EQ, GT, LT, a[i], b[i]);
                
                if (c !== EQ) return c;
            }
            if (a.length === b.length) return EQ;
            else if (a.length < b.length) return LT;
            else return GT;
        } else if (b == null) return GT;
        else if (typeof b === 'boolean') return GT;
        else if (typeof b === 'number') return GT;
        else if (typeof b === 'string') return GT;
        else return LT;
    }
    else {
        if (b == null) return GT;
        else if (typeof b === 'boolean') return GT;
        else if (typeof b === 'number') return GT;
        else if (typeof b === 'string') return GT;
        else if (isArray(b)) return GT;
        else {
            var akeys = keys(a);
            var bkeys = keys(b);
            
            var keys = akeys.concat(bkeys).sort();
            
            for (var i = 0; i < keys.length; i++) {
                var k = keys[i];
                
                if (a[k] === undefined) return LT;
                else if (b[k] === undefined) return GT;
                
                var c = _compare(EQ, GT, LT, a[k], b[k]);
                
                if (c !== EQ) return c;
            }
            
            if (akeys.length === bkeys.length) return EQ;
            else if (akeys.length < bkeys.length) return LT;
            else return GT;
        }
    }
};

exports._compare = _compare;
