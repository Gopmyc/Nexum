function LIBRARY:Run(tRelay, sArgs)
	if not IsString(sArgs) or sArgs:len() == 0 then
		return MsgC(Color(231, 76, 60), "[ERROR] Module name required for download")
	end

	local sModuleName = sArgs:match("^%w+$")
	if not sModuleName then
		return MsgC(Color(231, 76, 60), "[ERROR] Invalid module name: " .. sArgs)
	end

	tRelay:GetManifestModule(sModuleName, function(sContent)
		local tManifest = tRelay:GetLibrary("PARSING"):ParseManifest(sContent)
		tRelay:CacheManifest(sModuleName, tManifest)

		local nTotalFiles = #tManifest
		local nDownloaded = 0

		for _, sFilePath in ipairs(tManifest) do
			MsgC(Color(52, 152, 219), "[INFO] Downloading: " .. sFilePath .. " ...")
			tRelay:DownloadFile(
				sModuleName,
				sFilePath,
				function()
					nDownloaded = nDownloaded + 1
					MsgC(
						Color(46, 204, 113),
						string.format("[SUCCESS] Downloaded: %s (%d/%d files)", sFilePath, nDownloaded, nTotalFiles)
					)

					if nDownloaded == nTotalFiles then
						tRelay:GetLibrary("MANIFEST"):SetStatus(sModuleName, true)
						tRelay:SaveCache(sModuleName, sContent)
						MsgC(Color(52, 152, 219), "[INFO] All files downloaded for module: " .. sModuleName)
					end
				end
			)
		end
	end)
end