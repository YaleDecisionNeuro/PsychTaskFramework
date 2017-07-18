*** Settings ***
Documentation     PsychTaskFramework test suite common keywords and variables
Library           OperatingSystem
Library           SikuliLibrary

*** Variables ***
${MATLAB_IMAGE_DIR}      ${CURDIR}\\img

*** Keywords ***
Focus Matlab Command Window
    Add Image Path    ${MATLAB_IMAGE_DIR}
    #Type With Modifiers  0  CTRL
    Wait Until Screen Contain  matlab-command-window-symbol.png  30
    Click  matlab-command-window-symbol.png
    Sleep  1s
    Press Special Key  ENTER

Display Correct Lottery With
    [Arguments]   ${matlab_test_name}
    Sleep   1s
    Focus Matlab Command Window
    Input Text   ${EMPTY}   ${matlab_test_name}
    Press Special Key   ENTER
    Wait Until Screen Contain   ${matlab_test_name}.png   15
    Sleep   1s
    Press Special Key   LEFT

Display Correct Lottery With Windows Legacy Renderer
    [Documentation]   Compare instead to the references that use the Windows 
    ...               legacy render rather than the cross-platform PTB render
    [Arguments]   ${matlab_test_name}
    Sleep   1s
    Focus Matlab Command Window
    Input Text   ${EMPTY}   ${matlab_test_name}
    Press Special Key   ENTER
    Wait Until Screen Contain   win_${matlab_test_name}.png   15
    Sleep   1s
    Press Special Key   LEFT