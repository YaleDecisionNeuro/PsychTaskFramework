% window dimesion open window
[Win.win Win.winrect] = Screen(0, 'OpenWindow',0); %[handel,window dimensin matrix]
HideCursor(Win.win); % Hide screen cursor

mondims = getTextDims(Win.win,'slight',18)

Screen('CloseAll') % Close screen and psychtoolbox


