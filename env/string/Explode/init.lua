return function(sSeparator, sString, bWithPattern)
	if sSeparator == "" then return string.Totable(sString) end
	if bWithPattern == nil then bWithPattern = false end

	local tResult			= {}
	local nCurrentPos		= 1

	for nIndex = 1, string.len(sString) do
		local nStartPos, nEndPos	= string.find(sString, sSeparator, nCurrentPos, not bWithPattern)

		if not nStartPos then break end
		tResult[nIndex]				= string.sub(sString, nCurrentPos, nStartPos - 1)
		nCurrentPos					= nEndPos + 1
	end

	tResult[#tResult + 1]	= string.sub(sString, nCurrentPos)

	return tResult
end