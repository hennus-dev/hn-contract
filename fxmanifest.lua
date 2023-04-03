fx_version 'cerulean'

game 'gta5'
version '1.1.1'

author 'Hennu`s - Hakos'
description 'transfer vehicles system'

version '1.1.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page "nui/index.html"

files {
    "nui/index.html",
    "nui/style.css",
    "nui/app.js",
    "nui/img/*.png"
}


lua54 'yes'