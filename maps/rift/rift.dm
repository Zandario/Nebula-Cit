#if !defined(USING_MAP_DATUM)

	//Content & etc

	#include "../../mods/content/bigpharma/_bigpharma.dme"
	#include "../../mods/content/matchmaking/_matchmaking.dme"
	#include "../../mods/content/scaling_descriptors.dm"

	//Species

	#include "../../mods/species/utility_frames/_utility_frames.dme"
	#include "../../mods/species/neoavians/_neoavians.dme"

	#include "rift_areas.dm"
	#include "rift_departments.dm"
	#include "rift_jobs.dm"
	#include "rift_overmap.dm"
	#include "rift_unit_testing.dm"
	#include "rift-1-surface.dmm"

	#define USING_MAP_DATUM /datum/map/rift

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Nexus

#endif
