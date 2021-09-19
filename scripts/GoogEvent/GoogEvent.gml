/// @param name
/// @param [parametersStruct]
/// 
/// Sends an event to Google Analytics with the given name and, optionally, some parameters defined in a struct
/// It is recommended that parameters conform to the event specification, see https://developers.google.com/analytics/devguides/collection/protocol/ga4/reference/events

function GoogEvent(_name, _parameters = {})
{
    var _data = {
        client_id: global.__GoogClientID,
        events: [
            {
                name: _name,
                params: _parameters
            }
        ]
    };
    
    var _string = json_stringify(_data);
    var _id = http_post_string(global.__GoogURL, _string);
    if (GOOG_DEBUG) __GoogTrace("Sent HTTP request for event \"", _string, "\"");
    
    if (global.__GoogFirstRequestTime == undefined) global.__GoogFirstRequestTime = current_time;
    
    if ((global.__GoogUsingAsyncEvent == undefined) && (current_time - global.__GoogFirstRequestTime > 30000))
    {
        if (os_is_network_connected(false))
        {
            __GoogTrace("Warning! No async HTTP event handled, make sure GoogAsyncHTTPEvent() is being called in a persistent object");
            global.__GoogUsingAsyncEvent = false;
            ds_map_clear(global.__GoogHTTPResponseMap);
        }
        else
        {
            global.__GoogFirstRequestTime = undefined;
        }
    }
    
    if ((global.__GoogUsingAsyncEvent == undefined) || global.__GoogUsingAsyncEvent)
    {
        global.__GoogHTTPResponseMap[? _id] = _string;
    }
}