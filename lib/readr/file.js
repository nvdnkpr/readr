// Generated by CoffeeScript 2.0.0-beta6
void function () {
  var async, File, fs, getFile, getFileSync, getNodeVersion, partiallyApply, pathDoesNotExistError, readFile;
  fs = require('fs');
  async = require('async');
  (File = exports).glob = require('globber');
  File.getFiles = function (path, options, cb) {
    if ('function' === typeof options) {
      cb = options;
      options = {};
    }
    return File.glob(path, options, function (err, paths) {
      var iterator;
      if (null != err)
        return cb(err);
      iterator = partiallyApply(getFile, options.encoding);
      return async.map(paths, iterator, function (err, files) {
        if (null != err)
          return cb(err);
        return cb(null, files);
      });
    });
  };
  File.getFilesSync = function (path, options) {
    if (null == options)
      options = {};
    return File.glob.sync(path, options).map(partiallyApply(getFileSync, options.encoding));
  };
  getFile = function (encoding, path, cb) {
    return fs.exists(path, function (pathExists) {
      if (!pathExists)
        return cb(pathDoesNotExistError(path));
      return readFile(path, encoding, function (err, contents) {
        if (null != err)
          return cb(err);
        return cb(null, {
          path: path,
          contents: contents
        });
      });
    });
  };
  getFileSync = function (encoding, path) {
    if (fs.existsSync(path)) {
      return {
        path: path,
        contents: readFile(path, encoding)
      };
    } else {
      throw pathDoesNotExistError(path);
    }
  };
  readFile = function (path, encoding, cb) {
    var method, options;
    if (null == encoding)
      encoding = 'utf8';
    if (encoding === 'buffer')
      encoding = null;
    options = getNodeVersion() < 10 ? encoding : { encoding: encoding };
    method = 'function' === typeof cb ? 'readFile' : 'readFileSync';
    return fs[method](path, options, cb);
  };
  partiallyApply = function (fn, args) {
    args = 2 <= arguments.length ? [].slice.call(arguments, 1) : [];
    return fn.bind.apply(fn, [null].concat([].slice.call(args)));
  };
  pathDoesNotExistError = function (path) {
    return new Error('' + path + ' does not exist');
  };
  getNodeVersion = function () {
    return +process.version.slice(1).split('.')[1];
  };
}.call(this);
