UNBOX = {}
UNBOX.VanillaID = 'unbox_test'
UNBOX.Items = {
	'roadsign2',
	'roadsign7',
	'tracer_rainbow',
    SHOP.PaintList['grape'],
	SHOP.PaintList['lime'],
	SHOP.PaintList['watermelon'],
}

UNBOX.Name='Test Box'
UNBOX.Type='Crate'
UNBOX.Model='models/props_junk/wood_crate001a.mdl'

UNBOX.Chances = {
    3,
    2,
    1,
    2,
    2,
    2,
}
SHOP:RegisterUnbox( UNBOX )