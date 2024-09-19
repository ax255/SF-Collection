--@name bassPlayURL
--@author Ax25 :3
--@client

local Sounds = {}
bassMode = bass.loadURL

function playSound(url, pos, volume, loop, id, fademin, fademax, pitch, callback)

    if bass.soundsLeft() < 2 then return end

    id = id or math.random(10000, 20000)

    pitch = pitch or 1
    fademin = fademin or 500
    fademax = fademax or 2000
    volume = volume or 1
    
    local function bassHandle(snd,_,err)
        
        if snd then
    
            if Sounds[id] then
                if isValid(Sounds[id]) then
                    Sounds[id]:stop()
                end 
                Sounds[id] = nil
            end
            
            Sounds[id] = snd
            Sounds[id]:setVolume(volume)
            Sounds[id]:setFade(fademin, fademax)
    
            if type(pos) == "Player" or type(pos) == "Entity" or type(pos) == "Hologram" then
                Sounds[id].Dpos = pos
                hook.add("think", "soundPos_"..id, function()
                    Sounds[id]:setPos(Sounds[id].Dpos:getPos())
                end)
            else
                Sounds[id]:setPos(pos)
            end
    
            Sounds[id]:play()
            Sounds[id]:setPitch(pitch)
    
            if loop then
                Sounds[id]:setLooping(true)
            else
                timer.simple(Sounds[id]:getLength(), function()
                    if Sounds[id] then
                        Sounds[id]:stop()
                        Sounds[id] = nil
                        hook.remove("think", "soundPos_"..id)
                    end
                end)
            end
            
            if callback then
                callback()
            end
    
        else
            
            if err then
                print(err)
                throw(err .. " " .. url)
                return
            end 
            
        end 

    end
    
    bassMode(url, "3d noplay noblock", bassHandle)

end
