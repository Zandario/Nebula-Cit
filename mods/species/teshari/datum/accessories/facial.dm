/decl/sprite_accessory/facial_hair/shaved/Initialize()
	. = ..()
	LAZYADD(species_allowed, SPECIES_TESHARI)

//! Facial Hair
/decl/sprite_accessory/facial_hair/teshari
	name = "Chin"
	icon = 'mods/species/teshari/icons/accessories/facial.dmi'
	icon_state = "teshari_chin"
	species_allowed = list(SPECIES_TESHARI)
	blend = ICON_MULTIPLY

/decl/sprite_accessory/facial_hair/teshari/scraggly
	name = "Scraggly"
	icon_state = "teshari_scraggly"
