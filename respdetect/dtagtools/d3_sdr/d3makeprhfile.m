
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  info that needs to be adjusted for each tag deployment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %set paths
caldir = 'C:\Users\stacy\Documents\MATLAB\dtagtools\d3\cal'; %folder where your xml cal files are kept
prhdir = 'C:\dtag\data\prh'; 
settagpath('cal',caldir,'prh',prhdir) ;

% enter tag specific info
% recdir = 'F:\SoCal11\dtag\data\gg11\gg11_266a';
% prefix = 'gg266a';
% deploy_name = 'gg11_266a';

% recdir = 'F:\SoCal11\dtag\data\bw11\bw11_215b';
% prefix = 'bw215b';
% deploy_name = 'bw11_215b';
% DECL = 12.35;
% TAGLOC = [33.5815 , -117.943];
% TAGOFF_CST = 5146 ;
% whichd3 = 'd102';

recdir = 'F:\SoCal11\dtag\data\bw11\bw11_214c';
prefix = 'bw214c';
deploy_name = 'bw11_214c';
DECL = 12.61;
TAGLOC = [33.8569 , -118.4995 ];
TAGOFF_CST =  ;
whichd3 = 'd103';


% recdir = 'F:\SoCal11\dtag\data\gg11\gg11_265a';
% prefix = 'gg265a';
% deploy_name = 'gg11_265a';
% DECL = 12.54; %declination angle of tag location in DEGREES!
% TAGLOC = [33.4647 -118.6269];
% TAGOFF_cst = 23893.81; %time the tag fell off the whale
% whichd3 = 'd103';

% recdir = 'E:\SoCal12\dtag\data\bw12\bw12_217b';
% prefix = 'bw217b';
% deploy_name = 'bw12_217b';
% whichd3 = 'd102';

% recdir = 'E:\SoCal12\dtag\data\bp12\bp12_294a';
% prefix = 'bp294a';
% deploy_name = 'bp12_294a';


df = 20; %decimation factor for sensor data
FIELDSITE = 'SoCal';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  from here on, process should be similar for most tag deployments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load in tag sensor data from swv and xml files
X = d3readswv(recdir,prefix,df);

%register the deployment
CAL = d3deployment_old(recdir,prefix,deploy_name) ; %_old fills in cc.EXP if it's empty 
%[CAL,id] = d3findcal(whichd3) ;  % gets cal info for a tag by convenience name. use this line if the previous line does not work.

%pressure sensor
[p,CAL]=d3calpressure(X,CAL,'full');

%accelerometer
min_depth = 10; 
[A,CAL,fs] = d3calacc(X,CAL,'full',min_depth) ;

%magnetometer
[M,CAL] = d3calmag(X,CAL,'full',min_depth) ;

%save whale-frame results
d3savecal(deploy_name,'CAL',CAL)

%Produce the orientation table. 
TH = 10;
DIR = 'descent';
PRH = prhpredictor(p,A,fs,TH,2,DIR);	
OTAB = []; %make sure OTAB is in radians and seconds since start of tag recording!

%calculate Aw and Mw, acc and mag data in whale-frame instead of tag-frame
[Aw,Mw] = tag2whale(A,M,OTAB,fs);

%use tag2 tools to make pitch, roll, and head
[pitch roll] = a2pr(Aw) ;
[head vm incl] = m2h(Mw,pitch,roll) ;
head = head + DECL*pi/180 ;      % adjust heading for declination angle in RADIANS
%check that the inclination is correct for your site...check a map of mag
%field inclination if you don't know what it should be
180/pi*mean(incl)
%and that it's std is not too big, less than somewhere around 5 degrees
180/pi*std(incl)

%save whale-frame and other info in the xml cal file
d3savecal(deploy_name,'OTAB',OTAB)
d3savecal(deploy_name,'LOCATION',FIELDSITE)
d3savecal(deploy_name,'TAGON.POSITION',TAGLOC)
d3savecal(deploy_name,'DECL',DECL) %MJ suggests to save DECL in ***DEGREES*** not radians
%if you have other metadata you would like to save in the cal file, you can
%add more lines here.

%save tag2 style prh file
saveprh(deploy_name,'p','pitch','roll','head','fs','Aw','Mw','A','M') ;  


