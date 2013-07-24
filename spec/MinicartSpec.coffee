jasmine.getFixtures().fixturesPath = "base/build/spec/fixtures"
jasmine.getJSONFixtures().fixturesPath = "base/build/spec/mocks"


describe 'SkuSelector Plugin', ->
	beforeEach ->
		mockNames = ['orderform.json']
		loadJSONFixtures(mockNames...)
		@mocks = (getJSONFixture(name) for name in mockNames)

	it 'should have loaded JSON fixtures correctly', ->
		#Assert
		expect(typeof @mocks).toBe(typeof [])
		expect(@mocks[0]).toBeDefined()
		expect(typeof @mocks[0]).toBe(typeof {})