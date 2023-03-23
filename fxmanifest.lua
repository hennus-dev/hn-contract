fx_version 'cerulean'

version "0.1.0"

game 'gta5'

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