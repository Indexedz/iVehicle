--[[ FOR MIRROR MODE ]]

fx_version "cerulean"
lua54 'yes'
game "gta5"

ui_page 'web/dist/index.html'

shared_scripts {
  "@Index/loaders/string.lua",
  '@Index/imports/main.lua',
  '@ox_lib/init.lua',
  'config.lua'
}

client_script "resources/**/client.lua"
server_script "resources/**/server.lua"

files {
  'web/dist/index.html',
  'web/dist/**/*',
  'data/*.lua',

  'modules/**/*.lua',
  'modules/**/*.json'
}
