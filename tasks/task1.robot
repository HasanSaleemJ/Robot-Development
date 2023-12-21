*** Settings ***
Documentation       Inhuman Insurance, Inc. Artificial Intelligence System robot.
...                 Produces traffic data work items.

Library             RPA.HTTP
Library             RPA.JSON
Library             RPA.Tables
Library             Collections
Library    RPA.Robocorp.WorkItems


*** Variables ***
${TRAFFIC_JSON_FILE_PATH}=      ${OUTPUT_DIR}${/}traffic.json
${TRAFFIC_JSON_CVS_PATH}=       ${OUTPUT_DIR}${/}test.csv
# JSON data keys:
${COUNTRY_KEY}=                 SpatialDim
${GENDER_KEY}=                  Dim1
${RATE_KEY}=                    NumericValue
${YEAR_KEY}=                    TimeDim


*** Tasks ***
Produces traffic data work items
    Download Traffic data
    ${traffic_data}=    Load Traffic Data as Table
    ${filtered_data}=    Filter and sort traffic data    ${traffic_data}
    ${filtered_data}=    Get latest data by country    ${traffic_data}
    ${payloads}=    Create work item payload    ${filtered_data}
    Save working items payload    ${payloads}

*** Keywords ***
Download Traffic data
    Download
    ...    https://github.com/robocorp/inhuman-insurance-inc/raw/main/RS_198.json
    ...    ${OUTPUT_DIR}${/}traffic.json
    ...    overwrite=${True}

Load Traffic Data as Table
    ${json}=    Load JSON from file    ${TRAFFIC_JSON_FILE_PATH}
    ${table}=    Create Table    ${json}[value]
    RETURN    ${table}

Filter and sort traffic data
    [Arguments]    ${table}
    ${max_rate}=    Set Variable    ${5.0}
    ${both_genders}=    Set Variable    BTSX
    Filter Table By Column    ${table}    ${RATE_KEY}    <    ${max_rate}
    Filter Table By Column    ${table}    ${GENDER_KEY}    ==    ${both_genders}
    Sort Table By Column    ${table}    ${YEAR_KEY}    False
    RETURN    ${table}

Get latest data by country
    [Arguments]    ${table}
    ${table}=    Group Table By Column    ${table}    ${COUNTRY_KEY}
    ${latest_data_by_country}=    Create List
    FOR    ${group}    IN    @{table}
        ${first_row}=    Pop Table Row    ${group}
        Append To List    ${latest_data_by_country}    ${first_row}
    END
    RETURN    ${latest_data_by_country}

Create work item payload
    [Arguments]    ${traffic_data}
    ${payloads}=    Create List
    FOR    ${row}    IN    @{traffic_data}
        ${payload}=    Create Dictionary
        ...    country=${row}[${COUNTRY_KEY}]
        ...    years=${row}[${YEAR_KEY}]
        ...    rate=${row}[${RATE_KEY}]
        Append To List    ${payloads}    ${payload}
    END
    RETURN    ${payloads}


Save working items payload
    [Arguments]    ${payloads}
    ${Variables}=    Create Dictionary    traffic_data=${payloads}
    Create Output Work Item    variables=${Variables}    save=True
    

