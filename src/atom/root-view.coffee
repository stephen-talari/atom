$ = require 'jquery'
fs = require 'fs'

Template = require 'template'
Buffer = require 'buffer'
Editor = require 'editor'
FileFinder = require 'file-finder'
Project = require 'project'
GlobalKeymap = require 'global-keymap'

module.exports =
class RootView extends Template
  content: ->
    @link rel: 'stylesheet', href: "#{require.resolve('atom.css')}?#{(new Date).getTime()}"
    @div id: 'app-horizontal', =>
      @div id: 'app-vertical', outlet: 'vertical', =>
        @div id: 'main', outlet: 'main', =>
          @subview 'editor', Editor.build()

  viewProperties:
    globalKeymap: null

    initialize: ({url}) ->
      @globalKeymap = new GlobalKeymap
      @globalKeymap.bindKeys '*'
        'meta+s': 'save'
        'meta+w': 'close'
        'meta+t': 'find-files'

      @editor.keyEventHandler = @globalKeymap

      if url
        @project = new Project(fs.directory(url))
        @editor.setBuffer(@project.open(url)) if fs.isFile(url)

    addPane: (view) ->
      pane = $('<div class="pane">')
      pane.append(view)
      @main.after(pane)

    toggleFileFinder: ->
      return unless @project

      if @fileFinder and @fileFinder.parent()[0]
        @fileFinder.remove()
        @fileFinder = null
      else
        @project.getFilePaths().done (paths) =>
          relativePaths = (path.replace(@project.url, "") for path in paths)
          @fileFinder = FileFinder.build
            urls: relativePaths
            selected: (relativePath) => @editor.setBuffer(@project.open(relativePath))
          @addPane @fileFinder
          @fileFinder.input.focus()
