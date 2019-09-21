local SarfCommonLibVersion = 1.0
if not _G["SarfCommonLib"] or _G["SarfCommonLib"].version >= SarfCommonLibVersion then -- LibVersionChecker
local old = _G["SarfCommonLib"]
SarfCommonLib = {}
SarfCommonLib.keep = {"internalEventListeners"}
SarfCommonLib.version = SarfCommonLibVersion
SarfCommonLib.mixins = {}
SarfCommonLib.mixins.logLevel = { FINEST = 5000, FINER = 1000,  FINE = 500, INFO = 100,  WARNING = 50, SEVERE = 0}
SarfCommonLib.internalEventListeners = {}
function SarfCommonLib:MixFromOther(selfName, otherValue)
    local ownValue = self[selfName]
    if type(ownValue) ~= "table" or type(otherValue) ~= "table" then return end
    for k, v in pairs(otherValue) do if not ownValue[k] then ownValue[k] = v end end
end

if type(old) == "table" and type(old.keep) == "table" then for k, v in pairs(old.keep) do SarfCommonLib:MixFromOther(v, old[k]) end end

function SarfCommonLib.mixins.log(self, level, what, ...)
    if self.options and self.options.logLevel and self.options.logLevel > level then
        if type(what) == "function" then
            local val = what(select(1, ...))
            if type(val) == "string" then
                ChatFrame1:AddMessage("log("..tostring(level)..") : " .. val)
            end
        end
    end
end

function SarfCommonLib.mixins.Eval(self, f)
    if type(f) == "function" then return f()
    else return f end
end

function SarfCommonLib.mixins.AddListener(self, listeners, listener, changeListenerFunc)
    if type(listeners) == "function" then local arr = {listeners, listener}; changeListenerFunc(arr)
    elseif type(listeners) == "table" then table.insert(listeners, listener)
    else changeListenerFunc(listener) end
end
function SarfCommonLib.mixins.RegisterEvent(self, event, listener)
    if type(SarfCommonLib.internalEventListeners[event]) ~= "table" then SarfCommonLib.internalEventListeners[event] = {} end
    self:AddListener(SarfCommonLib.internalEventListeners[event], listener, function(v) SarfCommonLib.internalEventListeners[event] = v end)
end

local dumpValue = function(res)
    local q = ""
    if type(res) == "string" then q = res
    elseif type(res) == "table" then
        for k, v in pairs(res) do
            q = q .. (tostring(k) .. " => " .. tostring(v)) .. "\n"
        end
    end
    return q
end

function SarfCommonLib.mixins.PCall(self, func,  ...)
    if type(func) == "function" then
        local res = { pcall(func, select(1, ...)) }
        if not res[1] then
            ChatFrame1:AddMessage("Error while calling " .. tostring(func) .. " : " .. tostring(res[2]))
        else
            table.remove(res, 1)
            self:log(self.logLevel.FINEST, dumpValue, res)
            return unpack(res)
        end
        
    end
end

function SarfCommonLib.mixins.SendToListeners(self, listeners, ...)
    local f = listeners
    if type(f) == "function" then
        f(select(1, ...))
    elseif type(f) == "table" then
        for k, v in pairs(f) do
            self:PCall(k, select(1, ...))
            self:PCall(v, select(1, ...))
        end
    end
end
function SarfCommonLib.mixins.FireEvent(self, event, ...)
    -- TODO: do this in another thread?
    self:SendToListeners(SarfCommonLib.internalEventListeners[event], select(1, ...))
end

function SarfCommonLib.mixins.Localize(self, textIndexP, defaultValueP, desiredLocaleP)
    local textIndex, defaultValue, desiredLocale = self:Eval(textIndexP), self:Eval(defaultValueP), self:Eval(desiredLocaleP)
    if type(self.localization) == "table" then
        local locale = desiredLocale or self.locale or "en"
        if type(self.locale[locale]) == "table" and type(self.locale[locale][textIndex]) == "string" then return self.locale[locale][textIndex]
        elseif type(self.locale[textIndex]) == "string" then return self.locale[textIndex] 
        elseif type(defaultValue) == "string" then return defaultValue 
        else return textIndex end
    elseif type(defaultValue) == "string" then return defaultValue 
    else return textIndex end
end
SarfCommonLib.mixins.L = SarfCommonLib.mixins.Localize

function SarfCommonLib.mixins.Colourize(self, text, colour)
    if type(colour) ~= "string" then return self:Localize(text) end
    local colourText = colour
    if colour == "RED" then colourText = "FFEF1212" end
    if colour == "GREEN" then colourText = "FF12EF12" end
    if colour == "BLUE" then colourText = "FF1212EF" end
    if colour == "LIGHTBLUE" then colourText = "FF5252EF" end
    if colour == "RB" then colourText = "FFEF12EF" end
    if colour == "YELLOW" then colourText = "FFEFEF12" end
    if colour == "CYAN" then colourText = "FF12EFEF" end
    if colour == "WHITE" then colourText = "FFFFFFEF" end
    return "|c" .. colourText .. self:Localize(text) .. "|r"
end

SarfCommonLib.mixins.C = SarfCommonLib.mixins.Colourize

function SarfCommonLib.mixins.Print(self, msg)
    ChatFrame1:AddMessage(self:Colourize(self.setup.shortName or "", "GREEN") .. ": " .. tostring(msg), 1, 1, 0)
end

_G["SLASH_RELOADUI1"] = "/rl"
_G["SLASH_RELOADUI2"] = "/reloadui"
_G["SlashCmdList"]["RELOADUI"] = function(cmd,a,b,c) ConsoleExec("reloadui") end

function SarfCommonLib.mixins.SlashCommandSetup(self)
    if type(self.slashcommands) ~= "table" then return end
    _G["SLASH_" .. self.setup.name .. "1"] = "/" .. self.setup.shortName
    _G["SLASH_" .. self.setup.name .. "2"] = "/" .. self.setup.name
    _G["SlashCmdList"][self.setup.name] = function(cmd,a,b,c) self:SlashCommand(cmd,a,b,c) end
end

function SarfCommonLib.mixins.SlashCommandUsage(self)
    self:Print("Usage: ")
    self:Print(string.format("%s %s %s\n", self:C(_G["SLASH_" .. self.setup.name .. "1"], "GREEN"), self:C("<command>", "CYAN"), self:C("[options]", "YELLOW")))
    local validCommands = ""
    if type(self.slashcommands) ~= "table" then
        self:Print("No valid commands available.")
    end
    for k, v in pairs(self.slashcommands) do
        local cmd = self:Eval(k)
        if type(cmd) == "string" then 
            if validCommands:len() > 0 then validCommands = validCommands .. ", " end
            validCommands = validCommands .. cmd
        end
    end
    if validCommands:len() <= 0 then
        self:Print("No valid commands available.")
    else
        self:Print("Valid commands: " .. validCommands)
    end
end

function SarfCommonLib.mixins.PostSetup(self)
    self:setupSlashCommandsBasic()
    self:SlashCommandSetup()
end

function SarfCommonLib.mixins.GetFirstWordAndRest(self, orig)
    if type(orig) == "string" then
        local start, stop = orig:find("%a+")
        if type(start) == "number" then
            local cmd = string.sub(orig, start, stop):lower()
            local arg = string.sub(orig, stop + 2, orig:len())
            return cmd, arg
        end
    end
    return nil, orig
end

function SarfCommonLib.mixins.SlashCommand(self, args)
    -- handle get and set commands
    if type(args) ~= "string" then return end
    local cmd, arg = self:GetFirstWordAndRest(args)
    if not cmd then return self:SlashCommandUsage() end
    local commandFunc = self.slashcommands[cmd]
    if type(commandFunc) == "function" then return commandFunc(arg)
    else
        self:Print("Unknown command " .. cmd)
    end
end

function SarfCommonLib.mixins.AddInitialization(self, func, config)
    if type(self.initializations) ~= "table" then self.initializations = {} end
    if config then if type(self.initializationsConfig) ~= "table" then self.initializationsConfig = {} end self.initializationsConfig[func] = config end
    table.insert(self.initializations, func)
end


function SarfCommonLib.mixins.AddConfigurationOption(self, name, typeOption, defaultValue, setFunc, getFunc)
    local n = "configurationOptions"
    if not self[n] then self[n] = {} end
    self[n][name] = { type = typeOption, defaultValue = defaultValue, setFunc = setFunc, getFunc = getFunc }
end

function SarfCommonLib.mixins.GetConfigurationOption(self, name, defaultValue, nextOne)
    if type(nextOne) == defaultValue then defaultValue = nextOne end
    local n = "configurationOptions"
    if self[n] and self[n][name] then
        local current = self[n][name]
        if type(current.value) == current.type then
            if type(current.getFunc) == "function" then
                return current.getFunc(current.value, current)
            else
                return current.value
            end
        end
        
    end
    return defaultValue
end


function SarfCommonLib.mixins.setupSlashCommandsBasic(self)
    local listAliases = {"listconfig", "listcfg", "listvars"}
    local listFunc = function(args)
        local n = "configurationOptions"
        local str = "None"
        if self[n] then
            self:Print("Configuration Options: '" .. tostring(args) .. "'")
            local filter = function(n) return true end
            if type(args) == "string" and args:len() > 0 then
                filter = function(n) return string.find(n, args) ~= nil end
            end
            local result = {}
            for k, v in pairs(self[n]) do
                if filter(k, v) then
                    local value = v.value or "unset, defaults to " .. tostring(v.defaultValue)
                    table.insert(result, string.format("%s = %s", k, tostring(value)))
                end
            end
            table.sort(result)
            for k, v in ipairs(result) do
                self:Print(v)
            end
        else
            self:Print("No configuration options available.")
        end
    end
    for k, v in pairs(listAliases) do self.slashcommands[v] = listFunc end

    self.slashcommands["set"] = function(args)
        local var, arg = self:GetFirstWordAndRest(args)
        if not var then return self:SlashCommandUsage() end
        local n = "configurationOptions"
        if self[n] and self[n][var] then
            local current = self[n][var]
            local newValue
            newValue, arg = self:GetFirstWordAndRest(arg)
            if newValue and type(current.setFunc) == "function" then
                current.setFunc(newValue, current)
                self:Print(string.format("Set %s to %s", var, tostring(current.value)))
                return
            end
            if newValue and type(newValue) ~= current.type then
                if current.type == "number" then
                    if type(newValue) == "string" then
                        newValue = tonumber(newValue)
                    end
                elseif current.type == "string" then
                    newValue = tostring(newValue)
                end
            end
            if newValue and type(newValue) == current.type then
                current.value = newValue
                self:Print(string.format("Set %s to %s", var, tostring(current.value)))
                return
            else
                -- could not set a type to notType
            end
        end
        return self:SlashCommandUsage()
    end

    self.slashcommands["get"] = function(args)
        local var, arg = self:GetFirstWordAndRest(args)
        if not var then return self:SlashCommandUsage() end
        local n = "configurationOptions"
        if self[n] and self[n][var] then
            local current = self[n][var]
            self:Print(string.format("%s is currently %s", var, tostring(current.value)))
            return
        end
        return self:SlashCommandUsage()
    end

end

function SarfCommonLib.mixins.LoadConfiguration(self, source)
    if type(destination) ~= "table" then return false end
    local n = "configurationOptions"
    local destination = self[n]
    for k, v in pairs(source) do
        if v.value and (type(destination[k]) == "table" and v.value ~= destination[k].defaultValue) then
            if not destination[k] then destination[k] = {} end
            destination[k].value = v.value
        end
    end
end



function SarfCommonLib.mixins.SaveConfiguration(self, destination)
    if type(destination) ~= "table" then return false end
    local n = "configurationOptions"
    for k, v in pairs(self[n]) do
        if v.value and v.value ~= v.defaultValue then
            if not destination[k] then destination[k] = {} end
            destination[k].value = v.value
        end
    end
end


function SarfCommonLib.mixins.SetConfigurationOption(self, name, newValue)
    local n = "configurationOptions"
    if type(nextOne) == defaultValue then defaultValue = nextOne end
    if self[n] and self[n][name] then
        local current = self[n][name]
        if type(newValue) == current.type then
            if type(current.setFunc) == "function" then
                current.setFunc(newValue, current)
            else
                current.value = newValue
            end
        end
    end
end

function SarfCommonLib.mixins.Initialize(self)
    if self.setup.done or type(self.initializations) ~= "table" then return end
    local removeList = {}
    local exec = function(obj)
        if type(obj) == "number" and self.initializations[obj] then return true end
        local f = obj
        if type(obj) == "string" then f = _G[obj] end
        if type(f) == "function" then local param = nil if type(self.initializationsConfig) == "table" then param = self.initializationsConfig[obj] end return f(param) end
    end
    for k, v in pairs(self.initializations) do
        if not exec(k) or not exec(v) then table.insert(removeList, k) end
    end
    for i = #removeList, 1, -1 do
        table.remove(self.initializations, removeList[i])
    end
    self:PostSetup()
    self.setup.done = true
    local slashCmd = _G["SLASH_" .. self.setup.name .. "1"]
    if slashCmd then slashCmd = " - use " .. slashCmd .. " to access."
    else slashCmd = "." end
    self:Print((self.setup.name or "") .. " initialized" .. slashCmd)
end

function SarfCommonLib.mixins.RegisterBlizzardEvent(self, event, func)
    self:AddListener(self[event], func, function(v) self[event] = v end)
end

function SarfCommonLib.mixins.AddTimer(self, func, inMilliseconds, timerConfig)
    if type(self.timers) ~= "table" then self.timers = {} end
    local executeAt = inMilliseconds or 1000
    --self.timers[func] = { when = executeAt, config = timerConfig }
    C_Timer.After(executeAt/1000, function() self:PCall(func, timerConfig) end)
end

function SarfCommonLib.mixins.AddTicker(self, func, between, timerConfig)
    if type(self.tickers) ~= "table" then self.tickers = {} end
    --self:log(self.logLevel.WARNING, function() return dumpValue({self, func, between,  timerConfig}) end)
    local executeAt = between or 1
    local ticker = C_Timer.NewTicker(between, function() self:PCall(func, timerConfig) end)
    self.tickers[func] = { between = between, handle = ticker, config = timerConfig }
end

SarfCommonLib.create = function(globalReference)
    local ref = globalReference
    if type(ref) == "string" then ref = _G[globalReference] end
    if type(ref) ~= "table" then return false end
    if not ref.frame then ref.frame = CreateFrame("Frame") end
    
    for k, v in pairs(SarfCommonLib.mixins) do
        ref[k] = v
    end
    ref.frame:SetScript("OnEvent", function(event, ...)
        local f = ref.frame[event]
        if type(f) == "string" then 
            f = ref[f]
        end
        ref:SendToListeners(f, select(1,...))
    end)
    
    if not ref.options then ref.options = {} end
    if not ref.options.logLevel then ref.options.logLevel = ref.logLevel.INFO end
    
    local init = function() ref:Initialize() end
    ref.frame:SetScript("OnLoad", init)
    ref:RegisterBlizzardEvent("PLAYER_ENTERING_WORLD", init)
    ref:AddTimer(init, 3000)
    return ref
end
end -- LibVersionChecker


