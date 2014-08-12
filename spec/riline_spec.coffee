Riline = require('../src/riline')

describe 'Riline', ->

  beforeEach ->
    @riline = new Riline()

  describe '#contructor', ->
    it 'sets @property to true', ->
      expect(@riline.property).to.be.true
