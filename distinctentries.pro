;+
;----------------------------
;   NAME
;----------------------------
; distinctentries.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; program for selecting and returning the distinct values in a vector
;----------------------------
;   COMMENTS
;----------------------------
; the UNIQ command does a similar thing
;----------------------------
;   INPUTS:
;----------------------------
; vec             : the vector to find distinct entries for
; datatype        : the type of data in the input vector. The possibilites are: 
;                   'float', 'lonint', 'integer' and 'double'
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
;
;----------------------------
;   OUTPUTS:
;----------------------------
; vecout         : output containing the distinct values of input vector
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
;
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
PRO distinctentries,vec,datatype,vecout

n = size(vec)
nlines = n(1)
svec = sort(vec)
vec = vec(svec)

case datatype of
; -----------------------------
; for real/floating data choose
'float'   : begin
   vecout0 = fltarr(nlines)
   vecout0(0) = vec(0)
   for i=1l,nlines-1 do begin
      if vec(i) ne vec(i-1) then begin
         vecout0(i) = vec(i)            ;writing distinct values to vecout0
      endif
   endfor
   ;removing 0 from vecout0 array and creating output
   xvecout = where(vecout0 ne 0,count)
   vecout = flt64arr(count)
   vecout = vecout0(xvecout)
end
; -----------------------------
; for long integer data choose
'lonint'  : begin
   vecout0 = lon64arr(nlines)
   vecout0(0) = vec(0)
   for i=1l,nlines-1 do begin
      if vec(i) ne vec(i-1) then begin
         vecout0(i) = vec(i)            ;writing distinct values to vecout0
      endif
   endfor
   ;removing 0 from vecout0 array and creating output
   xvecout = where(vecout0 ne 0,count)
   vecout = lon64arr(count)
   vecout = vecout0(xvecout)
end
; -----------------------------
; for small integer data choose
'integer' : begin
   vecout0 = intarr(nlines)
   vecout0(0) = vec(0)
   for i=1l,nlines-1 do begin
      if vec(i) ne vec(i-1) then begin
         vecout0(i) = vec(i)            ;writing distinct values to vecout0
      endif
   endfor
   ;removing 0 from vecout0 array and creating output
   xvecout = where(vecout0 ne 0,count)
   vecout = intarr(count)
   vecout = vecout0(xvecout)
end
; -----------------------------
; for double precision data choose
'double'  : begin
   vecout0 = dblarr(nlines)
   vecout0(0) = vec(0)
   for i=1l,nlines-1 do begin
      if vec(i) ne vec(i-1) then begin
         vecout0(i) = vec(i)            ;writing distinct values to vecout0
      endif
   endfor
   ;removing 0 from vecout0 array and creating output
   xvecout = where(vecout0 ne 0,count)
   vecout = dblarr(count)
   vecout = vecout0(xvecout)   
end
; -----------------------------
; error message
else      : begin
   print,':: defarr :: ERROR! The datatype chosen is'  
   print,'             wrong please choose another' 
end
; -----------------------------
endcase 
END