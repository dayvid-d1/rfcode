*** Settings ***
Resource    ./../3-Settings/Settings.resource

Suite Setup  Open Application
Suite Teardown  Close Application

*** Variables ***
#Reference Data
${NEW_BUTTON}  toolStripButton
${RDTY_TOOLSTRIP}  referenceDataTypeGrid
${RDTY_CREATE_BUTTON}  ReferenceData_createTypeForm_save
${RDTY_NEW_FORM}  AddNewRecordWindow
${RDTY_TABSTRIP}  ReferenceDataView
${RDRC_TOOLSTRIP}  referenceDataRecordGrid
${RDRC_CREATE_BUTTON}  ReferenceData_createRecordForm_save


*** Test Cases ***

$Scenario: User creates a Reference Data record 
  [Setup]  Setup Instance
  Given user accesses Reference Data module
  When the user creates a data type with rdty_name as AutomationTest
  And the user creates a record with rdrc_name as AutomationTestRecord
  [Teardown]  Teardown Instance