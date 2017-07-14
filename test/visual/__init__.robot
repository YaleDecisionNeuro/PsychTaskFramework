*** Settings ***
Documentation     PsychTaskFramework test suite set up
Suite Setup       Start Matlab
Suite Teardown    Stop Remote Server
Library           OperatingSystem
Library           SikuliLibrary
Resource          lib.robot

*** Variables ***
${MATLAB_IMAGE_DIR}      ${CURDIR}\\img

*** Keywords ***
Start Matlab
    Run  Matlab.exe
    Sleep   15s
    Focus Matlab Command Window
    # Input Text    ${EMPTY}  cd ${CURDIR}/..
    Input Text    ${EMPTY}  addpath(genpath('./test'))
    Press Special Key  ENTER

Focus Matlab Command Window
    Add Image Path    ${MATLAB_IMAGE_DIR}
    #Type With Modifiers  0  CTRL
    Wait Until Screen Contain  matlab-command-window-symbol.png  30
    Click  matlab-command-window-symbol.png
    Sleep  1s
    Press Special Key  ENTER
