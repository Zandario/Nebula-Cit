/decl/loadout_category/teshari
	name = "Teshari"

/decl/loadout_option/teshari
	whitelisted = list(SPECIES_TESHARI)
	category = /decl/loadout_category/teshari
	abstract_type = /decl/loadout_option/teshari

/decl/loadout_option/teshari/uniform_selection
	name = "Teshari Smock Selection"
	path = /obj/item/clothing/under/teshari_smock
	slot = slot_w_uniform_str

/decl/loadout_option/teshari/uniform_selection/get_gear_tweak_options()
	. = ..()
	LAZYINITLIST(.[/datum/gear_tweak/path])
	.[/datum/gear_tweak/path] |= list(
		"plain smock"     = /obj/item/clothing/under/teshari_smock,
		"worker's smock"  = /obj/item/clothing/under/teshari_smock/worker,
		"rainbow smock"   = /obj/item/clothing/under/teshari_smock/rainbow,
		"armoured smock"  = /obj/item/clothing/under/teshari_smock/security,
		"hazard smock"    = /obj/item/clothing/under/teshari_smock/engineering,
		"black uniform"   = /obj/item/clothing/under/teshari_smock/utility,
		"gray uniform"    = /obj/item/clothing/under/teshari_smock/utility/gray,
		"stylish uniform" = /obj/item/clothing/under/teshari_smock/stylish_command
	)

/decl/loadout_option/teshari/shoes
	name  = "footwraps"
	path  = /obj/item/clothing/shoes/teshari/footwraps
	flags = GEAR_HAS_COLOR_SELECTION
	slot  = slot_shoes_str


/decl/loadout_option/teshari/hoodedcloak
	name = "Teshari Hooded Cloak"
	path = /obj/item/clothing/suit/storage/toggle/teshari_hoodedcloak
	slot = slot_wear_suit_str
