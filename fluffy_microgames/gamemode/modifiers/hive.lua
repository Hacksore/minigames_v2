MOD.Name = 'Hive'
MOD.Region = 'knockback'
MOD.SurviveValue = 1
MOD.ScoreValue = 0.2
MOD.ScoringPane = true
MOD.WinValue = 3
MOD.RoundTime = 30

local function spawnBees()
    local number = GAMEMODE:PlayerScale(0.4, 3, 6)
    local positions = GAMEMODE:GetRandomLocations(number, 'sky')

    for i=1,number do
        local pos = positions[i]
        local bee = ents.Create("npc_manhack")
        bee:SetPos(pos)
        bee:Spawn()
        bee:SetMaxHealth(1)
        bee:SetHealth(1)
    end
end

local function spawnQueen()
    local number = GAMEMODE:PlayerScale(2, 3, 16)
    local positions = GAMEMODE:GetRandomLocations(number, 'sky')

    for i=1,number do
        local pos = positions[i]
        local queen = ents.Create("npc_manhack")
        queen:SetPos(pos)
        queen:Spawn()
        queen:SetMaxHealth(200)
        queen:SetHealth(200)
        queen:SetModelScale(5)
    end
end


function MOD:OnNPCKilled(npc, attacker, inflictor)
    if not attacker:IsPlayer() then return end
    if npc:GetClass() != "npc_manhack" then return end
    
    attacker:AddMScore(1)
end

function MOD:Initialize()
    spawnBees()
    spawnQueen()
    GAMEMODE:Announce("Who angered the bees!?")
end

function MOD:Loadout(ply)
    ply:Give('weapon_smg1')
    ply:GiveAmmo(9999, 4, true)
end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
end

MOD.ThinkTime = 1
function MOD:Think()
    spawnBees()
end