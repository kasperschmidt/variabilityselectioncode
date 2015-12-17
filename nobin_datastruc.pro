;+
;----------------------------
;   NAME
;----------------------------
; nobin_datastruc.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; This routine creates the structure function (like) data srtructures used as input to
; powerlawmcmc.pro when the nobinnning keyword is used. (In the case of binned structure
; functions structurefctSTR.pro creates the input for powerlawmcmc.pro)
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; MJD             : The mjd of the data
; mag             : the magnitudes of the data
; magerr          : the (photometric) error on the data magnitudes
; nobundl         : the number of databundles (objects)
; bundlindex      : indices indicating bundles
; bundlsize       : the size of each bundle
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /VERBOSE        : set /VERBOSE to get info/messages printed to the screen
;----------------------------
;   OUTPUTS:
;----------------------------
; datastruc       : The data structure returned by the routine. The entries are
;                   datastruc(N).dt(*)      = the time difference for the individual values
;                   datastruc(N).mag(*)    = the magnitudes
;                   datastruc(N).magerr(*) = the errors on the magnitudes
;                   where N is the number of bundles in the data
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; IDL> nobin_datastruc,mjd_gband(entriesg),g0(entriesg),g0err(entriesg),nobundl,bundlindex,bundlsize,structue_gband,/VERBOSE
;----------------------------
;   BUGS
;----------------------------
;
;----------------------------
;   REVISION HISTORY
;----------------------------
; 2009-07-12  started by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
PRO nobin_datastruc,mjd,mag,magerr,nobundl,bundlindex,bundlesize,datastruc,VERBOSE=VERBOSE

PS = n_elements(EPS)
VB = n_elements(VERBOSE)

;defining the maximum number of data pairs to be put in the structure
maxBS = max(bundlesize)
N = maxBS*(maxBS-1)/2
;creating structure
dataarr    = {dt:fltarr(N),value:fltarr(N),valueerr:fltarr(N)}
datastruc = replicate(dataarr,nobundl)

; --- Filling the structure with data
for i=0l,nobundl-1 do begin
   for j=0l,bundlesize(i)-1 do begin
      datastruc(i).dt(j)     = mjd(bundlindex(i,j))
      datastruc(i).value(j)    = mag(bundlindex(i,j))
      datastruc(i).valueerr(j) = magerr(bundlindex(i,j))
      if VB eq 1 AND n_elements(datastruc(i).dt(*)) ne bundlesize(i) then print,":: nobin_datastruc :: ERROR: The number of entries and the bundlesize don't match for bundl no ",i
   endfor
endfor
END
