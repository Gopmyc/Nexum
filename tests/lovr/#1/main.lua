-- Initialize Nexum
local Nexum = require("srcs")

-- Instantiate an example object
local sInstanceName	= "SERVER ONE"
local myInstance	= Nexum:Instantiate("networking", sInstanceName)

-- Update loop
function love.update(dt)
    Nexum:Update(dt)
end

-- Draw loop
function love.draw()
    Nexum:Draw()
end

function love.quit()
	Nexum:Quit()
end