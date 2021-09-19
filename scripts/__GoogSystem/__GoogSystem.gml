global.__GoogClientID         = undefined;
global.__GoogPayloadCommon    = undefined;
global.__GoogHTTPResponseMap  = ds_map_create();
global.__GoogFirstRequestTime = undefined;
global.__GoogUsingAsyncEvent  = undefined;

//Set up the XORShift32 starting seed
global.__GoogXORShift32State = floor(1000000*date_current_datetime() + display_mouse_get_x() + display_get_width()*display_mouse_get_y());

global.__GoogURLEncodeInBuffer  = buffer_create(1024, buffer_grow, 1);
global.__GoogURLEncodeOutBuffer = buffer_create(1024, buffer_grow, 1);
global.__GoogURLEncodeAllowed   = array_create(256, false);
global.__GoogURLEncodeHex       = array_create(256);

for(var _i = ord("A"); _i <= ord("Z"); _i++) global.__GoogURLEncodeAllowed[_i] = true;
for(var _i = ord("a"); _i <= ord("z"); _i++) global.__GoogURLEncodeAllowed[_i] = true;
for(var _i = ord("0"); _i <= ord("9"); _i++) global.__GoogURLEncodeAllowed[_i] = true;
global.__GoogURLEncodeAllowed[ord("-")] = true;
global.__GoogURLEncodeAllowed[ord("_")] = true;
global.__GoogURLEncodeAllowed[ord(".")] = true;
global.__GoogURLEncodeAllowed[ord("!")] = true;
global.__GoogURLEncodeAllowed[ord("~")] = true;
global.__GoogURLEncodeAllowed[ord("*")] = true;
global.__GoogURLEncodeAllowed[ord("'")] = true;
global.__GoogURLEncodeAllowed[ord("(")] = true;
global.__GoogURLEncodeAllowed[ord(")")] = true;

for (_i = 0; _i < 256; _i++)
{
    var _hd = _i >> 4;
    
    if (_hd >= 10)
    {
        var _hv = ord("A") + _hd - 10;
    }
    else
    {
        var _hv = ord("0") + _hd;
    }
    
    var _hd = _i & $F;
    if (_hd >= 10)
    {
        _hv |= (ord("A") + _hd - 10) << 8;
    }
    else
    {
        _hv |= (ord("0") + _hd) << 8;
    }
    
    global.__GoogURLEncodeHex[_i] = _hv;
}

var _generateClientID = true;
if (file_exists(GOOG_PERSISTENT_CACHE))
{
    __GoogTrace("Found persistent cache, trying to load");
    
    try
    {
        var _buffer = buffer_load(GOOG_PERSISTENT_CACHE);
        var _string = buffer_read(_buffer, buffer_string);
        var _json = json_parse(_string);
        
        GoogClientIDForce(_json.clientID);
        
        __GoogTrace("Persistent cache loaded successfully");
        _generateClientID = false;
    }
    catch(_)
    {
        __GoogTrace("Warning! Persistent cache failed to load, generating a new client ID");
    }
}
else
{
    __GoogTrace("No persistent cache found, generating a new client ID");
}

if (_generateClientID)
{
    GoogClientIDForce(__GoogGenerateUUID4String(true));
    
    //Save out the generated client ID to our cache for use next time
    var _string = json_stringify({ clientID: GoogClientIDGet() });
    var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
    buffer_write(_buffer, buffer_text, _string);
    buffer_save(_buffer, GOOG_PERSISTENT_CACHE);
    buffer_delete(_buffer);
    
    __GoogTrace("Persistent cache saved to disk");
}





/// @param string
function __GoogURLEncode(_string)
{
    buffer_seek(global.__GoogURLEncodeInBuffer, buffer_seek_start, 0);
    buffer_write(global.__GoogURLEncodeInBuffer, buffer_text, string(_string));
    
    var _length = buffer_tell(global.__GoogURLEncodeInBuffer);
    buffer_seek(global.__GoogURLEncodeInBuffer, buffer_seek_start, 0);
    buffer_seek(global.__GoogURLEncodeOutBuffer, buffer_seek_start, 0);
    repeat (_length)
    {
        var _byte = buffer_read(global.__GoogURLEncodeInBuffer, buffer_u8);
        if (global.__GoogURLEncodeAllowed[_byte])
        {
            buffer_write(global.__GoogURLEncodeOutBuffer, buffer_u8, _byte);
        }
        else
        {
            buffer_write(global.__GoogURLEncodeOutBuffer, buffer_u8, ord("%"));
            buffer_write(global.__GoogURLEncodeOutBuffer, buffer_u16, global.__GoogURLEncodeHex[_byte]);
        }
    }
    
    buffer_write(global.__GoogURLEncodeOutBuffer, buffer_u8, 0);
    buffer_seek(global.__GoogURLEncodeOutBuffer, buffer_seek_start, 0);
    return buffer_read(global.__GoogURLEncodeOutBuffer, buffer_string);
}

/// @param [hyphenate=false]
function __GoogGenerateUUID4String(_hyphenate = false)
{
    //As per https://www.cryptosys.net/pki/uuid-rfc4122.html (though without the hyphens)
    var _UUID = md5_string_utf8(string(current_time) + string(date_current_datetime()) + string(__GoogXORShift32Random(1000000)));
    _UUID = string_set_byte_at(_UUID, 13, ord("4"));
    _UUID = string_set_byte_at(_UUID, 17, ord(__GoogXORShift32Choose("8", "9", "a", "b")));
    
    if (_hyphenate)
    {
        _UUID = string_copy(_UUID, 1, 8) + "-" + string_copy(_UUID, 9, 4) + "-" + string_copy(_UUID, 13, 4) + "-" + string_copy(_UUID, 17, 4) + "-" + string_copy(_UUID, 21, 12);
    }
    
    return _UUID;
}

//Basic XORShift32, nothing fancy
function __GoogXORShift32Random(_value)
{
    var _state = global.__GoogXORShift32State;
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state <<  5;
    global.__GoogXORShift32State = _state;
    
	return _value * abs(_state) / (real(0x7FFFFFFFFFFFFFFF) + 1.0);
}

function __GoogXORShift32Choose()
{
    return argument[floor(__GoogXORShift32Random(argument_count))];
}

function __GoogTrace()
{
    var _string = "Google Analytics: ";
    
    var _i = 0;
    repeat(argument_count)
    {
        _string += argument[_i];
        ++_i;
    }
    
    show_debug_message(_string);
    
    return _string;
}