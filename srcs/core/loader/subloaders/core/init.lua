SUBLOADER.__ENV	= {
	ACCESS_POINT	= "CORE",
	CONTENT			=
	{
		CORE	= (function()
			local _			= {}
			
			_.__index		= _

			return _
		end)()
	},
}

function SUBLOADER:Initialize(tContent)
	assert(istable(tContent),			"[OBJECTS SUB-LOADER] Content must be a table")
	assert(isfunction(self.GetLoader),	"[OBJECTS SUB-LOADER] Loader access method is missing")

	self.__ENV.CONTENT.CORE.__LIBRARIES	= self:GetLoader():GetLibrariesBase("libraries", self.__ENV.CONTENT.CORE)
	self.__BUFFER						= {}
		
	for sID, tFile in ipairs(tContent) do -- TODO : Make a methode in SUBLOADER_BASE to check structure intergrity for each file in config and throw a error message ilf struct is invalide, check if has a PATH, KEY, ARGS, ect...
		if not (istable(tFile) and isstring(tFile.path) and istable(tFile.sides) and isstring(tFile.key) and istable(tFile.args)) then
			MsgC(self:GetLoader():GetConfig().DEBUG.COLORS.ERROR, "[OBJECTS SUB-LOADER] Invalid file entry at index '" ..sID.. "' for " .. self:GetID())
			goto continue
		end

		self.__BUFFER[tFile.key]	= self:LoadFile(tFile)

		::continue::
	end

	self.__Initialized					= true

	return self.__BUFFER
end

function SUBLOADER:LoadFile(tFile, fChunk)
	assert(istable(tFile),			"[OBJECTS SUB-LOADER] File entry must be a table")
	assert(isstring(tFile.path),	"[OBJECTS SUB-LOADER] File entry 'path' must be a string")
	assert(istable(tFile.sides),	"[OBJECTS SUB-LOADER] File entry 'sides' must be a table")
	assert(isstring(tFile.key),		"[OBJECTS SUB-LOADER] File entry 'key' must be a string")
	assert(istable(tFile.args),		"[OBJECTS SUB-LOADER] File entry 'args' must be a table")

	local bIsReload		= isfunction(fChunk)
	local bShared		= tFile.sides.client
	local tDependencies	= self:GetLoader():GetLibrary("RESSOURCES"):GetDependencies(tFile.args, tFile.sides, self)

	if not istable(tDependencies) and (#tFile.args > 0) then 
		return MsgC(self:GetLoader():GetConfig().DEBUG.COLORS.ERROR, "[OBJECTS SUB-LOADER] The dependencies for the file '" ..tFile.key.. "' could not be resolved.\n")
	end

	local _				= self:GetLoader():GetLibrary("RESSOURCES"):IncludeFiles(bIsReload and fChunk or tFile.path, tFile.sides, tDependencies, self:GetEnv(), tFile.is_binary)

	MsgC(self:GetLoader():GetConfig().DEBUG.COLORS.SUCCESS, "The file '" .. tFile.key .. "' was " .. (bIsReload and "reload" or "loaded") .." successfully for " .. self:GetID() .. "\n")

	return _, bShared
end