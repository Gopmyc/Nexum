return function(iR, iG, iB)
	return {
		[1]		= iR,
		[2]		= iG,
		[3]		= iB,
		[4]		= 255,
		__hex	= string.format("#%02X%02X%02X", iR, iG, iB),
	}
end