'use strict';

const {fork} = require('child_process')
const Emitter = require('events')
const emitter = new Emitter()
var fs           = require('fs'),
    _            = require('lodash'),
    fsStore      = require('imdone-core/lib/mixins/repo-fs-store'),
    log          = require('debug')('imdone-atom:repo-watched-fs-store'),
    File         = require('imdone-core/lib/file'),
    constants    = require('imdone-core/lib/constants'),
    path         = require('path'),
    config       = require('./imdone-config');

var workerPath = path.join(config.getPackagePath(), 'lib', 'services', 'worker.js')

module.exports = mixin;

function mixin(repo, fs) {
  fs = fs || require('fs');

  repo = fsStore(repo, fs);
  repo.worker = fork(workerPath)
  repo.worker.on('message', ({event, data}) => {
    emitter.emit(event, data)
  })
  var _init = repo.init;
  repo.init = function(cb) {
    _init.call(repo, function(err, files) {
        repo.initWatcher();
        if (cb) cb(err, files);
    });
  };

  var _destroy = repo.destroy;
  repo.destroy = function() {
    repo.worker.send({event: 'destroyWatcher'})
    _destroy.apply(repo);
  };

  var _refresh = repo.refresh;
  let refreshing = false;
  repo.refresh = function(cb) {
    // console.log('refresh called')
    if (refreshing) {
      if (cb) return cb()
      return
    }
    // console.log('running refresh')
    refreshing = true
    emitter.once('refresh', function() {
      // console.log('received refresh')
      _refresh.call(repo, function(err, files) {
        repo.initWatcher();
        refreshing = false
        if (cb) cb(err, files);
      });
    })
    repo.worker.send({event: 'refresh'})
  };

  var _isImdoneConfig = function(path) {
    var relPath = repo.getRelativePath(path);
    return relPath.indexOf(constants.CONFIG_FILE) > -1;
  };

  var _isImdoneIgnore = function(path) {
    var relPath = repo.getRelativePath(path);
    return relPath.indexOf(constants.IGNORE_FILE) > -1;
  };

  const WATCHER_EVENTS = {
    add: function(path) {
      log("Watcher received add event for file: " + path);
      var relPath = repo.getRelativePath(path);
      var file = repo.getFile(relPath);
      if (file === undefined) file = new File({repoId: repo.getId(), filePath: relPath, languages: repo.languages});

      repo.fileOK(file, function(err, stat) {
        if (err || !stat) return;
        if (stat.mtime <= file.getModifiedTime()) return;
        log("Reading file: " + path);
        repo.readFile(file, function (err, file) {
          repo.emitFileUpdate(file);
        });
      });
    },
    addDir: function(path) {log('Directory', path, 'has been added');},
    change: function(path) {
      console.log(`received a change for ${path}`)
      log("Watcher received change event for file: " + path);
      var relPath = repo.getRelativePath(path);
      var file = repo.getFile(relPath) || relPath;
      if (_isImdoneConfig(path) || _isImdoneIgnore(path)) {
        repo.emitConfigUpdate();
      } else {
        repo.fileOK(file, function(err, ok) {
          if (err || !ok) return;
          log("Reading file: " + path);
          repo.readFile(file, function (err, file) {
            repo.emitFileUpdate(file);
          });
        });
      }
    },
    unlink: function(path) {
      log("Watcher received unlink event for file: " + path);
      var file = new File({repoId: repo.getId(), filePath: repo.getRelativePath(path), languages: repo.languages});
      log("Removing file: " + path);
      repo.removeFile(file);
      repo.emitFileUpdate(file);
    },
    unlinkDir: function(path) {log('Directory', path, 'has been removed');},
    error: function(error) {log('Error while watching files:', error);}
  }
  repo.initWatcher = function() {
    log("Creating a new watcher");
    let data = {path: repo.path, exclude: repo.config.exclude, ignorePatterns: repo.ignorePatterns}
    repo.worker.send({event: 'initWatcher', data})
    _.keys(WATCHER_EVENTS).forEach( key => {
      emitter.removeListener(key, WATCHER_EVENTS[key])
      emitter.on(key, WATCHER_EVENTS[key])
    })
  };

  return repo;
}
