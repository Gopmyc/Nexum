function LIBRARY:Call(tServer, tEvent)
	local sID		= tostring(tEvent.udPeer:connect_id())
	local tPeer		= tServer:IsValidClient(sID)
	
	if not tPeer then
		return MsgC(Color(231, 76, 60), "Unregister Client [ID : " .. sID .. "] attempted to send message : " .. tostring(tEvent.Data))
	end

	local sPacketID, Content	= tServer.CODEC:Decode(tEvent.Data)
	
	if not tServer:IsValidMessage(sPacketID) then
		return tServer.EVENTS:Call(tServer, {
			type	= "unhandled",
			peer	= tEvent.udPeer,
			data	= { sPacketID, Content },
			channel	= nil,
			flag	= nil,
		})
	end

	tServer.CLIENTS[sID][2]	=	os.time()
	tServer.HOOKS:CallHook(sPacketID, Content)
end