_       = require 'lodash'
Ractive = require 'ractive'

Eventful = require '../../utils/ractive/eventful.coffee'
firebase = require '../../models/firebase.coffee'
system   = require '../../models/system.coffee'
user     = require '../../models/user.coffee'
key      = require '../../utils/key.coffee'
Icons    = require '../icons.coffee'

module.exports = Eventful.extend

  'name': 'views/pages/new'

  'template': require '../../templates/pages/new.html'

  'data': { 'value': 'unfoldingWord-dev/ts-desktop', user }

  'components': { Icons }

  'adapt': [ Ractive.adaptors.Ractive ]

  # Listen to Enter keypress or Submit button click.
  submit: (evt, value) ->
    return if key.is(evt) and not key.isEnter(evt)

    [ owner, name ] = value.split '/'

    # Save repo.
    @publish '!projects/add', { owner, name }

    # Redirect to the dashboard.
    # TODO: trigger a named route
    window.location.hash = '#'

  onconstruct: ->
    # Sign-in a user.
    @on '!signin', ->
      do firebase.signin

  onrender: ->
    document.title = 'Add a project'

    # TODO: autocomplete on our username if we are logged in or based
    #  on repos we already have.
    autocomplete = (value) ->

    @observe 'value', _.debounce(autocomplete, 200), { 'init': no }

    # Focus on the input field.
    do @el.querySelector('input').focus

    @on 'submit', @submit