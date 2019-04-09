ITEM = {}
ITEM.VanillaID = 'deadhead'
ITEM.Name = 'Dead Head'
ITEM.Model = 'models/Gibs/HGIBS.mdl'
ITEM.Attachment = 'eyes'
ITEM.Slot = 'head'

ITEM.Modify = {
	scale = 1.6,
	offset = Vector( -2.5, 0, 0 ),
	angle = Angle( 0, -15, 0 )
}

SHOP:RegisterHat( ITEM )

ITEM = {}
ITEM.VanillaID = 'stucksawblade'
ITEM.Name = 'Stuck Sawblade'
ITEM.Model = 'models/props_junk/sawblade001a.mdl'
ITEM.Attachment = 'eyes'
ITEM.Slot = 'hat'

ITEM.Modify = {
	scale = 0.2,
	offset = Vector(0, 0, 4),
	angle = Angle(0, 0, 90),
}

SHOP:RegisterHat( ITEM )

ITEM = {}
ITEM.VanillaID = 'harpoonheadache'
ITEM.Name = 'Harpoon Headache'
ITEM.Model = 'models/props_junk/harpoon002a.mdl'
ITEM.Attachment = 'eyes'
ITEM.Slot = 'ears'

ITEM.Modify = {
	scale = 0.2,
	offset = Vector(-2, 0, 2),
	angle = Angle(10, 90, 0),
}

SHOP:RegisterHat( ITEM )