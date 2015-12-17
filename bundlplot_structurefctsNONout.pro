;+
;----------------------------
;   NAME
;----------------------------
; bundlplot_structurefctsNONout.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure calculating the sturcture functions for the input data.
; Afterwards the structure function data is fitted to a power law via
; Markov Chain Monte Carlo
; Binning the structure function is optional.
; Files containing the fitted values for each object, the colors and
; the actual structure function values will be created if calculations done.
;----------------------------
;   COMMENTS
;----------------------------
; The code is designed to SDSS data and therefore needs 5 bands (ugriz) as input.
;----------------------------
;   INPUTS:
;----------------------------
; infileout            : The name of the outliers file to be used.
; infileNONout         : The name of the NONoutliers file to be used.
; nametag              : String with a name tag used in the output file names for easy recognition 
;                       (e.g. describing the input data in short)
; objid                : Vector containing unique ids for each epoch
; headid               : Vector with IDs tying epochs of the same object together in 'bundles' of data
; u0                   : magnitude values of 1st band (SDSS u)
; u0err                : errors on the 1st magnitude
; mjd_u                : observation mjd for the 1st band
; g0                   : magnitude values of 2nd band (SDSS g)
; g0err                : errors on the 2nd magnitude
; mjd_g                : observation mjd for the 2nd band
; r0                   : magnitude values of 3rd band (SDSS r)
; r0err                : errors on the 3rd magnitude
; mjd_r                : observation mjd for the 3rd band
; i0                   : magnitude values of 4th band (SDSS i)
; i0err                : errors on the 4th magnitude
; mjd_i                : observation mjd for the 4th band
; z0                   : magnitude values of 5th band (SDSS z)
; z0err                : errors on the 5th magnitude
; mjd_z                : observation mjd for the 5h band
; u0err_min            : value of a possible error flor on the 1st magnitude (set to 0.0 if not present)
; g0err_min            : value of a possible error flor on the 2nd magnitude (set to 0.0 if not present)
; r0err_min            : value of a possible error flor on the 3rd magnitude (set to 0.0 if not present)
; i0err_min            : value of a possible error flor on the 4th magnitude (set to 0.0 if not present)
; z0err_min            : value of a possible error flor on the 5th magnitude (set to 0.0 if not present)
; zs                   : redshift of input objects (1 redshift per object, i.e. size(vector)=#objects)
; ra                   : the ra of each observation
; dec                  : the dec of each observation
; headdistinct         : vector containing the unique IDs from headid (one per object)
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /WSTRUC              : set the keyword /WSTRUC to write structure function arrays to .fits file
; /PWRLAWFILE          : set /PWRLAWFILE to create an output file (filepowerlaw) containing the
;                        power law fit values and charateristica
; /NOBINNING           : set this keyword to skip the binning step in the structure function
;                        calculations and fit the power law to the actual data pairs
; /VERBOSE             : set /VERBOSE to get messages printed on the screen (recommended since
;                        the calculations might take a while, so you can follow along and see
;                        it is still running)
; /NOCOLOR             : set /NOCOLOR if you want to skip the step where the color file is created
;                        (usefull when testing or running fast since this step takes quite some time)
;----------------------------
;   OUTPUTS:
;----------------------------
; filestructure        : Name of output file containing the structure function data
; filecolor            : Name of output file containing the color terms calculated
; filepowerlaw         : Name of output file containing the power law fit characteristica
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; creating fit to structure functions and writing all possible files
; IDL> bundlplot_structurefctsNONout,infileout,infileNONout,nametag,objid,headid,u0,u0err,mjd_u,g0,g0err,mjd_g,r0,r0err,mjd_r, i0,i0err,mjd_i,z0,z0err,mjd_z,u0err_min,g0err_min, r0err_min,i0err_min,z0err_min,zs,ra,dec,filestructure,filecolor,filepowerlaw,headdistinct,/WSTRUC,/PWRLAWFILE,/VERBOSE
;----------------------------
;   BUGS
;----------------------------
;
;----------------------------
;   REVISION HISTORY
;----------------------------
; 2009-08-27  started by K. B. Schmidt (MPIA) - by modyfying/rewriting earlier version
; 2009-09-14  Nobinning calculations added by K. B. Schmidt (MPIA)
; 2009-09-22  zNONx and HeadNONx vectors and output in powerlaw file formatted + extra
;             column with headobjIDs added by K. B. Schmidt
;----------------------------
;   DEPENDENCIES
;----------------------------
@ extractSubvector.pro
@ writecolors.pro
@ bundlmean.pro
@ powerlawmcmc.pro
@ nobin_datastruc.pro
;----------------------------
PRO bundlplot_structurefctsNONout,infileout,infileNONout,nametag,objid,headid,u0,u0err,mjd_u,g0,g0err,mjd_g,r0,r0err,mjd_r, i0,i0err,mjd_i,z0,z0err,mjd_z,u0err_min,g0err_min, r0err_min,i0err_min,z0err_min,zs,ra,dec,filestructure,filecolor,filepowerlaw,headdistinct,WSTRUC=WSTRUC,PWRLAWFILE=PWRLAWFILE,NOBINNING=NOBINNING,VERBOSE=VERBOSE,NOCOLOR=NOCOLOR

;setting keywords
WS       = n_elements(WSTRUC)
PW       = n_elements(PWRLAWFILE)
NOBIN    = n_elements(NOBINNING)
VB       = n_elements(VERBOSE)
NC       = n_elements(NOCOLOR)

;defining files
file1   = infileout
file2   = infileNONout
;----defining format for readcol
FMT='f,f,f,f,f,f,f,f,along'
;----reading data into vectors
if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 01 ',systime(/UTC)
readcol,file1,FORMAT=FMT,bundlnoOUT,bandOUT,mjdOUT,obsnoOUT,deltamagOUT,magOUT,magerrOUT,seeingOUT,objidOUT
datalinesOUT = n_elements(bundlnoOUT)

if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 02 ',systime(/UTC)
readcol,file2,FORMAT=FMT,bundlnoNON,bandNON,mjdNON,obsnoNON,deltamagNON,magNON,magerrNON,seeingNON,objidNON
datalinesNON = n_elements(bundlnoNON)

if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 03 ',systime(/UTC)
; getting the outliers in each band
gOUT = where(bandOUT eq 2,cg)
rOUT = where(bandOUT eq 3,cr)
iOUT = where(bandOUT eq 4,ci)
zOUT = where(bandOUT eq 5,cz)

; ---EXTRACTING OUTLIERS FROM DATA
if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 04 ',systime(/UTC)
extractSubvector,objid,objidout(gOUT),NONobjidg,NONentriesg;,/VERBOSE
extractSubvector,objid,objidout(rOUT),NONobjidr,NONentriesr;,/VERBOSE
extractSubvector,objid,objidout(iOUT),NONobjidi,NONentriesi;,/VERBOSE
extractSubvector,objid,objidout(zOUT),NONobjidz,NONentriesz;,/VERBOSE
if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 05 ',systime(/UTC)

if NC eq 0 then begin
   ;=================================================================================
   ;   Calculating color terms (where band1 and band2 are NONoutliers)
   writecolors,g0,r0,i0,NONentriesg,NONentriesr,NONentriesi,headid,mjd_g,mjd_r,mjd_i,zs,nametag,filecolor;,/VERBOSE;,OUTNAME='colorstest.dat'
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: writecolors.pro just created: ',filecolor
   ;=================================================================================
endif else begin
   filecolor = 'no color file created'
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: Keyword /NOCOLOR set so no color file written'
endelse

if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 06 ',systime(/UTC)
; --- CREATING BUNDLES ---
; --- g-band
sNONg = size(NONobjidg)
bundlseparation, sNONg(1),NONobjidg,headid(NONentriesg),nobundlg,bundlheadsg,bundlindexg,bundlsizeg
; --- r-band
sNONr = size(NONobjidr)
bundlseparation, sNONr(1),NONobjidr,headid(NONentriesr),nobundlr,bundlheadsr,bundlindexr,bundlsizer
; --- i-band
sNONi = size(NONobjidi)
bundlseparation, sNONi(1),NONobjidi,headid(NONentriesi),nobundli,bundlheadsi,bundlindexi,bundlsizei
; --- z-band
sNONz = size(NONobjidz)
bundlseparation, sNONz(1),NONobjidz,headid(NONentriesz),nobundlz,bundlheadsz,bundlindexz,bundlsizez

; ---CALCULATING THE STRUCTURE FUNCTION(S)---
;calculating binned structure functions (default)
if NOBIN eq 0 then begin
   ;=================
   ;==== g band =====
   ;=================
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 06.1 STRFCT ',systime(/UTC)
   structurefctSTR, g0(NONentriesg),g0err(NONentriesg),g0err_min,bundlsizeg,nobundlg,mjd_g(NONentriesg),strufctSTRarr_g,strufctnewSTRarr_g,sortresSTRarr_g
   ;=================
   ;==== r band =====
   ;=================
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 06.2 STRFCT ',systime(/UTC)
   structurefctSTR, r0(NONentriesr),r0err(NONentriesr),r0err_min,bundlsizer,nobundlr,mjd_r(NONentriesr),strufctSTRarr_r,strufctnewSTRarr_r,sortresSTRarr_r
   ;=================
   ;==== i band =====
   ;=================
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 06.3 STRFCT ',systime(/UTC)
   structurefctSTR, i0(NONentriesi),i0err(NONentriesi),i0err_min,bundlsizei,nobundli,mjd_i(NONentriesi),strufctSTRarr_i,strufctnewSTRarr_i,sortresSTRarr_i
   ;=================
   ;==== z band =====
   ;=================
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 06.4 STRFCT ',systime(/UTC)
   structurefctSTR, z0(NONentriesz),z0err(NONentriesz),z0err_min,bundlsizez,nobundlz,mjd_z(NONentriesz),strufctSTRarr_z,strufctnewSTRarr_z,sortresSTRarr_z
endif else begin
   ; ---CREATING DATA STRUCTURE FOR NOBINNING CASE---
   ;=================
   ;==== g band =====
   ;=================
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 06.1 NOBIN ',systime(/UTC)
   nobin_datastruc,mjd_g(NONentriesg),g0(NONentriesg),g0err(NONentriesg),nobundlg,bundlindexg,bundlsizeg,strufctnewSTRarr_g
   ;=================
   ;==== r band =====
   ;=================
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 06.2 NOBIN ',systime(/UTC)
   nobin_datastruc,mjd_r(NONentriesr),r0(NONentriesr),r0err(NONentriesr),nobundlr,bundlindexr,bundlsizer,strufctnewSTRarr_r
   ;=================
   ;==== i band =====
   ;=================
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 06.3 NOBIN ',systime(/UTC)
   nobin_datastruc,mjd_i(NONentriesi),i0(NONentriesi),i0err(NONentriesi),nobundli,bundlindexi,bundlsizei,strufctnewSTRarr_i
   ;=================
   ;==== z band =====
   ;=================
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 06.4 NOBIN ',systime(/UTC)
   nobin_datastruc,mjd_z(NONentriesz),z0(NONentriesz),z0err(NONentriesz),nobundlz,bundlindexz,bundlsizez,strufctnewSTRarr_z
endelse
;=================================================================================
if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 08 ',systime(/UTC)
nobundlu = nobundlg
;===========================
if nobundlg ne nobundlu OR nobundlg ne nobundlr OR nobundlg ne nobundli OR nobundlg ne nobundlz then begin
   print,' '
   print,'====================================================================='
   print,':: bundlplot_structurefctsNONout.pro :: ERROR : The no. of bundles are'
   print,'                                        different for the different bands' 
   print,'    ERROR                               -but they should be the same!!'
   print,'                                      # bundles in u band = ',nobundlu
   print,'              ERROR                   # bundles in g band = ',nobundlg
   print,'                                      # bundles in r band = ',nobundlr
   print,'                        ERROR         # bundles in i band = ',nobundli
   print,'                                      # bundles in z band = ',nobundlz
   print,'====================================================================='
   print,' ' 
endif

bundles = [nobundlu,nobundlg,nobundlr,nobundli,nobundlz]
nobundl = max(bundles)   ; but doesn't matter since they should all be the same
if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 09 ',systime(/UTC)
;=================================================================================
;   Writing the structure function data to file if the keyword /WSTRUC is set
;=================================================================================
if WS eq 1 and NOBIN eq 0 then begin
   date = systime(/UTC)        ; creating a string of the utc date (and time)
   ;defining table name for output ( outside loop so it can also be used without /WSTRUC set)
   filestructure = 'idloutput/structurefunctionvalues_'+date+'_'+nametag+'.fits'
   ;getting the number of bins and magnitude pairs used in the structure function calculations
   sizestr   = size(strufctnewSTRarr_i.dt) ;the same for all bands
   sizeres_g = size(sortresSTRarr_g.DMJD)
   sizeres_r = size(sortresSTRarr_r.DMJD)
   sizeres_i = size(sortresSTRarr_i.DMJD)
   sizeres_z = size(sortresSTRarr_z.DMJD)
   ; vector with object numbers (1 to nobundl)
   obj = fltarr(nobundl)
   for i=0l,nobundl-1 do begin
      obj(i)=i+1.0
   endfor
   ;---DEFINING A STRUCTURE WITH THE COLUMNS OF THE FITS FILE---
   str={object:0.0d,specz:0.0d, dt_g:fltarr(sizestr(1)),value_g:fltarr(sizestr(1)),err_g:fltarr(sizestr(1)),dMJD_g:fltarr(sizeres_g(1)),dMag_g:fltarr(sizeres_g(1)),dmagerr2_g:fltarr(sizeres_g(1)),dSFvalue_g:fltarr(sizeres_g(1)), dt_r:fltarr(sizestr(1)),value_r:fltarr(sizestr(1)),err_r:fltarr(sizestr(1)),dMJD_r:fltarr(sizeres_r(1)),dMag_r:fltarr(sizeres_r(1)),dmagerr2_r:fltarr(sizeres_r(1)),dSFvalue_r:fltarr(sizeres_r(1)), dt_i:fltarr(sizestr(1)),value_i:fltarr(sizestr(1)),err_i:fltarr(sizestr(1)),dMJD_i:fltarr(sizeres_i(1)),dMag_i:fltarr(sizeres_i(1)),dmagerr2_i:fltarr(sizeres_i(1)),dSFvalue_i:fltarr(sizeres_i(1)), dt_z:fltarr(sizestr(1)),value_z:fltarr(sizestr(1)),err_z:fltarr(sizestr(1)),dMJD_z:fltarr(sizeres_z(1)),dMaz_z:fltarr(sizeres_z(1)),dmazerr2_z:fltarr(sizeres_z(1)),dSFvalue_z:fltarr(sizeres_z(1))}

   str = replicate(str,nobundl)
   ;---FILLING THE ARRAY WITH DATA---
   str.object       = obj(*)
   str.specz        = zs(*)
   ; G band
   str.dt_g         = strufctnewSTRarr_g(*).dt(*)
   str.value_g      = strufctnewSTRarr_g(*).value(*)
   str.err_g        = strufctnewSTRarr_g(*).valueerr(*)
   str.dMJD_g       = sortresSTRarr_g(*).dMJD(*)
   str.dMag_g       = sortresSTRarr_g(*).dV(*)
   str.dmagerr2_g   = sortresSTRarr_g(*).dverr2(*)
   str.dSFvalue_g   = sortresSTRarr_g(*).dstrucnew(*)
   ; R band
   str.dt_r         = strufctnewSTRarr_r(*).dt(*)
   str.value_r      = strufctnewSTRarr_r(*).value(*)
   str.err_r        = strufctnewSTRarr_r(*).valueerr(*)
   str.dMJD_r       = sortresSTRarr_r(*).dMJD(*)
   str.dMag_r       = sortresSTRarr_r(*).dV(*)
   str.dmagerr2_r   = sortresSTRarr_r(*).dverr2(*)
   str.dSFvalue_r   = sortresSTRarr_r(*).dstrucnew(*)
   ; I band
   str.dt_i         = strufctnewSTRarr_i(*).dt(*)
   str.value_i      = strufctnewSTRarr_i(*).value(*)
   str.err_i        = strufctnewSTRarr_i(*).valueerr(*)
   str.dMJD_i       = sortresSTRarr_i(*).dMJD(*)
   str.dMag_i       = sortresSTRarr_i(*).dV(*)
   str.dmagerr2_i   = sortresSTRarr_i(*).dverr2(*)
   str.dSFvalue_i   = sortresSTRarr_i(*).dstrucnew(*)
   ; Z band
   str.dt_z         = strufctnewSTRarr_z(*).dt(*)
   str.value_z      = strufctnewSTRarr_z(*).value(*)
   str.err_z        = strufctnewSTRarr_z(*).valueerr(*)
   str.dMJD_z       = sortresSTRarr_z(*).dMJD(*)
   str.dMaz_z       = sortresSTRarr_z(*).dV(*)
   str.dmazerr2_z   = sortresSTRarr_z(*).dverr2(*)
   str.dSFvalue_z   = sortresSTRarr_z(*).dstrucnew(*)
   ;---WRITING THE STRUCTURE TO A FITSFILE---
   mwrfits, str, filestructure, /create
   ;---PRINTING EACH ENTRY IN THE STRUCTURE---
   help,str,/struc
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: Wrote structure function data to file:',filestructure
   print,' ' 
endif

if WS eq 1 and NOBIN eq 1 then begin
   date = systime(/UTC)        ; creating a string of the utc date (and time)
   ;defining table name for output ( outside loop so it can also be used without /WSTRUC set)
   filestructure = 'idloutput/structurefunctionvalues_'+date+'_'+nametag+'_NOBIN.fits'
   ;getting the number of bins and magnitude pairs used in the structure function calculations
   sizestrg   = size(strufctnewSTRarr_g.dt)
   sizestrr   = size(strufctnewSTRarr_r.dt)
   sizestri   = size(strufctnewSTRarr_i.dt)
   sizestrz   = size(strufctnewSTRarr_z.dt)
   ; vector with object numbers (1 to nobundl)
   obj = fltarr(nobundl)
   for i=0l,nobundl-1 do begin
      obj(i)=i+1.0
   endfor
   ;---DEFINING A STRUCTURE WITH THE COLUMNS OF THE FITS FILE---
   str={object:0.0d,specz:0.0d, dt_g:fltarr(sizestrg(1)),value_g:fltarr(sizestrg(1)),err_g:fltarr(sizestrg(1)), dt_r:fltarr(sizestrr(1)),value_r:fltarr(sizestrr(1)),err_r:fltarr(sizestrr(1)), dt_i:fltarr(sizestri(1)),value_i:fltarr(sizestri(1)),err_i:fltarr(sizestri(1)), dt_z:fltarr(sizestrz(1)),value_z:fltarr(sizestrz(1)),err_z:fltarr(sizestrz(1))}

   str = replicate(str,nobundl)
   ;---FILLING THE ARRAY WITH DATA---
   str.object       = obj(*)
   str.specz        = zs(*)
   ; G band
   str.dt_g         = strufctnewSTRarr_g(*).dt(*)
   str.value_g      = strufctnewSTRarr_g(*).value(*)
   str.err_g        = strufctnewSTRarr_g(*).valueerr(*)
   ; R band
   str.dt_r         = strufctnewSTRarr_r(*).dt(*)
   str.value_r      = strufctnewSTRarr_r(*).value(*)
   str.err_r        = strufctnewSTRarr_r(*).valueerr(*)
   ; I band
   str.dt_i         = strufctnewSTRarr_i(*).dt(*)
   str.value_i      = strufctnewSTRarr_i(*).value(*)
   str.err_i        = strufctnewSTRarr_i(*).valueerr(*)
   ; Z band
   str.dt_z         = strufctnewSTRarr_z(*).dt(*)
   str.value_z      = strufctnewSTRarr_z(*).value(*)
   str.err_z        = strufctnewSTRarr_z(*).valueerr(*)
   ;---WRITING THE STRUCTURE TO A FITSFILE---
   mwrfits, str, filestructure, /create
   ;---PRINTING EACH ENTRY IN THE STRUCTURE---
   help,str,/struc
   if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: Wrote structure function data to file:',filestructure
   print,' ' 
endif

if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 10 ',systime(/UTC)

;=================================================================================
;            Fitting power laws to the calculated structure functions
;=================================================================================
if NOBIN eq 0 then powerlawmcmc,strufctnewSTRarr_g,nobundl,fitresultg,Ag,gammag ;  , /PLOT  ;,/VERBOSE
if NOBIN eq 1 then powerlawmcmc,strufctnewSTRarr_g,nobundl,fitresultg,Ag,gammag,/NOBINNING ;  , /PLOT
if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 11 ',systime(/UTC)

if NOBIN eq 0 then powerlawmcmc,strufctnewSTRarr_r,nobundl,fitresultr,Ar,gammar  ;  ,/PLOT ;,/VERBOSE
if NOBIN eq 1 then powerlawmcmc,strufctnewSTRarr_r,nobundl,fitresultr,Ar,gammar,/NOBINNING ;  , /PLOT
if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 12 ',systime(/UTC)

if NOBIN eq 0 then powerlawmcmc,strufctnewSTRarr_i,nobundl,fitresulti,Ai,gammai ;  , /PLOT  ;,/VERBOSE
if NOBIN eq 1 then powerlawmcmc,strufctnewSTRarr_i,nobundl,fitresulti,Ai,gammai,/NOBINNING ;  , /PLOT
if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 13 ',systime(/UTC)

if NOBIN eq 0 then powerlawmcmc,strufctnewSTRarr_z,nobundl,fitresultz,Az,gammaz ;  , /PLOT  ;,/VERBOSE
if NOBIN eq 1 then powerlawmcmc,strufctnewSTRarr_z,nobundl,fitresultz,Az,gammaz,/NOBINNING ;  , /PLOT
if VB eq 1 then print,':: bundlplot_structurefctNONout.pro :: here 14 ',systime(/UTC)

;============================================================================
;                        WRITING POWER LAW FITS TO FILE
;============================================================================
; Creating a file to which the mean magnitude, mean error, structure function
; fit parameters, redshifts etc. is written for all the
; objects. This file can then be used to futher investigate possible relations
; between the variability and the other characteristica of the objects.
if PW eq 1 then begin
; Opening the file where all the relevant info for the outliers is written to
date = systime(/UTC)        ; creating a string of the utc date (and time)
path = 'idloutput/'
if NOBIN eq 0 then filepowerlaw = path+'powerlawfit_characteristica_'+date+'_'+nametag+'.dat'
if NOBIN eq 1 then filepowerlaw = path+'powerlawfit_characteristica_'+date+'_'+nametag+'_NOBIN.dat'
OPENW,22,filepowerlaw, WIDTH=600
printf,22,'###########################################################'
printf,22,'# Output from power law MCMC fits to object structure functions'
printf,22,'# Created on: ',date
printf,22,'# '
printf,22,'# The function fitted to is: A*x^gamma '
printf,22,'# it is fitted via Markov Chain Monte Carlo by optimizing the' 
printf,22,'# probability of the (gamma,A)-space positions ' 
printf,22,'# Refer to K. B. Schmidt et al 2010 for further information about the MCMC'
printf,22,'###########################################################'
printf,22,'# --- Columns are: ---'
printf,22,'# 01: bundle number'
printf,22,'# 02: bands (1=u, 2=g, 3=r, 4=i and 5=z) '
printf,22,'# 03: object redshift (redshift = -1 -> no specz (cut by flags)) '
printf,22,'# 04: RA mean value '
printf,22,'# 05: DEC mean value '
printf,22,'# 06: Magnitude mean value of current band (see column 17-21 for mean values of individual bands '

printf,22,'# 07: A0       (best-fit sample A) '
printf,22,'# 08: medianA  (median sample A)'
printf,22,'# 09: Aerrplus (upper 68% confidence limit) '
printf,22,'# 10: Aerrminus (lower 68% confidence limit)'
printf,22,'# 11: gamma0       (best-fit sample gamma)'
printf,22,'# 12: mediangamma  (median sample gamma)'
printf,22,'# 13: gammaerrplus (upper 68% confidence limit)'
printf,22,'# 14: gammaerrminus (lower 68% confidence limit)'
printf,22,'# 15: The minimum reduced chi-squared value of the fit'
printf,22,'# 16: Number of samples taken during fit'
printf,22,'# 17: Mean u magnitude of object (-1 means not calculated)'
printf,22,'# 18: Mean g magnitude of object (-1 means not calculated)'
printf,22,'# 19: Mean r magnitude of object (-1 means not calculated)'
printf,22,'# 20: Mean i magnitude of object (-1 means not calculated)'
printf,22,'# 21: Mean z magnitude of object (-1 means not calculated)'
printf,22,'# 22: The object id for the object (head of bundle) which the z correpsonds to'
printf,22,'###########################################################'


; ---CALCULATING MEAN VALUES FOR DATA WITHOUT OUTLIERS---
; calculated from all the values of magnitudes which are not outliers in the given band
; thus the claculations is meaning over all the values for a given band, which have not
; been removed by the outlier-removal routine
bundlmean, 'double',bundlindexg,ra(NONentriesg)       ,gra
bundlmean, 'double',bundlindexg,dec(NONentriesg)      ,gdec
bundlmean, 'float',bundlindexg,g0(NONentriesg)        ,gmean

bundlmean, 'double',bundlindexr,ra(NONentriesr)       ,rra
bundlmean, 'double',bundlindexr,dec(NONentriesr)      ,rdec
bundlmean, 'float',bundlindexr,r0(NONentriesr)        ,rmean

bundlmean, 'double',bundlindexi,ra(NONentriesi)       ,ira
bundlmean, 'double',bundlindexi,dec(NONentriesi)      ,idec
bundlmean, 'float',bundlindexi,i0(NONentriesi)        ,imean

bundlmean, 'double',bundlindexz,ra(NONentriesz)       ,zra
bundlmean, 'double',bundlindexz,dec(NONentriesz)      ,zdec
bundlmean, 'float',bundlindexz,z0(NONentriesz)        ,zmean

;format for output written
FMT='(i,i,d,d,d,16f20.7,i)'   ; 16f20.7 means 16 times float with 20 digits (one of which is an eventual dot) with 7 decimals

for i=0l,nobundl-1 do begin
   ;--- writing g band data
   printf,FORMAT=FMT,22,i+1,2,zs(i),gra(i),gdec(i),gmean(i),fitresultg(i,0),fitresultg(i,1),fitresultg(i,2),fitresultg(i,3),fitresultg(i,4),fitresultg(i,5),fitresultg(i,6),fitresultg(i,7),fitresultg(i,8),fitresultg(i,9),-1,gmean(i),rmean(i),imean(i),zmean(i),headdistinct(i)

   ;--- writing r band data
   printf,FORMAT=FMT,22,i+1,3,zs(i),rra(i),rdec(i),rmean(i),fitresultr(i,0),fitresultr(i,1),fitresultr(i,2),fitresultr(i,3),fitresultr(i,4),fitresultr(i,5),fitresultr(i,6),fitresultr(i,7),fitresultr(i,8),fitresultr(i,9),-1,gmean(i),rmean(i),imean(i),zmean(i),headdistinct(i)

   ;--- writing i band data
   printf,FORMAT=FMT,22,i+1,4,zs(i),ira(i),idec(i),imean(i),fitresulti(i,0),fitresulti(i,1),fitresulti(i,2),fitresulti(i,3),fitresulti(i,4),fitresulti(i,5),fitresulti(i,6),fitresulti(i,7),fitresulti(i,8),fitresulti(i,9),-1,gmean(i),rmean(i),imean(i),zmean(i),headdistinct(i)

   ;--- writinz z band data
   printf,FORMAT=FMT,22,i+1,5,zs(i),zra(i),zdec(i),zmean(i),fitresultz(i,0),fitresultz(i,1),fitresultz(i,2),fitresultz(i,3),fitresultz(i,4),fitresultz(i,5),fitresultz(i,6),fitresultz(i,7),fitresultz(i,8),fitresultz(i,9),-1,gmean(i),rmean(i),imean(i),zmean(i),headdistinct(i)
endfor

CLOSE,22
if VB eq 1 then print,':: bundlplot_structurefctsNONout :: Wrote power law fit data to:',filepowerlaw
endif

If WS eq 0 then filestructure = 'no structure function data file written'
If PW eq 0 then filepowerlaw  = 'no power law data file written'

Print,'---END OF PROGRAM',' @ ',systime(/UTC),'---'

;============================================================================
;============================================================================
END
