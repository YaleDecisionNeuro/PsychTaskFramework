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
