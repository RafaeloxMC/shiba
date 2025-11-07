#!/bin/sh
printf '\033c\033]0;%s\a' Shiba
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Shiba.arm64" "$@"
