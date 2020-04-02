--=============================================================
--= https://github.com/davuongthanh                           =
--=	https://www.youtube.com/channel/UC4f6N3gtOGqn2znOo7lxzQA  =
--= https://www.facebook.com/hida1995/                        =
--=============================================================
fx_version 'adamant'

game 'gta5'

description 'OD Horse'

version '1.0.0'

ui_page 'html/ui.html'

client_scripts {
    'config.lua',
	'client/main.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server/main.lua',
}


files {
	'html/ui.html',
	'html/css/style.css',
	'html/fonts/UVNBaiSau_R.ttf',
	'html/js/script.js',
	'html/img/button/buy.png',
    'html/img/button/buy_hover.png',
    
	--Animal
	'html/img/boar.png',
	'html/img/cow.png',
	'html/img/deer.png',
	'html/img/mtlion.png',
}