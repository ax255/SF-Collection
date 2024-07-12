--@name Easy Door
--@author Ax25 :3
--@shared

--- Author https://github.com/ax255
-- This is meant to be a quick replacement for fading doors
-- The door also has a wiremod input incase you want it to work with keypad or other wire mean

local doorInfo = {
    
    openMaterial = "", -- if you just put "" then when the door will open it will just make it transparent
    openingSound = "Doors.Move6", -- the sound the door will do when opening / closing
    blockAll = false, -- true will only let player trough, false will let player, props, etc.. go trough 
    
}

local Whitelist = {
    
    -- The chip automatically add your steam friends to the whitelist but you can still manually add friends here.
    -- Only the SteamID as the index matter, the name is only there to remember what steamID is to who.
    
    [owner():getSteamID()] = "You!", -- don't remove it unless you doesn't want to be able to open the door
    ["STEAM_0:0:63254908"] = "Ax25",
    ["STEAM_0:0:11353744"] = "BigPoop",
    --[] = "",
    
}

local Blacklist = {}

local ver = 1.5
local Debug = false -- don't touch this

if CLIENT then
    
    local ID
    
    net.receive("sv_ID", function(len, ply) -- receiving the door ID from server and rename the chip
        
        ID = net.readInt(len)
        setName("Easy Door:"..tostring(ID))
        
    end)
    
    if player() ~= owner() then return end

    local SteamFriends = {}
    
    local function updateSteamFriend() -- Update the steam friend list
        
        for v,i in pairs(find.allPlayers()) do
            if i:getFriendStatus() == "friend" then
                table.merge(SteamFriends, { [i:getSteamID()] = i } )
            end
        end
        
        timer.simple(1, function()
            
            net.start("cl_friend")
            net.writeTable(SteamFriends)
            net.send()
            
        end)
        
    end

    updateSteamFriend()
    timer.create("cl_friend", 20, 0, updateSteamFriend) -- we update the steamFriend list every 20 seconds incase a friend join after the door got placed

    local Door
    local boundingBox
    local x,y,z = 0,0,0
    
    enableHud(owner(), true)
    
    net.receive("sv_door", function() -- receiving the door from server
        Door = net.readEntity()
        boundingBox = { ["min"] = Door:obbMins(), ["max"] = Door:obbMaxs() }
    end)
    
    net.receive("sv_boundingBox", function() -- update the bouding box information from the server
        
        local Table = net.readTable()
        x = Table["x"]
        y = Table["y"]
        z = Table["z"]

        if Table["confirm"] then
            hook.remove("postdrawopaquerenderables", "Debug")
        end
        
        if Table["edit"] then
            hook.add("postdrawopaquerenderables", "Debug", editBox)
        end

    end)
    
    function editBox() -- draw the bounding box that will be used for detection

        if not isValid(Door) then return end
        
        render.setColor(Color(255, 255, 255, 100))
        render.draw3DWireframeBox(Door:getPos(), Door:getAngles(), (boundingBox.min)-Vector(x, y, z), boundingBox.max+Vector(x, y, z))
        render.setColor(Color(255, 0, 0, 100))
        render.draw3DBox(Door:getPos(), Door:getAngles(), (boundingBox.min)-Vector(x, y, z), boundingBox.max+Vector(x, y, z))

    end
    
    -- Floating Text from 3d2d cam exemple
    
    if player() == owner() then
        
        local scale = 0.03
        local font = render.createFont("Roboto", 256, 400, true)
    
        hook.add("PreDrawTranslucentRenderables", "", function() -- this is to show the door ID when owner has cursor on it
            
            if not isValid(Door) then return end
            
            local tr = owner():getEyeTrace()
            
            if tr.Entity ~= Door then return end
            
            local m = Door:getMatrix()
            m:translate(boundingBox.min+Vector(0, boundingBox.min.y*-1, 0))
            m:setAngles((eyePos() - m:getTranslation()):getAngle() + Angle(90, 0, 0))
            m:rotate(Angle(0, 90, 0))
            m:setScale(Vector(scale, -scale))
            
            render.pushMatrix(m)
                render.setColor(Color(255, 191, 20, 155))
                render.setColor(Color(10, 167, 238))
                render.setFont(font)
                render.drawSimpleText(0, 0, "DoorID: "..ID, 1, 1)
            render.popMatrix()
        end)
        
    end

else
    
    local Friends = {}
    local Door
    local boundingBox
    local ID = math.random(1,9999)
    local edit = false
    local Door_wl

    if chip():isWeldedTo() then
        Door = chip():isWeldedTo()
        boundingBox = { ["min"] = Door:obbMins(), ["max"] = Door:obbMaxs() }
        
        doorInfo.oldColor = Door:getColor()
        doorInfo.oldMaterial = Door:getMaterial()
        
        wire.adjustInputs({ "Open" }, { "NORMAL" })
        Door_wl = wire.getWirelink(chip())
    else
        throw("Chip need to be placed on a prop!")
    end
    
    local Players = find.allPlayers()
    
    for v,i in pairs(Players) do -- adding the steamID put in the Whitelist table into friends table
        if Whitelist[i:getSteamID()] and not Blacklist[i:getSteamID()] then
            table.merge(Friends, { [i:getSteamID()] = i } )
        end
    end

    net.receive("cl_friend", function() -- receiving the steam friend list from the owner client
        
        local Table = net.readTable()
        
        for v,i in pairs(Table) do
            if not Friends[v] and not Blacklist[i:getSteamID()] then
                table.merge(Friends, { [v] = i } )
            end 
        end
        
    end)
    
    local x,y,z = 5,5,5 -- Making by default the detection box a bit bigger to not have the need to always go in edit mode to have the door working
    
    function printED(String)
        print(Color(255, 150, 0), "[EasyDoor:"..tostring(ID).."] ",Color(255, 255, 255), String) 
    end
    
    timer.simple(0.5, function()
        
        local Chips = find.byClass("starfall_processor", function(ent)
            return ent:getOwner() == owner() and string.find(ent:getChipName(), "Door", 0) ~= nil and ent ~= chip()
        end)
        
        printED("Door ID:" .. " " .. ID)
        if not Chips[1] then -- if there is an ent in the chips table mean this is not first door placed, so not printing the commands again.
        printED("Welcome to EasyDoor v"..ver)
        printED("!edit ID | bounding box edit mode")
        printED("!add name ID | to add someone into the friendlist")
        printED("!remove name ID | to remove someone from the friendlist")
        printED("If ID not provided command will run on the door you looking at")
        printED("Replacing ID by all in add or remove will execute the command on all door")
        end
        
    end)
        
    hook.add("tick", "playerDetection", function() -- this hook detect if door should be opened or closed
        
        if not Door:isValid() then return end
        
        local Detection = find.inBox( Door:localToWorld((boundingBox.min)-Vector(x, y, z)) , Door:localToWorld((boundingBox.max)+Vector(x, y, z)), function(ent)
            return ent:isPlayer() and Friends[ent:getSteamID()]
        end)
        
        if Door_wl:inputValue("Open") == 1 then
            doorInfo.open = true
        end

        if doorInfo.open ~= doorInfo.openOld then
            doorInfo.openOld = doorInfo.open
            Door:emitSound(doorInfo.openingSound, 75, 100, 100)
            if doorInfo.open then

                doorInfo.oldColor = Door:getColor()
                doorInfo.oldMaterial = Door:getMaterial()
                
                if doorInfo.blockAll then
                Door:setCollisionGroup(15)
                chip():setCollisionGroup(15)
                else
                Door:setCollisionGroup(20)
                chip():setCollisionGroup(20)
                end                
                
                Door:setColor(Color(nil, nil, nil, 100))
                
                if doorInfo.openMaterial ~= "" then
                    chip():setMaterial(doorInfo.openMaterial)
                    Door:setMaterial(doorInfo.openMaterial)
                end
                
            else

                Door:setCollisionGroup(0)
                chip():setCollisionGroup(0)
                
                Door:setColor(Color(nil, nil, nil, 255 ))
                Door:setColor(doorInfo.oldColor)
                
                if doorInfo.openMaterial ~= "" then
                    Door:setMaterial(doorInfo.oldMaterial)
                    chip():setMaterial(doorInfo.oldMaterial)
                end
                    
            end
        end
        
        if Detection[1] then
            doorInfo.open = true
        else
            doorInfo.open = false
        end
        
    end)
    
    function updateBoundingBox(confirm, edit) -- this function is used to update the bouding box size to the client to draw to the hud, also used to activate the edit mode client side
            
        net.start("sv_boundingBox")
        net.writeTable( { ["x"] = x , ["y"] = y , ["z"] = z, ["confirm"] = confirm, ["edit"] = edit } )
        net.send(owner()) 
        
        if edit then
            printED("Edit mode ON")
            printED("Type x or y or z followed by the number of unit you want to increase the detection zone")
            printED("Type confirm to save and exit")
        end
            
    end
    
    function editMode(ply, text) -- this function is running when in edit mode, handling the commands
        
        edit = true
        local Message = string.explode(" ", text)

        if ply == owner() then
            
            if #Message > 2 then
                for i=1,#Message do
                    if type(Message[i]) == "number" then continue end
                    if Message[i] == "x" then
                        x = tonumber(Message[i+1])
                        updateBoundingBox()
                    elseif Message[i] == "y" then
                        y = tonumber(Message[i+1])
                        updateBoundingBox()
                    elseif Message[i] == "z" then
                        z = tonumber(Message[i+1])
                        updateBoundingBox()
                    end
                end    
            return ""
            end
           
            if Message[1] == "x" then
                x = tonumber(Message[2])
                updateBoundingBox()
            elseif Message[1] == "y" then
                y = tonumber(Message[2])
                updateBoundingBox()
            elseif Message[1] == "z" then
                z = tonumber(Message[2])
                updateBoundingBox()
            elseif Message[1] == "confirm" then
                hook.remove("PlayerSay", "confirm")
                edit = nil
                updateBoundingBox(true)
            else
               printED("invalid command, type confirm to exit") 
            end
            
        return ""
        end
        
    end

    
    hook.add("PlayerSay", "command", function(ply, text) -- main commands
        
        local Message = string.explode(" ", text)
        if ply == owner() and not edit then
            
            local tr = owner():getEyeTrace()
           
            if Message[1] == "!edit" and (Message[2] == tostring(ID) or tr.Entity == Door) then
                
                updateBoundingBox(nil, true)
                hook.add("PlayerSay", "confirm", editMode)
                
            return ""
            elseif Message[1] == "!add" and (Message[3] == tostring(ID) or Message[3] == "all" or tr.Entity == Door) then
                
                local Target = find.playersByName(Message[2])
                
                if Target[1] then
                    
                    if not isValid(Target[1]) then return end
                    
                    if not Friends[Target[1]:getSteamID()] then
                        table.merge(Friends, {[Target[1]:getSteamID()]=Target[1]})
                        Blacklist[Target[1]:getSteamID()] = nil
                        printED(Target[1]:getName() .. " added to friendlist.")
                    else
                        printED("Player already in friendlist.")
                    end
                    
                else
                    printED("Player not found.") 
                end
            
            return ""
            elseif Message[1] == "!remove" and (Message[3] == tostring(ID) or Message[3] == "all" or tr.Entity == Door) then
                
                local Target = find.playersByName(Message[2])
                
                if Target[1] then
                    
                    if not isValid(Target[1]) then return end
                    
                    if Friends[Target[1]:getSteamID()] then
                        Friends[Target[1]:getSteamID()] = nil
                        Blacklist[Target[1]:getSteamID()] = Target[1]
                        printED(Target[1]:getName() .. " removed from friendlist.")
                    else
                        printED("Player not in friendlist.")
                    end
                    
                else
                    printED("Player not found.") 
                end
            return ""
            end
            
        end
        
    end)

    hook.add("ClientInitialized", "firstPlace", function(ply)
        if ply == owner() then
            net.start("sv_door") -- sending the door to the owner client
            net.writeEntity(Door)
            net.send(owner())
        end
        
        net.start("sv_ID") -- sending the ID of the door to client
        net.writeInt(ID,64)
        net.send(ply)
        
    end)
    

end
