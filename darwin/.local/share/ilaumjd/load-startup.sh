#!/bin/sh

plist=~/Library/LaunchAgents/local.startup.plist
launchctl unload "$plist" 2>/dev/null || true
launchctl load -w "$plist"
