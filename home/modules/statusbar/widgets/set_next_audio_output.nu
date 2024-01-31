#!/usr/bin/env nu

def main [] {
    let status = (wpctl status | lines)

    mut sinks = []
    mut is_audio = false
    mut is_source = false

    for line in $status {
        if $line == 'Audio' {
            $is_audio = true
        } else if $is_audio and ($line | str contains 'Sinks:') {
            $is_source = true
        } else if $is_source and ($line | str contains '[vol:') {
            $sinks = ($sinks | append $line)
        } else if $is_audio {
            $is_source = false
        } else if $line == 'Video' {
            break
        }
    }

    mut result = []
    for sink in $sinks {
        let split_index = ($sink | str index-of '.')
        let id_part = ($sink | str substring 0..$split_index)

        let is_active = ($id_part | str contains '*')
        let id = ($id_part | split row ' ' | last)

        $result = ($result | append { 'active': $is_active, 'id': $id })
    }

    if ($result | last).active {
        (wpctl set-default ($result | first).id)
    } else {
        let id = ($result
        | skip until {|sink| $sink.active }
        | skip 1
        | first).id

        (wpctl set-default $id)
    }
}
