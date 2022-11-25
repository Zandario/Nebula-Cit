SUBSYSTEM_DEF(icon_smooth)
	name = "Icon Smoothing"
	wait = 1
	priority = SS_PRIORITY_SMOOTHING
	init_order = SS_INIT_ICON_SMOOTHING
	flags = SS_TICKER

	var/list/smooth_queue = list()
	var/list/deferred = list()

/datum/controller/subsystem/icon_smooth/stat_entry()
	..("Queue:[smooth_queue.len]")

/datum/controller/subsystem/icon_smooth/Initialize()
	// Clear.
	smooth_queue = list()
	deferred = list()

	// Smooth everything.
	for(var/z in 1 to world.maxz)
		smooth_zlevel(z, TRUE)

	var/list/queue = smooth_queue
	smooth_queue = list()

	while(length(queue))
		var/atom/smoothing_atom = queue[length(queue)]
		queue.len--
		if(QDELETED(smoothing_atom) || !(smoothing_atom.smoothing_flags & SMOOTHING_FLAG_QUEUED) || smoothing_atom.z <= 2)
			continue
		smoothing_atom.smooth_icon()
		CHECK_TICK

	return ..()


/datum/controller/subsystem/icon_smooth/fire()
	var/list/cached = smooth_queue
	while(length(cached))
		var/atom/smoothing_atom = cached[length(cached)]
		cached.len--
		if(QDELETED(smoothing_atom) || !(smoothing_atom.smoothing_flags & SMOOTHING_FLAG_QUEUED))
			continue
		if(smoothing_atom.atom_flags & ATOM_FLAG_INITIALIZED)
			smoothing_atom.smooth_icon()
		else
			deferred += smoothing_atom
		if (MC_TICK_CHECK)
			return

	if (!cached.len)
		if (deferred.len)
			smooth_queue = deferred
			deferred = cached
		else
			can_fire = FALSE


/datum/controller/subsystem/icon_smooth/proc/add_to_queue(atom/queued_atom)
	if(queued_atom.smoothing_flags & SMOOTHING_FLAG_QUEUED)
		return
	queued_atom.smoothing_flags |= SMOOTHING_FLAG_QUEUED
	smooth_queue += queued_atom
	if(!can_fire)
		can_fire = TRUE


/datum/controller/subsystem/icon_smooth/proc/remove_from_queues(atom/queued_atom)
	queued_atom.smoothing_flags &= ~SMOOTHING_FLAG_QUEUED
	smooth_queue -= queued_atom
	deferred -= queued_atom


//! ## Atom Smoothing Vars

/**
 * This atom's icon-smoothing behavior.
 *
 *! Possible values:
 *
 * * SMOOTHING_FLAG_CORNERS
 * - - Smoothing system in where adjacencies are calculated and used to build an image by mounting each corner at runtime.
 * * SMOOTHING_FLAG_BITMASK
 * - - Smoothing system in where adjacencies are calculated and used to select a pre-baked icon_state, encoded by bitmasking.
 * * SMOOTHING_FLAG_DIAGONAL_CORNERS
 * - - Atom has diagonal corners, with underlays under them.
 * * SMOOTHING_FLAG_BORDER
 * - - Atom will smooth with the borders of the map.
 * * SMOOTHING_FLAG_QUEUED
 * - - Atom is currently queued to smooth.
 * * SMOOTHING_FLAG_OBJ
 * - - Smooths with objects, and will thus need to scan turfs for contents.
 * * SMOOTHING_FLAG_CUSTOM
 * - - This is a temporary flag for supporting older smoothing systems.
 */
/atom/var/smoothing_flags = 0

/**
 *! IMPORTANT: This uses the smoothing direction flags as defined in icon_smoothing.dm, instead of the BYOND flags.
 *? What directions this is currently smoothing with.
 * This starts as null for us to know when it's first set, but after that it will hold a 8-bit mask ranging from 0 to 255.
 */
/atom/var/tmp/smoothing_junction = null

/// Smoothing variable
/atom/var/tmp/top_left_corner
/// Smoothing variable
/atom/var/tmp/top_right_corner
/// Smoothing variable
/atom/var/tmp/bottom_left_corner
/// Smoothing variable
/atom/var/tmp/bottom_right_corner

/**
 * What smoothing groups does this atom belongs to, to match atom_can_smooth_with.
 * If null, nobody can smooth with it.
 */
/atom/var/list/smoothing_groups = null

/**
 * List of smoothing groups this atom can smooth with.
 * If this is null and atom is smooth, it smooths only with itself.
 */
/atom/var/list/atom_can_smooth_with = null


//! ## Area Smoothing Vars
///Typepath to limit the areas (subtypes included) that atoms in this area can smooth with. Used for shuttles.
/area/var/area/area_limited_icon_smoothing


//! ## Turf Smoothing Vars
///Icon-smoothing variable to map a diagonal wall corner with a fixed underlay.
/turf/var/list/fixed_underlay = null
