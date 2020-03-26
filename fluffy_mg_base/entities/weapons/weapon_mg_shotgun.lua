SWEP.Base = "weapon_mg_base"

if CLIENT then
	SWEP.Slot = 2
	SWEP.SlotPos = 0
    
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
		draw.SimpleText('0', "HL2MPTypeDeath", x + wide/2, y + tall/2.5, Color(241, 196, 15), TEXT_ALIGN_CENTER)
	end
    
    killicon.AddFont("weapon_mg_shotgun", "HL2MPTypeDeath", "0", Color(255, 80, 0, 255))
end

SWEP.PrintName = "Shotgun"
SWEP.Knockback = 300

-- Primary fire damage and aim settings
SWEP.Primary.Damage = 10
SWEP.Primary.Cone = 0.1
SWEP.Primary.Delay = 0.75
SWEP.Primary.NumShots = 6
SWEP.Primary.Sound = Sound("Weapon_Shotgun.Single")
SWEP.Primary.Recoil = 8

-- Primary ammo settings
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Automatic = true

SWEP.Secondary.Automatic = true -- ???

-- Set the model for the gun
-- Using hands is preferred
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.ViewModelFOV = 62
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.HoldType = 'shotgun'

-- I'll be honest I copied this from a older shotgun weapon
-- Since the shotgun has unique reloading function, it needs extra data to handle that
function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Reloading")
    self:NetworkVar("Float", 0, "ReloadTimer")
end

-- Reset reloading information
function SWEP:Deploy()
    self:SetReloading(false)
    self:SetReloadTimer(0)
end

-- Called when the player presses their reload key
function SWEP:Reload()
    if self:GetReloading() then return end
    if self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
        if self:StartReload() then return end
    end
end

-- Handle the reload thinking
function SWEP:StartReload()
    if self:GetReloading() then return false end
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    
    if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return false end
    if self:Clip1() >= self.Primary.ClipSize then return false end
    
    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
    self:SetReloading(true)
    self:SetReloadTimer(CurTime() + self:SequenceDuration())
    return true
end

function SWEP:PerformReload()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    
    if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return false end
    if self:Clip1() >= self.Primary.ClipSize then return false end
    
    self.Owner:RemoveAmmo(1, self.Primary.Ammo, false)
    self:SetClip1(self:Clip1() + 1)
    
    self:SendWeaponAnim(ACT_VM_RELOAD)
    self:EmitSound("Weapon_Shotgun.Reload")
    self:SetReloadTimer(CurTime() + self:SequenceDuration())
    return true
end

function SWEP:FinishReload()
    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
    self:SetReloading(false)
    self:SetReloadTimer(CurTime() + self:SequenceDuration())
end

-- Start the reload function if needed
-- Also stop the user shooting while reloading
function SWEP:CanPrimaryAttack()
    if self:Clip1() <= 0 then
        self:Reload()
        return false
    end
    
    if self:GetReloading() then return false end
    
    return true
end

-- Yet more reloading logic
function SWEP:Think()
    if self:GetReloading() then
        if (self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():KeyDown(IN_ATTACK2)) and self:Clip1() >= 1 then
            self:FinishReload()
            return
        end
        
        if self:GetReloadTimer() <= CurTime() then
            local reloaded = self:PerformReload()
            if not reloaded then
                self:FinishReload()
            end
        end
    end
end

-- Fire both shells on secondary attack
function SWEP:SecondaryAttack()
    if self:Clip1() < 2 then return end
    
    self.Weapon:EmitSound("Weapon_Shotgun.Double")
	self:ShootBullet(self.Primary.Damage, math.floor(self.Primary.NumShots * 1.5), self.Primary.Cone)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay + 0.25)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay + 0.25)
    self:TakePrimaryAmmo(2)
    self.Owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil*2, math.Rand(-0.1, 0.1) * self.Primary.Recoil*2, 0))
    
    -- Adds the strong knockback effect
    self.Owner:SetGroundEntity(NULL) -- Stop the user sticking to the ground
	self.Owner:SetLocalVelocity(self.Owner:GetAimVector() * -self.Knockback)
end