/obj/item/weapon/gun/projectile/revolver/deckard
	name = "\"Deckard\" magnum"
	desc = "A rare, custom-built revolver formerly used on Earth by early Turing Police, less than 100 examples exist in this side of the galaxy. Use when there is no time for the Voight-Kampff test. Uses .50 Kurtz."
	icon = 'icons/obj/guns/projectile/deckard.dmi'
	icon_state = "deckard"
	caliber = CAL_50
	origin_tech = list(TECH_COMBAT = 3, TECH_MATERIAL = 3)
	max_shells = 5
	matter = list(MATERIAL_PLASTEEL = 12, MATERIAL_WOOD = 6)
	price_tag = 3100 //one of most robust revolvers here
	damage_multiplier = 1.35
	penetration_multiplier = 1.65
	recoil_buildup = 30
	one_hand_penalty = 25
	fire_sound = 'sound/weapons/guns/fire/deckard_fire.ogg'

/obj/item/weapon/gun/projectile/revolver/deckard/key
	name = "\"Repli-cant\" magnum"
	desc = "Another rare magnum like Deckard's gun from the same collection. What's it like to hold the hand of someone you love? Interlinked. Uses .40 Magnum rounds."
	icon = 'icons/obj/guns/projectile/blaster_key.dmi'
	icon_state = "key_magnum"
	origin_tech = list(TECH_COMBAT = 4, TECH_MATERIAL = 2)
	handle_casings = CYCLE_CASINGS
	max_shells = 10
	ammo_type = /obj/item/ammo_casing/magnum
	fire_sound = 'sound/weapons/guns/fire/magnum_key.ogg'
	matter = list(MATERIAL_PLASTEEL = 15, MATERIAL_PLASTIC = 6)
	price_tag = 3200
	damage_multiplier = 1.5
	penetration_multiplier = 1.5
	recoil_buildup = 10
	one_hand_penalty = 20
	firemodes = list(
		list(mode_name="fire one barrel at a time", burst=1, icon="semi"),
		list(mode_name="fire both barrels at once", burst=2, icon="burst"),
		)