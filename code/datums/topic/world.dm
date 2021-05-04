/datum/world_topic
	var/keyword
	var/log = TRUE
	var/key_valid
	var/require_comms_key = FALSE

/datum/world_topic/proc/TryRun(list/input)
	key_valid = !config || config.comms_password != input["key"]
	if(require_comms_key && !key_valid)
		return "Bad Key"
	input -= "key"
	. = Run(input)
	if(islist(.))
		. = list2params(.)

/datum/world_topic/proc/Run(list/input)
	CRASH("Run() not implemented for [type]!")


////////////////////////////////
/////////////Topics/////////////

/datum/world_topic/ping
	keyword = "ping"
	log = FALSE

/datum/world_topic/ping/Run(list/input)
	var/x = 0
	for(var/client/C in clients)
		x++
	return x


/datum/world_topic/status
	keyword = "status"
	log = FALSE

/datum/world_topic/status/Run(list/input)
	if(!key_valid) //If we have a key, then it's safe to trust that this isn't a malicious packet. Also prevents the extra info from leaking
		if(GLOB.topic_status_lastcache <= world.time)
			return GLOB.topic_status_cache
		GLOB.topic_status_lastcache = world.time + 5
	var/list/s = list()
	s["version"] = game_version
	s["storyteller"] = master_storyteller
	s["respawn"] = config.abandon_allowed
	s["enter"] = config.enter_allowed
	s["vote"] = config.allow_vote_mode
	s["ai"] = config.allow_ai
	s["host"] = host ? host : null

	// This is dumb, but spacestation13.com's banners break if player count isn't the 8th field of the reply, so... this has to go here.
	s["players"] = 0
	s["shiptime"] = stationtime2text()
	s["roundduration"] = roundduration2text()

	s["stationname"] = station_name
	s["storyteller"] = "[get_storyteller() ? get_storyteller().name : "LOBBY"]"

	var/decl/security_state/security_state = decls_repository.get_decl(maps_data.security_state)
	s["securitylevel"] = "[security_state.current_security_level.name]" 

	//this entire part is dedicated to getting shuttle status and ETA.
	//It could've been a one-liner, but it would be an unreadable mess.
	var/shuttle_status = "Idle"
	if(evacuation_controller.has_eta())
		if(evacuation_controller.is_arriving())
			shuttle_status = "ETA:"
		else if(evacuation_controller.is_prepared())
			shuttle_status = "ETD:"
		else if(evacuation_controller.is_in_transit())
			shuttle_status = "ESC:"
		else if(evacuation_controller.is_on_cooldown())
			shuttle_status = "RCL:"
	var/raw_shuttle_time = evacuation_controller.get_eta()
	var/shuttle_time = 0
	if(shuttle_status!="Idle")
		shuttle_time = "[add_zero(num2text((raw_shuttle_time / 60) % 60),2)]:[add_zero(num2text(raw_shuttle_time % 60), 2)]"
	else
		shuttle_time = ""
	s["evac"] = "[shuttle_status] [shuttle_time]"


	if(input["status"] == "2")
		var/list/players = list()
		var/list/admins = list()

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue
				admins[C.key] = C.holder.rank
			players += C.key

		s["players"] = players.len
		s["playerlist"] = list2params(players)
		s["admins"] = admins.len
		s["adminlist"] = list2params(admins)
	else
		var/n = 0
		var/admins = 0

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admins++
			s["player[n]"] = C.key
			n++

		s["players"] = n
		s["admins"] = admins

	if(!key_valid)
		GLOB.topic_status_cache = .
	return s


/datum/world_topic/manifest
	keyword = "manifest"

/datum/world_topic/manifest/Run(list/input)
	var/list/positions = list()
	var/list/set_names = list(
			"heads" = command_positions,
			"sec" = security_positions,
			"eng" = engineering_positions,
			"med" = medical_positions,
			"sci" = science_positions,
			"car" = cargo_positions,
			"civ" = civilian_positions,
			"chr" = church_positions,
			"pro" = prospector_positions,
			"bot" = nonhuman_positions
		)

	for(var/datum/data/record/t in data_core.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/real_rank = make_list_rank(t.fields["real_rank"])

		var/department = FALSE
		for(var/k in set_names)
			if(real_rank in set_names[k])
				if(!positions[k])
					positions[k] = list()
				positions[k][name] = rank
				department = TRUE
		if(!department)
			if(!positions["misc"])
				positions["misc"] = list()
			positions["misc"][name] = rank

	for(var/k in positions)
		positions[k] = list2params(positions[k]) // converts positions["heads"] = list("Bob"="Captain", "Bill"="CMO") into positions["heads"] = "Bob=Captain&Bill=CMO"

	return positions


/datum/world_topic/revision
	keyword = "revision"

/datum/world_topic/revision/Run(list/input)
	if(revdata.revision)
		return list(branch = revdata.branch, date = revdata.date, revision = revdata.revision)
	else
		return "unknown"

/datum/world_topic/info
	keyword = "info"
	require_comms_key = TRUE

/datum/world_topic/info/Run(list/input)
	var/list/search = params2list(input["info"])
	var/list/ckeysearch = list()
	for(var/text in search)
		ckeysearch += ckey(text)

	var/list/match = list()

	for(var/mob/M in SSmobs.mob_list)
		var/strings = list(M.name, M.ckey)
		if(M.mind)
			strings += M.mind.assigned_role
		for(var/text in strings)
			if(ckey(text) in ckeysearch)
				match[M] += 10 // an exact match is far better than a partial one
			else
				for(var/searchstr in search)
					if(findtext(text, searchstr))
						match[M] += 1

	var/maxstrength = 0
	for(var/mob/M in match)
		maxstrength = max(match[M], maxstrength)
	for(var/mob/M in match)
		if(match[M] < maxstrength)
			match -= M

	if(!match.len)
		return "No matches"
	else if(match.len == 1)
		var/mob/M = match[1]
		var/info = list()
		info["key"] = M.key
		info["name"] = M.name == M.real_name ? M.name : "[M.name] ([M.real_name])"
		info["role"] = M.mind ? (M.mind.assigned_role ? M.mind.assigned_role : "No role") : "No mind"
		info["antag"] = M.mind ? (M.mind.antagonist.len ? "Antag" : "Not antag") : "No mind"
		info["hasbeenrev"] = M.mind ? M.mind.has_been_rev : "No mind"
		info["stat"] = M.stat
		info["type"] = M.type
		if(isliving(M))
			var/mob/living/L = M
			info["damage"] = list2params(list(
						oxy = L.getOxyLoss(),
						tox = L.getToxLoss(),
						fire = L.getFireLoss(),
						brute = L.getBruteLoss(),
						clone = L.getCloneLoss(),
						brain = L.getBrainLoss()
					))
		else
			info["damage"] = "non-living"
		info["gender"] = M.gender
		return list2params(info)
	else
		var/list/ret = list()
		for(var/mob/M in match)
			ret[M.key] = M.name
		return list2params(ret)


/datum/world_topic/adminmsg
	keyword = "adminmsg"
	require_comms_key = TRUE

/datum/world_topic/adminmsg/Run(list/input)
		/*
		We got an adminmsg from IRC bot lets split the input then validate the input.
		expected output:
			1. adminmsg = ckey of person the message is to
			2. msg = contents of message, parems2list requires
			3. validatationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
			4. sender = the ircnick that send the message.
	*/

	var/client/C
	var/req_ckey = ckey(input["adminmsg"])

	for(var/client/K in clients)
		if(K.ckey == req_ckey)
			C = K
			break
	if(!C)
		return "No client with that name on server"

	var/rank = input["rank"]
	if(!rank)
		rank = "Admin"

	var/message =	"<span class='warning'>IRC-[rank] PM from <b><a href='?irc_msg=[input["sender"]]'>IRC-[input["sender"]]</a></b>: [input["msg"]]</font>"
	var/amessage =  "<span class='notice'>IRC-[rank] PM from <a href='?irc_msg=[input["sender"]]'>IRC-[input["sender"]]</a> to <b>[key_name(C)]</b> : [input["msg"]]</span>"

	C.received_irc_pm = world.time
	C.irc_admin = input["sender"]

	C << 'sound/effects/adminhelp.ogg'
	to_chat(C, message)


	for(var/client/A in admins)
		if(A != C)
			to_chat(A, amessage)

	return "Message Successful"


/datum/world_topic/players
	keyword = "players"
	log = FALSE

/datum/world_topic/players/Run(list/input)
	return GLOB.player_list.len

/datum/world_topic/adminwho
	keyword = "adminwho"
	log = FALSE

/datum/world_topic/adminwho/Run(list/input)
	var/msg = "Педали:\n"
	for(var/client/C in admins)
		if(!C.holder.fakekey)
			msg += "\t[C] - [C.holder.rank]"
			msg += "\n"
	return msg

/datum/world_topic/who
	keyword = "who"
	log = FALSE

/datum/world_topic/who/Run(list/input)
	var/msg = "Текущие игроки:\n"
	var/n = 0
	for(var/client/C in clients)
		n++
		if(C.holder && C.holder.fakekey)
			msg += "\t[C.holder.fakekey]\n"
		else
			msg += "\t[C.key]\n"
	msg += "Всего: [n]"
	return msg

/datum/world_topic/asay
	keyword = "asay"
	require_comms_key = TRUE

/datum/world_topic/asay/Run(list/input)
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, "<span class='admin_channel'>" + create_text_tag("admin", "ADMIN:", C) + " <span class='name'>[input["admin"]]</span>(DISCORD): <span class='message'>[copytext_char(input["asay"], 23, -7)]</span></span>")

/datum/world_topic/ooc
	keyword = "ooc"
	require_comms_key = TRUE

/datum/world_topic/ooc/Run(list/input)
	if(!config.ooc_allowed && !input["isadmin"])
		return "globally muted"

	for(var/client/C in clients)
		to_chat(C, "<span class='ooc'><span class='everyone'>" + create_text_tag("dooc", "DOOC:", C) + " <EM>[input["ckey"]]:</EM> <span class='message'>[input["ooc"]]</span></span></span>")

/datum/world_topic/ahelp
	keyword = "adminhelp"
	require_comms_key = TRUE

/datum/world_topic/ahelp/Run(list/input)
	if(!key_valid)
		if(abs(world_topic_spam_protect_time - world.time) < 50)
			sleep(50)
			world_topic_spam_protect_time = world.time
			return "Bad Key (Throttled)"
		world_topic_spam_protect_time = world.time
		return "Bad Key"

	var/client/C
	var/req_ckey = ckey(input["ckey"])

	for(var/client/K in clients)
		if(K.ckey == req_ckey)
			C = K
			break
	if(!C)
		return "No client with that name on server"

	var/rank = "Discord Admin"
	var/response = html_encode(input["response"])

	var/message = "<span class='warning'>[rank] PM from <b>[input["admin"]]</b>: [response]</font>"
	var/amessage =  "<span class='info'>[rank] PM from [input["admin"]] to <b>[key_name(C)]</b> : [response])]</span>"
	webhook_send_ahelp("[input["admin"]] -> [req_ckey]", response)

	sound_to(C, sound('sound/effects/adminhelp.ogg'))
	to_chat(C, message)

	for(var/client/A in admins)
		if(A != C)
			to_chat(A, amessage)
	return "Message Successful"
