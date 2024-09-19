%% FUNCTION: loadaudit

function    R=loadaudit(tag, metadata)
%
%    R=loadaudit(tag)
%     read an audit text file with name fname into an audit structure.
%     The text file must contain lines of the form:
%        cue duration type
%     Comments preceded by the symbol % will also be read in
%     Output:
%        R is a structure containing all of the audit cues, stypes and
%        comments.
%        Use findaudit, showaudit, tagaudit and saveaudit to handle R.
%     
%     Note: although it is possible to edit the audit file using a text
%     editor, the best way to visualize and edit the audit is using tagaudit.
%
%     Extras for experts:
%        R.cue is a nx2 matrix of [cue duration] in seconds since tag on
%        R.stype is a cell array of type strings matching each row of R.cue
%        R.comment is a cell array of comments
%        R.commentcue is a vector of indices in R.cue for the notes
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: March 2005
%     added note preservation

%R.cue = datetime("2023-01-01 00:00:00.00", 'Format', 'yyyy-MM-dd HH:mm:ss.SS'); % Cue needs to be initialized as a datetime array

if strcmp(metadata.tag_ver, "CATS") == 1
    R.cue = datetime([],[],[], 'Format', 'yyyy-MM-dd HH:mm:ss.SS');
else
    R.cue = [];
end
R.stype = [] ;
R.comment = [] ;
R.commentcue = [] ;

if nargin<1,
   help loadaudit
   return
end

% try to make filename
global TAG_PATHS
%if ~isempty(TAG_PATHS) & isfield(TAG_PATHS,'AUDIT'),
   %fname = sprintf('%s\\%s.txt',TAG_PATHS.AUDIT,tag) ;
%else
   fname = sprintf('%s.txt',tag) ;
%end

% check if the file exists
if ~exist(fname,'file'),
   fprintf(' Unable to find audit file %s - check directory and settagpath\n',fname) ;
   return
end

f = fopen(fname,'rt') ;
done = 0 ;

while ~done,
   s = fgetl(f) ;
   if s==-1,
      return
   end

   k = min(find(s == '%')) ;
   if ~isempty(k),
      note = s(k:end) ;
      if k==1,
         s = [] ;
      else
         s = s(1:k-1) ;
      end
   else
      note = [] ;
   end

   if ~isempty(s),    
       if strcmp(metadata.tag_ver, "CATS") == 1
           d = datetime(s, 'Format',  'yyyy/MM/dd HH:mm:ss.SSS'); % Get date of first line
           if all(~isnat([d d])),
               knext = size(R.cue,1)+1 ;
               R.cue(knext,1) = d;
               R.stype{knext} = [t] ;  % strip leading white space from remainder
           end
           if contains(s, 'b')
               [cs s] = strtok(s) ;
               c = str2double(cs) ;
               [ds t] = strtok(s) ;
               s = strcat(cs, " ", ds);
               t = regexprep(t, '\t', '');
           else
               t = "";
           end
       else
           [cs s] = strtok(s) ;
           c = str2double(cs) ;
           [ds s] = strtok(s) ;
           %d = str2double(ds) ;
           if all(~isnan(c)),
               knext = size(R.cue,1)+1 ;
               R.cue(knext,:) = c ;
               %[ss s] = strtok(s) ;
               R.stype{knext} = [ds] ;  % strip leading white space from remainder
           end
       end  
   end

   if ~isempty(note),
      knote = size(R.commentcue,1)+1 ;
      R.comment{knote} = note ;
      R.commentcue(knote,:) = size(R.cue,1) ;
   end
end

fclose(f) ;

end

