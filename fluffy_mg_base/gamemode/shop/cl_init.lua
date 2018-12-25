include('cl_inventory.lua')
include('cl_render.lua')
include('vgui/ShopMirror.lua')
include('vgui/ShopItemPanel.lua')

-- Fonts used in the inventory interface
surface.CreateFont('FS_I16', {
    font = 'Roboto',
    size = 16,
})

surface.CreateFont('FS_I24', {
    font = 'Coolvetica',
    size = 24,
    weight = 800,
})

surface.CreateFont('FS_I48', {
    font = 'Roboto',
    size = 48,
    weight = 800,
})

-- Colors used in the inventory interface
-- Easy to reskin
SHOP.Color1 = Color(245, 246, 250)
SHOP.Color2 = Color(220, 221, 225)
SHOP.Color3 = Color(0, 168, 255)
SHOP.Color4 = Color(0, 151, 230)

-- Handle equips broadcast from the server
net.Receive('SHOP_BroadcastEquip', function()
    local ply = net.ReadEntity()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    local ITEM = net.ReadTable()
    ITEM = SHOP:ParseVanillaItem(ITEM)
    
    if ITEM.Type == 'Hat' then
        -- See cl_render
        -- Passes off to cosmetic rendering engine
        SHOP:EquipCosmetic(ITEM, ply)
    elseif ITEM.Type == 'Tracer' then
        -- Unfinished
        ply.TracerEffect = ITEM.Effect
    end
end)