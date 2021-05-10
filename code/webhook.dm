/proc/webhook_send_roundstatus(var/status, var/extraData)
	var/list/query = list("status" = status)

	if(extraData)
		query.Add(extraData)

	webhook_send("roundstatus", query)

/proc/webhook_send_runtime(var/message) //when server logging gets fucked up, discord bot saves the day
	var/list/query = list("message" = message)
	webhook_send("runtimemessage", query)

/proc/webhook_send_asay(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("asaymessage", query)

/proc/webhook_send_ooc(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("oocmessage", query)

/proc/webhook_send_me(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("memessage", query)

/proc/webhook_send_ahelp(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("ahelpmessage", query)

/proc/webhook_send_garbage(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("garbage", query)

/proc/webhook_send_token(var/ckey, var/token)
	var/list/query = list("ckey" = ckey, "token" = token)
	webhook_send("token", query)

/proc/webhook_send_status_update(var/event,var/data)
	var/list/query = list("event" = event, "data" = data)
	webhook_send("status_update", query)

/proc/webhook_send(var/method, var/data)
	if (!config?.cumhook_url || !config?.cumhook_key)
		return

	var/query = "[config.cumhook_url]?key=[config.cumhook_key]&method=[method]&data=[url_encode(json_encode(data))]"
	spawn(-1)
		world.Export(query)

/client/verb/bot_token()
	set name = "Discord Bot Auth"
	set category = "OOC"
	set desc = "Send your discord id to connect your accounts"

	src << link("https://discord.com/oauth2/authorize?client_id=541713413424939019&redirect_uri=http%3A%2F%2Fbot.station13.ru%2Fconnect&response_type=code&scope=identify&state=[authhookplease(key)]")

/proc/authhookplease(key)
	return "[key]@[sha1(key + "[config.cumhook_key]")]"
