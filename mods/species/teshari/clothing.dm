//! Shoes

/obj/item/clothing/shoes/magboots/Initialize()
	. = ..()
	LAZYSET(sprite_sheets, BODYTYPE_TESHARI, 'mods/species/teshari/icons/clothing/feet/magboots.dmi')

/obj/item/clothing/shoes/galoshes/Initialize()
	. = ..()
	LAZYSET(sprite_sheets, BODYTYPE_TESHARI, 'mods/species/teshari/icons/clothing/feet/galoshes.dmi')

//! Gloves

/obj/item/clothing/gloves/Initialize()
	. = ..()
	if(!isnull(bodytype_equip_flags) && !(bodytype_equip_flags & BODY_FLAG_EXCLUDE))
		bodytype_equip_flags |= BODY_FLAG_TESHARI
	LAZYSET(sprite_sheets, BODYTYPE_TESHARI, 'mods/species/teshari/icons/clothing/gloves.dmi')

//! Backpacks & tanks

/obj/item/storage/backpack/satchel/Initialize()
	. = ..()
	LAZYSET(sprite_sheets, BODYTYPE_TESHARI, 'mods/species/teshari/icons/clothing/satchel.dmi')

//! Radsuits (theyre essential?)

/obj/item/clothing/head/radiation/Initialize()
	. = ..()
	LAZYSET(sprite_sheets, BODYTYPE_TESHARI, 'mods/species/teshari/icons/clothing/head/rad_helm.dmi')

/obj/item/clothing/suit/radiation/Initialize()
	. = ..()
	LAZYSET(sprite_sheets, BODYTYPE_TESHARI, 'mods/species/teshari/icons/clothing/suit/rad_suit.dmi')

//! Cloaks
/obj/item/clothing/accessory/cloak/Initialize()
	. = ..()
	LAZYSET(sprite_sheets, BODYTYPE_TESHARI, 'mods/species/teshari/icons/clothing/accessory/cloak.dmi')

/obj/item/clothing/accessory/cloak/hide/Initialize()
	. = ..()
	LAZYSET(sprite_sheets, BODYTYPE_TESHARI, 'mods/species/teshari/icons/clothing/accessory/cloak_hide.dmi')

//! Clothing
/obj/item/clothing/under/teshari_smock
	name = "smock"
	desc = "A loose-fitting smock favoured by tesharii."
	icon = 'mods/species/teshari/icons/clothing/under/smock.dmi'
	icon_state = ICON_STATE_WORLD
	bodytype_equip_flags = BODY_FLAG_TESHARI

/obj/item/clothing/under/teshari_smock/worker
	name = "worker's smock"
	icon = 'mods/species/teshari/icons/clothing/under/smock_grey.dmi'

/obj/item/clothing/under/teshari_smock/rainbow
	name = "rainbow smock"
	desc = "A brightly coloured, loose-fitting smock - the height of teshari fashion."
	icon = 'mods/species/teshari/icons/clothing/under/smock_rainbow.dmi'

/obj/item/clothing/under/teshari_smock/medical
	name = "small medical uniform"
	icon = 'mods/species/teshari/icons/clothing/under/smock_medical.dmi'

/obj/item/clothing/under/teshari_smock/security
	name = "armoured smock"
	desc = "A bright red smock with light armour insets, worn by teshari security personnel."
	icon = 'mods/species/teshari/icons/clothing/under/smock_red.dmi'

/obj/item/clothing/under/teshari_smock/engineering
	name = "hazard smock"
	desc = "A high-visibility yellow smock with orange highlights light armour insets, worn by teshari engineering personnel."
	icon = 'mods/species/teshari/icons/clothing/under/smock_yellow.dmi'

/obj/item/clothing/under/teshari_smock/utility
	name = "black uniform"
	icon = 'mods/species/teshari/icons/clothing/under/black_utility.dmi'

/obj/item/clothing/under/teshari_smock/utility/gray
	name = "gray uniform"
	icon = 'mods/species/teshari/icons/clothing/under/gray_utility.dmi'

/obj/item/clothing/under/teshari_smock/stylish_command
	name = "stylish uniform"
	icon = 'mods/species/teshari/icons/clothing/under/stylish_form.dmi'

//! Shoes
/obj/item/clothing/shoes/teshari
	name = "small shoes"
	icon = 'mods/species/teshari/icons/clothing/feet/shoes.dmi'
	color = COLOR_GRAY
	bodytype_equip_flags = BODY_FLAG_TESHARI

/obj/item/clothing/shoes/teshari/footwraps
	name = "cloth footwraps"
	desc = "A roll of treated canvas used for wrapping feet."
	icon = 'mods/species/teshari/icons/clothing/feet/footwraps.dmi'
	force = 0
	item_flags = ITEM_FLAG_SILENT
	w_class = ITEM_SIZE_SMALL

//! Suits
/obj/item/clothing/suit/storage/toggle/teshari_hoodedcloak
	name = "black and orange hooded cloak"
	desc = "A hood attached to a teshari cloak."
	icon = 'mods/species/teshari/icons/clothing/hoodedcloak/default/suit.dmi'
	body_parts_covered = SLOT_UPPER_BODY|SLOT_LOWER_BODY|SLOT_ARMS
	cold_protection = SLOT_UPPER_BODY|SLOT_LOWER_BODY|SLOT_ARMS
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list(
		bio = ARMOR_BIO_MINOR
		)
	hood = /obj/item/clothing/head/teshari_hoodedcloak
	allowed = list (/obj/item/pen, /obj/item/paper, /obj/item/flashlight,/obj/item/storage/fancy/cigarettes, /obj/item/storage/box/matches, /obj/item/chems/drinks/flask)
	siemens_coefficient = 0.6
	protects_against_weather = TRUE
	bodytype_equip_flags = BODY_FLAG_TESHARI

/obj/item/clothing/head/teshari_hoodedcloak
	name = "black and orange hood"
	desc = "A hood attached to a black and orange hooded cloak."
	icon = 'mods/species/teshari/icons/clothing/hoodedcloak/default/hood.dmi'
	body_parts_covered = SLOT_HEAD
	cold_protection = SLOT_HEAD
	flags_inv = HIDEEARS | BLOCK_HEAD_HAIR
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	protects_against_weather = TRUE
	bodytype_equip_flags = BODY_FLAG_TESHARI
