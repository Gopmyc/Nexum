function love.load(tArgs)
	tArgs[1]	= tArgs[1] and string.upper(tArgs[1]) or nil
	SERVER	= (tArgs[1] == "SERVER")
	CLIENT	= (tArgs[1] == "CLIENT")

	Nexum = require("srcs")
end

function love.update(iDeltaTime)
	Nexum:Update(iDeltaTime)
end

function love.draw()
	Nexum:Draw()
end

function love.quit()
	Nexum:Quit()
end