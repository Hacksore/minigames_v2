MOD.Name = 'Take Cover!'
MOD.ScoringPane = true

local function spawnSnipers()
    local number = GAMEMODE:PlayerScale(0.75, 2, 16)
    local positions = GAMEMODE:GetRandomLocations(number, 'crate')

    for i=1,number do
        local pos = positions[i] + Vector(0, 0, 32)
        local ent = ents.Create("npc_sniper") 
        sniper:SetPos(pos)
        sniper:Spawn()
        sniper:SetMaxHealth(10)
        sniper:SetHealth(10)
    end
end

function MOD:OnNPCKilled(npc, attacker, inflictor)
    if not attacker:IsPlayer() then return end
    if npc:GetClass() != "npc_sniper" then return end

    attacker:AddMScore(1)
end

function MOD:Initialize()
    spawnSnipers()
    GAMEMODE:Announce("Snipers,", "Take cover!")
end

function MOD:Loadout(ply)
    ply:SetMaxHealth(10)
    ply:SetHealth(10)
    ply:Give("weapon_357")
end
    
function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
end