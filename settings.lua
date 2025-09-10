-- Main

local settings = CreateFrame("Frame")

settings:RegisterEvent("PLAYER_LOGIN")

-- Slash Commands

SLASH_AT1 = "/at"

SlashCmdList["AT"] = function()
    settings:Show()
end

-- Functions

local function createSettingsItem(text, option, optionValue)
    -- Creating a setting table
    settings.items[option] = {}

    -- Text
    settings.items[option].text = settings:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
    settings.items[option].text:SetPoint("TOPLEFT", settings, "TOPLEFT", 5, -32)
    settings.items[option].text:SetText(text)

    -- Checkbox
    settings.items[option].checkbox = CreateFrame("CheckButton", nil, settings, "UICheckButtonTemplate")
    settings.items[option].checkbox:SetPoint("TOPRIGHT", settings, "TOPRIGHT", -5, -32)
    settings.items[option].checkbox:SetWidth(20)
    settings.items[option].checkbox:SetHeight(20)
    settings.items[option].checkbox:SetChecked(optionValue)

    -- Script Setups
    settings.items[option].checkbox:SetScript("OnClick", function()
        HouseDB.settings[option] = this:GetChecked()
    end)
end

-- Script Setups

settings:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        -- Frame configuration

        settings.items = {}

        settings:SetWidth(180)

        settings:SetHeight(200)

        settings:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

        settings:SetFrameStrata("DIALOG")

        settings:EnableMouse(true)

        settings:SetMovable(true)

        settings:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background"
        })

        settings:SetBackdropColor(0, 0, 0, 1)

        -- Title Bar

        settings.titleBar = CreateFrame("Frame", nil, settings)

        settings.titleBar:SetPoint("TOP", settings, "TOP", 0, 0)

        settings.titleBar:SetWidth(settings:GetWidth())

        settings.titleBar:SetHeight(25)

        settings.titleBar:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background"
        })

        settings.titleBar:SetBackdropColor(0, 0, 1, 1)

        settings.titleBar:EnableMouse(true)

        settings.titleBar:RegisterForDrag("LeftButton")

        settings.titleBar:SetScript("OnDragStart", function()
            settings:StartMoving()
        end)

        settings.titleBar:SetScript("OnDragStop", function()
            settings:StopMovingOrSizing()
        end)

        -- Title Bar Title

        settings.titleBar.text = settings.titleBar:CreateFontString(nil, "OVERLAY")

        settings.titleBar.text:SetPoint("CENTER", settings.titleBar, "CENTER", 0, 0)

        settings.titleBar.text:SetFont("fonts/arialn.ttf", 12)

        settings.titleBar.text:SetTextColor(1, 0, 1, 1)

        settings.titleBar.text:SetText("Action Tracker Settings")

        -- Title Bar Close

        settings.titleBar.close = CreateFrame("Button", nil, settings.titleBar, "UIPanelButtonTemplate")

        settings.titleBar.close:SetWidth(20)

        settings.titleBar.close:SetHeight(20)

        settings.titleBar.close:SetPoint("RIGHT", settings.titleBar, "RIGHT", -5, 0)

        settings.titleBar.close:SetText("x")

        settings.titleBar.close:SetScript("OnClick", function()
            settings:Hide()
            PlaySound("tellmessage", "SFX")
            print("Settings saved! Type /reload to apply changes.")
        end)

        -- Settings

        settings.option1 = createSettingsItem("Hide Background Color", "hideBackground", HouseDB.settings.hideBackground)
    end
end)
