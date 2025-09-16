-- Main

local settings = CreateFrame("Frame", nil, UIParent)

settings:RegisterEvent("PLAYER_LOGIN")
settings:RegisterEvent("UNIT_CASTEVENT")

local version = GetAddOnMetadata("SpellTracker", "Version")

local defaultSettings = {
    frame = {
        position = {
            point = "CENTER",
            x = 0,
            y = 0
        },
        padding = 5,
        spellSize = 15,
        spellCount = 6,
        scale = 2
    },
    settingsFrame = {
        position = {
            point = "CENTER",
            x = 0,
            y = 0
        }
    },
    settings = {
        hideBackground = false,
        lockPosition = false,
        debug = false
    },
    spellTrackerBlacklist = {
        ["Flurry"] = true,
        ["Deep Wound"] = true,
        ["Deep Wounds"] = true,
        ["Fatal Wound"] = true,
        ["Holy Strength"] = true,
        ["Charge Stun"] = true,
        ["Judgement of Wisdom"] = true,
        ["Intercept Stun"] = true,
        ["LOGINEFFECT"] = true
    },
    version = version
}

local spellTracker = CreateFrame("Frame", nil, UIParent)

-- Slash Commands

SLASH_SPELLTRACKER1 = "/spelltracker"

SlashCmdList["SPELLTRACKER"] = function()
    settings:Show()
    PlaySound("igMainMenuOpen", "SFX")
end

-- Blacklist

local blacklist = {}

-- Functions

local function createSpellFrames()
    for i = 1, SpellTrackerDB.frame.spellCount do
        spellTracker.spells[i] = CreateFrame("Frame", nil, spellTracker)

        spellTracker.spells[i]:SetWidth(SpellTrackerDB.frame.spellSize * SpellTrackerDB.frame.scale)
        spellTracker.spells[i]:SetHeight(SpellTrackerDB.frame.spellSize * SpellTrackerDB.frame.scale)

        if i == 1 then
            spellTracker.spells[i]:SetPoint("LEFT", spellTracker, "LEFT", SpellTrackerDB.frame.padding, 0)
        else
            spellTracker.spells[i]:SetPoint("LEFT", spellTracker.spells[i - 1], "RIGHT", SpellTrackerDB.frame.padding,
                0)
        end

        spellTracker.spells[i].text = ""
        spellTracker.spells[i].texture = spellTracker.spells[i]:CreateTexture(nil, "ARTWORK")
        spellTracker.spells[i].texture:SetAllPoints(spellTracker.spells[i])
        spellTracker.spells[i].texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        spellTracker.spells[i].time = 0
    end
end

local function configureSpellTracker()
    spellTracker.player = ({ UnitExists("player") })[2]

    spellTracker.spells = {}

    spellTracker:SetPoint(SpellTrackerDB.frame.position.point, UIParent, SpellTrackerDB.frame.position.x,
        SpellTrackerDB.frame.position.y)
    spellTracker:SetFrameStrata("MEDIUM")

    spellTracker:EnableMouse(true)

    if not SpellTrackerDB.settings.lockPosition then
        spellTracker:SetMovable(true)
    end

    if not SpellTrackerDB.settings.hideBackground then
        spellTracker:SetBackdrop({
            bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
            insets = {
                right = SpellTrackerDB.frame.padding * -1
            }
        })

        spellTracker:SetBackdropColor(0, 0, 0, 0.9)
    end

    spellTracker:RegisterEvent("UNIT_CASTEVENT")
    spellTracker:RegisterForDrag("LeftButton")

    spellTracker:SetWidth(SpellTrackerDB.frame.spellSize * SpellTrackerDB.frame.scale * SpellTrackerDB.frame.spellCount +
        (SpellTrackerDB.frame.spellCount * SpellTrackerDB.frame.padding))
    spellTracker:SetHeight(SpellTrackerDB.frame.spellSize * SpellTrackerDB.frame.scale + 8)
end

local function createSettingsItem(type, text, option, callback)
    local index = settings.itemsLength + 1

    settings.items[index] = {}

    local topOffset = settings.itemsLength * -18 + -5

    settings.items[index].text = settings:CreateFontString(nil, "OVERLAY")
    settings.items[index].text:SetPoint("TOPLEFT", settings.titleBar, "BOTTOMLEFT", 5, topOffset)
    settings.items[index].text:SetFont([[Interface\Addons\SpellTracker\fonts\Myriad-Pro.ttf]], 10)
    settings.items[index].text:SetTextColor(1, 1, 1, 1)
    settings.items[index].text:SetText(text)

    if type == "checkboxInput" then
        settings.items[index].checkbox = CreateFrame("CheckButton", nil, settings, "UICheckButtonTemplate")

        settings.items[index].checkbox:SetWidth(20)
        settings.items[index].checkbox:SetHeight(20)

        settings.items[index].checkbox:SetPoint("RIGHT", settings, "RIGHT", -3, 0)
        settings.items[index].checkbox:SetPoint("TOP", settings.items[index].text, "CENTER", 0,
            settings.items[index].checkbox:GetHeight() / 2)

        settings.items[index].checkbox:SetChecked(SpellTrackerDB.settings[option])

        settings.items[index].checkbox:SetScript("OnClick", callback)
    elseif type == "sliderInput" then
        settings.items[index].slider = CreateFrame("Slider", nil, settings)

        settings.items[index].slider:SetPoint("TOPLEFT", settings.items[index].text, "BOTTOMLEFT", 0, -5)
        settings.items[index].slider:SetWidth(settings:GetWidth() - 10)
        settings.items[index].slider:SetHeight(10)
        settings.items[index].slider:SetOrientation("HORIZONTAL")

        settings.items[index].slider:SetMinMaxValues(1, 3)
        settings.items[index].slider:SetValue(SpellTrackerDB.frame.scale)
        settings.items[index].slider:SetValueStep(0.2)

        settings.items[index].slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Horizontal]])

        settings.items[index].slider:SetBackdrop({
            edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
            edgeSize = 8,
            insets = { top = 8, bottom = 8, left = 8, right = 8 },
            tile = true
        })

        settings.items[index].slider:SetScript("OnValueChanged", callback)
    end

    settings.itemsLength = index
end

local function playSoundConditional(state, sound1, sound2)
    if state then
        PlaySound(sound1, "SFX")
    else
        PlaySound(sound2, "SFX")
    end
end

local function merge(default, current)
    for k, v in pairs(default) do
        if not current[k] then
            current[k] = v
        elseif type(v) == "table" and type(current[k]) == "table" then
            merge(v, current[k])
        end
    end
end

local function cleanup(current, default)
    for k, v in pairs(current) do
        if not default[k] then
            current[k] = nil
        elseif type(v) == "table" and type(default[k]) == "table" then
            cleanup(v, default[k])
        end
    end
end

-- Script Setups

settings:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        -- Global setup

        SpellTrackerDB = SpellTrackerDB or defaultSettings

        if version ~= SpellTrackerDB.version then
            merge(defaultSettings, SpellTrackerDB)
            cleanup(SpellTrackerDB, defaultSettings)

            SpellTrackerDB.version = version
        end

        blacklist = SpellTrackerDB.spellTrackerBlacklist

        -- Frame configuration

        settings.items = {}

        settings.itemsLength = 0

        settings:SetWidth(200)

        settings:SetHeight(200)

        settings:SetPoint(SpellTrackerDB.settingsFrame.position.point, UIParent,
            SpellTrackerDB.settingsFrame.position.x, SpellTrackerDB.settingsFrame.position.y)

        settings:SetFrameStrata("DIALOG")

        settings:EnableMouse(true)

        settings:SetMovable(true)

        settings:SetBackdrop({
            bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]
        })

        settings:SetBackdropColor(0, 0, 0, 1)

        settings:Hide()

        -- Title Bar

        settings.titleBar = CreateFrame("Frame", nil, settings)

        settings.titleBar:SetPoint("TOP", settings, "TOP", 0, 0)

        settings.titleBar:SetWidth(settings:GetWidth())

        settings.titleBar:SetHeight(20)

        settings.titleBar:SetBackdrop({
            bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]
        })

        settings.titleBar:SetBackdropColor(0, 0, 0, 1)

        settings.titleBar:EnableMouse(true)

        settings.titleBar:RegisterForDrag("LeftButton")

        settings.titleBar:SetScript("OnDragStart", function()
            settings:StartMoving()
        end)

        settings.titleBar:SetScript("OnDragStop", function()
            settings:StopMovingOrSizing()

            local position = { settings:GetPoint() }

            SpellTrackerDB.settingsFrame.position.point = position[1]
            SpellTrackerDB.settingsFrame.position.x = position[4]
            SpellTrackerDB.settingsFrame.position.y = position[5]
        end)

        -- Title Bar Title

        settings.titleBar.text = settings.titleBar:CreateFontString(nil, "OVERLAY")

        settings.titleBar.text:SetPoint("CENTER", settings.titleBar, "CENTER", 0, 0)

        settings.titleBar.text:SetFont([[Interface\Addons\SpellTracker\fonts\Myriad-Pro.ttf]], 12)

        settings.titleBar.text:SetTextColor(1, 1, 1, 1)

        settings.titleBar.text:SetText("Action Tracker settings")

        -- Title Bar Close

        settings.titleBar.close = CreateFrame("Button", nil, settings.titleBar, "UIPanelButtonTemplate")

        settings.titleBar.close:SetWidth(15)

        settings.titleBar.close:SetHeight(15)

        settings.titleBar.close:SetPoint("RIGHT", settings.titleBar, "RIGHT", -5, 0)

        settings.titleBar.close:SetText("x")

        settings.titleBar.close:GetFontString():SetJustifyH("RIGHT")

        settings.titleBar.close:SetScript("OnClick", function()
            settings:Hide()
            PlaySound("igMainMenuClose", "SFX")
        end)

        -- Settings

        createSettingsItem("checkboxInput", "Lock tracker position", "lockPosition",
            function()
                local state = this:GetChecked()

                SpellTrackerDB.settings["lockPosition"] = state

                if state then
                    spellTracker:EnableMouse(false)
                else
                    spellTracker:EnableMouse()
                end

                playSoundConditional(state, "igMainMenuOptionCheckBoxOn", "igMainMenuOptionCheckBoxOff")
            end)

        createSettingsItem("checkboxInput", "Hide background", "hideBackground",
            function()
                local state = this:GetChecked()

                SpellTrackerDB.settings["hideBackground"] = state

                if state then
                    spellTracker:SetBackdropColor(0, 0, 0, 0)
                else
                    spellTracker:SetBackdropColor(0, 0, 0, 0.9)
                end

                playSoundConditional(state, "igMainMenuOptionCheckBoxOn", "igMainMenuOptionCheckBoxOff")
            end)

        createSettingsItem("checkboxInput", "Debug mode", "debug",
            function()
                local state = this:GetChecked()

                SpellTrackerDB.settings["debug"] = state

                -- enable debug mode live

                playSoundConditional(state, "igMainMenuOptionCheckBoxOn", "igMainMenuOptionCheckBoxOff")
            end)

        createSettingsItem("sliderInput", "Tracker scale", "scale",
            function()
                local state = this:GetValue()

                SpellTrackerDB.frame["scale"] = state

                for i = 1, SpellTrackerDB.frame.spellCount do
                    spellTracker.spells[i]:SetWidth(SpellTrackerDB.frame.spellSize * state)
                    spellTracker.spells[i]:SetHeight(SpellTrackerDB.frame.spellSize * state)
                end

                spellTracker:SetWidth(SpellTrackerDB.frame.spellSize * state * SpellTrackerDB.frame.spellCount +
                    (SpellTrackerDB.frame.spellCount * SpellTrackerDB.frame.padding))

                spellTracker:SetHeight(SpellTrackerDB.frame.spellSize * state + 8)
            end)

        -- Version

        settings.version = settings:CreateFontString(nil, "OVERLAY")

        settings.version:SetPoint("BOTTOMRIGHT", settings, "BOTTOMRIGHT", -3, 3)

        settings.version:SetFont([[Interface\Addons\SpellTracker\fonts\Myriad-Pro.ttf]], 10)

        settings.version:SetTextColor(1, 1, 1, 1)

        settings.version:SetText("Version: " .. GetAddOnMetadata("SpellTracker", "Version"))

        configureSpellTracker()

        createSpellFrames()

        print("SpellTracker loaded! Use /spelltracker to open Action Tracker settings")
    end

    if event == "UNIT_CASTEVENT" then
        if (spellTracker.player == arg1 and arg3 == "CAST") then
            local castedSpell = { SpellInfo(arg4) }
            local castedAt = GetTime()

            if not blacklist[castedSpell[1]] and (castedSpell[1] ~= spellTracker.spells[1].text or castedAt > spellTracker.spells[1].time + 0.1) then
                for i = SpellTrackerDB.frame.spellCount, 1, -1 do
                    if i > 1 then
                        local oldSpell = spellTracker.spells[i - 1]

                        spellTracker.spells[i].text = oldSpell.text
                        spellTracker.spells[i].texture:SetTexture(oldSpell.texture:GetTexture())
                        spellTracker.spells[i].time = oldSpell.time
                    else
                        spellTracker.spells[i].text = castedSpell[1]
                        spellTracker.spells[i].texture:SetTexture(castedSpell[3])
                        spellTracker.spells[i].time = castedAt
                    end
                end

                if SpellTrackerDB.settings.debug then
                    print("|cffFF0000SPELLTRACKER DEBUG: |r" .. castedSpell[1])
                end
            end
        end
    end
end)

spellTracker:SetScript("OnDragStart", function()
    spellTracker:StartMoving()
end)

spellTracker:SetScript("OnDragStop", function()
    spellTracker:StopMovingOrSizing()

    local position = { spellTracker:GetPoint() }

    SpellTrackerDB.frame.position.point = position[1]
    SpellTrackerDB.frame.position.x = position[4]
    SpellTrackerDB.frame.position.y = position[5]
end)
