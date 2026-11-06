-- SwingTimerFader: shared helpers.
local _, ns = ...

-- True if a value is a restricted ("secret") value that must not be inspected.
function ns.IsSecret(v)
    if type(issecretvalue) ~= "function" then return false end
    local ok, r = pcall(issecretvalue, v)
    return not ok or r == true
end

function ns.Print(msg)
    print("|cff66ccffSwingTimerFader|r: " .. msg)
end
