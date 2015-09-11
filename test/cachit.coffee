assert = require 'assert'
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
    before (done) ->
      fs.writeFile file, 'utf8', JSON.stringify(foo: 'Foo.'), (err) ->
        throw err if err?
        cache = cachit(file)
        done()
