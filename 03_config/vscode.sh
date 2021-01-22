#!/usr/bin/env fish

code --install-extension Equinusocio.vsc-material-theme
code --install-extension skyapps.fish-vscode

rm ~/Library/Application\ Support/Code/User/settings.json
ln -sv (pwd)"/03_config/files/vscode_settings.json" ~/Library/Application\ Support/Code/User/settings.json