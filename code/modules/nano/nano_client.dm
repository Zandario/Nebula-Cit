/**
 * A "panic button" verb to close all UIs on current mob.
 * Use it when the bug with UI not opening (because the server still considers it open despite it being closed on client) pops up.
 * Feel free to remove it once the bug is confirmed to be fixed.
 */
/client/verb/resetnano()
	set name = "Reset NanoUI"
	set category = "OOC"

	var/ui_amt = length(mob.open_uis)
	SSnano.close_user_uis(mob)
	to_chat(src, "[ui_amt] UI windows reset.")

/**
 * Called when a Nano UI window is closed
 * This is how Nano handles closed windows
 * It must be a verb so that it can be called using winset
 */
/client/verb/nanoclose(uiref as text)
	set hidden = TRUE // hide this verb from the user's panel
	set name = "nanoclose"

	var/datum/nanoui/ui = locate(uiref)

	if (istype(ui))
		ui.close()
		if(ui.ref)
			var/href = "close=1"
			src.Topic(href, params2list(href), ui.ref)	// this will direct to the datum's Topic() proc via client.Topic()
		else if (ui.on_close_logic)
			// no atomref specified (or not found)
			// so just reset the user mob's machine var
			if(src && src.mob)
				src.mob.unset_machine()
