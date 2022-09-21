#!/usr/bin/env fish


set vscode_plugins \
    Equinusocio.vsc-material-theme \
    esbenp.prettier-vscode \
    jkjustjoshing.vscode-text-pastry \
    ms-azuretools.vscode-docker \
    ms-kubernetes-tools.vscode-kubernetes-tools \
    oderwat.indent-rainbow
    skyapps.fish-vscode \
    yzhang.markdown-all-in-one

for plugin in $vscode_plugins
    code --install-extension $plugin
end

rm ~/Library/Application\ Support/Code/User/settings.json
ln -sv (pwd)"/03_config/files/vscode_settings.json" ~/Library/Application\ Support/Code/User/settings.json
