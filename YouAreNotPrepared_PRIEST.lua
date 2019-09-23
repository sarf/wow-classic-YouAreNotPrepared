local YouAreNotPreparedPRIEST = {}
YouAreNotPrepared.modules.priest = YouAreNotPreparedPRIEST

function YouAreNotPreparedPRIEST.HasPrayerOfFortitudeRank1()
    return YouAreNotPrepared:HasAnySpellId(21562)
end

function YouAreNotPreparedPRIEST.HasPrayerOfFortitudeRank2()
    return YouAreNotPrepared:HasAnySpellId(21564)
end

function YouAreNotPreparedPRIEST:ReInit()
    if not YouAreNotPrepared:CreateReminderAbout("PRIEST.SacredCandle.amount.in.inventory", YouAreNotPreparedPRIEST.HasAnyGreaterBlessing, function() return 40 end, 17029, "You need more Sacred Candle") then
        YouAreNotPrepared:CreateReminderAbout("PRIEST.HolyCandle.amount.in.inventory", YouAreNotPreparedPRIEST.HasDivineIntervention, function() return 40 end, 17028, "You need more Holy Candle")
    end
end


YouAreNotPrepared:AddInitialization(function() 
    local _, class = UnitClass("player")
    if (class ~= "PRIEST" and not YouAreNotPrepared.config.testing) then return false end
    YouAreNotPreparedPRIEST:ReInit()
    return true
end)
