function LIBRARY:Call(tServer, tEvent)
	local sID	= tostring(tEvent.udPeer:connect_id())
	MsgC(Color(52, 152, 219), "Client [ID : " .. sID .. "] connected : " .. tostring(tEvent.udPeer))

	tServer.CLIENTS[sID]	=	{tEvent.udPeer, os.time()}
end