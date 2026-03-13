game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

version '1.0.0'
author 'Munafio <munafio.com>'

client_scripts {
    'client.lua'
}

shared_scripts {
    'config.lua'
}

escrow_ignore {
	'config.lua',
}
dependency '/assetpacks'
dependency '/assetpacks'