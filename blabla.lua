--@name blabla
--@author Ax25 :3
--@shared

if CLIENT then -- funni blabla chip, affect every player !!
    
    local Players = {}
    local Screens = {}
    
    local rolldelta = math.rad(40)
    local emitter = particle.create(Vector(0, 0, 0), false)
    local mat = render.createMaterial("https://raw.githubusercontent.com/ax255/public-stuff/main/speaking-head-in-silhouette-emoji-1024x983-bg6os3zn.png")
    
    local font = render.createFont("Roboto", 256, 400, true)
    render.createRenderTarget("screenRT1")
    local screenMat1 = material.create("UnlitGeneric") 
    screenMat1:setTextureRenderTarget("$basetexture", "screenRT1") 
    screenMat1:setInt("$flags", 2097152)
    
    function startYap(ply)
        Players[ply:getUserID()] = true
        if not Screens[ply:getUserID()] then
            Screens[ply:getUserID()] = hologram.create(chip():getPos(), Angle(90), "models/holograms/plane.mdl", Vector(4, 4, 0))
            Screens[ply:getUserID()]:suppressEngineLighting(true)
            Screens[ply:getUserID()]:setParent(ply)
            Screens[ply:getUserID()]:setMaterial("!" .. screenMat1:getName())
            Screens[ply:getUserID()]:setColor(Color(255, 255, 255, 254))
        end
    end
    
    function endYap(ply)
        Players[ply:getUserID()] = nil
        if Screens[ply:getUserID()] then
            Screens[ply:getUserID()]:remove()
            Screens[ply:getUserID()] = nil
        end
    end
    
    hook.add("PlayerStartVoice", "startYap", startYap)
    hook.add("PlayerEndVoice", "endYap", endYap)

    timer.create("blabla", 0.5, 0, function()
        for v,i in pairs(Players) do
            local ply = player(v)
            local particles = emitter:add(mat, (ply:getEyePos()+ply:getAimVector()*10) + Vector( 0, 0, -5 ), math.random(4, 8), 0, 0, 0, 255, 0, 1.5)
            if particles then
                particles:setVelocity( (ply:getAimVector()*30+Vector(math.random(0, 10),math.random(0, 10),math.random(0, 10))) )
                particles:setRollDelta(rolldelta)
            end
        end
    end)
    
    hook.add("renderoffscreen", "3dcam2dYap", function()
        render.selectRenderTarget("screenRT1")
        render.clear(Color(0, 0, 0, 0))
        render.setColor(Color(28, 102, 154, 255))
        render.setFont(font)
        render.drawText(512, 512, "Yapping", 1)
    end)
    
    hook.add("think", "YapScreenAnglePos", function()
        for v,i in pairs(Screens) do
            local desiredAngle = (render.getEyePos() - i:getPos()):getNormalized():getAngle()+Angle(90, 0, 0)
            i:setPos(player(v):getPos()+Vector(0, 0, 90)) 
            i:setAngles(desiredAngle)
        end
    end)
    
end
