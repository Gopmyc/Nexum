SUBLOADER.__ENV	= nil
SUBLOADER.__ID	= "HOT_REALOD"
SUBLOADER.tExeptedGroup	= {
	X	= true,
}

local function fGetFileInGroup(tGroup, sFile)
	assert(istable(tGroup), "[SUBLOADER] Invalid argument: tGroup must be a table")
	assert(isstring(sFile), "[SUBLOADER] Invalid argument: sFile must be a string")

	tGroup = (tGroup.FILES and tGroup.FILES.CONTENT) or tGroup

	if #tGroup < 1 then return MsgC(Color(231,76,60), "[SUBLOADER] The group has no files to search for '"..sFile.."'\n") end

	for iID, tFile in ipairs(tGroup) do
		if tFile.key == sFile then return tFile end
	end
	
	return MsgC(Color(231,76,60), "[SUBLOADER] File '"..sFile.."' not found in the given group\n")
end

local function fGetConfigGroup(tConfig, sGroup)
	assert(istable(tConfig), "[LOADER] Invalid argument: tConfig must be a table")
	assert(isstring(sGroup), "[LOADER] Invalid argument: sGroup must be a string")

	local tGroup = tConfig

	for _, sPart in ipairs(string.explode("/", sGroup)) do
		tGroup = tGroup and tGroup[sPart] or nil

		if not tGroup then
			MsgC(Color(231,76,60), "[LOADER] Config segment not found: '"..sPart.."' in group '"..sGroup.."'\n")
			break
		end
	end

	return tGroup
end

function SUBLOADER:Initialize(tContent)
	if CLIENT then return end
	assert(istable(tContent),			"[HOT RELOAD] Content must be a table")
	assert(isfunction(self.GetLoader),	"[HOT RELOAD] Loader access method is missing")

	local tConfig		= self:GetLoader():GetConfig()
	local bInitialize	= istable(tConfig) and istable(tConfig.DEBUG) and tConfig.DEBUG.ENABLED and isnumber(tConfig.DEBUG.HOT_RELOAD_TIME)

	if bInitialize then
		local iDelay				= tConfig.DEBUG.HOT_RELOAD_TIME
		local bOk, tHotRelod		= pcall(function() return self:HotReloadInitialize() end)

		self.HotReload	= tHotRelod
		MsgC(bOk and Color(46, 204, 113) or Color(231, 76, 60),	"[HOT-RELOAD] HotReloadInitialize " .. (bOk and "success" or "failed") .. "!\n")
		if not bOk then return MsgC(Color(231, 76, 60), "Error: " .. tostring(tHotRelod) .. "\n") and debug.Trace() end

		--timer.Create(
		--	ProjectNameCapital .. ":HotReload",
		--	iDelay,
		--	0,
		--	function()
		--		local bOk, sErr = xpcall(
		--			function()
		--				return self:HotReloading()
		--			end,
		--			function(sErr)
		--				MsgC(Color(231,76,60), string.format("[HOT-RELOAD] Error during HotReload: %s\n", sErr))
		--				debug.Trace()
		--			end
		--		)
		--	end
		--)
	end

	self.bDebug			= true
	self.__Initialized	= true

	return {}
end

function SUBLOADER:HotReloadInitialize()
	local tHotReload	= {}
	local tHotCache		= {}

	for _, sGroup in ipairs(self:GetLoader().LOAD_PRIORITY) do
		local tGroupRessources		= self:GetLoader().RESSOURCES[sGroup]
		if not tGroupRessources then goto continue end

		local tGroupConfig = fGetConfigGroup(self:GetLoader():GetConfig(), sGroup)
		for sFileKey, _ in pairs(tGroupRessources) do
			local tFile				= self.tExeptedGroup[sGroup] and {path = ""} or fGetFileInGroup(tGroupConfig, sFileKey)

			if not (tFile and isstring(tFile.path)) then
				MsgC(Color(231, 76, 60), string.format("[HOT-RELOAD] File '%s' in group '%s' has no valid path\n", sFileKey, sGroup))
				goto continue
			end

			local iIndex			= #tHotReload + 1
			tHotReload[iIndex]	= {
				[1] = sFileKey,
				[2] = lovr.filesystem.getLastModified(tFile.path),
				[3] = sGroup,
				[4] = tFile,
				[5] = {},
				[6] = tGroupConfig,
			}
			tHotCache[sFileKey] 	= iIndex

			if self.tExeptedGroup[sGroup] then print(sFileKey) print(tHotReload[iIndex], iIndex, tHotReload[iIndex][1]) end

			::continue::
		end

		::continue::
	end

	for _, entry in ipairs(tHotReload) do
		local tFileArgs	= entry[4].args

		if not istable(tFileArgs) then goto continue end
		for _, sDep in ipairs(tFileArgs) do
			local depIndex = tHotCache[sDep]

			if depIndex then
				tHotReload[depIndex][5][#tHotReload[depIndex][5] + 1] = entry
			end
		end

		::continue::
	end

	return tHotReload
end

function SUBLOADER:HotReloading()
	local tNetScript	= self:GetLoader():GetScript("net")
	local tHookScript	= self:GetLoader():GetScript("hook")
	local sPrefix		= "HOT_RELOAD"

	if SERVER then
		if not istable(self.HotReload) then return end
		for _, tFileData in ipairs(self.HotReload) do

			local tFile					= tFileData[4]
			local iTimeStamp			= lovr.filesystem.getLastModified(tFileData[1])

			if tFileData[2] >= iTimeStamp then goto continue end

			local tSubLoader			= self:GetLoader():GetSubLoaderBase():GetSubLoader(tFileData[3])
			local tRessource			= self:GetLoader().RESSOURCES[tSubLoader[1]:GetID()]
			local sModuleKey			= tFileData[1]

			local tOldModule			= tRessource[sModuleKey]
			local tNewModule, bShared	= tSubLoader[1]:LoadFile(tFile)

			if istable(tOldModule) and istable(tNewModule) then
				for sKey, Value in pairs(tNewModule) do
					if not isfunction(Value) then goto continue end -- TODO : Update more than just the functions
					tOldModule[sKey]	= Value
				end

				if isfunction(tOldModule.OnHotReload) then tOldModule:OnHotReload(tNewModule) end
			else
				tRessource[sModuleKey] = tNewModule
			end

			tFileData[2] = iTimeStamp

			if bShared then
				local sBinary	= self:LoadFile(tFile.path)
				tNetScript:SendLong(player.GetHumans(), sBinary, sPrefix, {tSubLoader[1]:GetID(), sModuleKey})
			end

			for _, tDependent in ipairs(tFileData[5]) do
				local tDepFile				= tDependent[4]
				local tDepSubLoader			= self:GetLoader():GetSubLoaderBase():GetSubLoader(tDependent[3])
				local tDepRessource			= self:GetLoader().RESSOURCES[tDepSubLoader[1]:GetID()]
				local sDepKey				= tDependent[1]

				local tOldDep				= tDepRessource[sDepKey]
				local tNewDep, bDepShared	= tDepSubLoader[1]:LoadFile(tDepFile)

				if istable(tOldDep) and istable(tNewDep) then
					for sKey, xValue in pairs(tNewDep) do
						if not isfunction(xValue) then goto continue end -- TODO : Update more than just the functions
						tOldDep[sKey] = xValue
					end

					if isfunction(tOldDep.OnHotReload) then
						tOldDep:OnHotReload(tNewDep)
					end
				else
					tDepRessource[sDepKey] = tNewDep
				end

				tDependent[2] = lovr.filesystem.getLastModified(tDepFile.path)

				if bDepShared then
					local sBinary = self:LoadFile(tDepFile.path)
					tNetScript:SendLong(player.GetHumans(), sBinary, sPrefix, {tDepSubLoader[1]:GetID(), sDepKey})
				end
				::continue::
			end
			::continue::
		end
	elseif CLIENT then
		for iID, tBuffer in ipairs(tNetScript:GetLongsByPrefix(sPrefix)) do
			tNetScript:RemoveLong(tBuffer.ID)
			
			local Other								= tBuffer.OTHER
			local tGroupConfig						= fGetConfigGroup(self:GetConfig(), Other[1])
			local tFile								= fGetFileInGroup(tGroupConfig, Other[2])
			local fChunk							= self:LoadFile(table.concat(tBuffer.DATA))

			self.RESSOURCES[Other[1]][Other[2]]	= self:GetLoader():GetSubLoaderBase():GetSubLoader(Other[1])[1]:LoadFile(tFile, fChunk)
		end
	end
end

function SUBLOADER:LoadFile(sString)
	assert(isstring(sString), "[SUBLOADER] Expected string for argument #1, got :" .. type(sString))

	if SERVER then
		local tLibrary1	= self:GetLibrary("server/compiler")
		sString			= tLibrary1:Compile(sString)
		if not isstring(sString) then return end

		local tLibrary2	= self:GetLibrary("lzw")
		sString			= tLibrary2:Compress(sString)
		if not isstring(sString) then return end

		return sString
	elseif CLIENT then
		sString			= util.Decompress(sString)
		if not isstring(sString) then return end

		local tLibrary1	= self:GetLibrary("lzw")
		sString			= tLibrary1:Decompress(sString)
		if not isstring(sString) then return end

		local tLibrary2	= self:GetLibrary("client/interpreter")

		return tLibrary2:Interpret(sString)
	end

	return nil
end