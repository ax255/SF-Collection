--@name radio lib exemple
--@author Ax25 :3
--@shared
--@include libs/radio_manager_lib.txt

require("libs/radio_manager_lib.txt")
--radiom:fetchPlaylist("https://raw.githubusercontent.com/ax255/public-stuff/main/Live%20Audio%20Asset/output.json") -- you can either fetch the playlist from an url

local playlist = {
 "https://autumn.revolt.chat/attachments/dnw_zipoM_qQ7g8yW2jsqjQOfevXQVFjTdDBa8LOmC/[DNB]%20sanj%20-%20last%20minute%20(sakuraburst%20remix).mp3",
 "https://autumn.revolt.chat/attachments/n5k4veguRbhZ9XEBjShIH2skt3Iu6Kphn9YCRwprcm/[DNB]%20Street%20-%20Hacking%20Code.mp3",
 "https://autumn.revolt.chat/attachments/JN6VxNkA71hAASQgIyMSHlHgXKkhmluhcz1PpvDC0I/[dreamless%20wanderer]%20(Camellia)%20-%20shadows%20of%20cats.mp3",
 "https://autumn.revolt.chat/attachments/LLSEe5B6w-at5yJoyQstRJGz9syhj7Xw1uhs5nMSob/[Drumstep]%20-%20Pegboard%20Nerds%20-%20Try%20This%20[Monstercat%20Release].mp3",
 "https://autumn.revolt.chat/attachments/Umtfu6B1ptP3YrKGBV6NwrlMKh_g0kYqfFw1vqzANJ/[Drumstep]%20Camellia%20-%20Epimerization.mp3",
 "https://autumn.revolt.chat/attachments/7CIZ5yL4j_D8OfBZwqEVX9nbG6zSuiWKlZ1jk26GFo/[DRUMSTEP]%20USAO%20-%20Showdown.mp3",
 "https://autumn.revolt.chat/attachments/Wvv7-2t9tSeRyRIzEiidw9CAA12rCWgT9899OesuI9/[Dubstep]%20-%20Pegboard%20Nerds%20&%20NGHTMRE%20-%20Superstar%20(feat.%20Krewella)%20[Monstercat%20Release].mp3",
 "https://autumn.revolt.chat/attachments/B5vNvyzVq8s_CQYX3TZLkLdERuKcJm4eX1h6ZYOG1G/[Dubstep]%20-%20Razihel%20&%20Virtual%20Riot%20-%20One%20For%20All,%20All%20For%20One%20[Monstercat%20Release].mp3",
 "https://autumn.revolt.chat/attachments/n2ikHbyKpejmIOmlS410_RmzPRETWWoXmeWM12psYM/[DUBSTEP]%20Kikuo%20-%20Ten%20Sho%20Sho%20Ten%20Sho.mp3",
 "https://autumn.revolt.chat/attachments/S2aejYxX7JulEwzM4M9ZGgJczXr3W8SCDzLZoZ8LPF/[Electronic]%20-%20Feint%20-%20Phosphor%20(feat.%20Miyoki)%20[Monstercat%20Release].mp3",
 "https://autumn.revolt.chat/attachments/beBzpfDi4iU_EKmVcZBQqlyPVQBoIdgrjrdhXwdlMw/[Electronic]%20-%20Haywyre%20-%20Everchanging%20[Monstercat%20Release].mp3",
 "https://autumn.revolt.chat/attachments/ryh_nof3cu0YnOms4-4HNDg4sVb0Kwwd_oOatQqK6E/[Electro_Drumstep]%20-%20hyleo%20x%20sakuraburst%20-%20Galaxy%20Cutter.mp3",
 "https://autumn.revolt.chat/attachments/pZ0t0GP4wWLjs1KacZ_a9Bj33kl_6d7IOIlG5HNerG/[Eng%20Sub]%20Give%20My%20Regards%20to%20Yotsuya-san%20[Himeringo].mp3",
 "https://autumn.revolt.chat/attachments/myaFoDYEXWnMY7za_w_-xNnDs7Pp13LSUkb7GomMzz/[Eng%20Sub]%20Heisei%20Cataclysm%20[IA].mp3",
 "https://autumn.revolt.chat/attachments/AMIfT0xfRl4tWaGm4I81InCJ4fhVq2MLfAI_Zh4JYN/[English%20Subs]%20Gensou%20no%20Satellite%20-%20Buta-Otome%20[%20Vocal].mp3",
 "https://autumn.revolt.chat/attachments/h3wpncPeWOIBBdXQ2M2o7QSBaL5BWty0aWJy8663aV/[EngSub]%20Asu%20no%20Yozora%20Shoukaihan%20[Yuaru].mp3",
 "https://autumn.revolt.chat/attachments/VsxGpqL9iwX7ugMAMaCE5ZDZnq1xVVdgHjxpPzW4l_/[ENG]%20Outer%20Science%20().mp3",
 "https://autumn.revolt.chat/attachments/6xm1jIgXNoPlhPrdUibj69WGUIf_cvVjQkG9haYHAY/[EXID()]%20%20(Ah%20Yeah)%20Music%20Video%20[Official%20MV].mp3",
 "https://autumn.revolt.chat/attachments/kCjtXbG7FxHRrvyI9YwDHpBPv0G0HPTJnHbT1m_dSe/[EZ2DJ]%20TJ.Hangnail%20-%20(Kamui)%20BGA%20(HD).mp3",
 "https://autumn.revolt.chat/attachments/Se2cstnA1FB-ezddP5zo-1kP41sJ24RGUCu9aIxt-c/[Flaming%20June]%20Maeda%20Jun%20x%20Yanagi%20Nagi%20-%20Killer%20Song%20[Subbed].mp3",
 "https://autumn.revolt.chat/attachments/HcbHPVDwz5IG5GLMkFiUSBUjwbDg0so75MiLuXshV_/[Foreground%20Eclipse]%20Are%20You%20Ready%20To%20Fall%20Into%20Falls%20_%20Fall%20of%20Tears.mp3",
 "https://autumn.revolt.chat/attachments/5R07FWJNT_21GrsBeR0WEHZUFM8RtB4KJjSf81fgWa/[FREEDL&MIRROR]Bloody%20Kiss%20-%20THX30KFOLLOWERS!.mp3",
 "https://autumn.revolt.chat/attachments/7PtsokMKReRW0ohA_NAcgO9zUusSHyj-RCIoX85yFm/[Full%20Flavor]%20-%20CaptainSparklez%20-%20Revenge%20(Reek%20Remix).mp3",
 "https://autumn.revolt.chat/attachments/5WzmygWU6gvL051Q7W5q1Z-yKY82WG__mTpFXAE6d_/[FULL%20SONG]%20Akiyama%20Uni%20-%20Kanpan%20Tasogare%20Shinbun.mp3",
 "https://autumn.revolt.chat/attachments/LNBBQ3Yk05WnSUF8JJT3cNvGk-hxywaf7QZORUDFdM/[Future%20Bass]%20Camellia%20-%20First%20Town%20Of%20This%20Journey.mp3",
 "https://autumn.revolt.chat/attachments/7KDyxClxNUj3A9y2TR-q3nLQwADl2K8j2NCV50uUq4/[Future%20Bass]%20YUC'e%20-%20Future%20Cider.mp3",
}
radiom:fetchPlaylist(playlist) -- or fetching it with a table
--radiom:enableDebug()

if SERVER then
    
    hook.add("radiomReady", "start", function()
        radiom:start()
    end)
    
   local screen=chip():isWeldedTo()
        
    if screen then
        screen:linkComponent(chip())
    end
    
else
    
    radiom:setVolume(0.5)
    radiom.shuffle = false

    render.createRenderTarget("Computing")
    local FPS = 60
    local next_frame = 0
    local fps_delta = 1/FPS

    hook.add("renderoffscreen", "Computing", function()

        local now = timer.systime()
        if next_frame > now then return end
        next_frame = now + fps_delta

        render.selectRenderTarget("Computing")
        render.clear(Color(0, 0, 0, 0))

        render.setColor(Color(255, 255, 255, 255))
        
        for num=1, 11 do
            
            local index = num+(radiom.playlistIndex-6)
            
            if index <= 0 then
                index = ( #radiom.playlist - 6 ) + ( num + radiom.playlistIndex )
            elseif index > #radiom.playlist then
                index = (index - #radiom.playlist)
            end

            render.setColor(Color(255, 255, 255, 255))
            render.drawRect(10, 10+(60*(num-1)), 600, 50)
            if num == 6 then
                render.setColor(Color(255, 0, 0, 255))
            else
                render.setColor(Color(0, 0, 0, 255))
            end
            render.drawText(45, 25+(60*(num-1)), (radiom.cleanedPlaylist[index] or "none"), 0)
            render.drawText(30, 25+(60*(num-1)), index, 1)
            
        end

    end)
   
    hook.add("render", "screen", function()
        
        render.setRenderTargetTexture("Computing")
        render.drawTexturedRect(0, 0, 512, 512)
        
    end)
    
end
