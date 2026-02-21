return (function()
	local tBackends	=
	{
		lovr	= lovr and lovr.filesystem and function(p) return lovr.filesystem.read(p) end,
		love	= love and love.filesystem and function(p) return love.filesystem.read(p) end,
		glua	= file and file.Read and function(p) return file.Read(p,"GAME") end,
		lua		= function(p)
			local f = io.open(p,"r")
			if not f then return nil end
			local c = f:read("*a")
			f:close()
			return c
		end
	}

	local fRead	= tBackends.lovr or tBackends.love or tBackends.glua or tBackends.lua

	return function(sPath)
		return fRead(sPath) or fRead(sPath.."/init.lua") or nil
	end
end)()