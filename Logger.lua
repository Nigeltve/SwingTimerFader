-- SwingTimerFader: chat output.
local ADDON, ns = ...

-- Severity levels; a message is shown when its level >= logger.logLevel.
local LEVEL = { DEBUG = 0, INFO = 1, WARNING = 2, ERROR = 3 }

local logger = {
    LEVEL = LEVEL,
    canDebug = false,           -- set true while developing to see Debug/Info/Warning output
    logLevel = LEVEL.DEBUG,     -- lowest severity shown when canDebug is on
}
ns.logger = logger

local function prefix(color, label)
    return ("|cff%s%s%s:|r "):format(color, ADDON, label and (" " .. label) or "")
end
local SAY = prefix("7dff86")
local PREFIX = {
    [LEVEL.DEBUG] = prefix("7da0ff", "Debug"),
    [LEVEL.INFO] = prefix("7dfff2", "Info"),
    [LEVEL.WARNING] = prefix("f4ff7d", "Warning"),
    [LEVEL.ERROR] = prefix("ff3737", "Error"),
}

local function log(self, level, msg)
    if not self.canDebug or level < self.logLevel then return end
    print(PREFIX[level] .. tostring(msg))
end

-- Always shown: messages meant for the player.
function logger:Say(msg)
    print(SAY .. tostring(msg))
end

function logger:LogDebug(msg)   log(self, LEVEL.DEBUG, msg) end
function logger:LogInfo(msg)    log(self, LEVEL.INFO, msg) end
function logger:LogWarning(msg) log(self, LEVEL.WARNING, msg) end

-- Errors are always shown, even in release builds with canDebug off.
function logger:LogError(msg)
    print(PREFIX[LEVEL.ERROR] .. tostring(msg))
end

function logger:Dump(tbl)
    if tbl == nil then
        self:Say("Table is nil")
        return
    end
    if not DevTools_Dump and UIParentLoadAddOn then
        pcall(UIParentLoadAddOn, "Blizzard_DebugTools")
    end
    if DevTools_Dump then DevTools_Dump(tbl) else self:Say(tostring(tbl)) end
end
