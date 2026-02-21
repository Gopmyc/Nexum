return (function()
	local tBackends	=
	{
		lovr	= lovr and lovr.filesystem and
			{
				fRead	= function(p) return lovr.filesystem.read(p) end,
				fErr	= function(s) print("[ENV-LOADER] "..s) end,
				fLoad	= function(c,p,e)
					local f,err = load(c,p,"t",e)
					return f,err
				end,
			},
		love	= love and love.filesystem and
			{
				fRead	= function(p) return love.filesystem.read(p) end,
				fErr	= function(s) print("[ENV-LOADER] "..s) end,
				fLoad	= function(c,p,e)
					local f,err = load(c,p,"t",e)
					return f,err
				end,
			},
		glua	= file and file.Read and
			{
				fRead	= function(p) return file.Read(p,"GAME") end,
				fErr	= function(s) MsgC(Color(231,76,60), s.."\n") end,
				fLoad	= function(c,p,e)
					local f,err = CompileString(c,p,false)
					if type(f)=="string" then return nil,err end
					setfenv(f,e)
					return f
				end,
			},
		lua		=
			{
				fRead	= function(p)
					local f = io.open(p,"r")
					if not f then return nil end
					local c = f:read("*a")
					f:close()
					return c
				end,
				fErr	= function(s) print("[ENV-LOADER] "..s) end,
				fLoad	= function(c,p,e)
					local f,err = load(c,p,"t",e)
					return f,err
				end
			},
	}

	local tFS	= tBackends.lovr or tBackends.love or tBackends.glua or tBackends.lua
	return function(sPath,tEnvironment)
		local sCode	= tFS and (tFS.fRead(sPath) or tFS.fRead(sPath.."/init.lua"))
		if not sCode then
			return tFS.fErr("Cannot read file: "..sPath)
		end

		local fChunk, sErr = tFS.fLoad(sCode,sPath,tEnvironment)
		if not fChunk then
			return tFS.fErr("Compile error: "..tostring(sErr).." in file: "..sPath)
		end

		return fChunk
	end
end)()