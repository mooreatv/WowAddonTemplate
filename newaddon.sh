#! /usr/bin/bash
# Setup a new addon source tree based on this template
# (c)2019 ALl rights reserved MooreaTv <moorea@ymail.com>
# (Note the path for bash above is what works with git bash on windows 10,
# might need to be changed to /bin/bash on some linuxes)

# ADDON_NAME eg "PixelPerfectAlign"
# ADDON_NS eg "PPA"
# ADDON_TITLE eg "Pixel Perfect Align"
# ADDON_UPPERCASE_NAME eg "PIXELPERFECTALIGN"
# ADDON_SLASH eg "ppa"
# ADDON_LONG_DESCRIPTION eg "Pixel Perfect Align Grid and Measuring tape"

#set -x

function help() {
  echo "$0 usage:"
  echo "$0  ADDON_NAME ADDON_NS ADDON_TITLE ADDON_UPPERCASE_NAME ADDON_SLASH ADDON_LONG_DESCRIPTION"
  echo "e.g  $0" 'PixelPerfectAlign PPA "Pixel Perfect Align" PIXELPERFECTALIGN ppa "Pixel Perfect Align Grid and Measuring tape"'
  exit 1
}

if [[ $# -ne 6 ]]; then
  help
fi

CMD="${@@Q}"

VARS="ADDON_NAME ADDON_NS ADDON_TITLE ADDON_UPPERCASE_NAME ADDON_SLASH ADDON_LONG_DESCRIPTION"

SED_EXPR=""
echo "About to run with"
for V in $VARS; do
  declare $V="$1"
  echo "$V=\"${!V}\""
  SED_EXPR="$SED_EXPR -e \"s|$V|${!V}|g\""
  shift
done

function doit() {
  echo "$0 $CMD" >> .addonHistory
  rm -r ../$ADDON_NAME
  mkdir ../$ADDON_NAME
  cp -r * ../$ADDON_NAME
  rm ../$ADDON_NAME/newaddon.sh
  mv -f ../$ADDON_NAME/ADDON_NAME ../$ADDON_NAME/$ADDON_NAME
  pushd ../$ADDON_NAME
  for fn in $(find . -type f); do
    echo "Working on $fn"
    newName=$(echo $fn | sed -e "s/ADDON_NAME/$ADDON_NAME/g")
    if [[ "$fn" != "$newName" ]]; then
      mv $fn $newName
      echo "renamed to $newName"
    fi
    eval sed -i $SED_EXPR "$newName"
  done
  popd
}

echo "sed expression $SED_EXPR"

doit

exit 0
