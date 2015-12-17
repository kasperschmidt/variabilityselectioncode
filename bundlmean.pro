;+
;----------------------------
;   NAME
;----------------------------
; bundlmean.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure calculating the mean of various bundles of data and returning
; the result in an array which can then be looped over.
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; datatype     : type of data. Possible choices are: 'float', 'lonint', 'integer' and 'double'  
; indexarr     : the indexes of each bundl ordered in rows - thus row i corresponds to the
;                entries of the i'th bundle.
; v            : the data to take the mean of (all bundles in one)
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
;
;----------------------------
;   OUTPUTS:
;----------------------------
; vmean        : vector containing the mean values of the data v for each bundl
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
; 2009-03-05  started by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
PRO bundlmean,datatype,indexarr,v,vmean

;--- Getting dimentions
sarr = size(indexarr)
row  = sarr(1)
col  = sarr(2)
;--- Defining constant
vtot = 0.
;--- Defining array
case datatype of
; for real/floating data choose
   'float'       : begin
                     vmean = fltarr(row)
                   end
; for long integer data choose
   'lonint'      : begin
                     vmean = lon64arr(row)
                   end
; for small integer data choose
   'integer'     : begin
                     vmean = intarr(row)
                   end
; for double precision data choose
   'double'      : begin
                     vmean = dblarr(row)
                   end
; error message
   else          : begin
                     print,':: bundlmean :: ERROR! The datatype chosen is'  
                     print,'                wrong please choose another' 
                   end
endcase 
;--- filling the array with 0s
for i=0l,row-1 do begin
   vmean(i) = 0.
endfor
;--- looping over bundls and calculating total values
for i=0l,row-1 do begin
   dummy = where(indexarr(i,*) ne 0,count)
   for j=0,count-1 do begin
      vtot = vtot + v(indexarr(i,j))      
   endfor
   vmean(i) = vtot/count
   vtot = 0.
endfor

END
