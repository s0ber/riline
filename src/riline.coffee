_ = require 'underscore'
colors = require 'colors'

colors.setTheme
  warning: 'yellow'

LINES_AROUND = 3
LINE_BREAK = '\n'
INDENTATION = '  '

Riline = class

  constructor: (text, @highlightLines = true) ->
    @text = text
    @messages = []

  addMessage: (message) ->
    message = _.clone(message)

    unless @_validateMessage(message)
      throw "Message should have following structure: {text, startLine, [endLine], [type = 'warning']}"

    message.type ?= 'warning'
    @messages.push(message)

  _validateMessage: (message) ->
    if not _.isObject(message)
      false
    else if not message.text? or not message.startLine?
      false
    else
      true

  printMessages: ->
    for message in @messages
      @printMessage(message)

    return

  printMessage: (message) ->
    message.endLine = message.startLine unless message.endLine?

    messageText = LINE_BREAK

    if @highlightLines
      messageText += "#{message.type.toUpperCase()}".underline + ': '
    else
      messageText += "#{message.type.toUpperCase()}: "

    messageText += message.text + ", line #{message.startLine}"+ LINE_BREAK

    if message.startLine < 1 or message.startLine > @linesNumber()
      return

    if message.endLine < 1 or message.endLine < message.startLine or message.endLine > @linesNumber()
      return

    start =
      if message.startLine - LINES_AROUND < 1
        1
      else
        message.startLine - LINES_AROUND

    end =
      if message.endLine + LINES_AROUND > @linesNumber()
        @linesNumber()
      else
        message.endLine + LINES_AROUND

    for i in [start..end]
      lineNumber = @numberWithZeros(i, end.toString().length)
      line = @getLine(i)
      lineText = ''
      lineText += ' ' + lineNumber
      lineText += INDENTATION unless line.length is 1
      lineText += line

      # this will highlight target lines with type color
      if @highlightLines and i >= message.startLine and i <= message.endLine
        lineText = lineText[message.type]

      messageText += lineText

    @log(messageText)

  log: (string) ->
    console.log(string)

  lines: ->
    @_lines ?= @text.split(LINE_BREAK)

  getLine: (lineNumber) ->
    @lines()[lineNumber - 1] + LINE_BREAK

  numberWithZeros: (number, size) ->
    ('00000000' + number).slice(-size)

  linesNumber: ->
    @_linesNumber ?= @lines().length - 1

module.exports = Riline
