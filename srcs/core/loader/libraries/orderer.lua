LIBRARY.SORTED	= {}
LIBRARY.VISITED	= {}
LIBRARY.FILEMAP	= {}

function LIBRARY:BuildGlobalOrder(tContent)
	assert(IsTable(tContent), "Expected a table of file data")

	self.SORTED = {}
	for sFileName, tFile in pairs(tContent) do
		self.FILEMAP[sFileName] = tFile
		self.VISITED[sFileName] = false
	end

	for sFileName, tFile in pairs(tContent) do
		if not self.VISITED[sFileName] then
			self:VisitFileDependencies(sFileName, tFile)
		end
	end

	self.FILEMAP = nil
	self.VISITED = nil

	return self.SORTED
end

function LIBRARY:VisitFileDependencies(sFileName, tFile)
	assert(IsString(sFileName),	"Expected a file name string")
	assert(IsTable(tFile),		"Expected a file data table")

	local vVisited  = self.VISITED[sFileName]

	if vVisited == true then return end
	if vVisited == "temp" then
		return MsgC(Color(231, 76, 60), "Circular dependency detected: " .. sFileName)
	end

	self.VISITED[sFileName] = "temp"

	for iIndex, sDepKey in pairs(tFile.DEPENDENCIES.INTERNAL) do
		sDepKey	= string.upper(sDepKey)
		local tDepFile = self.FILEMAP[sDepKey]
		if not tDepFile then
			return MsgC(Color(231, 76, 60), "Missing dependency: " .. sFileName .. " depends on " .. sDepKey)
		end
		self:VisitFileDependencies(sDepKey, tDepFile)
	end

	self.VISITED[sFileName] = true
	tFile.KEY				= sFileName
	table.insert(self.SORTED, tFile)
end