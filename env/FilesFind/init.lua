return (function()
	local _, lfs	= pcall(require, "lfs")

	local tBackends	=
	{
		lovr	= lovr and lovr.filesystem and
			{
				fList	= lovr.filesystem.getDirectoryItems,
				fFile	= lovr.filesystem.isFile,
				fDir	= lovr.filesystem.isDirectory
			},
		love	= love and love.filesystem and
			{
				fList	= love.filesystem.getDirectoryItems,
				fFile	= function(p) return love.filesystem.getInfo(p,"file")~=nil end,
				fDir	= function(p) return love.filesystem.getInfo(p,"directory")~=nil end
			},
		glua	= file and file.Find and
			{
				fList	= function(p)
					local tF,tD	= file.Find(p.."/*","GAME")
					local tR		= {}
					for _,v in ipairs(tF) do tR[#tR+1] = v end
					for _,v in ipairs(tD) do tR[#tR+1] = v end
					return tR
				end,
				fFile	= function(p) return file.Exists(p,"GAME") and not file.IsDir(p,"GAME") end,
				fDir	= file.IsDir
			},
		lfs		= lfs and
			{
				fList	= function(p)
					local tR	= {}
					for v in lfs.dir(p) do if v ~= "." and v ~= ".." then tR[#tR+1] = v end end
					return tR
				end,
				fFile	= function(p) return lfs.attributes(p,"mode") == "file" end,
				fDir	= function(p) return lfs.attributes(p,"mode") == "directory" end
			},
	}

	local tFS	= tBackends.lovr or tBackends.love or tBackends.glua or tBackends.lfs
	if not tFS then
		error("No suitable filesystem backend found")
	end

	return function(sPath)
		local tFiles, tDirs	= {}, {}
		for _,v in ipairs((tFS.fList(sPath)) or {}) do
			local sFull	= sPath .. "/" .. v
			table.insert(tFS.fFile(sFull) and tFiles or tFS.fDir(sFull) and tDirs, v)
		end
		return tFiles, tDirs
	end
end)()