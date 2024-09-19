--@name sprite exemple simple
--@author Ax25 :3
--@shared
--@include https://raw.githubusercontent.com/ax255/SF-Collection/main/libs/Sprite%20Loader.lua as sprite_loader.lua

dofile("sprite_loader.lua")

if CLIENT then
    
    setSpriteRes(512) -- we set the resolution we want our sprites to be
    addSprite( "hambugi", "https://raw.githubusercontent.com/ax255/public-stuff/main/Live Audio Asset/hamburger.png" ) -- create a new sprite name, url

    hook.add("render", "spriteExmple", function()

        render.setColor(Color(255, 255, 255, 255))
        drawSprite("hambugi", 0, 0, 256, 256, true) -- spriteName, x, y, w, h, showLoading
        
    end)
    
else
   
    local screen=chip():isWeldedTo()
        
    if screen then
        screen:linkComponent(chip())
    end 
    
end
