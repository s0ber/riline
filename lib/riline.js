(function() {
  var INDENTATION, LINES_AROUND, LINE_BREAK, Riline, _;

  _ = require('underscore');

  LINES_AROUND = 3;

  LINE_BREAK = '\n';

  INDENTATION = '  ';

  Riline = (function() {
    function _Class(text) {
      this.text = text;
      this.messages = [];
    }

    _Class.prototype.addMessage = function(message) {
      message = _.clone(message);
      if (!this._validateMessage(message)) {
        throw "Message should have following structure: {text, startLine, [endLine], [type = 'warning']}";
      }
      if (message.type == null) {
        message.type = 'warning';
      }
      return this.messages.push(message);
    };

    _Class.prototype._validateMessage = function(message) {
      if (!_.isObject(message)) {
        return false;
      } else if ((message.text == null) || (message.startLine == null)) {
        return false;
      } else {
        return true;
      }
    };

    _Class.prototype.printMessages = function() {
      var message, _i, _len, _ref, _results;
      _ref = this.messages;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        message = _ref[_i];
        _results.push(this.printMessage(message));
      }
      return _results;
    };

    _Class.prototype.printMessage = function(message) {
      var end, i, line, lineNumber, messageText, start, _i;
      if (message.endLine == null) {
        message.endLine = message.startLine;
      }
      messageText = LINE_BREAK;
      messageText += "" + (message.type.toUpperCase()) + ": ";
      messageText += message.text + (", line " + message.startLine) + LINE_BREAK;
      if (message.startLine < 1 || message.startLine > this.linesNumber()) {
        return;
      }
      if (message.endLine < 1 || message.endLine < message.startLine || message.endLine > this.linesNumber()) {
        return;
      }
      start = message.startLine - LINES_AROUND < 1 ? 1 : message.startLine - LINES_AROUND;
      end = message.endLine + LINES_AROUND > this.linesNumber() ? this.linesNumber() : message.endLine + LINES_AROUND;
      for (i = _i = start; start <= end ? _i <= end : _i >= end; i = start <= end ? ++_i : --_i) {
        lineNumber = this.numberWithZeros(i, end.toString().length);
        line = this.getLine(i);
        messageText += INDENTATION + lineNumber;
        if (line.length !== 1) {
          messageText += INDENTATION;
        }
        messageText += line;
      }
      return this.log(messageText);
    };

    _Class.prototype.log = function(string) {
      return console.log(string);
    };

    _Class.prototype.lines = function() {
      return this._lines != null ? this._lines : this._lines = this.text.split(LINE_BREAK);
    };

    _Class.prototype.getLine = function(lineNumber) {
      return this.lines()[lineNumber - 1] + LINE_BREAK;
    };

    _Class.prototype.numberWithZeros = function(number, size) {
      return ('00000000' + number).slice(-size);
    };

    _Class.prototype.linesNumber = function() {
      return this._linesNumber != null ? this._linesNumber : this._linesNumber = this.lines().length - 1;
    };

    return _Class;

  })();

  module.exports = Riline;

}).call(this);
