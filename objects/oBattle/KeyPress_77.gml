Menu(x-110, y-20, [
	["Fight", -1, -1, true],
	["Magic", SubMenu, 
		[
			[
				["Ice", -1, -1, true],
				["Back", MenuGoBack, -1, true]
			]
		], true
	],
	["Test1", -1, -1, true],
	["Test2", -1, -1, true],
	["Test3", -1, -1, true],
	["Escape", -1, -1, true]
], -1, undefined, 60)