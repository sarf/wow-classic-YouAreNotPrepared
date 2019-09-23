local YouAreNotPreparedPALADIN = {}
YouAreNotPrepared.modules.paladin = YouAreNotPreparedPALADIN

function YouAreNotPreparedPALADIN.HasAnyGreaterBlessing()
    return YouAreNotPrepared:HasAnySpellId({25918,25898,25782,25899,25916,25895,25890,25894})
end

function YouAreNotPreparedPALADIN.HasDivineIntervention()
    return YouAreNotPrepared:HasAnySpellId(19752)
end

function YouAreNotPreparedPALADIN:HasItemMessage(have, wanted, message)
    if wanted <= have then return true end
    
    return false, message:format(have, wanted, wanted - have)
end

function YouAreNotPreparedPALADIN:ReInit()
    YouAreNotPrepared:CreateReminderAbout("PALADIN.SymbolofKings.amount.in.inventory", YouAreNotPreparedPALADIN.HasAnyGreaterBlessing, function() return 200 end, 21177, "You need more Symbol of Kings")
    YouAreNotPrepared:CreateReminderAbout("PALADIN.SymbolofDivinity.amount.in.inventory", YouAreNotPreparedPALADIN.HasDivineIntervention, function() return 2 end, 17033, "You need more Symbol of Divinity")
end


YouAreNotPrepared:AddInitialization(function() 
    local _, class = UnitClass("player")
    if (class ~= "PALADIN" and not YouAreNotPrepared.config.testing) then return false end
    YouAreNotPreparedPALADIN:ReInit()
    return true
end)
