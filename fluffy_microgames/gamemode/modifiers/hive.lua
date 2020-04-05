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
        bee:SetColor(255, 0, 0, 255)
        bee:SetMaterial("models/props_combine/portalball001_sheet")
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
        queen:SetMaxHealth(150)
        queen:SetHealth(150)
        queen:SetModelScale(3)
        queen:SetColor(255, 0, 0, 255)
        queen:SetMaterial("models/props_combine/portalball001_sheet")
        --models/props_combine/portalball001_sheet
        --models/shiny
        --models/player/shared/gold_player
        --models/debug/debugwhite
        --queen:SetRenderMode() was meant to fix colour but didnt work, use material instead. if you get the rendermode thing too work remember to apply it too normal manhacks too (bee) oh and dont forget to apply the material too both
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
    ply:SetMaxHealth(50)
    ply:SetHealth(50)
    ply:Give('weapon_shotgun')
    ply:GiveAmmo(9999, 7, true)
    --ply:GiveAmmo(9999, 2, true) ar2 altfire balls
    --ply:GiveAmmo(9999, 4, true) smg1 ammo

end

function MOD:EntityTakeDamage(ent, dmg)
    if not ent:IsPlayer() then return end
end

MOD.ThinkTime = 1
function MOD:Think()
    spawnBees()
end