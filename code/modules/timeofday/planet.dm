// This holds information about a specific 'planetside' area, such as its time, weather, etc.  This will most likely be used to model Sif,
// but away missions may also have use for this.

/datum/planet
	var/name = "a rock"
	var/desc = "Someone neglected to write a nice description for this poor rock."

	var/datum/time/current_time = new() // Holds the current time for sun positioning.  Note that we assume day and night is the same length because simplicity.
	var/sun_process_interval = 3600 SECONDS
	var/sun_last_process = null // world.time

	var/datum/weather_holder/weather_holder

	var/sun_position = 0 // 0 means midnight, 1 means noon.

/datum/planet/New()
	..()
	current_time = current_time.make_random_time()
	update_sun()

/datum/planet/proc/process(amount)
	if(current_time)
		current_time = current_time.add_seconds(amount)
	if(sun_last_process <= world.time - sun_process_interval)
		update_sun()

// This changes the position of the sun on the planet.
/datum/planet/proc/update_sun()
	sun_last_process = world.time

// Returns the time datum of Sif.
/proc/get_sif_time()
	if(planet_sif)
		return planet_sif.current_time