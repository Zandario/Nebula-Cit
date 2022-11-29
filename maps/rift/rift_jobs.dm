/datum/map/rift
	default_job_type = /datum/job/rift_crew
	default_department_type = /decl/department/rift_crew
	allowed_jobs = list(/datum/job/rift_crew)
	// id_hud_icons = 'maps/rift/hud.dmi'

/datum/job/rift_crew
	title = "Atlas Crew"
	total_positions = -1
	spawn_positions = -1
	supervisors = "your conscience"
	economic_power = 1
	access = list()
	minimal_access = list()
	outfit_type = /decl/hierarchy/outfit/job/rift_crew
	department_types = list(/decl/department/rift_crew)

/decl/hierarchy/outfit/job/rift_crew
	name = "Job - Atlas Crewmember"
