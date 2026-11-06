-- SwingTimerFader: fade state machine.
-- The idle countdown is a one-shot timer; OnUpdate runs only during the fade.
local _, ns = ...

local SetGroupAlpha, Get, groups, PHASE = ns.SetGroupAlpha, ns.Get, ns.groups, ns.PHASE
local logger = ns.logger

local driver = CreateFrame("Frame")
driver:Hide()
local fadingCount = 0

local function cancelTimer(g)
    if g.timer then g.timer:Cancel(); g.timer = nil end
end

local function stopFade(g)
    if g.phase == PHASE.FADING then
        fadingCount = fadingCount - 1
        if fadingCount == 0 then driver:Hide() end
    end
end

-- Leave whatever the group was doing and enter a new phase.
local function enterPhase(g, phase, alpha)
    cancelTimer(g)
    stopFade(g)
    if g.phase ~= phase then logger:LogDebug(("%s: %s -> %s"):format(g.key, g.phase, phase)) end
    g.phase = phase
    if alpha then SetGroupAlpha(g, alpha) end
end

local function startFade(g)
    g.timer = nil
    if g.phase ~= PHASE.WAITING then return end
    if Get("fadeTime") <= 0 then
        enterPhase(g, PHASE.HIDDEN, 0)
        return
    end
    logger:LogDebug(("%s: %s -> %s"):format(g.key, g.phase, PHASE.FADING))
    g.phase, g.fadeStart, g.fadeFrom = PHASE.FADING, GetTime(), g.alpha
    fadingCount = fadingCount + 1
    driver:Show()
end

driver:SetScript("OnUpdate", function()
    local now, dur = GetTime(), Get("fadeTime")
    for _, g in ipairs(groups) do
        if g.phase == PHASE.FADING then
            local t = dur > 0 and (now - g.fadeStart) / dur or 1
            if t >= 1 then
                enterPhase(g, PHASE.HIDDEN, 0)
            else
                SetGroupAlpha(g, g.fadeFrom * (1 - t))
            end
        end
    end
end)

-- (Re)arm the countdown from waitStart. The bar stays up for the fade delay,
-- or at least one swing interval when the countdown was started by a swing.
local function scheduleFade(g)
    cancelTimer(g)
    local remaining = g.waitStart + math.max(Get("delay"), g.swingHold) - GetTime()
    if remaining <= 0 then
        startFade(g)
    else
        g.timer = C_Timer.NewTimer(remaining, function() startFade(g) end)
    end
end

local function startWaiting(g, swingHold)
    enterPhase(g, PHASE.WAITING)
    g.waitStart, g.swingHold = GetTime(), swingHold or 0
    scheduleFade(g)
end

-- Bring one group in line with its active flag and the enabled setting.
function ns.RefreshGroup(g, enabled)
    if not enabled then
        if g.phase ~= PHASE.OFF then
            enterPhase(g, PHASE.OFF)
            g.alpha = 1
            ns.Apply(g) -- always restore, even if we think alpha is already 1
        end
    elseif g.active then
        if g.phase ~= PHASE.SHOWN then enterPhase(g, PHASE.SHOWN, 1) end
    elseif g.phase == PHASE.SHOWN or g.phase == PHASE.OFF then
        startWaiting(g)
    end
end

function ns.Refresh()
    local enabled = ns.IsEnabled()
    for _, g in ipairs(groups) do ns.RefreshGroup(g, enabled) end
end

-- A swing landed on a group we think is idle (backup for missed start events):
-- show it and keep it shown until a swing is missed.
function ns.OnSwing(g, swingDuration)
    if g.active or g.phase == PHASE.OFF then return end
    SetGroupAlpha(g, 1)
    startWaiting(g, (swingDuration or 0) + 0.2) -- small slack for latency
end

-- Apply a changed delay to countdowns already running.
function ns.OnDelayChanged()
    for _, g in ipairs(groups) do
        if g.phase == PHASE.WAITING then scheduleFade(g) end
    end
end
