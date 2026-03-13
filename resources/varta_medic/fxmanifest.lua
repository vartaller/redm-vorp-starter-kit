fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
name 'varta_medic'
description 'NPC Doctor — heals players for money, no player-job required'
lua54 'yes'

shared_scripts { 'config.lua' }
client_script  'client/main.lua'
server_script  'server/main.lua'
