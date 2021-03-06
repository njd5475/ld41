
local Game = require("class")()

require('utils')

function Game:_init()
  print("Initialize the game")
  self.objects = {}
  self.types = {}
  local me = self
  love.draw = function() me:draw() end
  love.update = function(dt) me:update(dt) end
  self.bounds = {
    x = 0,
    y = 0,
    w = love.graphics:getWidth(),
    h = love.graphics:getHeight()
  }
  self.gravity = 319 --639 --200 --639
  self.hud = {}
  self.player = require('player')()
  self:add(self.player)
  self.gameOver = false
end

function Game:draw()
  love.graphics.setColor(150, 150, 245, 255)
  love.graphics.rectangle("fill", 0, 0, love.graphics:getWidth(), love.graphics:getHeight())
  for _, b in pairs(self.objects) do
    b:draw(self)
  end

  for _, b in pairs(self.hud) do
    b:draw(self)
  end

  if self.gameOver then
    local f = love.graphics.getFont()
    love.graphics.print("Game Over", love.graphics:getWidth()/2-f:getWidth("Game Over")/2 , love.graphics.getHeight()/2-f:getHeight())
  end
end

function Game:update(dt)
  if not self.gameOver then
    for _, b in pairs(self.objects) do
      if not b:dead() then
        b:update(self, dt)
        self:fallOrStop(b, dt)
      else
        self.objects[b:id()] = nil
        self.types[b:type()][b:id()] = nil
      end
    end

    for _, b in pairs(self.hud) do
      if not b:dead() then
        b:update(self, dt)
      else
        self.hud[b:id()] = nil
      end
    end
  end
end

function Game:fallOrStop(o, dt)
  if o.y then
    if o:moveable() then

      local lastY = o.y
      o.y = o.y + self.gravity * dt
      if o.y > self.bounds.x + self.bounds.h and self:outside(o) then
        print("Killing the " .. o:type() .. " because it dropped below the world")
        o:kill()
      else
        local bounds = o:bounds()
        local feet = o:feet()
        for _, f in pairs(feet) do
          local results = self:withinRange(f.x, f.y, o:boundsRadiiSq(), "platform")
          for _, p in pairs(results) do
            if inside(p:bounds(), f.x, f.y) then
              o.y = lastY
              o:adjustToPlatform(p)
            end
          end
        end
      end
    end
  end
end

function Game:add(o)
  if o.dead and o.id and not o:dead() then
    self.objects[o:id()] = o
    if not self.types[o:type()] then
      self.types[o:type()] = {}
    end
    self.types[o:type()][o:id()] = o
  else
    print("Err: Game only accepts non-dead game objects")
  end
end

function Game:addHud(o)
  if o.dead and o.id and not o:dead() then
    self.hud[o:id()] = o
  else
    print("Err: Hud only accepts non-dead game objets")
  end
end

function Game:outside(go)
  return not collides(self.bounds, go:bounds())
end

function Game:withinRange(x, y, rangeSq, type)
  local results = {}
  local objs = self.objects
  if type then
    objs = self.types[type]
  end

  if objs then
    for _, o in pairs(objs) do
      local cx, cy = o:boundsCenter()
      local dsq = distSq(cx, cy, x, y)
      if (rangeSq+o:boundsRadiiSq()) >= dsq then
        table.insert(results, o)
      end
    end
  end

  return results
end

function Game:catsGotMilk()
  print("Game Over")
  self.gameOver = true
end

return Game()
