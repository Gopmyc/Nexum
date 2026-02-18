-- Do you think it's ugly ? Me too
local MergeBool				= function(a, b) if a == nil then return b end; if b == nil then return a end; return a and b end
local MergeFunctionTable	= function(dst, src) for k, v in pairs(src) do dst[k] = MergeBool(dst[k], v); end end
local MergeLibrary			= function(dstLib, srcLib)
	if dstLib == nil then if srcLib == "full" then return "full" end; return table.Copy(srcLib); end
	if dstLib == "full" and srcLib == "full" then return "full" end
	if dstLib == "full" and type(srcLib) == "table" then return table.Copy(srcLib) end
	if type(dstLib) == "table" and srcLib == "full" then return table.Copy(dstLib) end

	if type(dstLib) == "table" and type(srcLib) == "table" then
		local t = {}
		for fn, allow in pairs(dstLib) do if srcLib[fn] ~= nil then t[fn] = allow and srcLib[fn]; end end
		return t
	end

	return nil
end
----------

function LIBRARY:ApplyConstants(tEnv, tPolicy)
	for sKey, vValue in pairs(tPolicy.constants or {}) do
		tEnv[sKey] = vValue
	end

	return tEnv
end

function LIBRARY:ApplyFunctions(tEnv, tPolicy)
	for sKey, bAllow in pairs(tPolicy.functions or {}) do
		if bAllow then
			tEnv[sKey] = _G[sKey]
		end
	end

	return tEnv
end

function LIBRARY:ApplyLibraries(tEnv, tPolicy)
	for sLib, vScope in pairs(tPolicy.libraries or {}) do
		if vScope == "full" then
			tEnv[sLib] = _G[sLib]
		elseif IsTable(vScope) then
			local tLib = {}
			for sFn, bAllow in pairs(vScope) do
				if bAllow and _G[sLib] then
					tLib[sFn] = _G[sLib][sFn]
				end
			end
			tEnv[sLib] = tLib
		end
	end

	return tEnv
end

function LIBRARY:ApplyNamespaces(tEnv, tPolicy)
	for sName, tCfg in pairs(tPolicy.namespaces or {}) do
		if tCfg.exposed then
			tEnv[sName]	= tEnv[sName] or {}
		end
	end

	return tEnv
end

function LIBRARY:ApplyFallback(tEnv, tPolicy)
	local tFallback = tPolicy.fallback
	if not tFallback then return tEnv end

	local tMt = getmetatable(tEnv)
	if not IsTable(tMt) then
		tMt = {}
	end

	if not tFallback.global then
		tMt.__index = function(_, sKey)

			if tFallback.error_on_missing then
				local info = debug.getinfo(2, "Slfn")

				local sSource	= info and info.short_src or "unknown"
				local iLine		= info and info.currentline or 0
				local sName		= info and info.name or "?"
				local sWhat		= info and info.namewhat or "chunk"

				MsgC(
					Color(241,196,15),
					"[SANDBOX WARNING] Access denied\n",
					Color(200,200,200),
					"  Key     : ", tostring(sKey), "\n",
					"  File    : ", tostring(sSource), "\n",
					"  Line    : ", tostring(iLine), "\n",
					"  Function: ", tostring(sName), " (", tostring(sWhat), ")"
				)
			end

			return nil
		end
	else
		tMt.__index = _G
	end

	setmetatable(tEnv, tMt)

	return tEnv
end

function LIBRARY:InitAccessPoint(tEnv, sAccessPoint, sFileSource, tFileArgs, tCapabilities)
	tEnv[sAccessPoint]					= tEnv[sAccessPoint] or {}

	tEnv[sAccessPoint].GetConfig		= function()
		return tCapabilities
	end

	tEnv[sAccessPoint].GetDependence	= function(_, sKey)
		return tFileArgs and tFileArgs[sKey]
	end

	tEnv[sAccessPoint].__PATH			= sFileSource:match("^(.*[/\\])[^/\\]+%.lua$") or nil
	tEnv[sAccessPoint].__NAME			= sFileSource:match("([^/\\]+)%.lua$") or "compiled-chunk"

	return tEnv
end

function LIBRARY:LoadInternalLibraries(tEnv, sAccessPoint, sPath)
	local tLib			= tEnv[sAccessPoint].LIBRARIES
	local sID			= tEnv[sAccessPoint].__PATH .. tEnv[sAccessPoint].__NAME or "unknown"
	local tParentEnv	= tEnv.__ENV
	
	if not (IsTable(tLib) and IsString(tLib.PATH) and IsFunction(tLib.Load)) then
		MsgC(Color(241, 196, 15), "[WARNING][ENV-RESSOURCES] Cannot load internal libraries for '" .. sID .. "' : invalid LIBRARIES access point")
		return tEnv
	end

	local sBasePath	= sPath or tEnv[sAccessPoint].__PATH or ""
	sBasePath		= (sBasePath:find("/server/$") or sBasePath:find("/client/$")) and sBasePath:match("^(.*[/\\])[^/\\]+[/\\]$") or sBasePath

	tLib:Load(sBasePath .. tLib.PATH, tParentEnv)

	return tEnv
end

function LIBRARY:BuildPolicy(tEnvProfile)
	if not (IsTable(self.SAFE_GLOBALS) and IsTable(tEnvProfile)) then
		return MsgC(Color(231, 76, 60), "[ERROR] " .. (not IsTable(self.SAFE_GLOBALS) and "'SAFE_GLOBALS' not set" or "'tEnvProfile' is not a table"))
	end

	local tPolicy	= {
		constants	= {},
		functions	= {},
		libraries	= {},
		namespaces	= {},
		fallback	= nil,
	}

	for _, profileName in ipairs(tEnvProfile) do
		local tProfile	= self.SAFE_GLOBALS[profileName]
		if not IsTable(tProfile) then
			goto continue
		end

		for k, v in pairs(tProfile.constants or {}) do
			if tPolicy.constants[k] == nil then
				tPolicy.constants[k]	= v
			end
		end

		MergeFunctionTable(tPolicy.functions, tProfile.functions or {})

		for lib, cfg in pairs(tProfile.libraries or {}) do
			tPolicy.libraries[lib]	= MergeLibrary(tPolicy.libraries[lib], cfg)
		end

		for name, ns in pairs(tProfile.namespaces or {}) do
			tPolicy.namespaces[name]			= tPolicy.namespaces[name] or {}
			tPolicy.namespaces[name].exposed	= MergeBool(tPolicy.namespaces[name].exposed, ns.exposed)
		end

		if tProfile.fallback then
			if not tPolicy.fallback then
				tPolicy.fallback	= table.Copy(tProfile.fallback)
			else
				tPolicy.fallback.global				= MergeBool(tPolicy.fallback.global, tProfile.fallback.global)
				tPolicy.fallback.error_on_missing	= MergeBool(tPolicy.fallback.error_on_missing, tProfile.fallback.error_on_missing)
			end
		end

		::continue::
	end

	return tPolicy
end

function LIBRARY:BuildEnvironment(sFileSource, tSandEnv, sAccessPoint, tFileArgs, tCapabilities, tEnvProfile, bLoadLibraries)
	local tEnv		= table.Copy(tSandEnv, true)

	if not IsTable(tEnvProfile) then
		error("[ENV] Root script without env_profile : " .. tostring(sFileSource))
	end

	local tPolicy	= self:BuildPolicy(tEnvProfile)
	if not IsTable(tPolicy) then
		error("[ENV] Policy build failed for : " .. tostring(sFileSource))
	end

	tEnv.__ENV	= tEnv

	self:ApplyConstants(tEnv, tPolicy)
	self:ApplyFunctions(tEnv, tPolicy)
	self:ApplyLibraries(tEnv, tPolicy)
	self:ApplyNamespaces(tEnv, tPolicy)
	self:ApplyFallback(tEnv, tPolicy)
	self:InitAccessPoint(tEnv, sAccessPoint, sFileSource, tFileArgs, tCapabilities)
	if bLoadLibraries then self:LoadInternalLibraries(tEnv, sAccessPoint) end

	return tEnv
end

function LIBRARY:SetEnvSpecification(tEnv)
	self.SAFE_GLOBALS	= tEnv
end