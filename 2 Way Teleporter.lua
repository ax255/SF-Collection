--@name 2 Way Teleporter
--@author Ax25
--@server

local seats = {}
local saved = {}

function getOtherSeat(seat)
    for i, s in pairs(seats) do 
        if seat ~= s then
            return s
        end
    end
end

function handleSeat(ply, vehicle)

    if not ( ply and ply:isValid() ) or not ( vehicle and vehicle:isValid() ) then
        return
    end

    if seats[vehicle:entIndex()] and vehicle.busy then
        vehicle:ejectDriver()
        return
    end

    if seats[vehicle:entIndex()] then

        vehicle.busy = true

        local oldPos = vehicle:getPos()
        local otherSeat = getOtherSeat(vehicle)

        vehicle:setPos(otherSeat:getPos())
        vehicle:ejectDriver()

        vehicle:setPos(oldPos)

        vehicle.busy = false

    end

end

if getUserdata() ~= "" then
    saved = bit.stringToTable(getUserdata())
end

if not table.isEmpty(saved) then

    hook.add("DupeFinished", "restore", function(tbl)

        for entIndex, seat in pairs(tbl) do

            if saved[entIndex] then
                seats[seat:entIndex()] = seat
            end

        end

        setUserdata(bit.tableToString(seats))

        hook.add("PlayerEnteredVehicle", "teleporter", handleSeat)

    end)

else

    local seat1 = prop.createSent(chip():getPos() + Vector(-30, 0, 30), Angle(), "phx_seat", true)
    local seat2 = prop.createSent(chip():getPos() + Vector(30, 0, 30), Angle(), "phx_seat", true)

    seats[seat1:entIndex()] = seat1
    seats[seat2:entIndex()] = seat2

    setUserdata(bit.tableToString(seats))

    hook.add("PlayerEnteredVehicle", "teleporter", handleSeat)

end