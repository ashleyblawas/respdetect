%dtag3 class notes
first round of dtag3 built will NOT have GPS, but hopefully later generations will.
entire tag is now potted in urethane - not really possible to open the unit to make repairs.
one battery controls both the vhf and the tag.
release wires are now just a little cap that is much easier - off with a pair of tweezer, push on.
suction cups are not held in by any pins, etc - just install from bottom of tag and push in
talking to tag is now via usb interface (connector on belly side of the tag).
all charging is done via the usb.
there can be some issues with the terminals corroding - poss solutions are to very carefully clean it, or to solder 
over the pads and periodically replace the solder.
tag controls vhf radio - when it sends signal (eg just at surface) and speed and ping duration.
pulse rate slow and fast - 1.5, 2.5 seconds (1/10 sec during vhf on demand mode)
battery life time is about 48 hours 
high and low gain - 
talking to tag - use program d3host.exe
    battery voltage ~4.2 fully charged - probably OK to deploy if >~3.7.  If will never charge >3.9-4, then battery is probably going bad.
    (will only happen, generally, after 1000s of deployment cycles.)
    1. get directory - read memory of the tag. (file #, start time, end time, size.  time is ALWAYS UTC). 
    also gives free space in memory. 686mb is max file size
    2. offload files - select the file numbers  you want and they will be offloaded to the directory set in 5. set data directory.  
    default is in d3 zone.  there is a time clock that will show you how long it will take to offload.  Nominal rate is 
    3GB/hour (= full tag  - about 10 hours). if there is an error in the middle of an offload, can restart with a specific dtg file.  
    Can not start offload, etc in the middle of a dtg - always need to offload complete files.
    6. expert mode - gives more options, including board time set and read.  the tag sets itself to whatever your computer is set to
    (only the UTC version).  also can retrieve the name of the current firmware file (in case of trouble with programming of tag.  
    c. configure - set up the tag for a deployment. 
        salinity trigger is in % -- 0 will start recording as soon as tag is armed.  30 is a good standard for most areas 
        (may want to consider lower value for fresher water or higher in an area with lots of salt in the air).
        release by & release after - whichever one is FIRST will be the one that triggers release.
        for release by - if you enter a single number, it's seconds, two, hours and seconds, etc.
        release duration: how long the release "burns"  once burning has begun.  don't make it TOO long - it will use up the battery, which will decrease VHF run time.  one hour may be a good default.
        note: if in cold, fresh water ,will want to test how long it takes to burn a release. to be conservative may want to use 2-3 hours.  
        PTM found it to take about 30 min in cold water in greenland.  SDR tested in AK and it was about 40-60 min.
        VHF on demand: on = at pressure_surface - pings at about one time per 0.8 seconds; turns off at deeper depths.
        VHF pulse length: short = 25 msec; long = undetectably longer.
        VHF pulse rate - every 1.5 seconds (fast) or every 2.5 seconds (slow). This is what the tag will do once it's off and floating.  
        PROBABLY the VHF can continue for on the order of months after tag is done recording, but HAS NOT been tested yet.
        at 120 kHz, writes 0.3 gb per hour (doubles with doubling audio sampling rate).
        no magnet needed to turn vhf off:  if you disconnect from tag without arming, then tag will turn off vhf.
        ARMED TAGS will have their VHF on and there is no way to turn them off w/o disarming - watch out for interference if you are on a vessel with an armed tag and are trying to listen for another tag.
        low gain is 18.4 dB , high gain is 30.2 dB in the electronics.  -> hphone sens ~ 187 and 175 (not cal yet). 
        there is potential to adjust this gain with a custom tag. 

The tag shuts itself off when its battery reaches 3.3V.

tag3 has a hardware anti-aliasing filter; first batch of tag3 has an 80 kHz anti-aliasing filter. (this may change in future for higher f tags)
    
d3read.exe automatically uses the offload directory specified in d3host.exe - don't have to copy the executable to the data directory.

lights on the tag: 
    recharge. orange - on when charging (i.e. connected to usb).  off when done charging. 
    host. green - on when plugged in to usb 
    status. red. this one and host one flash every 10 sec to show it is recording. (good for bench testing - in future versions will not do this anymore).
    msp (labeled on tag). 3 flashes when waiting for trigger. 5 fast flashes when triggered.

tag stops recording when plugged in to USB, but remains ARMED.  need to talk to it, disarm, reset release times, check battery, rearm and then redeploy if desired.
if you unplug and then plug in again a second time, tag goes into host mode and you can talk to it.
    
****there is a 10 second "mute" at the start of every recording and about once an hour - this is a way to measure tag system/electrical noise.

to "calibrate" hydrophones (to check them in comparison to one another) you can use a pistonphone (part of the reason why they are "sticking out").

dtag3 is set up on 3V system - everything is +/- 3V with virtual ground

GPS, gyroscope, and ECG sensors will hopefully be added soon.  They gyroscope needs to be placed inside its own little pressure housing before it will work.

sensor data sampling rates (after Sarasota) will be:  mag: 100; acc 200; pressure 200; channels 11-20 20 HZ !!!

can use rubber gloves instead of shower caps to protect cups.

220 mhz instead of 148 (like dtag2) for VHF tracking! allows having a 10" antenna (shorter)

no longer need to demag before each deployment.  may be a good idea to do it at the start of a cruise and maybe 1-2x during the project,
but not absolutely required.

on tag 3, the antenna is a GROUND (can use this during release voltage test, etc.)

on tag3, since the vhf is on the main tag circuit, you can detect the vhf pings in the audio record (prob another reason to use VHF on demand!)
_______________________________________________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Pre-Deployment Protocol

1. Make sure tag is clean - if not, rinse with fresh water, then wash with mild detergent, then rinse well with fresh water, 
rinse SUCTION CUPS ONLY with alcohol (alcohol can degrade the urethane the tag is potted in), and finallly with DI water.  
Keep cups clean and protected with a shower cap, glove, or plastic bag.  May want to use a cotton swab or a toothbrush for 
alcohol on the inside of the cups.  Also clean the shower cap, etc. Alcohol should ideally be 99% isopropyl or ethanol.  
Let tag air dry after all washing is done.

2. Make visual check of the tag - make sure release is good, tubes are crimped, there are no holes in housing, all cups 
are present and appear undamaged, LEDs not flashing, everything looks normal.

3. Prepare tag for deployment. [NOTE : Need to make pre-deployment checklist for dtag3]
    a. Plug in to USB.
    b. Check battery voltage.  Should be >4 (4.2 is completely charged).
    c. Make sure that tag memory is cleared: erase all files, recheck memory and make sure about 32 GB are free.
       [if 32 GB are not free but all files have been erased, try rebooting the tag (unplug, replug).
    d. Check which firmware you are running and note the version AND date.
    e. Do a release test.  You need to set release after time to 1 min and release burn time of about 10 sec.,
    and then check voltage on the little release loops after 1 min - there is no "rtest" function in the tag code.  
    Correct voltage through release wire should match battery voltage.  
    At the same time, could do a tap test on the hphones.  Can also look at the "bridge" and "pressure" values 
    for a tag sitting still, and acc/mag for a tag you pitch/roll around in the air, to make sure the ones that
    should be constant are constant and those that change should change.  Tom Hurst has a list of the values 
    that each of these sensors should have "on the bench".
    f. set VHF settings and test VHF signal.  IF tag is armed, VHF will ping continuously until trigger, 
    then go in on demand mode if so selected.
    g. set audio settings, gain, and release time, and burn time settings. Note all settings.
    h. arm tag and make sure you get the message "arming tag....done".  Unplug it from the USB.
    Red light should flash periodically if the tag is armed and waiting to trigger.
    i. make sure that VHF can be tracked from mother ship when tag boat is a km or so away.
    
4. Deploy and Recover Tag!
5. Download data from tag.
    a. Plug tag in to USB communication cable (do it twice - first time shuts down tag, second puts in host mode).  
    Should have a green host light and orange charge light.
    If you get a tag back and it is not waking up, use special "tag shut down" harness to turn it off, then connect 
    it to the regular USB.  If that doesn't work, you may want to restart and/or try a different USB port.  
    If all else fails, may check cables or try a different cable.
    b. Select option 1 from d3host.exe to see which files are on the tag.
    c. Select option 2 from d3host.exe menu to offload files (may want to first use 5. Set data directory).
        i. select files you would like to download from the list or a for all or x for none
        ii. enter a filename base (e.g. 'tt123a' - note that it does NOT include the 'yy_'). The program will download the dtg files.
    d. Use d3read.exe to unpack the .dtg files into .wav and .swv files.  IT will ask for a filename base - if left blank, 
    the program will show all the files in the directory.  If you enter a base, it will show all files with that base.
    e. Check quality & size of .swv and .wav files using audition, audacity, matlab, etc. for wav files and matlab for swv files.
    [note to self: need to make a "checkswv.m" file to make some plots automatically.]
    f. Make multiple copies of the data (=dtg files) - generally on 2-3 hard drives and/or sets of CDs or DVDs.
    g. Erase tag.
6. Process Data set as desired.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
Zlex
WHOI keeps a copy of all dtag data (must provide at the end of each project).
To get started - must have funding or a proposal in progress - WHOI will be involved in grant process. tags are not "for sale."
Planning Stages
    if WHOI project, they will take care of logistics and planning and packing.
    larger whales need larger tag boat and longer carbon fiber tag pole (this costs $5000-7000, can get specs or borrow a pole from WHOI).
    Can be taken apart to ship - airline allowed.
    smaller animals can use smaller pole.
    BOATS:  liability, insurance (liability up to 1 million $), boat inspected, driver with captain's license, first aid training,
    and enrolled in drug & alcohol test...(WHOI & UNOLS requirements)
    for beaked whales - small tag boat w/4stroke engine or elec engine (low noise) and is very maneuverable at low speeds;
    don't change speed or shift gear once you are engaged with a group of beaked whales.
    WHOI has one large and two small tag boats; 3-4 motors; you pay for maintenance, gas, and any damage to boat.
    Be sure to get lots of infor about tides, currents, weather, wind patterns; ideally have some knowledge with professional people in
    the area like fishermen, coast guard, etc.      Where are the ports?  Where are tall places to go for land based radio tracking 
    (can get up to 50 miles radio tracking range if on mountain)? 
    Are there any small planes available for radio tracking for lost tags ?
    Bring tag lab contact info (TOM & ZLEX) and stay in touch if there are any problems (e.g. tag is acting weird, or tag is lost).
    Be sure you have proper permits - IACUC (institution-specific) + NOAA/NMFS tagging permit (takes more than a year to get!  
    generally limited to a specific area and time frame.  keep a copy of the permit with you in the field.)
DTAG3 RADIO TRACKING
    freq is 218 MHz
    Antenna is a 4-element yagi (mount on highest part of boat away from other transmitters and antennae if possible).
    Antenna cables feed into display box (DFORTON).  Has a USB cable that can connect to a computer and allow plotting of tracking signal.
    coax in the middle of the back goes to the r1000 receiver (ONLY R1000 can do both dtag2 and 3 freqs)
    In Norway - blue is +.
    remember to turn gain down as tag gets closer.  can also increase freq a little when tag is close, and decrease a little when tag is v far away.
    as you approach the tag, best technique is to keep going until you pass the tag and each time you pass it, make spiralling boxes around the tag.
    if you are getting detections but are not sure they are really tags, shift freq up and down - if still there, the "signal" is interference.
    Handheld antennae: for a lost tag, the best tool is a handheld yagi with an R1000, deployed at the highest possible point.
    May want to clean the BNC cable connectors with electrical cleaner. 
    3 crossbars of the yagi should be PERPENDICULAR to the water.
    Powerful flashlight will help find tag in the dark - very strong reflection from copper on the tag/vhf area.
    Use rechargeable batteries in the R1000 and then you can use it with a plug-in charger.
    At start of tagging attempt, check that mother ship is getting signal from the tag on VHF receivers.
Other notes:
Try to take photos and make notes of any tag orientations and tag movements.
Make sure to file a float plan with your shore crew and the coast guard if you are in a shore based project.  
If possible bring a VHF, sat phone, phone epirb, epirb, etc.


        