;+
;----------------------------
;   NAME
;----------------------------
; defarr.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure defining arrays from structures (e.g. read .fits files)
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; nlines          : the number of lines in the data structure (fits file)
; struc           : the structure to create arrays from
; datatype        : the type of data; pssiblities are: 'float', 'lonint', 'integer' and 'double'
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
;
;----------------------------
;   OUTPUTS:
;----------------------------
; arr              ; the structure turned inot a array
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
; 2010-01-15  started by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
PRO defarr,    nlines, struc, datatype, arr

case datatype of
; for real/floating data choose
   'float'       : begin
                     arr = fltarr(nlines)
                     arr = struc   
                  end
; for long integer data choose
   'lonint'     : begin
                     arr = lon64arr(nlines)
                     arr = struc   
                  end
; for small integer data choose
   'integer'    : begin
                     arr = intarr(nlines)
                     arr = struc   
                  end
; for double precision data choose
   'double'      : begin
                     arr = dblarr(nlines)
                     arr = struc   
                   end
; error message
   else          : begin
                     print,':: defarr :: ERROR! The datatype chosen is'  
                     print,'             wrong please choose another' 
                   end
endcase 
END