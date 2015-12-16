rip = null
makeRip = (html) ->
  $(html)
    .find('span')
    .restInPlace()
    .data('restInPlaceEditor')

beforeEach -> rip = null

describe "Setup", ->
  describe "looking up attributes in parents", ->
    beforeEach ->
      rip = makeRip """
        <p data-url="localhorst" data-formtype="textarea" data-object="person" data-attribute="name" data-placeholder="Enter name">
          <span>Blubb</span>
        </p>"""
    it "should find the data-url"        , -> expect(rip.url).toEqual('localhorst')
    it "should find the data-formtype"   , -> expect(rip.formType).toEqual('textarea')
    it "should find the data-object"     , -> expect(rip.objectName).toEqual('person')
    it "should find the data-attribute"  , -> expect(rip.attributeName).toEqual('name')
    it "should find the data-placeholder", -> expect(rip.placeholder).toEqual('Enter name')

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
        <p data-url="localhorst" data-formtype="textarea1" data-object="person" data-attribute="name" data-placeholder="placeholder">
          <span data-url="localhorst2" data-formtype="textarea" data-object="person2" data-attribute="name2" data-placeholder="placeholder2">Blubb</span>
        </p>"""
      expect(rip.url).toEqual('localhorst2')
      expect(rip.formType).toEqual('textarea')
      expect(rip.objectName).toEqual('person2')
      expect(rip.attributeName).toEqual('name2')
      expect(rip.placeholder).toEqual('placeholder2')

describe "Server communication", ->
  beforeEach ->
    rip = makeRip '<p><span data-object="person" data-attribute="age" data-placeholder="placeholder">Blubb</span></p>'

  describe "when processing the response from the server", ->

    it "should not include_root_in_json by defafult", ->
      expect(rip.include_root_in_json).toBe(false)

    it "should unwrap the object if include_root_in_json is set", ->
      rip.include_root_in_json = true
      expect(rip.extractAttributeFromData(person : {age:10})).toEqual(10)

    it "should directly access the attribute if include_root_in_json is not set", ->
      rip.include_root_in_json = false
      expect(rip.extractAttributeFromData(age:12)).toEqual(12)

  describe "when sending the update", ->
    csrf_metatags = null
    describe "when not changing fields", ->
      beforeEach ->
        spyOn(rip, 'getValue').andReturn('placeholder')
        csrf_metatags = $('meta[name=csrf-param], meta[name=csrf-token]')
        csrf_metatags.remove()
      afterEach ->
        csrf_metatags.appendTo($('head'))

      it "should not send the data", ->
        expect(rip.requestData()['person[age]']).toEqual(null)

    describe "when changing fields", ->
      beforeEach ->
        spyOn(rip, 'getValue').andReturn(111)
        csrf_metatags = $('meta[name=csrf-param], meta[name=csrf-token]')
        csrf_metatags.remove()

      afterEach ->
        csrf_metatags.appendTo($('head'))

      it "should include the data", ->
        expect(rip.requestData()['person[age]']).toEqual(111)

      it "should include rails csrf stuff if its in the HTML", ->
        $('head').append """
          <meta content="test_authenticity_token" name="csrf-param" />
          <meta content="123456" name="csrf-token" />
        """
        expect(rip.requestData()['test_authenticity_token']).toEqual('123456')

      it "should not include rails csrf stuff if its not in the HTML", ->
        expect(rip.requestData()['authenticity_token']).toBeUndefined()


  describe "after updating", ->
    jqXHR = null
    beforeEach ->
      jqXHR = new $.Deferred()
      spyOn(rip, 'ajax').andCallFake (options = {}) ->
        options.url      = @url
        options.dataType = "json"
        jqXHR

    describe "when receiving HTTP 204 No Content", ->
      newValue = 12
      beforeEach ->
        spyOn(rip, 'getValue').andCallFake () ->
          newValue
        spyOn(rip, 'loadSuccessCallback')
        rip.update()

      it "should abort", ->
        jqXHR.status = 204
        jqXHR.resolve('', '', jqXHR)
        expect(rip.loadSuccessCallback).toHaveBeenCalledWith(newValue, true)

    describe "when receiving an empty body", ->
      beforeEach ->
        spyOn(rip, 'loadViaGET')
        rip.update()

      it "should load via get", ->
        jqXHR.status = 200
        jqXHR.resolve('', '', jqXHR)
        expect(rip.loadViaGET).toHaveBeenCalled()

    describe "when receiving a body with data", ->
      response = age : 12
      beforeEach ->
        spyOn(rip, 'loadSuccessCallback')
        rip.update(response)

      it "should load the success callback", ->
        jqXHR.resolve(response)
        expect(rip.loadSuccessCallback).toHaveBeenCalledWith(response)

    describe "when receiving unparseable data", ->
      beforeEach ->
        spyOn(rip, 'loadViaGET')
        rip.update()

      it "should load via get", ->
        jqXHR.status = 200
        jqXHR.reject(jqXHR, 'parsererror')
        expect(rip.loadViaGET).toHaveBeenCalled()

    describe "when receiving any other error", ->
      beforeEach ->
        spyOn(rip, 'abort')
        rip.update()

      it "should abort", ->
        jqXHR.status = 500
        jqXHR.reject(jqXHR)
        expect(rip.abort).toHaveBeenCalled()

    describe "when receiving HTML", ->
      response = age : "<strong></strong>"
      beforeEach ->
        rip.update(response)

      it "should escape the HTML", ->
        jqXHR.resolve(response)
        expect(rip.$element.html()).toEqual("&lt;strong&gt;&lt;/strong&gt;")


describe "User Interaction", ->
  beforeEach ->
    rip = makeRip '<p><span data-object="person" data-attribute="age">Blubb</span></p>'

  describe "when clicked", ->
    it "should be turned rip-active", ->
      rip.$element.click()
      expect(rip.$element.hasClass('rip-active')).toBe(true)

    it "should call activate", ->
      spyOn(rip, 'activate')
      rip.$element.click()
      expect(rip.activate).toHaveBeenCalled()

    xit "should remove the click handler"

  describe "when aborting", ->
    beforeEach ->
      rip.activate()

    it "should remove rip-active", ->
      rip.abort()
      expect(rip.$element.hasClass('rip-active')).toBe(false)

describe "jQuery Interface", ->

  it "should automatically convert elements with class rest-in-place", ->
    rip = $('#autoload-sample').data('restInPlaceEditor')
    expect(typeof rip.activate).toEqual("function")

  it "should convert jQuery objects with the restInPlace() function ", ->
    rip = $('<p><span data-object="person" data-attribute="age">Blubb</span></p>')
      .find('span')
      .restInPlace()
      .data('restInPlaceEditor')
    expect(typeof rip.activate).toEqual("function")

describe "Events", ->
  handlers = {}
  jqXHR = null

  beforeEach ->
    rip = makeRip '<p><span data-object="person" data-attribute="age">Blubb</span></p>'
    handlers =
      activate : ->
      success  : ->
      failure  : ->
      update   : ->
      abort    : ->
      ready    : ->
    jqXHR = new $.Deferred()
    spyOn(rip, 'ajax').andCallFake (options = {}) ->
      options.url      = @url
      options.dataType = "json"
      jqXHR


  it "should dispatch activate.rest-in-place", ->
    spyOn(handlers, 'activate')
    rip.$element.bind("activate.rest-in-place", handlers.activate)
    rip.activate()
    expect(handlers.activate).toHaveBeenCalled()

  it "should dispatch success.rest-in-place", ->
    spyOn(handlers, 'success')
    rip.$element.bind("success.rest-in-place", handlers.success)
    rip.loadSuccessCallback({person: {age: 666}})
    expect(handlers.success).toHaveBeenCalled()

  describe "on failure", ->
    responseJSON = {"some": "json"}
    beforeEach ->
      spyOn(handlers, 'failure')
      rip.$element.bind("failure.rest-in-place", handlers.failure)
      jqXHR.status = 404
      jqXHR.responseJSON = responseJSON
      jqXHR.reject(jqXHR, "Response text")

    it "loadViaGET should dispatch failure.rest-in-place", ->
      rip.loadViaGET()
      expect(handlers.failure).toHaveBeenCalledWith(jasmine.any(jQuery.Event),responseJSON)
      # Test POST failure

    it "update should dispatch failure.rest-in-place", ->
      rip.update()
      expect(handlers.failure).toHaveBeenCalledWith(jasmine.any(jQuery.Event), responseJSON)

  it "should dispatch update.rest-in-place", ->
    spyOn(handlers, 'update')
    rip.$element.bind("update.rest-in-place", handlers.update)
    rip.update()
    expect(handlers.update).toHaveBeenCalled()

  it "should dispatch abort.rest-in-place", ->
    spyOn(handlers, 'abort')
    rip.$element.bind("abort.rest-in-place", handlers.abort)
    rip.activate()
    rip.abort()
    expect(handlers.abort).toHaveBeenCalled()

  it "should dispatch ready.rest-in-place", ->
    spyOn(handlers, 'ready')
    rip.$element.bind("ready.rest-in-place", handlers.ready)
    rip.activate()
    expect(handlers.ready).toHaveBeenCalled()

describe "Placeholder", ->
  beforeEach ->
    rip = makeRip '<p><span data-placeholder="Enter age"></span></p>'

  it "sets a placeholder when the value is empty", ->
    expect(rip.$element.html()).toEqual('<span class="rest-in-placeholder">Enter age</span>')

  it "dosen't set a placeholder when a value is present", ->
    rip = makeRip '<p><span data-object="person" data-attribute="age" data-placeholder="Enter age">123</span></p>'
    expect(rip.$element.html()).toNotEqual('<span class="rest-in-placeholder">Enter age</span>')

  it "switches to placeholder attribute when activated", ->
    rip.activate()
    expect(rip.$element.find('input')[0].hasAttribute('placeholder'));

