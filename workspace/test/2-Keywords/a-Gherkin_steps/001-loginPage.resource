*** Settings ***
Resource    ./../../3-Settings/Settings.resource

*** Keywords ***

User accesses ${module} module
  User logs-in to SLIMS
  Navigate to ${module} module

User logs-in to SLIMS  
  Type username field with value ${USERNAME}
  Type password field with value ${PASSWORD}
  Click on value LOGIN
  Verify user is logged in as ${USERNAME}

Verify user is logged in as ${USERNAME}
  ${locator}=  getLocator ${SLIMS_USER_INFO} class username
  Get Text  ${locator}  ==  ${USERNAME}