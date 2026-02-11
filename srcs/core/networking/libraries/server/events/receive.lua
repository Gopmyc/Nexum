function LIBRARY:Call(tServer, tEvent)
	local sID		= tostring(tEvent.udPeer:connect_id())
	local udPeer	= tServer:IsValidClient(sID)
	
	if not udPeer then
		return MsgC(Color(231, 76, 60), "Unregister Client [ID : " .. sID .. "] attempted to send message : " .. tostring(tEvent.Data))
	end

	local sPacketID, Content	= tServer.CODEC:Decode(tEvent.Data)
	
	if not tServer:IsValidMessage(sPacketID) then
		return MsgC(Color(231, 76, 60), "Client [ID : " .. sID .. "] attempted to send an undeclared message : " .. tostring(sPacketID))
	end

	tServer.CLIENTS[sID][2]	=	os.time()
	tServer.HOOKS:CallHook(sPacketID, Content)
end