readr = require '../'
{expect} = require 'chai'
{deepInclude} = require './support/test_helpers'

testDir = __dirname

csvLocation = testDir + '/csv'
mustacheLocation = testDir + '/mustache'

# Takes two arrays of template objects and does a deep comparison
deepInclude = (results, expectedResults) ->
  expectedResults.every (eR) ->
    results.some (r) ->
      r.path is eR.path and r.contents is eR.contents and r.friendlyPath is eR.friendlyPath


describe 'readr', ->
  it 'globs for files and adds the default friendlyPath', (done) ->
    expectedResults = [
      {
        path: mustacheLocation + '/index.mustache'
        contents: '<h1>Hello, {{name}}</h1>'
        friendlyPath: 'mustache/index'
      }
      {
        path: mustacheLocation + '/show.mustache'
        contents: '<h1>{{user.name}}</h1>'
        friendlyPath: 'mustache/show'
      }
      {
        path: mustacheLocation + '/nested_dir/nested_dir_2/nested_dir_3/nested_file.mustache'
        contents: '<header>NESTED DIR!!!!</header>'
        friendlyPath: 'mustache/nested_dir/nested_dir_2/nested_dir_3/nested_file'
      }
    ]

    readr testDir, {extension: 'mustache'}, (err, files) ->
      expect(files.length).to.equal 3
      expect(deepInclude files, expectedResults).to.be.true

      done()


  it 'returns a single file with only the extension removed when no `friendlyPath` option is provided', (done) ->
    expectedResult =
      path: csvLocation + '/people.csv'
      contents: 'Name,Age\njohn,24'
      friendlyPath: csvLocation + '/people'

    readr csvLocation + '/people.csv', {extension: 'csv'}, (err, files) ->
      expect(files.length).to.equal 1
      expect(files[0]).to.eql expectedResult
      done()

  it "doesn't choke on a path with a trailing slash", (done) ->
    expectedResult =
      path: csvLocation + '/people.csv'
      contents: 'Name,Age\njohn,24'
      friendlyPath: 'csv/people'

    readr testDir + '/', {extension: 'csv'}, (err, files) ->
      expect(files.length).to.equal 1
      expect(files[0]).to.eql expectedResult
      done()

  describe '`friendlyPath` option', ->
    it 'is the `friendlyPath` option if `friendlyPath` option is a string', (done) ->
      options = {friendlyPath: 'peoplecsv', extension: 'csv'}

      expectedResult =
        path: csvLocation + '/people.csv'
        contents: 'Name,Age\njohn,24'
        friendlyPath: 'peoplecsv'

      readr csvLocation + '/people.csv', options, (err, files) ->
        expect(files.length).to.equal 1
        expect(files[0]).to.eql expectedResult
        done()


    it 'is the absolute path if no friendly option is provided and path argument is a file', (done) ->
      expectedResult =
        path: csvLocation + '/people.csv'
        contents: 'Name,Age\njohn,24'
        friendlyPath: csvLocation + '/people.csv'

      readr csvLocation + '/people.csv', (err, files) ->
        expect(files.length).to.equal 1
        expect(files[0]).to.eql expectedResult
        done()

    it 'invokes the `friendlyPath` option if `friendlyPath` option is a function', (done) ->
      friendlyPath = (path) -> 'dashboard/' + path

      expectedResults = [
        {
          path: mustacheLocation + '/index.mustache'
          contents: '<h1>Hello, {{name}}</h1>'
          friendlyPath: 'dashboard/index'
        }
        {
          path: mustacheLocation + '/show.mustache'
          contents: '<h1>{{user.name}}</h1>'
          friendlyPath: 'dashboard/show'
        }
        {
          path: mustacheLocation + '/nested_dir/nested_dir_2/nested_dir_3/nested_file.mustache'
          contents: '<header>NESTED DIR!!!!</header>'
          friendlyPath: 'dashboard/nested_dir/nested_dir_2/nested_dir_3/nested_file'
        }
      ]

      readr mustacheLocation, {friendlyPath, extension: 'mustache'}, (err, files) ->
        expect(deepInclude files, expectedResults).to.be.true
        done()
