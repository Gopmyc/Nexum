return function(...)
	local tArgs			= {...}
	local tCurrentColor	= {255,255,255}
	local sOutput		= ""

	for _, Arg in ipairs(tArgs) do
		if IsTable(Arg) then
			local iR, iG, iB	= Arg[1] or Arg.R or Arg.r, Arg[2] or Arg.G or Arg.g, Arg[3] or Arg.B or Arg.b
			if not (IsNumber(iR) and IsNumber(iG) and IsNumber(iB)) then
				MsgC(Color(255, 0, 0), "[ERROR] Invalid color table passed to MsgC.")
				goto continue
			end
			if not IsString(Arg.__hex) then Arg=Color(iR, iG, iB); end

			tCurrentColor	= Arg
		else
			sOutput	= sOutput .. string.format(
				"\27[38;2;%d;%d;%dm%s\27[0m",
				tCurrentColor[1],
				tCurrentColor[2],
				tCurrentColor[3],
				tostring(Arg)
			)
		end

		::continue::
	end

	print(sOutput)
end