function LIBRARY:Initialize(tEvents)
	local tEvents = tEvents or {}

	return setmetatable(
		{
			__EVENTS = setmetatable(
				{},
				{
					__index = function(_, kKey)
						return tEvents[kKey]
					end,
					__newindex = function()
						error("__EVENTS is read-only", 2)
					end,
					__pairs = function()
						return pairs(tEvents)
					end,
					__len = function()
						local iCount = 0
						for _, _ in pairs(tEvents) do
							iCount = iCount + 1
						end
						return iCount
					end
				}
			),
		},
		{
			__mode		= "kv",
		}
	)
end

function LIBRARY:Call(tServer, tEvent)
	return xpcall(
		function()
			return self.__EVENTS[tEvent.sType](tServer, tEvent)
		end,
		function(sErr)
			MsgC(Color(255, 0, 0), "[ERROR] Event error : " .. tostring(sErr))
		end
	)
end
	
function LIBRARY:BuildEvent(sType, tPeer, Data, iChannel)
	assert(isstring(sType),	"BuildEvent : Type event must be a string")
	assert(istable(tPeer),	"BuildEvent : Peer event must be a table")
		
	return {
		sType		= sType,
		tPeer		= tPeer,
		tData		= Data,
		iChannel	= iChannel,
	}
end

local EVENTS_DEFAULT	= {
	["connect"]		=	function(tServer, tEvent)
		local sID			=	tostring(tEvent.tPeer:connect_id())

		MsgC(Color(52, 152, 219), "Client [ID : " .. sID .. "] connected : " .. tostring(tEvent.tPeer))
	
		tServer.CLIENTS[sID]	=	{tEvent.tPeer, os.time()}
	end,
			
	["receive"]		=	function(tServer, tEvent) -- tData : {sID, ...}
		local sID			=	tostring(tEvent.tPeer:connect_id())
		local tPeer			=	tServer:IsValidClient(sID)

		if not tPeer then
			return MsgC(Color(231, 76, 60), "Unregister Client [ID : " .. sID .. "] attempted to send message : " .. tostring(tEvent.tData))
		end
	
		---- pcall all steps ----
		-- // TODO : Decrypt data...
		-- // TODO : Uncompress data...
		-- // TODO : JSON to Table...
		
		if not tServer:IsValidMessage(tData[1]) then
			return MsgC(Color(231, 76, 60), "Client [ID : " .. sID .. "] attempted to send an undeclared message : " .. tostring(tData[1]))
		end
	
		tServer.CLIENTS[sID][2]	=	os.time()
		tServer.HOOKS:CallHook(tData[1], tData[2])
	end,
			
	["disconnect"]	=	function(tServer, tEvent)
		local sID			=	tostring(tEvent.tPeer:connect_id())
	
		if not tServer:IsValidClient(sID) then return end
		MsgC(Color(52, 152, 219), "Client [ID : " .. sID .. "] disconnected : " .. tostring(tEvent.tPeer))
	
		tServer.CLIENTS[sID]	=	nil
	end,
			
	["send"]		=	function(tServer, tEvent)
		local sID			=	tostring(tEvent.tPeer:connect_id())
		local tPeer			=	tServer:IsValidClient(sID)
		local tData			=	tEvent.tData
		local sFlag			=	tData.flag

		if not tPeer then
			return MsgC(Color(231, 76, 60), "Attempted to send message to unregister Client [ID : " .. sID .. "]  : " . .tostring(tPeer))
		end

		if not istable(tData) then
			return MsgC(Color(231, 76, 60), "Attempt to send data type other than table"..type(tData))
		end
		
		tData	=	{tData.id, tData.packet}
				
		---- pcall all steps ----
		-- // TODO : Table data to JSON...
		-- // TODO : Crypt data...
		-- // TODO : Compress data..
		
		tPeer:send(tData, tEvent.iChannel, sFlag or "reliable")
	end,
}