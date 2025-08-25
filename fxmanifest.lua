fx_version 'cerulean'

lua54 'yes'
games { 'common' }

name 'frp_radialmenu'
version '1.0.0'

client_scripts {
	'@frp_lib/library/linker.lua',
    "@frp_lib/lib/i18n.lua",
    "locale/*.lua",

    "client/main.lua",
    "client/ox_radial.lua",
    "config/*.lua",
    "client/utils.lua",
}

ui_page 'web/build/index.html'
-- ui_page 'http://localhost:3000'

files {
    'web/build/index.html',
    'web/build/**/*',
}