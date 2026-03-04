return (function()
	local tBackends =
	{
		lovr = (lovr and lovr.filesystem) and function(sPath)
			return lovr.filesystem.remove(sPath)
		end,

		love = (love and love.filesystem) and function(sPath)
			return love.filesystem.remove(sPath)
		end,

		glua = (file and file.Exists and file.Delete) and function(sPath)
			return file.Delete(sPath)
		end,

		lua = function(sPath)
			local fFile = io.open(sPath, "r")
			if fFile then
				fFile:close()
				local ok, err = os.remove(sPath)
				return ok or false, err
			end
			return false
		end,
	}

	local fDelete = tBackends.lovr or tBackends.love or tBackends.glua or tBackends.lua

	return function(sPath)
		assert(IsString(sPath), "[DELETE] 'sPath' must be a string")
		return fDelete(sPath)
	end
end)()