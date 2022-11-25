/datum/appearance_descriptor/age/teshari
	chargen_min_index = 3
	chargen_max_index = 6
	standalone_value_descriptors = list(
		"a hatchling" =     1,
		"an fledgeling" =   6,
		"a young adult" =  12,
		"an adult" =       25,
		"middle-aged" =    35,
		"aging" =          45,
		"elderly" =        50
	)

/decl/species/teshari
	name = SPECIES_TESHARI
	name_plural = "Teshari"
	description = "A race of feathered raptors who developed alongside the Skrell, inhabiting the polar tundral regions outside of \
	Skrell territory. Extremely fragile, they developed hunting skills that emphasized taking out their prey without themselves getting hit."

	base_prosthetics_model = null

	age_descriptor = /datum/appearance_descriptor/age/teshari
	holder_icon = 'mods/species/teshari/icons/holder.dmi'

	meat_type = /obj/item/chems/food/meat/chicken

	base_color = "#001144"
	base_eye_color = "#43a5de"
	base_markings = list(/decl/sprite_accessory/marking/teshari = "#747070")
	default_h_style = /decl/sprite_accessory/hair/teshari

	preview_outfit = /decl/hierarchy/outfit/job/generic/assistant/teshari

	available_bodytypes = list(
		/decl/bodytype/teshari,
	)

	total_health = 120
	mob_size = MOB_SIZE_SMALL
	holder_type = /obj/item/holder
	gluttonous = GLUT_TINY
	blood_volume = 320
	hunger_factor = DEFAULT_HUNGER_FACTOR * 1.6

	spawn_flags = SPECIES_CAN_JOIN
	appearance_flags = HAS_HAIR_COLOR | HAS_SKIN_COLOR | HAS_EYE_COLOR
	bump_flag = MONKEY
	swap_flags = MONKEY|SIMPLE_ANIMAL
	push_flags = MONKEY|SIMPLE_ANIMAL

	heat_discomfort_strings = list(
		"Your feathers prickle in the heat.",
		"You feel uncomfortably warm.",
		)

	has_organ = list(
		BP_STOMACH = /obj/item/organ/internal/stomach,
		BP_HEART   = /obj/item/organ/internal/heart,
		BP_LUNGS   = /obj/item/organ/internal/lungs,
		BP_LIVER   = /obj/item/organ/internal/liver,
		BP_KIDNEYS = /obj/item/organ/internal/kidneys,
		BP_BRAIN   = /obj/item/organ/internal/brain,
		BP_EYES    = /obj/item/organ/internal/eyes/teshari,
	)

	override_limb_types = list(BP_TAIL = /obj/item/organ/external/tail/teshari)

	unarmed_attacks = list(
		/decl/natural_attack/bite/sharp,
		/decl/natural_attack/claws,
		/decl/natural_attack/stomp/weak,
	)

	available_cultural_info = list(
		TAG_CULTURE = list(
			/decl/cultural_info/culture/teshari,
			/decl/cultural_info/culture/teshari/saurian,
			/decl/cultural_info/culture/other,
		)
	)

/decl/species/teshari/equip_default_fallback_uniform(mob/living/carbon/human/H)
	if(istype(H))
		H.equip_to_slot_or_del(new /obj/item/clothing/under/teshari_smock/worker, slot_w_uniform_str)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/teshari, slot_shoes_str)

/decl/species/teshari/get_holder_color(mob/living/carbon/human/H)
	return H.skin_colour

/obj/item/organ/internal/eyes/teshari
	eye_icon = 'mods/species/teshari/icons/eyes.dmi'

/decl/hierarchy/outfit/job/generic/assistant/teshari
	name = "Job - Teshari Assistant"
	uniform = /obj/item/clothing/under/teshari_smock/worker
	shoes = /obj/item/clothing/shoes/teshari/footwraps
