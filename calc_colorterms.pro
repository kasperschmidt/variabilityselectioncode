;+
;----------------------------
;   NAME
;----------------------------
; calc_colorterms.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure returning the color term from two filters calculated with restrictions on
; which entries to use. The two filters (b1 and b2) and the entries in each
; filter (entries1 and entries2) which are suitable for the color estimation is needed 
;----------------------------
;   COMMENTS
;----------------------------
; The entries1 and entries2 can for instance be used to only calculate the colors for values with 
; a reasonable error or trustable magnitude.
;----------------------------
;   INPUTS:
;----------------------------
; b1           : the magnitudes in band 1 
; b2           : the magnitudes in band 2
; ent1         : the entries of band 1 to be considered/used in the color calculation 
; ent2         : the entries of band 2 to be considered/used in the color calculation
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
;
;----------------------------
;   OUTPUTS:
;----------------------------
; b1o          : the b1 magnitudes used in the color calculation
; b2o          : the b2 magnitudes used in the color calculation
; b1b2         : the b1-b2 color
; entries      : the entries of the original band vectors used to estimate the color
;                usefull for where queries. 
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
; 2009-07-20  started by K. B. Schmidt (MPIA)
; 2009-08-28  K. B. Schmidt (MPIA): Adding error message in the case where no pairs can
;                                   be made (happens for downsampled PS1 mock data)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
PRO calc_colorterms,b1,b2,ent1,ent2,b1o,b2o,b1b2,entries

; getting a 'discrimination' vector to find entri matches
vec1 = fltarr(n_elements(b1))
; defining 'empty' vector for where detections
empty = [-1]

for i=0l,n_elements(ent2)-1 do begin
   xx = where(ent1 eq ent2(i))
   if xx ne empty then vec1(xx) = -10
endfor

entries = where(vec1 eq -10)
if entries eq empty then begin
   print,':: calc_colorterms.pro :: No matching bands found so no colors calculated.'
   print,'                          Output set to mag1=[61,61], mag2=[62,62], color=[63,63]'
   print,'                          and entries=[0,1]'
   b1o     = [61,61]
   b2o     = [62,62]
   b1b2    = [63,63]
   entries = [0,1]
endif else begin
   b1o  = b1(entries)
   b2o  = b2(entries)
   b1b2 = b1(entries) - b2(entries)
endelse

END


