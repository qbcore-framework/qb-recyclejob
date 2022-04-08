fx_version 'cerulean'
game 'gta5'

description 'QB-RecycleJob'
version '2.1.0'

shared_script 'config.lua'

client_script {
  'client/main.lua',
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',
  '@PolyZone/CircleZone.lua'
}

server_script 'server/main.lua'

lua54 'yes'
