#!/usr/bin/env nu

def main [] {
    mut state = { "icon": "󰌸", "connected": false, "online": false }

    let id = (ip link | awk "/state UP/ {print $2}")
    if $id == "" {
        return $state
    }

    $state.icon = "󰪎"
    $state.connected = true

    if (get_online_status) {
        $state.icon = "󰖟"
        $state.online = true
    }

    $state | to json
}

def get_online_status [] {
    (get_online_status_for_url https://www.google.com) or (get_online_status_for_url https://www.microsoft.com)
}

def get_online_status_for_url [url: string] {
    try {
        return (http head --max-time 1sec $url | any {true})
    } catch {
        return false
    }
}
