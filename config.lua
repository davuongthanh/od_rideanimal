--=============================================================
--= https://github.com/davuongthanh                           =
--=	https://www.youtube.com/channel/UC4f6N3gtOGqn2znOo7lxzQA  =
--= https://www.facebook.com/hida1995/                        =
--=============================================================
Config = {}
Config.DrawDistance = 5.0
Config.ZoneSize     = {x = 1.0, y = 1.0, z = 0.5}
Config.MarkerColor  = {r = 255, g = 255, b = 255}
Config.MarkerType   = 27
Config.Locale = 'vn'

Config.Zones = {
	AnimalShop = {
		Pos = {x = 1580.72, y = 2178.88, z = 78.079 },
		Sprite = 463,
		Display = 4,
		Color = 27
	},
	
	AnimalSpawn = {
		Pos = {x = 1578.81, y = 2170.93, z = 79.14, h = 126.5 },
		Pos = {x = 1577.23, y = 2167.94, z = 79.19, h = 258.5 },
		Pos = {x = 1578.76, y = 2161.12, z = 79.42, h = 210.5 },
		Pos = {x = 1584.2, y = 2159.1, z = 79.59, h = 14.5 },
	},

}
Config.AnimalShop = {
	{
		name = 'boar',
		label = 'Heo rừng',
		price = 50
	},

	{
		name = 'cow',
		label = 'Bò sữa',
		price = 150
	},

	{
		name = 'deer',
		label = 'Nai',
		price = 250
	},

	{
		name = 'mtlion',
		label = 'Báo',
		price = 10000
	},
}