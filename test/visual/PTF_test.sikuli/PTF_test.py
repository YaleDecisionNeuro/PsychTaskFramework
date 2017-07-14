# What to look for:
def chooseLotto(event):
    sleep(0.5)
    type(Key.LEFT)
    print('Success!')

import ptf_lib
reload(ptf_lib)

ptf_lib.setupMatlabEnvironment('C:/Users/sp576/Documents/Coding/PsychTaskFramework')

# If runTest returned the region/event, it would be possible to determine if it was seen
# See end of post: https://sikulix.wordpress.com/2015/10/07/new-in-1-1-0-observe-revised-with-new-features/
ptf_lib.runTest('testRA_25', "RA_monetary_USD10_25.png", chooseLotto)
ptf_lib.runTest('testMDM_img', "MDM_amb50.png", chooseLotto)
ptf_lib.runTest('testRA_img', "RA_moneyimg_ambig24.png", chooseLotto)
