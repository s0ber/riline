Riline
=====
[![Build Status](https://travis-ci.org/s0ber/riline.png?branch=master)](https://travis-ci.org/s0ber/riline)

Utility for logging lines of code from a text string (or file).

## Hot To Use

Initialized riline object constructor gets text string as a parameter, then you can log parts of this text string in a console with some warning message.

```coffee
Riline = require('../src/riline')
fs = require 'fs'

text = fs.readFileSync('./my_text_file.txt').toString()
riline = new Riline(text)

riline.addMessage
  type: 'warning'
  startLine: 10
  endLine: 15
  message: 'Somethin is wrong in this lines'

riline.addMessage
  type: 'warning'
  startLine: 50
  message: 'This will highlight only one line'

# it will print all added messages in console with related pieces of text
riline.printMessages()
```
