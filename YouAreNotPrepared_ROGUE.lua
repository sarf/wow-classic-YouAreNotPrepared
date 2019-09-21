local YouAreNotPreparedROGUE = {}
YouAreNotPreparedROGUE.Poisons = {}
YouAreNotPreparedROGUE.Poisons.InstantItemIds = {6947,6949,6950,8926,8927,8928}
YouAreNotPreparedROGUE.Poisons.CripplingItemIds = {3775,3776}
YouAreNotPreparedROGUE.Poisons.SpellCasterItemIds = {5237,6951,9186}
YouAreNotPreparedROGUE.Poisons.DoTItemIds = {2892,2893,8984,8985,20844}
YouAreNotPreparedROGUE.Poisons.HealItemIds = {10918,10920,10921,10922}

for k, v in pairs(YouAreNotPreparedROGUE.Poisons) do
    local mapped = {}
    for l, w in pairs(v) do
        mapped[w] = true
    end
    YouAreNotPreparedROGUE.Poisons[k.."Mapped"] = mapped
end

YouAreNotPrepared.modules.rogue = YouAreNotPreparedROGUE

function YouAreNotPreparedROGUE:CanPoison()
    return YouAreNotPrepared:HasAnySpellId(2842)
end

function YouAreNotPreparedROGUE:HasPoisonsOnWeapons()
    if YouAreNotPrepared:GetConfigurationOption("ROGUE.Ignore.PoisonsWeapon", false) then
        return true
    end
    hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo()
    local mainHandNeedsPoison = GetInventoryItemID("player",16) ~= nil and not GetInventoryItemBroken("player",16)
    local offHandNeedsPoison = GetInventoryItemID("player",17) ~= nil and not GetInventoryItemBroken("player",17)
    return (hasMainHandEnchant or not mainHandNeedsPoison) and (hasOffHandEnchant or not offHandNeedsPoison)
end

function YouAreNotPreparedROGUE:GetAmountOfPoisonInBags(name)
    local poisonMatch 
    if type(self.Poisons[name.."Mapped"]) == "table" then poisonMatch = function(id) return self.Poisons[name.."Mapped"][id] end
    else
        poisonMatch = function(id) for k, v in pairs(self.Poisons[name]) do if v == id then return true end end return false end
    end
   
    local amount = 0
    for bag = 0, NUM_BAG_FRAMES, 1 do
        for slot = 1, GetContainerNumSlots(bag) do
            local id = GetContainerItemID(bag, slot)
            if poisonMatch(id) then
                local _, itemCount = GetContainerItemInfo(bag, slot);
                amount = amount + itemCount
            end
        end
    end

    local map = YouAreNotPrepared:GetItemsInBags(poisonMatch)
    if type(map) ~= "table" then return 0 end
    local amount = 0
    for k, v in pairs(map) do
        amount = amount + v.amount 
    end
    return amount
end

function YouAreNotPreparedROGUE:HasPoisonsInInventory()
    if YouAreNotPrepared:GetConfigurationOption("ROGUE.Ignore.PoisonsInventory", false) then
        return true
    end
    local state = true
    local stateMessage = ""

    local isInRaid = false
    
    local factor = 1
    if isInRaid then factor = 2 end

    local instantAmount = YouAreNotPrepared:GetConfigurationOption("ROGUE.InstantPoison.amount.in.inventory", 80  * factor)
    if self:GetAmountOfPoisonInBags("InstantItemIds") < instantAmount then
        state = false
        stateMessage = stateMessage .. "\nNeed more Instant Poisons"
    end

    local cripplingAmount = YouAreNotPrepared:GetConfigurationOption("ROGUE.InstantPoison.CripplingPoison.in.inventory", 20)
    if self:GetAmountOfPoisonInBags("CripplingItemIds") < cripplingAmount then
        state = false
        stateMessage = stateMessage .. "\nNeed more Crippling Poisons"
    end

    local spellCasterAmount = YouAreNotPrepared:GetConfigurationOption("ROGUE.InstantPoison.SpellCasterPoison.in.inventory", 20)
    if self:GetAmountOfPoisonInBags("SpellCasterItemIds") < spellCasterAmount then
        state = false
        stateMessage = stateMessage .. "\nNeed more SpellCaster Poisons"
    end
    local dotAmount = YouAreNotPrepared:GetConfigurationOption("ROGUE.InstantPoison.DoTPoison.in.inventory", 0)
    if self:GetAmountOfPoisonInBags("DoTItemIds") < dotAmount then
        state = false
        stateMessage = stateMessage .. "\nNeed more SpellCaster Poisons"
    end
    local healAmount = YouAreNotPrepared:GetConfigurationOption("ROGUE.InstantPoison.HealPoison.in.inventory", 0)
    if self:GetAmountOfPoisonInBags("HealItemIds") < healAmount then
        state = false
        stateMessage = stateMessage .. "\nNeed more SpellCaster Poisons"
    end

    return state, stateMessage
end

function YouAreNotPreparedROGUE:HasItemsInInventory()
    -- check for ???
    return true
end

function YouAreNotPreparedROGUE:CanLockPick()
    return YouAreNotPrepared:HasAnySpellId(1804)
end

function YouAreNotPreparedROGUE:HasLockPickItem()
    if YouAreNotPrepared:GetConfigurationOption("ROGUE.Ignore.LockPick", false) then
        return true
    end
    local hasLockpick = self:GetAmountOfPoisonInBags(5060) > 0
    local message = "Need lock pick"
    return hasLockpick, message
end

function YouAreNotPreparedROGUE:CanVanish()
    return YouAreNotPrepared:HasAnySpellId({1856, 27617})
end

function YouAreNotPreparedROGUE:HasVanishItem()
    if YouAreNotPrepared:GetConfigurationOption("ROGUE.Ignore.Vanish", false) then
        return true
    end
    return self:HasItemMessage(self:GetAmountOfPoisonInBags(5140), YouAreNotPrepared:GetConfigurationOption("ROGUE.Vanish.amount.in.inventory", 20), "Need %3d more Flash Powder for Vanish")
end

function YouAreNotPreparedROGUE:CanBlind()
    return YouAreNotPrepared:HasAnySpellId({1856, 27617})
end

function YouAreNotPreparedROGUE:HasBlindItem()
    if YouAreNotPrepared:GetConfigurationOption("ROGUE.Ignore.Blind", false) then
        return true
    end
    return self:HasItemMessage(self:GetAmountOfPoisonInBags(5530), YouAreNotPrepared:GetConfigurationOption("ROGUE.Blind.amount.in.inventory", 20), "Need %3d more Blinding Powder for Blind")
end

function YouAreNotPreparedROGUE:HasItemMessage(have, wanted, message)
    if wanted <= have then return true end
    
    return false, message:format(have, wanted, wanted - have)
end



YouAreNotPrepared:AddInitialization(function() 
    YouAreNotPrepared:AddConfigurationOption("ROGUE.InstantPoison.amount.in.inventory", "number", 50)
    YouAreNotPrepared:AddConfigurationOption("ROGUE.CripplingPoison.amount.in.inventory", "number", 50)
    YouAreNotPrepared:AddConfigurationOption("ROGUE.SpellCasterPoison.amount.in.inventory", "number", 0)
    YouAreNotPrepared:AddConfigurationOption("ROGUE.Vanish.amount.in.inventory", "number", 20)
    YouAreNotPrepared:AddConfigurationOption("ROGUE.Blind.amount.in.inventory", "number", 20)
    YouAreNotPrepared:AddConfigurationOption("ROGUE.Ignore.PoisonsInventory", "boolean", false)
    YouAreNotPrepared:AddConfigurationOption("ROGUE.Ignore.PoisonsWeapon", "boolean", false)
    YouAreNotPrepared:AddConfigurationOption("ROGUE.Ignore.LockPick", "boolean", false)
    YouAreNotPrepared:AddConfigurationOption("ROGUE.Ignore.Vanish", "boolean", false)
    YouAreNotPrepared:AddConfigurationOption("ROGUE.Ignore.Blind", "boolean", false)
    local _, class = UnitClass("player")
    if (class ~= "ROGUE" and not YouAreNotPrepared.config.testing) then return false end
    if (YouAreNotPreparedROGUE:CanPoison()) then
        YouAreNotPrepared:AddReminder(function() return YouAreNotPreparedROGUE:HasPoisonsInInventory() end)
        YouAreNotPrepared:AddFieldReminder(function() return YouAreNotPreparedROGUE:HasPoisonsOnWeapons() end)
    end
    YouAreNotPrepared:AddReminder(function() return YouAreNotPreparedROGUE:HasItemsInInventory() end)
    if (YouAreNotPreparedROGUE:CanLockPick()) then YouAreNotPrepared:AddReminder(function() return YouAreNotPreparedROGUE:HasLockPickItem() end) end
    if (YouAreNotPreparedROGUE:CanVanish()) then YouAreNotPrepared:AddReminder(function() return YouAreNotPreparedROGUE:HasVanishItem() end) end
    if (YouAreNotPreparedROGUE:CanBlind()) then YouAreNotPrepared:AddReminder(function() return YouAreNotPreparedROGUE:HasBlindItem() end) end
    return true
end)