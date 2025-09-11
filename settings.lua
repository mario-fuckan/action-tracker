-- Main

local settings = CreateFrame("Frame")

settings:RegisterEvent("PLAYER_LOGIN")

-- Slash Commands

SLASH_AT1 = "/at"

SlashCmdList["AT"] = function()
    settings:Show()
end

-- Functions

local function createSettingsItem(text, option, callback)
    -- Index
    local index = settings.itemsLength + 1

    -- Creating a setting table
    settings.items[index] = {}

    -- Offset

    local topOffset = settings.itemsLength * -20 + -5

    -- Text
    settings.items[index].text = settings:CreateFontString(nil, "OVERLAY")
    settings.items[index].text:SetPoint("TOPLEFT", settings.titleBar, "BOTTOMLEFT", 5, topOffset)
    settings.items[index].text:SetFont([[Interface\Addons\house\fonts\Myriad-Pro.ttf]], 12)
    settings.items[index].text:SetTextColor(1, 1, 1, 1)
    settings.items[index].text:SetText(text)

    -- Checkbox
    settings.items[index].checkbox = CreateFrame("CheckButton", nil, settings, "UICheckButtonTemplate")

    settings.items[index].checkbox:SetWidth(20)
    settings.items[index].checkbox:SetHeight(20)

    settings.items[index].checkbox:SetPoint("RIGHT", settings, "RIGHT", -5, 0)
    settings.items[index].checkbox:SetPoint("TOP", settings.items[index].text, "CENTER", 0,
        settings.items[index].checkbox:GetHeight() / 2)

    settings.items[index].checkbox:SetChecked(HouseDB.settings[option])

    -- Script Setups
    settings.items[index].checkbox:SetScript("OnClick", callback)

    -- Increment items length
    settings.itemsLength = index
end

-- Script Setups

settings:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        -- Frame configuration

        settings.items = {}

        settings.itemsLength = 0

        settings:SetWidth(200)

        settings:SetHeight(200)

        settings:SetPoint(HouseDB.settingsFrame.position.point, UIParent,
            HouseDB.settingsFrame.position.x, HouseDB.settingsFrame.position.y)

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

        settings.titleBar:SetHeight(20)

        settings.titleBar:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background"
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

            HouseDB.settingsFrame.position.point = position[1]
            HouseDB.settingsFrame.position.x = position[4]
            HouseDB.settingsFrame.position.y = position[5]
        end)

        -- Title Bar Title

        settings.titleBar.text = settings.titleBar:CreateFontString(nil, "OVERLAY")

        settings.titleBar.text:SetPoint("CENTER", settings.titleBar, "CENTER", 0, 0)

        settings.titleBar.text:SetFont([[Interface\Addons\house\fonts\Myriad-Pro.ttf]], 12)

        settings.titleBar.text:SetTextColor(1, 1, 1, 1)

        settings.titleBar.text:SetText("Action Tracker Settings")

        -- Title Bar Close

        settings.titleBar.close = CreateFrame("Button", nil, settings.titleBar, "UIPanelButtonTemplate")

        settings.titleBar.close:SetWidth(15)

        settings.titleBar.close:SetHeight(15)

        settings.titleBar.close:SetPoint("RIGHT", settings.titleBar, "RIGHT", -5, 0)

        settings.titleBar.close:SetText("x")

        settings.titleBar.close:GetFontString():SetJustifyH("RIGHT")

        settings.titleBar.close:SetScript("OnClick", function()
            settings:Hide()
        end)

        -- Settings

        createSettingsItem("Lock Tracker Position", "lockPosition",
            function()
                local state = this:GetChecked()

                HouseDB.settings["lockPosition"] = state

                LockPosition(state)
            end)

        createSettingsItem("Hide Background Color", "hideBackground",
            function()
                local state = this:GetChecked()

                HouseDB.settings["hideBackground"] = state

                HideBackground(state)
            end)
    end
end)
