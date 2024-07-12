--@name createFlag
--@author Ax25 :3
--@shared

-- to create a new flag do in chat: !f size (size must be a number)

local vertical = true -- true make the line vertical, false make it horizontal

local colors = { -- FR, the flag will be rendered following the color order from first to last, can add any number of colors
    Color(0, 38, 84),
    Color(255, 255, 255),
    Color(237, 41, 57),
}

if CLIENT then
    
    render.createRenderTarget("screenRT1")
    local screenMat1 = material.create("UnlitGeneric") 
    screenMat1:setTextureRenderTarget("$basetexture", "screenRT1") 
    screenMat1:setInt("$flags", 2097152)
    
    local height = 1023/#colors

    hook.add("renderoffscreen", "renderflag", function()
        
        render.selectRenderTarget("screenRT1")
        render.clear(Color(0, 0, 0, 0))
        
        render.setFilterMag(1)
        render.setFilterMin(1)

        for i, color in ipairs(colors) do
            
            render.setColor(color)
            
            if vertical then
                
                render.drawRect((i-1)*height, 0, height, 1024)
            
            else
                
                render.drawRect(0, (i-1)*height, 1024, height)
                
            end
            
        end
        
        hook.remove("renderoffscreen", "renderflag")
        
    end)
    
    local waits = {}
    function awaitUntilValid(entIndex, func)

        local index = #waits+1
        waits[index] = {}
        waits[index].callback = func
        waits[index].entIndex = entIndex
        
    end
    
    timer.create("validCheck", 0.5, 0, function()
        
        for k,data in pairs(waits) do
            
            local ent = entity(data.entIndex)

            if ent:isValid() then
               
                data.callback()
                --print(ent, " is valid")
                waits[k] = nil 
                
            end
            
        end
        
    end) 
    
    local function createFlag(base, scale)
        
        local screen = hologram.create(base:getPos()+Vector(0, 0, 0), base:getAngles(), "models/holograms/plane.mdl", Vector(scale/1.5, scale, 0))
        screen:suppressEngineLighting(true)
        
        screen:setFilterMag(1)
        screen:setFilterMin(1)
        
        screen:setMaterial("!" .. screenMat1:getName())
        screen:setColor(Color(255, 255, 255, 254))
        screen:setParent(base)
     
    end
    
    local function queueFlag(entIndex, scale)
        
        awaitUntilValid(entIndex, function()
            
            createFlag(entity(entIndex), scale)
            
        end)
        
    end
    
    net.receive("newFlag", function()
        
        local entIndex = net.readInt(32)
        local scale = net.readInt(32) 

        queueFlag(entIndex, scale)
        
    end)
    
    net.receive("initFlags", function()
        
        local flags = net.readTable()
        
        for i, data in ipairs(flags) do
            
            queueFlag(data[1], data[2])
            
        end
        
    end)
    
else
    
    local flags = {}
    
    local function createFlag(pos, scale)

        local base = prop.create( pos+Vector(0, 0, 5*scale), Angle(90), "models/hunter/plates/plate1x1.mdl", true ) 
        base:setMaterial("Models/effects/vol_light001")
        base:setNocollideAll(true)
        
        net.start("newFlag")
        net.writeInt(base:entIndex(), 32)
        net.writeInt(scale, 32)
        net.send()
        
        table.insert(flags, {base:entIndex(), scale})
        
    end
    
    hook.add("ClientInitialized", "sendFlag", function(ply)
        
        net.start("initFlags")
        net.writeTable(flags)
        net.send(ply)
        
    end)
    
    hook.add("PlayerSay", "addFlag", function(ply, text)
        
        if ply == owner() and string.sub(text, 0, 2) == "!f" then
            
            local scale = string.explode(" ", text)[2]
            
            createFlag( (owner():getEyeTrace().HitPos or owner():getPos() ), tonumber(scale) )
            
            return ""
        end
        
    end)

end
