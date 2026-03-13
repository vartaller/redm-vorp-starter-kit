fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

name        'vorp_bartenders'
description 'Bartender NPCs for all saloons — VORP Core'
version     '1.0.0'
author      'custom'

shared_scripts {
    'config/config.lua',
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}

dependencies {
    'vorp_core',
    'vorp_inventory',
}
