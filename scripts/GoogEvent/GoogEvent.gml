/// @param struct
/// 
/// Sends an event to Google Analytics
/// Struct must contain key-value pairs in accordance with Google Analytics parameters
/// 
/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters

function GoogEvent(_struct)
{
    if ((global.__GoogClientID == undefined) || (global.__GoogPayloadCommon == undefined))
    {
        show_error("Google Analytics:\nClient ID unset, please call GoogClientIDSet()\n ", true);
        return undefined;
    }
    
    var _string = "";
    
    var _names = variable_struct_get_names(_struct);
    var _length = array_length(_names);
    
    var _i = 0;
    repeat(_length)
    {
        _string += _names[_i] + "=" + __GoogURLEncode(_struct[$ _names[_i]]) + "&";
        ++_i;
    }
    
    _string += global.__GoogPayloadCommon;
    
    var _cacheBuster = round(__GoogXORShift32Random(999999));
    var _id = http_post_string("https://www.google-analytics.com/collect?payload_data&z=" + string(_cacheBuster), _string);
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