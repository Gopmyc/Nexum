return (function()
	local _, lfs	= pcall(require, "lfs")
	local tBackends	=
		{
			lovr	= lovr and lovr.filesystem and function(p) return lovr.filesystem.isFile(p) end,
			love	= love and love.filesystem and function(p) return love.filesystem.getInfo(p,"file")~=nil end,
			glua	= file and file.Exists and function(p) return file.Exists(p,"GAME") and not file.IsDir(p,"GAME") end,
			lfs		= lfs and function(p) return lfs.attributes(p,"mode")=="file" end,
		}

	local fIsFile	= tBackends.lovr or tBackends.love or tBackends.glua or tBackends.lfs
	if not fIsFile then
		error("No suitable filesystem backend found")
	end

	return function(sPath)
		return fIsFile(sPath) or false
	end
end)()