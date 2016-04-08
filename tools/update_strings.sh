#!/bin/sh
set -e

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8


# check if Babelish exists
if ! gem spec "babelish" > /dev/null 2>&1; then
    echo "Installing babelish"
    sudo gem install babelish
fi

echo "Downloading strings spreadsheet .."
curl https://docs.google.com/spreadsheets/d/1dZ9BX_LPoblDrvd7WntmJLaJeV3u6uTJ0XLXWRtPo04/export\?format\=csv > tools/tmp_strings.csv

echo "Converting CSV to Localizable strings .."
babelish csv2strings --filename tools/tmp_strings.csv --output_dir tools --langs English:en

echo "Cleanup"
# uncomment after merge
# if [ -d "tools/en.lproj" ]; then
#     rm -r ../GemsCore/GemsCoreBundle/en.lproj
#     mv tools/en.lproj ../GemsCore/GemsCoreBundle/
#     rm tools/tmp_strings.csv
# fi