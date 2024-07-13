--@name snow particle lib exemple
--@author Ax25 :3
--@shared
--@include libs/snow_particles_lib.txt

if CLIENT then
    
    require("libs/snow_particles_lib.txt")
    
    local ham = SnowParticles:new(255, 255, 512, 512, 250, nil, nil, 150, 30)
    ham:setWindSpeedSpread(-1,1)
    ham:debugInfo(false)
    ham:setTPS(60)

    local FPS = 60
    local next_frame = 0
    local fps_delta = 1/FPS
    
    render.createRenderTarget("snow")
    hook.add("renderoffscreen", "snow", function()
        
        ham:sim()

        local now = timer.systime()
        if next_frame > now then return end
        next_frame = now + fps_delta

        render.selectRenderTarget("snow")
        render.clear(Color(0, 0, 0, 0))

        ham:render()

    end)

    hook.add("render", "screen", function()
        render.setRenderTargetTexture("snow")
        render.drawTexturedRect(0, 0, 512, 512)
    end)

else
    
    local screen=chip():isWeldedTo()
        
    if screen then
        screen:linkComponent(chip())
    end
        
end
