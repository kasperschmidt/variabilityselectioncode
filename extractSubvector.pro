;+
;----------------------------
;   NAME
;----------------------------
; extractSubvector.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; This procedure return the resultant vector when a subvector have
; been removed from the input vector.
; It's preferable to have the two vectors contain unique entries such as object
; IDs or similar. In this case there is no confusion of what line to remove - each
; entry in the inout sub vector refers to one (and only one) line in the input vector
;----------------------------
;   COMMENTS
;----------------------------
; A warning will be printed if multiple rows are removed for one subvectore entry 
;
; If the subvector contains entries which doesn't occur in the vector the entries
; will not sum up as n_elements(VECTOR)-n_elements(OUTVEC) = n_elements(SUBVECTOR)
; which will prdocue an error message printed to the screen. In this case this
; error should just be ignored. This happens if you for instance use the procedure
; to find matches between two vectors input as VECTOR and SUBVECTOR.
;
; Input vector can not contain the value -1000.00 since this value is used to remove
; the subvector entries.
;----------------------------
;   INPUTS:
;----------------------------
; vector         : input vector from which you want to remove the subvector
; subvector      : the subvector to be removed from the input 'vector'
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /VERBOSE       : set /VERBOSE to get warnings on multiple matches and no matches etc.
;                  WARNING if your input vector is large and the entries are not unique
;                          the output is a lot!
; /REMOVEDENT    : set REMOVEDENT = to and array and this array will be returned containing
;                  the entries of the removed subvetor wrt the total vector. Usefull if you
;                  want to use the subvector of the total vector instead of the vector where
;                  the subvector has been removed
;----------------------------
;   OUTPUTS:
;----------------------------
; outvec         : the new vector where the subvector has been removed
; entries        : the entries removed from the input vector. These are convenient
;                  to create subvectors of other data vectors - if you for instance have
;                  the magnitudes of the objects in the input vector you can get the 
;                  magnitudes for the outvec by magnitude_vector(entries)
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; ; If you have for instance a vector with the object IDs for a bunch of stars
; and you know which of these object IDs have bad photometry, you might want
; to get rid of them in the original vector. Thus by typing:
;
; IDL> extractSubvector,vector,bad_photometry_vector,outvec,entries
;
; you will get an outvector (outvec) that contains the new vector when the
; bad photometry entries are removed and a vector with the entry numbers
; (entries) in the original vector (which you can use to fo instance create
; other vectors where the bad photometry entries are missing 
;----------------------------
;   BUGS
;----------------------------
; The code only works in the right way if the amount of decimals of the entries are the same
; for instance 1.993845 is not taken to be the same as 1.9938
;----------------------------
;   REVISION HISTORY
;----------------------------
; 2009-07-16  started by K. B. Schmidt (MPIA)
; 2009-09-02  Keyword REMOVEDENT added by K. B. Schmidt (MPIA)
; 2010-10-20  Enabeling run if vectors are identical, i.e. subvector =
;             full vector   K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
PRO extractSubvector,vector,subvector,outvec,entries,VERBOSE=VERBOSE,REMOVEDENT=REMOVEDENT

vb = n_elements(VERBOSE)    ; checking if verbose is set
RE = n_elements(REMOVEDENT)

emptyvec = [-1]
ssv = size(subvector)
SVel= n_elements(subvector)
; new vector to extract from, or else the code will change vector to the modified one!
vec2 = vector

for i=0l,SVel-1 do begin
   xx = where(vector eq subvector(i),ccut)   ; getting entries to remove
   ;printing warning if more than one vector entry is removed for the i'th subvector entry
   if ccut gt 1 then begin
      if vb eq 1 then print,':: extractSubvector.pro :: Warning: subvector entry ',strtrim(subvector(i),1),' occured',strtrim(ccut,1),' times.'
   endif

   ;if xx is empty print warning - if not then change vector values
   if xx eq emptyvec then begin
      if vb eq 1 then print,':: extractSubvector.pro :: Warning: subvector entry ',strtrim(subvector(i),1),' has no matches'
   endif else begin
      ;setting vector entries to -1000 for easy recognition
      vec2(xx)=-1000.00
   endelse
endfor

entries = where(vec2 ne -1000.00,cnout)
if RE ne 0 then REMOVEDENT = where(vec2 eq -1000.00,cRE)

if entries eq [-1] then begin     ; in the case there are matches to all input values
   outvec = -9999.
   if vb eq 1 then print,':: extractSubvector.pro :: Matches found for all input values. Hence, outvec=[-9999] and entries=[-1]'
endif else begin                  ; in the case there is a well defined subvector and entries have been removed
   outvec = vector(entries)

   sout = size(outvec)
   sv   = size(vector)
   ;printing error if the sizes don't match up - the vector entries are not unique in this case
   if (n_elements(vector)-SVel ne n_elements(outvec)) then begin
   print,'-------------------------------------------------------------------------------'
   print,':: extractSubvector.pro :: ERROR!! The dimensions are wrong which indicate that'
   print,'                                   entries of the input vectors are not unique!'
   print,'    ERROR                          size of input vector        :',size(vector)
   print,'           ERROR                   size of input subvector     :',size(subvector)
   print,'                  ERROR            size of output vector       :',size(outvec)
   print,'                         ERROR     size of output entries-array:',size(entries)
   if RE ne 0 then print,'                                   size of removed entries-arr.:',size(REMOVEDENT)
   print,'                                   is that what you expected? If so ... no worries!'
   print,'-------------------------------------------------------------------------------'
   endif

endelse

END
