;+
;----------------------------
;   NAME
;----------------------------
; removesparsesamples.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; procedure for removeing bundles of epochs where there are t0o few epochs.
; If you for instance want more than 15 epochs of data you can use this program
; to remove all the objects that have less than 15 epochs in the datafile
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; infile         : The table name of the file where the undersampled objects should be
;                  removed from
; epochs         : The minimum number of epochs for each object in the output fits file
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /VERBOSE       : set /VERBOSE to get information printed to the screen
;----------------------------
;   OUTPUTS:
;----------------------------
; outfile        : the filename of the .fits file where all the samples with less than
;                  'epochs' epochs are removed
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; IDL> removesparsesamples,'inputdata.fits',20,outfile,/VERBOSE
;----------------------------
;   BUGS
;----------------------------
; 
;----------------------------
;   REVISION HISTORY
;----------------------------
;   2009-07-11  started by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
PRO removesparsesamples,infile,epochs,outfile,VERBOSE=VERBOSE

VB = n_elements(VERBOSE)

ep = STRTRIM(epochs,1)

;splitting the infile in name and extension (split(0)+name and split(1)=extension)
split = STRSPLIT(infile,'.',/extract)
outfile = split(0)+'_epochsGT'+ep+'.fits'       ; creating name of output file
s=MRDFITS(infile,1,hdr)                         ; reading infile

;resetting counters
crem   = 0.0
clines = 0.0

;defining array to idicate lines to remove
ss = size(s)
gone = fltarr(ss(1))

; Get unique headobjids:
sorts = sort(s.headobjid)
objects = s[uniq(s[sorts].HEADOBJID)].HEADOBJID
Nobj = n_elements(objects)
if VB eq 1 then print, ':: removesparsesamples.pro :: Found',Nobj,' objects in table'

for i=0l,Nobj-1 do begin
   xx = where(s[sorts].HEADOBJID eq objects(i), cep)
   if cep lt ep then begin
      gone(xx) = 1.0
      crem = crem + 1
   endif else begin
      gone(xx) = 0.0
   endelse
endfor

yy = where(gone eq 0,clines)
if yy ne [-1] then begin
   MWRFITS, s[yy], outfile, /create
   if VB eq 1 then print, ':: removesparsesamples.pro :: Removed ',crem,' objects from ',infile
   if VB eq 1 then print, ':: removesparsesamples.pro :: which corresponds to removing ',ss(1)-clines,' lines'
   if VB eq 1 then print, ':: removesparsesamples.pro :: The new .fits table have been written to ',outfile
endif else begin
   if VB eq 1 then print, ':: removesparsesamples.pro :: No objects need to be removed so no output file written!'
endelse
END