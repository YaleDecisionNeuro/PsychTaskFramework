 *** Settings ***
Documentation     PsychTaskFramework correct display of lottery
Test Setup        Add Needed Images
Library           SikuliLibrary
Resource          ../lib.robot
Test template     Display Correct Lottery With

*** Variables ***
${IMAGE_DIR}      ${CURDIR}\\img

*** Test Cases ***
Correct Win Probability And Color
    testRA_25
Correct Medical Image Display
    testMDM_img
Correct Monetary Image Display
    testRA_img
    testSODM_mon_img
Correct Food Image Display
    testHLFF_HF_0

*** Keywords ***
Add Needed Images
    Add Image Path    ${IMAGE_DIR}
