-- SwingTimerFader: shared helpers.
local ADDON, ns = ...

-- Version from the .toc "## Version:" line.
local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
ns.VERSION = getMetadata and getMetadata(ADDON, "Version") or "unknown"

-- True if a value is a restricted ("secret") value that must not be inspected.
function ns.IsSecret(v)
    if type(issecretvalue) ~= "function" then return false end
    local ok, r = pcall(issecretvalue, v)
    return not ok or r == true
end
