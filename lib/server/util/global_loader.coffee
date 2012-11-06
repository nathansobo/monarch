# Global Loader - a utility for loading multiple files that collectively define
# a common global module. Each file should export a function that receives a
# single object containing the global modules to be modified.

_ = require 'underscore'
fs = require 'fs'
glob = require 'glob'
path = require 'path'

loader =
  dir: '.'
  globals: {}

  configure: (options) ->
    for key in ['globals', 'dir']
      loader[key] = options[key] if options[key]

  require: (filePath) ->
    fileExport = require(fullPath(filePath))
    fileExport(loader.globals) if _.isFunction(fileExport)

  requireTree: (dirPath) ->
    filePaths = glob.sync("#{dirPath}/**/*", cwd: loader.dir)
    filePaths.forEach (filePath) ->
      if isFile(fullPath(filePath))
        loader.require(stripExtension(filePath))

fullPath = (filePath) ->
  path.resolve(loader.dir, filePath)

isFile = (filePath) ->
  fs.statSync(filePath).isFile()

stripExtension = (filePath) ->
  extension = path.extname(filePath)
  filePath.replace("#{extension}$", '')

module.exports = loader
