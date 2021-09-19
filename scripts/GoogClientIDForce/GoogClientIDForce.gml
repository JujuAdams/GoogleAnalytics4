/// @param id
/// 
/// Forces the client ID to the given value. This library automatically generates a client ID for the user so this is rarely necessary
/// The ID provided to this function should be a UUIDv4 (http://www.ietf.org/rfc/rfc4122.txt)
///
/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters

function GoogClientIDForce(_id)
{
    if (_id != global.__GoogClientID)
    {
        global.__GoogClientID = string(_id);
        global.__GoogPayloadCommon = "v=1&tid=" + string(GOOG_TRACKING_ID) + "&cid=" + __GoogURLEncode(global.__GoogClientID);
        
        __GoogTrace("Set client ID to \"", global.__GoogClientID, "\"");
    }
}