mocha.setup 'bdd'

expect = chai.expect
vtex.portal.verbose = true

describe 'Totem Expiration', ->
  @timeout(5000)

  it 'should expire with default URL', (done) ->
    expectedURL = '/'
    calledURL = undefined

    vtex.portal.location =
      replace: (url) -> calledURL = url

    setTimeout ( ->
      expect(calledURL).to.equal(expectedURL)
      done()
    ), 100

    vtex.portal.startExpiration(undefined, 10, [])

  it 'should expire with URL', (done) ->
    expectedURL = 'test'
    calledURL = undefined

    vtex.portal.location =
      replace: (url) -> calledURL = url

    setTimeout ( ->
      expect(calledURL).to.equal(expectedURL)
      done()
    ), 100

    vtex.portal.startExpiration(expectedURL, 10)

  it 'should expire without URL', (done) ->
    calledURL = undefined

    vtex.portal.location =
      replace: (url) -> calledURL = url

    setTimeout ( ->
      expect(calledURL).to.be.undefined
      done()
    ), 100

    vtex.portal.startExpiration(false, 10, [])

  it 'should take longer to expire if event is triggered', (done) ->
    expectedURL = 'test'
    calledURL = undefined

    vtex.portal.location =
      replace: (url) -> calledURL = url

    # Trigger event
    setTimeout ( ->
      $(window).trigger('mousemove')
    ), 100

    # Should not be expired yet
    setTimeout ( ->
      expect(calledURL).to.be.undefined
    ), 250

    # Should be expired
    setTimeout ( ->
      expect(calledURL).to.equal(expectedURL)
      done()
    ), 400

    vtex.portal.startExpiration(expectedURL, 200, ['mousemove'])

  it 'should not take longer to expire if wrong event is triggered', (done) ->
    expectedURL = 'test'
    calledURL = undefined

    vtex.portal.location =
      replace: (url) -> calledURL = url

    # Trigger event
    setTimeout ( ->
      $(window).trigger('test')
    ), 100

    # Should be expired
    setTimeout ( ->
      expect(calledURL).to.equal(expectedURL)
    ), 250

    # Should be expired
    setTimeout ( ->
      expect(calledURL).to.equal(expectedURL)
      done()
    ), 400

    vtex.portal.startExpiration(expectedURL, 200, ['mousemove'])

  it 'should take longer to expire if custom event is triggered', (done) ->
    expectedURL = 'test'
    calledURL = undefined

    vtex.portal.location =
      replace: (url) -> calledURL = url

    # Trigger event
    setTimeout ( ->
      $(window).trigger('test')
    ), 100

    # Should not be expired yet
    setTimeout ( ->
      expect(calledURL).to.be.undefined
    ), 250

    # Should be expired
    setTimeout ( ->
      expect(calledURL).to.equal(expectedURL)
      done()
    ), 400

    vtex.portal.startExpiration(expectedURL, 200, ['test'])

  it 'should stop expiration', (done) ->
    expectedURL = 'test'
    calledURL = undefined

    vtex.portal.location =
      replace: (url) -> calledURL = url

    # Stop
    setTimeout ( ->
      vtex.portal.stopExpiration()
    ), 100

    # Should not be expired yet
    setTimeout ( ->
      expect(calledURL).to.be.undefined
      done()
    ), 400

    vtex.portal.startExpiration(expectedURL, 200, [])

mocha.run()