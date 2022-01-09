<h1 align="center">Google Analytics 1.0.0</h1>

<p align="center">Implementation of Google's <a href="https://developers.google.com/analytics/devguides/collection/protocol/ga4">Measurement Protocol v4</a> for GameMaker Studio 2 by <b>@jujuadams</b></p>

<p align="center"><a href="https://github.com/JujuAdams/GoogleAnalytics/releases/">Download the .yymps</a></p>
<p align="center">Chat about this library on the <a href="https://discord.gg/8krYCqr">Discord server</a></p>

&nbsp;

Google Analytics has multiple entry points, including Android and iOS integrations with Firebase, a couple of JavaScript libraries, and an implementation specifically for AMP HTML. This library implements the lowest-level protocol, the so-called [Measurement Protocol](https://developers.google.com/analytics/devguides/collection/protocol/v1), which is designed to work in any environment where there is an HTTP-capable internet connection. This allows GameMaker to customize what information is being sent to Google at the HTTP request level, which affords you total control over the what analytics are being reported.

Using Google Analytics in general requires that you [set up an account](https://support.google.com/analytics/answer/9304153?hl=en&ref_topic=9303319) with Google. This backend documentation changes unpredictably so I can't give exact instructions, but in general you'll want to follow the instructions as though you were setting up a website. Make sure that you set up a Google Analytics 4 property. Further analytics-related setup documentation can be found [here](https://support.google.com/analytics/topic/9303319?hl=en&ref_topic=9143232)).

Setting up this library is comparatively straight-forward. You can import all the code from the [.yymps]() found in the latest release. Once you've got the code inside your project, set the macros in `__GoogConfig()` to match the values found in Google's backend. Make sure you call `GoogAsyncHTTPEvent()` in the Async HTTP event in a persistent object to help with debugging, and you're ready to start using the library.

Call `GoogHit()` to send events to Google Analytics. A hit can contain one or many events. The arguments for this function come in pairs, each pair describing an "event". The first argument in each pair is the name of the event, the second argument in each pair are the parameters for the event as a struct. You can find a big list of events and event parameters [here](https://developers.google.com/analytics/devguides/collection/protocol/ga4/reference/events). This GML implementation of the Measuremnt Protocol supports every type of event.

Please be careful with what events, and the quantity of events, that you send to Google. [There are some limitations](https://developers.google.com/analytics/devguides/collection/protocol/ga4/sending-events?client_type=gtag) that Google puts on hits, as of January 2022:
- Hits can have a maximum of 25 events
- Events can have a maximum of 25 parameters
- Events can have a maximum of 25 user properties
- Event names must be 40 characters or fewer, may only contain alpha-numeric characters and underscores, and must start with an alphabetic character
- Parameter names (including item parameters) must be 40 characters or fewer, may only contain alpha-numeric characters and underscores, and must start with an alphabetic character
- Parameter values (including item parameter values) must be 100 character or fewer
- Item parameters can have a maximum of 10 custom parameters
- The HTTP request body must be smaller than 130kB

This implementation also includes a way to send additional information about the user to Google using "user properties". User properties can be set by setting variables on the `GOOG_USER_PROPERTIES` struct. This struct is held in global scope so can be accessed everywhere. In order to filter data using user properties you'll need to set up custom dimensions and metrics [in the Google Analytics backend](https://support.google.com/analytics/answer/10075209?visit_id=637773252533763572-1115991491&rd=1). There are limitations on user properties as well:
- User property names must be 24 characters or fewer
- User property values must be 36 characters or fewer

Finally, this library automatically creates a client ID and user ID to differentiate players. If you'd like to override the in-built behaviour for something else, you can use the `GoogClientIDForce()` and `GoogUserIDForce()` functions. The default client ID and user ID values are randomly generated and thus anonymize users. I strongly recommend not using idenifying information as the client ID or user ID (e.g. don't use a player's Steam ID as an analytics user ID, consider using HMAC to hash it first). Furthermore, this library is hardcoded to prevent analytics data that you send to Google being used for targeted advertising by third parties.
