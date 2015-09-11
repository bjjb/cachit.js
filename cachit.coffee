@Promise ?= require 'bluebird'
{ Promise } = @

strategies =
  memory: (store = {}) ->
    store: (k, v) -> Promise.resolve(store[k] = v)
    fetch: (k) -> Promise.resolve(store[k])
  file: (file, options = {}) ->
    store = {}
    options.read ?= Promise.promisify(require('fs').readFile) # NodeJS
    options.write ?= Promise.promisify(require('fs').writeFile) # NodeJS
    { read, write, autosave } = options
    load = read(file).then(JSON.parse).catch({}).then (data) -> store = data
    save = -> write(file, 'utf8', JSON.stringify(store))
    store: (k, v) ->
      store[k] = v
      if autosave
        save().then(-> v)
      else
        Promise.resolve(v)
    fetch: (k) ->
      load.then -> store[k]

cachit = (strategy = strategies.memory()) ->
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
