-- SwingTimerFader: saved variables and settings.
-- STF_DB (account): delay, fadeTime.  STF_DB_CHAR (character): enabled.
local _, ns = ...

local DEFAULTS = { delay = 1.5, fadeTime = 0.5 }
local CHAR_DEFAULTS = { enabled = true }
-- Single source of truth for allowed ranges (used by /stf and the sliders).
ns.LIMITS = { delay = { 0, 5 }, fadeTime = { 0, 3 } }

local function clamp(key, value)
    local lim = ns.LIMITS[key]
    return math.min(lim[2], math.max(lim[1], value))
end

function ns.InitDB()
    STF_DB = type(STF_DB) == "table" and STF_DB or {}
    STF_DB_CHAR = type(STF_DB_CHAR) == "table" and STF_DB_CHAR or {}
    for k, v in pairs(DEFAULTS) do
        if type(STF_DB[k]) ~= type(v) then STF_DB[k] = v end
        STF_DB[k] = clamp(k, STF_DB[k])
    end
    for k, v in pairs(CHAR_DEFAULTS) do
        if type(STF_DB_CHAR[k]) ~= type(v) then STF_DB_CHAR[k] = v end
    end
end

-- Falls back to the default if saved variables aren't loaded yet.
function ns.Get(key)
    local value = STF_DB and STF_DB[key]
    if value == nil then value = DEFAULTS[key] end
    return value
end

function ns.IsEnabled()
    return STF_DB_CHAR and STF_DB_CHAR.enabled
end

-- Set delay/fadeTime, clamped to LIMITS. Returns false on bad input.
function ns.SetValue(key, value)
    value = tonumber(value)
    if not ns.LIMITS[key] or not value then return false end
    STF_DB[key] = clamp(key, value)
    if key == "delay" then ns.OnDelayChanged() end -- fadeTime is read live
    ns.SyncOptions()
    return true
end

function ns.SetEnabled(on)
    STF_DB_CHAR.enabled = on and true or false
    ns.Refresh()
    ns.SyncOptions()
end
