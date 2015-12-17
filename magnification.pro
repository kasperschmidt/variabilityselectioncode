;+
;----------------------------
;   NAME
;----------------------------
; magnification.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; This procedure estimates the amount of variability in a set of given objects,
; calculate the structure function of each individual object (optional) and fits that
; or the actual data to a power law via Markov Chain Monte Carlo.
; The results are written to various files which are summed up under 'OUTPUT'.
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; INFILE         : set infile=A string containing the name (and path) of the file to run
;                  the code on. 
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; NAMETAG        ; set NAMETAG=to some recognizable tag you want to use in the output
;                  filenames. If not set the infile name will be used.
; ERRORFLOOR     ; set ERRORFLOOR to 1 or 2 to add an error floor (see code for values)
;                  default is ERRORFLOOR=0 and means no floor set.
; MAG            : set MAG=0 to use PSF magnitudes (default)
;                      MAG=1 to use model magnitudes 
;                      MAG=2 to use de-reddened psf magnitudes
;                      MAG=3 to use de-reddened model magnitudes
;                      MAG=4 to use de-reddened fiber magnitudes
;                      MAG=5 to use de-reddened petrosian magnitudes
; VERBOSE        : set /VERBOSE to get (more) output printed to the screen
; NOBINNING      : set /NOBINNING to fit the powerlaw to the actual data pairs without
;                : binning in the structure function calculations
;----------------------------
;   OUTPUTS:
;----------------------------
; fileoutliers    ; Name of the file containing the objects characterized as outliers
; fileNONoutliers ; Name og the file containing the objects not characterized as outliers
; filestructure   : Name of the output fits file containing the values used and the
;                   result for the structure function calculations (only created if
;                   the NOBINNING keyword is not set).
; filecolor       : Name of the output ascii file containing the colors and deltaMjd
;                   of the data.
; filepowerlaw    ; Name of the output ascii file containing the characteristica of
;                   the power law fit to the data.
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; running file using a nametag for the output files, no binnging in the structure function
; estimates, which will be done with extinction corrected PSF magnitudes
; IDL> magnification,INFILE='inputdata.fits', NAMETAG='MyDataPSFmag',/VERBOSE,/NOBINNING,MAG=2
;----------------------------
;   BUGS
;----------------------------
;
;----------------------------
;   REVISION HISTORY
;----------------------------
; 2009-08-26  started by K. B. Schmidt (MPIA): Rewriting and compressing earlier code.
; 2009-09-29  de-reddened magnitudes added by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
@ bundlseparation.pro
@ defarr.pro
@ bundlplot_Dmagoutliers.pro
@ bundlplot_structurefctsNONout.pro
@ distinctentries.pro
;----------------------------
;-
PRO magnification,INFILE=INFILE,NAMETAG=NAMETAG,fileoutliers,fileNONoutliers,filestructure,filecolor, filepowerlaw,ERRORFLOOR=ERF, MAG=MAG,VERBOSE=VERBOSE,NOBINNING=NOBINNING

VB    = n_elements(VERBOSE)
NOBIN = n_elements(NOBINNING)

if vb eq 1 then begin
   print,':: magnification.pro ::       ----------------------------'
   print,':: magnification.pro ::          BEGIN MAGNIFICATION.PRO  '
   print,':: magnification.pro ::          ',systime(/UTC)
   print,':: magnification.pro ::       ----------------------------'
endif

if n_elements(ERRORFLOOR) eq 0 then ERF = 0
;setting default magnitudes to psf
if n_elements(MAG) eq 0 then MAG = 0

if n_elements(infile) eq 0 then begin  ;printing error if no file is given
   print,':: magnification.pro :: No input file specified - please specify one.'
   stop  ; stopping code...
endif else begin
   s=MRDFITS(infile,1)
   if VB eq 1 then print,':: magnification.pro :: read file: ',INFILE
endelse

if n_elements(NAMETAG) eq 0 then begin
   strp = STR_SEP(infile,'/')          ;splitting infile into path and filename
   name = strp(n_elements(strp)-1)
   TAG = STR_SEP(name,'.')             ;splitting filename into name and extenstion 
   NAMETAG = TAG(0)                    ;setting the name of the infile to NAMETAG
   if VB eq 1 then print,':: magnification.pro :: No NAMETAG set. Will use: ',NAMETAG
endif

sarr = size(s)
nlines = sarr(1)        ; the number of lines in fits file

; -----------------------------------------------
; ---DEFINING MAGNITUDE---
case MAG of
0: begin
if vb eq 1 then print,':: magnification.pro :: psf Magnitudes have been chosen (by default)'
defarr, nlines,s.psfMag_u,'float'       ,u0
defarr, nlines,s.psfMag_g,'float'       ,g0
defarr, nlines,s.psfMag_r,'float'       ,r0
defarr, nlines,s.psfMag_i,'float'       ,i0
defarr, nlines,s.psfMag_z,'float'       ,z0

defarr, nlines,s.psfMagerr_u,'float'    ,u0err
defarr, nlines,s.psfMagerr_g,'float'    ,g0err
defarr, nlines,s.psfMagerr_r,'float'    ,r0err
defarr, nlines,s.psfMagerr_i,'float'    ,i0err
defarr, nlines,s.psfMagerr_z,'float'    ,z0err
end
; -----------------------------------------------
1: begin
if vb eq 1 then print,':: magnification.pro :: model Magnitudes have been chosen'
defarr, nlines,s.modelMag_u,'float'       ,u0
defarr, nlines,s.modelMag_g,'float'       ,g0
defarr, nlines,s.modelMag_r,'float'       ,r0
defarr, nlines,s.modelMag_i,'float'       ,i0
defarr, nlines,s.modelMag_z,'float'       ,z0

defarr, nlines,s.modelMagerr_u,'float'    ,u0err
defarr, nlines,s.modelMagerr_g,'float'    ,g0err
defarr, nlines,s.modelMagerr_r,'float'    ,r0err
defarr, nlines,s.modelMagerr_i,'float'    ,i0err
defarr, nlines,s.modelMagerr_z,'float'    ,z0err
end
; ----------------------PSF-------------------------
2: begin
if vb eq 1 then print,':: magnification.pro :: de-reddened (extinction corrected) psf Magnitudes have been chosen'
defarr, nlines,s.psfMag_u,'float'       ,u0psf
defarr, nlines,s.psfMag_g,'float'       ,g0psf
defarr, nlines,s.psfMag_r,'float'       ,r0psf
defarr, nlines,s.psfMag_i,'float'       ,i0psf
defarr, nlines,s.psfMag_z,'float'       ,z0psf

defarr, nlines,s.deredPsfMag_u,'float'  ,u0
defarr, nlines,s.deredPsfMag_g,'float'  ,g0
defarr, nlines,s.deredPsfMag_r,'float'  ,r0
defarr, nlines,s.deredPsfMag_i,'float'  ,i0
defarr, nlines,s.deredPsfMag_z,'float'  ,z0

defarr, nlines,s.psfMagerr_u,'float'    ,u0errpsf
defarr, nlines,s.psfMagerr_g,'float'    ,g0errpsf
defarr, nlines,s.psfMagerr_r,'float'    ,r0errpsf
defarr, nlines,s.psfMagerr_i,'float'    ,i0errpsf
defarr, nlines,s.psfMagerr_z,'float'    ,z0errpsf

; getting the extinction of each entry (the deredPsfMag entries are calculated as psfMag_band - extinction_band)
ext_u = u0psf - u0
ext_g = g0psf - g0
ext_r = r0psf - r0
ext_i = i0psf - i0
ext_z = z0psf - z0

errfrac = 0.15 ; the fraction of the exctinction estimated to be it error acc. to Schlegel et al. (1998)

; caculating estimated errors on de-reddened magnitudes like in Richards et al 2002
u0err = sqrt( u0errpsf*u0errpsf + (errfrac*ext_u)*(errfrac*ext_u) )
g0err = sqrt( g0errpsf*g0errpsf + (errfrac*ext_g)*(errfrac*ext_g) )
r0err = sqrt( r0errpsf*r0errpsf + (errfrac*ext_r)*(errfrac*ext_r) )
i0err = sqrt( i0errpsf*i0errpsf + (errfrac*ext_i)*(errfrac*ext_i) )
z0err = sqrt( z0errpsf*z0errpsf + (errfrac*ext_z)*(errfrac*ext_z) )

;deallocating arrays again
u0psf = fltarr(1)
g0psf = fltarr(1)
r0psf = fltarr(1)
i0psf = fltarr(1)
z0psf = fltarr(1)
u0errpsf = fltarr(1)
g0errpsf = fltarr(1)
r0errpsf = fltarr(1)
i0errpsf = fltarr(1)
z0errpsf = fltarr(1)
ext_u = fltarr(1)
ext_g = fltarr(1)
ext_r = fltarr(1)
ext_i = fltarr(1)
ext_z = fltarr(1)
end
; --------------------MODEL---------------------------
3: begin
if vb eq 1 then print,':: magnification.pro :: Extinction corrected model magnitudes have been chosen'
; reading model magnitudes and errors
defarr, nlines,s.modelMag_u   ,'float'  ,u0mod
defarr, nlines,s.modelMag_g   ,'float'  ,g0mod
defarr, nlines,s.modelMag_r   ,'float'  ,r0mod
defarr, nlines,s.modelMag_i   ,'float'  ,i0mod
defarr, nlines,s.modelMag_z   ,'float'  ,z0mod
defarr, nlines,s.modelMagerr_u,'float'  ,u0moderr
defarr, nlines,s.modelMagerr_g,'float'  ,g0moderr
defarr, nlines,s.modelMagerr_r,'float'  ,r0moderr
defarr, nlines,s.modelMagerr_i,'float'  ,i0moderr
defarr, nlines,s.modelMagerr_z,'float'  ,z0moderr

; getting the extinction of each entry (the deredPsfMag entries are calculated as psfMag_band - extinction_band)
defarr, nlines,s.psfMag_u     ,'float'  ,u0psf
defarr, nlines,s.psfMag_g     ,'float'  ,g0psf
defarr, nlines,s.psfMag_r     ,'float'  ,r0psf
defarr, nlines,s.psfMag_i     ,'float'  ,i0psf
defarr, nlines,s.psfMag_z     ,'float'  ,z0psf
defarr, nlines,s.deredPsfMag_u,'float'  ,u0extpsf
defarr, nlines,s.deredPsfMag_g,'float'  ,g0extpsf
defarr, nlines,s.deredPsfMag_r,'float'  ,r0extpsf
defarr, nlines,s.deredPsfMag_i,'float'  ,i0extpsf
defarr, nlines,s.deredPsfMag_z,'float'  ,z0extpsf
ext_u = u0psf - u0extpsf
ext_g = g0psf - g0extpsf
ext_r = r0psf - r0extpsf
ext_i = i0psf - i0extpsf
ext_z = z0psf - z0extpsf

; calculating extinction corrected magnitude and errors
u0 = u0mod - ext_u
g0 = u0mod - ext_g
r0 = u0mod - ext_r
i0 = u0mod - ext_i
z0 = u0mod - ext_z

errfrac = 0.15 ; the fraction of the exctinction estimated to be its error according to Schlegel et al. (1998)
; caculating estimated errors on de-reddened magnitudes like in Richards et al 2002
u0err = sqrt( u0moderr*u0moderr + (errfrac*ext_u)*(errfrac*ext_u) )
g0err = sqrt( g0moderr*g0moderr + (errfrac*ext_g)*(errfrac*ext_g) )
r0err = sqrt( r0moderr*r0moderr + (errfrac*ext_r)*(errfrac*ext_r) )
i0err = sqrt( i0moderr*i0moderr + (errfrac*ext_i)*(errfrac*ext_i) )
z0err = sqrt( z0moderr*z0moderr + (errfrac*ext_z)*(errfrac*ext_z) )

;deallocating array memory
u0mod = fltarr(1)
g0mod = fltarr(1)
r0mod = fltarr(1)
i0mod = fltarr(1)
z0mod = fltarr(1)
u0moderr = fltarr(1)
g0moderr = fltarr(1)
r0moderr = fltarr(1)
i0moderr = fltarr(1)
z0moderr = fltarr(1)
u0psf = fltarr(1)
g0psf = fltarr(1)
r0psf = fltarr(1)
i0psf = fltarr(1)
z0psf = fltarr(1)
u0extpsf = fltarr(1)
g0extpsf = fltarr(1)
r0extpsf = fltarr(1)
i0extpsf = fltarr(1)
z0extpsf = fltarr(1)
ext_u = fltarr(1)
ext_g = fltarr(1)
ext_r = fltarr(1)
ext_i = fltarr(1)
ext_z = fltarr(1)

end
; ---------------------FIBER--------------------------
4: begin
if vb eq 1 then print,':: magnification.pro :: Extinction corrected fiber magnitudes have been chosen'
; reading fiber magnitudes and errors
defarr, nlines,s.fiberMag_u   ,'float'  ,u0fib
defarr, nlines,s.fiberMag_g   ,'float'  ,g0fib
defarr, nlines,s.fiberMag_r   ,'float'  ,r0fib
defarr, nlines,s.fiberMag_i   ,'float'  ,i0fib
defarr, nlines,s.fiberMag_z   ,'float'  ,z0fib
defarr, nlines,s.fiberMagerr_u,'float'  ,u0fiberr
defarr, nlines,s.fiberMagerr_g,'float'  ,g0fiberr
defarr, nlines,s.fiberMagerr_r,'float'  ,r0fiberr
defarr, nlines,s.fiberMagerr_i,'float'  ,i0fiberr
defarr, nlines,s.fiberMagerr_z,'float'  ,z0fiberr

; getting the extinction of each entry (the deredPsfMag entries are calculated as psfMag_band - extinction_band)
defarr, nlines,s.psfMag_u     ,'float'  ,u0psf
defarr, nlines,s.psfMag_g     ,'float'  ,g0psf
defarr, nlines,s.psfMag_r     ,'float'  ,r0psf
defarr, nlines,s.psfMag_i     ,'float'  ,i0psf
defarr, nlines,s.psfMag_z     ,'float'  ,z0psf
defarr, nlines,s.deredPsfMag_u,'float'  ,u0extpsf
defarr, nlines,s.deredPsfMag_g,'float'  ,g0extpsf
defarr, nlines,s.deredPsfMag_r,'float'  ,r0extpsf
defarr, nlines,s.deredPsfMag_i,'float'  ,i0extpsf
defarr, nlines,s.deredPsfMag_z,'float'  ,z0extpsf
ext_u = u0psf - u0extpsf
ext_g = g0psf - g0extpsf
ext_r = r0psf - r0extpsf
ext_i = i0psf - i0extpsf
ext_z = z0psf - z0extpsf

; calculating extinction corrected magnitude and errors
u0 = u0fib - ext_u
g0 = u0fib - ext_g
r0 = u0fib - ext_r
i0 = u0fib - ext_i
z0 = u0fib - ext_z

errfrac = 0.15 ; the fraction of the exctinction estimated to be its error according to Schlegel et al. (1998)
; caculating estimated errors on de-reddened magnitudes like in Richards et al 2002
u0err = sqrt( u0fiberr*u0fiberr + (errfrac*ext_u)*(errfrac*ext_u) )
g0err = sqrt( g0fiberr*g0fiberr + (errfrac*ext_g)*(errfrac*ext_g) )
r0err = sqrt( r0fiberr*r0fiberr + (errfrac*ext_r)*(errfrac*ext_r) )
i0err = sqrt( i0fiberr*i0fiberr + (errfrac*ext_i)*(errfrac*ext_i) )
z0err = sqrt( z0fiberr*z0fiberr + (errfrac*ext_z)*(errfrac*ext_z) )

;deallocating array memory
u0fib = fltarr(1)
g0fib = fltarr(1)
r0fib = fltarr(1)
i0fib = fltarr(1)
z0fib = fltarr(1)
u0fiberr = fltarr(1)
g0fiberr = fltarr(1)
r0fiberr = fltarr(1)
i0fiberr = fltarr(1)
z0fiberr = fltarr(1)
u0psf = fltarr(1)
g0psf = fltarr(1)
r0psf = fltarr(1)
i0psf = fltarr(1)
z0psf = fltarr(1)
u0extpsf = fltarr(1)
g0extpsf = fltarr(1)
r0extpsf = fltarr(1)
i0extpsf = fltarr(1)
z0extpsf = fltarr(1)
ext_u = fltarr(1)
ext_g = fltarr(1)
ext_r = fltarr(1)
ext_i = fltarr(1)
ext_z = fltarr(1)

end
; ---------------------PETROSIAN--------------------------
5: begin
if vb eq 1 then print,':: magnification.pro :: Extinction corrected petrosian magnitudes have been chosen'
; reading petrosian magnitudes and errors
defarr, nlines,s.petroMag_u   ,'float'  ,u0pet
defarr, nlines,s.petroMag_g   ,'float'  ,g0pet
defarr, nlines,s.petroMag_r   ,'float'  ,r0pet
defarr, nlines,s.petroMag_i   ,'float'  ,i0pet
defarr, nlines,s.petroMag_z   ,'float'  ,z0pet
defarr, nlines,s.petroMagerr_u,'float'  ,u0peterr
defarr, nlines,s.petroMagerr_g,'float'  ,g0peterr
defarr, nlines,s.petroMagerr_r,'float'  ,r0peterr
defarr, nlines,s.petroMagerr_i,'float'  ,i0peterr
defarr, nlines,s.petroMagerr_z,'float'  ,z0peterr

; getting the extinction of each entry (the deredPsfMag entries are calculated as psfMag_band - extinction_band)
defarr, nlines,s.psfMag_u     ,'float'  ,u0psf
defarr, nlines,s.psfMag_g     ,'float'  ,g0psf
defarr, nlines,s.psfMag_r     ,'float'  ,r0psf
defarr, nlines,s.psfMag_i     ,'float'  ,i0psf
defarr, nlines,s.psfMag_z     ,'float'  ,z0psf
defarr, nlines,s.deredPsfMag_u,'float'  ,u0extpsf
defarr, nlines,s.deredPsfMag_g,'float'  ,g0extpsf
defarr, nlines,s.deredPsfMag_r,'float'  ,r0extpsf
defarr, nlines,s.deredPsfMag_i,'float'  ,i0extpsf
defarr, nlines,s.deredPsfMag_z,'float'  ,z0extpsf
ext_u = u0psf - u0extpsf
ext_g = g0psf - g0extpsf
ext_r = r0psf - r0extpsf
ext_i = i0psf - i0extpsf
ext_z = z0psf - z0extpsf

; calculating extinction corrected magnitude and errors
u0 = u0pet - ext_u
g0 = u0pet - ext_g
r0 = u0pet - ext_r
i0 = u0pet - ext_i
z0 = u0pet - ext_z

errfrac = 0.15 ; the fraction of the exctinction estimated to be its error according to Schlegel et al. (1998)
; caculating estimated errors on de-reddened magnitudes like in Richards et al 2002
u0err = sqrt( u0peterr*u0peterr + (errfrac*ext_u)*(errfrac*ext_u) )
g0err = sqrt( g0peterr*g0peterr + (errfrac*ext_g)*(errfrac*ext_g) )
r0err = sqrt( r0peterr*r0peterr + (errfrac*ext_r)*(errfrac*ext_r) )
i0err = sqrt( i0peterr*i0peterr + (errfrac*ext_i)*(errfrac*ext_i) )
z0err = sqrt( z0peterr*z0peterr + (errfrac*ext_z)*(errfrac*ext_z) )

;deallocating array memory
u0pet = fltarr(1)
g0pet = fltarr(1)
r0pet = fltarr(1)
i0pet = fltarr(1)
z0pet = fltarr(1)
u0peterr = fltarr(1)
g0peterr = fltarr(1)
r0peterr = fltarr(1)
i0peterr = fltarr(1)
z0peterr = fltarr(1)
u0psf = fltarr(1)
g0psf = fltarr(1)
r0psf = fltarr(1)
i0psf = fltarr(1)
z0psf = fltarr(1)
u0extpsf = fltarr(1)
g0extpsf = fltarr(1)
r0extpsf = fltarr(1)
i0extpsf = fltarr(1)
z0extpsf = fltarr(1)
ext_u = fltarr(1)
ext_g = fltarr(1)
ext_r = fltarr(1)
ext_i = fltarr(1)
ext_z = fltarr(1)

end
endcase

; -----------------------------------------------
; ---DEFINING ARRAYS---
defarr, nlines,s.headobjid,'lonint'     ,headid
distinctentries,headid,'lonint'         ,headdistinct
defarr, nlines,s.objid,'lonint'         ,objid

;*60.d*60.0D
defarr, nlines,s.ra,'double' ,ra     ; converted from deg to arcsec
defarr, nlines,s.dec,'double',dec    ; converted from deg to arcsec

defarr, nlines,s.mjd_u,'float'          ,mjd_u
defarr, nlines,s.mjd_g,'float'          ,mjd_g
defarr, nlines,s.mjd_r,'float'          ,mjd_r
defarr, nlines,s.mjd_i,'float'          ,mjd_i
defarr, nlines,s.mjd_z,'float'          ,mjd_z

defarr, nlines,s.z,'double'              ,zspec

defarr, nlines,s.psfSigma1_u,'float'    ,spsf1_u
defarr, nlines,s.psfSigma1_g,'float'    ,spsf1_g
defarr, nlines,s.psfSigma1_r,'float'    ,spsf1_r
defarr, nlines,s.psfSigma1_i,'float'    ,spsf1_i
defarr, nlines,s.psfSigma1_z,'float'    ,spsf1_z

;if VB eq 1 then help,/mem
;deallocate memory from the structure
s = fltarr(1)
;if VB eq 1 then help,/mem

; -----------------------------------------------
; ---EXTRACTING REDSHIFTS zs ---
; creating vector with redshift for headdistinct (if value is -1 the
; spectroscopacly confirmed epoch have been removed by flagging), thus
; the 10th entry of zs correspond to the 10th entry of headdistinct
no = size(headdistinct)
loop = no(1)
zs = dblarr(loop)
for i=0l,loop-1 do begin
   xx = where(headdistinct(i) eq headid)
   zin = zspec(xx)
   zz = where(zin ne -1.,czz)
   if czz eq 0 then begin
      zs(i) = -1.
   endif else begin
      zs(i) = zin(zz(0))
   endelse
endfor
; -----------------------------------------------
; ---SDSS CALIBRATION ERROR FLOOR---
;    defining the mininum magnitude errors added as a
;    'calibration error floor' to the magnitude errors
case ERF of
0: begin
; -No error floor-
 u0err_min = 0.0
 g0err_min = 0.0
 r0err_min = 0.0
 i0err_min = 0.0
 z0err_min = 0.0
   end
1: begin
; -D.Mortlocks estimates-
 u0err_min = 0.0107
 g0err_min = 0.0216
 r0err_min = 0.0153
 i0err_min = 0.0178
 z0err_min = 0.0133
   end
2: begin
; -D.Mortlocks estimates-
 u0err_min = 0.03
 g0err_min = 0.03
 r0err_min = 0.03
 i0err_min = 0.03
 z0err_min = 0.03
   end
endcase

; ---DIVIDING DATA INTO BUNDLS---
bundlseparation,nlines,objids,headid,nobundl,bundlheads,bundlindex,bundlsize

; ---INVESTIGATING OUTLIERS---
bundlplot_Dmagoutliers,mjd_g,mjd_r,mjd_i,mjd_z,g0,r0,i0,z0,bundlindex,bundlsize,nobundl,spsf1_g,spsf1_r,spsf1_i,spsf1_z,g0err,r0err,i0err,z0err,objid,nametag,fileNONoutliers,fileoutliers;,/PLOT,MAGCUT=10.00

; ---STRUCTURE FUNCTION RESULTS FOR DATA WITH OUTLIERS REMOVED---
if NOBIN eq 0 then begin
   bundlplot_structurefctsNONout,fileoutliers,fileNONoutliers,nametag,objid,headid,u0,u0err,mjd_u,g0,g0err,mjd_g,r0,r0err,mjd_r,i0,i0err,mjd_i,z0,z0err,mjd_z,u0err_min,g0err_min,r0err_min,i0err_min,z0err_min,zs,ra,dec,filestructure,filecolor,filepowerlaw,headdistinct,/PWRLAWFILE,/VERBOSE,/NOCOLOR;,/WSTRUC
endif else begin
   bundlplot_structurefctsNONout,fileoutliers,fileNONoutliers,nametag,objid,headid,u0,u0err,mjd_u,g0,g0err,mjd_g,r0,r0err,mjd_r,i0,i0err,mjd_i,z0,z0err,mjd_z,u0err_min,g0err_min,r0err_min,i0err_min,z0err_min,zs,ra,dec,filestructure,filecolor,filepowerlaw,headdistinct,/PWRLAWFILE,/VERBOSE,/NOBINNING,/NOCOLOR;,/WSTRUC
endelse

if VB eq 1 then print,':: magnification.pro :: The following files were created using the input file:'
if VB eq 1 then print,'                        ',infile
if VB eq 1 then print,'                        ',fileNONoutliers
if VB eq 1 then print,'                        ',fileoutliers
if VB eq 1 then print,'                        ',filecolor
if VB eq 1 then print,'                        ',filestructure
if VB eq 1 then print,'                        ',filepowerlaw

if VB eq 1 then begin
   print,':: magnification.pro ::       ----------------------------'
   print,':: magnification.pro ::         END OF MAGNIFICATION.PRO  '
   print,':: magnification.pro ::         ',systime(/UTC)
   print,':: magnification.pro ::       ----------------------------'
endif
END
