# What to look for:
def chooseLotto(event):
    sleep(0.5)
    type(Key.LEFT)
    print('Success!')

import ptf_lib
reload(ptf_lib)

ptf_lib.setupMatlabEnvironment('C:/Users/sp576/Documents/Coding/PsychTaskFramework')

ptf_lib.runTest('testRA_25', "RA_monetary_USD10_25.png", chooseLotto)
ptf_lib.runTest('testMDM_img', "MDM_amb50.png", chooseLotto)
ptf_lib.runTest('testRA_img', "RA_moneyimg_ambig24.png", chooseLotto)