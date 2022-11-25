var/global/list/wall_blend_objects = list(
	/obj/machinery/door,
	/obj/structure/wall_frame,
	/obj/structure/grille,
	/obj/structure/window/reinforced/full,
	/obj/structure/window/reinforced/polarized/full,
	/obj/structure/window/shuttle,
	/obj/structure/window/borosilicate/full,
	/obj/structure/window/borosilicate_reinforced/full
)
var/global/list/wall_noblend_objects = list(
	/obj/machinery/door/window
)
var/global/list/wall_fullblend_objects = list(
	/obj/structure/wall_frame
)

/turf/simulated/wall/proc/can_join_with(turf/simulated/wall/target_wall)
	if(material && istype(target_wall.material))
		var/other_wall_icon = target_wall.get_wall_icon()
		if(material.wall_blend_icons[other_wall_icon])
			return 2
		if(get_wall_icon() == other_wall_icon)
			return 1
	return 0

/turf/simulated/wall/custom_smooth(dirs)
	smoothing_junction = dirs
	update_icon()

/turf/simulated/wall/on_update_icon()
	. = ..()
	cut_overlays()

	if(!istype(material))
		return

	if(!wall_connections || !other_connections)
		var/list/wall_dirs =  list()
		var/list/other_dirs = list()
		for(var/stepdir in global.alldirs)
			var/turf/T = get_step(src, stepdir)
			if(!T)
				continue
			if(istype(T, /turf/simulated/wall))
				switch(can_join_with(T))
					if(0)
						continue
					if(1)
						wall_dirs += get_dir(src, T)
					if(2)
						wall_dirs += get_dir(src, T)
						other_dirs += get_dir(src, T)
			if(handle_structure_blending)
				var/success = 0
				for(var/O in T)
					for(var/b_type in global.wall_blend_objects)
						if(istype(O, b_type))
							success = TRUE
							break
					for(var/nb_type in global.wall_noblend_objects)
						if(istype(O, nb_type))
							success = FALSE
							break
					if(success)
						wall_dirs += get_dir(src, T)
						if(get_dir(src, T) in global.cardinal)
							var/blendable = FALSE
							for(var/fb_type in global.wall_fullblend_objects)
								if(istype(O, fb_type))
									blendable = TRUE
									break
							if(!blendable)
								other_dirs += get_dir(src, T)
						break
		wall_connections = dirs_to_corner_states(wall_dirs)
		other_connections = dirs_to_corner_states(other_dirs)

	var/material_icon_base = get_wall_icon()
	var/image/I
	var/base_color = material.color
	// Handle fakewalls.
	if(!density)
		I = image(material_icon_base, "fwall_open")
		I.color = base_color
		add_overlay(I)
		return

	for(var/i = 1 to 4)
		I = image(material_icon_base, "[wall_connections[i]]", dir = BITFLAG(i-1))
		I.color = base_color
		add_overlay(I)
		if(paint_color)
			I = image(icon, "paint[wall_connections[i]]", dir = BITFLAG(i-1))
			I.color = paint_color
			add_overlay(I)
		if(stripe_color)
			I = image(icon, "stripe[wall_connections[i]]", dir = BITFLAG(i-1))
			I.color = stripe_color
			add_overlay(I)

	if(apply_reinf_overlay())
		var/reinf_color = paint_color ? paint_color : reinf_material.color
		if(construction_stage != null && construction_stage < 6)
			I = image('icons/turf/walls/_construction_overlays.dmi', "[construction_stage]")
			I.color = reinf_color
			add_overlay(I)
		else
			if(reinf_material.use_reinf_state)
				I = image(reinf_material.icon_reinf, reinf_material.use_reinf_state)
				I.color = reinf_color
				add_overlay(I)
			else
				// Directional icon
				for(var/i = 1 to 4)
					I = image(reinf_material.icon_reinf, "[wall_connections[i]]", dir = BITFLAG(i-1))
					I.color = reinf_color
					add_overlay(I)

	if(material.wall_flags & WALL_HAS_EDGES)
		for(var/i = 1 to 4)
			I = image(material_icon_base, "other[other_connections[i]]", dir = BITFLAG(i-1))
			I.color = stripe_color ? stripe_color : base_color
			add_overlay(I)

	var/image/texture = material.get_wall_texture()
	if(texture)
		add_overlay(texture)

	if(damage != 0 && SSmaterials.wall_damage_overlays)
		var/integrity = material.integrity
		if(reinf_material)
			integrity += reinf_material.integrity
		add_overlay(SSmaterials.wall_damage_overlays[clamp(round(damage / integrity * DAMAGE_OVERLAY_COUNT) + 1, 1, DAMAGE_OVERLAY_COUNT)])

/turf/simulated/wall/proc/paint_wall(new_paint_color)
	paint_color = new_paint_color
	update_icon()

/turf/simulated/wall/proc/stripe_wall(new_paint_color)
	stripe_color = new_paint_color
	update_icon()

/turf/simulated/wall/proc/update_strings()
	if(reinf_material)
		SetName("reinforced [material.solid_name] [material.wall_name]")
		desc = "It seems to be a section of hull reinforced with [reinf_material.solid_name] and plated with [material.solid_name]."
	else
		SetName("[material.solid_name] [material.wall_name]")
		desc = "It seems to be a section of hull plated with [material.solid_name]."

/turf/simulated/wall/proc/get_wall_icon()
	. = (istype(material) && material.icon_base) || 'icons/turf/walls/solid.dmi'

/turf/simulated/wall/proc/apply_reinf_overlay()
	. = istype(reinf_material)
