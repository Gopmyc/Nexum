function lovr.load(tArgs)
	tArgs[1]		= tArgs[1] and string.upper(tArgs[1]) or nil
	SERVER 			= (tArgs[1] == "SERVER")
	CLIENT 			= (tArgs[1] == "CLIENT")

	Nexum 			= require("srcs")
	local tRelay	= Nexum:Instanciate("relay", "RELAY #1")

	tArgs[2]		= IsString(tArgs[2]) and ((tArgs[2]:byte(1) == 47) and tArgs[2]) or nil

	return tArgs[2] and tRelay:RunCommand(tArgs[2]) or nil
end

function lovr.update(dt)
	Nexum:Update(dt)
end

function lovr.draw(Pass)
	Nexum:Draw(Pass)
end

function lovr.quit()
	Nexum:Quit()
end