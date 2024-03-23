/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


/// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
/// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

/// When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

/client
	var/list/cache = list() //! List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() //! List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 //! Last job done.

/// This proc sends the asset to the client, but only if it needs it.
/// This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE, var/check_cache = TRUE)
	client = client?.get_client()
	if(!client)
		return FALSE

	if(check_cache && (client.cache.Find(asset_name) || client.sending.Find(asset_name)))
		return FALSE

	var/decl/asset_cache/asset_cache = GET_DECL(/decl/asset_cache)
	send_rsc(client, asset_cache.cache[asset_name], asset_name)
	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += asset_name
		return TRUE
	if (!client)
		return FALSE

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	direct_output(client, browse("<script>window.location.href='?asset_cache_confirm_arrival=[job]'</script>", "window=asset_cache_browser"))

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * client.sending.len) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return TRUE

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	client = client?.get_client()
	if(!client)
		return FALSE

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return FALSE
	if (unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		to_chat(client, "Sending resources...")
	var/decl/asset_cache/asset_cache = GET_DECL(/decl/asset_cache)
	for(var/asset in unreceived)
		if (asset in asset_cache.cache)
			send_rsc(client, asset_cache.cache[asset], asset)

	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += unreceived
		return TRUE
	if (!client)
		return FALSE
	client.sending |= unreceived
	var/job = ++client.last_asset_job

	direct_output(client, browse("<script>window.location.href='?asset_cache_confirm_arrival=[job]'</script>", "window=asset_cache_browser"))

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return TRUE

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(var/client/client, var/list/files, var/register_asset = TRUE)
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file,files[file])
		send_asset(client,file)
		sleep(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	var/decl/asset_cache/asset_cache = GET_DECL(/decl/asset_cache)
	asset_cache.cache[asset_name] = asset

//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
var/global/list/asset_datums = list()

//get a assetdatum or make a new one
/proc/get_asset_datum(var/type)
	if (!(type in asset_datums))
		return new type()
	return asset_datums[type]

/datum/asset/New()
	asset_datums[type] = src

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/simple/send(client)
	send_asset_list(client, assets, verify)


//DEFINITIONS FOR ASSET DATUMS START HERE.
var/global/template_file_name = "all_templates.json"

/datum/asset/simple/nanoui

	var/list/common_dirs = list(
		"nano/css/",
		"nano/images/",
		"nano/images/status_icons/",
		"nano/images/modular_computers/",
		"nano/public/",
		"nano/js/"
	)
	var/list/uncommon_dirs = list(
		"news_articles/images/"
	)
	var/list/template_dirs = list(
		"nano/templates/",
		"nano/templates/interfaces/",
		"nano/templates/layouts/",
	)
	var/template_temp_dir = "data/"

/datum/asset/simple/nanoui/register()
	// Crawl the directories to find files.
	var/list/exts = list(
		"js",
		"css",
		"html",
		"gif",
		"png",
		"jpg",
	)

	// Handle common and uncommon paths.
	for(var/path in directory_walk_exts(common_dirs, exts, 0))
		assets[filepath_extract_name(path)] = file(path)

	// Handle uncommon paths.
	for(var/path in directory_walk_exts(uncommon_dirs, exts, 0))
		assets[filepath_extract_name(path)] = file(path)

	// Handle Templates.
	merge_and_register_templates()

	// Handle map images.
	var/list/mapnames = list()
	for(var/z in SSmapping.map_levels)
		mapnames += map_image_file_name(z)

	for(var/path in directory_walk_exts(MAP_IMAGE_PATH, list("png"), 0))
		var/filename = filepath_extract_name(path)
		if((filename in mapnames) && fexists(path))
			assets[filename] = file(path)

	..()

/datum/asset/simple/nanoui/proc/merge_and_register_templates()
	var/list/templates = list()
	for(var/path in directory_walk_exts(template_dirs, list("jst"), 0))
		templates[filepath_extract_name(path)] = replacetext(replacetext(file2text(path), "\n", ""), "\t", "")

	// Handle the compiled template collection.
	var/full_file_name = template_temp_dir + global.template_file_name
	if(fexists(full_file_name))
		fdel(file(full_file_name))

	var/template_file = file(full_file_name)
	to_file(template_file, json_encode(templates))
	assets[global.template_file_name] = file(full_file_name)


/datum/asset/simple/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon, FALSE)
	send_asset_list(client, assets, TRUE)

	send_asset(client, global.template_file_name)

// Note: this is intended for dev work, and is unsafe. Do not use outside of that.
/datum/asset/simple/nanoui/proc/recompute_and_resend_templates()
	merge_and_register_templates()
	for(var/client/C in clients)
		if(C) // there are sleeps here, potentially
			send_asset(C, global.template_file_name, FALSE, FALSE)
			to_chat(C, SPAN_WARNING("Nanoui templates have been updated. Please close and reopen any browser windows."))

/client/proc/resend_nanoui_templates()
	set category = "Debug"
	set name = "Resend Nanoui Templates"
	if(!check_rights(R_DEBUG))
		return
	var/datum/asset/simple/nanoui/nano_asset = get_asset_datum(/datum/asset/simple/nanoui)
	if(nano_asset)
		nano_asset.recompute_and_resend_templates()

/*
	Asset cache
*/
/decl/asset_cache
	var/list/cache = list()

/decl/asset_cache/proc/load()
	for(var/type in subtypesof(/datum/asset) - /datum/asset/simple)
		var/datum/asset/A = new type()
		A.register()
		CHECK_TICK

	for(var/client/C in global.clients) // This is also called in client/New, but as we haven't initialized the cache until now, and it's possible the client is already connected, we risk doing it twice.
		// Doing this to a client too soon after they've connected can cause issues, also the proc we call sleeps.
		spawn(10)
			getFilesSlow(C, cache, FALSE)
