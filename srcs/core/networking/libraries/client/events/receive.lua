function LIBRARY:Call(tServer, tEvent)
	local sID				=	tostring(tEvent.peer:connect_id())
	local bSuccess, tData	=	pcall(JSON.decode, tEvent.data)

	if not (bSuccess and istable(tData)) then
		return MsgC(Color(241, 196, 15), "[WARNING] Invalid JSON received from server [ID : " .. sID .. "]")
	end

	MsgC(Color(52, 152, 219), "Received message [" .. tostring(tData[1]) .. "] from server")
		
	return tServer.HOOKS:CallHook(tData[1], tData[2])
end