*** Settings ***
Resource    ./../../3-Settings/Settings.resource

*** Keywords ***
#TODO - Generalize
The user creates a data type with ${field} as ${value}
  Open class ${NEW_BUTTON} in ${RDTY_TOOLSTRIP}
  Input ${value} in name '${field}'
  Click on eventproxy ${RDTY_CREATE_BUTTON}

The user creates a record with ${field} as ${value}
  Go to tab 'Records'
  Open class ${NEW_BUTTON} in ${RDRC_TOOLSTRIP}
  Input ${value} in name "${field}"
  Click on eventproxy ${RDRC_CREATE_BUTTON}