-- Generated with FluffyStore Creator
ITEM = {}
ITEM.VanillaID = 'clockmask'
ITEM.Name = 'Minute to Midnight'
ITEM.Model = 'models/props_trainstation/trainstation_clock001.mdl'
ITEM.Attachment = 'eyes'
ITEM.Slot = 'face'

ITEM.Modify = {
	scale = 0.15,
	offset = Vector(3, 0, 0),
}

SHOP:RegisterHat( ITEM )

-- Generated with FluffyStore Creator
ITEM = {}
ITEM.VanillaID = 'tiremask'
ITEM.Name = 'Tired Out'
ITEM.Model = 'models/props_vehicles/carparts_tire01a.mdl'
ITEM.Attachment = 'eyes'
ITEM.Slot = 'face'

ITEM.Modify = {
	scale = 0.4,
	offset = Vector(0, 0, -0.6),
	angle = Angle(0, 90, 0),
}

SHOP:RegisterHat( ITEM )