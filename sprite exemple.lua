--@name sprite exemple
--@author Ax25 :3
--@shared
--@include https://raw.githubusercontent.com/ax255/SF-Collection/main/libs/Sprite%20Loader.lua as sprite_loader.lua

dofile("sprite_loader.lua")

if CLIENT then
    
    setSpriteRes(512)

    addSprite( "1000yardstare", discordEmojiUrl("1190691392314425346") )
    addSprite( "TBHCreatura", discordEmojiUrl("1147243448282390649") )
    addSprite( "bored", discordEmojiUrl("1157309890742726716") )
    addSprite( "cool1", discordEmojiUrl("1129511160601911470") )
    addSprite( "depression", discordEmojiUrl("1156664291232055467") )
    addSprite( "devious", discordEmojiUrl("1135190956883329269") )
    addSprite( "enraged", discordEmojiUrl("1144763102622126163") )
    addSprite( "facepalm", discordEmojiUrl("1157310302761791660") )
    addSprite( "faku", discordEmojiUrl("1142620856284090368") )
    addSprite( "gyat", discordEmojiUrl("1134218042411323464") )
    addSprite( "heh", discordEmojiUrl("726833110947463210") )
    addSprite( "hey", discordEmojiUrl("1134209092353806356") )
    addSprite( "hollow", discordEmojiUrl("1124326227881246801") )
    addSprite( "huh", discordEmojiUrl("1154859264645537924") )
    addSprite( "laughatthisuser", discordEmojiUrl("1129511555491446874") )
    addSprite( "mischevious", discordEmojiUrl("1135190991939317770") )
    addSprite( "mocking", discordEmojiUrl("1157309690775076985") )
    addSprite( "no", discordEmojiUrl("1138099025296506900") )
    addSprite( "obamna", discordEmojiUrl("868893471782613072") )
    addSprite( "ohhhhhhhhhhhhhhhh", discordEmojiUrl("1129511610646544494") )
    addSprite( "pessitroll", discordEmojiUrl("1135629995566448680") )
    addSprite( "prowler07", discordEmojiUrl("1121123064340545628") )
    addSprite( "rage-1", discordEmojiUrl("1134212554990833674") )
    addSprite( "rager", discordEmojiUrl("1140371510637383761") )
    addSprite( "rizzler", discordEmojiUrl("1134218407663902841") )
    addSprite( "skeletonappear", discordEmojiUrl("1148242046725922908") )
    addSprite( "skull2", discordEmojiUrl("1120380953794195560") )
    addSprite( "swagin", discordEmojiUrl("1160305409828077568") )
    addSprite( "toesucky", discordEmojiUrl("1022579266233315349") )
    addSprite( "trolldeluxe", discordEmojiUrl("1132303488886525993") )
    addSprite( "trolldespair", discordEmojiUrl("1132266717658239016") )
    addSprite( "trollface", discordEmojiUrl("1132266652508094494") )
    addSprite( "true", discordEmojiUrl("1160142405836738672") )
    addSprite( "umadbro", discordEmojiUrl("1134980138363256932") )
    addSprite( "victor", discordEmojiUrl("611126258234949642") )
    addSprite( "what", discordEmojiUrl("1017823194389946449") )
    addSprite( "wowza", discordEmojiUrl("1129511540547137636") )
    addSprite( "yes", discordEmojiUrl("1138099010121506836") )
    addSprite( "yippiee", discordEmojiUrl("1147889980966969364") )
    addSprite( "zynxBynx1", discordEmojiUrl("1115898197093662731") )

    hook.add("render", "spriteExmple", function()
        
        render.setFilterMag(1)
        render.setFilterMin(1)
        
        render.setColor(Color(50, 50, 50, 255))
        render.drawRect(0, 0, 512, 512)

        render.setColor(Color(255, 255, 255, 255))
        --drawSprite("yippiee", 0, 0, 256, 256)
        drawSprite("prowler07", 256, 0, 256, 256, true)
        drawSprite("TBHCreatura", 0, 256, 256, 256, true)
        drawSprite("swagin", 256, 256, 256, 256, true)

        local numRows = math.ceil(math.sqrt(spritertIndex))
        local squareSize = 256 / numRows
        
        for i = 1, spritertIndex do
            local row = math.floor((i - 1) / numRows)
            local col = (i - 1) % numRows
            local x = col * squareSize
            local y = row * squareSize
            
            render.setColor(Color(255, 255, 255, 255))
        
            render.setRenderTargetTexture("sprites" .. i)
            render.drawTexturedRect(x, y, squareSize, squareSize)
            
            render.drawText(x + squareSize/2, y, "RT: sprites"..i, 1)
            render.setColor(Color(255, 0, 0, 100))
            render.drawRectOutline(x, y, squareSize+1, squareSize+1, 1)
            
        end
        
    end)
    
else
   
    local screen=chip():isWeldedTo()
        
    if screen then
        screen:linkComponent(chip())
    end 
    
end
