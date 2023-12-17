*** Settings ***
Documentation       Insert the sales data for the week and export it as a PDF.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             OperatingSystem
Library    RPA.Desktop


*** Variables ***
${OUTPUT_DIR}       output\\receipts\\
${OUTPUT_SS}        output\\screen_shots\\
${OUTPUT_ZIPS}      output\\ZIps\\


*** Tasks ***
Insert the sales data for the week and export it as a PDF
    Open the intranet website
    Login
    Download the cvs file
    Navigate to the oradering page
    Order A Robot By Using The CVS File
    ZIP Archive PDF Files
    Logout


*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/
    Maximize Browser Window

Login
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:sales-form

Fill and submit the form
    Input Text    firstname    John
    Input Text    lastname    Smith
    Input Text    salesresult    123
    Select From List By Value    salestarget    10000
    Click Button    Submit

Download the cvs file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Order A Robot By Using The CVS File
    ${data}=    Read table from CSV    orders.csv
    FOR    ${data}    IN    @{data}
        Fill and submit the form for one person    ${data}
    END

Navigate to the oradering page
    @{nav_links}=    Get WebElements    class:nav-item
    Click Element    ${nav_links}[1]
    Click Element    class:alert-buttons

Fill and submit the form for one person
    [Arguments]    ${sales_reps}
    Select From List By Value    head    ${sales_reps}[Head]
    Click Element    xpath=//div[@class='radio form-check']//label//input[@id='id-body-${sales_reps}[Body]']
    Input Text    xpath=//form//div[@class='mb-3'][3]//input    ${sales_reps}[Legs]
    Input Text    xpath=//form//div[@class='mb-3'][4]//input    ${sales_reps}[Address]
    Wait And Click Button    xpath=//button[@id='order']
    ${div_visible}=    Run Keyword And Return Status
    ...    Element Should Be Visible
    ...    xpath=//div[@class='alert alert-danger']
    IF    ${div_visible}
        Run Keyword And Ignore Error    Scroll Element Into View    xpath=//button[@id='order']
        Wait And Click Button    xpath=//button[@id='order']
        ${rec_visible}=    Run Keyword And Return Status    Element Should Be Visible    id:receipt
        IF    not ${rec_visible}
            Wait And Click Button    xpath=//button[@id='order']
            ${rec2_visible}=    Run Keyword And Return Status    Element Should Be Visible    id:receipt
            IF    not ${rec2_visible}
                Wait And Click Button    xpath=//button[@id='order']
            END
        END
    END
    Wait Until Page Contains Element    id:receipt
    Wait Until Page Contains Element    robot-preview-image 
    Export As Pdf    ${sales_reps}[Order number]
    Click Button    id:order-another
    Click Element    class:alert-buttons
    Wait Until Page Contains Element    //form

Export As PDF
    [Arguments]    ${order_id}
    ${sales_results_html}=    RPA.Browser.Selenium.Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${order_id}.pdf
    Screenshot    id:robot-preview-image    ${OUTPUT_SS}${order_id}.png
    ${files}=    Create List
    ...    ${OUTPUT_SS}${order_id}.png
    Open Pdf    ${OUTPUT_DIR}${order_id}.pdf
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${order_id}.pdf
    Close All Pdfs

ZIP Archive PDF Files
    Archive Folder With Zip    ${OUTPUT_DIR}    Pdf.zip
Logout
    Click Button    logout