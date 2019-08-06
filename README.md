# ADDON_NAME

Things to do for new addon:

- Create github repo (named ADDON_NAME CamelCase) and short description
- use newaddon.sh ADDON_NAME to copy initial files
- Create curseforge addon and setup source link and webhook for build from github using project id
- Create wowinterface addon upload zip created by curseforge
- update ~/installaddons.bat and ../MoLib/installmolib.bat

- Variables are: (must not have substring of one another as it's brute force search and replaced)
  - ADDON_NAME eg "PixelPerfectAlign"
  - ADDON_NS eg "PPA"
  - ADDON_TITLE eg "Pixel Perfect Align"
  - ADDON_UPPERCASE_NAME eg "PIXELPERFECTALIGN"
  - ADDON_SLASH eg "ppa"
  - ADDON_LONG_DESCRIPTION eg "Pixel Perfect Align Grid and Measuring tape"
