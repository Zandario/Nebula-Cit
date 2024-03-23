/**
 * nanoui datum (represents a UI instance).
 *
 * nanoui is used to open and update nano browser uis
 */
/datum/nanoui
	/// The user who opened this ui.
	var/mob/user
	/// The object this ui "belongs" to.
	var/datum/src_object
	/// The title of this ui.
	var/title
	/// The key of this ui, this is to allow multiple (different) uis for each [src_object].
	var/ui_key
	/// Used as the window name/identifier for [browse] and [onclose].
	var/window_id
	/// The browser window width.
	var/width = 0
	/// The browser window height.
	var/height = 0
	/// Sets whether to use extra logic when window closes.
	var/on_close_logic = TRUE
	/// An extra ref to use when the window is closed, usually null.
	var/datum/ref = null
	/// options for modifying window behaviour.
	var/window_options = "focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;" // window option is set using [window_id].
	/// The list of stylesheets to apply to this ui.
	var/list/stylesheets = list()
	/// The list of javascript scripts to use for this ui.
	var/list/scripts = list()
	/// A list of templates which can be used with this ui.
	var/templates[0]
	/// The layout key for this ui (this is used on the frontend, leave it as "default" unless you know what you're doing).
	var/layout_key = "default"
	/// Optional layout key for additional ui header content to include.
	var/layout_header_key = "default_header"
	/// Sets whether to re-render the ui layout with each update (default FALSE, turning on will break the map ui if it's in use).
	var/auto_update_layout = FALSE
	/// Sets whether to re-render the ui content with each update (default TRUE).
	var/auto_update_content = TRUE
	/// The default state to use for this ui (this is used on the frontend, leave it as "default" unless you know what you're doing).
	var/state_key = "default"
	/// Show the map ui, this is used by the default layout.
	var/show_map = FALSE
	/// The map z level to display.
	var/map_z_level = 1
	/// initial data, containing the full data structure, must be sent to the ui (the data structure cannot be extended later on).
	var/list/initial_data[0]
	/// set to TRUE to update the ui automatically every [master_controller] tick.
	var/is_auto_updating = FALSE
	/// The current status/visibility of the ui.
	var/status = STATUS_INTERACTIVE

	// Relationship between a master interface and its children. Used in [update_status]
	var/datum/nanoui/master_ui
	var/list/datum/nanoui/children = list()
	var/datum/topic_state/state = null

	var/static/datum/asset/simple/nanoui/nano_assets = get_asset_datum(/datum/asset/simple/nanoui)
/**
 * Create a new nanoui instance.
 *
 * @param {/mob} nuser - The mob who has opened/owns this ui.
 * @param {/datum} nsrc_object - The datum which this ui belongs to.
 * @param {string} nui_key - A string key to use for this ui. Allows for multiple unique uis on one src_oject.
 * @param {string} ntemplate - The filename of the template file from '/nano/templates/' (e.g. "my_template.jst").
 * @param {string} ntitle - The title of this ui.
 * @param {int} nwidth - the width of the ui window.
 * @param {int} nheight - the height of the ui window.
 * @param {/atom} nref - A custom ref to use if [on_close_logic] is set to TRUE.
 *
 * @returns {/datum/nanoui} new nanoui object
 */
/datum/nanoui/New(nuser, nsrc_object, nui_key, ntemplate_filename, ntitle = 0, nwidth = 0, nheight = 0, var/datum/nref = null, var/datum/nanoui/master_ui = null, var/datum/topic_state/state = global.default_topic_state)
	if(!istype(nano_assets))
		nano_assets = get_asset_datum(/datum/asset/simple/nanoui)
	user = nuser
	src_object = nsrc_object
	ui_key = nui_key
	window_id = "[ui_key]\ref[src_object]"

	src.master_ui = master_ui
	if(master_ui)
		master_ui.children += src
	src.state = state

	// add the passed template filename as the "main" template, this is required
	add_template("main", ntemplate_filename)

	if(ntitle)
		title = sanitize(ntitle)
	if(nwidth)
		width = nwidth
	if(nheight)
		height = nheight
	if(nref)
		ref = nref

	add_common_assets()
	// assets.send(user, ntemplate_filename)
	if(user?.client)
		// ASYNC'd to avoid blocking processes that may be waiting on this one to finish.
		#warn THIS REALLY SHOULDN'T BE ASYNC YOU IDIOT! IT MAKES LOADING TOO SLOW!
		INVOKE_ASYNC(nano_assets, TYPE_PROC_REF(/datum/asset/simple/nanoui, send), user.client, ntemplate_filename) //ship it

//Do not qdel nanouis. Use close() instead.
/datum/nanoui/Destroy()
	user = null
	src_object = null
	state = null
	. = ..()

/**
 * Use this proc to add assets which are common to (and required by) all nano uis.
 */
/datum/nanoui/proc/add_common_assets()
	add_script("libraries.min.js"      ) // A JS file comprising of jQuery, doT.js and jQuery Timer libraries (compressed together)
	// add_script("nanoui.bundle.min.js"  ) // A JS file comprising of NanoUtility, NanoTemplate, NanoStateManager, NanoState, NanoStateDefault, NanoBaseCallbacks and NanoBaseHelpers (compressed together)

	add_script("nano_utility.js"       ) // The NanoUtility JS, this is used to store utility functions.
	add_script("nano_template.js"      ) // The NanoTemplate JS, this is used to render templates.
	add_script("nano_state_manager.js" ) // The NanoStateManager JS, it handles updates from the server and passes data to the current state
	add_script("nano_state.js"         ) // The NanoState JS, this is the base state which all states must inherit from
	add_script("nano_state_default.js" ) // The NanoStateDefault JS, this is the "default" state (used by all UIs by default), which inherits from NanoState
	add_script("nano_base_callbacks.js") // The NanoBaseCallbacks JS, this is used to set up (before and after update) callbacks which are common to all UIs
	add_script("nano_base_helpers.js"  ) // The NanoBaseHelpers JS, this is used to set up template helpers which are common to all UIs

	add_stylesheet("shared.css") // this CSS sheet is common to all UIs
	add_stylesheet("tgui.css"  ) // this CSS sheet is common to all UIs
	add_stylesheet("icons.css" ) // this CSS sheet is common to all UIs

/**
 * Set the current status (also known as visibility) of this ui.
 *
 * @param {(STATUS_INTERACTIVE|STATUS_UPDATE|STATUS_DISABLED|STATUS_CLOSE)} state - The status to set, see the defines at the top of this file
 * @param {boolean} push_update - Push an update to the ui to update it's status (an update is always sent if the status has changed to red (0))
 */
/datum/nanoui/proc/set_status(state, push_update)
	if(state != status) // Only update if it is different
		if(status == STATUS_DISABLED)
			status = state
			if(push_update)
				update()
		else
			status = state
			if(push_update || status == 0)
				push_data(null, 1) // Update the UI, force the update in case the status is 0, data is null so that previous data is used


/**
 * Update the status (visibility) of this ui based on the user's status.
 *
 * @param {boolean} push_update - Push an update to the ui to update it's status. This is set to FALSE if an update is going to be pushed anyway (to avoid unnessary updates)
 *
 * @returns {boolean} - TRUE if closed, FALSE otherwise.
 */
/datum/nanoui/proc/update_status(push_update = FALSE)
	var/atom/host = src_object && src_object.nano_host()
	if(!host)
		close()
		return TRUE
	var/new_status = host.CanUseTopic(user, state)
	if(master_ui)
		new_status = min(new_status, master_ui.status)

	if(new_status == STATUS_CLOSE)
		close()
		return TRUE

	set_status(new_status, push_update)

	return FALSE

/**
 * Set the ui to auto update (every master_controller tick).
 *
 * @param state {boolean} Set auto update to TRUE or FALSE.
 */
/datum/nanoui/proc/set_auto_update(nstate = TRUE)
	is_auto_updating = nstate

/**
 * Set the initial data for the ui. This is vital as the data structure set here cannot be changed when pushing new updates.
 *
 * @param data /list The list of data for this ui.
 */
/datum/nanoui/proc/set_initial_data(list/data)
	initial_data = data

/**
 * Get config data to sent to the ui.
 *
 * @returns {/list} - List of config data.
 */
/datum/nanoui/proc/get_config_data()
	var/name = "[src_object]"
	name = sanitize(name)
	var/decl/currency/cur = GET_DECL(global.using_map.default_currency)
	var/list/config_data = list(
		"title" = title,
		"srcObject" = list("name" = name),
		"stateKey" = state_key,
		"status" = status,
		"autoUpdateLayout" = auto_update_layout,
		"autoUpdateContent" = auto_update_content,
		"showMap" = show_map,
		"mapName" = global.using_map.path,
		"mapZLevel" = map_z_level,
		"mapZLevels" = SSmapping.map_levels,
		"user" = list("name" = user.name),
		"currency" = cur.name,
		"templateFileName" = global.template_file_name
	)
	return config_data

/**
 * Get data to sent to the ui.
 *
 * @param {/list} data - The list of general data for this ui (can be null to use previous data sent).
 *
 * @returns {/list} - data to send to the ui.
 */
/datum/nanoui/proc/get_send_data(list/data)
	var/list/config_data = get_config_data()

	var/list/send_data = list("config" = config_data)

	if(!isnull(data))
		send_data["data"] = data

	return send_data

/**
 * Set the browser window options for this ui.
 *
 * @param {string} nwindow_options - The new window options.
 */
/datum/nanoui/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

/**
 * Add a CSS stylesheet to this UI.
 * These must be added before the UI has been opened, adding after that will have no effect.
 *
 * @param {string} file - The name of the CSS file from /nano/css (e.g. "my_style.css")
 */
/datum/nanoui/proc/add_stylesheet(file)
	stylesheets.Add(file)

/**
 * Add a JavsScript script to this UI
 * These must be added before the UI has been opened, adding after that will have no effect
 *
 * @param {string} file - The name of the JavaScript file from /nano/js (e.g. "my_script.js")
 */
/datum/nanoui/proc/add_script(file)
	scripts.Add(file)

/**
 * Add a template for this UI
 * Templates are combined with the data sent to the UI to create the rendered view
 * These must be added before the UI has been opened, adding after that will have no effect
 *
 * @param {string} key - The key which is used to reference this template in the frontend
 * @param {string} filename - The name of the template file from /nano/templates (e.g. "my_template.jst")
 */
/datum/nanoui/proc/add_template(key, filename)
	templates[key] = filename

/**
 * Set the layout key for use in the frontend Javascript
 * The layout key is the basic layout key for the page
 *
 * Two files are loaded on the client based on the layout key varable:
 * - a template in /nano/templates with the filename "layout_<layout_key>.jst
 * - a CSS stylesheet in /nano/css with the filename "layout_<layout_key>.css
 *
 * @param {string} nlayout - The layout key to use
 */
/datum/nanoui/proc/set_layout_key(nlayout_key)
	layout_key = lowertext(nlayout_key)

 /**
 * Set the ui to update the layout (re-render it) on each update, turning this on will break the map ui (if it's being used)
 *
 * @param {boolean} state - Sets [auto_update_layout].
 */
/datum/nanoui/proc/set_auto_update_layout(state)
	auto_update_layout = state

/**
 * Set the ui to update the main content (re-render it) on each update
 *
 * @param {boolean} state - Set update to 1 or 0 (true/false) (default 1)
 */
/datum/nanoui/proc/set_auto_update_content(nstate)
	auto_update_content = nstate

/**
 * Set the state key for use in the frontend Javascript
 *
 * @param {string} nstate_key The key of the state to use
 */
/datum/nanoui/proc/set_state_key(nstate_key)
	state_key = nstate_key

/**
 * Toggle showing the map ui
 *
 * @param {boolean} nstate_key - TRUE to show map, FALSE to hide (default is FALSE)
 */
/datum/nanoui/proc/set_show_map(nstate)
	show_map = nstate

/**
 * Toggle showing the map ui
 *
 * @param {boolean} nstate_key - TRUE to show map, FALSE to hide (default is FALSE)
 */
/datum/nanoui/proc/set_map_z_level(nz)
	map_z_level = nz

/**
 * Set whether or not to use the "old" on close logic (mainly unset_machine())
 *
 * @param {boolean} state - Set on_close_logic to 1 or 0 (true/false)
 */
/datum/nanoui/proc/use_on_close_logic(state)
	on_close_logic = state

/**
 * Return the HTML for this UI
 *
 * @returns string HTML for the UI
 */
/datum/nanoui/proc/get_html()

	// before the UI opens, add the layout files based on the layout key
	add_stylesheet("layout_[layout_key].css")
	add_template("layout", "layout_[layout_key].jst")
	if(layout_header_key)
		add_template("layoutHeader", "layout_[layout_header_key].jst")

	var/html = SSnano.basehtml

	// Inject inline JS
	var/inline_js = ""
	for(var/filename in scripts)
		inline_js += "<script type='text/javascript' src='[filename]'></script>"
	if (inline_js)
		html = replacetextEx(html, "<!-- nanoui:inline-js -->", inline_js)

	// Inject inline CSS
	var/inline_css = ""
	for(var/filename in stylesheets)
		inline_css += "<link rel='stylesheet' type='text/css' href='[filename]'>"
	if (inline_css)
		html = replacetextEx(html, "<!-- nanoui:inline-css -->", inline_css)


	var/template_data_json = "{}" // An empty JSON object
	if(templates.len)
		template_data_json = strip_improper(json_encode(templates))

	var/initial_data_json = replacetextEx(replacetextEx(json_encode(get_send_data(initial_data)), "&#34;", "&amp;#34;"), "'", "&#39;")
	initial_data_json = strip_improper(initial_data_json);

	var/url_parameters_json = json_encode(list("src" = "\ref[src]"))

	html = replacetextEx(html, "\[nanoui:template_data_json]", template_data_json)
	html = replacetextEx(html, "\[nanoui:url_parameters_json]", url_parameters_json)
	html = replacetextEx(html, "\[nanoui:initial_data_json]", initial_data_json)

	return html

/**
 * Open this UI
 *
 * @returns nothing
 */
/datum/nanoui/proc/open()
	if(!user.client)
		return

	if(!src_object)
		close()

	var/window_size = ""
	if(width && height)
		window_size = "size=[width]x[height];"
	if(update_status(FALSE))
		return // Will be closed by update_status().

	user << browse(get_html(), "window=[window_id];[window_size][window_options]")
	winset(user, "mapwindow.map", "focus=true") // return keyboard focus to map
	on_close_winset()
	//onclose(user, window_id)
	SSnano.ui_opened(src)

/**
 * Reinitialise this UI, potentially with a different template and/or initial data
 *
 * @returns nothing
 */
/datum/nanoui/proc/reinitialise(template, new_initial_data)
	if(template)
		add_template("main", template)
	if(new_initial_data)
		set_initial_data(new_initial_data)
	open()

/**
 * Close this UI
 */
/datum/nanoui/proc/close()
	is_auto_updating = FALSE
	SSnano.ui_closed(src)
	show_browser(user, null, "window=[window_id]")
	for(var/datum/nanoui/child in children)
		child.close()
	children.Cut()
	state = null
	master_ui = null
	qdel(src)

/**
 * Set the UI window to call the nanoclose verb when the window is closed
 * This allows Nano to handle closed windows
 *
 * @returns nothing
 */
/datum/nanoui/proc/on_close_winset()
	if(!user.client)
		return
	var/params = "\ref[src]"

	spawn(2)
		if(!user || !user.client)
			return
		winset(user, window_id, "on-close=\"nanoclose [params]\"")

/**
 * Push data to an already open UI window
 *
 * @returns nothing
 */
/datum/nanoui/proc/push_data(data, force_push = 0)
	if(update_status(0))
		return // Closed
	if(status == STATUS_DISABLED && !force_push)
		return // Cannot update UI, no visibility
	to_output(user, list2params(list(strip_improper(json_encode(get_send_data(data))))),"[window_id].browser:receiveUpdateData")

/**
 * This Topic() proc is called whenever a user clicks on a link within a Nano UI
 * If the UI status is currently STATUS_INTERACTIVE then call the src_object Topic()
 * If the src_object Topic() returns 1 (true) then update all UIs attached to src_object
 */
/datum/nanoui/Topic(href, href_list)
	update_status(0) // update the status
	if(status != STATUS_INTERACTIVE || user != usr) // If UI is not interactive or usr calling Topic is not the UI user
		return

	// This is used to toggle the nano map ui
	var/map_update = 0
	if(href_list["showMap"])
		set_show_map(text2num(href_list["showMap"]))
		map_update = 1

	if(href_list["mapZLevel"])
		var/map_z = text2num(href_list["mapZLevel"])
		if(isMapLevel(map_z))
			set_map_z_level(map_z)
			map_update = 1

	if((src_object && src_object.Topic(href, href_list, state)) || map_update)
		SSnano.update_uis(src_object) // update all UIs attached to src_object

/**
 * Process this UI, updating the entire UI or just the status (aka visibility)
 *
 * @param {boolean} forced - string For this UI to update
 */
/datum/nanoui/proc/try_update(forced = FALSE)
	if(!src_object || !user)
		close()
		return

	if(status && (forced || is_auto_updating))
		update() // Update the UI (update_status() is called whenever a UI is updated)
	else
		update_status(1) // Not updating UI, so lets check here if status has changed

/**
 * This Process proc is called by SSnano.
 * Use try_update() to make manual updates.
 */
/datum/nanoui/Process()
	try_update()

/**
 * Update the UI
 *
 * @param {boolean} force_open - Force the UI to open
 */
/datum/nanoui/proc/update(force_open = FALSE)
	src_object.ui_interact(user, ui_key, src, force_open, master_ui, state)
