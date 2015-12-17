;+
;----------------------------
;   NAME
;----------------------------
; medianizedata.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure 'medianizing' data
; To 'medianize' a set of datapoints in principle means to take N points
; arround the data point of interest, calculating the mean of these points
; and assigning this value as a new medianized value of the datapoint of
; interest. Doing this for all the points gives you a new medianized set
; of data which you can then compare with the original one. Such a comparison
; is effectient to detect outliers in the original data, for instance by
; calculating delta y = y_i,original - y_i,medianized
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; xval      : vector containing the x-components of the data set
; yval      : vector containing the y-components of the data set
; N         : the number of points on each side of the x value to medianize
;             over - Illustrated below for the (*)-point with N=2. The
;             first(last) N points are medianized over the N points right(left)
;             of them, i.e, for N=2 point 1 and 2 are only medianized over
;             points 2,3 and 3,4 respectively. Choosing N to be an odd number
;             is prefereable in the median case, since then the median is unique
;             for the N first and last points, whereas if N is even there
;             are two medians. In this case the IDL median routine (used here)
;             returns the mean of the two median values (when EVEN keyword set)
;                y ^
;                  |             :       * :  *
;                  |             :*   (*)  :
;                  |         *   :   *    *:
;                  |       *   * :         :
;                  |    *  *     :         :
;                  |  *(x1,y1)   :___N=2___:  
;                  -----------------------------------> x
; mVSm      : needs the string 'mean' or 'median' to indicate whether you
;             want to use the mean or median when medianizing. Using the mean
;             is more accurate but if you have outliers the result is biased,
;             whereas taking the median ignores outliers. 
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
;
;----------------------------
;   OUTPUTS:
;----------------------------
; ymed      : vector with the new medianized y-coordinates
; deltay    : the difference between the original and medianized values
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; IDL>
;----------------------------
;   BUGS
;----------------------------
;
;----------------------------
;   REVISION HISTORY
;----------------------------
; 2009-01-15  started by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
PRO medianizedata, xval,yval,N,mVSm,ymed,deltay

sizex = size(xval)                ; determining data size
npx = sizex(1)                    ; the number of entries in xval
sizey = size(yval)                ; determining data size
npy = sizey(1)                    ; the number of entries in xval
;------------------
;--error messaging bad input--
if (N eq 0) then print,':: medianizedata.pro :: ERROR: have chosen to medianize over 0 neighbor points. Please choose N != 0'
if (npx ne npy) then  begin 
   print,':: medianizedata.pro :: ERROR: input vectors do not have the same size!' 
   goto, lastline
endif
;------------------
;--error message if size of arrays are less than 2N+1--
if (npy lt 2*N+1) then begin
   print,':: medianizedata.pro :: ERROR: Size of input arrays are less than the'
   print,'                               # points medianized over: size < 2N+1'
   print,'                               input array dimension = ',strtrim(npy,1)
   print,'                               2*N+1                 = ',strtrim(2*N+1,1)
   print,'                               therefore output set to 2 vectors containing 10 entries with value -9000'
   ymed = fltarr(10)
   deltay = fltarr(10)
   for i=0,9 do begin
      ymed(i) = -9000
      deltay(i) = -9000
   endfor
   goto, lastline
endif

;------------------
; the final result array of medianized y-values to be filled
ymed = fltarr(npy)

;splitting up in the two cases taking the mean or median
case mVSm of

'mean'  : begin
          ; medianize the first N points
          for i=0l,N-1 do begin
             ytotlow = 0.        ;resetting counter
             for j=i+1l,i+N do begin
                ytotlow = ytotlow + yval(j)
             endfor
             ymed(i) = ytotlow/N
          endfor

          ; medianizing intermediate points
          for i=N+0l,npy-N-1 do begin
             ytotabove = 0.      ;resetting counter
             ytotbelow = 0.      ;resetting counter
             for j=i,i+N-1 do begin
                ytotabove = ytotabove + yval(j)
                ytotbelow = ytotbelow + yval(j-N)
             endfor
             ymed(i) = (ytotabove+ytotbelow)/(2*N)
          endfor

          ; medianize the last N points 
          for i=npy-N-1,npy-1 do begin
             ytothigh = 0.        ;resetting counter
             for j=i-N,i-1 do begin
                ytothigh = ytothigh + yval(j)
             endfor
             ymed(i) = ytothigh/N
          endfor
          ;------------------
          ;calculating the difference between origial and medianized valuse
          deltay = fltarr(npy)
          for i=0l,npy-1 do begin
             deltay(i) = yval(i)-ymed(i)
          endfor
          end

'median': begin
          ; medianize the first N points
          yalllow = fltarr(N)
          for i=0l,N-1 do begin
             for j=i+1l,i+N do begin
                yalllow(j-(i+1)) = yval(j)
             endfor
             ymed(i) = median(yalllow,/EVEN)
          endfor

          ; medianizing intermediate points
          yallmid = fltarr(2*N+1)
          for i=N,npy-N-1 do begin
             for j=i-N,i+N do begin
                yallmid(j-(i-N)) = yval(j)
             endfor
             ymed(i) = median(yallmid)
          endfor

          ; medianize the last N points
          yallhigh = fltarr(N)
          for i=npy-N-1l,npy-1 do begin
             ytothigh = 0.        ;resetting counter
             for j=i-N+0l,i-1 do begin
                yallhigh(j-(i-N)) = yval(j)
             endfor
             ymed(i) =median(yallhigh,/EVEN)
          endfor
          ;------------------
          ;calculating the difference between origial and medianized valuse
          deltay = fltarr(npy)
          for i=0l,npy-1 do begin
             deltay(i) = yval(i)-ymed(i)
          endfor
          end
endcase
lastline:
END


