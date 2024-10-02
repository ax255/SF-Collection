--@name oneway prop
--@author Ax25 :3
--@server

--[[

    To make a prop oneway write in chat !oneway while looking at it
    you can do the command !undo while looking at the prop to restore it

--]]

local exteriorMat = "brick/brick_model" -- People on the other way of the props will see this material
local interiorMat = "models/props_combine/com_shield001a" -- This material has to be a shader material to be able to see trough world glow props

local saved = false
local ents = {}

local extQueue = {}

timer.create("extqeue", 0.05, 0, function()
    local data = extQueue[1]
    if not data then return end
    
    local ent = data.ent

    try(function()
        local ext = prop.create(ent:getPos() + (data.offset * data.obbz / 4 ), ent:getAngles(), ent:getModel())
        ext:setMaterial(exteriorMat)
        ext:setSolid(false)
        ext:setRenderMode(9)
        ext:setParent(ent)
        ext:doNotDuplicate()
        
        ents[ent:entIndex()].ext = ext
        
        table.remove(extQueue, 1)
        
        setUserdata(bit.tableToString(ents))
    end)
end)

local function onewayify(ent, saveTbl)
    if saveTbl then
        ents[ent:entIndex()] = saveTbl
    else
        ents[ent:entIndex()] = {
            ent = ent,
            oldMat = ent:getMaterial(),
        }
    end
    
    local obb = ent:obbSize()
    local offset = ents[ent:entIndex()].offset
    
    if not offset then
        offset = ( owner():getPos():setZ(0) - ent:getPos():setZ(0) ):getNormalized()
        offset:round(0)
        offset = offset * -1
        
        ents[ent:entIndex()].offset = offset
    end
    
    
    extQueue[#extQueue + 1] = {
        offset = offset,
        obbz = obb.z,
        ent = ent
    }

    ent:setSolid(false)
    ent:setMaterial(interiorMat)
    
    ents[ent:entIndex()].ext = ext

    setUserdata(bit.tableToString(ents))
end

local function restore(ent)
    local data = ents[ent:entIndex()]
    
    data.ext:remove()
    data.ent:setMaterial(data.oldMat)
    data.ent:setSolid(true)
    
    ents[ent:entIndex()] = nil
    setUserdata(bit.tableToString(ents))
end

--[[
hook.add("KeyPress", "onewayify", function(ply, key)
    if ply == owner() and key == IN_KEY.RELOAD then
        local tr = owner():getEyeTrace()
        
        if tr.Entity and hasPermission("entities.canTool", tr.Entity) then
            onewayify(tr.Entity)
        else
            print("Invalid prop or doesn't have permission to tool the prop") 
        end
    end
end)
]]

hook.add("Removed", "restore", function()
    if not saved then
        for i, data in pairs(ents) do
            local ent = data.ent

            if ent and ent:isValid() then
                restore(ent)
            end
        end 
    end
end)

hook.add("DupeFinished", "restore", function(entTbl)
    if getUserdata() ~= "" then
        local oldEnts = bit.stringToTable(getUserdata())
        
        for oldIndex, ent in pairs(entTbl) do
            if oldEnts[oldIndex] then
                oldEnts[oldIndex].ent = ent
                onewayify(ent, oldEnts[oldIndex])
            end
        end
    end
end)

local CMDS = {}
local prefixs = {
    ["!"] = true,
    ["/"] = true,
    ["."] = true,
}

hook.add("playersay", "cmd", function(ply, text)
    if ply ~= owner() then return end
    
    local prefix = string.sub(text, 1, 1)
    
    if prefixs[prefix] then
        text = string.sub(text, 2, -1)

        local args = string.explode(" ", text)
        local name = args[1]
        
        table.remove(args, 1)
        
        if CMDS[name] then
            CMDS[name](unpack(args))
            return ""
        end
    end
end)

CMDS["undo"] = function()
    local entities = find.inRay(owner():getEyePos(), owner():getEyePos() + owner():getAimVector() * 2000, Vector(-1, -1, -1), Vector(1, 1, 1), function(ent) 
        return ent ~= owner() and ent:getOwner() and ent:getOwner() == owner()
    end)

    for i, ent in ipairs(entities) do
        if ent and ent:isValid() and ents[ent:entIndex()] then
            restore(ent)
            break
        end
    end
end

CMDS["oneway"] = function()
    local tr = owner():getEyeTrace()
    
    if tr.Entity and hasPermission("entities.canTool", tr.Entity) then
        onewayify(tr.Entity)
    else
        print("Invalid prop or doesn't have permission to tool the prop") 
    end
end
