//As a general rule, all origin backrounds must have summ of +0 of stat values

/datum/category_group/setup_option_category/background/origin
	name = "Происхождение"
	category_item_type = /datum/category_item/setup_option/background/origin

/datum/category_item/setup_option/background/origin

/datum/category_item/setup_option/background/origin/corpo
	name = "Корпорат"
	desc = "Few leave the corporate world with their lives - fewer still with their souls intact. \
	You've been there - you've bent the rules, exploited secrets and weaponized information. \
	There's no such thing as a fair game, only winners and losers."

	stat_modifiers = list(
		STAT_ROB = -5,
		STAT_TGH = -5,
		STAT_VIG = 4,
		STAT_BIO = 7,
		STAT_MEC = 8,
		STAT_COG = 6
	)

/datum/category_item/setup_option/background/origin/streetkid
	name = "Дитя Улиц"
	desc = "They say if you wanna understand the streets, you gotta live 'em. Gangs, fixers, dolls, small-time pushers - you were raised by them all. \
	Down here the law of the jungle dictates the weak serve the strong - the only law in Night City you have yet to break."

	restricted_depts = SECURITY | SCIENCE

	stat_modifiers = list(
		STAT_ROB = 8,
		STAT_TGH = 6,
		STAT_VIG = 4,
		STAT_BIO = -2,
		STAT_MEC = -4,
		STAT_COG = -3
	)


/datum/category_item/setup_option/background/origin/nomad
	name = "Кочевник"
	desc = "Roaming the Badlands, looting scrapyards, raiding fuel depots - life on the road wasn't easy. \
	But growing up in a nomad clan has its perks. \
	Honesty, integrity, and a love of freedom - qualities that few in Navarro possess, and no amount of money can buy."

	stat_modifiers = list(
		STAT_ROB = 3,
		STAT_TGH = 3,
		STAT_VIG = 2,
		STAT_BIO = 3,
		STAT_MEC = 3,
		STAT_COG = 1
	)
