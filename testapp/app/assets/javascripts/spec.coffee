rip = null
makeRip = (html) ->
  $(html)
    .find('span')
    .rest_in_place()
    .data('restInPlaceEditor')

beforeEach -> rip = null

describe "Setup", ->
  describe "looking up attributes in parents", ->
    beforeEach ->
      rip = makeRip """
        <p data-url="localhorst" data-formtype="textarea" data-object="person" data-attribute="name">
          <span>Blubb</span>
        </p>"""
    it "should find the data-url"      , -> expect(rip.url).toEqual('localhorst')
    it "should find the data-formtype" , -> expect(rip.formType).toEqual('textarea')
    it "should find the data-object"   , -> expect(rip.objectName).toEqual('person')
    it "should find the data-attribute", -> expect(rip.attributeName).toEqual('name')
    
    it "should prefer inner settings over outer", ->
      rip = makeRip """<div data-object="outer"><p data-url="inner"><span>Blubb</span></p></div>"""
      expect(rip.url).toEqual('inner')
    
  describe "guessing objectName from Rails", ->
    describe 'without parent-provided info', ->
      beforeEach -> rip = makeRip """<p id="person_123"><span>Blubb</span></p>"""
      it "should derive the objectName from a railslike id", -> expect(rip.objectName).toEqual('person')
    describe 'with parent-provided info', ->
      beforeEach -> rip = makeRip """<div data-object="customer"><p id="person_123"><span>Blubb</span></p></div>"""
      it "should not overwrite the explicit value with the guess", -> expect(rip.objectName).not.toEqual('person')
    
  describe "own data attributes", ->
    it "url should default to the current path", ->
      rip = makeRip '<p><span>Blubb</span></p>'
      expect(rip.url).toEqual(document.location.pathname)
    it "formtype should default to input", ->
      rip = makeRip '<p><span>Blubb</span></p>'
      expect(rip.formType).toEqual('input')
    it "should take precedence over anything set through parents", ->
      rip = makeRip """
        <p data-url="localhorst" data-formtype="textarea1" data-object="person" data-attribute="name">
          <span data-url="localhorst2" data-formtype="textarea" data-object="person2" data-attribute="name2">Blubb</span>
        </p>"""
      expect(rip.url).toEqual('localhorst2')
      expect(rip.formType).toEqual('textarea')
      expect(rip.objectName).toEqual('person2')
      expect(rip.attributeName).toEqual('name2')
    
xdescribe "Server communication"
xdescribe "Forms"
xdescribe "User Interaction"