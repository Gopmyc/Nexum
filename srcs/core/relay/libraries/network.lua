function LIBRARY:GetManifestModule(sLink, sModuleName, fCallBack)
	assert(IsString(sLink),			"[LIBRARY] 'sLink' must be a string")
	assert(IsString(sModuleName),	"[LIBRARY] 'sModuleName' must be a string")
	assert(IsFunction(fCallBack),	"[LIBRARY] 'fCallBack' must be a function")

	FetchURL(sLink .. "/main/MANIFEST", function(sContent)
		if not IsString(sContent) or sContent:len() == 0 then
			return MsgC(Color(231, 76, 60), "[ERROR] Empty or invalid MANIFEST for module: " .. sModuleName)
		end

		xpcall(
			function() return fCallBack(sContent) end,
			function(sErr)
				MsgC(Color(231, 76, 60), "[ERROR] Failed to fetch the MANIFEST of module '" .. sModuleName .. "': " .. tostring(sErr))
			end
		)
	end)
end

function LIBRARY:DownloadFile(sLink, sModuleName, sPath, fCallBack)
	assert(IsString(sLink),								"[LIBRARY] 'sLink' must be a string")
	assert(IsString(sModuleName),						"[LIBRARY] 'sModuleName' must be a string")
	assert(IsString(sPath),								"[LIBRARY] 'sPath' must be a string")
	assert(fCallBack == nil or IsFunction(fCallBack),	"[LIBRARY] 'fCallBack' must be a function or nil")

	FetchURL(sLink .. "/main/" .. sPath, function(sContent)
		if not IsString(sContent) or sContent:len() == 0 then
			MsgC(Color(241, 196, 15), "[WARNING] " .. sPath .. " is empty or invalid for module: " .. sModuleName)
			sContent	= "";
		end

		local bSuccess, sErr = xpcall(
			function()
				WriteFile(sPath, sContent)
			end,
			function(sE) return sE end
		)

		if not bSuccess then
			MsgC(Color(231, 76, 60), "[ERROR] Failed to write file " .. sPath .. ": " .. tostring(sErr))
			return
		end

		if fCallBack then
			xpcall(
				function() fCallBack() end,
				function(sE) MsgC(Color(231, 76, 60), "[ERROR] Callback failed for " .. sPath .. ": " .. tostring(sE)) end
			)
		end
	end)
end