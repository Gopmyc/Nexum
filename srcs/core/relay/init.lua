function CORE:Initialize()
	local FOLDER_TO_CLEAN	= assert(self:GetConfig().RELAY.FOLDER_TO_CLEAN,	"[CORE] 'FOLDER_TO_CLEAN' is requierd")
	local sData 			= ReadFile("MANIFEST")

	if (not sData) or #sData <= 0 then
		MsgC(Color(231, 76, 60), "\t[ERROR] Failed to read the MANIFEST of the relay core")
	end

	self:GetLibrary("MANIFEST"):SetManifest((sData and #sData > 0) and self:GetDependence("YAML").eval(sData) or {})
	local tRelay	= setmetatable({
		FOLDER_TO_CLEAN	= FOLDER_TO_CLEAN,
		_CACHE			= {
			MODULE_MANIFEST	= {},
		},
	}, {__index = CORE})

	MsgC(Color(52, 152, 219), "[INFO] The relay instance has been initialized")

	return tRelay
end

function CORE:RunCommand(sCommandLine)
	return self:GetLibrary("COMMAND"):RunCommand(self, sCommandLine)
end

function CORE:CacheManifest(sModuleName, tManifest)
	assert(IsString(sModuleName), "[CORE] 'sModuleName' must be a string")
	assert(IsTable(tManifest), "[CORE] 'tManifest' must be a table")

	local sSanitizedName = sModuleName:match("^%w+$"):upper()
	self._CACHE.MODULE_MANIFEST[sSanitizedName] = tManifest
end

function CORE:GetCachedManifest(sModuleName)
	assert(IsString(sModuleName), "[CORE] 'sModuleName' must be a string")

	local sSanitizedName = sModuleName:match("^%w+$"):upper()
	return self._CACHE.MODULE_MANIFEST[sSanitizedName]
end

function CORE:Destroy()
	local tManifestLib;
	local tManifest;
	local sSerialized;
	local bSerialize, sErr;
	local bWrite, sWriteErr;

	tManifestLib	= self:GetLibrary("MANIFEST")
	tManifest	= tManifestLib and tManifestLib.MANIFEST
	if not IsTable(tManifest) then
		MsgC(Color(231, 76, 60), "[ERROR] Cannot save MANIFEST: invalid table")
		goto cleanup
	end

	bSerialize, sErr	= xpcall(
		function()
			sSerialized = self:GetDependence("YAML").dump_yaml(tManifest)
		end,
		function(sE) return sE end
	)

	if not bSerialize or not IsString(sSerialized) or sSerialized:len() == 0 then
		MsgC(Color(231, 76, 60), "[ERROR] Failed to serialize MANIFEST: " .. tostring(sErr))
		goto cleanup
	end

	bWrite, sWriteErr	= xpcall(
		function()
			WriteFile("MANIFEST", sSerialized)
		end,
		function(sE) return sE end
	)

	if not bWrite then
		MsgC(Color(231, 76, 60), "[ERROR] Failed to write MANIFEST: " .. tostring(sWriteErr))
		goto cleanup
	end

	MsgC(Color(46, 204, 113), "[SUCCESS] MANIFEST saved successfully")

	::cleanup::
	setmetatable(self, nil)
end

function CORE:DeleteFiles(sModuleName)
	assert(IsString(sModuleName), "[CORE] 'sModuleName' must be a string")

	local tManifestEntry = self:GetLibrary("MANIFEST"):CheckManifestEntry(sModuleName)

	local sSanitizedName = sModuleName:match("^%w+$"):upper()
	local tManifest = self:GetCachedManifest(sSanitizedName) or self:LoadCache(sSanitizedName)

	if not IsTable(tManifest) then
		return MsgC(Color(231, 76, 60), "[ERROR] No cached manifest for module: " .. sSanitizedName)
	end

	local tRootFolders = { ["srcs"] = true, ["configuration"] = true }

	for _, sPath in ipairs(tManifest) do
		if not (IsString(sPath) and sPath:match("^%S+$")) then
			goto continue
		end

		local bOk, sErr	= pcall(DeletePath, sPath)
		bOk				= (not bOk) and
			MsgC(Color(231, 76, 60), "[ERROR] Failed to delete file: " .. sPath .. " (" .. tostring(sErr) .. ")")
			or MsgC(Color(46, 204, 113), "[SUCCESS] Deleted file: " .. sPath)

		::continue::
	end

	self:CleanEmptyFolders()
	self:GetLibrary("MANIFEST"):SetStatus(sModuleName, false)

	MsgC(Color(52, 152, 219), "[INFO] Files and empty folders deleted for module: " .. sModuleName)
end

function CORE:CleanEmptyFolders(sBasePath, tVisited)
	sBasePath	= IsString(sBasePath) and sBasePath or ""
	tVisited	= tVisited or {}

	local tStack	= { sBasePath }
	local tToDelete = {}

	while #tStack > 0 do
		local sDir = table.remove(tStack)

		if not tVisited[sDir] then
			tVisited[sDir] = "visited"

			local tFiles, tDirs = FilesFind(sDir)

			for _, subDir in ipairs(tDirs) do
				local sFullPath = (sDir == "" and subDir or sDir .. "/" .. subDir)
				tStack[#tStack + 1] = sFullPath
			end

			tToDelete[#tToDelete + 1] = sDir
		end
	end

	for i = #tToDelete, 1, -1 do
		local sDir = tToDelete[i]
		local tFiles, tDirs = FilesFind(sDir)
		if #tFiles == 0 and #tDirs == 0 and self.FOLDER_TO_CLEAN[sDir:match("^([^/]+)")] then
			local bOk, sErr = pcall(DeletePath, sDir)
			bOk = (not bOk) and
				MsgC(Color(231, 76, 60), "[ERROR] Failed to delete folder: " .. sDir .. " (" .. tostring(sErr) .. ")") or
				MsgC(Color(52, 152, 219), "[INFO] Deleted empty folder: " .. sDir)
			if bOk then
				tVisited[sDir] = "deleted"
			end
		end
	end
end

function CORE:GetManifestModule(sModuleName, fCallBack)
	return self:GetLibrary("NETWORK"):GetManifestModule(
		self:GetLibrary("MANIFEST"):GetLink(sModuleName),
		sModuleName,
		fCallBack
	)
end

function CORE:DownloadFile(sModuleName, sPath, fCallBack)
	return self:GetLibrary("NETWORK"):DownloadFile(
		self:GetLibrary("MANIFEST"):GetLink(sModuleName),
		sModuleName,
		sPath,
		fCallBack
	)
end

function CORE:SaveCache(sModuleName, sContent)
	assert(IsString(sModuleName),	"[CORE] 'sModuleName' must be a string")
	assert(IsString(sContent),		"[CORE] 'sContent' must be a string")

	WriteFile(".cache/" .. sModuleName:upper() .. "/MANIFEST", sContent)
end

function CORE:LoadCache(sModuleName)
	assert(IsString(sModuleName), "[CORE] 'sModuleName' must be a string")

	sModuleName	= sModuleName:upper()
	local sData	= ReadFile(".cache/" .. sModuleName .. "/MANIFEST")
	if not IsString(sData) or #sData == 0 then
		return MsgC(Color(231, 76, 60), "[ERROR] No manifest found for module: " .. sModuleName)
	end

	local tManifest	= self:GetLibrary("PARSING"):ParseManifest(sData)

	self:CacheManifest(sModuleName, tManifest)

	return tManifest
end