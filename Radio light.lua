--@name Radio light
--@author Ax25
--@shared
--@model models/props/cs_office/radio.mdl
--@include https://raw.githubusercontent.com/ax255/SF-Collection/main/libs/radio%20manager.lua as radiom
require("radiom")

/*
    Commands
    
    !skip | skip the song
    
    !volume number | set the volumr
    
    !search name | search and play song from the loaded playlist
    
    !time number | set the time of the current song
    
    !add url | add a song to the wait list

*/

local playlist = { -- You can manually make playlist that way
    "https://autumn.revolt.chat/attachments/dnw_zipoM_qQ7g8yW2jsqjQOfevXQVFjTdDBa8LOmC/[DNB]%20sanj%20-%20last%20minute%20(sakuraburst%20remix).mp3",
    "https://autumn.revolt.chat/attachments/n5k4veguRbhZ9XEBjShIH2skt3Iu6Kphn9YCRwprcm/[DNB]%20Street%20-%20Hacking%20Code.mp3",
    "https://autumn.revolt.chat/attachments/JN6VxNkA71hAASQgIyMSHlHgXKkhmluhcz1PpvDC0I/[dreamless%20wanderer]%20(Camellia)%20-%20shadows%20of%20cats.mp3",
    "https://autumn.revolt.chat/attachments/LLSEe5B6w-at5yJoyQstRJGz9syhj7Xw1uhs5nMSob/[Drumstep]%20-%20Pegboard%20Nerds%20-%20Try%20This%20[Monstercat%20Release].mp3",
}

--radiom:fetchPlaylist(playlist) -- and import it to radiom that way

-- Or fetch json playlist from the internet (comment or uncomment those line to add them)

radiom:fetchPlaylist("https://raw.githubusercontent.com/ax255/public-stuff/main/Live%20Audio%20Asset/output.json", true) -- Mostly weeb song
radiom:fetchPlaylist("https://raw.githubusercontent.com/ax255/public-stuff/main/80-90.json", true) -- 80s 90s music
radiom:fetchPlaylist("https://autumn.revolt.chat/attachments/owF_rZp-0H04vRaoATdEeCj21mS4rSjyKn45SKv5rB/output.json", true) -- More 80s 90s music and 2000
--radiom:fetchPlaylist("https://cdn.revoltusercontent.com/attachments/zzTNSX8t356nSlTknQvQphm2w_NHENmz5VvJyUnSFG/export.json", true) -- Minecraft OST
--radiom:fetchPlaylist("https://cdn.revoltusercontent.com/attachments/bcgubqL6qNztuCazUTg2U6i9JqUE_78LBNnTQ3vzf8/output.json", true) -- outerwild OST

--radiom:enableDebug() -- debug mode, you shouldn't need it

if CLIENT then

    radiom.followEnt = chip() -- You can replace it by owner() if you want the music to follow you
    radiom.followOffset = Vector(0, 0, 20)
    
    local fft = {}
    local bassMagnitude = 0
    local musicRainbow
    local c = 0
    local weldedto
    
    function normalizedBass()
        local normalized = (math.max(bassMagnitude+50, -50) / 50) * 3
        return math.clamp(normalized, 0.4, 3)
    end
    
    local FPS = 30
    local next_frame = 0
    local fps_delta = 1/FPS
    
    local dynLight = light.create(chip():getPos(), 300, 2, Color(255, 255, 255))

    hook.add("think", "hamborgiradio", function()
        dynLight:setPos(radiom.followEnt:getPos())
        dynLight:draw()
        
        local now = timer.systime()
        if next_frame > now then return end
        next_frame = now + fps_delta
        
        if radiom:bassValid() then 
            fft = radiom.bass:getFFT(5)
        else
            for k,v in pairs(fft) do
                fft[k] = 0
            end 
        end
        
        local fftSize = 8192
        local sampleRate = 48000
        local bassEnergy = 0
        local binSize = sampleRate / fftSize
        
        for k = 1, #fft do
            local freq = (k - 1) * binSize
            if freq >= 20 and freq <= 150 then
                local energy = fft[k] ^ 2
                bassEnergy = bassEnergy + energy
            end
        end
        
        c = c + 0.5
        if c > 360 then c = 0 end
        
        bassMagnitude = math.min(-0.05, (10 * math.log10(bassEnergy)) )
        musicRainbow = Color((-bassMagnitude*5 )%360-c, 1, 1):hsvToRGB()

        dynLight:setColor(musicRainbow)
        dynLight:setSize(300*math.max(0.8, normalizedBass()))
        
        if weldedto and weldedto:isValid() then
            weldedto:setColor(musicRainbow)
        end
    end)

    net.receive("weld", function()
        weldedto = net.readEntity()
    end)
    
    function formatTime(value)
        local time = string.formattedTime(value)
        time.m = time.h > 0 and (time.m < 10 and "0" or "")..time.m or time.m
        time.s = (time.s < 10 and "0" or "")..time.s

        return (time.h > 0 and time.h..":" or "")..time.m..":"..time.s
    end
    
    timer.create("rah", 1, 0, function()
        local time = radiom.time and math.floor(radiom.time) or "0"
        local length = radiom.length and math.floor(radiom.length) or "0"
        local str = "\nNow playing: " .. (radiom.musicName or "none") .. "\n"

        local barAmount = 20
        local currmax = math.ceil((time / length) * barAmount)
        
        str = str .. string.rep(string.utf8char(9644), barAmount - 5) .. "\n"

        str = str .. string.utf8char(9658)

        for i = 1, barAmount do
            if i <= currmax then
                str = str .. string.utf8char(9632)
            else
                str = str .. string.utf8char(9633)
            end
        end
        
        str = str .. "\n" .. formatTime(time) .. " / " .. formatTime(length) .. "\n"
        
        str = str .. string.rep(string.utf8char(9644), barAmount - 5) .. "\n"
        
        str = str .. "Volume: " .. tostring(radiom.volume) .. "\n"

        setName(str)
    end)
else
    local weldedto = chip():isWeldedTo()
    
    hook.add("radiomReady", "start", function()
        timer.simple(1, function()
            radiom:start()
            
            radiom:setFadeMin(500)
            radiom:setFadeMax(1500)
            
            radiom:setVolume(0.8)
        end)
    end)
    
    hook.add("ClientInitialized", "", function(ply)
        if weldedto then
            net.start("weld")
            net.writeEntity(weldedto)
            net.send(ply)
        end
    end)
    
    hook.add("playersay", "radio_cmd", function(ply, text)
        if ply ~= owner() then return end

        local args = string.explode(" ", text)
        local cmd = args[1]
        table.remove(args, 1)
        
        -- lazy to do proper cmd system since only a few cmd
        
        if cmd == "!skip" then
            radiom:skip()
            print("skipped")
            
            return ""
        elseif cmd == "!volume" then
            local vol = tonumber(args[1])

            if vol then
                radiom:setVolume(vol)
                print("volume set to " .. vol)
            end
            
            return ""
        elseif cmd == "!search" then
            if args[1] then
                local found = radiom:searchPlay(tostring(args[1]))
                
                if found then
                    print("Song found")
                else
                    print("Song not found")
                end
            end
            
            return ""
        elseif cmd == "!time" then
            local time = tonumber(args[1])
            
            if time then
                radiom:setTime(time)
                print("time set to " .. time)
            end
            
            return ""
        elseif cmd == "!add" then
            local url = tostring(args[1])
            
            if url then
                radiom:addSong(url)
                
                print("Added song to wait list")
            end
            
            return ""
        end
    end)
end
