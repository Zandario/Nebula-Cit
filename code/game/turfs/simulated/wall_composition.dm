/turf/simulated/wall/proc/set_material(decl/material/newmaterial, decl/material/newrmaterial, decl/material/newgmaterial, defer_icon)

	material = newmaterial
	if(ispath(material, /decl/material))
		material = GET_DECL(material)
	else if(!istype(material))
		PRINT_STACK_TRACE("Wall has been supplied non-material '[newmaterial]'.")
		material = GET_DECL(get_default_material())

	reinf_material = newrmaterial
	if(ispath(reinf_material, /decl/material))
		reinf_material = GET_DECL(reinf_material)
	else if(!istype(reinf_material))
		reinf_material = null

	girder_material = newgmaterial
	if(ispath(girder_material, /decl/material))
		girder_material = GET_DECL(girder_material)
	else if(!istype(girder_material))
		girder_material = null

	update_material(TRUE)

/turf/simulated/wall/proc/update_material(defer_icon)
	if(construction_stage != -1)
		if(reinf_material)
			construction_stage = 6
		else
			construction_stage = null
	if(!material)
		material = GET_DECL(get_default_material())
	if(material)
		explosion_resistance = material.explosion_resistance
	if(reinf_material && reinf_material.explosion_resistance > explosion_resistance)
		explosion_resistance = reinf_material.explosion_resistance
	update_strings()
	set_opacity(material.opacity >= 0.5)
	SSradiation.resistance_cache.Remove(src)
	if(!defer_icon)
		update_icon()

/turf/simulated/wall/proc/get_default_material()
	. = DEFAULT_WALL_MATERIAL
