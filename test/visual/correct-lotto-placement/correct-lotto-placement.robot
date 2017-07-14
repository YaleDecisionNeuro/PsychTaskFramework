*** Settings ***
Documentation     PsychTaskFramework correct display of lottery
Test Setup        Add Needed Images
Library           SikuliLibrary
Resource          ../lib.robot

*** Variables ***
${IMAGE_DIR}      ${CURDIR}\\img

*** Test Cases ***
Display Correct Lottery
    Sleep  1s
    Focus Matlab Command Window
    Input Text  ${EMPTY}  testRA_25
    Press Special Key  ENTER
    Wait Until Screen Contain   RA_monetary_USD10_25.png  30
    Sleep  1s
    Press Special Key  LEFT
Display Medical Symbols
    Sleep  1s
    Focus Matlab Command Window
    Input Text  ${EMPTY}  testMDM_img
    Press Special Key  ENTER
    Wait Until Screen Contain   MDM_amb50.png  30
    Sleep  1s
    Press Special Key  LEFT
Display Cash Symbols
    Sleep  1s
    Focus Matlab Command Window
    Input Text  ${EMPTY}  testRA_img
    Press Special Key  ENTER
    Wait Until Screen Contain   RA_moneyimg_ambig24.png  30
    Sleep  1s
    Press Special Key  LEFT

*** Keywords ***
Add Needed Images
    Add Image Path    ${IMAGE_DIR}

# This is duplicated from ../__init__.txt and should be put in a resource file
# Focus Matlab Command Window
#     Add Image Path    ${MATLAB_IMAGE_DIR}
#     #Type With Modifiers  0  CTRL
#     Wait Until Screen Contain  matlab-command-window-symbol.png  30
#     Click  matlab-command-window-symbol.png
#     Sleep  1s
#     Press Special Key  ENTER
