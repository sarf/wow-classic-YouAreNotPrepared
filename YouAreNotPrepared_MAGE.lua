local YouAreNotPreparedMAGE = {}
YouAreNotPreparedMAGE.Poisons = {}
YouAreNotPrepared.modules.mage = YouAreNotPreparedMAGE

function YouAreNotPreparedMAGE.CanPortal()
    return YouAreNotPrepared:HasAnySpellId({11420,11417,11418,11416,11419,10059})
end

function YouAreNotPreparedMAGE.CanTeleport()
    return YouAreNotPrepared:HasAnySpellId({3565,3561,3567,3563,3562,3566})
end

function YouAreNotPreparedMAGE.HasArcaneBrilliance()
    return YouAreNotPrepared:HasAnySpellId({23208})
end

function YouAreNotPreparedMAGE:HasItemMessage(have, wanted, message)
    if wanted <= have then return true end
    
    return false, message:format(have, wanted, wanted - have)
end

function YouAreNotPreparedMAGE:ReInit()
    YouAreNotPrepared:CreateReminderAbout("MAGE.ArcanePowder.amount.in.inventory", YouAreNotPreparedMAGE.HasArcaneBrilliance, function() return 20 + ((IsInRaid() and 20) or 0) end, 17020, "You need more arcane powder")
    YouAreNotPrepared:CreateReminderAbout("MAGE.RuneofTeleportation.amount.in.inventory", YouAreNotPreparedMAGE.CanTeleport, function() return 10 end, 17031, "You need more Rune of Teleportation")
    YouAreNotPrepared:CreateReminderAbout("MAGE.RuneofPortals.amount.in.inventory", YouAreNotPreparedMAGE.CanPortal, function() return 10 end, 17032, "You need more Rune of Portals")
end


YouAreNotPrepared:AddInitialization(function() 
    local _, class = UnitClass("player")
    if (class ~= "MAGE" and not YouAreNotPrepared.config.testing) then return false end
    YouAreNotPreparedMAGE:ReInit()
    return true
end)
