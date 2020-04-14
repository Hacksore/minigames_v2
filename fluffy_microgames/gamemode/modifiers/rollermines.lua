MOD.Name = 'Rollermines'
-- MOD.Region = 'knockback'

MOD.SurviveValue = 3

local function spawnRollermines()
    local number = GAMEMODE:PlayerScale(1, 1, 5)
    local positions = GAMEMODE.GetRandomLocations(number, 'sky')

    for i=1,number do
        local pos = positions[i]
        local ent = ents.Create('npc_rollermine')
        ent:SetPos(pos)
        ent:Spawn()
    end
end

function MOD:Initialize()
    spawnRollermines()
    GAMEMODE:Announce("Look out!")
end

function MOD:Loadout(ply)
    ply.SetMaxHealth(10)
    ply.SetHealth(10)
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
end

MOD.ThinkTime = 1
function MOD:Think()
    spawnRollermines()
end