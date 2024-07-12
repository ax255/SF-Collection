--@name Chat Above Head
--@author Ax25 :3, toakley682
--@shared

local char_limit = 300 -- max length of the text
local history_limit = 3 -- how many past message it will show, set to 1 to only have most recent message
local muted = false -- enable it if message sent doesn't appear in chat
local cpsCounter = true -- enable or disable the CPS counter

if CLIENT then
    
    local fadeTime = 8 -- how much time the text is visible
    local liveUpdate = true -- if set to true it will send what you currently writing set it to false to disable it
    local font = render.createFont("Roboto", 60, 400, true) -- the first number is the font size
    local color_text = Color(0, 255, 255) -- the text will be this color
    local text_offset = 0 -- offset for the text height incase your model is blocking the text, can be negative or positive
    
    local writing_sounds = { -- the sound on each key stroke, first is sound path, second is volume                
        { "ambient/machines/keyboard5_clicks.wav", 0.5 }, -- you can add mutiple sound following the table format, they will randomly be played
        { "ambient/machines/keyboard3_clicks.wav", 0.5 },
        { "ambient/machines/keyboard2_clicks.wav", 0.5 },
    }
    
    local sent_sounds = { -- the sound when message is sent
        { "ambient/machines/keyboard7_clicks_enter.wav", 1 },
    }

    timer.create("rainbow", 1/8, 0, function() -- exemple of how you could make the text rainbow

        color_text = Color((timer.curtime()*30)%360, 1, 1):hsvToRGB()
        
    end)

    -- you shouldn't modify anything below this
    
    local liveText = ""
    local lastTextTime = timer.curtime()
    local mk = render.parseMarkup("", 1024)
    local CPS = 0
    
    if player() == owner() then
        
        local curtext = ""
        
        hook.add("ChatTextChanged", "chatUpdate", function(txt)

            timer.simple(0, function() 
                
                if txt ~= "" then
                    
                    curtext = txt
                    
                    if liveUpdate then
        
                        --if #curtext > char_limit then return end
                        
                        local out = string.right(curtext, char_limit)

                        if net.getBitsLeft() < #out*8 + char_limit*8 then
                            return
                        end
                        
                        net.start("chattxt")
                        net.writeString(out)
                        net.writeBool(false)
                        net.send()
                        
                    end

                end
    
            end)
            
        end)
        
        hook.add("PlayerChat", "confirmChat", function(ply, text, team, isdead)

            if ply == owner() and string.trimRight(text) == string.trimRight(curtext) and not muted then

                net.start("chattxt")
                net.writeString(curtext)
                net.writeBool(true)
                net.send()
                
            end
            
        end)
        
        hook.add("FinishChat", "openclose", function()
            
            if muted then
                
                net.start("chattxt")
                net.writeString(curtext)
                net.writeBool(true)
                net.send()
                
            else
                
                net.start("chattxt")
                net.writeString("AXRESETLAST")
                net.writeBool(false)
                net.send()
                
            end
            
        end)
        
    end
    
    local function updateMk(tbl)
        
        if player():getPos():getDistance(owner():getPos()) > 1500 then
            return
        end
        
        local outStr
        
        local diffTime = timer.curtime() - lastTextTime
        local timeAlpha = math.round(255 * math.max(0, 1 - diffTime / fadeTime))

        for i = 1, #tbl do
       
            if tbl[i] then
                
                local frac = math.max(0.4, 1 - 0.2 * ( #tbl - i ) )
                local color_mk = "<color=".. math.round(color_text.r*frac) .. "," .. math.round(color_text.g*frac) .. "," .. math.round(color_text.b*frac) .. "," .. math.round(timeAlpha*frac) .. ">"

                outStr = ( ( outStr and outStr .. "\n" ) or "" ) .. color_mk .. tbl[i] .. "</color>"
                
            end
            
        end

        mk = render.parseMarkup("<font="..font..">" .. outStr, 1024)
        
    end
    
    timer.create("mkUpdate", 1/8, 0, function()
        
        updateMk(string.explode("\n", liveText))
        
    end)
    
    net.receive("txtupdate", function()

        liveText = net.readString()
        lastTextTime = timer.curtime()
        bool = net.readBool()
        
        if cpsCounter then
            
            CPS = net.readFloat()
            CPS = math.round(CPS, 2)
            
        end

        if not sound.canEmitSound() or not hasPermission("entities.emitSound", owner()) then
            return
        end

        if bool then
            
            local sound = table.random(sent_sounds)
            owner():emitSound(sound[1], nil, nil, sound[2])
            
        else
            
            local sound = table.random(writing_sounds)
            owner():emitSound(sound[1], nil, nil, sound[2])

        end

    end)
    
    render.createRenderTarget("screenRT1")
    local screenMat1 = material.create("UnlitGeneric") 
    screenMat1:setTextureRenderTarget("$basetexture", "screenRT1") 
    screenMat1:setInt("$flags", 2097152)
    
    screen = hologram.create(chip():getPos(), Angle(90), "models/holograms/plane.mdl", Vector(4, 4, 0))
    screen:suppressEngineLighting(true)
    screen:setParent(owner())
    screen:setMaterial("!" .. screenMat1:getName())
    screen:setColor(Color(255, 255, 255, 254))

    hook.add("renderoffscreen", "textrender", function()
        render.selectRenderTarget("screenRT1")
        render.clear(Color(0, 0, 0, 0))
        
        if player() == owner() and  convar.getInt("simple_thirdperson_enabled") == 0 then
            return
        end
        
        if player():getPos():getDistance(owner():getPos()) > 1500 then
            return
        end
        
        local diffTime = timer.curtime() - lastTextTime
        local Alpha = 255 * math.max(0, 1 - diffTime / fadeTime)
    
        render.setColor(Color(50, 50, 50, math.max(Alpha-50, 0)))
        render.setFont(font)
        
        local CPSTextSizeX, CPSTextSizeY
        
        if cpsCounter then
            
            local CPSText = ( CPS .. " CPS" )
            
            CPSTextSizeX, CPSTextSizeY = render.getTextSize( CPSText )
            render.drawRect( 512 - CPSTextSizeX / 2, 0, CPSTextSizeX, CPSTextSizeY )
            
            render.setColor( Color( 255, 255, 255, Alpha ) )
            render.drawSimpleText( 512, 0, CPSText, 1 )
            
        end
        
        render.setColor(Color(50, 50, 50, math.max(Alpha-50, 0)))
        
        if mk then
            
            local w, h = mk:getSize()
            
            render.drawRect(( 512 - w / 2 ) - 10, 10 + (CPSTextSizeY or 0), w + 20, h)
            mk:draw(512, 10 + (CPSTextSizeY or 0), 1, 0, nil, 1)
            
        end
        
    end)
    
    hook.add("think", "textAngle", function()
        
        if not owner():isValid() then 
            if screen:isValid() then
                screen:setPos(Vector(0, 0, 0))
            end
            return 
        end
        
        local desiredAngle = (render.getEyePos() - screen:getPos()):getNormalized():getAngle()+Angle(90, 0, 0)
        screen:setPos( ( owner():getEyePos() + Vector( 0, 0, text_offset ) ) + Vector(0, 0, mk:getHeight()/25 ) ) 
        screen:setAngles(desiredAngle)
        
    end)
    
else
    
    local text = ""
    local lastMsg = ""
    
    local CPS = 0
    
    local lastText = ""
    local CharactersSinceLastCheck = 0
    local CPSCheckTime = 0.4
    
    if cpsCounter then
    
        timer.create( "CPSCheck", CPSCheckTime, 0, function()
            
            CPS = CharactersSinceLastCheck / CPSCheckTime
            
            CharactersSinceLastCheck = 0
            
        end)
        
    end
    
    net.receive("chattxt", function(_,ply)
        
        local str = net.readString()
        local bool = net.readBool()
        
        local out = ""
        
        if cpsCounter then
            
            CharactersSinceLastCheck = CharactersSinceLastCheck + math.max( #str - #lastText, 0 )
            
        end

        lastText = str

        if str == "" then
            return
        end

        if bool then

            if str == lastMsg then
                return
            end
            
            if str ~= "" then
                
                if text == "" then
                    
                    text = str
                    
                else
                    
                    text = text .. "\n" .. str
                    
                end
                
            end
            
            text = string.right(text, char_limit)
            
            local exp = string.explode("\n", text)
            
            if #exp > history_limit then
                
                for i = 1, #exp - history_limit do
                    
                    if exp[i] then
                        
                        table.remove(exp, i) 
                        
                    end
                    
                end
                
            end
            
            for i = 1, history_limit do
                
                if exp[i] then
                    
                    if out == "" then
                        
                        out = exp[i]
                        
                    else
                        
                        out = out .. "\n" .. exp[i]
                        
                    end
                    
                end
                
            end
            
            text = string.right(text, char_limit)
            
            text = out
            lastMsg = str
            
        else
            
            if text == "" then
                
                if str ~= "AXRESETLAST" then

                    out = string.right(str, char_limit)
                    
                end
                
            else
                
                if str == "AXRESETLAST" then
                    
                    out = string.right(text, char_limit)

                else
                    
                    out = string.right(text .. "\n" .. str, char_limit)
                    
                end

            end
            
        end
        
        if net.getBitsLeft() < #out*8 + char_limit*8 then
            return
        end

        net.start("txtupdate")
        net.writeString(out)
        net.writeBool(bool)
        net.writeFloat(CPS)
        net.send()
        
    end)
    
end
