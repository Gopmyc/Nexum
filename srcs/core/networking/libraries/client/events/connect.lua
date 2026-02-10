function LIBRARY:Call(tServer, tEvent)
	local sID			=	tostring(tEvent.udPeer:connect_id())
	
	MsgC(Color(46, 204, 113), "Connected to server [ID : " .. sID .. "] : " .. tostring(tEvent.udPeer))
end