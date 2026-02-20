return function(tDestination, tSource)
	if tDestination == nil then
		return tSource
	end
	if tSource == nil then
		return tDestination
	end

	local iDestLen = #tDestination
	for i = 1, #tSource do
		iDestLen = iDestLen + 1
		tDestination[iDestLen] = tSource[i]
	end

	return tDestination
end