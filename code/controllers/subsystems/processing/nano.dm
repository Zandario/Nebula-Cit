PROCESSING_SUBSYSTEM_DEF(nano)
	name = "NanoUI"
	priority = SS_PRIORITY_NANO
	wait = 2 SECONDS

	/// a list of current open [/datum/nanoui] UIs, grouped by [src_object] and [ui_key]
	var/list/open_uis = list()

	/// The HTML base used for all UIs.
	var/basehtml


/datum/controller/subsystem/processing/nano/PreInit(recovering)
	basehtml = file2text('nano/public/nanoui.html')
	// // Inject inline polyfills
	// var/polyfill = file2text('tgui/public/tgui-polyfill.min.js')
	// polyfill = "<script>\n[polyfill]\n</script>"
	// basehtml = replacetextEx(basehtml, "<!-- tgui:inline-polyfill -->", polyfill)



/**
 * Get an open {/datum/nanoui} ui for the current user, src_object and ui_key and try to update it with data
 *
 * @param {/mob} user - The mob who opened/owns the ui
 * @param {datum} src_object - The obj or mob which the ui belongs to
 * @param {string} ui_key - A string key used for the ui
 * @param {/datum/nanoui} ui - An existing instance of the ui (can be null)
 * @param {/list} data - The data to be passed to the ui, if it exists
 * @param {boolean} [force_open=FALSE] - (optional) The ui is being forced to (re)open, so close ui if it exists (instead of updating)
 *
 * @returns {/datum/nanoui} The found ui, null if none exists.
 */
/datum/controller/subsystem/processing/nano/proc/try_update_ui(mob/user, src_object, ui_key, datum/nanoui/ui, data, force_open = FALSE) as /datum/nanoui
	if(!ui) // no ui has been passed, so we'll search for one
		ui = get_open_ui(user, src_object, ui_key)
	if(!ui)
		return null
	// The UI is already open
	force_open ? ui.reinitialise(new_initial_data=data) : ui.push_data(data)
	return ui

/**
 * Get an open {/datum/nanoui} ui for the current user, src_object and ui_key
 *
 * @param {/mob} user - The mob who opened/owns the ui.
 *
 * @param {/datum} src_object - The obj or mob which the ui belongs to.
 *
 * @param {string} ui_key - A string key used for the ui.
 *
 * @returns {(/datum/nanoui|null)} - The found ui, or null if none exists.
 */
/datum/controller/subsystem/processing/nano/proc/get_open_ui(mob/user, src_object, ui_key) as /datum/nanoui
	var/src_object_key = "\ref[src_object]"
	if(!open_uis[src_object_key] || !open_uis[src_object_key][ui_key])
		return null

	for(var/datum/nanoui/ui in open_uis[src_object_key][ui_key])
		if(ui.user == user)
			return ui

/**
 * Update all {/datum/nanoui} uis attached to src_object.
 *
 * @param {/datum} src_object - The datum which the uis are attached to.
 *
 * @returns {num} - The number of uis updated.
 */
/datum/controller/subsystem/processing/nano/proc/update_uis(src_object) as num
	. = 0
	var/src_object_key = "\ref[src_object]"
	if(!open_uis[src_object_key])
		return

	for(var/ui_key in open_uis[src_object_key])
		for(var/datum/nanoui/ui in open_uis[src_object_key][ui_key])
			if(ui.src_object && ui.user && ui.src_object.nano_host())
				ui.try_update(1)
				.++
			else
				ui.close()

/**
 * Close all {/datum/nanoui} uis attached to src_object
 *
 * @param src_object /obj|/mob The obj or mob which the uis are attached to
 *
 * @returns {num} The number of uis close
 */
/datum/controller/subsystem/processing/nano/proc/close_uis(src_object) as num
	. = 0
	if(!length(open_uis))
		return

	var/src_object_key = "\ref[src_object]"
	if(!open_uis[src_object_key])
		return

	for(var/ui_key in open_uis[src_object_key])
		for(var/datum/nanoui/ui in open_uis[src_object_key][ui_key])
			ui.close() // If it's missing src_object or user, we want to close it even more.
			.++

/**
 * Update {/datum/nanoui} uis belonging to user.
 *
 * @param {/mob} user - The mob who owns the uis.
 *
 * @param {/datum} src_object - (optional) If src_object is provided, only update uis which are attached to src_object.
 *
 * @param {string} ui_key - (optional) If ui_key is provided, only update uis with a matching ui_key.
 *
 * @returns {num} The number of uis updated.
 */
/datum/controller/subsystem/processing/nano/proc/update_user_uis(mob/user, src_object, ui_key) as num
	. = 0
	if(!length(user.open_uis))
		return // has no open uis

	for(var/datum/nanoui/ui in user.open_uis)
		if((isnull(src_object) || ui.src_object == src_object) && (isnull(ui_key) || ui.ui_key == ui_key))
			ui.try_update(TRUE)
			.++

/**
 * Close {/datum/nanoui} uis belonging to user
 *
 * @param {/mob} user - The mob who owns the uis.
 *
 * @param {/datum} [src_object] - (optional) If provided, only close uis which are attached to src_object.
 *
 * @param {string} [ui_key] - (optional) If provided, only close uis with a matching ui_key.
 *
 * @returns {num} - The number of uis closed.
 */
/datum/controller/subsystem/processing/nano/proc/close_user_uis(mob/user, src_object, ui_key) as num
	. = 0
	if(!length(user.open_uis))
		return // has no open uis

	for(var/datum/nanoui/ui in user.open_uis)
		if((isnull(src_object) || ui.src_object == src_object) && (isnull(ui_key) || ui.ui_key == ui_key))
			ui.close()
			.++

/**
 * Add a {/datum/nanoui} ui to the list of open uis.
 * This is called by the {/datum/nanoui/open()}.
 *
 * @param {/datum/nanoui} ui - The ui to add.
 */
/datum/controller/subsystem/processing/nano/proc/ui_opened(datum/nanoui/ui) as null
	var/src_object_key = "\ref[ui.src_object]"
	LAZYINITLIST(open_uis[src_object_key])
	LAZYDISTINCTADD(open_uis[src_object_key][ui.ui_key], ui)
	LAZYDISTINCTADD(ui.user.open_uis, ui)
	START_PROCESSING(SSnano, ui)

/**
 * Remove a {/datum/nanoui} ui from the list of open uis.
 * This is called by the {/datum/nanoui/proc/close()}.
 *
 * @param {/datum/nanoui} ui - The ui to remove.
 *
 * @returns {boolean} If the UI was removed successfully or not.
 */
/datum/controller/subsystem/processing/nano/proc/ui_closed(datum/nanoui/ui)
	var/src_object_key = "\ref[ui.src_object]"
	if(!open_uis[src_object_key] || !open_uis[src_object_key][ui.ui_key])
		return FALSE // wasn't open

	STOP_PROCESSING(SSnano, ui)
	if(ui.user)	// Sanity check in case a user has been deleted (say a blown up borg watching the alarm interface)
		LAZYREMOVE(ui.user.open_uis, ui)
	open_uis[src_object_key][ui.ui_key] -= ui
	if(!length(open_uis[src_object_key][ui.ui_key]))
		open_uis[src_object_key] -= ui.ui_key
		if(!length(open_uis[src_object_key]))
			open_uis -= src_object_key
	return TRUE

/**
 * This is called on user logout.
 * Closes/clears all uis attached to the user's [/mob].
 *
 * @param {/mob} user - The user's mob.
 *
 * @returns {int} The number of uis closed.
 */
/datum/controller/subsystem/processing/nano/proc/user_logout(mob/user) as num
	return close_user_uis(user)

/**
 * This is called when a player transfers from one mob to another.
 * Transfers all open UIs to the new mob.
 *
 * @param {/mob} oldMob - The user's old mob.
 * @param {/mob} newMob - The user's new mob.
 *
 * @returns {boolean} If the transfer was successful or not.
 */
/datum/controller/subsystem/processing/nano/proc/user_transferred(mob/oldMob, mob/newMob)
	if(!oldMob || !oldMob.open_uis)
		return FALSE // has no open uis

	LAZYINITLIST(newMob.open_uis)
	for(var/datum/nanoui/ui in oldMob.open_uis)
		ui.user = newMob
		newMob.open_uis += ui
	oldMob.open_uis = null
	return TRUE // success
