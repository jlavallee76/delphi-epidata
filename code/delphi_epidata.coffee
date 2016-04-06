###
A module for DELPHI's Epidata API.

https://github.com/undefx/delphi-epidata

Notes:
 - If running in node.js (or using browserify), there are no external
   dependencies. Otherwise, a global jQuery object named `$` must be available.
###

# Use built-in node.js modules unless jQuery is available
unless $?.getJSON?
  http = require('http')
  querystring = require('querystring')


# Because the API is stateless, the Epidata class only contains static methods
class Epidata

  # API base url
  BASE_URL = 'http://delphi.midas.cs.cmu.edu/epidata/api.php'

  # Helper function to cast values and/or ranges to strings
  _listitem = (value) ->
    if value.hasOwnProperty('from') and value.hasOwnProperty('to')
      return "#{value['from']}-#{value['to']}"
    else
      return "#{value}"

  # Helper function to build a list of values and/or ranges
  _list = (values) ->
    if not Array.isArray(values)
      values = [values]
    return (_listitem(value) for value in values).join(',')

  # Helper function to request and parse epidata
  _request = (callback, params) ->
    # Function to handle the API response
    handler = (data) ->
      if data?.result?
        callback(data.result, data.message, data.epidata)
      else
        callback(0, 'unknown error', null)
    # Request data from the server
    if $?.getJSON?
      # API call with jQuery
      $.getJSON(BASE_URL, params, handler)
    else
      # Function to handle the HTTP response
      reader = (response) ->
        text = ''
        response.setEncoding('utf8')
        response.on('data', (chunk) -> text += chunk)
        response.on('error', (e) -> error(e.message))
        response.on('end', () -> handler(JSON.parse(text)))
      # API call with Node
      http.get("#{BASE_URL}?#{querystring.stringify(params)}", reader)

  # Build a `range` object (ex: dates/epiweeks)
  @range = (from, to) ->
    if to <= from
      [from, to] = [to, from]
    return { from: from, to: to }

  # Fetch FluView data
  @fluview: (callback, regions, epiweeks, issues, lag) ->
    # Check parameters
    unless regions? and epiweeks?
      throw { msg: '`regions` and `epiweeks` are both required' }
    if issues? and lag?
      throw { msg: '`issues` and `lag` are mutually exclusive' }
    # Set up request
    params =
      'source': 'fluview'
      'regions': _list(regions)
      'epiweeks': _list(epiweeks)
    if issues?
      params.issues = _list(issues)
    if lag?
      params.lag = lag
    # Make the API call
    _request(callback, params)

  # Fetch ILINet data
  @ilinet: (callback, locations, epiweeks, auth) ->
    # Check parameters
    unless locations? and epiweeks?
      throw { msg: '`locations` and `epiweeks` are both required' }
    # Set up request
    params =
      'source': 'ilinet'
      'locations': _list(locations)
      'epiweeks': _list(epiweeks)
    if auth?
      params.auth = auth
    # Make the API call
    _request(callback, params)

  # Fetch Delphi's imputed state ILI
  @stateili: (callback, auth, states, epiweeks) ->
    # Check parameters
    unless auth? and states? and epiweeks?
      throw { msg: '`auth`, `states`, and `epiweeks` are all required' }
    # Set up request
    params =
      'source': 'stateili'
      'auth': auth
      'states': _list(states)
      'epiweeks': _list(epiweeks)
    # Make the API call
    _request(callback, params)

  # Fetch Google Flu Trends data
  @gft: (callback, locations, epiweeks) ->
    # Check parameters
    unless locations? and epiweeks?
      throw { msg: '`locations` and `epiweeks` are both required' }
    # Set up request
    params =
      'source': 'gft'
      'locations': _list(locations)
      'epiweeks': _list(epiweeks)
    # Make the API call
    _request(callback, params)

  # Fetch Google Health Trends data
  @ght: (callback, auth, locations, epiweeks, query) ->
    # Check parameters
    unless auth? and locations? and epiweeks? and query?
      throw { msg: '`auth`, `locations`, `epiweeks`, and `query` are all required' }
    # Set up request
    params =
      'source': 'ght'
      'auth': auth
      'locations': _list(locations)
      'epiweeks': _list(epiweeks)
      'query': query
    # Make the API call
    _request(callback, params)

  # Fetch HealthTweets data
  @twitter: (callback, auth, locations, dates, epiweeks) ->
    # Check parameters
    unless auth? and locations?
      throw { msg: '`auth` and `locations` are both required' }
    unless dates? ^ epiweeks?
      throw { msg: 'exactly one of `dates` and `epiweeks` is required' }
    # Set up request
    params =
      'source': 'twitter'
      'auth': auth
      'locations': _list(locations)
    if dates?
      params.dates = _list(dates)
    if epiweeks?
      params.epiweeks = _list(epiweeks)
    # Make the API call
    _request(callback, params)

  # Fetch Wikipedia access data
  @wiki: (callback, articles, dates, epiweeks, hours) ->
    # Check parameters
    unless articles?
      throw { msg: '`articles` is required' }
    unless dates? ^ epiweeks?
      throw { msg: 'exactly one of `dates` and `epiweeks` is required' }
    # Set up request
    params =
      'source': 'wiki'
      'articles': _list(articles)
    if dates?
      params.dates = _list(dates)
    if epiweeks?
      params.epiweeks = _list(epiweeks)
    if hours?
      params.hours = _list(hours)
    # Make the API call
    _request(callback, params)

  # Fetch NIDSS flu data
  @nidss_flu: (callback, regions, epiweeks, issues, lag) ->
    # Check parameters
    unless regions? and epiweeks?
      throw { msg: '`regions` and `epiweeks` are both required' }
    if issues? and lag?
      throw { msg: '`issues` and `lag` are mutually exclusive' }
    # Set up request
    params =
      'source': 'nidss_flu'
      'regions': _list(regions)
      'epiweeks': _list(epiweeks)
    if issues?
      params.issues = _list(issues)
    if lag?
      params.lag = lag
    # Make the API call
    _request(callback, params)

  # Fetch NIDSS dengue data
  @nidss_dengue: (callback, locations, epiweeks) ->
    # Check parameters
    unless locations? and epiweeks?
      throw { msg: '`locations` and `epiweeks` are both required' }
    # Set up request
    params =
      'source': 'nidss_dengue'
      'locations': _list(locations)
      'epiweeks': _list(epiweeks)
    # Make the API call
    _request(callback, params)

  # Fetch Delphi's forecast
  @delphi: (callback, system, epiweek) ->
    # Check parameters
    unless system? and epiweek?
      throw { msg: '`system` and `epiweek` are both required' }
    # Set up request
    params =
      'source': 'delphi'
      'system': system
      'epiweek': epiweek
    # Make the API call
    _request(callback, params)

  # Fetch Delphi's digital surveillance signals
  @signals: (callback, auth, names, locations, epiweeks) ->
    # Check parameters
    unless auth? and names? and locations? and epiweeks?
      throw { msg: '`auth`, `names`, `locations`, and `epiweeks` are all required' }
    # Set up request
    params =
      'source': 'signals'
      'auth': auth
      'names': _list(names)
      'locations': _list(locations)
      'epiweeks': _list(epiweeks)
    # Make the API call
    _request(callback, params)

  # Fetch Delphi's wILI nowcast
  @nowcast: (callback, locations, epiweeks) ->
    # Check parameters
    unless locations? and epiweeks?
      throw { msg: '`locations` and `epiweeks` are both required' }
    # Set up request
    params =
      'source': 'nowcast'
      'locations': _list(locations)
      'epiweeks': _list(epiweeks)
    # Make the API call
    _request(callback, params)

  # Fetch API metadata
  @meta: (callback) ->
    _request(callback, {'source': 'meta'})


# Export the API to the global environment
(exports ? window).Epidata = Epidata
