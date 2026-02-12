function LIBRARY:Call(tClient, tEvent)
	local sID	= tostring(tEvent.peer:connect_id())

	MsgC(Color(241, 196, 15), "Disconnected from server [ID : " .. sID .. "] : " .. tostring(tEvent.peer) .. "[" .. os.date("%Y-%m-%d %H:%M:%S") .. "]")

	tClient.PEER:disconnect()
	tClient.PEER = nil
end