*** Settings ***
Resource    ./../../3-Settings/Settings.resource

*** Keywords ***

getLocator2 ${parentType} ${parent} ${type} ${name}
  ${parentLocator}=  getAttribute ${parentType} ${parent}
  ${childLocator}=  getAttribute ${type} ${name}
  ${locator}=  Set Variable  ${parentLocator} >> //../.. >> ${childLocator}
  [Return]  ${locator}

getLocator ${parent} ${type} ${name}
  ${parentLocator}=  getAttribute eventproxy ${parent}
  ${childLocator}=  getAttribute ${type} ${name}
  ${locator}=  Set Variable  ${parentLocator} >> //../.. >> ${childLocator}
  [Return]  ${locator}

getAttribute ${type} ${name}
  ${locator}=  Set Variable  [${type}*=${name}]
  [Return]  ${locator}

getInputAttribute ${type} ${name}
  ${locator}=  Set Variable  xpath=(//input[@${type}=${name}])[2]
  [Return]  ${locator}

getTabAttribute ${name}
  ${locator}=  Set Variable  xpath=(//td[text()=${name}][contains(@class,'tabButton')]) 
  [Return]  ${locator}