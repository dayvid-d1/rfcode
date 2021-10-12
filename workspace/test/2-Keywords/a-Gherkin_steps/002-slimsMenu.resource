*** Settings ***
Resource    ./../../3-Settings/Settings.resource

*** Keywords ***
Navigate to ${module} module
  Open class ${SLIMS_MENU} in ${SLIMS_MAIN_MENU}
  Fill name ${SLIMS_SEARCH} in ${SLIMS_PANEL} with ${module}
  Open title '${module}' in ${SLIMS_PANEL}
  Validate '${module}' as class in ${SLIMS_CANVAS}