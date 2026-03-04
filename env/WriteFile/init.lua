return (function()
	local tBackends =
	{
		lovr = (lovr and lovr.filesystem) and function(sPath, sContent)
			local sDir = sPath:match("(.+)/[^/]+$")
			if sDir then
				lovr.filesystem.createDirectory(sDir)
			end
			return lovr.filesystem.write(sPath, sContent)
		end,

		love = (love and love.filesystem) and function(sPath, sContent)
			local sDir = sPath:match("(.+)/[^/]+$")
			if sDir then
				love.filesystem.createDirectory(sDir)
			end
			return love.filesystem.write(sPath, sContent)
		end,

		glua = (file and file.Write) and function(sPath, sContent)
			local sDir = sPath:match("(.+)/[^/]+$")
			if sDir then
				local tParts = {}
				for sPart in string.gmatch(sDir, "[^/]+") do
					tParts[#tParts+1] = sPart
					file.CreateDir(table.concat(tParts, "/"))
				end
			end
			file.Write(sPath, sContent)
			return true
		end,

		lua = function(sPath, sContent)
			local sDir = sPath:match("(.+)/[^/]+$")
			if sDir then
				local sCur = ""
				for sPart in sDir:gmatch("[^/]+") do
					sCur = (sCur == "" and sPart) or (sCur .. "/" .. sPart)
					os.execute('mkdir "' .. sCur .. '" 2>nul')
				end
			end
			local fFile = io.open(sPath, "w")
			if not fFile then return nil end
			fFile:write(sContent)
			fFile:close()
			return true
		end,
	}

	local fWrite = tBackends.lovr or tBackends.love or tBackends.glua or tBackends.lua

	return function(sPath, sContent)
		return fWrite(sPath, sContent)
	end
end)()