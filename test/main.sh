#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && source <(curl -s "https://raw.githubusercontent.com/nicholasadamou/Dotfile-Utilities/master/utils.sh")

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    # ' At first you're like "shellcheck is awesome" but then you're
    #   like "wtf[,] [why] are we still using bash[?]" '.
    #
    #  (from: https://twitter.com/astarasikov/status/568825996532707330)

    find \
        ../src \
        -type f \
        ! -path '../src/bin/*' \
        -exec shellcheck \
                -e SC1090 \
                -e SC1091 \
                -e SC2033 \
                -e SC2129 \
                -e SC2155 \
                -e SC2164 \
                -e SC2200 \
        {} +

    print_result $? "Run code through ShellCheck"

}

main
