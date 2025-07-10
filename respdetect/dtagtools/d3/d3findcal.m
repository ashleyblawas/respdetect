function    [CAL,id,cname] = d3findcal(cname)
%
%    [CAL,id,cname] = d3findcal(cname,id)
%     Retrieve calibration information for a tag
%     Examples:
%     [CAL,id] = d3findcal('d401') ;  % gets cal info for a tag by convenience name
%     [CAL,id,cname] = d3findcal('1D032215') ; % gets cal info for a tag by ID code
%     [CAL,id,cname] = d3findcal(3842187796) ; % gets cal info for a tag by ID number
%
%     markjohnson@st-andrews.ac.uk
%     26 jan 2013

CAL = [] ; id = [] ;
if nargin == 0,
   help d3findcal
   cname = [] ; id = [] ;
   return
end

if ~isstr(cname),
   cname = hex2str(cname) ;
end

% see if there is an xml file on the path called cname
if exist([cname '.xml'],'file'),
   readmatxml([lower(cname) '.xml']) ;
   CAL = DEV.CAL ;
   if ~isfield(CAL,'SRC'),
      CAL.SRC.ID = DEV.ID ;
      CAL.SRC.NAME = DEV.NAME ;
   end
   id = DEV.ID ;
   cname = DEV.NAME ;
   return ;
end

if length(cname)~=8,
   cname = [] ;
   return
end

% otherwise, look for a cal file for the device in the caldir
% look on the matlab path for a path name containing 'd3' and 'cal'
pp = path ;
DEV = [] ;
cname = upper(cname) ;
while ~isempty(pp),
   [dirn,pp] = strtok(pp,';') ;
   if ~isempty(strfind(dirn,'d3')) && ~isempty(strfind(dirn,'cal')), 
      dd = dir([dirn '\*.xml']) ;
      for k=1:length(dd),
         try,
            [rx,vname]=xml2mat([dirn '\' dd(k).name]) ;
            if strcmp(vname,'DEV') && strcmp(upper(rx.ID),cname), %sdr added "upper()"
               DEV = rx ;
               break ;
            end   
         catch,
         end
      end
   end
end

if isempty(DEV),
   cname = [] ;
   return
end

cname = DEV.NAME ;
id = DEV.ID ;
CAL = DEV.CAL ;
CAL.SRC.ID = DEV.ID ;
CAL.SRC.NAME = DEV.NAME ;
