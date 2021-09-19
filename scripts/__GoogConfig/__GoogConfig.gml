//The tracking ID for your Google Analytics property
//This library uses the "Universal Analytics" API
//To set this up, see https://support.google.com/analytics/answer/9539598 and https://support.google.com/analytics/answer/10269537
#macro GOOG_TRACKING_ID  ""

//Name of the file on disk to store the user's client ID so that it persists between sessions
//A client ID is automatically generated for the user when this library is run for the first time
//If the cache file cannot be found then a new client ID will be generated
#macro GOOG_PERSISTENT_CACHE  "goog_cache.json"

//Set this to <true> to see more information about what events this library is sending
//This is verbose output and likely not useful in production builds
#macro GOOG_DEBUG  false