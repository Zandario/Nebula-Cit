//# This file contains all Nano procs/definitions for external classes/objects


/**
 * The ui_interact proc is used to open and update Nano UIs
 * If ui_interact is not used then the UI will not update correctly
 * ui_interact is currently defined for /atom/movable
 *
 * @param {/mob} user - The mob who is interacting with this UI
 * @param {string} [ui_key="main"] - A string key to use for this UI. Allows for multiple unique UIs on one obj/mob (defaut value "main")
 * @param {/datum/nanoui} ui - This parameter is passed by the nanoui process() proc when updating an open UI
 * @param {boolean} [force_open=TRUE] - Force the UI to (re)open, even if it's already open
 * @param {/datum/nanoui} master_ui - The master UI to use for this UI.
 * @param {/datum/topic_state} [state=global.default_topic_state] - The topic state to use for this UI.
 *
 * @return nothing
 */
/datum/proc/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE, datum/nanoui/master_ui = null, datum/topic_state/state = global.default_topic_state)
	return

/**
 * Data to be sent to the UI.
 * This must be implemented for a UI to work.
 *
 * @param {/mob} user - The mob who interacting with the UI
 * @param {string} [ui_key="main"] - A string key to use for this UI. Allows for multiple unique UIs on one obj/mob (defaut value "main")
 *
 * @return {/list} - Data to be sent to the UI
 */
/datum/proc/ui_data(mob/user, ui_key = "main")
	return list() // Not implemented.

/**
 * The UI's host object (usually src_object).
 * This allows modules/datums to have the UI attached to them,
 * and be a part of another object.
 */
/datum/proc/nano_host()
	return src

/**
 * Container for the UI.
 * This allows modules/datums to have the UI attached to them, and be a part of another object.
 */
/datum/proc/nano_container()
	return src
