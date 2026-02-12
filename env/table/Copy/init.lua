return function(tTable, bDeep, tSeen)
	tSeen = (bDeep and tSeen) or nil
	if bDeep and IsTable(tSeen) and tSeen[tTable] then return tSeen[tTable] end

	local tCopy = {}
	if bDeep then
		tSeen			= tSeen or {}
		tSeen[tTable]	= tCopy
	end

	for kKey, vValue in pairs(tTable) do
		tCopy[kKey] = (bDeep and IsTable(vValue) and table.Copy(vValue, true, tSeen)) or vValue
	end

	return tCopy
end