function    K = findzc(x,TH,Tmax)
%
%    K = findzc(x,TH,Tmax)
%    EXPERIMENTAL - SUBJECT TO CHANGE!!
%    Find cues to each zero-crossing in vector x.
%    TH is the magnitude threshold for detecting a zero-crossing. 
%    Tmax is the (optional) maximum duration in samples between threshold 
%    crossings. 
%    To be accepted as a zero-crossing, the signal must pass from below 
%    -TH to above TH, or vice versa, in no more than Tmax samples.
%  
%    Output: K is a nx3 matrix [Ks,Kf,S], where Ks contains the cue of
%    the first threshold-crossing in samples, Kf contains the cue of the second
%    threshold-crossing in samples. S contains the sign of each zero-crossing
%    (1 = positive-going, -1 = negative-going).
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    last modified: January 2008
%    fixed a bug (failure to recognize some starting and ending
%    zero-crossings), 11 july 2011, mj

K = [] ;

if nargin<2,
   help findzc
   return
end

xtp = diff(x>TH) ;
xtn = diff(x<-TH) ;
kpl = find(xtp>0) ;  % leading edges of positive threshold crossings
kpt = find(xtp<0) ;  % trailing edges of positive threshold crossings
knl = find(xtn>0) ;  % leading edges of negative threshold crossings
knt = find(xtn<0) ;  % trailing edges of negative threshold crossings

K = zeros(length(kpl)+length(knl),3) ;
cnt = 0 ;
if min(kpl)<min(knl),
   SIGN = 1 ;
else
   SIGN = -1 ;
end

while 1,
   if SIGN==1,
      if isempty(kpl), break, end
      kk = max(find(knt<=kpl(1))) ;
      if ~isempty(kk),
         cnt = cnt+1 ;
         K(cnt,:) = [knt(kk),kpl(1),SIGN] ;
         knt = knt(kk+1:end) ;
         knl = knl(knl>kpl(1)) ;
         kpl = kpl(2:end) ;
      end
      SIGN = -1 ;

   else
      if isempty(knl), break, end
      kk = max(find(kpt<=knl(1))) ;
      if ~isempty(kk),
         cnt = cnt+1 ;
         K(cnt,:) = [kpt(kk),knl(1),SIGN] ;
         kpt = kpt(kk+1:end) ;
         kpl = kpl(kpl>knl(1)) ;
         knl = knl(2:end) ;
      end
      SIGN = 1 ;
   end
end
K = K(1:cnt,:) ;

if nargin==3,
   k = find(K(:,2)-K(:,1)<=Tmax) ;
   K = K(k,:) ;
end
