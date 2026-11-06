-- SwingTimerFader: detects when each bar group is in use, and drives the fader.
local ADDON, ns = ...

local IsSecret, melee, ranged = ns.IsSecret, ns.melee, ns.ranged

local AUTO_ATTACK = 6603
local AUTO_REPEAT_SPELLS = { 75, 5019, 2764 } -- Auto Shot, Shoot (wand), Throw
local SWING_RANGED = Enum and Enum.PlayerSwingType and Enum.PlayerSwingType.Ranged or 2

local IsCurrent = IsCurrentSpell or (C_Spell and C_Spell.IsCurrentSpell)
local GetName = (C_Spell and C_Spell.GetSpellName) or GetSpellInfo

-- Call fn safely; return its first result only if it is a readable value.
local function readable(fn, ...)
    if not fn then return nil end
    local ok, r = pcall(fn, ...)
    if ok and not IsSecret(r) then return r end
end

-- State detection ------------------------------------------------------------------
local function rangedRepeating()
    for _, id in ipairs(AUTO_REPEAT_SPELLS) do
        if readable(IsCurrent, id) then return true end
        local name = readable(GetName, id)
        if name and readable(IsAutoRepeatSpell, name) then return true end
    end
    return false
end

-- Used on login/reload, when no start/stop event will tell us the state.
local function readState()
    melee.active = readable(IsCurrent, AUTO_ATTACK) and true or false
    ranged.active = rangedRepeating()
end

-- Swing interval in seconds, from the event or the current weapon speed.
local function swingSeconds(duration, isRanged)
    if type(duration) == "number" and not IsSecret(duration) and duration > 0 then return duration end
    local speed = isRanged and readable(UnitRangedDamage, "player") or readable(UnitAttackSpeed, "player")
    return type(speed) == "number" and speed or 0
end

local function setActive(g, on)
    if g.active == on then return end
    g.active = on
    ns.RefreshGroup(g, ns.IsEnabled())
end

-- Handlers -------------------------------------------------------------------------
local events = CreateFrame("Frame")
local handlers = {}

function handlers.ADDON_LOADED(name)
    if name ~= ADDON then return end
    ns.InitDB()
    ns.CreateOptions()
    events:UnregisterEvent("ADDON_LOADED")
end

function handlers.PLAYER_ENTERING_WORLD()
    readState()   -- correct state after /reload mid-attack
    ns.Refresh()
    for _, g in ipairs(ns.groups) do ns.Apply(g) end -- (re)hook frames that now exist
end

-- Bars may be created when weapons change; pick them up.
handlers.PLAYER_EQUIPMENT_CHANGED = ns.ResolveMissing
handlers.WEAPON_SLOT_CHANGED = ns.ResolveMissing

-- PLAYER_ENTER/LEAVE_COMBAT mean melee auto-attack started/stopped.
function handlers.PLAYER_ENTER_COMBAT() setActive(melee, true) end
function handlers.PLAYER_LEAVE_COMBAT() setActive(melee, false) end
function handlers.START_AUTOREPEAT_SPELL() setActive(ranged, true) end
function handlers.STOP_AUTOREPEAT_SPELL() setActive(ranged, false) end
function handlers.PLAYER_DEAD()
    melee.active, ranged.active = false, false
    ns.Refresh()
end

-- swingType: 0 = main hand, 1 = off hand, 2 = ranged (Enum.PlayerSwingType)
function handlers.PLAYER_SWING(duration, swingType)
    if swingType == nil or IsSecret(swingType) then return end
    local isRanged = swingType == SWING_RANGED
    ns.OnSwing(isRanged and ranged or melee, swingSeconds(duration, isRanged))
end

events:SetScript("OnEvent", function(_, event, ...)
    local h = handlers[event]
    if h then h(...) end
end)
for event in pairs(handlers) do
    pcall(events.RegisterEvent, events, event) -- some events may not exist on every client
end
