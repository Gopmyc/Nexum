return function(sPath)
	local tFiles, tDirs = {}, {}

	for _, sItem in ipairs(lovr.filesystem.getDirectoryItems(sPath)) do
		local sFull = sPath .. "/" .. sItem

		table.insert(
			lovr.filesystem.isFile(sFull) and tFiles or
			lovr.filesystem.isDirectory(sFull) and tDirs
		, sItem)
	end

	return tFiles, tDirs
end