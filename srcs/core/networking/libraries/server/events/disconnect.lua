function LIBRARY:Call(tServer, tEvent)
	local sID	= tostring(tEvent.udPeer:connect_id())

	if not tServer:IsValidClient(sID) then return end
	MsgC(Color(52, 152, 219), "Client [ID : " .. sID .. "] disconnected : " .. tostring(tEvent.udPeer))

	tServer.CLIENTS[sID]	=	nil
end