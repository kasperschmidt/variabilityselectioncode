;+
;----------------------------
;   NAME
;----------------------------
; writecolors.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Routine taking 3 magnitudes as input and the vectors containing the
; entries to use in the calculations together with an bundle identifier (headid)
; and from that calculates the color terms and write them to a file
; with the correponding time differences and redsifts.
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; b1           : magnitude values 1
; b2           : magnitude values 2
; b3           : magnitude values 3
; ent1         : entries to use in calculations from the b1 vector
; ent2         : entries to use in calculations from the b2 vector
; ent3         : entries to use in calculations from the b3 vector
; headobjid    : Bundle identifier - a uniqe id that links objids together in bundles
; mjd1         : the mjd values correcponding to the b1 measurements
; mjd2         : the mjd values correcponding to the b2 measurements
; mjd3         : the mjd values correcponding to the b3 measurements
; z            : the redshift of each bundle (since they are the same objects at different
;                epochs only one redshift is needed)
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /VERBOSE     : set /VERBOSE to get comments printed to the screen
; /OUTNAME     : set OUTNAME='string_name' to manually set the output files name
;----------------------------
;   OUTPUTS:
;----------------------------
; outfile     : the name of the outputfile produced
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
; 2009-07-21  started by K. B. Schmidt (MPIA)
; 2009-08-28  Adding nametag by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
@ calc_colorterms.pro
;----------------------------
;-
PRO writecolors,b1,b2,b3,ent1,ent2,ent3,headobjid,mjd1,mjd2,mjd3,zall,nametag,outfile,VERBOSE=VERBOSE, OUTNAME=OUTNAME

vb = n_elements(VERBOSE)
ON = n_elements(OUTNAME)

date = systime(/UTC)        ; creating a string of the utc date (and time)

; creating the output file if not given manually on commandline
if ON eq 0 then begin
   path = 'idloutput/'
   outfile     = path+'colorterms_'+date+'_'+nametag+'.dat'
endif else begin
   outfile = outname
endelse
if VB eq 1 then print,':: writecolors.pro :: The color terms output file is: ',outfile 
; printing header to file
OPENW,66,outfile, WIDTH=300
printf,66,'###########################################################'
printf,66,'# Output from writecolors.pro (K.B. Schmidt (MPIA)) calculating '
printf,66,'# the delta-color-terms for a set of multi epoch data'
printf,66,'# This file was created on: ',date
printf,66,'# '
printf,66,'# The dValue simply means the difference between two epochs'
printf,66,'# i.e. dMjd is Mjd(epoch1)-Mjd(epoch2) and likewise for the'
printf,66,'# magnitudes and the colors.'
printf,66,'# Parenthesis give SDSS gri examples of output.'
printf,66,'###########################################################'
printf,66,'# --- Columns are: ---'
printf,66,'# 01: bundle number'
printf,66,'# 02: object redshift '
printf,66,'# 03: bundle object id '
printf,66,'# 04: dMjd band1 (g-band)'
printf,66,'# 05: dMjd band2 (r-band)'
printf,66,'# 06: dMjd band3 (i-band)'
printf,66,'# 07: dmag band1 (g-band) '
printf,66,'# 08: dmag band2 (r-band) '
printf,66,'# 09: dmag band3 (i-band) '
printf,66,'# 10: delta color band1-band2 (g-r)'
printf,66,'# 11: delta color band1-band3 (g-i)'
printf,66,'# 12: delta color band2-band3 (r-i)'
printf,66,'###########################################################'
;Defining the format to write in:
FMT='( F,F,i20,F,F,F,F,F,F,F,F,F)'
;getting unique headobjids (used when assigning redhift to the selected bundles
Uheads = headobjid(uniq(headobjid))

;==== CALCULATING THE b1-b2 COLOR ====
calc_colorterms,b1,b2,ent1,ent2,b1o12,b2o12,b1b2,entries12
svec12 = n_elements(entries12)
; creating (sub)vectors to be used in par calculations and written to bundles:
mjd112      = mjd1(entries12)
mjd212      = mjd2(entries12)
headobjid12 = headobjid(entries12)
; getting the headobjids (sorting - just in case)
heads12 = uniq(headobjid12(sort(headobjid12)))
Nb12      = n_elements(heads12)
if vb eq 1 then print,':: writecolors.pro :: found ',Nb12,' bundles to calculate band1-band2 colors for'
; resetting loop values
i = 0
m = 0
n = 0
; looping over bundles
for i=0l,Nb12-1 do begin
   ; getting redhsift for the i'th bundle
   zindex = where(Uheads eq headobjid12(heads12(i)))
   zhead = zall(zindex)

   zz = where(headobjid12 eq headobjid12(heads12(i)))
   ; counting epochs in the i'th bundle
   sbundle = n_elements(zz)
   ; getting the vectors containing the epochs for the i'th bundle
   b1zz    = b1o12(zz)
   b2zz    = b2o12(zz)
   b1b2zz  = b1b2(zz)
   mjd1zz  = mjd112(zz)
   mjd2zz  = mjd212(zz)
   ; looping over all the N(N-1)/2 pairs of data in the i'th bundle
   for m = 0l,sbundle-2 do begin                                    ;|
      for n = m+1l,sbundle-1 do begin                               ;|
         ; calculating the differences for each pair in the i'th bundle
         db112   = b1zz(m)-b1zz(n)
         db212   = b2zz(m)-b2zz(n)
         db1b2   = b1b2zz(m)-b1b2zz(n) 
         dmjd112 = mjd1zz(m)-mjd1zz(n)
         dmjd212 = mjd2zz(m)-mjd2zz(n)
         ;writing the data to the output file (the -9999 values means empty)
         printf,66,FORMAT=FMT,i+1,zhead,headobjid(heads12(i)),dmjd112,dmjd212,-9999,db112,db212,-9999,db1b2,-9999,-9999
      endfor                                                      ;|
   endfor                                                         ;|
endfor

;==== CALCULATING THE b1-b3 COLOR ====
calc_colorterms,b1,b3,ent1,ent3,b1o13,b3o13,b1b3,entries13
svec13 = n_elements(entries13)
; creating (sub)vectors to be used in par calculations and written to bundles:
mjd113      = mjd1(entries13)
mjd313      = mjd3(entries13)
headobjid13 = headobjid(entries13)
; getting the headobjids (sorting - just in case)
heads13 = uniq(headobjid13(sort(headobjid13)))
Nb13      = n_elements(heads13)
if vb eq 1 then print,':: writecolors.pro :: found ',Nb13,' bundles to calculate band1-band3 colors for'
; resetting loop values
i = 0
m = 0
n = 0
; looping over bundles
for i=0l,Nb13-1 do begin
   ; getting redhsift for the i'th bundle
   zindex = where(Uheads eq headobjid13(heads13(i)))
   zhead = zall(zindex)

   zz = where(headobjid13 eq headobjid13(heads13(i)))
   ; counting epochs in the i'th bundle
   sbundle = n_elements(zz)
   ; getting the vectors containing the epochs for the i'th bundle
   b1zz    = b1o13(zz)
   b3zz    = b3o13(zz)
   b1b3zz  = b1b3(zz)
   mjd1zz  = mjd113(zz)
   mjd3zz  = mjd313(zz)
   ; looping over all the N(N-1)/2 pairs of data in the i'th bundle
   for m = 0l,sbundle-2 do begin                                    ;|
      for n = m+1l,sbundle-1 do begin                               ;|
         ; calculating the differences for each pair in the i'th bundle
         db113   = b1zz(m)-b1zz(n)
         db313   = b3zz(m)-b3zz(n)
         db1b3   = b1b3zz(m)-b1b3zz(n) 
         dmjd113 = mjd1zz(m)-mjd1zz(n)
         dmjd313 = mjd3zz(m)-mjd3zz(n)
         ;writing the data to the output file (the -9999 values means empty)
         printf,66,FORMAT=FMT,i+1,zhead,headobjid(heads13(i)),dmjd113,-9999,dmjd313,db113,-9999,db313,-9999,db1b3,-9999
      endfor                                                      ;|
   endfor                                                         ;|
endfor

;==== CALCULATING THE b2-b3 COLOR ====
calc_colorterms,b2,b3,ent2,ent3,b2o23,b3o23,b2b3,entries23
svec23 = n_elements(entries23)
; creating (sub)vectors to be used in par calculations and written to bundles:
mjd223      = mjd2(entries23)
mjd323      = mjd3(entries23)
headobjid23 = headobjid(entries23)
; getting the headobjids (sorting - just in case)
heads23 = uniq(headobjid23(sort(headobjid23)))
Nb23      = n_elements(heads23)
if vb eq 1 then print,':: writecolors.pro :: found ',Nb23,' bundles to calculate band2-band3 colors for'
; resetting loop values
i = 0
m = 0
n = 0
; looping over bundles
for i=0l,Nb23-1 do begin
   ; getting redhsift for the i'th bundle
   zindex = where(Uheads eq headobjid23(heads23(i)))
   zhead = zall(zindex)

   zz = where(headobjid23 eq headobjid23(heads23(i)))
   ; counting epochs in the i'th bundle
   sbundle = n_elements(zz)
   ; getting the vectors containing the epochs for the i'th bundle
   b2zz    = b2o23(zz)
   b3zz    = b3o23(zz)
   b2b3zz  = b2b3(zz)
   mjd2zz  = mjd223(zz)
   mjd3zz  = mjd323(zz)
   ; looping over all the N(N-1)/2 pairs of data in the i'th bundle
   for m = 0l,sbundle-2 do begin                                    ;|
      for n = m+1l,sbundle-1 do begin                               ;|
         ; calculating the differences for each pair in the i'th bundle
         db223   = b2zz(m)-b2zz(n)
         db323   = b3zz(m)-b3zz(n)
         db2b3   = b2b3zz(m)-b2b3zz(n) 
         dmjd223 = mjd2zz(m)-mjd2zz(n)
         dmjd323 = mjd3zz(m)-mjd3zz(n)
         ;writing the data to the output file (the -9999 values means empty)
         printf,66,FORMAT=FMT,i+1,zhead,headobjid(heads23(i)),-9999,dmjd223,dmjd323,-9999,db223,db323,-9999,-9999,db2b3
      endfor                                                      ;|
   endfor                                                         ;|
endfor

CLOSE,66
END