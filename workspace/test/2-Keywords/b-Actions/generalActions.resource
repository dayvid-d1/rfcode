*** Settings ***
Resource          ./../../3-Settings/Settings.resource

*** Keywords ***
Capture click ${locator}
    Wait For Elements State    ${locator}
    Take Screenshot
    Log to console   ${locator}
    Click    ${locator}
    Take Screenshot

Close Application
    Close Browser

Open Application
    New Browser    browser=${BROWSER}    headless=false

Setup Instance
    New Context    viewport={'width': 1920, 'height': 1080}    recordVideo={'dir':'${OUTPUT_DIR}/browser/video/','size':{'width': 1920, 'height': 1080}}
    New Page    ${URL}

Teardown Instance
    Close Page    page=CURRENT
    Delete All Cookies
    Close Context    context=CURRENT

On Error
    log to Console    "Testing Failed"
    #TODO - Generalize

Fill dropdown field ${field} with value ${value}
    Wait For Elements State    name=${field} >> //input
    Select options by    name=${field} >> //input    label    ${value}

Fill ${type} ${name} in ${parent} with ${value}
    ${locator}=    getLocator ${parent} ${type} ${name}
    Fill text    ${locator}    ${value}

Input ${value} in ${type} ${name}
    ${locator}=    getInputAttribute ${type} ${name}
    Fill text    ${locator}    ${value}

Type ${field} field with value ${value}
    ${locator}=    getAttribute name ${field}
    Fill text    ${locator}    ${value}

Click on ${type} ${button}
    ${locator}=    getAttribute ${type} ${button}
    Capture click ${locator}

Go to tab ${name}
    ${locator}=    getTabAttribute ${name}
    Capture click ${locator}

Open ${type} ${name} in ${parent}
    Take Screenshot
    ${locator}=    getLocator ${parent} ${type} ${name}
    Capture click ${locator}

Validate ${name} as ${type} in ${parent}
    Take Screenshot
    ${locator}=    getLocator ${parent} ${type} ${name}
    Wait For Elements State    ${locator}