local function fResolveField(tRoot, sPath)
	local tValue	= tRoot

	if sPath ~= "ROOT" then
		for sKey in string.gmatch(sPath, "[^%.]+") do
			if IsTable(tValue) then
				tValue	= tValue[sKey]
			else
				tValue	= nil
				break
			end
		end
	end

	return tValue
end

local function fValidateGroup(sGroup, tGroup)
	if not IsTable(tGroup) then
		return false, "[SUBLOADER] Invalid config group '"..sGroup.."': expected table, got "..type(tGroup)
	end
	if not IsTable(tGroup.DATA) then
		return false, "[SUBLOADER] Missing 'FILES' table in group '"..sGroup.."'"
	end
	if not IsString(tGroup.DATA.SUBLOADER) then
		return false, "[SUBLOADER] Invalid 'FILES.SUBLOADER' in group '"..sGroup.."': expected string"
	end
	if not IsBool(tGroup.DATA.SHARED) then
		return false, "[SUBLOADER] Invalid 'FILES.SHARED' in group '"..sGroup.."': expected boolean"
	end
	if not IsTable(tGroup.DATA.ENV_PROFILE) then
		return false, "[SUBLOADER] Missing 'ENV_PROFILE' table in group '"..sGroup.."'"
	end
	return true
end

local function fValidateSubLoader(sGroup, tSubLoader)
	if not IsTable(tSubLoader) then
		return false, "[SUBLOADER] Sub-loader for group '"..sGroup.."' did not return a valid table"
	end
	if not (IsTable(tSubLoader[1]) and IsFunction(tSubLoader[1].Initialize)) then
		return false, "[SUBLOADER] Sub-loader for group '"..sGroup.."' is missing a valid Initialize method"
	end
	return true
end

local SUBLOADER_BASE	= {}

function SUBLOADER_BASE:Initialize(tConfig, sBasePath, tLoader)
	local self	= setmetatable({
		INITIALIZED	= true,
		SUBLOADERS	= {},
		ATTRIBUTES	=
		{
			CONFIG		= tConfig,
			BASE_PATH	= sBasePath,
			LOADER		= tLoader,
		},
	}, {__index = SUBLOADER_BASE})

	return self
end

function SUBLOADER_BASE:InitializeGroup(sGroup)
	if not self.INITIALIZED then return MsgC(self:GetAttribute("LOADER"):GetConfig().DEBUG.COLORS.ERROR, "[LOADER] SubLoader base not initialize") end
	if not IsString(sGroup) then return MsgC(self:GetAttribute("LOADER"):GetConfig().DEBUG.COLORS.ERROR, "[LOADER] sGroup not a string : "..type(sGroup)) end

	local tConfig			= self:GetAttribute("CONFIG")
	local sBasePath			= self:GetAttribute("BASE_PATH")
	local tLoader			= self:GetAttribute("LOADER")
	local tGroup			= tLoader:GetConfig()[sGroup]

	if not IsTable(tGroup) then
		return MsgC(tLoader:GetConfig().DEBUG.COLORS.WARNING, "[LOADER] No configuration found for group '"..sGroup.."'")
	end
	local bShouldLoad		= (tGroup.DATA.SHARED and CLIENT) or SERVER
	if not bShouldLoad then return end

	local bValid, sError	= fValidateGroup(sGroup, tGroup)
	if not bValid then
		return MsgC(tLoader:GetConfig().DEBUG.COLORS.ERROR, string.format("[LOADER] Group '%s' validation failed: %s", sGroup, sError or "unknown"))
	end

	tLoader:GetConfig()[sGroup].CONTENT	= tLoader:GetLibrary("ORDERER"):BuildGlobalOrder(tGroup.CONTENT)
	local sPath							= sBasePath .. tGroup.DATA.SUBLOADER
	local bSubOk, tSubLoader			= pcall(function() return tLoader:LoadSubLoader(sPath, tGroup.CONTENT, tGroup.DATA.SHARED, sGroup, tGroup.DATA.ENV_PROFILE) end)
	if not bSubOk then
		return MsgC(tLoader:GetConfig().DEBUG.COLORS.ERROR, string.format("[LOADER] Failed to load SubLoader for '%s', sPath : '%s', ERROR : %s", sGroup, sPath, tSubLoader))
	end

	local bSubValid, sSubError = fValidateSubLoader(sGroup, tSubLoader)
	if not bSubValid then
		return MsgC(tLoader:GetConfig().DEBUG.COLORS.ERROR, string.format("[LOADER] SubLoader '%s' validation failed: %s", sGroup, sSubError or "unknown"))
	end

	MsgC(tLoader:GetConfig().DEBUG.COLORS.SUCCESS, "[LOADER] SubLoader for group '"..sGroup.."' loaded successfully !")

	local bInitOk, tInitialized = pcall(function() return tSubLoader[1]:Initialize(tSubLoader[2]) end)
	if not bInitOk then
		return MsgC(tLoader:GetConfig().DEBUG.COLORS.ERROR, string.format("[LOADER] SubLoader '%s' initialization failed ! ERROR : %s", sGroup, tInitialized))
	end

	self.SUBLOADERS[sGroup]	= tSubLoader

	return tSubLoader, tInitialized
end

function SUBLOADER_BASE:CheckFileStructureIntegrity(iID, tFile)
	for _, tRule in ipairs(self:GetAttribute("LOADER").RULES_FILES) do
		local sField	= tRule.FIELD
		local sType		= tRule.TYPE
		local fCheck	= _G["Is" .. sType]

		if not IsFunction(fCheck) then
			error("[OBJECTS SUB-LOADER] Unknown type checker 'is" .. sType .. "'")
		end

		if not fCheck(fResolveField(tFile, sField)) then
			return MsgC(
				self:GetAttribute("LOADER"):GetConfig().DEBUG.COLORS.ERROR,
				"[OBJECTS SUB-LOADER] Invalid field '" .. sField .. "' for ID : " .. iID
			)
		end
	end

	return true
end

function SUBLOADER_BASE:SetAttribute(sKey, Value)
	assert(IsString(sKey),	"[SUBLOADER_BASE] Key must be a string")
	assert(Value ~= nil,	"[SUBLOADER_BASE] Value cannot be nil")

	self.ATTRIBUTES[sKey] = Value
end

function SUBLOADER_BASE:GetAttribute(sKey)
	assert(IsString(sKey), 	"[SUBLOADER_BASE] Key must be a string")

	return self.ATTRIBUTES[sKey]
end

function SUBLOADER_BASE:GetSubLoaders()
	return self.SUBLOADERS
end

function SUBLOADER_BASE:GetSubLoader(sGroup)
	return self.SUBLOADERS[sGroup]
end

function SUBLOADER_BASE:GetGroupByFileName(sFileName)
	assert(IsString(sFileName), "[SUBLOADER_BASE] File name must be a string")

	sFileName	= string.upper(sFileName)
	for sGroup, tSubLoader in pairs(self.SUBLOADERS) do
		for iID, tFile in pairs(tSubLoader[2]) do
			if tFile.KEY == sFileName then
				return sGroup, iID, tFile
			end
		end
	end

	return nil, nil, nil
end

return SUBLOADER_BASE