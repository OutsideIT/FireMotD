#!/bin/bash

show_colortest () {
    ColorMap=1; [[ (-n $1) && ($1 -eq 0) ]] && ColorMap=0
    echo -n -e "\n\e[1mYour terminal \e[4mdoes not\e[24m support 256 colors if:\e[0m\n"
    echo " * The Color Cube colors are the same as System Colors"
    echo " * Your gray scale ramp has only 3 variations"
    echo -n -e "\nSystem colors:\n"
    for code in {0..15}; do
        ds="  "
        if [[ $ColorMap -eq 0 ]]; then
            [[ $code -lt 10 ]] && ds=" $code  " || ds=" $code "
        fi
        echo -n -e "\e[48;05;${code}m${ds}"
        [[ ($code -eq 7) || ($code -eq 15) ]] && echo -n -e "\e[0m\n"
    done
    tcolor=255
    echo -n -e "\nColor cube, 6x6x6:\n"
    for green in {0..5}; do
        for red in {0..5}; do
            for blue in {0..5}; do
                color=$((16 + (red * 36) + (green * 6) + blue));
                ds="  "
                if [[ $ColorMap -eq 0 ]]; then
                    [[ $color -lt 100 ]] && ds="$color  " || ds="$color "
                fi
                echo -n -e "\e[38;05;${tcolor}m\e[48;05;${color}m${ds}"
            done
            echo -n -e "\e[0m "
        done
        echo -n -e "\e[0m\n"
        tcolor=0
    done
    tcolor=255
    echo -n -e "\nGrayscale ramp:\n"
    for gray in {232..255}; do
        [[ $gray -gt 245 ]] && tcolor=0
        ds="  "
        [[ $ColorMap -eq 0 ]] && ds=" $gray "
        echo -n -e "\e[38;05;${tcolor}m\e[48;05;${gray}m${ds}"
    done
    echo -e "\e[0;37m\e[0m\n"
}
