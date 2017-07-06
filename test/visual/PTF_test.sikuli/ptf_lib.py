from sikuli import *

# Setup
# Focus existing Matlab window or open a new one
def focusMatlab():
    matlab = App('MATLAB')

    if not matlab.isRunning():
        matlab.open(60)

    matlab.focus()
    sleep(10)

def focusMatlabCommandWindow():
    type('0', Key.CTRL)
    sleep(3)

def setupMatlabEnvironment(ptf_root, wait = 3):
    focusMatlab()
    sleep(wait)
    focusMatlabCommandWindow()
    sleep(wait)

    type(Key.ENTER)
    type('cd ' + ptf_root + Key.ENTER)
    type("addpath('./test');" + Key.ENTER)

def runTest(matlab_test_name, image_file_path, handler, observe_time = 30):
    sleep(3)
    focusMatlab()
    focusMatlabCommandWindow()
    type(matlab_test_name + ';' + Key.ENTER)

    # Matlab / PTB will automatically project to largest screen ID -> check there
    with Region(Screen(getNumberScreens() - 1)):
        onAppear(image_file_path, handler)
        observe(observe_time)
