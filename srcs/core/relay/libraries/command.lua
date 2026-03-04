function LIBRARY:RunCommand(tRelay, sCommandLine)
	assert(IsString(sCommandLine), "[LIBRARY] 'sCommandLine' must be a string")

	local sCommand, sArgs = sCommandLine:match("^/(%S+)%s*(.*)")
	if not IsString(sCommand) then
		return MsgC(Color(231, 76, 60), "[ERROR] Invalid command syntax: " .. sCommandLine)
	end

	local tLibrary = tRelay:GetLibrary("COMMANDS/" .. sCommand:upper())
	if not tLibrary then
		return MsgC(Color(231, 76, 60), "[ERROR] Command not found: " .. sCommand)
	end

	pcall(
		function()
			return tLibrary:Run(tRelay, sArgs)
		end,
		function(sErr)
			return MsgC(Color(231, 76, 60), "[ERROR] Command execution error: " .. tostring(sErr))
		end
	)
end