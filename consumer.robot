*** Settings ***
Documentation       Inhuman Insurance, Inc. Artificial Intelligence System robot.
...                 Consumes traffic data work items.

Library    RPA.Robocorp.WorkItems


*** Variables ***
${WORK_ITEM_NAME}=      traffic_data

*** Keywords ***
Process traffic data
    ${payload}=    Get Work Item Payload
    ${traffic_data}=    Set Variable    ${payload}[${WORK_ITEM_NAME}]

*** Tasks ***
Consumes traffic data work items
    For Each Input Work Item    Process traffic data
