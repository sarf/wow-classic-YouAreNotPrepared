local lib = {}
_G["LibBagIds"] = lib

if BagBrother and BagBrother.Player then
    lib.FindFirstItemById = function(self, itemId)
        local itemIdStr = tostring(itemId)
        for bag = 0, 4 do for k, v in pairs(self.Player[bag]) do local index, endIndex = string.find(v, itemIdStr) if index then local count = 1 if endIndex + 2 < v:len() then count = tonumber(string.sub(v, endIndex+2)) or 1 end return bag, k, count end end
    end
    lib.FindItemsById = function(self, itemId)
        local itemIdStr = tostring(itemId)
        local result = {}
        for bag = 0, 4 do for k, v in pairs(self.Player[bag]) do local index, endIndex = string.find(v, itemIdStr) if index then local count = 1 if endIndex + 2 < v:len() then count = tonumber(string.sub(v, endIndex+2)) or 1 end table.insert(result, {bag, k, count}) end end
        return result
    end
else
    lib.FindFirstItemById = function(self, itemId)
        local itemIdNum = tonumber(itemId)
        for bag = 0, 4 do for slot = 1, GetContainerNumSlots(bag) do local id = GetContainerItemInfo(bag, slot) if id == itemIdNum then return bag, slot, select(2, GetContainerItemInfo(bag,slot)) end end end
    end
    lib.FindItemsById = function(self, itemId)
        local itemIdNum = tonumber(itemId)
        local result = {}
        for bag = 0, 4 do for slot = 1, GetContainerNumSlots(bag) do local id = GetContainerItemInfo(bag, slot) if id == itemIdNum then table.insert(result, {bag, slot, select(2, GetContainerItemInfo(bag,slot))} end end end
        return result
    end
end
