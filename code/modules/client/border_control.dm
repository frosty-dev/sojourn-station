#define BORDER_CONTROL_DISABLED 0
#define BORDER_CONTROL_LEARNING 1
#define BORDER_CONTROL_ENFORCED 2

var/list/whitelistedCkeys
var/savefile/borderControlFile = new /savefile("data/bordercontrol.db")
var/whitelistLoaded = 0

//////////////////////////////////////////////////////////////////////////////////
proc/BC_IsKeyAllowedToConnect(var/key)
	key = ckey(key)

	if(config.borderControl == BORDER_CONTROL_DISABLED)
		return 1
	else if (config.borderControl == BORDER_CONTROL_LEARNING)
		if(!BC_IsKeyWhitelisted(key))
			//log_and_message_admins("[key] has joined and was added to the border whitelist.")
			//WHITELIST AUTOJOBBAN
			var/list/whitelist_jobbs
			whitelist_jobbs = list("Premier","Steward","Militia Commander","Warrant Officer","Chief Executive Officer",
					"Guild Master","Chief Biolab Overseer","Chief Research Overseer","Prime",
					"Militia Commander","Warrant Officer","Ranger","Corpsman",
					"Blackshield Trooper","Marshal Officer","Sergeant","AI","Supply Specialist")
			log_and_message_admins("New player ---[key]--- has joined!")
			establish_db_connection()
			if(!dbcon.IsConnected())
				log_and_message_admins("WHITELIST AUTOJOBBAN: Connection to the database failed!")
				return 1
			var/server = "[world.internet_address]:[world.port]"
			var/bantype_pass = 1
			var/bantype_str = "JOB_PERMABAN"
			var/duration = -1
			var/reason = "WHITELIST AUTOJOBBAN"
			var/ckey = key
			var/computerid = null
			var/ip = null
			var/target_id = null
			var/DBQuery/query
			if(!target_id)
				query = dbcon.NewQuery("SELECT id FROM players WHERE ckey = '[ckey]'")
				query.Execute()
				if(!query.NextRow())
					log_and_message_admins("WHITELIST AUTOJOBBAN ERROR: CAN'T DO NEXT ROW FOR ---[ckey]---")
					return
				target_id = query.item[1]
			var/banned_by_id = 1
			for(var/job in whitelist_jobbs)
				var/sql = "INSERT INTO bans (target_id, time, server, type, reason, job, duration, expiration_time, cid, ip, banned_by_id) VALUES ([target_id], Now(), '[server]', '[bantype_str]', '[reason]', '[job]', [(duration)?"[duration]":"0"], Now() + INTERVAL [(duration>0) ? duration : 0] MINUTE, '[computerid]', '[ip]', [banned_by_id])"
				var/DBQuery/query_insert = dbcon.NewQuery(sql)
				if(!query_insert.Execute())
					log_and_message_admins("WHITELIST AUTOJOBBAN ERROR: CAN'T CREATE NEW ENTRY FOR ---[ckey]--- [query_insert.ErrorMsg()]")
		BC_WhitelistKey(key)
		return 1
	else
		return BC_IsKeyWhitelisted(key)

//////////////////////////////////////////////////////////////////////////////////
proc/BC_IsKeyWhitelisted(var/key)
	key = ckey(key)

	if(!whitelistLoaded)
		BC_LoadWhitelist()

	if(LAZYISIN(whitelistedCkeys, key))
		return 1
	else
		return 0

//////////////////////////////////////////////////////////////////////////////////
ADMIN_VERB_ADD(/client/proc/BC_WhitelistKeyVerb, R_ADMIN, FALSE)
/client/proc/BC_WhitelistKeyVerb()

	set name = "Border Control - Whitelist Key"
	set category = "Admin"

	var/key = input("CKey to Whitelist", "Whitelist Key") as null|text

	if(key)
		var/confirm = alert("Add [key] to the border control whitelist?", , "Yes", "No")
		if(confirm == "Yes")
			log_and_message_admins("[key_name(usr)] added [key] to the border whitelist.")
			BC_WhitelistKey(key)


//////////////////////////////////////////////////////////////////////////////////
proc/BC_WhitelistKey(var/key)
	key = ckey(key)

	if(!whitelistLoaded)
		BC_LoadWhitelist()

	if(key)
		if(!LAZYISIN(whitelistedCkeys,key))
			LAZYINITLIST(whitelistedCkeys)

			ADD_SORTED(whitelistedCkeys, key, /proc/cmp_text_asc)
			BC_SaveWhitelist()
			return 1
		else // Already in
			return 0

		return


//////////////////////////////////////////////////////////////////////////////////
ADMIN_VERB_ADD(/client/proc/BC_RemoveKeyVerb, R_ADMIN, FALSE)
/client/proc/BC_RemoveKeyVerb()

	set name = "Border Control - Remove Key"
	set category = "Admin"

	var/keyToRemove = input("CKey to Remove", "Remove Key") as null|anything in whitelistedCkeys

	if(keyToRemove)
		var/confirm = alert("Remove [keyToRemove] from the border control whitelist?", , "Yes", "No")
		if(confirm == "Yes")
			log_and_message_admins("[key_name(usr)] removed [keyToRemove] from the border whitelist.")
			BC_RemoveKey(keyToRemove)

	return


//////////////////////////////////////////////////////////////////////////////////
/client/proc/BC_RemoveKey(var/key)
	key = ckey(key)

	if(!LAZYISIN(whitelistedCkeys, key))
		return 1
	else
		if(whitelistedCkeys)
			whitelistedCkeys.Remove(key)
		BC_SaveWhitelist()
		return 1




//////////////////////////////////////////////////////////////////////////////////
ADMIN_VERB_ADD(/client/proc/BC_ToggleState, R_ADMIN, FALSE)
/client/proc/BC_ToggleState()

	set name = "Border Control - Toggle Mode"
	set category = "Admin"

	var/choice = input("New State", "Border Control State") as null|anything in list("Disabled", "Learning", "Enforced")

	switch(choice)
		if("Disabled")
			if(config.borderControl != BORDER_CONTROL_DISABLED)
				config.borderControl = BORDER_CONTROL_DISABLED
				log_and_message_admins("[key_name(usr)] has disabled border control.")
		if("Learning")
			if(config.borderControl != BORDER_CONTROL_LEARNING)
				config.borderControl = BORDER_CONTROL_LEARNING
				log_and_message_admins("[key_name(usr)] has set border control to learn new keys on connection!")
			var/confirm = alert("Learn currently connected keys?", , "Yes", "No")
			if(confirm == "Yes")
				for(var/client/C in clients)
					if (BC_WhitelistKey(C.key))
						log_and_message_admins("[key_name(usr)] added [C.key] to the border whitelist by adding all current clients.")

		if("Enforced")
			if(config.borderControl != BORDER_CONTROL_ENFORCED)
				config.borderControl = BORDER_CONTROL_ENFORCED
				log_and_message_admins("[key_name(usr)] has enforced border controls. New keys can no longer join.")

	// Else do nothing

	return


//////////////////////////////////////////////////////////////////////////////////

/hook/startup/proc/loadBorderControlWhitelistHook()
	BC_LoadWhitelist()
	return 1

//////////////////////////////////////////////////////////////////////////////////
/proc/BC_LoadWhitelist()

	LAZYCLEARLIST(whitelistedCkeys)

	LAZYINITLIST(whitelistedCkeys)

	if(!borderControlFile)
		return 0

	borderControlFile["WhitelistedCkeys"] >> whitelistedCkeys

	whitelistLoaded = 1


//////////////////////////////////////////////////////////////////////////////////
proc/BC_SaveWhitelist()
	if(!whitelistedCkeys)
		return 0

	if(!borderControlFile)
		return 0

	borderControlFile["WhitelistedCkeys"] << whitelistedCkeys
