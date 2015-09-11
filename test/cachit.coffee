assert = require 'assert'
fs = require 'fs'
path = require 'path'
cachit = require '../cachit'

describe "cachit", ->
  describe "memory store", ->
    cache = cachit()
    x = null
    before -> x = 0
    it "is a function", ->
      assert typeof cache is 'function'
    it "returns a thenable", ->
      retval = cache("x", "X")
      assert retval.then
      assert typeof retval.then is 'function'
    it "calls the cached function once only", (done) ->
      cache("foo", -> (x += 1; "FOO!"))
        .then (result) ->
          assert.equal 'FOO!', result
          assert.equal 1, x
        .then -> cache("foo", -> (x += 1; "BAR!"))
        .then -> cache("bar", -> (x += 1; "BAR!"))
        .then (result) ->
          assert.equal 'BAR!', result
          assert.equal 2, x
        .then(-> done()).catch(done)
  describe "file store", ->
    file = path.join(__dirname, "cache.json")
    cache = cachit(file)
    x = null
    before (done) ->
      x = 0
      fs.writeFile file, JSON.stringify(foo: 'Foo.'), 'utf8', (err) ->
        throw err if err?
        cache = cachit(file)
        done()
    it "uses the JSON file", (done) ->
      cache('foo', -> (x += 1; "FOO!"))
        .then (result) ->
          assert.equal 'Foo.', result
          assert.equal 0, x
        .then(-> done()).catch(done)
    it "works normally otherwise", (done) ->
      cache('bar', -> (x += 1; "BAR!"))
        .then (result) ->
          assert.equal 'BAR!', result
          assert.equal 1, x
        .then -> cache('bar', -> (x += 1; "BLAH!"))
        .then (result) ->
          assert.equal 'BAR!', result
          assert.equal 1, x
        .then(-> done()).catch(done)
