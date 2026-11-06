-- SwingTimerFader: the bar groups and writing alpha to Blizzard's frames.
local _, ns = ...

local IsSecret = ns.IsSecret

ns.PHASE = { SHOWN = "shown", WAITING = "waiting", FADING = "fading", HIDDEN = "hidden", OFF = "off" }
local PHASE = ns.PHASE

-- One group per independently faded set of bars.
local function newGroup(key, frames)
    return {
        key = key, frames = frames, cache = {}, complete = false,
        active = false, phase = PHASE.SHOWN, alpha = 1,
        fadeStart = 0, fadeFrom = 1, -- fade progress
        waitStart = 0, swingHold = 0, -- idle countdown
    }
end
ns.melee = newGroup("melee", { "SwingTimerMainHandFrame", "SwingTimerOffHandFrame" })
ns.ranged = newGroup("ranged", { "SwingTimerRangedFrame" })
ns.groups = { ns.melee, ns.ranged }

local suppressHook = false -- true while we write alpha ourselves
local hooked = {}

local function hookFrame(frame, group)
    if hooked[frame] then return end
    hooked[frame] = true
    -- Observe native alpha writes without replacing any method (no taint).
    pcall(hooksecurefunc, frame, "SetAlpha", function(self)
        if suppressHook or group.phase == PHASE.OFF or group.alpha >= 1 then return end
        suppressHook = true
        pcall(self.SetAlpha, self, group.alpha)
        suppressHook = false
    end)
end

local function usable(frame)
    if not frame or not frame.SetAlpha then return false end
    if not frame.IsForbidden then return true end
    local ok, forbidden = pcall(frame.IsForbidden, frame)
    return ok and not IsSecret(forbidden) and not forbidden
end

-- Resolve and hook frames once; retry only while some are still missing
-- (they may be created after we load).
local function resolve(group)
    local list, found = group.cache, 0
    for i, name in ipairs(group.frames) do
        if not list[i] then
            local frame = _G[name]
            if usable(frame) then
                hookFrame(frame, group)
                list[i] = frame
            end
        end
        if list[i] then found = found + 1 end
    end
    group.complete = found == #group.frames
end

-- Write the group's current alpha to all of its frames.
function ns.Apply(group)
    if not group.complete then resolve(group) end
    local a = group.alpha
    suppressHook = true
    for _, frame in pairs(group.cache) do
        pcall(frame.SetAlpha, frame, a) -- never leave suppressHook stuck on an error
    end
    suppressHook = false
end

-- Also writes while frames are missing, so late-created ones get the right alpha.
function ns.SetGroupAlpha(group, a)
    if a ~= group.alpha or not group.complete then
        group.alpha = a
        ns.Apply(group)
    end
end

-- Pick up frames that didn't exist yet (called on world entry / gear changes).
function ns.ResolveMissing()
    for _, g in ipairs(ns.groups) do
        if not g.complete then ns.Apply(g) end
    end
end

function ns.Describe(g)
    local parts = {}
    for i, name in ipairs(g.frames) do
        local state = g.cache[i] and "ok" or (_G[name] and "unusable" or "missing")
        parts[#parts + 1] = name .. "=" .. state
    end
    return ("%s: active=%s phase=%s alpha=%.2f  %s"):format(
        g.key, tostring(g.active), g.phase, g.alpha, table.concat(parts, " "))
end
