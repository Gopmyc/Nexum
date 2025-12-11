function LIBRARY:DeepRawCopy(tTable, tSeen)
    tSeen			= tSeen or {}
    if tSeen[tTable] then return tSeen[tTable] end

    local tCopy		= {}
    tSeen[tTable]	= tCopy

    for Key, Value in pairs(tTable) do
    	if istable(Value) then
    		tCopy[Key] = self:DeepRawCopy(Value, tSeen)
    	else
    		tCopy[Key] = Value
    	end
    end

    return tCopy
end