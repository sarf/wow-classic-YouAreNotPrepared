local YouAreNotPrepared_Ammo = {}
local YANP = YouAreNotPrepared
YouAreNotPrepared_Ammo.slot = { ammo = GetInventorySlotInfo("AmmoSlot"), ranged = GetInventorySlotInfo("RangedSlot") }


YouAreNotPrepared.modules.ammo = YouAreNotPrepared_Ammo


function YouAreNotPrepared_Ammo:UsesAmmo(itemId)
    -- NEEDS LOCALIZATION
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemId)
    --YouAreNotPrepared:Print("Item info. '" .. itemType .. "' / '" .. itemSubType .. "'")
    if (itemType == "Weapon") then
        return itemSubType == "Guns" or itemSubType == "Bows" or itemSubType == "Crossbows"
    end
    return false
end
function YouAreNotPrepared_Ammo:UsesItself(itemId)
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemId)
    if (itemType == "Weapon") then
        return itemSubType == "Thrown"
    end
    return false
end

function YouAreNotPrepared_Ammo:GetAmmoLeft()
    local self = YouAreNotPrepared_Ammo
    local id = GetInventoryItemID("player", self.slot.ranged)
    if type(id) ~= "number" or id == 0 then
        return -1
    end
    if self:UsesAmmo(id) then
        local ammoId = GetInventoryItemID("player", self.slot.ammo)
        if not ammoId or ammoId == 0 then return 0 end
        return GetInventoryItemCount("player", self.slot.ammo)
    elseif self:UsesItself(id) then
        return GetInventoryItemCount("player", self.slot.ranged)
    end
    return -1
end
function YouAreNotPrepared_Ammo:Reminder()
    local ammoLeft = YouAreNotPrepared_Ammo:GetAmmoLeft()
    if ammoLeft == -1 then
        return true, "can not determine amount of ammo"
    end
    local reminderAmount = YouAreNotPrepared:GetConfigurationOption("AMMO.ReminderWhenBelow", 200)
    if ammoLeft < reminderAmount then
        return false, string.format("need to get more ammo\n(have: %d, want: %d, get: %d)", ammoLeft, reminderAmount, reminderAmount - ammoLeft)
    end
    return true, ""
end

YouAreNotPrepared:AddInitialization(function()
    YouAreNotPrepared:AddConfigurationOption("AMMO.ReminderWhenBelow", "number", 200)
end)



YouAreNotPrepared:AddReminder(function() return YouAreNotPrepared_Ammo:Reminder() end)

-- /run local _,msg = YouAreNotPrepared.modules.ammo:Reminder() YouAreNotPrepared:Print(msg)