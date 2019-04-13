-- Prepare some prepared queries to make database stuff faster and more secure
hook.Add('InitPostEntity', 'PreparedInventoryQueries', function()
	local db = GAMEMODE:CheckDBConnection()
	GAMEMODE.MinigamesPQueries['getinventory'] = db:prepare("SELECT inventory, equipped FROM minigames_inventory WHERE `steamid64` = ?;")
	GAMEMODE.MinigamesPQueries['addnewinventory'] = db:prepare("INSERT INTO minigames_inventory VALUES(?, NULL, NULL);")
	GAMEMODE.MinigamesPQueries['updateinventory'] = db:prepare("UPDATE minigames_inventory SET `inventory` = ?, `equipped` = ? WHERE `steamid64` = ?;")
end )

-- Global shop tables to keep track of player inventories
SHOP.PlayerInventories = SHOP.PlayerInventories or {}
SHOP.PlayerEquipped = SHOP.PlayerEquipped or {}
SHOP.PlayerEquippedSlots = SHOP.PlayerEquippedSlots or {}

-- Default inventory for testing purposes
local test_inventory = {
    {VanillaID = 'unbox_test'},
    {VanillaID = 'paintkit_test'},
    {VanillaID = 'testtrail', Name='Hilarious', Rarity=2, Type='Trail', Paintable=true, Material='trails/lol.vmt'},
	{VanillaID = 'testtrail', Name='Hilarious', Rarity=2, Type='Trail', Paintable=true, Material='trails/lol.vmt'},
	{VanillaID = 'tracer_disco'},
    {VanillaID = 'balloon_classic'},
    {VanillaID = 'clockmask'},
	SHOP.PaintList['blueberry'],
	{VanillaID = 'tracer_lol', Locked = true}
}

-- Function to generate a default inventory
-- This should return a table
function SHOP:DefaultInventory()
    return test_inventory
end

-- Save a player's inventory to the database
function SHOP:SaveInventory(ply)
    if not SHOP.PlayerInventories[ply] then return end
    
    local json = util.TableToJSON(SHOP.PlayerInventories[ply], false)
    local json_equipped = util.TableToJSON(SHOP.PlayerEquipped[ply] or {}, false)
    
    local q = GAMEMODE.MinigamesPQueries['updateinventory']
	if not q then return end
    q:setString(1, json)
    q:setString(2, json_equipped)
    q:setString(3, ply:SteamID64())
    
    -- Success function
    function q:onSuccess(data)
        print('success')
    end
    
    -- Print error if any occur (they shouldn't)
    function q:onError(err)
        print(err)
    end
    q:start()
end

-- Load a player's inventory
function SHOP:LoadInventory(ply, callback)
    local q = GAMEMODE.MinigamesPQueries['getinventory']
	if not q then return end
    q:setString(1, ply:SteamID64())
    
    -- Success function
    function q:onSuccess(data)
        if type(data) == 'table' and #data > 0 then
            -- Load information from DB
            SHOP.PlayerInventories[ply] = util.JSONToTable(data[1]['inventory'] or '') or {}
            SHOP.PlayerEquipped[ply] = util.JSONToTable(data[1]['equipped'] or '') or {}
            
            if #SHOP.PlayerEquipped[ply] > 0 then
                for k, v in pairs(SHOP.PlayerEquipped[ply]) do
                    if not v then continue end
                    SHOP:EquipItem(k, ply, true)
                end
            end
        else
            -- Add new blank row into the table
            local q = GAMEMODE.MinigamesPQueries['addnewinventory']
            q:setString(1, ply:SteamID64())
            q:start()
            
            SHOP.PlayerInventories[ply] = SHOP:DefaultInventory()
        end
        
        if callback then
            callback(inventory)
        end
    end
    
    -- Print error if any occur (they shouldn't)
    function q:onError(err)
        print(err)
    end
    q:start()
end

-- Transmit the equipped table to the clients
-- This makes sure the server & client about what items are equipped
function SHOP:NetworkEquipped(ply)
	if not SHOP.PlayerEquipped[ply] then return end
	
    net.Start('SHOP_NetworkEquipped')
        net.WriteTable(SHOP.PlayerEquipped[ply])
    net.Send(ply)
end

-- Network the entire inventory to the client
-- Only use this when needed
function SHOP:NetworkInventory(ply)
    net.Start('SHOP_NetworkInventory')
        net.WriteTable(SHOP.PlayerInventories[ply])
    net.Send(ply)
end

-- Add an item to the inventory
function SHOP:AddItem(ITEM, ply, nosave)
    if type(ITEM) != 'table' then
        ITEM = {VanillaID = ITEM}
    end
    if not SHOP.VanillaItems[ITEM.VanillaID] then return end
    
    if not SHOP.PlayerInventories[ply] then return end
    local key = table.insert(SHOP.PlayerInventories[ply], ITEM)
    
    -- Network change to the client
    net.Start('SHOP_InventoryChange')
        net.WriteString('ADD')
        net.WriteTable(ITEM)
    net.Send(ply)
    
    -- Save the inventory changes
    if not nosave then
        SHOP:SaveInventory(ply)
    end
	
	return key
end

-- Remove an item from the inventory
function SHOP:RemoveItem(key, ply, nosave)
    if not SHOP.PlayerInventories[ply] then return end
	if not SHOP.PlayerInventories[ply][key] then return end
	table.remove(SHOP.PlayerInventories[ply], key)
	
	-- Network changes
	net.Start('SHOP_InventoryChange')
		net.WriteString('REMOVE')
		net.WriteInt(key, 16)
	net.Send(ply)
	SHOP:NetworkEquipped(ply)
    
    -- Save the inventory changes
    if not nosave then
        SHOP:SaveInventory(ply)
    end
end

function SHOP:EquipItem(key, ply, state)
    -- Handle equipping/unequipping of items
    if not SHOP.PlayerEquipped[ply] then SHOP.PlayerEquipped[ply] = {} end
	if not SHOP.PlayerEquippedSlots[ply] then SHOP.PlayerEquippedSlots[ply] = {} end
	
	-- Determine whether to equip or not
	local equip = false
	if state == nil then
		equip = !SHOP.PlayerEquipped[ply][key]
	else
		equip = state
	end
	
    if equip then
        -- Equip the item
        local ITEM = SHOP.PlayerInventories[ply][key]
        ITEM = SHOP:ParseVanillaItem(ITEM)
		
		-- Check the slot is empty
		local slot = ITEM.Slot or ITEM.Type
		print(slot)
		if SHOP.PlayerEquippedSlots[ply][slot] then return end
    
        local equipped = false
        if ITEM.Type == 'Hat' then
            equipped = SHOP:EquipCosmetic(ITEM, ply)
        elseif ITEM.Type == 'Tracer' then
            equipped = SHOP:EquipTracer(ITEM, ply)
        elseif ITEM.Type == 'Trail' then
            equipped = SHOP:EquipTrail(ITEM, ply)
        end
    
		-- If equip was successful, store the change
        if equipped then
            SHOP.PlayerEquipped[ply][key] = true
			SHOP.PlayerEquippedSlots[ply][slot] = true
            SHOP:NetworkEquipped(ply)
        end
    else
		-- Unequip the item
        local ITEM = SHOP.PlayerInventories[ply][key]
        ITEM = SHOP:ParseVanillaItem(ITEM)
		
		local slot = ITEM.Slot or ITEM.Type
    
        if ITEM.Type == 'Hat' then
            SHOP:UnequipCosmetic(ITEM, ply)
        elseif ITEM.Type == 'Tracer' then
            SHOP:UnequipTracer(ply)
        elseif ITEM.Type == 'Trail' then
            SHOP:UnequipTrail(ply)
        end
        
		-- Clear the table
        SHOP.PlayerEquipped[ply][key] = nil
		SHOP.PlayerEquippedSlots[ply][slot] = nil
        SHOP:NetworkEquipped(ply)
    end
end

hook.Add('PlayerInitialSpawn', 'LoadShopInventory', function(ply)
    -- to do
    SHOP.PlayerInventories[ply] = test_inventory
end)

hook.Add('PlayerDisconnected', 'ShopDisconnect', function(ply)
    -- save inventory here
    
    SHOP.PlayerInventories[ply] = nil
end)

net.Receive('SHOP_NetworkInventory', function(len, ply)
    -- stop this from being lagged out
    if ply.LastVerification then
        if ply.LastVerification + 5 > CurTime() then return end
    end
    ply.LastVerification = CurTime()
    
    local check = net.ReadString()
    if not SHOP.PlayerInventories[ply] then
        SHOP:LoadInventory(ply, function() SHOP:NetworkInventory(ply) end)
        return
    end
    
    if check != SHOP:HashTable(SHOP.PlayerInventories[ply]) then
        SHOP:NetworkInventory(ply)
    end
end)

net.Receive('SHOP_RequestItemAction', function(len, ply)
    if not SHOP.PlayerInventories[ply] then return end
    local action = net.ReadString()
    local key = net.ReadInt(16)
    
    if action == 'EQUIP' then
		-- Handle equipping of items
		SHOP:EquipItem(key, ply)
    elseif action == 'PAINT' then
		-- Handle painting of items
		local paintcan = net.ReadInt(16)
		
		-- Verify the item can be painted
		local ITEM = SHOP.PlayerInventories[ply][key]
		ITEM = SHOP:ParseVanillaItem(ITEM)
		if not ITEM.Paintable then return end
		
		local PAINT = SHOP.PlayerInventories[ply][paintcan]
		if PAINT.Type != 'Paint' then return end
		
		local reequip = false
		-- Unequip the item if it's already equipped
		if SHOP.PlayerEquipped[ply] and SHOP.PlayerEquipped[ply][key] then
			SHOP:EquipItem(key, ply, false)
			reequip = true
		end
		
		SHOP.PlayerInventories[ply][key].Color = PAINT.Color
		SHOP:RemoveItem(paintcan, ply)
		
		-- Reequip the item automagically
		if reequip then
			SHOP:EquipItem(key, ply, true)
		end
	elseif action == 'UNBOX' then
		-- Handle unboxing of items
		SHOP:OpenUnbox(key, ply)
	elseif action == 'DELETE' then
		-- Handle deletion of items
		-- Verify the item isn't locked
		local ITEM = SHOP.PlayerInventories[ply][key]
		ITEM = SHOP:ParseVanillaItem(ITEM)
		if ITEM.Locked then return end
		
		SHOP:RemoveItem(key, ply)
	elseif action == 'GIFT' then
		-- Handle gifting of items
		-- Verify the item isn't locked
		local ITEM = SHOP.PlayerInventories[ply][key]
		ITEM = SHOP:ParseVanillaItem(ITEM)
		if ITEM.Locked then return end
		
		-- Verify the giftee is a player
		local giftee = net.ReadEntity()
		if not IsValid(giftee) then return end
		if not giftee:IsPlayer() then return end
		
		SHOP:AddItem(ITEM, giftee)
		SHOP:RemoveItem(key, ply)
	end
end)