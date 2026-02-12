function lovr.load(tArgs)
	assert((tArgs[1] == "SERVER") or (tArgs[1] == "CLIENT"), "error: First argument must be either 'SERVER' or 'CLIENT', use : ./Nexum.exe 'SERVER' or : ./Nexum.exe 'CLIENT'")
	SERVER	= (tArgs[1] == "SERVER")
	CLIENT	= (tArgs[1] == "CLIENT")

	Nexum = require("srcs")
end

function lovr.update(iDeltaTime)
	Nexum:Update(iDeltaTime)
end

function lovr.draw(Pass)
	Nexum:Draw(Pass)
end

function lovr.quit()
	Nexum:Quit()
end