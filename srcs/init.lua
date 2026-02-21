--
-- ┌─────────────┐
-- │ ENTRY POINT │
-- └─────────────┘
--

if not (lovr or love or AddCSLuaFile or pcall(require, "lfs")) then
	error("Nexum requires a compatible environment to run.\nPlease ensure you are running this in a supported environment.\nRefer to the documentation for more details.")
end

local function SetGlobalByPath(sPath, Value)
	local Last;
	local t	= _G
	for sPart in sPath:gmatch("[^%.]+") do
		if Last then
			t[Last]	= (type(t[Last]) ~= "table") and {} or t[Last]
			t		= t[Last]
		end
		Last	= sPart
	end
	t[Last]	= Value
end

local CONFIGURATION	= require("configuration/nexum")

local bSuccess, Content;
for iID, tGlobal in ipairs(CONFIGURATION.ENVIRONMENT) do
	if tGlobal.KEY and tGlobal.PATH then
		bSuccess, Content	= pcall(require, tGlobal.PATH)
		SetGlobalByPath(bSuccess and tGlobal.KEY or false, bSuccess and Content)
	end
end

for sKey, sPath in pairs(CONFIGURATION.LIBRARIES) do
	bSuccess, CONFIGURATION.LIBRARIES[sKey]	= pcall(require, sPath)
end

if not (SERVER or CLIENT) then
	MsgC(Color(52, 152, 219), "\n[NEXUM] No valid environment detected, set to default environment: ", Color(46, 204, 113), CONFIGURATION.DEFAULT_ENVIRONMENT)
end
SERVER	= ((not (SERVER or CLIENT)) and (CONFIGURATION.DEFAULT_ENVIRONMENT == "SERVER") or SERVER)
CLIENT	= ((not (SERVER or CLIENT)) and (CONFIGURATION.DEFAULT_ENVIRONMENT == "CLIENT") or CLIENT)

return require("srcs/core/loader/init"):Initialize(CONFIGURATION.CONFIGURATION_PATH, CONFIGURATION.LIBRARIES)