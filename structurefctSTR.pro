;+
;----------------------------
;   NAME
;----------------------------
; structurefctSTR.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure calculating the structure function in two different ways.
; 1) following the approach by Vanden Berk et al. 2004
; 2) an approach similar to 1) but where the individual errors (and
; not the average ones like in 1)) are taken into account.
;
; We want to calculate
;  -------------------------------------------
; | f(x1,x2)                                  |
; | f(x1,x3) f(x2,x3)                         |
; | f(x1,x4) f(x2,x4) f(x3,x4)                | N-1
; |     :        :        :                   |
; | f(x1,xN) f(x2,xN) f(x3,xN) ... f(xN-1,xN) |
;  -------------------------------------------
;                    N-1
; where the function f is either abs(of difference) or product
; Thus the results array has dimensions: 3,SUM_i=1^(N-1)of(N-i),nobundl
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; v                : the data to be analyzed
; verr             : errors on the data
; verrmin          : the value of a possible 'calibration error floor'
;                    (set to 0. if no error floor excists) 
; bundlsize        : size of each data bundle (# of epochs for each object)
; nobundl          : number of objects
; mjd              : Modified Julian Day for each data point in v
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; PS1BIN           : Set /PS1BIN to create a four bin structure function for data
;                    (down)sampled with the PS1 cadence (time intervals). If not set
;                    the default number of bins is 10 equally spaced in log from 0 to
;                    2.3^10
;----------------------------
;   OUTPUTS:
;----------------------------
; strufctSTRarr    : The structure function for each epoch put into a data
;                    structure array. The array contains one structure for each
;                    object with the central dt values and the structure function
;                    values. 
;                    The time intervals used are given by the vectors set below. If
;                    the keyword /PS1BIN is set bins optimized for Pan-STARRS 1 data
;                    are used. Each data structure is ordered so that it contains two
;                    collumns: one containing the centre of the time bins and one
;                    containing the structure function values for the given
;                    timebins. The bundles are the structure array dimension. Thus
;                    calling strufctSTRarr(10) will return the structure function
;                    data for the 11th object. Calling
;                    strufctSTRarr(10).dt(*) gives you the time bins and
;                    strufctSTRarr(10).value(*) the structure function values.
; strufctnewSTRarr : Is a data structure array arranged in the same way as for
;                    strufctSTRarr for a slightly modified structure function where
;                    each measurement is corrected with its own error and not the mean
;                    error. The basic eq. is: 
;                    V_ij = sqrt(pi/2) abs(mi-mj) - sqrt(erri^2+errj^2)
;                    which is them divided into bins of similar timediffs.
;                    furthermore there is a string dimension containing error estimates of
;                    the calculated values. The errors are estimated as:
;                    standard deviation of the values in each time bin
; sortresSTRarr    : The sorted (by time difference) results used to calculate the 
;                    structure finction put into a data structure array.
;                    Each structure (one for each object) in the array
;                    contains four collumns: 
;                    1) the MJD difference
;                    2) the v value difference
;                    3) the sum of the errors on v squared
;                    4) the corresponding (new) structure function value
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
; 2009-03-25  started by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
PRO structurefctSTR,v,verr,verrmin,bundlsize,nobundl,mjd,strufctSTRarr,strufctnewSTRarr,sortresSTRarr, PS1BIN = PS1BIN

bintype = n_elements(PS1BIN)

;---CALCULATING THE SIZE OF LARGEST POSSIBLE VECTOR---
; calculating the sum over (N-i) from 1 to N-1 used as the size of the
; structure entries
   sN = 0.
   for f=1,max(bundlsize)-1 do begin
      sN = sN + (max(bundlsize)-f)
   endfor

;---VALUES USED WHEN TIME BINNING---
if bintype eq 0 then begin
;  the default is 10 bins (11 entries) equally space in log:
   timebin = fltarr(11)
   timebin = [0,2.3^1,2.3^2,2.3^3,2.3^4,2.3^5,2.3^6,2.3^7,2.3^8,2.3^9,2.3^10]
   tbin = n_elements(timebin)                          ; number of time bin 'dividers'
endif else begin
;  Defining 4 bins (5 entries) suitable for the PS1 time sampling (cadence)
   timebin = fltarr(5)
   timebin = [0,30,360,720,1200]
   tbin = n_elements(timebin)                          ; number of time bin 'dividers'
endelse

;one element array with value -1 to test test for no-value-bins in where fcts
emptybin    = [-1]
;-----------------------------------
;Defining data structures for the calculation results and the output.
;--- STRuctures for calculations---
resSTR    = {dMJD:fltarr(sN),dv:fltarr(sN),dverr2:fltarr(sN),dStrucNew:fltarr(sN)}
resSTRarr = replicate(resSTR,nobundl)

sortresSTR    = {dMJD:fltarr(sN),dv:fltarr(sN),dverr2:fltarr(sN),dStrucNew:fltarr(sN)}
sortresSTRarr = replicate(sortresSTR,nobundl)
;--- STRuctures for output---
strufctSTR       = {dt:fltarr(tbin-1),value:fltarr(tbin-1)}
strufctSTRarr    = replicate(strufctSTR,nobundl)

strufctnewSTR    = {dt:fltarr(tbin-1),value:fltarr(tbin-1),valueerr:fltarr(tbin-1)}
strufctnewSTRarr = replicate(strufctnewSTR,nobundl)

;variable keeping track of bundles so j loop runs over right entries
bundles = 0.
;-----------------------------------
;---FILLING THE resSTR structure---
for i=0l,nobundl-1 do begin             ;looping over bundls
   htot = 0.                             ;resetting index counter for new bundl
   for j=0l+bundles,bundles+bundlsize(i)-2 do begin     ;looping over epochs in bundl
      for k=j+1,bundles+bundlsize(i)-1 do begin ;looping over epochs again(making pairs)
         index = htot                   ;assigning index value
         resSTRarr(i).dMJD(index) = abs(mjd(j)-mjd(k))         ;time difference
         resSTRarr(i).dv(index)   = abs(v(j)-v(k))             ;value difference
         ;sum of errors^2 corrected with the SDSS error floor (3 diff ways)
         resSTRarr(i).dverr2(index) = verr(j)^(2.)+verr(k)^(2.)-2*verrmin^(2.)
         version = 1           ;identifier used when writing to file
;         resSTRarr(i).dverr2(index) = abs(verr(j)^(2.)+verr(k)^(2.)-2*verrmin^(2.))
;         version = 2           ;identifier used when writing to file
;         resSTRarr(i).dverr2(index) = (verr(j)-verrmin)^(2.)+(verr(k)-verrmin)^(2.)
;         version = 3           ;identifier used when writing to file

         ;calculating the variability of structNew to be time binned
         resSTRarr(i).dStrucNew(index) =sqrt(!pi/2.)*resSTRarr(i).dv(index)-sqrt(resSTRarr(i).dverr2(index))
         htot = htot+1.                  ;index increment
      endfor
   endfor
   bundles = bundles + bundlsize(i)
endfor

;-----------------------------------
;---CALCULATING AND FILLING OUTPUT STRUCTURES---
for i=0l,nobundl-1 do begin        ;looping over bundls
   ;sorting structures so each entry is sorted by increasing dMJD
   ss = sort(resSTRarr(i).dMJD(*))
   sortresSTRarr(i).dMJD      = (resSTRarr(i).dMJD(ss))
   sortresSTRarr(i).dv        = (resSTRarr(i).dv(ss))
   sortresSTRarr(i).dverr2    = (resSTRarr(i).dverr2(ss))
   sortresSTRarr(i).dStrucNew = (resSTRarr(i).dStrucNew(ss))
   ;------------------------------------------------------
   ;---TIME INETERVALS DEFINED AND CALC STRUCTURE FUNCTION---   
   ;The first and last entries are calculated manually to ensure a
   ;proper start and end of the structure functions
   ;---CALCULATING FIRST ENTRY---
   for k=0l,tbin-2 do begin     ;looping over the number of MJD bins
      sumv   = 0.               ;resetting sum
      sumerr = 0.               ;resetting sum
      sumstr = 0.               ;resetting sum
      ;getting the entries which fall in the k'th MJD bin
      timek = where((sortresSTRarr(i).dMJD(*) gt timebin(k)) AND (sortresSTRarr(i).dMJD(*) lt timebin(k+1)), ctk)

      ;creating time steps for plotting as centre of bin
      strufctSTRarr(i).dt(k)    = (timebin(k)+timebin(k+1))/2.
      strufctnewSTRarr(i).dt(k) = (timebin(k)+timebin(k+1))/2.
      ;making sure that empty bins are still 0 bins (avoid filling them)
      if timek eq emptybin then begin  ; setting bin values to 0.0 if timebin is empty
         if k eq 0 then begin
            fakepoint  = 0.000
            fakepointN = 0.000
         endif else begin
            fakepoint  = 0.0 
            fakepointN = 0.0 
         endelse
         strufctSTRarr(i).value(k) = fakepoint
         strufctnewSTRarr(i).value(k) = fakepointN
         goto, jump1
      endif

      ;creating vectors of dv,dverr2 and dStrucNew for the given bin
      varr      = sortresSTRarr(i).dv(timek)       
      errarr    = sortresSTRarr(i).dverr2(timek)   
      strnewarr = sortresSTRarr(i).dStrucNew(timek)
      ;calculating the total values
      for m=0l,ctk-1 do begin
          sumv   = sumv   + varr(m)
          sumerr = sumerr + errarr(m)
          sumstr = sumstr + strnewarr(m)
      endfor
      ;calculating the values for each time bin of the  Vanden Berk structure function
      strufctSTRarr(i).value(k) = sqrt(!pi/2.*(sumv/ctk)^(2.)-sumerr/ctk)
      ;calculating the value in each time bin of the alternative structure function
      strufctnewSTRarr(i).value(k) = sumstr/ctk
      ;calculating the estimated error on the structure function values
      if n_elements(strnewarr) gt 1 then begin
         strufctnewSTRarr(i).valueerr(k) = STDDEV(strnewarr)/sqrt(ctk)
      endif else begin
         strufctnewSTRarr(i).valueerr(k) = abs(strnewarr[0])   ;abs so we dont get <0 values
      endelse
jump1:
   endfor
endfor
END
