/decl/bodytype/teshari
	name              = "teshari"
	bodytype_category = BODYTYPE_TESHARI
	icon_base         = 'mods/species/teshari/icons/body.dmi'
	blood_overlays    = 'mods/species/teshari/icons/blood.dmi'
	limb_blend        = ICON_MULTIPLY
	bodytype_flag     = BODY_FLAG_TESHARI

	var/tail_icon       = 'mods/species/teshari/icons/tail.dmi'
	var/tail            = "tail_teshari"
	var/tail_blend      = ICON_MULTIPLY
	var/tail_hair       = "tail_teshari_over"
	var/tail_hair_blend = ICON_MULTIPLY
	var/tail_states
	var/tail_animation

/decl/bodytype/teshari/Initialize()
	equip_adjust = list(
		slot_l_ear_str     = list("[NORTH]" = list("x" =  1, "y" = -5), "[EAST]" = list("x" = -2, "y" = -5), "[SOUTH]" = list("x" = -1, "y" = -5),  "[WEST]" = list("x" =  0, "y" = -5)),
		slot_r_ear_str     = list("[NORTH]" = list("x" =  1, "y" = -5), "[EAST]" = list("x" =  0, "y" = -5), "[SOUTH]" = list("x" = -1, "y" = -5),  "[WEST]" = list("x" =  2, "y" = -5)),
		BP_L_HAND          = list("[NORTH]" = list("x" =  3, "y" = -3), "[EAST]" = list("x" =  1, "y" = -3), "[SOUTH]" = list("x" = -3, "y" = -3),  "[WEST]" = list("x" = -5, "y" = -3)),
		BP_R_HAND          = list("[NORTH]" = list("x" = -3, "y" = -3), "[EAST]" = list("x" =  5, "y" = -3), "[SOUTH]" = list("x" =  3, "y" = -3),  "[WEST]" = list("x" = -1, "y" = -3)),
		slot_head_str      = list("[NORTH]" = list("x" =  0, "y" = -5), "[EAST]" = list("x" =  1, "y" = -5), "[SOUTH]" = list("x" =  0, "y" = -5),  "[WEST]" = list("x" = -1, "y" = -5)),
		slot_wear_mask_str = list("[NORTH]" = list("x" =  0, "y" = -6), "[EAST]" = list("x" =  2, "y" = -6), "[SOUTH]" = list("x" =  0, "y" = -6),  "[WEST]" = list("x" = -2, "y" = -6)),
		slot_glasses_str   = list("[NORTH]" = list("x" =  0, "y" = -6), "[EAST]" = list("x" =  1, "y" = -6), "[SOUTH]" = list("x" =  0, "y" = -6),  "[WEST]" = list("x" = -1, "y" = -6)),
		slot_back_str      = list("[NORTH]" = list("x" =  0, "y" = -6), "[EAST]" = list("x" =  3, "y" = -6), "[SOUTH]" = list("x" =  0, "y" = -6),  "[WEST]" = list("x" = -3, "y" = -6)),
		slot_w_uniform_str = list("[NORTH]" = list("x" =  0, "y" = -6), "[EAST]" = list("x" = -1, "y" = -6), "[SOUTH]" = list("x" =  0, "y" = -6),  "[WEST]" = list("x" =  1, "y" = -6)),
		slot_tie_str       = list("[NORTH]" = list("x" =  0, "y" = -5), "[EAST]" = list("x" =  0, "y" = -5), "[SOUTH]" = list("x" =  0, "y" = -5),  "[WEST]" = list("x" =  0, "y" = -5)),
		slot_wear_id_str   = list("[NORTH]" = list("x" =  0, "y" = -6), "[EAST]" = list("x" = -1, "y" = -6), "[SOUTH]" = list("x" =  0, "y" = -6),  "[WEST]" = list("x" =  1, "y" = -6)),
		slot_wear_suit_str = list("[NORTH]" = list("x" =  0, "y" = -6), "[EAST]" = list("x" = -1, "y" = -6), "[SOUTH]" = list("x" =  0, "y" = -6),  "[WEST]" = list("x" =  1, "y" = -6)),
		slot_belt_str      = list("[NORTH]" = list("x" =  0, "y" = -6), "[EAST]" = list("x" = -1, "y" = -6), "[SOUTH]" = list("x" =  0, "y" = -6),  "[WEST]" = list("x" =  1, "y" = -6)),
	)
	. = ..()

/obj/item/organ/external/tail/teshari/get_tail()
	if(istype(owner?.bodytype, /decl/bodytype/teshari))
		var/decl/bodytype/teshari/bird_bod = owner.bodytype
		return bird_bod.tail

/obj/item/organ/external/tail/teshari/get_tail_animation()
	if(istype(owner?.bodytype, /decl/bodytype/teshari))
		var/decl/bodytype/teshari/bird_bod = owner.bodytype
		return bird_bod.tail_animation

/obj/item/organ/external/tail/teshari/get_tail_icon()
	if(istype(owner?.bodytype, /decl/bodytype/teshari))
		var/decl/bodytype/teshari/bird_bod = owner.bodytype
		return bird_bod.tail_icon

/obj/item/organ/external/tail/teshari/get_tail_states()
	if(istype(owner?.bodytype, /decl/bodytype/teshari))
		var/decl/bodytype/teshari/bird_bod = owner.bodytype
		return bird_bod.tail_states

/obj/item/organ/external/tail/teshari/get_tail_blend()
	if(istype(owner?.bodytype, /decl/bodytype/teshari))
		var/decl/bodytype/teshari/bird_bod = owner.bodytype
		return bird_bod.tail_blend

/obj/item/organ/external/tail/teshari/get_tail_hair()
	if(istype(owner?.bodytype, /decl/bodytype/teshari))
		var/decl/bodytype/teshari/bird_bod = owner.bodytype
		return bird_bod.tail_hair

/obj/item/organ/external/tail/teshari/get_tail_hair_blend()
	if(istype(owner?.bodytype, /decl/bodytype/teshari))
		var/decl/bodytype/teshari/bird_bod = owner.bodytype
		return bird_bod.tail_hair_blend
