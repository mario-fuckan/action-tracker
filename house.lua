-- Main

local spellTracker = CreateFrame("Frame")

spellTracker:RegisterEvent("PLAYER_LOGIN")

-- Functions

local function createSpellFrames()
    for i = 1, HouseDB.frame.spellCount do
        spellTracker.spells[i] = CreateFrame("Frame")

        spellTracker.spells[i]:SetWidth(HouseDB.frame.spellSize)
        spellTracker.spells[i]:SetHeight(HouseDB.frame.spellSize)

        if i == 1 then
            spellTracker.spells[i]:SetPoint("LEFT", spellTracker, "LEFT", HouseDB.frame.padding, 0)
        else
            spellTracker.spells[i]:SetPoint("LEFT", spellTracker.spells[i - 1], "RIGHT", HouseDB.frame.padding,
                0)
        end

        spellTracker.spells[i].texture = spellTracker.spells[i]:CreateTexture(nil, "ARTWORK")
        spellTracker.spells[i].texture:SetAllPoints(spellTracker.spells[i])
        spellTracker.spells[i].texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
end

local function configureSpellTracker()
    spellTracker.blacklist = {
        ["Flurry"] = true,
        ["Deep Wound"] = true,
        ["Deep Wounds"] = true,
        ["Fatal Wound"] = true,
        ["Holy Strength"] = true,
        ["Charge Stun"] = true,
        ["Judgement of Wisdom"] = true,
        ["Intercept Stun"] = true,
        ["LOGINEFFECT"] = true,
    }

    spellTracker.player = ({ UnitExists("player") })[2]

    spellTracker.spells = {}

    spellTracker:SetPoint(HouseDB.frame.position.point, HouseDB.frame.position.relativeTo, HouseDB.frame.position.x,
        HouseDB.frame.position.y)
    spellTracker:SetFrameStrata("MEDIUM")

    spellTracker:SetMovable(true)
    spellTracker:EnableMouse(true)

    if not HouseDB.settings.hideBackground then
        spellTracker:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            insets = {
                right = HouseDB.frame.padding * -1
            }
        })

        spellTracker:SetBackdropColor(0, 0, 0, 0.9)
    end

    spellTracker:RegisterEvent("UNIT_CASTEVENT")
    spellTracker:RegisterForDrag("LeftButton")

    spellTracker:SetWidth(HouseDB.frame.spellSize * HouseDB.frame.spellCount +
        (HouseDB.frame.spellCount * HouseDB.frame.padding))
    spellTracker:SetHeight(HouseDB.frame.spellSize + 8)
end

-- Script Setups

spellTracker:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        configureSpellTracker()
        createSpellFrames()
    end

    if (spellTracker.player == arg1 and arg3 == "CAST") then
        local castedSpell = { SpellInfo(arg4) }

        if not spellTracker.blacklist[castedSpell[1]] then
            for i = HouseDB.frame.spellCount, 2, -1 do
                local oldSpell = spellTracker.spells[i - 1].texture:GetTexture()

                spellTracker.spells[i].texture:SetTexture(oldSpell)
            end

            spellTracker.spells[1].texture:SetTexture(castedSpell[3])
        end
    end
end)

spellTracker:SetScript("OnDragStart", function()
    spellTracker:StartMoving()
end)

spellTracker:SetScript("OnDragStop", function()
    spellTracker:StopMovingOrSizing()

    local position = { spellTracker:GetPoint() }

    HouseDB.frame.position.point = position[1]
    HouseDB.frame.position.x = position[4]
    HouseDB.frame.position.y = position[5]
end)
