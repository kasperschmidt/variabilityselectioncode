;+
;----------------------------
;   NAME
;----------------------------
; bundlplot_Dmagoutliers
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Separates the input data into two files containing the magnitude (lightcurve) 
; outliers and the NON outliers found by running a median filter over the light
; curves and removing all points which deviates more than MAGCUT from that
;----------------------------
;   COMMENTS
;----------------------------
; Routine designed for SDSS vs PS1 bands, i.e. 4 bands (griz)
;----------------------------
;   INPUTS:
;----------------------------
; mjd_g          : MJD of 1st (SDSS g) band obeservation
; mjd_r          : MJD of 2nd (SDSS r) band obeservation
; mjd_i          : MJD of 3rd (SDSS i) band obeservation
; mjd_z          : MJD of 4th (SDSS z) band obeservation
; g0             : magnitudes of 1st band
; r0             : magnitudes of 2nd band
; i0             : magnitudes of 3rd band
; z0             : magnitudes of 4th band
; bundlindex     : the indexes for each indivdual bundle (indexes of the epochs for a given object)
; bundlsize      : the sizes of each individual bundle (# epochs per object)
; nobundl        : the number of bundles (objects)
; spsf1_g        : Inner gaussian sigma for the composite fit of the 1st band (seeing/FWHM)
; spsf1_r        : Inner gaussian sigma for the composite fit of the 2nd band (seeing/FWHM)
; spsf1_i        : Inner gaussian sigma for the composite fit of the 3rd band (seeing/FWHM)
; spsf1_z        : Inner gaussian sigma for the composite fit of the 4th band (seeing/FWHM)
; g0err          : error on the magnitudes of 1st band
; r0err          : error on the magnitudes of 2nd band
; i0err          : error on the magnitudes of 3rd band
; z0err          : error on the magnitudes of 4th band
; objid          : The ID of the objects with the mjds, mags and spsfs read
; nametag        : A name tag used in the output file names to characterize the input file
;                  and to easy recognition.
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /MAGCUT        : Set MAGCUT=some value to manually determine the allowed difference
;                  between the medianized lightcurves and the actual lightcurves used
;                  used to define outliers. The default is 0.25 magnitudes, i.e.,
;                  everything that deviates more is characterized as an 'outlier'
; /VERBOSE       : set VERBOSE to get information plotted on the screen
;----------------------------
;   OUTPUTS:
;----------------------------
; filenameNONout ; The name of the file containing the NON-outliers
; filenameout    ; The name of the file containing the outliers
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
; 2009-08-27  started by K. B. Schmidt (MPIA) - modifying an earlier version
;             of the code.
; 2009-09-07  z band calculations added by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
@ medianizedata.pro
;----------------------------
;-
PRO bundlplot_Dmagoutliers,mjd_g,mjd_r,mjd_i,mjd_z,g0,r0,i0,z0,bundlindex,bundlsize,nobundl,spsf1_g,spsf1_r,spsf1_i,spsf1_z,g0err,r0err,i0err,z0err,objid,nametag,filenameNONout,filenameout,MAGCUT=MAGCUT

MC = n_elements(MAGCUT)
VB = n_elements(VERBOSE)

FWHM = 2*sqrt(2*alog(2))     ; full with half maximum 'conversion'-factor

if MC eq 0 then begin        ; The cut made in the delta_mag to determine outliers is set to default or MAGCUT
   cut=0.25
endif else begin
   cut=MAGCUT
endelse
; opening outliers and NONoutliers output files
date = systime(/UTC)        ; creating a string of the utc date (and time)
path = 'idloutput/'
filenameout = path+'outliers_cut0p25_'+date+'_'+nametag+'.dat'
OPENW,10,filenameout, WIDTH=200
printf,10,'# columns are:'
printf,10,'# bundlno, band, mjd, obsno, deltamag, mag, magerr, seeing, objectID'
printf,10,'# for the bands 1=u, 2=g, 3=r, 4=i and 5=z'

filenameNONout = path+'NONoutliers_cut0p25_'+date+'_'+nametag+'.dat'
OPENW,15,filenameNONout, WIDTH=200
printf,15,'# columns are:'
printf,15,'# bundlno, band, mjd, obsno, deltamag, mag, magerr, seeing, objectID'
printf,15,'# for the bands 1=u, 2=g, 3=r, 4=i and 5=z'
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
for j=0l,nobundl-1 do begin     ; looping over data bundles

   jxx = fltarr(bundlsize(j))
   for k=0l,bundlsize(j)-1 do begin
      jxx(k) = 1+k
   endfor

   ;sorting mjd
   ;==g
   jmjd_g = mjd_g(bundlindex(j,0:(bundlsize(j)-1)))
   mjdgsort=jmjd_g[sort(jmjd_g)]
   ;==r
   jmjd_r = mjd_r(bundlindex(j,0:(bundlsize(j)-1)))
   mjdrsort=jmjd_r[sort(jmjd_r)]
   ;==i
   jmjd_i = mjd_i(bundlindex(j,0:(bundlsize(j)-1)))
   mjdisort=jmjd_i[sort(jmjd_i)]
   ;==z
   jmjd_z = mjd_z(bundlindex(j,0:(bundlsize(j)-1)))
   mjdzsort=jmjd_z[sort(jmjd_z)]

   ;sort data by the mjd order
   ;==objidg
   jidg = objid(bundlindex(j,0:(bundlsize(j)-1)))
   jidsortg = jidg[sort(jmjd_g)]
   ;==objidr
   jidr = objid(bundlindex(j,0:(bundlsize(j)-1)))
   jidsortr = jidr[sort(jmjd_r)]
   ;==objidi
   jidi = objid(bundlindex(j,0:(bundlsize(j)-1)))
   jidsorti = jidi[sort(jmjd_i)]
   ;==objidz
   jidz = objid(bundlindex(j,0:(bundlsize(j)-1)))
   jidsortz = jidz[sort(jmjd_z)]
   ;==g
   jg = g0(bundlindex(j,0:(bundlsize(j)-1)))
   jgsort  =jg[sort(jmjd_g)]
   ;==r
   jr = r0(bundlindex(j,0:(bundlsize(j)-1)))
   jrsort  =jr[sort(jmjd_r)]
   ;==i
   ji = i0(bundlindex(j,0:(bundlsize(j)-1)))
   jisort  =ji[sort(jmjd_i)]
   ;==z
   jz = z0(bundlindex(j,0:(bundlsize(j)-1)))
   jzsort  =jz[sort(jmjd_z)]
   ;==seeing g
   jseeg = spsf1_g(bundlindex(j,0:(bundlsize(j)-1)))*FWHM
   jseegsort  =jseeg[sort(jmjd_g)]
   ;==seeing r
   jseer = spsf1_r(bundlindex(j,0:(bundlsize(j)-1)))*FWHM
   jseersort  =jseer[sort(jmjd_r)]
   ;==seeing i
   jseei = spsf1_i(bundlindex(j,0:(bundlsize(j)-1)))*FWHM
   jseeisort  =jseei[sort(jmjd_i)]
   ;==seeinz z
   jseez = spsf1_z(bundlindex(j,0:(bundlsize(j)-1)))*FWHM
   jseezsort  =jseez[sort(jmjd_z)]
   ;==magerr g
   jgerr = g0err(bundlindex(j,0:(bundlsize(j)-1)))
   jgerrsort  =jgerr[sort(jmjd_g)]
   ;==magerr r
   jrerr = r0err(bundlindex(j,0:(bundlsize(j)-1)))
   jrerrsort  =jrerr[sort(jmjd_r)]
   ;==magerr i
   jierr = i0err(bundlindex(j,0:(bundlsize(j)-1)))
   jierrsort  =jierr[sort(jmjd_i)]
   ;==mazerr z
   jzerr = z0err(bundlindex(j,0:(bundlsize(j)-1)))
   jzerrsort  =jzerr[sort(jmjd_z)]

   ;calculating medianized light curves
   medianizedata, jxx,jgsort,3,'median',jgmed,deltajg
   medianizedata, jxx,jgsort,3,'mean',jgmean,deltajgmean

   medianizedata, jxx,jrsort,3,'median',jrmed,deltajr
   medianizedata, jxx,jrsort,3,'mean',jrmean,deltajrmean

   medianizedata, jxx,jisort,3,'median',jimed,deltaji
   medianizedata, jxx,jisort,3,'mean',jimean,deltajimean

   medianizedata, jxx,jzsort,3,'median',jzmed,deltajz
   medianizedata, jxx,jzsort,3,'mean',jzmean,deltajzmean

   goutlier = where(abs(deltajg) gt cut,countg)
   routlier = where(abs(deltajr) gt cut,countr)
   ioutlier = where(abs(deltaji) gt cut,counti)
   zoutlier = where(abs(deltajz) gt cut,countz)

   sg = size(goutlier)
   sizeg = sg(1)

   ; Before writing outliers and non outliers data
   ; checking if one (or some) of the non outliers has the value -9999. If this is the case
   ; the definition of outliers and non outliers should be swapped. This for instance happens
   ; when running downsampled data, since there are more -9999 values for downsampled data 
   ; these will be taken as the actual values and the sensible magnitudes will then be 
   ;outliers. Thus the output will be changed if that is the case:
   nonoutg = where(abs(deltajg) lt cut,cnong)
   if cnong eq 0 then begin         ; checking if there are any outliers at all
      cnines = 0
   endif else begin
      nines = where(jgsort(nonoutg) eq -9999,cnines)
   endelse
   ; if there are more than 0 -9999 values in the nonout values the output files are changed
   if cnines gt 0 then begin 
      file1 = 15
      file2 = 10
      ; writing NONoutliers data to file
      ; the criteria that the abs(deltaXX ne 9000) makes sure that objects with two few epochs to be
      ; medianized are note written to the files. Furthermore in the case of downsampled data, we mak   e
      ; sure that no -9999 magnitude values occur in the NON outliers files by setting jXsort(l) ne -9999
      for l=0,max(jxx)-1 do begin
      ;==gband
         if (abs(deltajg(l)) gt cut AND abs(deltajg(l)) ne 9000) AND jgsort(l) ne -9999 then begin
            printf,file1,j+1,2,mjdgsort(l),jxx(l),deltajg(l),jgsort(l),jgerrsort(l),jseegsort(l),jidsortg(l)
         endif 
      ;==rband
         if (abs(deltajr(l)) gt cut AND abs(deltajr(l)) ne 9000) AND jrsort(l) ne -9999 then begin
            printf,file1,j+1,3,mjdrsort(l),jxx(l),deltajr(l),jrsort(l),jrerrsort(l),jseersort(l),jidsortr(l)
         endif
      ;==iband
         if (abs(deltaji(l)) gt cut AND abs(deltaji(l)) ne 9000) AND jisort(l) ne -9999 then begin
            printf,file1,j+1,4,mjdisort(l),jxx(l),deltaji(l),jisort(l),jierrsort(l),jseeisort(l),jidsorti(l)
         endif
      ;==zband
         if (abs(deltajz(l)) gt cut AND abs(deltajz(l)) ne 9000) AND jzsort(l) ne -9999 then begin
            printf,file1,j+1,5,mjdzsort(l),jxx(l),deltajz(l),jzsort(l),jzerrsort(l),jseezsort(l),jidsortz(l)
         endif 
      endfor

      ; writing outliers data to OTHER file
      for l=0,max(jxx)-1 do begin
      ;==gband
         if ((abs(deltajg(l)) lt cut AND abs(deltajg(l)) ne 9000)) or jgsort(l) eq -9999 then begin
            printf,file2,j+1,2,mjdgsort(l),jxx(l),deltajg(l),jgsort(l),jgerrsort(l),jseegsort(l),jidsortg(l)
         endif
      ;==rband
         if ((abs(deltajr(l)) lt cut AND abs(deltajr(l)) ne 9000)) or jrsort(l) eq -9999 then begin
            printf,file2,j+1,3,mjdrsort(l),jxx(l),deltajr(l),jrsort(l),jrerrsort(l),jseersort(l),jidsortr(l)
         endif
      ;==iband
         if ((abs(deltaji(l)) lt cut AND abs(deltaji(l)) ne 9000)) or jisort(l) eq -9999 then begin
            printf,file2,j+1,4,mjdisort(l),jxx(l),deltaji(l),jisort(l),jierrsort(l),jseeisort(l),jidsorti(l)
         endif
      ;==zband
         if ((abs(deltajz(l)) lt cut AND abs(deltajz(l)) ne 9000)) or jzsort(l) eq -9999 then begin
            printf,file2,j+1,5,mjdzsort(l),jxx(l),deltajz(l),jzsort(l),jzerrsort(l),jseezsort(l),jidsortz(l)
         endif
      endfor

   endif else begin
      file1 = 10
      file2 = 15
      ; writing outliers data to file
      ; the criteria that the abs(deltaXX ne 9000) makes sure that objects with two few epochs to be
      ; medianized are note written to the files.
      for l=0,max(jxx)-1 do begin
      ;==gband
         if (abs(deltajg(l)) gt cut AND abs(deltajg(l)) ne 9000) AND jgsort(l) ne -9999 then begin
            printf,file1,j+1,2,mjdgsort(l),jxx(l),deltajg(l),jgsort(l),jgerrsort(l),jseegsort(l),jidsortg(l)
         endif 
      ;==rband
         if (abs(deltajr(l)) gt cut AND abs(deltajr(l)) ne 9000) AND jrsort(l) ne -9999 then begin
            printf,file1,j+1,3,mjdrsort(l),jxx(l),deltajr(l),jrsort(l),jrerrsort(l),jseersort(l),jidsortr(l)
         endif
      ;==iband
         if (abs(deltaji(l)) gt cut AND abs(deltaji(l)) ne 9000) AND jisort(l) ne -9999 then begin
            printf,file1,j+1,4,mjdisort(l),jxx(l),deltaji(l),jisort(l),jierrsort(l),jseeisort(l),jidsorti(l)
         endif
      ;==zband
         if (abs(deltajz(l)) gt cut AND abs(deltajz(l)) ne 9000) AND jzsort(l) ne -9999 then begin
            printf,file1,j+1,5,mjdzsort(l),jxx(l),deltajz(l),jzsort(l),jzerrsort(l),jseezsort(l),jidsortz(l)
         endif 
      endfor

      ; writing non outliers data to OTHER file
      for l=0,max(jxx)-1 do begin
      ;==gband
         if (abs(deltajg(l)) lt cut AND abs(deltajg(l)) ne 9000)  then begin
            printf,file2,j+1,2,mjdgsort(l),jxx(l),deltajg(l),jgsort(l),jgerrsort(l),jseegsort(l),jidsortg(l)
         endif
      ;==rband
         if (abs(deltajr(l)) lt cut AND abs(deltajr(l)) ne 9000) then begin
            printf,file2,j+1,3,mjdrsort(l),jxx(l),deltajr(l),jrsort(l),jrerrsort(l),jseersort(l),jidsortr(l)
         endif
      ;==iband
         if (abs(deltaji(l)) lt cut AND abs(deltaji(l)) ne 9000) then begin
            printf,file2,j+1,4,mjdisort(l),jxx(l),deltaji(l),jisort(l),jierrsort(l),jseeisort(l),jidsorti(l)
         endif
      ;==zband
         if (abs(deltajz(l)) lt cut AND abs(deltajz(l)) ne 9000)  then begin
            printf,file2,j+1,5,mjdzsort(l),jxx(l),deltajz(l),jzsort(l),jzerrsort(l),jseezsort(l),jidsortz(l)
         endif
      endfor
   endelse
endfor
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CLOSE,15
CLOSE,10
if VB eq 0 then begin
   print,':: bundlplot_Dmagoutliers.pro :: Wrote outliers and NONoutliers to files:'
   print,'                                 ',filenameout
   print,'                                 ',filenameNONout
endif
END
