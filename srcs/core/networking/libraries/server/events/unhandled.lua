function LIBRARY:Call(tServer, tEvent)
	local sID		= tostring(tEvent.udPeer:connect_id())
	local sPacketID	= tEvent.Data[1]

	return MsgC(Color(231, 76, 60), "Client [ID : " .. sID .. "] attempted to send an undeclared message : " .. tostring(sPacketID))
end