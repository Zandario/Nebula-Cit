// Atom-level definitions

/atom/New(loc, ...)
	//atom creation method that preloads variables at creation
	if(global.use_preloader && (src.type == global._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		global._preloader.load(src)

	var/do_initialize = SSatoms.atom_init_stage
	var/list/created = SSatoms.created_atoms
	if(do_initialize > INITIALIZATION_INSSATOMS_LATE)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			//we were deleted
			return
	else if(created)
		var/list/argument_list
		if(length(args) > 1)
			argument_list = args.Copy(2)
		if(argument_list || do_initialize == INITIALIZATION_INSSATOMS_LATE)
			created[src] = argument_list

	if(atom_flags & ATOM_FLAG_CLIMBABLE)
		verbs += /atom/proc/climb_on

/**
 * The primary method that objects are setup in SS13 with
 *
 * we don't use New as we have better control over when this is called and we can choose
 * to delay calls or hook other logic in and so forth
 *
 * During roundstart map parsing, atoms are queued for intialization in the base atom/New(),
 * After the map has loaded, then Initalize is called on all atoms one by one. NB: this
 * is also true for loading map templates as well, so they don't Initalize until all objects
 * in the map file are parsed and present in the world
 *
 * If you're creating an object at any point after SSInit has run then this proc will be
 * immediately be called from New.
 *
 * mapload: This parameter is true if the atom being loaded is either being intialized during
 * the Atom subsystem intialization, or if the atom is being loaded from the map template.
 * If the item is being created at runtime any time after the Atom subsystem is intialized then
 * it's false.
 *
 * The mapload argument occupies the same position as loc when Initialize() is called by New().
 * loc will no longer be needed after it passed New(), and thus it is being overwritten
 * with mapload at the end of atom/New() before this proc (atom/Initialize()) is called.
 *
 * You must always call the parent of this proc, otherwise failures will occur as the item
 * will not be seen as initalized (this can lead to all sorts of strange behaviour, like
 * the item being completely unclickable)
 *
 * !Note: Ignore the note below until the first two lines of the proc are uncommented. -Zandario
 * You must not sleep in this proc, or any subprocs
 *
 * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
 * there are no other arguments
 *
 * Must return an [initialization hint][INITIALIZE_HINT_NORMAL] or a runtime will occur.
 *
 * !Note: the following functions don't call the base for optimization and must copypasta handling:
 * * [/turf/proc/Initialize]
 */
/atom/proc/Initialize(mapload, ...)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

	if(atom_flags & ATOM_FLAG_INITIALIZED)
		PRINT_STACK_TRACE("Warning: [src]([type]) initialized multiple times!")
	atom_flags |= ATOM_FLAG_INITIALIZED

	if(isnull(default_pixel_x))
		default_pixel_x = pixel_x
	else
		pixel_x = default_pixel_x
	if(isnull(default_pixel_y))
		default_pixel_y = pixel_y
	else
		pixel_y = default_pixel_y
	if(isnull(default_pixel_z))
		default_pixel_z = pixel_z
	else
		pixel_z = default_pixel_z
	if(isnull(default_pixel_w))
		default_pixel_w = pixel_w
	else
		pixel_w = default_pixel_w

	if(light_power && light_range)
		update_light()

	if(length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
	if(length(atom_can_smooth_with))
		sortTim(atom_can_smooth_with)
		if(atom_can_smooth_with[length(atom_can_smooth_with)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTHING_FLAG_OBJ

	if(opacity)
		updateVisibility(src)
		var/turf/T = loc
		if(istype(T))
			T.recalc_atom_opacity()

	return INITIALIZE_HINT_NORMAL

/**
 * Late Intialization, for code that should run after all atoms have run Intialization
 *
 * To have your LateIntialize proc be called, your atoms [Initalization][/atom/proc/Initialize]
 *  proc must return the hint
 * [INITIALIZE_HINT_LATELOAD] otherwise you will never be called.
 *
 * Useful for doing things like finding other atoms in a global list because you can guarantee
 * that all atoms will actually exist in the "WORLD" at this time and that all their Intialization
 * code has been run.
 */
/atom/proc/LateInitialize()
	set waitfor = FALSE

/atom/Destroy()
	UNQUEUE_TEMPERATURE_ATOM(src)

	QDEL_NULL(reagents)

	LAZYCLEARLIST(our_overlays)
	LAZYCLEARLIST(priority_overlays)

	LAZYCLEARLIST(climbers)

	QDEL_NULL(light)

	if(opacity)
		updateVisibility(src)

	return ..()

// Called if an atom is deleted before it initializes. Only call Destroy in this if you know what you're doing.
/atom/proc/EarlyDestroy(force = FALSE)
	return QDEL_HINT_QUEUE


// Movable level stuff

/atom/movable/Initialize(ml, ...)
	. = ..()
	if (!follow_repository.excluded_subtypes[type] && follow_repository.followed_subtypes_tcache[type])
		follow_repository.add_subject(src)

	if(ispath(virtual_mob))
		virtual_mob = new virtual_mob(get_turf(src), src)

	// Fire Entered events for freshly created movables.
	// Changing this behavior will almost certainly break power; update accordingly.
	if (!ml && loc)
		loc.Entered(src, null)

/atom/movable/Destroy()
	// Clear this up early so it doesn't complain about events being disposed while it's listening.
	if(isatom(virtual_mob))
		QDEL_NULL(virtual_mob)

	// If you want to keep any of these atoms, handle them before ..()
	for(var/thing in contents) // proooobably safe to assume they're never going to have non-movables in contents?
		qdel(thing)

	unregister_all_movement(loc, src) // unregister events before destroy to avoid expensive checking

	. = ..()

	for(var/A in src)
		qdel(A)

	forceMove(null)

	if(LAZYLEN(movement_handlers) && !ispath(movement_handlers[1]))
		QDEL_NULL_LIST(movement_handlers)

	if (bound_overlay)
		QDEL_NULL(bound_overlay)

	vis_locs = null //clears this atom out of all vis_contents
	clear_vis_contents(src)
