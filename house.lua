-- Main

local spellTracker = CreateFrame("Frame")

spellTracker:RegisterEvent("PLAYER_LOGIN")

-- Blacklist

local blacklist = Blacklist

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

    spellTracker:SetPoint(HouseDB.frame.position.point, UIParent, HouseDB.frame.position.x,
        HouseDB.frame.position.y)
    spellTracker:SetFrameStrata("MEDIUM")

    spellTracker:EnableMouse(true)

    if not HouseDB.settings.lockPosition then
        spellTracker:SetMovable(true)
    end

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

-- Global functions

function LockPosition(state)
    if state then
        spellTracker:EnableMouse(false)
    else
        spellTracker:EnableMouse()
    end
end

function HideBackground(state)
    if state then
        spellTracker:SetBackdropColor(0, 0, 0, 0)
    else
        spellTracker:SetBackdropColor(0, 0, 0, 0.9)
    end
end

-- Script Setups

spellTracker:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        configureSpellTracker()
        createSpellFrames()

        print("My addon loaded! Use /at to open Action Tracker settings")
    end

    if (spellTracker.player == arg1 and arg3 == "CAST") then
        local castedSpell = { SpellInfo(arg4) }
        local castedAt = GetTime()

        if not blacklist[castedSpell[1]] and (castedSpell[1] ~= spellTracker.spells[1].text or spellTracker.spells[1].time + 0.1 < castedAt) then
            for i = HouseDB.frame.spellCount, 1, -1 do
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
