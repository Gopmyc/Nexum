function LIBRARY:Call(tServer, tEvent)
	local sID			=	tostring(tEvent.tPeer:connect_id())
	MsgC(Color(52, 152, 219), "Client [ID : " .. sID .. "] connected : " .. tostring(tEvent.tPeer))

	tServer.CLIENTS[sID]	=	{tEvent.tPeer, os.time()}
end