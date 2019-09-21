local YANP_Custom = {}
YouAreNotPrepared_Custom = YANP_Custom

--[[

    Custom Reminder
        one or more conditionals
            can be script, can be item not being present in sufficient quantity
        whether it applies in the field or while resting (or both!)
        what message should be shown


]]--

function YANP_Custom:SetupCustomizationFrame()
    local frame = CreateFrame("Frame")
    -- add possible conditionals
    -- ex: script
    --     item (drag'n'drop or itemID specification)
    --     ????
end


YouAreNotPrepared_TalentPoints = {}
YouAreNotPrepared.modules.talentPoints = YouAreNotPrepared_TalentPoints

YouAreNotPrepared:AddInitialization(function()
    YouAreNotPrepared:AddConfigurationOption("TALENTS.FieldReminderWhenHaveMoreOrEqualThan", "number", 0)
end)

function YouAreNotPrepared_TalentPoints:Reminder()
    if TalentFrame and TalentFrame:IsVisible() then
        return true, ""
    end
    local talentsNeededToRemind = YouAreNotPrepared:GetConfigurationOption("TALENTS.FieldReminderWhenHaveMoreOrEqualThan", 1)
    local tp = UnitCharacterPoints("player")
    if tp > talentsNeededToRemind or YouAreNotPrepared_TalentPoints.test then
        return false, string.format("need to spend talent points!")
    end
    return true, ""
end


YouAreNotPrepared:AddFieldReminder(function() return YouAreNotPrepared_TalentPoints:Reminder() end)


--[[
]]