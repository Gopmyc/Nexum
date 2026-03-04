function LIBRARY:Run(tRelay, sArgs)
	local tManifest = tRelay:GetLibrary("MANIFEST").MANIFEST

	local sNameCol, sStatusCol = "LIBRARY", "STATUS"
	local nNameWidth, nStatusWidth = 20, 15

	MsgC(
		Color(255, 255, 255),
		string.format("%-"..nNameWidth.."s", sNameCol),
		Color(255, 255, 255),
		" | ",
		Color(255, 255, 255),
		string.format("%-"..nStatusWidth.."s", sStatusCol)
	)
	MsgC(
		Color(127, 140, 141),
		string.rep("-", nNameWidth),
		Color(255, 255, 255),
		"-+-",
		Color(127, 140, 141),
		string.rep("-", nStatusWidth)
	)

	for sName, tData in pairs(tManifest) do
		local bInstalled = tData.INSTALLED
		local sStatus = bInstalled and "INSTALLED" or "NOT INSTALLED"
		local cStatus = bInstalled and Color(46, 204, 113) or Color(231, 76, 60)

		MsgC(
			Color(52, 152, 219),
			string.format("%-"..nNameWidth.."s", sName),
			Color(255, 255, 255),
			" | ",
			cStatus,
			sStatus
		)
	end
end