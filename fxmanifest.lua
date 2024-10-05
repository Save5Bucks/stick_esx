fx_version 'cerulean'
game 'gta5'

author 'Save5Bucks'
description 'Manual Transmission Script using ESX'
version '1.0.2'

-- Client scripts
client_scripts {
    'config.lua',
    'client.lua'
}

-- Server scripts (if needed in the future)
server_scripts {
    '@mysql-async/lib/MySQL.lua', -- MySQL library change this for whichever resource you use
    'server.lua'
}

-- NUI Files (HTML, CSS, JS)
ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/style.css',
    'html/script.js'
}

-- Dependencies
dependencies {
    'es_extended'
}

lua54 'yes'
