function LIBRARY:Run(tRelay, sArgs)
	if not IsString(sArgs) or sArgs:len() == 0 then
		return MsgC(Color(231, 76, 60), "[ERROR] Module name required for deletion")
	end

	local sModuleName = sArgs:match("^%w+$")
	if not sModuleName then
		return MsgC(Color(231, 76, 60), "[ERROR] Invalid module name: " .. sArgs)
	end

	tRelay:DeleteFiles(sModuleName)
end