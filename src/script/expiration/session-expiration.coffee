###
Namespace declaration
###
window.vtex or= {}
window.vtex.portal or= {}
vtex.portal.location = window.location # For test purposes
console.log or= -> # Declare empty log function for older IE's
Date.now or= -> new Date().getTime() # Shim for Date.now

###
Internal variables and functions
###

DEBUG = -> console.log.apply console, arguments if vtex.portal.verbose

# Which URL to redirect to
expirationURL = '/'

# How long should the user be idle before expiring this session
expirationMillis = 10 * 60 * 1000

# What to do when expiration occurs
expirationHandler = (idleTime, url = expirationURL) ->
  DEBUG "Totem time expired. Idle for", idleTime
  vtex.portal.stopExpiration()
  # Clean order form cookie
  document.cookie = "checkout.vtex.com=;expires=Thu, 01 Jan 1970 00:00:00 GMT; domain=.#{window.location.hostname}; path=/;";
  DEBUG "Cleaned order form cookie", document.cookie.split(";")
# Send to URL
  if url
    DEBUG "Redirecting to", url
    vtex.portal.location.replace url

# Which events should reset the expiration timer
expirationResetEvents = ["mousemove", "keyup", "click", "scroll"]

# Timeout id for the handleExpirationTimeout function
timeoutId = null 

# Time when last expiration reset event was recorded
lastExpirationResetEventDate = 0

# Record expiration reset event now
resetIdleTime = (e) ->
  DEBUG "Reset idle time with event", e?.type
  lastExpirationResetEventDate = Date.now()

# Check if the user is idle more than expirationMillis milliseconds and expire.
handleExpirationTimeout = (url, millis) ->
  idleTime = Date.now() - lastExpirationResetEventDate
  DEBUG "Idle for", idleTime
  if idleTime < millis
    timeToNextExpiration = millis - idleTime
    DEBUG "Setting timeout for", timeToNextExpiration
    timeoutId = setTimeout((-> handleExpirationTimeout(url, millis)), timeToNextExpiration)
  else
    DEBUG "Unbinding reset timer events"
    $(window).off(event, resetIdleTime) for event in expirationResetEvents
    expirationHandler(idleTime, url)

###
Exported functions and variables on vtex.portal namespace
###

vtex.portal.startExpiration = (url = expirationURL, millis = expirationMillis, events = expirationResetEvents) ->
  throw new Error("Totem expiration timeout already set") if timeoutId
  DEBUG "Setting Totem expiration timeout for", millis
  timeoutId = setTimeout((-> handleExpirationTimeout(url, millis)), millis)
  $(window).on(event, resetIdleTime) for event in events
  # Store events for cleanup
  expirationResetEvents = events if expirationResetEvents isnt events
  
vtex.portal.stopExpiration = ->
  clearTimeout(timeoutId)
  timeoutId = null
  $(window).off(event, resetIdleTime) for event in expirationResetEvents