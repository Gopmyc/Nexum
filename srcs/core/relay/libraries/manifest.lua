LIBRARY.MANIFEST	= ""

function LIBRARY:SetManifest(tManifest)
	assert(IsTable(tManifest), "Invalid Manifest")

	if IsTable(self.MANIFEST) then
		return MsgC(Color(231, 76, 60), "Error MANIFEST is alredy registered")
	end

	self.MANIFEST	= tManifest
end

function LIBRARY:CheckManifestEntry(sModuleName)
	assert(IsString(sModuleName),	"[LIBRARY] 'sModuleName' must be a string")

	if not IsTable(self.MANIFEST) then
		return MsgC(Color(231, 76, 60), "Error MANIFEST is not registered")
	end

	local sSanitizedName = sModuleName:match("^%w+$"):upper()
	if not sSanitizedName then
		return MsgC(Color(231, 76, 60), "[ERROR] Invalid module name: " .. tostring(sModuleName))
	end

	if not (
		IsTable(self.MANIFEST[sSanitizedName])
		and IsString(self.MANIFEST[sSanitizedName].LINK)
		and IsBool(self.MANIFEST[sSanitizedName].INSTALLED)
	) then
		return MsgC(Color(231, 76, 60), "[ERROR] Invalid module name: " .. tostring(sModuleName))
	end

	return self.MANIFEST[sSanitizedName]
end

function LIBRARY:GetLink(sModuleName)
	assert(IsString(sModuleName),	"[LIBRARY] 'sModuleName' must be a string")

	local sSanitizedName = sModuleName:match("^%w+$"):upper()
	local tManifestEntry = self:CheckManifestEntry(sModuleName)

	local sLink = tManifestEntry.LINK
	if not IsString(sLink) or sLink:len() == 0 then
		return MsgC(Color(231, 76, 60), "[ERROR] No link found for module: " .. sModuleName)
	end

	return sLink
end

function LIBRARY:SetStatus(sModuleName, bStatus)
	assert(IsString(sModuleName),	"[LIBRARY] 'sModuleName' must be a string")
	assert(IsBool(bStatus),			"[LIBRARY] 'bStatus' must be a bool")

	local tManifestEntry = self:CheckManifestEntry(sModuleName)
	tManifestEntry.INSTALLED = bStatus
end