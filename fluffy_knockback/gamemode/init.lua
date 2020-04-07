AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Give the player these weapons on loadout
function GM:PlayerLoadout( ply )
    ply:StripWeapons()
    ply:StripAmmo()
    ply:Give('weapon_stunstick')
    -- Health goes the opposite way to normal in this gamemode
    -- 500HP = WHOA
    -- 1HP = fine!
    ply:SetHealth(1)
    ply:SetMaxHealth(500)
    ply:SetJumpPower(350)
end

-- Apply knockback proportional to health when damaged
function GM:EntityTakeDamage(enttarget, dmginfo)
    if not enttarget:IsPlayer() then return end
    if dmginfo:GetAttacker():IsPlayer() then
        local hp = enttarget:Health()
        local knockback = math.Clamp(hp + dmginfo:GetDamage(), 0, 500)
        enttarget:SetHealth(knockback)
        
        -- Apply knockback
        local v = dmginfo:GetDamageForce():GetNormalized()
        --v.z = math.max(math.abs(v.z) * 0.3, 0.001)
        enttarget:SetGroundEntity(nil)
        enttarget:SetVelocity(v * knockback * 4)
        return true
    elseif dmginfo:GetAttacker():GetClass() == 'trigger_hurt' then
    end
end