--@name Chair Use Zoltins fix
--@author Ax25 :3
--@shared

--[[ -- Exemple of use

    if SERVER then
        local Chair = prop.createSent(chip():getPos(), Angle(0), "Seat_Airboat", true)
    
        timer.simple(1, function() -- putting a delay just to wait for owner client to init
            
            Chair:useChair(function() -- this function will be called if using the chair was succesful
                print("succes")    
            end, function() -- this function will be called if it failed to use the chair
                print("fail")
            end)
            
        end) 
    end

--]]

if SERVER then
    
    local Entity = getMethods("Entity")

    function Entity:useChair(succes, fail)
        
        if not self:isValid() or not self:isVehicle() or self.inUse then return end
        self.oldPos = self:getPos()
        self.inUse = true
        self:setPos(owner():getEyePos()+Vector(0,0,-5))
        
        net.start("sv_useChair")
        net.send(owner())
        
        hook.add("PlayerEnteredVehicle", "useChair", function(ply, vehicle)
            if ply == owner() and vehicle ==  self and self:isValid() then
                hook.remove("PlayerEnteredVehicle", "useChair")
                timer.remove("chairTimeout")
                self:setPos(self.oldPos)
                self:ejectDriver()
                self.inUse = false
                if succes then
                   succes() 
                end
            end
        end)
        
        timer.create("chairTimeout", 1, 1, function()
            if self.inUse and self:isValid() then
                hook.remove("PlayerEnteredVehicle", "useChair")
                self:setPos(self.oldPos)
                self.inUse = false
                if fail then
                    fail()
                end
            end
        end)
        
    end
    
else
    
    net.receive("sv_useChair", function()
        if player() == owner() then
            concmd("-use")
            timer.simple(0, function()
                concmd("+use")
                timer.simple(0.01, function() concmd("-use") end)
            end)
        end
    end)
    
end
