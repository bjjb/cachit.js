# Cachit

A little backend-agnostic caching helper for JavaScript

## Installation (NodeJS)

    npm install cachit

## Usage

    var cachit, cache
    if (typeof(require) === 'function')
      cachit = require('cachit')
    else if (!!window)
      cachit = window.cachit
    cache = cachit()
    cache('foo', function() { console.log("Running foo!"); return "Foo." })
    cache('foo', function() { console.log("Running foo!"); return "Foo." })

The preceding code will print "Running foo!" just once, as the second time,
the return value of the function has been cached (in memory), and it will be
returned.
