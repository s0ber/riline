Riline = require('../src/riline')
fs = require 'fs'
_ = require 'underscore'

describe 'Riline', ->

  beforeEach ->
    @text = fs.readFileSync('./spec/fixtures/slim_document.slim').toString()
    @riline = new Riline(@text)

  describe '#contructor', ->
    it 'saves provided text string in @text', ->
      expect(@riline.text).to.be.equal @text

  describe '#addMessage', ->
    it 'saves information about message in @messages', ->
      warning1 = text: 'a warning', startLine: 5, lastLine: 10
      @riline.addMessage(warning1)
      expect(@riline.messages).to.be.eql [_.extend(warning1, type: 'warning')]

      warning2 = text: 'another warning', startLine: 10, type: 'warning'
      @riline.addMessage(warning2)
      expect(@riline.messages).to.be.eql [_.extend(warning1, type: 'warning'), warning2]

    it 'checks that warning has correct structure', ->
      catched = false
      try
        @riline.addMessage('hmm')
      catch e
        expect(e).to.match /Message should have following structure/
        catched = true

      expect(catched).to.be.true

  describe '#printMessages', ->
    beforeEach ->
      sinon.spy(@riline, 'log')

    context 'it is first line', ->
      it 'prints messages to console', ->
        @riline.addMessage text: 'Some text message', startLine: 1
        @riline.printMessages()
        expect(@riline.log).to.be.calledOnce
        expect(@riline.log.lastCall.args[0]).to.be.equal """

          WARNING: Some text message, line 1
            1  doctype html
            2  html
            3    head
            4      title\n
          """

    context 'it is one of the first lines', ->
      it 'prints messages to console', ->
        @riline.addMessage text: 'Some text message', startLine: 2, endLine: 8
        @riline.printMessages()
        expect(@riline.log).to.be.calledOnce
        expect(@riline.log.lastCall.args[0]).to.be.equal """

          WARNING: Some text message, line 2
            01  doctype html
            02  html
            03    head
            04      title
            05        | Rails App Template
            06      = stylesheet_link_tag 'application', media: 'all'
            07      = javascript_include_tag 'application'
            08      = csrf_meta_tags
            09
            10    body.layout data={app: 'app'}
            11      .layout-main\n
          """

    context 'it is middle of a text string', ->
      it 'prints messages to console', ->
        @riline.addMessage text: 'Some text message', startLine: 71, endLine: 73
        @riline.printMessages()
        expect(@riline.log).to.be.calledOnce
        expect(@riline.log.lastCall.args[0]).to.be.equal '''

          WARNING: Some text message, line 71
            68                        color: red
            69                      }
            70
            71                    :javascript
            72                      $('.page-body')
            73                        .append('<div class="my_class is-blue">This #{a} is appended by js.</div>')
            74
            75                    - unescaped_text = '<span class="my_class is-red">unescaped html</span>'
            76                    :javascript\n
          '''

    context 'it is near the end of a text string', ->
      it 'prints messages to console', ->
        @riline.addMessage text: 'Some text message', startLine: 117, endLine: 118
        @riline.printMessages()
        expect(@riline.log).to.be.calledOnce
        expect(@riline.log.lastCall.args[0]).to.be.equal '''

          WARNING: Some text message, line 117
            114            | it was false...
            115
            116      footer.layout-footer
            117        .layout-footer_inner
            118          .footer
            119            | Footer text here\n
          '''
    context 'it is the end of a text string', ->
      it 'prints messages to console', ->
        @riline.addMessage text: 'Some text message', startLine: 119
        @riline.printMessages()
        expect(@riline.log).to.be.calledOnce
        expect(@riline.log.lastCall.args[0]).to.be.equal '''

          WARNING: Some text message, line 119
            116      footer.layout-footer
            117        .layout-footer_inner
            118          .footer
            119            | Footer text here\n
          '''

  describe '#linesNumber', ->
    it 'returns proper number of lines', ->
      linesNumber = @riline.linesNumber()
      expect(linesNumber).to.be.eql 119

  describe '#getLine', ->
    it 'returns proper string line', ->
      line = @riline.getLine(10)
      expect(line).to.be.equal "  body.layout data={app: 'app'}\n"

