task "build", "build the JavaScripts", ->
  { exec } = require 'child_process'
  exec "./node_modules/bin/coffee -cp cachit.coffee > index.js"
