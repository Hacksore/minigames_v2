UNBOX = {}
UNBOX.VanillaID = 'paintkit_test'
UNBOX.Items = {
	SHOP.PaintList['banana'],
	SHOP.PaintList['cherry'],
	SHOP.PaintList['lemon'],
	SHOP.PaintList['plum'],
	SHOP.PaintList['strawberry'],
	SHOP.PaintList['grape'],
	SHOP.PaintList['lime'],
	SHOP.PaintList['watermelon'],
	SHOP.PaintList['blueberry']
}

UNBOX.Name='Fruit Paint Kit'
UNBOX.Type='Crate'
UNBOX.Model='models/props_junk/cardboard_box003a.mdl'

UNBOX.Chances = {
	5,
	5,
	5,
	5,
	5,
	4,
	4,
	4,
	3,
}
SHOP:RegisterUnbox( UNBOX )