/datum/map/rift
	name = "Rift"
	full_name = "NSB Atlas"
	path = "rift"
	ground_noun = "plated covering"

	system_name   = "Lythios-43"

	station_name  = "NSB \"Atlas\""
	station_short = "Atlas"

	dock_name     = "NSS Demeter"
	boss_name     = "Central Command"
	boss_short    = "CC"
	company_name  = "NanoTrasen"
	company_short = "NT"

	lobby_screens = list('maps/rift/lobby/citadel_lobby.png')
	welcome_sound = 'sound/effects/alarm.ogg'

	overmap_ids = list(OVERMAP_ID_SPACE)
	num_exoplanets = 1

	emergency_shuttle_leaving_dock = "Attention all hands: the escape pods have been launched, maintaining burn for %ETA%."
	emergency_shuttle_called_message = "Attention all hands: emergency evacuation procedures are now in effect. Escape pods will launch in %ETA%"
	emergency_shuttle_recall_message = "Attention all hands: emergency evacuation sequence aborted. Return to normal operating conditions."
	evac_controller_type = /datum/evacuation_controller/lifepods

	starting_money = 70000
	department_money = 0
	salary_modifier = 1

	radiation_detected_message = "High levels of radiation have been detected in proximity of the %STATION_NAME%. Please move to the closest saferoom available."

	allowed_spawns = list(/decl/spawnpoint/cryo)
	default_spawn = /decl/spawnpoint/cryo

// /datum/map/rift/get_map_info()
// 	return

/datum/map/rift/create_trade_hubs()
	new/datum/trade_hub/rift()

/datum/trade_hub/rift
	name = "Long-Range Subspace Trade Uplink"

/datum/trade_hub/rift/get_initial_traders()
	return list(
		/datum/trader/medical,
		/datum/trader/mining,
	)
