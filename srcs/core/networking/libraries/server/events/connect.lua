function LIBRARY:Call(tServer, tEvent)
	local sID	= tostring(tEvent.udPeer:connect_id())
	MsgC(Color(52, 152, 219), "Client [ID : " .. sID .. "] connected : " .. tostring(tEvent.udPeer) .. " [" .. os.date("%Y-%m-%d %H:%M:%S") .. "]")

	tServer.CLIENTS[sID]	=	{tEvent.udPeer, os.time()}

	-- AddNetworkID
	for sID, tClient in pairs(tServer.CLIENTS) do
		tServer:SendToClient(sID, tServer:BuildPacket("message-id-test", "Hello friend !", false, true))
	end
end