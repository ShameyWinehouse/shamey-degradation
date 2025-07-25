Config = {}

Config.ShameyDebug = false

Config.Lassoes = {
	Plain = {
		Use = {
			IncrementAmount = 0.07,
		},
		Hogtie = {
			IncrementAmount = 1.00,
		},
		BreakThreshold = 0.99,
	},
	Reinforced = {
		Use = {
			IncrementAmount = 0.01,
		},
		Hogtie = {
			IncrementAmount = 0.05,
		},
		BreakThreshold = 0.99,
	},
	CheckInterval = 10 * 1000
}

Config.FishingRods = {
	Plain = {
		Use = {
			IncrementAmount = 0.005,
		},
		BreakThreshold = 0.99,
	},
}

Config.Torches = {
	Plain = {
		Use = {
			IncrementAmount = 0.00010,
		},
		BreakThreshold = 0.99,
	},
}

Config.Bows = {
	Plain = {
		Use = {
			IncrementAmount = 0.00020,
		},
		BreakThreshold = 0.99,
	},
	Improved = {
		Use = {
			IncrementAmount = 0.00010,
		},
		BreakThreshold = 0.99,
	},
}

Config.MeleeWeapons = {
	List = {
		`WEAPON_MELEE_KNIFE_TRADER`,
		`WEAPON_MELEE_KNIFE`,
		`WEAPON_MELEE_KNIFE_JAWBONE`,
		`WEAPON_MELEE_CLEAVER`,
		`WEAPON_MELEE_HATCHET`,
		`WEAPON_MELEE_HATCHET_HUNTER`,
		`WEAPON_MELEE_MACHETE`,
		`WEAPON_MELEE_MACHETE_COLLECTOR`,
	},
}