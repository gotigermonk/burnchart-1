proxy      = do require('proxyquire').noCallThru
{ assert } = require 'chai'
path       = require 'path'

class Sa

  # How soon do we call back?
  timeout: 1

  # Save the uri.
  get: (uri) ->
    @params = { uri }
    @

  # Save the key-value pair.
  set: (key, value) ->
    @params[key] = value
    @
  
  # Call back with the response.
  end: (cb) ->
    setTimeout =>
      cb null, @response
    , @timeout

superagent = new Sa()

# Proxy the superagent lib.
request = proxy path.resolve(__dirname, '../src/modules/github/request.coffee'),
  'superagent': superagent

# User is ready, make the requests.
user = require '../src/models/user.coffee'
user.set 'ready', yes

# Get config so we can fudge timeout.
config = require '../src/models/config.coffee'

# Global mediator.
mediator = require '../src/modules/mediator.coffee'

module.exports =

  'request - all milestones (ok)': (done) ->
    superagent.response =
      'statusType': 2
      'error': no
      'body': [ null ]
    
    owner = 'unfoldingWord-dev'
    name = 'burnchart'

    request.allMilestones { owner, name }, (err, data) ->
      assert.isNull err
      assert.deepEqual superagent.params,
        'uri': 'https://api.github.com/repos/radekstepan/burnchart/milestones?state=open&sort=due_date&direction=asc'
        'Content-Type': 'application/json',
        'Accept': 'application/vnd.github.v3'
      assert.deepEqual data, [ null ]
      do done

  'request - all milestones (403)': (done) ->
    superagent.response =
      'statusType': 4
      'error': no
      'body':
        'message': 'API rate limit exceeded'

    owner = 'unfoldingWord-dev'
    name = 'burnchart'
    milestone = 0
    
    notified = no
    mediator.on '!app/notify', ->
      notified = yes

    request.oneMilestone { owner, name, milestone }, (err) ->
      assert err, 'Error'
      assert.isTrue notified

      mediator.off '!app/notify'

      do done

  'request - one milestone (ok)': (done) ->
    superagent.response =
      'statusType': 2
      'error': no
      'body': [ null ]
    
    owner = 'unfoldingWord-dev'
    name = 'burnchart'
    milestone = 1

    request.oneMilestone { owner, name, milestone }, (err, data) ->
      assert.isNull err
      assert.deepEqual superagent.params,
        'uri': 'https://api.github.com/repos/unfoldingWord-dev/burnchart/milestones/1?state=open&sort=due_date&direction=asc'
        'Content-Type': 'application/json',
        'Accept': 'application/vnd.github.v3'
      assert.deepEqual data, [ null ]
      do done
  
  'request - one milestone (404)': (done) ->
    superagent.response =
      'statusType': 4
      'error': Error "cannot GET undefined (404)"
      'body':
        'documentation_url': "http://developer.github.com/v3"
        'message': "Not Found"

    owner = 'unfoldingWord-dev'
    name = 'burnchart'
    milestone = 0
    
    request.oneMilestone { owner, name, milestone }, (err) ->
      assert err, 'Not Found'
      do done

  'request - one milestone (500)': (done) ->
    superagent.response =
      'statusType': 5
      'error': Error "Error"
      'body': null

    owner = 'unfoldingWord-dev'
    name = 'burnchart'
    milestone = 0
    
    request.oneMilestone { owner, name, milestone }, (err) ->
      assert err, 'Error'
      do done

  'request - all issues (ok)': (done) ->
    superagent.response =
      'statusType': 2
      'error': no
      'body': [ null ]

    owner = 'unfoldingWord-dev'
    name = 'burnchart'
    milestone = 0
    
    request.allIssues { owner, name, milestone }, {}, (err, data) ->
      assert.isNull err
      assert.deepEqual superagent.params,
        'uri': 'https://api.github.com/repos/unfoldingWord-dev/burnchart/issues?milestone=0&per_page=100'
        'Content-Type': 'application/json',
        'Accept': 'application/vnd.github.v3'
      assert.deepEqual data, [ null ]
      do done

  'request - timeout': (done) ->
    # Run this last or reset timeout to default again...
    config.set 'request.timeout', 10

    superagent.timeout = 20
    superagent.response =
      'statusType': 2
      'error': no
      'body': [ null ]

    owner = 'unfoldingWord-dev'
    name = 'burnchart'
    milestone = 0
    
    request.allIssues { owner, name, milestone }, {}, (err) ->
      assert err, 'Request has timed out'
      do done

  'request - use tokens': (done) ->
    user.set 'github.accessToken', 'ABC'

    superagent.response = {}

    owner = 'unfoldingWord-dev'
    name = 'burnchart'
    
    request.repo { owner, name }, ->
      assert superagent.params.Authorization, 'token ABC'
      do done
