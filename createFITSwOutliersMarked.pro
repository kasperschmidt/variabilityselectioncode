;+
;----------------------------
;   NAME
;----------------------------
; createFITSwOutliersMarked.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure setting all the values defined as outliers (given in a seperate ascii file) 
; from a fits table to the value of -9999 so that they are easy recognisable.
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; FITSin           : string and path of the input fitstable from which one wants
;                    to remove the outliers
; Outliers         : the name and path of the file containing the outliers of the FITSin
;                    file as determined from bundlplot_Dmagoutliers.pro
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /VERBOSE         : set /VERBOSE to get info/messages printed to the screen
;----------------------------
;   OUTPUTS:
;----------------------------
; FITSout          : The new FITS file where the outliers have been removed
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; sesar RRL
; IDL> createFITSwOutliersMarked,'/path/of/file/data.fits','/path/of/ouliers/file/outliersdata.dat',FITSout,/VERBOSE
; The QSO file w deredmag
; IDL> createFITSwOutliersMarked,'/Users/kasperborelloschmidt/work/casjobs_SDSS/fits/QSOs/DR5qcat_s82_photo_FieldModelANDDered_sorted.fit','/Users/kasperborelloschmidt/work/casjobs_SDSS/fits/QSOs/outliers_cut0p25_Tue Feb  2 09:36:28 2010_QSOsALL_NOwstruc.dat',FITSout,/VERBOSE
;----------------------------
;   BUGS
;----------------------------
;
; The error statement that there are more than one outlier for each
; objid is also printed if the same object with the same outliers occurs
; multiple times in the data file, as might be the case for any files
; created using the SQL keyword 'top'
;
;----------------------------
;   REVISION HISTORY
;----------------------------
; 2010-02-01  started by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
@ namedate.pro
;----------------------------
;-
PRO createFITSwOutliersMarked,FITSin,Outliers,FITSout,VERBOSE=VERBOSE

VB = n_elements(VERBOSE)

Fin = MRDFITS(FITSin,1)                                 ; reading FITSin file
objects = Fin(uniq(Fin.headobjid)).headobjid              ; getting bundle head IDs
lines = n_elements(Fin.objid)                           ; the number of lines in the Fits table

FMT2 = 'f,f,f,f,f,f,f,f,O'                              ; setting format of outliers file
readcol,Outliers,FORMAT=FMT2,o1,o2,o3,o4,o5,o6,o7,o8,o9 ; reading outliers

for i=0L,lines-1 do begin                               ; looping over all lines
   objidfits = Fin[i].objid                             ; the ID of the i'th epoch
   HeadID    = Fin[i].Headobjid                         ; the HeadID of the ith epoch

   ;------------------ u-band outliers ------------------
   outlier_u = where(o2 eq 1 and o9 eq objidfits, cOUT) ; getting any u-band outliers
   if cOUT gt 1 then begin                              ; print error if more than one outlier for i'th epoch
       print,':: createFITSwOutliersMarked.pro :: ERROR! There are more than one outlier in the u-band'
       print,'                                    for the epoch ID ',strtrim(objidfits,1),' of the Headobjid ',strtrim(headid,1)
   endif
   if outlier_u ne [-1] then Fin[i].PSFmag_u = -9999.    ; if any set PSF value to -9999

   ;------------------ g-band outliers ------------------
   outlier_g = where(o2 eq 2 and o9 eq objidfits, cOUT) ; getting any u-band outliers
   if cOUT gt 1 then begin                              ; print error if more than one outlier for i'th epoch
       print,':: createFITSwOutliersMarked.pro :: ERROR! There are more than one outlier in the g-band'
       print,'                                    for the epoch ID ',strtrim(objidfits,1),' of the Headobjid ',strtrim(headid,1)
   endif
   if outlier_g ne [-1] then Fin[i].PSFmag_g = -9999.    ; if any set PSF value to -9999

   ;------------------ r-band outliers ------------------
   outlier_r = where(o2 eq 3 and o9 eq objidfits, cOUT) ; getting any u-band outliers
   if cOUT gt 1 then begin                              ; print error if more than one outlier for i'th epoch
       print,':: createFITSwOutliersMarked.pro :: ERROR! There are more than one outlier in the r-band'
       print,'                                    for the epoch ID ',strtrim(objidfits,1),' of the Headobjid ',strtrim(headid,1)
   endif
   if outlier_r ne [-1] then Fin[i].PSFmag_r = -9999.    ; if any set PSF value to -9999

   ;------------------ i-band outliers ------------------
   outlier_i = where(o2 eq 4 and o9 eq objidfits, cOUT) ; getting any u-band outliers
   if cOUT gt 1 then begin                              ; print error if more than one outlier for i'th epoch
       print,':: createFITSwOutliersMarked.pro :: ERROR! There are more than one outlier in the i-band'
       print,'                                    for the epoch ID ',strtrim(objidfits,1),' of the Headobjid ',strtrim(headid,1)
   endif
   if outlier_i ne [-1] then Fin[i].PSFmag_i = -9999.    ; if any set PSF value to -9999

   ;------------------ z-band outliers ------------------
   outlier_z = where(o2 eq 5 and o9 eq objidfits, cOUT) ; getting any u-band outliers
   if cOUT gt 1 then begin                              ; print error if more than one outlier for i'th epoch
       print,':: createFITSwOutliersMarked.pro :: ERROR! There are more than one outlier in the z-band'
       print,'                                    for the epoch ID ',strtrim(objidfits,1),' of the Headobjid ',strtrim(headid,1)
   endif
   if outlier_z ne [-1] then Fin[i].PSFmag_z = -9999.    ; if any set PSF value to -9999

endfor

;creating name for output file:
namedate,FITSin,path,name,extension,date,dateus
FITSout='/'+path+'/'+name+'_outliers9999.'+extension
if vb eq 1 then print,':: createFITSwOutliersMarked.pro :: Wrote the output to: ',strtrim(FITSout,1)
mwrfits, Fin, FITSout, /create                          ; writing the output fits table

if vb eq 1 then print,' '
if vb eq 1 then print,':: createFITSwOutliersMarked.pro :: -- END OF PROGRAM -- '
if vb eq 1 then print,' '
END
