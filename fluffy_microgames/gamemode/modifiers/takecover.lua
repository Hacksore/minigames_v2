MOD.Name = 'Ambush'
MOD.Region = 'empty'

MOD.SurviveValue = 4

local function spawnSnipers()
    local number = GAMEMODE:PlayerScale(0.5, 10, 15)
    local positions = GAMEMODE:GetRandomLocations(number, 'crate')

    for i=1,number do
        local pos = positions[i] + Vector(0, 0, 32)
        local ent = ents.Create("npc_sniper") 
        ent:SetPos(pos)
        ent:Spawn()
    end
end

function MOD:Initialize()
    spawnSnipers()
    GAMEMODE:Announce("Snipers,", "Take cover!")
end

function MOD:Loadout(ply)
    ply:SetMaxHealth(30)
    ply:SetHealth(30)
end
    
function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
end