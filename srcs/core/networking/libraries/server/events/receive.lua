function LIBRARY:Call(tServer, tEvent) -- tData : {sID, ...}
	local sID			=	tostring(tEvent.tPeer:connect_id())
	local tPeer			=	tServer:IsValidClient(sID)
	
	if not tPeer then
		return MsgC(Color(231, 76, 60), "Unregister Client [ID : " .. sID .. "] attempted to send message : " .. tostring(tEvent.tData))
	end

	---- pcall all steps ----
	-- // TODO : Decrypt data...
	-- // TODO : Uncompress data...
	-- // TODO : JSON to Table...
	
	if not tServer:IsValidMessage(tData[1]) then
		return MsgC(Color(231, 76, 60), "Client [ID : " .. sID .. "] attempted to send an undeclared message : " .. tostring(tData[1]))
	end

	tServer.CLIENTS[sID][2]	=	os.time()
	tServer.HOOKS:CallHook(tData[1], tData[2])
end