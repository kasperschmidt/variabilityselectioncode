;+
;----------------------------
;   NAME
;----------------------------
; bundlplot_aVSgamma.pro
;
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Program plotting the A (amplitude) VS gamma (exponent) parameters from the 
; structure function power law fit with 1D distribution on the axis
;----------------------------
;   COMMENTS
;----------------------------
; none
;
;----------------------------
;   INPUTS:
;----------------------------
; 
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /EPS          : set /EPS to turn the plots in to .eps files
;  --- disabled /CONT         : set /CONT to plot contours overlaid on QSO points
; /DOWNSAMPLE   ; set /DOWNSAMPLE to load the downsampled data and plot that
; /BINS10       : set /BINS10 (only works together with /DOWNSAMPLE) to get
;                 the downsampled data binned as usual and not the special
;                 4 PS1 bins
; /NOERR        : set /NOERR if you dont want error bars on plots (when plotting 
;                 no error bars are shown by default (contours => many points)
; /CUT          : set /CUT if you want suggested cut regions overplotted
; /FSTAR        : set /FSTAR to include the F-star data in the plot
; /RRL          : set /RRL to include the RRL data in the plot
; /ALLINONE     : set /ALLINONE if you want to read in the file containing all objects
;                 in the same file - used for the actual data or tests of unknown
;                 sources, i.e., if you don't know the type of data beforehand
; /WAITING      ; set /WAITING to have a small pause between the pltting of each evolution
;                 tract - done to be able to follow the tracks beeing plotted
; YMAXP         : set YMAXP equal to the maximum percentage on the y axis of the gamma 
;                 histogram if the default value 0.2 is too
;                 small/large
; /SKIPLEGEND   : Set /SKIPLEGEND not to write the legend in the upper
;                 right corner of the plot
;----------------------------
;   OUTPUTS:
;----------------------------
;
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; plotting both QSO, Fstar and RRLyrae data without error bars
; IDL> bundlplot_aVSgamma,/NOERR,/FSTAR,/RRL,/DOWNSAMPLE
; running the All in one file
; IDL> bundlplot_aVSgamma,/NOERR,/ALLINONE,/CUT,YMAXP=1.0
; for the BOSS objects
; 
;----------------------------
;   BUGS
;----------------------------
;
;----------------------------
;   REVISION HISTORY
;----------------------------
; 2009-07-15  started by K. B. Schmidt (MPIA)
; 2009-09-15  /FSTAR and /RRL keywords added by K. B. Schmidt (MPIA)
; 2009-09-21  /ALLINONE keyword added by K. B. Schmidt (MPIA)
;----------------------------
; dependecies,to be compiled as well:
@ histogrambinnedRange.pro
;@ contourarray.pro
@ plothist.pro            ; have to do it manually since the one at MPIA is presumably an old version
@ extractSubvector.pro
;@ Histoplot.pro           ; to be able ot plot logarithmic bins
; input/output:        opt. i   opt. i          opt. i            opt. i       opt. ii    opt. i
PRO bundlplot_aVSgamma,EPS=EPS,CONT=CONT,DOWNSAMPLE=DOWNSAMPLE,BINS10=BINS10,NOERR=NOERR,CUT=CUT,FSTAR=FSTAR,RRL=RRL,ALLINONE=ALLINONE,WAITING=WAITING,YMAXP=YMAXP,SKIPLEGEND=SKIPLEGEND

nerr     = n_elements(NOERR)
CO       = n_elements(CONT)
DS       = n_elements(DOWNSAMPLE)
BIN10    = n_elements(BINS10)
PS       = n_elements(EPS)
CT       = n_elements(CUT)
RL       = n_elements(RRL)
FS       = n_elements(FSTAR)
AIO      = n_elements(ALLINONE)
WT       = n_elements(WAITING)
YM       = n_elements(YMAXP)
SLEG     = n_elements(SKIPLEGEND)
;=== READING DATA FOR PLOTS ===
path         = '/disk3/kschmidt/casjobs090615/casjobs_SDSS/idloutput/powerlawfit/'
pathNOBINall = '/disk3/kschmidt/structurefunctioncalcs/idloutput/090916NOBINrunALL/'
pathNOBINDS  = '/disk3/kschmidt/structurefunctioncalcs/idloutput/090917NOBINrunDS/'
pathGT30  = '/disk3/kschmidt/structurefunctioncalcs/idloutput/090923unknownGT30_dbl_NOstrfctfitsfile/'
;======================================================================================================
;                                 READING s82 DATA
;======================================================================================================
FMT='i,i,d,d,d,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,O'
if DS eq 0 then begin
   ;======================================================
   ;==== F-stars ====
   ;---NOBINNING---
   if FS eq 1 then readcol,pathNOBINall+'powerlawfit_characteristica_Thu Sep 17 01:22:24 2009_FstarsTop5K_NOBIN.dat' ,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21

   ;======================================================
   ;=== RR Lyrae ====
   ;---NOBINNING---
   ;if RL eq 1 then readcol,pathNOBINall+'powerlawfit_characteristica_Wed Sep 16 19:19:18 2009_RRLyraeTop5K_NOBIN.dat'  ,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21

   ; file containing both RRL and Fstar contaminants so they have the same color
   ;if RL eq 1 then readcol,pathNOBINall+'powerlawfit_characteristica_090916_RRLyraeTop5K_NOBIN_AND_090917_FstarsTop5K_NOBIN.dat',b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21

   ; sesar et al 2009 RRL
   if RL eq 1 then readcol,'/disk3/kschmidt/structurefunctioncalcs/idloutput/091026RRLsesar09/powerlawfit_characteristica_Mon Oct 26 16:25:49 2009_sesar09_483RRL_s82sampling_NoBIN_NOBIN.dat' ,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21,b22 ;& legendtxt='S82 RRL' 

   ;file for testing rewritten procedure
   ;readcol,'../../structurefunctioncalcs/idloutput/090902RRLtest/powerlawfit_characteristica_Wed Sep  2 11:06:17 2009_RRLyraeTop5K.dat' ,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21
   ;======================================================
   ;testing if you want to plot a All-In-One file or a QSO file
   if AIO eq 0 then begin
   ;===== QSOs ======
   ;reading data created with the file:
   ; DR5qcat_s82_photo_wFieldinfo_wModelMag_top2000_orderby.fit
   ;readcol,path+'powerlawfit_characteristica_Fri Jul  3 07:20:45 2009.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21
   ;=== FOR ALL QSO DATA ===
   ;the combination of the output from running Part1 and Part2 of the file
   ;DR5qcat_s82_photo_wFieldinfo_wModelMag_top2000parent_sorted_epochsGT20.fits
   ;readcol,path+'powerlawfit_characteristica_Sat Jul 11_Part1and2_combined.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21

   ;---NOBINNING---
   ;readcol,pathNOBINall+'powerlawfit_characteristica_090917_QSOall_Part1and2_combined_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21 & com='93%' & samp = 'S82';& pur='99%'

   ; --- RRL search with Sonia Duffau ---
   ;readcol,FORMAT=FMT,'/disk3/kschmidt/structurefunctioncalcs/idloutput/091216sesarcontaminants/powerlawfit_characteristica_Wed Dec 16 09:53:50 2009_sesar_contaminants_s82sampling_NoBIN_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 ;& com='94%' & pur='45%'

   ; --- Bhatti Delta Scuti ---
   ;readcol,FORMAT=FMT,'/Users/kasperborelloschmidt/work/casjobs_SDSS/bhatti_etal_deltascutiLC/idloutput/powerlawfit_characteristica_Thu Jun  3 08:52:06 2010__multirun_bhattiDeltaScutiDummy_sorted_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 ;& com='XX%' & pur='XX%'

   ; --- Bhatti RRL ab ---
   ;readcol,FORMAT=FMT,'/Users/kasperborelloschmidt/work/casjobs_SDSS/bhatti_etal_RRLtypeab/idloutput/powerlawfit_characteristica_Fri Jun 18 09:15:59 2010__multirun_bhattiRRLtypeab_sorted_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 ;& com='XX%' & pur='XX%'

   ; --- Bhatti RRL c ---
   ;readcol,FORMAT=FMT,'/Users/kasperborelloschmidt/work/casjobs_SDSS/bhatti_etal_RRLtypec/idloutput/powerlawfit_characteristica_Fri Jun 18 09:13:02 2010__multirun_bhattiRRLtypec_sorted_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 ;& com='XX%' & pur='XX%'

   ; --- Bhatti Unknown Per Var ---
   ;readcol,FORMAT=FMT,'/Users/kasperborelloschmidt/work/casjobs_SDSS/bhatti_etal_unknownpervar/idloutput/powerlawfit_characteristica_Wed Jun 30 08:53:08 2010__multirun_bhattiUnknownPerVar_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 ;& com='XX%' & pur='XX%'

   ; --- Bhatti Ecl Var ---
   ;readcol,FORMAT=FMT,'/Users/kasperborelloschmidt/work/casjobs_SDSS/bhatti_etal_eclipsingvar/idloutput/powerlawfit_characteristica_Wed Jun 30 08:49:15 2010__multirun_bhattiEclipsingVar_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 ;& com='XX%' & pur='XX%'

   ; --- Sesar RRL ---
   readcol,FORMAT=FMT,'/Users/kasperborelloschmidt/Desktop/powerlawfit_characteristica_Mon_Oct_26_16_25_49_2009_sesar09_483RRL_s82sampling_NoBIN_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 ;& com='XX%' & pur='XX%'

   ; --- BOSS ~20k QSO candidates ---
   ;readcol,FORMAT=FMT,'/Users/kasperborelloschmidt/work/SDSSIII_BOSS/powerlawfit_characteristica_BOSStargetQSO.dat',c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 & Nobj='21,538' & samp = 'S82' 

   ; --- Extended lens search ---
   ;readcol,FORMAT=FMT,'/disk3/kschmidt/structurefunctioncalcs/idloutput/100108extendedlenssearch/powerlawfit_characteristica_Fri Jan  8 02:09:09 2010_ext_17i21_UVX_030RA060_deredpsfmag_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 & legendtxt='Ext. 17i21' & com='12%'  & Nobj='12,168' & samp = 'S82' & magtype='PSF mag' ; & pur='92%'

   ;readcol,FORMAT=FMT,'/Users/kasperborelloschmidt/work/casjobs_SDSS/fits/extended_lenssearch/powerlawfit_characteristica_17i21_UVX_fibermag_wholeS82.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 & legendtxt='Ext. 17i21' & com='XX%'  & Nobj='39,449' & samp = 'S82' & magtype='FIB mag' ; & pur='XX%'

   ; -- WHOLE OF S82 griz BOX --
   ;readcol,FORMAT=FMT,'/disk3/kschmidt/structurefunctioncalcs/idloutput/100322grizBOX_wholeS82/powerlawCATALL_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 & legendtxt='griz box' & com='xx%' & pur='xx%' & Nobj='208258' & samp = 'S82' & counts=['204949','2,435','874']

   endif else begin

   ; --- nUVX box - whole S82 ---
   readcol,FORMAT=FMT,'/disk3/kschmidt/structurefunctioncalcs/100414nUVXboxWholeS82/powerlawfit_characteristica_Wed Apr 14 14:30:36 2010__multirun_s82pointsourcesGreenBox_wDeredMag_sorted_NOBIN.dat',c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 & legendtxt='nUVX' & Nobj='3254' & samp = 'S82' & parentQSOs = '/disk3/kschmidt/structurefunctioncalcs/QSOsINparentfiles/headobjid_QSOsIN_headobjids_PARENT_s82pointsourcesGreenBox_distinct_wDeredMag_sorted.dat'

   ; --- sesar et al 2009 RRL ---
   ;readcol,'/disk3/kschmidt/structurefunctioncalcs/idloutput/091026RRLsesar09/powerlawfit_characteristica_Mon Oct 26 16:25:49 2009_sesar09_483RRL_s82sampling_NoBIN_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 & legendtxt='S82 RRL' & com='97%' & Nobj='483' & samp = 'S82'

   endelse

   ;======================================================
endif else begin
   ;======================================================================================================
   ;                                 READING s82 DOWNSAMPLED DATA
   ;======================================================================================================
   ; overwriting the read table entries if the user wants the 10 bins data instead
   if BIN10 eq 1 then begin 

   endif else begin
      ; --- F/G stars DS no outliers ---
      if FS eq 1 then readcol,'/disk3/kschmidt/structurefunctioncalcs/idloutput/100203donwsamplingALLafterMedianize/powerlawfit_characteristica_Tue Feb  2 20:55:44 2010_FGstars_outMark_DS_NOBIN.dat' ,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22

      ; --- Sesar RRL DS no outliers ---
      if RL eq 1 then readcol,'/disk3/kschmidt/structurefunctioncalcs/idloutput/100203donwsamplingALLafterMedianize/powerlawfit_characteristica_Tue Feb  2 20:38:40 2010_sesarRRL_outMark_DS_NOBIN.dat' ,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21,b22 ;& legendtxt='S82 RRL'


      ;=== FOR ALL QSO DATA ===
      readcol,'/disk3/kschmidt/structurefunctioncalcs/idloutput/100203donwsamplingALLafterMedianize/powerlawfit_characteristica_Tue Feb  2 21:09:36 2010_QSOall_outMark_DS_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21 & com='76%' & samp = 'PS1';& pur='XX%'

      ; --- RRL search with Sonia Duffau ---
      ;readcol,FORMAT=FMT,'/disk3/kschmidt/structurefunctioncalcs/idloutput/091216sesarcontaminants/powerlawfit_characteristica_Thu Dec 17 08:20:30 2009_sesar_contaminants_PS1sampling_NoBIN_NOBIN.dat' ,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,c21,c22 ;& com='94%' & pur='45%'

   endelse
endelse
; getting g,r and i band indexes
if FS eq 1 then begin
   ags = where(a2 eq 2,cags)
   ars = where(a2 eq 3,cars)
   ais = where(a2 eq 4,cais)
   azs = where(a2 eq 5,cazs)
endif

if RL eq 1 then begin
   bgs = where(b2 eq 2,cbgs)
   brs = where(b2 eq 3,cbrs)
   bis = where(b2 eq 4,cbis)
   bzs = where(b2 eq 5,cbzs)
endif

cgs = where(c2 eq 2,ccgs)
crs = where(c2 eq 3,ccrs)
cis = where(c2 eq 4,ccis)
czs = where(c2 eq 5,cczs)

;goto,jump
;======================================================================================================
;======================================================================================================
;======================================================================================================
;======================================================================================================
;
;                                  PLOTTING!   r band
;
;======================================================================================================
;======================================================================================================
;======================================================================================================
;======================================================================================================
!P.MULTI = [0, 0, 0]

;Set general values for plot (easier to change)
cs      = 2                   ; charsize
th      = 2                   ; thick
ss      = 0.3  ;0.6                   ; symsize
binx    = 0.02               ; bins used for the histogram on the xaxis
biny    = 0.05                ; bins used for the histogram on the yaxis
xscat   = [0.01,0.90]         ; the x range of the scatter plot
yscat   = [-0.1,1.25]         ; the x range of the scatter plot

;======================================
if PS eq 1 then begin
   set_plot, 'ps'
   col=getcolor(/load)     ; get color table for plot
   plot1 = 'AvsgammaHist_rband.eps'
   device,  file=plot1 ,/color , /encapsulated, xsize=25, ysize=25;, xsize=7
   thickall = 6
endif else begin
   set_plot, 'x'
   col=getcolor(/load)     ; get color table for plot
   device, retain=2        ; ensuring that plotting windows 'regenerate'
   window, 1, xsize=700, ysize=600  , title='r-band'
   thickall = 2
endelse

plot,c7(cgs),c11(cgs),psym=2,col=col.black, linestyle=4  $
        , /NODATA $
	, xtitle='A (amplitude at 1 yr)' $
	, ytitle='!7c!3 (power law exponent)'$
        , xrange=xscat , /xstyle $
        , yrange = yscat, /ystyle $
	, charsize =cs $
        , charthick = thickall $
	, xthick = thickall $
	, ythick = thickall $
	,/xlog $
;	, /ylog $
        , pos = [0.12,0.12,0.8,0.8] $
        , background = col.white


if CO eq 1 then begin
;========= DEFINING & PLOTTING CONTOUR ARRAYS =========
oplot,c7(crs),c11(crs),psym=5,col=col.cyan,symsize=ss
contourarray,c7(crs),0.0,1.0,c11(crs),-0.1,1.2,40,40,10,contarrc,levelbinc,xrangec,yrangec
contour,contarrc,xrangec,yrangec,/overplot $
	, levels=levelbinc $
	, C_COLOR=[col.cyan]

if RL eq 1 then begin
oplot,b7(brs),b11(brs),psym=4,col=col.red,symsize=ss
contourarray,b7(brs),0.0,1.0,b11(brs),-0.1,1.2,70,100,5,contarrb,levelbinb,xrangeb,yrangeb
contour,contarrb,xrangeb,yrangeb,/overplot $
	, levels=[1,5,10,50,100] $;levelbinb $
	, C_COLOR=[col.red]
endif

if FS eq 1 then begin
oplot,a7(ars),a11(ars),psym=6,col=col.charcoal,symsize=ss
contourarray,a7(ars),0.0,1.0,a11(ars),-0.1,1.2,70,100,5,contarra,levelbina,xrangea,yrangea
contour,contarra,xrangea,yrangea,/overplot $
	, levels=[5,10,20,50,100] $;levelbinb $
	, C_COLOR=[col.charcoal]
endif
;======================================================
endif else begin
PSIZE_QSO = 1.25
PSIZE_Fs  = 1.25
PSIZE_RRl = 1.25
thick = 3.0
circle = 0
square = 8
upstri = 5
triangle = 4

;selecting between plotting styles for QSO data and All-In-One data
if AIO eq 0 then begin
   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.cyan, /FILL
   oplot,c7(crs),c11(crs),psym=8,symsize=ss
   print,'The number of A and Gamma sets plotted: ',n_elements(c7(crs))

   if nerr eq 0 then oploterror,c7(crs),c11(crs),c10(crs), c14(crs),psym=3, col=col.black, ERRCOLOR=col.cyan,/LOBAR,/xlog
   if nerr eq 0 then oploterror,c7(crs),c11(crs),c9(crs), c13(crs),psym=3, col=col.black, ERRCOLOR=col.cyan, /HIBAR,/xlog
   ;=== LEGEND ===
   ;oplot,c7*0+0.89,c11*0+1.2,psym=8,symsize=1.5
   ;xyouts,1.08,1.5,'QSOs',col=col.black,charsize=cs,charthick=thickall
   ;xyouts,1.08,1.5,' ',col=col.black,charsize=cs,charthick=thickall
   ;==============
endif else begin

   inputIDs = c22(crs)
   Avalues  = c7(crs)
   gammas   = c11(crs)
   FMT2 = 'O'
   readcol,FORMAT=FMT2,parentQSOs,pqsoID   ; reading the IDs for the QSO in the parent file (to be shown as another color
   QSOentriesr = dblarr(1)     ; defining array for output (size will be chaged)
   extractSubvector,inputIDs,pqsoID,outvecr,outentr,REMOVEDENT=QSOentriesr

   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.cyan, /FILL
   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.cyan, /FILL
   oplot,Avalues(QSOentriesr),gammas(QSOentriesr),psym=8,symsize=ss

   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.red, /FILL
   oplot,Avalues(outentr),gammas(outentr),psym=8,symsize=ss

   if nerr eq 0 then oploterror,c7(crs),c11(crs),c10(crs), c14(crs),psym=3, col=col.black, ERRCOLOR=col.navy,/LOBAR,/xlog
   if nerr eq 0 then oploterror,c7(crs),c11(crs),c9(crs), c13(crs),psym=3, col=col.black, ERRCOLOR=col.navy, /HIBAR,/xlog

   ;=== LEGEND ===
   ;oplot,c7*0+0.25,c11*0+1.1,psym=8,symsize=1.5 ; search xxx
   ;xyouts,1.08,1.5,legendtxt,col=col.black,charsize=cs,charthick=thickall
endelse

if RL eq 1 then begin
   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.red , /FILL
   oplot,b7(brs),b11(brs),psym=8,symsize=ss
   if nerr eq 0 then oploterror,b7(brs),b11(brs),b10(brs),b14(brs),psym=3, col=col.black, ERRCOLOR=col.red,/LOBAR,/xlog
   if nerr eq 0 then oploterror,b7(brs),b11(brs),b9(brs),b13(brs),psym=3, col=col.black, ERRCOLOR=col.red,/HIBAR,/xlog
   ;=== LEGEND ===
   ;oplot,c7*0+1.04,c11*0+1.45,psym=8,symsize=1.5
   ;xyouts,0.3,0.975,'RR Lyrae',col=col.black,charsize=cs,charthick=thickall
   ;xyouts,1.08,1.4,'Contam.',col=col.black,charsize=cs,charthick=thickall
   ;==============
endif

if FS eq 1 then begin
   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.charcoal, /FILL
   oplot,a7(ars),a11(ars),psym=8,symsize=ss
   if nerr eq 0 then oploterror,a7(ars),a11(ars),a10(ars),a14(ars),psym=3, col=col.black, ERRCOLOR=col.charcoal,/LOBAR,/xlog
   if nerr eq 0 then oploterror,a7(ars),a11(ars),a9(ars),a13(ars),psym=3, col=col.black, ERRCOLOR=col.charcoal,/HIBAR,/xlog
   ;=== LEGEND ===
   ;oplot,c7*0+0.25,c11*0+0.9,psym=8,symsize=1.5
   ;xyouts,0.3,0.875,'fstars',col=col.black,charsize=cs,charthick=thickall
   ;==============
endif
endelse

;suggested cuts in the A-gamma space
if CT eq 1 then begin
   ;oplot,[0.015,0.03],[1.05,0.15],linestyle=0,col=col.black,thick=2
   ;oplot,[0.03,0.3],[0.15,0.1],linestyle=0,col=col.black,thick=2

   N = 10000
   xaxis = fltarr(N)
   for i =0,N-1 do begin
      xaxis(i) = i*10./N
   endfor
   ;oplot,xaxis,-2*alog10(xaxis)-2.8,linestyle=0,col=col.green,thick=6
   ;oplot,xaxis,0.075+xaxis*0,linestyle=0,col=col.green,thick=6
   ;oplot,xaxis,0.5*alog10(xaxis)+0.55,linestyle=0,col=col.green,thick=6


;   oplot,xaxis,-2*alog10(xaxis)-2.25,linestyle=0,col=col.magenta,thick=6
;   oplot,xaxis,0.055+xaxis*0,linestyle=0,col=col.magenta,thick=6
   oplot,xaxis,0.5*alog10(xaxis)+0.5,linestyle=0,col=col.black,thick=thickall+3

   oplot,[0.0703882,0.128825],[0.055,0.055],linestyle=0,col=col.black,thick=thickall+3
   oplot,[0.0177828,0.0703882],[1.25,0.055],linestyle=0,col=col.black,thick=thickall+3

endif

;=== LEGEND ===
;Completeness and purity legend
if n_elements(com) ne 0 then xyouts,0.25,1.1,'c = '+com,col=col.black,charsize=cs,charthick=thickall
if n_elements(pur) ne 0 then xyouts,0.25,1.0,'p = '+pur,col=col.black,charsize=cs,charthick=thickall
;The counts of objects in the three regions
if n_elements(counts) ne 0 then begin
   xyouts,0.015,-0.06,strtrim(counts[0],1),col=col.black,charsize=cs,charthick=thickall
   xyouts,0.04,1.15,strtrim(counts[1],1),col=col.black,charsize=cs,charthick=thickall
   xyouts,0.3,-0.06,strtrim(counts[2],1),col=col.black,charsize=cs,charthick=thickall
endif
;==============
;Legend box in upper right corner
;==============
if SLEG eq 0 then begin 
plot,c7(cgs),c11(cgs),psym=2,col=col.white $
        , /NODATA $
	, xtitle=' ' $
	, ytitle=' '$
        , xrange=[0,1] , /xstyle $
        , yrange =[0,1], /ystyle $
	, charsize =cs $
        , charthick = thickall $
	, xthick = thickall $
	, ythick = thickall $
        , pos = [0.8,0.8,0.98,0.98] $
        ,/noerase $
        , background = col.white

if FS eq 1 then begin
   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.charcoal, /FILL
   oplot,c7*0+0.1,c11*0+0.95,psym=8,symsize=1.5
   xyouts,0.2,0.9,'F/G stars',col=col.black,charsize=cs,charthick=thickall
endif

if RL eq 1 then begin
   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.red , /FILL
   oplot,c7*0+0.1,c11*0+0.35,psym=8,symsize=1.5
   xyouts,0.2,0.3,'RR Lyrae',col=col.black,charsize=cs,charthick=thickall
;   xyouts,0.2,0.3,'Contam.',col=col.black,charsize=cs,charthick=thickall
endif

if AIO eq 0 then begin
   if n_elements(legendtxt) ne 0 then xyouts,0.2,0.9,legendtxt,col=col.black,charsize=cs,charthick=thickall
   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.cyan, /FILL
   oplot,c7*0+0.1,c11*0+0.65,psym=8,symsize=1.5
   xyouts,0.2,0.6,'RRL',col=col.black,charsize=cs,charthick=thickall
   xyouts,0.2,0.4,'Sesar et',col=col.black,charsize=cs,charthick=thickall
   xyouts,0.2,0.2,'al. 2009',col=col.black,charsize=cs,charthick=thickall
   if n_elements(magtype) ne 0 then xyouts,0.2,0.3,strtrim(magtype,1),col=col.black,charsize=cs,charthick=thickall
endif else begin
   xyouts,0.2,0.9,legendtxt,col=col.black,charsize=cs,charthick=thickall

   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.cyan, /FILL
   oplot,c7*0+0.1,c11*0+0.65,psym=8,symsize=1.5
   xyouts,0.2,0.6,'QSOs',col=col.black,charsize=cs,charthick=thickall

   PLOTSYM, circle, psize_QSO, THICK = THICK1, COLOR = col.red , /FILL
   oplot,c7*0+0.1,c11*0+0.35,psym=8,symsize=1.5
   xyouts,0.2,0.3,'Unknown',col=col.black,charsize=cs,charthick=thickall
endelse
endif
;==============


;==== x-axis histograms ====
if AIO eq 1 then plothist,Avalues(QSOentriesr),xc7,yc7,bin=binx,/noplot   ; calculating histogram vectors without plotting
if AIO eq 0 then plothist,c7(crs),xc7,yc7,bin=binx,/noplot   ; calculating histogram vectors without plotting
nyc7 = n_elements(yc7)                      ; getting number of bins
sumc = 0.0                                  ; resetting sum
for i=0,nyc7-1 do begin
   sumc = sumc + yc7(i)                     ; getting total number of objects in bins
endfor
yc7norm = yc7/sumc                          ; normalising to the total number (probability dist)

if FS eq 1 then begin
   plothist,a7(ars),xa7,ya7,bin=binx,/noplot   ; calculating histogram vectors without plotting
   nya7 = n_elements(ya7)                      ; getting number of bins
   suma = 0.0                                  ; resetting sum
   for i=0,nya7-1 do begin
      suma = suma + ya7(i)                     ; getting total number of objects in bins
   endfor
   ya7norm = ya7/suma                          ; normalising to the total number (probability dist)
endif

if RL eq 1 or AIO eq 1 then begin
   if AIO eq 1 then    plothist,Avalues(outentr),xb7,yb7,bin=binx,/noplot   ; calculating histogram vectors without plotting
   if RL eq 1 then plothist,b7(brs),xb7,yb7,bin=binx,/noplot   ; calculating histogram vectors without plotting
   nyb7 = n_elements(yb7)                      ; getting number of bins
   sumb = 0.0                                  ; resetting sum
   for i=0,nyb7-1 do begin
      sumb = sumb + yb7(i)                     ; getting total number of objects in bins
   endfor
   yb7norm = yb7/sumb                          ; normalising to the total number (probability dist)
endif

;=============================================================
;====calculating histogram (so I can get logarithmic bins)====

; setting the number of bins and the minimu and maximum exponents for the bin sizes
Nbins = 30.0
minexp = -2.1
maxexp = 0.05
bins = fltarr(Nbins+1) 
;claculating bin boarders
for l=0,Nbins do begin
   bins(l) = 10.^(minexp+(maxexp-minexp)/Nbins*l)
endfor
; defining arrays
bincen  = fltarr(Nbins)

if FS eq 1 then histval_a = fltarr(Nbins)
if RL eq 1 or AIO eq 1 then histval_b = fltarr(Nbins)
histval_c = fltarr(Nbins)

;vector to turn into histogram
if FS eq 1 then vec_a = a7(ars)
if RL eq 1 then vec_b = b7(brs)
if AIO eq 1 then vec_b = Avalues(outentr)
if AIO eq 0 then vec_c = c7(crs)
if AIO eq 1 then vec_c = Avalues(QSOentriesr)
; placing values of vec in bins
if FS eq 1 then binnedRatio_a = Value_Locate(bins,vec_a(sort(vec_a)))
if RL eq 1 or AIO eq 1 then binnedRatio_b = Value_Locate(bins,vec_b(sort(vec_b)))
binnedRatio_c = Value_Locate(bins,vec_c(sort(vec_c)))
; reset counter
if FS eq 1 then countall_a= 0.0
if RL eq 1 or AIO eq 1 then countall_b= 0.0
countall_c= 0.0
for i=1,n_elements(bins)-1 do begin
   ; getting and inserting histogram values
   if FS eq 1 then xx = where(binnedRatio_a eq i, count_a)
   if FS eq 1 then histval_a(i-1)=count_a+0.0
   if RL eq 1 or AIO eq 1 then xx = where(binnedRatio_b eq i, count_b)
   if RL eq 1 or AIO eq 1 then histval_b(i-1)=count_b+0.0
   xx = where(binnedRatio_c eq i, count_c)
   histval_c(i-1)=count_c+0.0

   bincen(i-1) = bins(i)+(bins(i)-bins(i-1))/2
   if FS eq 1 then countall_a = countall_a + count_a
   if RL eq 1 or AIO eq 1 then countall_b = countall_b + count_b
   countall_c = countall_c + count_c
endfor
;=============================================================


yminplot = 0.01
plot,c7(crs), psym=2 ,col=col.black $
        ,/nodata $
        ,xrange = xscat, /xstyle $
        ,yrange=[yminplot,1.0] , /ystyle $
	, charsize =cs $
        , charthick = thickall $
	, xthick = thickall $
	, ythick = thickall $
        ,/xlog $
        ,/ylog $
        , yticks = 2 $
        , xticks = 1 , xtickname = [' ',' '] $      ; removing the x ticks
        ,/noerase $
        ,pos=[0.12,0.8,0.8,0.98]


;---------------------- CREATING SHADED REGION ---------------------
;defining polygon coordinates (giving the points in clockwise order)
;defining vectors
for h=1,Nbins-1 do begin

if FS eq 1 then begin
xpoly = [bins(h),bins(h+1),bins(h+1),bins(h) ]
ypoly = [yminplot,yminplot,histval_a(h-1)/countall_a,histval_a(h-1)/countall_a]
; filling the polygon defined above
PolyFill, xpoly, ypoly, col=col.charcoal,clip=[yminplot,yminplot,1.0,1.0], NOCLIP=0 ;, /LINE_FILL, orientation=90,thick=8
endif

if RL eq 1 or AIO eq 1 then begin
xpoly = [bins(h),bins(h+1),bins(h+1),bins(h) ]
ypoly = [yminplot,yminplot,histval_b(h-1)/countall_b,histval_b(h-1)/countall_b]
; filling the polygon defined above
PolyFill, xpoly, ypoly, col=col.red,clip=[yminplot,yminplot,1.0,1.0], NOCLIP=0 ;, /LINE_FILL, orientation=90,thick=8
endif

xpoly = [bins(h),bins(h+1),bins(h+1),bins(h) ]
ypoly = [yminplot,yminplot,histval_c(h-1)/countall_c,histval_c(h-1)/countall_c]
; filling the polygon defined above
if AIO eq 0 then PolyFill, xpoly, ypoly, col=col.cyan,clip=[yminplot,yminplot,1.0,1.0], NOCLIP=0 ;, /LINE_FILL, orientation=90,thick=8
if AIO eq 1 then PolyFill, xpoly, ypoly, col=col.cyan,clip=[yminplot,yminplot,1.0,1.0], NOCLIP=0 ;, /LINE_FILL, orientation=90,thick=8

endfor
;------------------------------------------------------------------
if FS eq 1 then oplot,bincen,histval_a/countall_a,psym=10,col=col.black,linestyle=3,thick=thickall
if RL eq 1 or AIO eq 1 then oplot,bincen,histval_b/countall_b,psym=10,col=col.black,linestyle=4,thick=thickall
oplot,bincen,histval_c/countall_c,psym=10,col=col.black,linestyle=2,thick=thickall

; N_objects LEGEND
if n_elements(Nobj) ne 0 then xyouts,0.013,0.4,'N!Dobjects!N = '+Nobj,col=col.black,charsize=cs,charthick=thickall
; Sampling LEGEND
if n_elements(samp) ne 0 then xyouts,0.2,0.4,samp+' sampling',col=col.black,charsize=cs,charthick=thickall

;------------------------------------------------------------------
;------------------------------------------------------------------
;------------------------------------------------------------------
;==== y-axis histograms ====
if FS eq 1 then begin
plothist,a11(ars),xa11,ya11,bin=biny,/noplot   ; calculating histogram vectors without plotting
nya11 = n_elements(ya11)                      ; getting number of bins
suma = 0.0                                  ; resetting sums
for i=0,nya11-1 do begin
   suma = suma + ya11(i)               ; getting total number of objects in bins
endfor
ya11norm = ya11/suma                 ; normalising to the total number (probability dist)
endif

if RL eq 1 or AIO eq 1 then begin
if AIO eq 1 then plothist,gammas(outentr),xb11,yb11,bin=biny,/noplot
if RL eq 1 then plothist,b11(brs),xb11,yb11,bin=biny,/noplot
nyb11 = n_elements(yb11)
sumb = 0.0
for i=0,nyb11-1 do begin
   sumb = sumb + yb11(i)               ; getting total number of objects in bins
endfor
yb11norm = yb11/sumb
endif

plothist,c11(crs),xc11,yc11,bin=biny,/noplot
nyc11 = n_elements(yc11)
sumc = 0.0
for i=0,nyc11-1 do begin
   sumc = sumc + yc11(i)               ; getting total number of objects in bins
endfor
yc11norm = yc11/sumc

if YM eq 0 then ymaxp = 0.2

if AIO eq 0 then begin
   plothist,c11(crs),bin=biny,col=col.black, linestyle=2 $
        ,/rotate  $
        ,axiscolor=col.black $
        , xrange = [0.0,ymaxp], /xstyle $
        , yrange=yscat , /ystyle $
        ,/fill $
;        ,/fline  $
        , charthick = thickall $
	, xthick = thickall $
	, ythick = thickall $
        ,fcolor=col.cyan $
	, charsize =cs $
        ,/noerase $
        , peak = max(yc11norm) $   ; histogram normalised so largest bin has the peak value
        , xticks=2 $
;        , /xlog $
        , yticks = 1 , ytickname = [' ',' '] $      ; removing the y ticks
        ,pos=[0.8,0.12,0.97,0.8]
endif else begin
   plothist,gammas(QSOentriesr),bin=biny,col=col.black, linestyle=2 $
        ,/rotate  $
        ,axiscolor=col.black $
        , xrange = [0.0,ymaxp], /xstyle $
        , yrange=yscat , /ystyle $
        ,/fill $
;        ,/fline  $
        , charthick = thickall $
	, xthick = thickall $
	, ythick = thickall $
        ,fcolor=col.cyan $
	, charsize =cs $
        ,/noerase $
        , peak = max(yc11norm) $   ; histogram normalised so largest bin has the peak value
        , xticks=2 $
;        , /xlog $
        , yticks = 1 , ytickname = [' ',' '] $      ; removing the y ticks
        ,pos=[0.8,0.12,0.97,0.8]
endelse

if AIO eq 1 then begin
plothist,gammas(outentr),bin=biny,col=col.black, linestyle=4 $
        ,/rotate  $
        ,axiscolor=col.black $
        , xrange = [0.0,ymaxp], /xstyle $
        , yrange=yscat , /ystyle $
        ,/fill $
;        ,/fline  $
        , charthick = thickall $
	, xthick = thickall $
	, ythick = thickall $
	, charsize =cs $
        ,fcolor=col.red $
;        , /xlog $
        , xticks=2 $
        , yticks = 1 , ytickname = [' ',' '] $      ; removing the y ticks
        ,/noerase $
        ,peak = max(yb11norm) $   ; histogram normalised so largest bin has the peak value
        ,pos=[0.8,0.12,0.97,0.8]
endif

if RL eq 1 then begin
plothist,b11(brs),bin=biny,col=col.black, linestyle=4 $
        ,/rotate  $
        ,axiscolor=col.black $
        , xrange = [0.0,ymaxp], /xstyle $
        , yrange=yscat , /ystyle $
        ,/fill $
;        ,/fline  $
        , charthick = thickall $
	, xthick = thickall $
	, ythick = thickall $
	, charsize =cs $
        ,fcolor=col.red $
;        , /xlog $
        , xticks=2 $
        , yticks = 1 , ytickname = [' ',' '] $      ; removing the y ticks
        ,/noerase $
        ,peak = max(yb11norm) $   ; histogram normalised so largest bin has the peak value
        ,pos=[0.8,0.12,0.97,0.8]
endif

if FS eq 1 then begin
plothist,a11(ars),bin=biny,col=col.black, linestyle=3 $
        ,/rotate  $
        ,axiscolor=col.black $
        , xrange = [0.0,ymaxp], /xstyle $
        , yrange=yscat , /ystyle $
        ,/fill $
;        ,/fline  $
        , charthick = thickall $
	, xthick = thickall $
	, ythick = thickall $
        ,fcolor=col.charcoal $
	, charsize =cs $
        ,/noerase $
        , peak = max(ya11norm) $   ; histogram normalised so largest bin has the peak value
        , xticks=2 $
;        , /xlog $
        , yticks = 1 , ytickname = [' ',' '] $      ; removing the y ticks
        ,pos=[0.8,0.12,0.97,0.8]
endif



;overplotting the histogram lines:
if AIO eq 0 then plothist,c11(crs),bin=biny,col=col.black,/rotate, linestyle=2 , peak = max(yc11norm),/overplot,thick=thickall
if AIO eq 1 then plothist,gammas(QSOentriesr),bin=biny,col=col.black,/rotate, linestyle=2 , peak = max(yc11norm),/overplot,thick=thickall
;oplot,xa11,yc11norm,psym=10,col=col.black, linestyle=0 ,thick=thickall
if FS eq 1 then begin
plothist,a11(ars),bin=biny,col=col.black,/rotate, linestyle=3 , peak = max(ya11norm),/overplot,thick=thickall
endif
if RL eq 1 then begin
plothist,b11(brs),bin=biny,col=col.black,/rotate, linestyle=4 , peak = max(yb11norm),/overplot,thick=thickall
endif
if AIO eq 1 then begin
plothist,gammas(outentr),bin=biny,col=col.black,/rotate, linestyle=4 , peak = max(yb11norm),/overplot,thick=thickall
endif

;drawing an arrow to signal that the y hist goes further out
if FS eq 1 or RL eq 1 then ARROW, 0.13, 0.025, 0.23, 0.025,col=col.black,thick=thickall,/data,/solid,hsize=-0.2

if PS eq 1 then begin
   device, /close
   set_plot, 'x'
endif

print,':: bundlplot_aVSgamma.pro :: END OF PROGRAM    '
stop
END
