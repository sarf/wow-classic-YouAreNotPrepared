YouAreNotPrepared = {}
YouAreNotPrepared.setup = { name = "YouAreNotPrepared", shortName = "YANP" }
YouAreNotPrepared.version = { major = 1, minor = 0, build = 1, codename = "(Ambitious Aardvark) "}
YouAreNotPrepared.initializations = {}
YouAreNotPrepared.data = {}
YouAreNotPrepared.config = { testing = false }
YouAreNotPrepared.slashcommands = {}
YouAreNotPrepared.reminders = {}
YouAreNotPrepared.reminderConfigurations = {}
YouAreNotPrepared.fieldReminders = {} -- fieldReminders is used "in the field" and should both be few and quick to run
YouAreNotPrepared.cache = {}
YouAreNotPrepared.cacheInvalidators = {}
YouAreNotPrepared.modules = {}
SarfCommonLib.create(YouAreNotPrepared)

--YouAreNotPrepared:RegisterBlizzardEvent("PLAYER_ENTERING_COMBAT", function() 

-- TODO: create reminder surface

-- /dump YouAreNotPrepared:GetItemsInBags(function(id) return id == 2589 end)
function YouAreNotPrepared:GetItemsInBags(isItMatch)
    -- look into caching
    local map = {}
    for bag = 0, NUM_BAG_FRAMES, 1 do
        for slot = 1, GetContainerNumSlots(bag) do
            local id = GetContainerItemID(bag, slot)
            local isMatch = false
            if type(id) == "number" and isItMatch(id, bag, slot) then
                if not map[id] then map[id] = { amount = 0, locations = {} } end
                local entry = map[id]
                local _, itemCount = GetContainerItemInfo(bag, slot);
                entry.amount = entry.amount + itemCount
                local location = {}
                location.bag = bag
                location.slot = slot
                table.insert(entry.locations, location)
            end
        end
    end
    return map
end

function YouAreNotPrepared:Cache(cacheIndex, cacheFunc, needCachingFunc)
    if type(self.cache[cacheIndex]) ~= "table" then self.cache[cacheIndex] = {} end
    local currentCache = self.cache[cacheIndex]
    local needsCaching = not currentCache.invalid or type(needCachingFunc) == "function" and needCachingFunc(currentCache)
    if needsCaching then
        cacheFunc(currentCache)
    end
    return currentCache
end

function YouAreNotPrepared.CacheSpells(cacheValue)
    local index = 1
    local skillType, id = GetSpellBookItemInfo(index, "player")
    local spellMap = {}
    while skillType do
        if skillType == "SPELL" then spellMap[id] = true end
        index = index + 1
        skillType, id = GetSpellBookItemInfo(index, "player")
    end
    cacheValue.invalid = false
    cacheValue.map = spellMap
end

function YouAreNotPrepared.InvalidateFunc(cacheName)
    local func = YouAreNotPrepared.cacheInvalidators[cacheName]
    if type(func) ~= "function" then 
        func = function()
            local myCache = YouAreNotPrepared.cache[cacheName] 
            if type(myCache) == "table" then myCache.invalid = true end
        end
        YouAreNotPrepared.cacheInvalidators[cacheName] = func
    end
    return func
end

YouAreNotPrepared:RegisterBlizzardEvent("SPELLS_CHANGED", YouAreNotPrepared.InvalidateFunc("spells"))
YouAreNotPrepared:RegisterBlizzardEvent("LEARNED_SPELL_IN_TAB", YouAreNotPrepared.InvalidateFunc("spells"))

function YouAreNotPrepared:HasAnySpellId(spellIds)
    local cache = self:Cache("spells", YouAreNotPrepared.CacheSpells)
    if type(spellIds) == "table" then
        for k, v in pairs(spellIds) do
            if cache[v] then return true end
        end
    elseif type(spellIds) == "number" then
        if cache[spellIds] then return true end
    else
        return false
    end
end



function YouAreNotPrepared:AddReminder(func, configArr)
    self.reminderConfigurations[func] = configArr
    table.insert(self.reminders, func)
end

function YouAreNotPrepared:AddFieldReminder(func, configArr)
    self.reminderConfigurations[func] = configArr
    table.insert(self.fieldReminders, func)
end

function YouAreNotPrepared.TalentPointRemainingReminder()
    local talentPoints = UnitCharacterPoints("player");
    
    if talentPoints > 0 then
        return false, "You need to spend your talent point(s)"
    end
    
    return true, ""
end
YouAreNotPrepared:AddReminder(YouAreNotPrepared.TalentPointRemainingReminder)

function YouAreNotPrepared:ShouldRemind()
    return IsResting() and not InCombatLockdown()
end

function YouAreNotPrepared:CheckIfShouldRemindAgain()
    local timestamp = time()
    if not self.data.lastReminded or timestamp - self.data.lastReminded > YouAreNotPrepared:GetConfigurationOption("YANP.timeBetweenReminders", 60 * 5) then
        return self:ShouldRemind()
    end
    return false
end

function YouAreNotPrepared_Sound(reminder)
    if YouAreNotPrepared:GetConfigurationOption("YANP.sound.enabled", true) then
        local soundToPlay = YouAreNotPrepared:GetConfigurationOption("YANP.sound.default", 1141) -- Credits to SmartBuff for this sound
        if YouAreNotPrepared:GetConfigurationOption("YANP.sound.onlyIfSpecified", false) or reminder.sound then
            soundToPlay = reminder.sound
        end
        if type(soundToPlay) == "number" then
            return pcall(PlaySound, soundToPlay)
        elseif type(soundToPlay) == "string" then
            return pcall(PlaySoundFile, soundToPlay)
        end
        return false, "no sound to play"
    end
    return false, "sound disabled"
end

local pv = function(v)
    return type(v) .. " " .. tostring(v)
end

function YouAreNotPrepared:EvaluateReminders(reminderTable)
    if type(reminderTable) ~= "table" then self:Print("Eval reminders did not receive a table") return false end
    local data = {}
    data.msg = ""
    data.sound = nil
    for k, v in pairs(reminderTable) do
        local ok, reminderBool, reminderMsg, sound = pcall(v, self.reminderConfigurations[v])
        if not ok then
            self:Print("Failed to evaluate ".. tostring(k) .. " :: " .. tostring(v))
        elseif not reminderBool then
            if type(reminderMsg) ~= "table" then
                local t = {}
                t.message = reminderMsg
                t.sound = sound
                reminderMsg = t
            end
            if reminderMsg.sound then data.sound = reminderMsg.sound end
            if type(reminderMsg.message) == "string" and reminderMsg.message:len() > 0 then
                data.msg = data.msg .. tostring(reminderMsg.message) .. "\n"
            end
        elseif YouAreNotPrepared:GetConfigurationOption("YANP.debug", false) then
            self:Print("Evaluation of " .. pv(k) .. " :: " .. pv(v) .. " => " .. pv(reminderMsg))
        end
    end
    if data.msg and data.msg:len() > 0 then
        YouAreNotPrepared_ShowMessage(YouAreNotPrepared:GetConfigurationOption("YANP.message.shouldRemainFor", 15), data.msg)
        if(YouAreNotPrepared:GetConfigurationOption("YANP.printMessage", true)) then
            self:Print(data.msg)
        end
        YouAreNotPrepared_Sound(data)
        return data
    end
end

-- Sound /run PlaySound(8959)

YouAreNotPrepared.everySecond = function()
    local self = YouAreNotPrepared
    local t = time()
    local dbg = YouAreNotPrepared:GetConfigurationOption("YANP.debug", false)
    if self:ShouldRemind() then
        if type(self.data.lastReminded) ~= "number" or t - self.data.lastReminded >= YouAreNotPrepared:GetConfigurationOption("YANP.timeBetweenReminders", 60 * 5) then
            if dbg and type(self.data.lastReminded) == "number" then
                self:Print("Last reminded: " .. pv(self.data.lastReminded) .. " Cur Time: " .. pv(t) .. " diff: " .. pv(t - self.data.lastReminded))
            end
            if self:EvaluateReminders(self.reminders) then
                self.data.lastReminded = t
            end
        end
    end
    if type(self.data.lastFieldReminded) ~= "number" or t - self.data.lastFieldReminded >= YouAreNotPrepared:GetConfigurationOption("YANP.timeBetweenFieldReminders", 60 * 5) then
        if dbg and type(self.data.lastFieldReminded) == "number" then
            self:Print("Last field reminded: " .. pv(self.data.lastFieldReminded) .. " Cur Time: " .. pv(t) .. " diff: " .. pv(t - self.data.lastFieldReminded))
        end
        if self:EvaluateReminders(self.fieldReminders) then
            self.data.lastFieldReminded = t
        end
        
    end
end

YouAreNotPrepared:AddConfigurationOption("YANP.debug", "boolean", false)
YouAreNotPrepared:AddConfigurationOption("YANP.printMessage", "boolean", true)
YouAreNotPrepared:AddConfigurationOption("YANP.sound.enabled", "boolean", true)
YouAreNotPrepared:AddConfigurationOption("YANP.sound.default", "number", 1141)
YouAreNotPrepared:AddConfigurationOption("YANP.sound.onlyIfSpecified", "boolean", false)
YouAreNotPrepared:AddConfigurationOption("YANP.timeBetweenReminders", "number", 60 * 5)
YouAreNotPrepared:AddConfigurationOption("YANP.timeBetweenFieldReminders", "number", 60 * 5)
YouAreNotPrepared:AddConfigurationOption("YANP.message.shouldRemainFor", "number", 15)
YouAreNotPrepared:AddTicker(YouAreNotPrepared.everySecond, 1)


DOYANP = function() YouAreNotPrepared:EvaluateReminders(YouAreNotPrepared.reminders) end

