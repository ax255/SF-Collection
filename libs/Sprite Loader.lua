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
    spriteWaitlist.lookup = {}

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
    
    function addSprite(name, path, keepRatio)
        if sprites[name] or spriteWaitlist.lookup[name] then return end

        spriteWaitlist.lookup[name] = path
        table.insert( spriteWaitlist.sprites, { name, path, keepRatio } )
    end
    
    hook.add("tick", "processSprite", function()
        if timer.curtime() - spriteWaitlist.lastTime > 0.1 and not spriteWaitlist.processing then -- and player():getPos():getDistance(chip():getPos()) < 500 then
            local sprite = spriteWaitlist.sprites[1]
            
            if sprite then
                processSprite( sprite[1], sprite[2], sprite[3] )
                spriteWaitlist.processing = true
                
                table.remove(spriteWaitlist.sprites, 1)
                spriteWaitlist.lookup[sprite[1]] = nil
                spriteWaitlist.lastTime = timer.curtime()
            end
        end
    end)
    
    function processSprite(name, path, keepRatio)
        if nextSprite.x > HorizontalFrames-1 then
            spritertIndex = spritertIndex + 1
        
            newRT( spritertIndex )
            
            nextSprite.x = 0
            nextSprite.y = 0
        end
        
        sprites[name] = {}
        sprites[name].path = path
        sprites[name].x = nextSprite.x
        sprites[name].y = nextSprite.y
        sprites[name].rt = spritertIndex

        if string.find(path, "icon16") then
            local mat = material.createFromImage(path, "")

            hook.add("renderoffscreen", "drawEmojiRT", function()
                render.selectRenderTarget( "sprites" .. spritertIndex )
                
                render.setFilterMag(1)
                render.setFilterMin(1)

                render.setColor(Color(255, 255, 255, 255))
                
                render.setMaterial(mat)
                render.drawTexturedRect( 1024 / HorizontalFrames * sprites[name].x, 1024 / VerticalFrames * sprites[name].y, spriteRes, spriteRes )

                timer.simple(0, function()
                    render.destroyTexture(mat)
                    spriteWaitlist.processing = false
                    
                    hook.remove("renderoffscreen", "drawEmojiRT")
                end)
            end)
        else
            
            --local spriteMat = material.create("UnlitGeneric")
            --spriteMat:setInt("$flags", 256)
            --spriteMat:setTextureURL("$basetexture", path, function(mtl, path, w, h, layout )
            local spriteMat = render.createMaterial(path, function(mtl, path, w, h, layout)
                local width, height = 1024, 1024

                if keepRatio then
                    local scale
                    if w > h then
                        scale = width / w
                    else
                        scale = height / h
                    end
            
                    width = w * scale
                    height = h * scale
                end

                if layout then
                    layout(0, 0, width, height)
                end
            end, function(mat, path)
                hook.add("renderoffscreen", "drawEmojiRT", function()
                    render.selectRenderTarget( "sprites" .. spritertIndex )
                    
                    render.setFilterMag(1)
                    render.setFilterMin(1)
                    
                    --render.setColor(Color(0, 0, 0, 255))
                    --render.drawRect( 1024 / HorizontalFrames * sprites[name].x, 1024 / VerticalFrames * sprites[name].y, spriteRes, spriteRes )
        
                    render.setColor(Color(255, 255, 255, 255))
                    
                    render.setMaterial(mat)
                    render.drawTexturedRect( 1024 / HorizontalFrames * sprites[name].x, 1024 / VerticalFrames * sprites[name].y, spriteRes, spriteRes )
    
                    render.destroyRenderTarget( mat:getName() .. "$basetexture" )
                    render.destroyTexture(mat)
                    
                    spriteWaitlist.processing = false
        
                    hook.remove("renderoffscreen", "drawEmojiRT")
                end)
            end)
        end
        
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
