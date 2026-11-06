-- SwingTimerFader: /stf slash command.
local _, ns = ...

local logger = ns.logger

-- Commands that set a numeric setting.
local VALUE_COMMANDS = {
    delay = { key = "delay", label = "Fade delay" },
    fade = { key = "fadeTime", label = "Fade-out time" },
}

local function status()
    logger:Say(("enabled=%s delay=%.1f fade=%.1f"):format(
        tostring(ns.IsEnabled()), ns.Get("delay"), ns.Get("fadeTime")))
    for _, g in ipairs(ns.groups) do logger:Say(ns.Describe(g)) end
end

SLASH_SWINGTIMERFADER1 = "/stf"
SlashCmdList.SWINGTIMERFADER = function(msg)
    local cmd, arg = (msg or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
    local value = VALUE_COMMANDS[cmd]
    if cmd == "" then
        logger:Say("v" .. ns.VERSION .. "  (/stf help for commands)")
        ns.OpenOptions()
    elseif cmd == "config" then
        ns.OpenOptions()
    elseif cmd == "toggle" then
        local on = not ns.IsEnabled()
        ns.SetEnabled(on)
        logger:Say(on and "enabled for this character." or "disabled for this character.")
    elseif value then
        if ns.SetValue(value.key, arg) then
            logger:Say(("%s set to %.1fs."):format(value.label, ns.Get(value.key)))
        else
            local lim = ns.LIMITS[value.key]
            logger:Say(("Usage: /stf %s <seconds %g-%g>"):format(cmd, lim[1], lim[2]))
        end
    elseif cmd == "status" then
        status()
    else
        logger:Say("/stf [config | toggle | delay <s> | fade <s> | status]")
    end
end
