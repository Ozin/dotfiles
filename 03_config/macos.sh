#!/usr/bin/env fish

# Inspired by:
#   - https://github.com/mathiasbynens/dotfiles/blob/main/.macos
#   - https://ryanmo.co/2017/01/05/setting-keyboard-shortcuts-from-terminal-in-macos/
#   - https://github.com/acourtneybrown/dotfiles/blob/main/script/macos

# Ask for the administrator password upfront
sudo -v

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "de" "en"
defaults write NSGlobalDomain AppleLocale -string "de_DE@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "Europe/Berlin" > /dev/null

# Stop iTunes from responding to the keyboard media keys
# Also stops media keys from working
# launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

# Clear keyboard shortcut for Shift-Cmd-A (Search man page in index in Terminal.app)
defaults write pbs.plist NSServicesStatus -dict-add "com.apple.Terminal - Search man Page Index in Terminal - searchManPages" '{
  "enabled_services_menu" = 0;
  "enabled_context_menu" = 0;
  "key_equivalent" = "";
  "presentation_modes" = {
    "ContextMenu" = 0;
    "ServicesMenu" = 0;
  };
}'