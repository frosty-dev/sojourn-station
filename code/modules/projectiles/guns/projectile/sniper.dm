/obj/item/weapon/gun/projectile/heavysniper
	name = "Anti-Materiel Rifle"
	desc = "A heavy anti-material rifle fitted with a scope, it was originally designed for use against armoured exosuits. It is capable of punching through windows and non-reinforced walls with ease. Fires armor piercing .60-06 shells."
	icon = 'icons/obj/guns/projectile/heavysniper.dmi'
	icon_state = "heavysniper"
	item_state = "heavysniper"
	w_class = ITEM_SIZE_HUGE
	force = WEAPON_FORCE_PAINFUL
	slot_flags = SLOT_BACK
	origin_tech = list(TECH_COMBAT = 5, TECH_MATERIAL = 2, TECH_ILLEGAL = 2)
	caliber = CAL_ANTIM
	recoil_buildup = 75
	handle_casings = HOLD_CASINGS
	load_method = SINGLE_CASING
	max_shells = 1
	ammo_type = /obj/item/ammo_casing/antim
	fire_sound = 'sound/weapons/guns/fire/sniper_fire.ogg'
	reload_sound 	= 'sound/weapons/guns/interact/rifle_load.ogg'
	matter = list(MATERIAL_PLASTEEL = 40, MATERIAL_PLASTIC = 20, MATERIAL_DIAMOND = 3, MATERIAL_OSMIUM = 5, MATERIAL_URANIUM = 2)
	price_tag = 20000
	one_hand_penalty = 100
	var/bolt_open = 0
	var/item_suffix = ""
	zoom_factor = 2.0
	twohanded = TRUE

/obj/item/weapon/gun/projectile/heavysniper/update_icon()
	..()

	var/iconstring = initial(icon_state)
	var/itemstring = ""

	if (item_suffix)
		itemstring += "[item_suffix]"

	if (bolt_open)
		iconstring += "_open"
	else
		iconstring += "_closed"

	icon_state = iconstring
	set_item_state(itemstring)



/obj/item/weapon/gun/projectile/heavysniper/attack_self(mob/user) //Someone overrode attackself for this class, soooo.
	if(zoom)
		toggle_scope(user)
		return
	bolt_act(user)

/obj/item/weapon/gun/projectile/heavysniper/proc/bolt_act(mob/living/user)
	playsound(src.loc, 'sound/weapons/guns/interact/rifle_boltback.ogg', 75, 1)
	bolt_open = !bolt_open
	if(bolt_open)
		if(chambered)
			to_chat(user, SPAN_NOTICE("You work the bolt open, ejecting [chambered]!"))
			chambered.loc = get_turf(src)
			loaded -= chambered
			chambered = null
		else
			to_chat(user, SPAN_NOTICE("You work the bolt open."))
	else
		to_chat(user, SPAN_NOTICE("You work the bolt closed."))
		playsound(src.loc, 'sound/weapons/guns/interact/rifle_boltforward.ogg', 75, 1)
		bolt_open = 0
	add_fingerprint(user)
	update_icon()

/obj/item/weapon/gun/projectile/heavysniper/special_check(mob/user)
	if(bolt_open)
		to_chat(user, SPAN_WARNING("You can't fire [src] while the bolt is open!"))
		return 0
	return ..()

/obj/item/weapon/gun/projectile/heavysniper/load_ammo(var/obj/item/A, mob/user)
	if(!bolt_open)
		return
	..()

/obj/item/weapon/gun/projectile/heavysniper/unload_ammo(mob/user, var/allow_dump=1)
	if(!bolt_open)
		return
	..()

/obj/item/weapon/weaponparts
	var/part_color = ""
	name = "weaponpart"
	desc = "how did you get it?"
	icon = 'icons/obj/weaponparts.dmi'

/obj/item/weapon/weaponparts/heavysniper/stock
	name = "sniper stock"
	desc = "This is a sniper stock. You need to attach the reciever."
	icon_state = "sniper_stock"

/obj/item/weapon/weaponparts/heavysniper/reciever
	name = "sniper reciever"
	desc = "This is a sniper reciever. You need to attach it to the stock."
	icon_state = "sniper_reciever"

/obj/item/weapon/weaponparts/heavysniper/stockreciever
	name = "sniper stock with reciever"
	desc = "This is a sniper stock with reciever. Now attach the barrel."
	icon_state = "sniper_stockreciever"

/obj/item/weapon/weaponparts/heavysniper/barrel
	name = "sniper rifle barrel"
	desc = "This is a barrel from a sniper rifle."
	icon_state = "sniper_barrel"

/obj/item/weapon/weaponparts/heavysniper/stock/attackby(obj/item/W, mob/user,)
	if(istype(W,/obj/item/weapon/weaponparts/heavysniper/reciever))
		to_chat(user, "You attach the reciever to the stock")
		var/obj/item/weapon/weaponparts/heavysniper/stockreciever/HS = new (get_turf(src))
		if(loc == user)
			equip_slot = user.get_inventory_slot(src)
			if(equip_slot in list(slot_r_hand, slot_l_hand))
				user.drop_from_inventory(src)
				user.equip_to_slot_if_possible(HS, equip_slot)
		qdel(W)
		qdel(src)


/obj/item/weapon/weaponparts/heavysniper/stockreciever/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/weaponparts/heavysniper/barrel))
		to_chat(user, "You attach the barrel to the stock")
		var/obj/item/weapon/gun/projectile/heavysniper/HS = new (get_turf(src))
		if(loc == user)
			equip_slot = user.get_inventory_slot(src)
			if(equip_slot in list(slot_r_hand, slot_l_hand))
				user.drop_from_inventory(src)
				user.equip_to_slot_if_possible(HS, equip_slot)
		qdel(W)
		qdel(src)

/obj/item/weapon/gun/projectile/revolver/little_comet
	name = "\"Little Comet\" pistol"
	desc = "A special pistol developed to be as flashy and over priced as the businessmen that carry them. Uses .35 special rounds."
	icon = 'icons/obj/guns/projectile/little_comet.dmi'
	icon_state = "little_comet"
	item_state = "little_comet"
	drawChargeMeter = FALSE
	max_shells = 5
	caliber = CAL_PISTOL
	origin_tech = list(TECH_COMBAT = 10, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/pistol
	matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_WOOD = 6)
	price_tag = 10000
	damage_multiplier = 1.1 //because pistol round
	penetration_multiplier = 20
	pierce_multiplier =  5
	recoil_buildup = 50