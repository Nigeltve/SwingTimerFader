-- SwingTimerFader options panel (Settings > AddOns > SwingTimerFader).
local _, ns = ...

local panel, category, enabledBox
local sliders = {}

local function seconds(v)
    return ("%.1fs"):format(v)
end

local function makeSlider(parent, key, label, anchor, yOff)
    local minV, maxV = ns.LIMITS[key][1], ns.LIMITS[key][2]

    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff)
    title:SetText(label)

    local s = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    s:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 4, -12)
    s:SetWidth(240)
    s:SetHeight(16)
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(0.1)
    s:SetObeyStepOnDrag(true)
    if s.Text then s.Text:SetText("") end
    if s.Low then s.Low:SetText(("%gs"):format(minV)) end
    if s.High then s.High:SetText(("%gs"):format(maxV)) end

    s.valueText = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    s.valueText:SetPoint("LEFT", s, "RIGHT", 12, 0)

    s:SetScript("OnValueChanged", function(self, v)
        if self.syncing then return end
        ns.SetValue(key, math.floor(v * 10 + 0.5) / 10) -- SetValue calls SyncOptions
    end)
    sliders[key] = s
    return s
end

function ns.SyncOptions()
    if not panel then return end
    enabledBox:SetChecked(ns.IsEnabled())
    for key, s in pairs(sliders) do
        local v = ns.Get(key)
        s.syncing = true
        s:SetValue(v)
        s.syncing = false
        s.valueText:SetText(seconds(v))
    end
end

function ns.CreateOptions()
    if panel or not Settings or not Settings.RegisterCanvasLayoutCategory then return end

    panel = CreateFrame("Frame", "SwingTimerFaderOptionsPanel", UIParent)
    panel:Hide()

    local header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 16, -16)
    header:SetText("SwingTimerFader")

    local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
    sub:SetText("Fades each built-in swing timer bar while it is not in use.")

    enabledBox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    enabledBox:SetSize(28, 28)
    enabledBox:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", -4, -16)
    local cbLabel = enabledBox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cbLabel:SetPoint("LEFT", enabledBox, "RIGHT", 4, 0)
    cbLabel:SetText("Enabled (this character)")
    enabledBox:SetScript("OnClick", function(self) ns.SetEnabled(self:GetChecked()) end)

    local delay = makeSlider(panel, "delay", "Fade delay after auto-attack stops", enabledBox, -20)
    makeSlider(panel, "fadeTime", "Fade-out time", delay, -30)

    panel:SetScript("OnShow", ns.SyncOptions)

    category = Settings.RegisterCanvasLayoutCategory(panel, "SwingTimerFader")
    Settings.RegisterAddOnCategory(category)
end

function ns.OpenOptions()
    if category and Settings.OpenToCategory then
        Settings.OpenToCategory(category:GetID())
    else
        ns.Print("Options panel unavailable; use /stf delay <s> and /stf fade <s>.")
    end
end
