-- TODO: Delete

function lovr.load(tArgs)
	tArgs[1]	= tArgs[1] and string.upper(tArgs[1]) or nil
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