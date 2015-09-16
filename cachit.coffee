@Promise ?= require 'bluebird'
{ Promise } = @

readFile = (file) ->
  new Promise (resolve, reject) ->
    require('fs').readFile file, 'utf8', (err, data) ->
      return reject(err) if err?
      resolve data
readJSON = (file) ->
  readFile(file).then(JSON.parse).catch (err) ->
    console.err err
    {}
writeFile = (file, data) ->
  new Promise (resolve, reject) ->
    require('fs').writeFile file, data, (err) ->
      return reject(err) if err?
      resolve()
writeJSON = (file, data) ->
  writeFile(file, JSON.stringify(data))

strategies =
  memory: (store = {}) ->
    store: (k, v) -> Promise.resolve(store[k] = v)
    fetch: (k) -> Promise.resolve(store[k])
  file: (file, options = {}) ->
    store = {}
    options.read ?= readJSON
    options.write ?= writeJSON
    options.autosave ?= true
    { read, write, autosave } = options
    load = read(file).then (data) -> store = data
    save = -> write(file, 'utf8', store)
    store: (k, v) ->
      store[k] = v
      if autosave
        save().then(-> v)
      else
        Promise.resolve(v)
    fetch: (k) ->
      load.then -> store[k]

cachit = (strategy = strategies.memory()) ->
  if typeof strategy is 'string'
    strategy = strategies.file(strategy)
  { store, fetch, hasKey } = strategy
  hasKey ?= (k) -> fetch(k).then (v) -> v?
  (k, v) ->
    Promise.resolve(k?() or k)
      .then hasKey
      .then (hasKey) ->
        return fetch(k) if hasKey
        Promise.resolve(if typeof v is 'function' then v() else v)
          .then (v) -> store(k, v)

if module?.exports?
  module.exports = cachit
else
  @cachit = cachit
