--@name Sprite Loader
--@author Ax25, toakely682
--@shared

if CLIENT then

    spriteRes = 128
    spritertIndex = 1
    
    local nextSprite = { x = 0, y = 0 }
    local sprites = {}
    local spriteWaitlist = {}
    spriteWaitlist.sprites = {}
    spriteWaitlist.lastTime = timer.curtime()
    spriteWaitlist.processing = false

    local HorizontalFrames = 1024 / spriteRes
    local VerticalFrames = 1024 / spriteRes
    
    function setSpriteRes(num)
        
        if num > 1024 then
           throw("Sprite size cannot be higher than 1024") 
        end
        
        spriteRes = num
        HorizontalFrames = 1024 / spriteRes
        VerticalFrames = 1024 / spriteRes
        
    end
    
    function getUV(FrameX, FrameY)
        
        FrameX = FrameX + 1
        FrameY = FrameY + 1

        local UStart = 1 / HorizontalFrames * ( FrameX - 1 )
        local UEnd = 1 / HorizontalFrames * FrameX
        
        local VStart = 1 / VerticalFrames * ( FrameY - 1 )
        local VEnd = 1 / VerticalFrames * FrameY
        
        return UStart, VStart, UEnd, VEnd
        
    end
    
    local forceSize = nil
    function discordEmojiUrl(EmojiID, Size)
        
        Size = forceSize or Size or spriteRes
        return "https://cdn.discordapp.com/emojis/" .. EmojiID .. ".png?size=" .. Size .. "&quality=lossless" 
        
    end
    
    function newRT(index)
        
        render.createRenderTarget( "sprites" .. spritertIndex )

        hook.add("renderoffscreen", "rtInit_"..index, function()
            
            render.selectRenderTarget("sprites" .. spritertIndex)
            render.clear(Color(0, 0, 0, 0))
            hook.remove("renderoffscreen", "rtInit_"..index)
            
        end)
        
    end

    newRT( spritertIndex )
    
    function addSprite(name, url)
        
        if sprites[name] then return end
        
        table.insert( spriteWaitlist.sprites, { name, url } )

    end
    
    hook.add("tick", "processSprite", function()
        
        if timer.curtime() - spriteWaitlist.lastTime > 0.1 and not spriteWaitlist.processing then -- and player():getPos():getDistance(chip():getPos()) < 500 then
            
            local sprite = spriteWaitlist.sprites[1]
            
            if sprite then
    
                processSprite( sprite[1], sprite[2] )
                spriteWaitlist.processing = true
                
                table.remove(spriteWaitlist.sprites, 1)
                spriteWaitlist.lastTime = timer.curtime()
                
            end
            
        end
        
    end)
    
    function processSprite(name, url)

        if nextSprite.x > HorizontalFrames-1 then
            
            spritertIndex = spritertIndex + 1
        
            newRT( spritertIndex )
            
            nextSprite.x = 0
            nextSprite.y = 0

        end
        
        sprites[name] = {}
        sprites[name].url = url
        sprites[name].x = nextSprite.x
        sprites[name].y = nextSprite.y
        sprites[name].rt = spritertIndex

        local spriteMat = material.create("UnlitGeneric")
        spriteMat:setInt("$flags", 256)
        spriteMat:setTextureURL("$basetexture", url, function(mtl, url, w, h, layout )
            
            if layout then
                layout(0, 0, 1024, 1024)
            end
            
        end, function(mat, url)
            
            hook.add("renderoffscreen", "drawEmojiRT", function()
                
                render.selectRenderTarget( "sprites" .. spritertIndex )
                
                render.setFilterMag(1)
                render.setFilterMin(1)
                
                --render.setColor(Color(0, 0, 0, 255))
                --render.drawRect( 1024 / HorizontalFrames * sprites[name].x, 1024 / VerticalFrames * sprites[name].y, spriteRes, spriteRes )
    
                render.setColor(Color(255, 255, 255, 255))
                
                render.setMaterial(spriteMat)
                render.drawTexturedRect( 1024 / HorizontalFrames * sprites[name].x, 1024 / VerticalFrames * sprites[name].y, spriteRes, spriteRes )

                render.destroyRenderTarget( spriteMat:getName() .. "$basetexture" )
                render.destroyTexture(spriteMat)
                
                spriteWaitlist.processing = false
    
                hook.remove("renderoffscreen", "drawEmojiRT")
                
            end)
            
        end)
        
        if nextSprite.y + 1 > VerticalFrames-1 then
            
            nextSprite.x = nextSprite.x + 1
            nextSprite.y = 0
            
        else
            
            nextSprite.y = nextSprite.y + 1
            
        end
        
    end
    
    function drawSprite(name, x, y, w, h, showProgress)
        
        local sprite = sprites[name]
        
        if not sprite then 
            
            if showProgress then
                
                render.setFont(render.getDefaultFont())
                render.setColor(Color(255, 255, 255, 255))
                render.drawText(x + w / 2, y + h / 2, "loading/not found", 1)
                render.drawText(x + w / 2, ( y + h / 2 ) + 15, "left: " .. #spriteWaitlist.sprites, 1)
                
            end
            
            return nil
        end
        
        render.setRenderTargetTexture( "sprites" .. sprite.rt )
        render.drawTexturedRectUV( x, y, w, h, getUV( sprite.x, sprite.y ) )
        
        return true
        
    end
    
end
