function LIBRARY:Call(tClient, tEvent)
	local sID		= tostring(tEvent.udPeer:connect_id())
	local udPeer	= tClient:IsValidClient(sID)
	
	if not udPeer then
		return MsgC(Color(231, 76, 60), "Unregister Client [ID : " .. sID .. "] attempted to send message : " .. tostring(tEvent.Data))
	end

	local sPacketID, Content	= tClient.CODEC:Decode(tEvent.Data)

	tClient.HOOKS:CallHook(sPacketID, Content)
end