return (function()
	local o_, lfs	= pcall(require, "lfs")
	local tBackends	=
		{
			lovr	= lovr and lovr.filesystem and function(p) return lovr.filesystem.isDirectory(p) end,
			love	= love and love.filesystem and function(p) return love.filesystem.getInfo(p,"directory")~=nil end,
			glua	= file and file.IsDir and function(p) return file.IsDir(p,"GAME") end,
			lfs		= lfs and function(p) return lfs.attributes(p,"mode")=="directory" end,
		}

	local fIsDir	= tBackends.lovr or tBackends.love or tBackends.glua or tBackends.lfs
	if not fIsDir then
		error("No suitable filesystem backend found")
	end

	return function(sPath)
		return fIsDir(sPath) or false
	end
end)()