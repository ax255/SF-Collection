--@name Simple Radio
--@author Ax25
--@shared
--@include https://raw.githubusercontent.com/ax255/SF-Collection/main/libs/radio%20manager.lua as radiom
require("radiom")


local playlist = { -- you can make playlist directly into a table format
 "https://autumn.revolt.chat/attachments/dnw_zipoM_qQ7g8yW2jsqjQOfevXQVFjTdDBa8LOmC/[DNB]%20sanj%20-%20last%20minute%20(sakuraburst%20remix).mp3",
 "https://autumn.revolt.chat/attachments/n5k4veguRbhZ9XEBjShIH2skt3Iu6Kphn9YCRwprcm/[DNB]%20Street%20-%20Hacking%20Code.mp3",
 "https://autumn.revolt.chat/attachments/JN6VxNkA71hAASQgIyMSHlHgXKkhmluhcz1PpvDC0I/[dreamless%20wanderer]%20(Camellia)%20-%20shadows%20of%20cats.mp3",
 "https://autumn.revolt.chat/attachments/LLSEe5B6w-at5yJoyQstRJGz9syhj7Xw1uhs5nMSob/[Drumstep]%20-%20Pegboard%20Nerds%20-%20Try%20This%20[Monstercat%20Release].mp3",
}

radiom:fetchPlaylist("https://raw.githubusercontent.com/ax255/public-stuff/main/Live%20Audio%20Asset/output.json") -- you either use a link that point to a json with the links
--radiom:fetchPlaylist(playlist) -- or you use a table you made

if CLIENT then

    radiom.followEnt = owner() -- the sound will follow the given entity
    
else
    
    hook.add("radiomReady", "start", function() -- we start the radio
        radiom:start()
        
        radiom:setFadeMin(500)
        radiom:setFadeMax(2000)
        
        radiom:setVolume(0.5)
    end)
    
end
