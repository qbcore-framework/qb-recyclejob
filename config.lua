Config = {
	-- **** IMPORTANT ****
	-- UseTarget should only be set to true when using qb-target
	UseTarget               = GetConvar('UseTarget', 'false') == 'true',

	OutsideLocation         = vector4(55.55, 6472.18, 31.43, 44.0),
	InsideLocation          = vector4(1073.0, -3102.49, -39.0, 266.61),
	DutyLocation            = vector4(1048.7, -3100.62, -38.2, 88.02),
	DropLocation            = vector4(1048.224, -3097.071, -38.999, 274.810),
	SellMaterials = true, --  allow players to sell materials to a ped 
	LimitedMaterials = true, -- limit the amount of materials that can be sold
	SellPed 				= vector4(1049.84, -3094.08, -40.0, 178.84),
	DrawPackageLocationBlip = true,

	PickupActionDuration    = math.random(4000, 6000),
	DeliveryActionDuration  = 5000,

	PickupLocations         = {
		{model = math.random(1,7), loc = vector4(1067.68, -3095.57, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1065.20, -3095.57, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1062.73, -3095.57, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1060.37, -3095.57, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1057.95, -3095.57, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1055.58, -3095.57, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1053.09, -3095.57, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1053.07, -3102.62, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1055.49, -3102.62, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1057.93, -3102.62, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1060.19, -3102.62, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1062.71, -3102.62, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1065.19, -3102.62, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1067.46, -3102.62, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1067.69, -3109.71, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1065.13, -3109.71, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1062.70, -3109.71, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1060.24, -3109.71, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1057.76, -3109.71, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1055.52, -3109.71, -39.9, 342.39),},
		{model = math.random(1,7), loc = vector4(1053.16, -3109.71, -39.9, 342.39),},
	},
	WarehouseObjects        = {
		[1] = 'prop_boxpile_05a',
		[2] = 'prop_boxpile_04a',
		[3] = 'prop_boxpile_06b',
		[4] = 'prop_boxpile_02c',
		[5] = 'prop_boxpile_02b',
		[6] = 'prop_boxpile_01a',
		[7] = 'prop_boxpile_08a',
	},
	PickupBoxModel          = 'prop_cs_cardbox_01',
}
