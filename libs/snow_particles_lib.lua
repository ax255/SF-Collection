--@name Snow particles lib
--@author Ax25 :3
--@client

--[[

SnowParticles:new(x, y, w, h, num, minSize, maxSize, fallSpeed, windSpeed)
    x top left corner x
    y top left corner y
    w width of the simulation rect
    h height of the simulation rect
    num How many snow particle to make
    minSize Minimum size of the particle
    maxSize Maximum size of the particle
    fallSpeed Speed in pixel per second the snow particle will fall
    windSpeed Speed in pixel per second of side wind the snow particle will experience, postive number goes to the right and negative number to the left

SnowParticles:setFallSpeed(num)
    Set the falling speed in pixel per second to the provided number 

SnowParticles:setWindSpeed(num)
    Set the wind speed pixel per second to the provided number

SnowParticles:setFallSpeedSpread(min, max)
    Set the speed spread of each snow particle

SnowParticles:setWindSpeedSpread(min, max)
    Set the wind speed spread of each snow particle

SnowParticles:setSizeSpread(min, max)
    Set the size spread of each snow particle

SnowParticles:build()
    Force the rebuilding of the snow particles

SnowParticles:setTPS(num)
    Set the simualtion max update rate per seconds

SnowParticles:sim()
    Tell the simulator to update the simulation to next state, best to be put in a think

SnowParticles:render()
    Draw the snow particle (must be in a 2d render context)
    
SnowParticles:debug(bool)
    true to show debug information, false to disable

]]


SnowParticles = class( "SnowParticles" )

function SnowParticles:initialize(x, y, w, h, num, minSize, maxSize, fall, wind)
    
    self.EffectParticles = {}
    self.ParticleNumber = num or 50
    self.FallSpeed = fall or 20
    self.WindSpeed = wind or 10
    self.rainMode = false
    
    self.fallSpeedSpread = { 0.5, 1.5 }
    self.windSpeedSpread = { 0.8, 1.2 }
    self.sizeSpread = { (minSize or 0.2), (maxSize or 4 ) }
    self.extraModifier = 1

    self.curtime = timer.curtime()
    self.lastTime = timer.curtime()
    
    self.TPS = 40
    self.TPSDelta = 1 / self.TPS
    self.NextMoveDelay = 0
    
    self.renderLerp = false
    self.renderLerpFraction = 0.3

    self.x = x
    self.y = y
    self.w = w
    self.h = h
    
    self.debug = false
    
    self:__constructEffectParticles()

end

function SnowParticles:__constructEffectParticles()
    self.EffectParticles = {}
    for i=1,self.ParticleNumber do

        local xrand, yrand = math.random(-(self.w/2), self.w*1.5), math.random(-self.h, 0)
        
        table.insert(self.EffectParticles, { 
            
            x = xrand,
            y = yrand, 
            oldPos = { xrand, yrand },
            size = math.rand(self.sizeSpread[1], self.sizeSpread[2]), 
            
            nextSparkleTime = 0, 
            isSparkling = false,
            sparkleInterval = math.rand(1.5, 3),
            sparkleStartTime = 0,
            
            FallSpeed = math.rand(self.fallSpeedSpread[1], self.fallSpeedSpread[2]),
            WindSpeed = math.rand(self.windSpeedSpread[1], self.windSpeedSpread[1]),
            
            Color = Color(255, 250, 250, 255)
            
        } )
        
    end
end

function SnowParticles:setFallSpeed(num)
    self.FallSpeed = num
end

function SnowParticles:setWindSpeed(num)
    self.WindSpeed = num
end

function SnowParticles:setFallSpeedSpread(min, max)
    self.fallSpeedSpread = { min, max }
    self:__ParticleIterator("FallSpeed", function()
         return math.rand(self.fallSpeedSpread[1], self.fallSpeedSpread[2]) 
    end )
end

function SnowParticles:setWindSpeedSpread(min, max)
    self.windSpeedSpread = { min, max }
    self:__ParticleIterator("WindSpeed", function() 
        return math.rand(self.windSpeedSpread[1], self.windSpeedSpread[2]) 
    end )
end

function SnowParticles:setSizeSpread(min, max)
    self.sizeSpread = { min, max }
    self:__ParticleIterator("size", function() 
        return math.rand(self.sizeSpread[1], self.sizeSpread[2]) 
    end )
end

function SnowParticles:build()
    self:__constructEffectParticles()
end

function SnowParticles:setTPS(num)
    self.TPS = num
    self.TPSDelta = 1 / self.TPS
end

function SnowParticles:__ParticleIterator(target, func)
    if not self.EffectParticles[1] then return end
    for k,snow in ipairs(self.EffectParticles) do
       snow[target] = func()
    end
end

function SnowParticles:__isInRenderBox(x, y)
    return x >= self.x and x <= (self.x + self.w) and 
           y >= self.y and y <= (self.y + self.h)
end

function SnowParticles:debugInfo(bool)
   self.debug = bool 
end

function SnowParticles:sim()

    if not self.EffectParticles[1] then
        return
    end
    
    self.curtime = timer.curtime()
    
    if not (self.NextMoveDelay < self.curtime) then -- TPS
        return 
    end
    self.NextMoveDelay = self.curtime + self.TPSDelta
    
    local deltaTime = self.curtime - self.lastTime -- deltatime calculation
    self.lastTime = self.curtime

    local sim = self
    for k,snow in ipairs(self.EffectParticles) do 
        
        if snow.y > sim.h or ( snow.x > sim.w*1.5 or snow.x < -(sim.w/2) ) then
            snow.y = 0
            snow.x = math.random(-(sim.w/2), sim.w*1.5)
            snow.nextSparkleTime = 0
            snow.isSparkling = false
        end

        local curtime = timer.curtime() -- sparkle effect
        if curtime >= snow.nextSparkleTime then
            snow.isSparkling = true
            snow.sparkleStartTime = curtime
            snow.nextSparkleTime = curtime + snow.sparkleInterval
        end

        local alpha = 255 -- sparkle color
        if snow.isSparkling then
            local elapsedSparkleTime = curtime - snow.sparkleStartTime
            if elapsedSparkleTime < snow.sparkleInterval then
                alpha = 255 * ( 0.5 + 0.5 * math.sin((elapsedSparkleTime / snow.sparkleInterval) * 3.1415926535898) )
            else
                snow.isSparkling = false
            end
        end

        snow.Color[4] = alpha

        snow.y = snow.y + (sim.FallSpeed * snow.FallSpeed * self.extraModifier * deltaTime)
        snow.x = snow.x + (sim.WindSpeed * snow.WindSpeed * self.extraModifier * deltaTime)
        
    end
 
end

function SnowParticles:render()
    
    local sim = self

    if sim.debug then
        render.setColor(Color(255, 0, 0, 50))
        render.drawRectOutline(sim.x, sim.y, sim.w, sim.h, 2)
        render.drawRectOutline(sim.x - sim.w/2, sim.y, sim.w*2, sim.h, 2)
        
        render.setColor(Color(0, 255, 0, 50))
        render.drawRectOutline(sim.x- sim.w/2, sim.y-sim.h, sim.w*2, sim.h, 2)
    end
    
    for k,snow in ipairs(self.EffectParticles) do
        
        if self:__isInRenderBox(snow.x+sim.x, snow.y+sim.y) then

            render.setColor( Color(snow.Color[1], snow.Color[2], snow.Color[3], snow.Color[4]) )
            if sim.renderLerp then
                
                local lerpX = math.lerp(sim.renderLerpFraction, snow.oldPos[1], snow.x)
                local lerpY = math.lerp(sim.renderLerpFraction, snow.oldPos[2], snow.y)
                
                --if self:__isInRenderBox(lerpX+sim.x, lerpY+sim.y) then 
                    if ( lerpX - snow.oldPos[1] > sim.w/16 ) or ( lerpY - snow.oldPos[2] > sim.h/16 ) then
                        render.drawFilledCircle(snow.x+sim.x, snow.y+sim.y, snow.size)
                        snow.oldPos = { snow.x+sim.x, snow.y+sim.y }
                    else
                        render.drawFilledCircle(lerpX+sim.x, lerpY+sim.y, snow.size)
                        snow.oldPos = { lerpX, lerpY }
                    end
                    
                --end
                
            else
                
                render.drawFilledCircle(snow.x+sim.x, snow.y+sim.y, snow.size)
                 
                if sim.rainMode then
                    for i=1,sim.FallSpeed/20 do
                        render.drawFilledCircle(snow.x-((sim.WindSpeed/20)*i), snow.y-(i*snow.size), snow.size-(i/(sim.FallSpeed/20))) 
                    end 
                end
                
            end
            render.setColor(Color(255, 255, 255, 255))
            
        elseif sim.debug then
            
            render.setColor(Color(255, 0, 0, 100))
            render.drawFilledCircle(snow.x+sim.x, snow.y+sim.y, snow.size) 
            render.setColor(Color(255, 255, 255, 255))
            
        end

    end
    
end
