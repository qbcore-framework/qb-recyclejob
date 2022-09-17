fx_version 'cerulean'
game 'gta5'

description 'QB-RecycleJob'
version '2.1.0'

shared_scripts {
  'config.lua',
  '@qb-core/shared/locale.lua',
  'locales/en.lua', -- Change to the language you want
}

client_script {
  'client/main.lua',
  '@PolyZone/client.lua',
  '@PolyZone/BoxZone.lua',
  '@PolyZone/CircleZone.lua'
}

server_script 'server/main.lua'

lua54 'yes'
