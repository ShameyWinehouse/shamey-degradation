game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

client_scripts {
    '@redm-events/dataview.lua',
    '@redm-events/events.lua',
    'client.lua',
}

server_scripts {
    'server.lua'
}

shared_script {
    'config.lua',
    'shared.lua',
}

dependencies {
    'vorp_core',
    'vorp_inventory',
	'rainbow-core',
}


author 'Shamey Winehouse'
description 'License: GPL-3.0-only'