game 'rdr3'
fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

version '3.0.0'
author 'BLN Studio <bln-studio.com>'
description 'Develop RedM scripts in one codebase runs on multiple frameworks, easily.'

lua54 'yes'

ui_page('ui/index.html')

files {
	"ui/index.html",
	"ui/**/*",
}

shared_scripts {
	'core/config.lua',
	'core/main.lua',
	'modules/**/shared.lua'
}

client_scripts {
	'modules/**/**.c.lua',
	'modules/**/client.lua',
}

server_scripts {
	'core/v.lua',
	'core/vcheck.lua',
	'modules/framework/api/**/framework.lua',
	'modules/**/**.s.lua',
	'modules/**/server.lua',
}

escrow_ignore {
	'core/config.lua',
	'modules/framework/api/custom/framework.lua',
}

dependency '/assetpacks'