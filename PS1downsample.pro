;+
;----------------------------
;   NAME
;----------------------------
; PS1downsample.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Read in SDSS multi-epoch object table and downsample to PS1 cadence
;----------------------------
;   COMMENTS
;----------------------------
; Unobserved magnitudes zeroed out in magerr, and set to -9999 in mag.
; Unobserved epochs removed completely to save space.
; Values (specific band in epochs) to be ignored in the input table should
; have the value -9999 to be recognized and ignored in the downsampling
;
; NB! only resets psfMAG and psfMAGerr
;----------------------------
;   INPUTS:
;----------------------------
; table           : Fits file containing SDSS objects: one row per object per epoch
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /deredPSF       : set the keyword to indicate the presence of deredPSF magnitudes
;                   in the fits file. These will then be reset together with the PSF
;                   magnitudes when selecting the epochs
;----------------------------
;   OUTPUTS:
;----------------------------
; newtable        : The path and name of the new Fits file containing SDSS objects, same format
;                   Filename is table:r_PS1downsampled.fits 
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
; 2009-07-01  started by Marshall (UCSB) in Heidelberg
; 2009-07-13  Objid changed by K. B. Schmidt (MPIA)
;             objids of selected epochs changed and written 'by hand'
;             to output file to prevent multiple objids in the same 
;             object bundle
; 2010-02-01  Ignoring of -9999 values in input file and
;             /deredPSF keyword added by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
pro PS1downsample, table, newtable, VERBOSE=vb, DEREDPSF=DEREDPSF

vb = n_elements(vb)
dered = n_elements(DEREDPSF)

; Read in table and hdr:
x = mrdfits(table,1,hdr)

; Get unique headobjids:
objects = x[uniq(x[sort(x.HEADOBJID)].HEADOBJID)].HEADOBJID
print, 'PS1DOWNSAMPLE: found ',n_elements(objects),' objects in table'

; New table name:                       
parts = strsplit(table,'.',/extract)
root = strjoin(parts[0:n_elements(parts)-2],'.')
newtable = root+'_PS1downsampled.fits'
print, 'PS1DOWNSAMPLE: output table will be '+newtable

; Loop over objects:
ngood = n_elements(objects)

for kk=0L,n_elements(objects)-1 do begin
; Get row numbers:
  j = where(x.HEADOBJID eq objects[kk])
  if (vb) then print, "Object ",objects[kk]
  
; Look at MJDs - adopt i band as common MJD for all bands:
  t = x[j].MJD_I - 53600
  psf_u = x[j].PSFmag_u
  psf_g = x[j].PSFmag_g
  psf_r = x[j].PSFmag_r
  psf_i = x[j].PSFmag_i
  psf_z = x[j].PSFmag_z
  if (vb) then print, "  Observed epochs: ",t
  
; Only proceed if we have enough epochs:    
    jz = 0
; Check jz later to see if he is more than one element...

; Trim row numbers outside each year of SN survey (started on MJD 53600):  
  for season=1L,3L do begin
    index = where(t gt 365*(season-1) - 28 and t lt (365*(season-1) + 90 + 28))
    nn = n_elements(index)
    if (vb) then print, "  Season ",season," has: ",nn," epochs:"

    if index ne [-1] then begin
       ; counting bad photometry entries in given season
       bad_u = n_elements(where(psf_u[index] eq -9999.))    
       bad_g = n_elements(where(psf_g[index] eq -9999.))    
       bad_r = n_elements(where(psf_r[index] eq -9999.))    
       bad_i = n_elements(where(psf_i[index] eq -9999.))    
       bad_z = n_elements(where(psf_z[index] eq -9999.))    
    endif else begin
       ; counting bad photometry entries in given season
       bad_u = 0
       bad_g = 0
       bad_r = 0
       bad_i = 0
       bad_z = 0
    endelse
    ; deternining if there are at least 7 epochs in the season where all bands 
    ; at least have 2 entries with good photometry
    if (nn ge 7 and (nn-bad_u) ge 2 and (nn-bad_g) ge 2 and (nn-bad_r) ge 2 and (nn-bad_i) ge 2 and (nn-bad_z) ge 2) then begin

      jj = j(index) 
      tt = x[jj].MJD_I - 53600
      ;This is an unsorted list of times. Sort it!
      index = sort(tt)
      jj = jj[index]
      tt = tt[index]
      if (vb) then print, tt

;  z and u -band have largest time separation. 
;  i,r,g taken in sequence, 5 days apart and 30 days between repeats.
; if any one season has fewer than 7 epochs, junk the season!    
      ;----------------------------- z band -----------------------------
      mag     =  x[jj].PSFmag_z         ; getting the magnitudes
;      mag[0:3] = -9999
;      mag[15] = -9999
      for i=0,n_elements(tt)-1 do begin ;looping over sorted array to find best distance
        if (mag[i] ne -9999) then begin ; making sure that magnitude for t1 is good
          t1 = tt[i]
          t1_entry = i                  ;storing entry number
          goto, t1foundz                 ;if a t1 is found jump out of loop
        endif        
      endfor
      t1foundz:
;     z-band - 150 day cadence in PS1:
      t2 = t1 + 150.0
      ;sorting time differences and magnitudes wrt time diff.
      distance = tt[sort(abs(tt - t2))]
      magsort =  mag[sort(abs(tt - t2))]

      for i=0,n_elements(distance)-1 do begin ;looping over sorted array to find best distance
        ;asking for dt where distance is not 0 and PSFmag is good
        if (distance[i] gt 0.0 and magsort[i] ne -9999) then begin
          dt = distance[i]
          goto, dtfoundz                   ;if a dt is found jump out of loop
        endif        
      endfor
      dtfoundz:
      jjz = [jj[t1_entry],jj[where(tt eq dt)]]
      tz = x[jjz].MJD_I - 53600

      ;----------------------------- u band -----------------------------
      ;u-band - not a PS1 filter. Just use z-band epochs!
      jju = [jj[t1_entry],jj[where(tt eq dt)]]
      tu = x[jju].MJD_I - 53600

      ;----------------------------- i band -----------------------------
      mag     =  x[jj].PSFmag_i         ; getting the magnitudes
      for i=0,n_elements(tt)-1 do begin ;looping over sorted array to find best distance
        ; making sure that magnitude for t1 is good and that we don't use the one from z-band
        if (mag[i] ne -9999 and tt[i] ne tt[t1_entry]) then begin
          t1 = tt[i]
          t1_entry = i                  ;storing entry number
          goto, t1foundi                 ;if a t1 is found jump out of loop
        endif        
      endfor
      t1foundi:
;     i band - 30 day cadence in PS1:
      t2 = t1 + 30.0
      ;sorting time differences and magnitudes wrt time diff.
      distance = tt[sort(abs(tt - t2))]
      magsort =  mag[sort(abs(tt - t2))]

      for i=0,n_elements(distance)-1 do begin ;looping over sorted array to find best distance
        ;asking for dt where distance is not 0 and PSFmag is good
        if (distance[i] gt 0.0 and magsort[i] ne -9999) then begin
          dt = distance[i]
          goto, dtfoundi                   ;if a dt is found jump out of loop
        endif        
      endfor
      dtfoundi:
      jji = [jj[t1_entry],jj[where(tt eq dt)]]
      ti = x[jji].MJD_I - 53600

      ;----------------------------- r band -----------------------------
      mag     =  x[jj].PSFmag_r         ; getting the magnitudes
;     r band - 30 day cadence in PS1, 5 days after i: 
      t1 = t1 + 5
      distance = tt[sort(abs(tt - t1))]
      magsort =  mag[sort(abs(tt - t1))]
      for i=0,n_elements(tt)-1 do begin ;looping over sorted array to find best distance
        if (magsort[i] ne -9999 and distance[i] gt 0.0) then begin ; making sure that magnitude for t1 is good
          t1 = distance[i]
          t1_entry = i                  ;storing entry number
          goto, t1foundr                 ;if a t1 is found jump out of loop
        endif        
      endfor
      t1foundr:
      jjr = [jj[where(tt eq t1)],0]
;     i band - 30 day cadence in PS1:
      t2 = t1 + 30.0
      ;sorting time differences and magnitudes wrt time diff.
      distance = tt[sort(abs(tt - t2))]
      magsort =  mag[sort(abs(tt - t2))]

      for i=0,n_elements(distance)-1 do begin ;looping over sorted array to find best distance
        ;asking for dt where distance is not 0 and PSFmag is good
        if (distance[i] gt 0.0 and magsort[i] ne -9999) then begin
          dt = distance[i]
          goto, dtfoundr                   ;if a dt is found jump out of loop
        endif        
      endfor
      dtfoundr:
      jjr = [jjr[0],jj[where(tt eq dt)]]
      tr = x[jjr].MJD_I - 53600

      ;----------------------------- g band -----------------------------
      mag     =  x[jj].PSFmag_g         ; getting the magnitudes
;     r band - 30 day cadence in PS1, 5 days after i: 
      t1 = t1 + 5
      distance = tt[sort(abs(tt - t1))]
      magsort =  mag[sort(abs(tt - t1))]
      for i=0,n_elements(tt)-1 do begin ;looping over sorted array to find best distance
        if (magsort[i] ne -9999 and distance[i] gt 0.0) then begin ; making sure that magnitude for t1 is good
          t1 = distance[i]
          t1_entry = i                  ;storing entry number
          goto, t1foundg                 ;if a t1 is found jump out of loop
        endif        
      endfor
      t1foundg:
      jjg = [jj[where(tt eq t1)],0]
;     i band - 30 day cadence in PS1:
      t2 = t1 + 30.0
      ;sorting time differences and magnitudes wrt time diff.
      distance = tt[sort(abs(tt - t2))]
      magsort =  mag[sort(abs(tt - t2))]

      for i=0,n_elements(distance)-1 do begin ;looping over sorted array to find best distance
        ;asking for dt where distance is not 0 and PSFmag is good
        if (distance[i] gt 0.0 and magsort[i] ne -9999) then begin
          dt = distance[i]
          goto, dtfoundg                   ;if a dt is found jump out of loop
        endif        
      endfor
      dtfoundg:
      jjg = [jjg[0],jj[where(tt eq dt)]]
      tg = x[jjg].MJD_I - 53600

      if (vb) then begin
        print, "    Selected epochs:"
        print, "      z-band: ",tz
        print, "      u-band: ",tu
        print, "      i-band: ",ti
        print, "      r-band: ",tr
        print, "      g-band: ",tg
      endif
   
      if (season eq 1) then begin
        jz = [jjz]
        ju = [jju]
        ji = [jji]
        jr = [jjr]
        jg = [jjg]
      endif else begin
        jz = [jz,jjz]
        ju = [ju,jju]
        ji = [ji,jji]
        jr = [jr,jjr]
        jg = [jg,jjg]
      endelse
    endif ; the end of the nn gt 7 loop
            
  endfor ; then end of the sesons loop

; OK, have indices jz,ju etc of epochs we want to keep. Want 6
; epochs per filter:
  if (n_elements(jz) eq 6) then begin
;   Copy desired rows of table, one filter at a time.
    nrows = 0

;   z-band:
    xx = x[jz]
;   Reset photometry:
    xx.psfMag_u = xx.psfMag_u*0.0 - 9999
    xx.psfMag_g = xx.psfMag_g*0.0 - 9999
    xx.psfMag_r = xx.psfMag_r*0.0 - 9999
    xx.psfMag_i = xx.psfMag_i*0.0 - 9999
    xx.psfMag_z = xx.psfMag_z
    xx.psfMagErr_u = xx.psfMagErr_u*0.0
    xx.psfMagErr_g = xx.psfMagErr_g*0.0
    xx.psfMagErr_r = xx.psfMagErr_r*0.0
    xx.psfMagErr_i = xx.psfMagErr_i*0.0
    xx.psfMagErr_z = xx.psfMagErr_z
    if dered eq 1 then begin
       xx.deredpsfMag_u = xx.deredpsfMag_u*0.0 - 9999
       xx.deredpsfMag_g = xx.deredpsfMag_g*0.0 - 9999
       xx.deredpsfMag_r = xx.deredpsfMag_r*0.0 - 9999
       xx.deredpsfMag_i = xx.deredpsfMag_i*0.0 - 9999
       xx.deredpsfMag_z = xx.deredpsfMag_z
    endif

    ;----------------------------------------------------------------------
    ;modifying the object IDs to prevent multiple objids in the same bundle
    ;the objids are on the form oooooobbeee, where o shows the object number,
    ;bb shows the band (u,g,r,i,z ~ 1,2,3,4,5) and e indicates the epoch
    sxjz     = size(x[jz])       ; getting the size of structure
    newobjidz= lon64arr(sxjz[1]) ; defining array for new objids
    for k=1,sxjz[1] do begin     ; looping over the number of g band epochs
       newobjidz[k-1] = 10000000000+(i+1)*1000000+5000+k
    endfor
    xx.objid = newobjidz         ; filling structure with new objids
    ;----------------------------------------------------------------------
; Add to pile:        
    if (n_elements(y) eq 0) then begin
      y = [xx]
    endif else begin
      y = [y,xx]
    endelse
    nrows += n_elements(xx)

;   u-band:
    xx = x[ju]
    xx.psfMag_u = xx.psfMag_u
    xx.psfMag_g = xx.psfMag_g*0.0 - 9999
    xx.psfMag_r = xx.psfMag_r*0.0 - 9999
    xx.psfMag_i = xx.psfMag_i*0.0 - 9999
    xx.psfMag_z = xx.psfMag_z*0.0 - 9999
    xx.psfMagErr_u = xx.psfMagErr_u
    xx.psfMagErr_g = xx.psfMagErr_g*0.0
    xx.psfMagErr_r = xx.psfMagErr_r*0.0
    xx.psfMagErr_i = xx.psfMagErr_i*0.0
    xx.psfMagErr_z = xx.psfMagErr_z*0.0
    if dered eq 1 then begin
       xx.deredpsfMag_u = xx.deredpsfMag_u
       xx.deredpsfMag_g = xx.deredpsfMag_g*0.0 - 9999
       xx.deredpsfMag_r = xx.deredpsfMag_r*0.0 - 9999
       xx.deredpsfMag_i = xx.deredpsfMag_i*0.0 - 9999
       xx.deredpsfMag_z = xx.deredpsfMag_z*0.0 - 9999
    endif
    ;----------------------------------------------------------------------
    ;modifying the object IDs to prevent multiple objids in the same bundle
    ;the objids are on the form oooooobbeee, where o shows the object number,
    ;bb shows the band (u,g,r,i,z ~ 1,2,3,4,5) and e indicates the epoch
    sxju     = size(x[ju])       ; getting the size of structure
    newobjidu= lon64arr(sxju[1]) ; defining array for new objids
    for k=1,sxju[1] do begin     ; looping over the number of g band epochs
       newobjidu[k-1] = 10000000000+(i+1)*1000000+1000+k
    endfor
    xx.objid = newobjidu         ; filling structure with new objids
    ;----------------------------------------------------------------------
    y = [y,xx]
    nrows += n_elements(xx)

;   i-band:
    xx = x[ji]
    xx.psfMag_u = xx.psfMag_u*0.0 - 9999
    xx.psfMag_g = xx.psfMag_g*0.0 - 9999
    xx.psfMag_r = xx.psfMag_r*0.0 - 9999
    xx.psfMag_i = xx.psfMag_i
    xx.psfMag_z = xx.psfMag_z*0.0 - 9999
    xx.psfMagErr_u = xx.psfMagErr_u*0.0
    xx.psfMagErr_g = xx.psfMagErr_g*0.0
    xx.psfMagErr_r = xx.psfMagErr_r*0.0
    xx.psfMagErr_i = xx.psfMagErr_i
    xx.psfMagErr_z = xx.psfMagErr_z*0.0
    if dered eq 1 then begin
       xx.deredpsfMag_u = xx.deredpsfMag_u*0.0 - 9999
       xx.deredpsfMag_g = xx.deredpsfMag_g*0.0 - 9999
       xx.deredpsfMag_r = xx.deredpsfMag_r*0.0 - 9999
       xx.deredpsfMag_i = xx.deredpsfMag_i
       xx.deredpsfMag_z = xx.deredpsfMag_z*0.0 - 9999
    endif

    ;----------------------------------------------------------------------
    ;modifying the object IDs to prevent multiple objids in the same bundle
    ;the objids are on the form oooooobbeee, where o shows the object number,
    ;bb shows the band (u,g,r,i,z ~ 1,2,3,4,5) and e indicates the epoch
    sxji     = size(x[ji])       ; getting the size of structure
    newobjidi= lon64arr(sxji[1]) ; defining array for new objids
    for k=1,sxji[1] do begin     ; looping over the number of g band epochs
       newobjidi[k-1] = 10000000000+(i+1)*1000000+4000+k
    endfor
    xx.objid = newobjidi         ; filling structure with new objids
    ;----------------------------------------------------------------------
    y = [y,xx]
    nrows += n_elements(xx)

;   r-band:
    xx = x[jr]
    xx.psfMag_u = xx.psfMag_u*0.0 - 9999
    xx.psfMag_g = xx.psfMag_g*0.0 - 9999
    xx.psfMag_r = xx.psfMag_r
    xx.psfMag_i = xx.psfMag_i*0.0 - 9999
    xx.psfMag_z = xx.psfMag_z*0.0 - 9999
    xx.psfMagErr_u = xx.psfMagErr_u*0.0
    xx.psfMagErr_g = xx.psfMagErr_g*0.0
    xx.psfMagErr_r = xx.psfMagErr_r
    xx.psfMagErr_i = xx.psfMagErr_i*0.0
    xx.psfMagErr_z = xx.psfMagErr_z*0.0
    if dered eq 1 then begin
       xx.deredpsfMag_u = xx.deredpsfMag_u*0.0 - 9999
       xx.deredpsfMag_g = xx.deredpsfMag_g*0.0 - 9999
       xx.deredpsfMag_r = xx.deredpsfMag_r
       xx.deredpsfMag_i = xx.deredpsfMag_i*0.0 - 9999
       xx.deredpsfMag_z = xx.deredpsfMag_z*0.0 - 9999
    endif
    ;----------------------------------------------------------------------
    ;modifying the object IDs to prevent multiple objids in the same bundle
    ;the objids are on the form oooooobbeee, where o shows the object number,
    ;bb shows the band (u,g,r,i,z ~ 1,2,3,4,5) and e indicates the epoch
    sxjr     = size(x[jr])       ; getting the size of structure
    newobjidr= lon64arr(sxjr[1]) ; defining array for new objids
    for k=1,sxjr[1] do begin     ; looping over the number of g band epochs
       newobjidr[k-1] = 10000000000+(i+1)*1000000+3000+k
    endfor
    xx.objid = newobjidr          ; filling structure with new objids
    ;----------------------------------------------------------------------
    y = [y,xx]
    nrows += n_elements(xx)

;   g-band:
    xx = x[jg]
    xx.psfMag_u = xx.psfMag_u*0.0 - 9999
    xx.psfMag_g = xx.psfMag_g
    xx.psfMag_r = xx.psfMag_r*0.0 - 9999
    xx.psfMag_i = xx.psfMag_i*0.0 - 9999
    xx.psfMag_z = xx.psfMag_z*0.0 - 9999
    xx.psfMagErr_u = xx.psfMagErr_u*0.0
    xx.psfMagErr_g = xx.psfMagErr_g
    xx.psfMagErr_r = xx.psfMagErr_r*0.0
    xx.psfMagErr_i = xx.psfMagErr_i*0.0
    xx.psfMagErr_z = xx.psfMagErr_z*0.0
    if dered eq 1 then begin
       xx.deredpsfMag_u = xx.deredpsfMag_u*0.0 - 9999
       xx.deredpsfMag_g = xx.deredpsfMag_g
       xx.deredpsfMag_r = xx.deredpsfMag_r*0.0 - 9999
       xx.deredpsfMag_i = xx.deredpsfMag_i*0.0 - 9999
       xx.deredpsfMag_z = xx.deredpsfMag_z*0.0 - 9999
    endif
    ;----------------------------------------------------------------------
    ;modifying the object IDs to prevent multiple objids in the same bundle
    ;the objids are on the form oooooobbeee, where o shows the object number,
    ;bb shows the band (u,g,r,i,z ~ 1,2,3,4,5) and e indicates the epoch
    sxjg     = size(x[jg])       ; getting the size of structure
    newobjidg= lon64arr(sxjg[1]) ; defining array for new objids
    for k=1,sxjg[1] do begin     ; looping over the number of g band epochs
       newobjidg[k-1] = 10000000000+(i+1)*1000000+2000+k
    endfor
    xx.objid = newobjidg         ; filling structure with new objids
    ;----------------------------------------------------------------------
    y = [y,xx]
    nrows += n_elements(xx)
    if (vb) then print, nrows," rows of data accumulated for this object"

  endif else begin
    ngood = ngood - 1
    print, 'WARNING: object ',objects[kk],' has only ',$
           n_elements(jz),' z-band epochs (or photometry accepted epochs), skipping...'
  endelse
  if (vb) then print, " "
endfor ; the end of the objects loop
; OK, y array is full - write out!
mwrfits, y, newtable, /create
print, 'PS1DOWNSAMPLE: ',n_elements(y),' epochs for ',ngood,' objects written to file.'

return
END