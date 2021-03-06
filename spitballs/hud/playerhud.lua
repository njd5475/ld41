
local PlayerHud = require('gameobject'):derive("playerhud")

function PlayerHud:_init(player)
  require('gameobject')._init(self)
  self.player = player
end

-- TODO pretty this display up
function PlayerHud:draw(game)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Spitball Machines: " .. #self.player.machines, 0, love.graphics.getFont():getHeight())
end

require('game'):addHud(PlayerHud(require('game').player))
