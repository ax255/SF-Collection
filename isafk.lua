--@name isAFK
--@author Ax25 :3
--@shared

if CLIENT then

    local playersStatus = {}
    local status = game.hasFocus()
    local lastStatus = status
    local focus = game.hasFocus()
    local inputAFK = false
    local lastInputTime = timer.curtime()

    local function sendStatus()
        net.start("focusStatus")
        net.writeBool(status)
        net.send()
    end
    sendStatus()

    local function sendPing()
        net.start("ping")
        net.send()
    end
    sendPing()

    timer.create("ping", 4, 0, sendPing)

    timer.create("afkCheck", 0.1, 0, function()

        focus = game.hasFocus()

        if timer.curtime() - lastInputTime > 20 then
            inputAFK = true
        else
            inputAFK = false
        end

        if ( not focus ) or ( inputAFK ) then
            status = false
        else
            status = true 
        end

        if lastStatus ~= status then
            lastStatus = status
            sendStatus()
        end

    end)

    hook.add("inputPressed", "lastInput", function()
        lastInputTime = timer.curtime()
    end)

    hook.add("mousemoved", "lastInput", function()
        lastInputTime = timer.curtime()
    end)

    net.receive("Status", function()
        playersStatus = net.readTable()
    end)

    if player() == owner() then
       enableHud(owner(), true) 
    end

    local fontRoboto60 = render.createFont(
        "Roboto",
        60,
        500,
        false,
        false,
        true,
        false,
        0,
        true,
        0
    )

    hook.add("PostDrawTranslucentRenderables", "", function()

        for k,data in pairs(playersStatus) do

            local ply = player(k)
            if not ply:isValid() then
                playersStatus[k] = nil
                continue
            end

            local dist = player():getPos():getDistance(ply:getPos())

            if ( not data.status and player() ~= ply ) and dist < 1000 then

                local m = ply:getMatrix()
                local pos = ply:worldToLocal( ply:getAttachment( ply:lookupAttachment("eyes") ) )
                m:translate(pos+Vector(0, 0, 20))
                local ang = (render.getEyePos() - m:getTranslation()):getAngle() + Angle(90, 0, 0)
                m:setAngles(ang)
                m:rotate(Angle(0, 90, 0))
                m:setScale(Vector(0.1, -0.1))

                render.pushMatrix(m)
                    render.enableDepth(true)
                    render.setColor(Color(10, 167, 238))
                    render.setFont(fontRoboto60)
                    render.drawSimpleText(0, 0, "AFK", 1, 1)
                render.popMatrix()

            end

        end

    end)

else

    local playersStatus = {}

    local function createPlyTable(ply)
        playersStatus[ply:getUserID()] = {}
        playersStatus[ply:getUserID()].status = true
        playersStatus[ply:getUserID()].lastPing = 0
        playersStatus[ply:getUserID()].lastSvInput = timer.curtime()
    end

    net.receive("focusStatus", function(_,ply)
        if not playersStatus[ply:getUserID()] then
            createPlyTable(ply)
        end
        playersStatus[ply:getUserID()].status = net.readBool()
        playersStatus[ply:getUserID()].lastPing = timer.curtime()
        --print(ply,playersStatus[ply:getUserID()].status)
    end)

    net.receive("ping", function(_,ply)
        if not playersStatus[ply:getUserID()] then
            createPlyTable(ply)
        end
        playersStatus[ply:getUserID()].lastPing = timer.curtime()
    end)

    timer.create("broadcastStatus", 1, 0, function()
        for k,_ in pairs(playersStatus) do
            if not player(k):isValid() then
                playersStatus[k] = nil
            end 
        end
        net.start("Status")
        net.writeTable(playersStatus)
        net.send()
    end)

    hook.add("KeyPress", "svlastInput", function(ply)
        if not playersStatus[ply:getUserID()] then
            createPlyTable(ply)
        end
        playersStatus[ply:getUserID()].lastSvInput = timer.curtime() 
    end)

    timer.create("checkSvLastInput", 2, 0, function() -- incase client stop sending data
        for k,ply in pairs(find.allPlayers()) do

            if not playersStatus[ply:getUserID()] then
                createPlyTable(ply)
            end

            if timer.curtime() - playersStatus[ply:getUserID()].lastPing > 6 then

                if timer.curtime() - playersStatus[ply:getUserID()].lastSvInput > 20 then
                    playersStatus[ply:getUserID()].status = false
                else
                    playersStatus[ply:getUserID()].status = true
                end

            end

        end
    end)

end
