/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Текущие игроки:</b>\n"

	var/list/Lines = list()

	if(holder && (R_ADMIN & holder.rights || R_MOD & holder.rights))
		for(var/client/C in clients)
			var/entry = "\t[C.key]"
			if(C.holder && C.holder.fakekey)
				entry += " <i>(как [C.holder.fakekey])</i>"
			if(SSticker.current_state == GAME_STATE_PREGAME)
				entry += " - Готов как [C.prefs.real_name]"
			else
				entry += " - Играет как [C.mob.real_name]"
			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <font color='darkgray'><b>Без сознания</b></font>"
				if(DEAD)
					if(isghost(C.mob))
						var/mob/observer/ghost/O = C.mob
						if(O.started_as_observer)
							entry += " - <font color='gray'>Наблюдает</font>"
						else
							entry += " - <font color='black'><b>МЁРТВ</b></font>"
					else
						entry += " - <font color='black'><b>МЁРТВ</b></font>"

			if(is_special_character(C.mob))
				entry += " - <b><span class='warning'>Антагонист</font></b>"

			if(C.is_afk())
				entry += " (AFK - [C.inactivity2text()])"

			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in clients)
			if(C.holder && C.holder.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	msg += "<b>Всего игроков: [length(Lines)]</b>"
	to_chat(src, msg)

/client/verb/adminwho()
	set category = "Admin"
	set name = "Adminwho"

	var/msg = ""
	var/modmsg = ""
	var/mentmsg = ""
	var/num_mods_online = 0
	var/num_admins_online = 0
	var/num_mentors_online = 0
	if(holder)
		for(var/client/C in admins)
			if(R_ADMIN & C.holder.rights || (!R_MOD & C.holder.rights && !R_MENTOR & C.holder.rights))	//Used to determine who shows up in admin rows

				if(C.holder.fakekey && (!R_ADMIN & holder.rights && !R_MOD & holder.rights))		//Mentors can't see stealthmins
					continue

				msg += "\t[C] [C.holder.rank]"

				if(C.holder.fakekey)
					msg += " <i>(как [C.holder.fakekey])</i>"

				if(isobserver(C.mob))
					msg += " - Наблюдает"
				else if(isnewplayer(C.mob))
					msg += " - Лобби"
				else
					msg += " - Играет"

				if(C.is_afk())
					msg += " (AFK - [C.inactivity2text()])"
				msg += "\n"

				num_admins_online++
			else if(R_MOD & C.holder.rights)				//Who shows up in mod/mentor rows.
				modmsg += "\t[C] [C.holder.rank]"

				if(isobserver(C.mob))
					modmsg += " - Наблюдает"
				else if(isnewplayer(C.mob))
					modmsg += " - Лобби"
				else
					modmsg += " - Играет"

				if(C.is_afk())
					modmsg += " (AFK - [C.inactivity2text()])"
				modmsg += "\n"
				num_mods_online++

			else if(R_MENTOR & C.holder.rights)
				mentmsg += "\t[C] [C.holder.rank]"
				if(isobserver(C.mob))
					mentmsg += " - Наблюдает"
				else if(isnewplayer(C.mob))
					mentmsg += " - Лобби"
				else
					mentmsg += " - Играет"

				if(C.is_afk())
					mentmsg += " (AFK - [C.inactivity2text()])"
				mentmsg += "\n"
				num_mentors_online++

	else
		for(var/client/C in admins)
			if(R_ADMIN & C.holder.rights || (!R_MOD & C.holder.rights && !R_MENTOR & C.holder.rights))
				if(!C.holder.fakekey)
					msg += "\t[C] [C.holder.rank]\n"
					num_admins_online++
			else if (R_MOD & C.holder.rights)
				modmsg += "\t[C] [C.holder.rank]\n"
				num_mods_online++
			else if (R_MENTOR & C.holder.rights)
				mentmsg += "\t[C] [C.holder.rank]\n"
				num_mentors_online++

	if(config.admin_irc)
		to_chat(src, "<span class='info'>Adminhelps are also sent to IRC. If no admins are available in game try anyway and an admin on IRC may see it and respond.</span>")
	msg = "<b>Текущая администрация ([num_admins_online]):</b>\n" + msg

	if(config.show_mods)
		msg += "\n<b> Текущие модераторы ([num_mods_online]):</b>\n" + modmsg

	if(config.show_mentors)
		msg += "\n<b> Текущие менторы ([num_mentors_online]):</b>\n" + mentmsg

	to_chat(src, msg)
