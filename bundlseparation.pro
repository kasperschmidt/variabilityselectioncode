;+
;----------------------------
;   NAME
;----------------------------
; bundlseparation.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure dividing data into bundles of related data
; Designed for sorting the same objects at different epochs
; into bundles (which is useful in stripe82 and PS1) so you 
; can manipulate each object (at different epochs) one by one.
;----------------------------
;   COMMENTS
;----------------------------
; You can acchieve a result similar to what this routine creates 
; for structure by using the command(s)
; ENT = UNIQ(data.headids)     ; getting entries of unique IDs
; IDs = data(ent).headids      ; getting the actual IDs
;----------------------------
;   INPUTS:
;----------------------------
; nlines     : total number of lines in data file
; objids     : vector containing an id for each object (size=nlines)
; headid     : vector that links the objects to the 'headid' bundle i.e. 
;              objects with the same headid belongs to the same bundle (size=nlines)
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; 
;----------------------------
;   OUTPUTS:
;----------------------------
; count      : the number of bundls formed
; heads      : vector containing the bundlids (headids) with size=count
; yyarr      : array with the indexes for each bundl listed in the rows
;              thus the 12th row, i.e. yyarr(11,*) gives the indexes that 
;              are in the 12th bundl (idl starts at 0). 
;              Thus looping over rows you can plot and/or
;              manipulate each bundl separately (size=count,nlines/count*5)
; bundlesize : vector containing the size of each bundl (size=count)
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
PRO bundlseparation, nlines,objids,headid,count,heads,yyarr,bundlesize

;--- filling the array with 0s
heads0 = lon64arr(nlines)
for i=0l,nlines-1 do begin
   heads0(i) = 0
endfor
;--- resetting counters
count     = 0.
countbin  = 0.
;--- loop dividing data into bundls
objhead = headid(0)
heads0(0) = headid(0)

for i=0l,nlines-1 do begin
    if (headid(i) eq objhead) then begin
        countbin = countbin + 1.
    endif else begin
        objhead = headid(i)
        ;filling head values into array
        heads0(i) = objhead
        ;counting the total number of bundles (# different objhead ids)
        count = count + 1.
    endelse

    if (i eq nlines-1) then begin
        count = count + 1.
    endif
endfor

; removing 0s in heads0 array
heads = lon64arr(count)
k=0.
for i=0l,nlines-1 do begin
   if (heads0(i) ne 0.) then begin
   heads(k)=heads0(i)
   k = k+1.
   endif
endfor

yysize = nlines/count*10     ; size of yyarr columns set to 10 times the 
                             ; mean bundlesize. Should a bundl be larger
                             ; than nlines/count*10 this number must be changed
yyarr = fltarr(count,yysize)
bundlesize = fltarr(count)

; Loop over all the bundles (loop til count-1)
for jj=0l,count-1 do begin
   lh = jj                                       ; line of head heads2 table
   yy = where(headid eq heads(lh), cbundl)       ; the objects with same head

   bundlesize(jj) = cbundl                        ; # objects in each bundl
   ; creating array with bundl entries in each column
   for i=0l,cbundl-1 do begin
      yyarr(jj,i) = yy(i)                        ; filling the yyarr
   endfor
endfor

END