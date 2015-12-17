;+
;----------------------------
;   NAME
;----------------------------
; multirun_magnification.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure reading in filenames of fits files from a text file, downsamples them
; and runs magnification.pro (without binning the data; can be changed though) on both 
; the parent and down-sampled file to create the A and gamma power law output files 
; (and others if set...).
;----------------------------
;   COMMENTS
;----------------------------
; The filenames read should contain the path to the files as well.
;----------------------------
;   INPUTS:
;----------------------------
; filenames       : name and path of a file containing the names and paths of the
;                   data fits files to run the magnification.pro on.
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; REMSPARSE      : set REMSPARSE= some integer to remove sparsely sampled objects
;                  which has #epochs<REMSPARSE
; /VERBOSE        : set /VERBOSE to get info/messages printed to the screen
;----------------------------
;   OUTPUTS:
;----------------------------
; output          : text file containing the output from the procedure
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; Running on files in filenames.txt with more epochs than 20
; IDL> multirun_magnification,'/path/of/file/filenames.txt',output,REMSPARSE=20,/VERBOSE
;----------------------------
;   BUGS
;----------------------------
;
;----------------------------
;   REVISION HISTORY
;----------------------------
; 2010-02-05  started by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
@ magnification.pro
@ namedate.pro
@ PS1downsample.pro
@ removesparsesamples.pro
@ createFITSwOutliersMarked.pro
;----------------------------
;-
PRO multirun_magnification,filenames,output,REMSPARSE=REMSPARSE,VERBOSE=VERBOSE

print,':: RUNALLmagnification.pro ::       ----------------------------------'
print,':: RUNALLmagnification.pro ::        BEGIN multirun_magnification.PRO  '
print,':: RUNALLmagnification.pro ::            ',systime(/UTC)
print,':: RUNALLmagnification.pro ::       ----------------------------------'

VB = n_elements(VERBOSE)
RS = n_elements(REMSPARSE)

FMT = 'A'
readcol,FORMAT=FMT,filenames,FN
Nfiles = n_elements(FN)
namedate,filenames,path,name,extension,date,dateus                ; chopping up input file name
output = 'multirun_magnification_output_'+name+'_'+dateus+'.txt'  ; creating output name
openw,77,output

MAGin = 2;0                     ; choosing to use exctinction corrected magnitudes in calculations 
                              ; (see header of magnification.pro for alternatives)

if Nfiles gt 1 then begin     ; checking that looping makes sense
 for i=0,Nfiles-1 do begin    ; looping over files in filenames file
   file=FN[i]                                          ; Getting the i'th filename
   namedate,file,path,name,extension,date,dateus       ; chopping up input file name
   NT = '_multirun_'+name                              ; using file name as nametag

   if RS eq 1 then begin
      epochs = remsparse
      removesparsesamples,file,epochs,file_remsparse,/VERBOSE   ; removing sparsely sampled objects
   endif else begin
      file_remsparse = file
   endelse

   if VB eq 1 then magnification,INFILE=file_remsparse,f1,f2,f3,f4,f5,/VERBOSE,NAMETAG=NT,/NOBINNING,MAG=MAGin
   if VB eq 0 then magnification,INFILE=file_remsparse,f1,f2,f3,f4,f5,NAMETAG=NT,/NOBINNING,MAG=MAGin

   createFITSwOutliersMarked,file_remsparse,f1,FITSout,/VERBOSE
   PS1downsample,FITSout,fileDS,/deredPSF                        ; downsampling data

   if VB eq 1 then magnification,INFILE=fileDS,f1DS,f2DS,f3DS,f4DS,f5DS,/VERBOSE,NAMETAG=NT+'DS',/NOBINNING,MAG=MAGin
   if VB eq 0 then magnification,INFILE=fileDS,f1DS,f2DS,f3DS,f4DS,f5DS,NAMETAG=NT+'DS',/NOBINNING,MAG=MAGin

   ;========================================================================================
   ; printing output to screen if verbose is set
   if VB eq 1 then begin
      print,' '
      print,'================================================================================'
      print,' Parent file                   : ',strtrim(file,1)
      print,' File with sparse samples rem. : ',strtrim(file_remsparse,1)
      print,' The outliers file             : ',strtrim(f1,1)
      print,' The NONoutliers file          : ',strtrim(f2,1)
      print,' The structure function data   : ',strtrim(f3,1)
      print,' The color terms               : ',strtrim(f4,1)
      print,' The power law characteristica : ',strtrim(f5,1)
      print,' -------- DOWN-SAMPLED --------'
      print,' The parent file               : ',strtrim(fileDS,1)
      print,' The outliers file             : ',strtrim(f1DS,1)
      print,' The NONoutliers file          : ',strtrim(f2DS,1)
      print,' The structure function data   : ',strtrim(f3DS,1)
      print,' The color terms               : ',strtrim(f4DS,1)
      print,' The power law characteristica : ',strtrim(f5DS,1)
      print,'================================================================================'
   endif

   ;=======================================================================================
   ; printing output to file
   printf,77,' '
   printf,77,'#================================================================================'
   printf,77,' Parent file                   : ',strtrim(file,1)
   printf,77,' File with sparse samples rem. : ',strtrim(file_remsparse,1)
   printf,77,' The outliers file             : ',strtrim(f1,1)
   printf,77,' The NONoutliers file          : ',strtrim(f2,1)
   printf,77,' The structure function data   : ',strtrim(f3,1)
   printf,77,' The color terms               : ',strtrim(f4,1)
   printf,77,' The power law characteristica : ',strtrim(f5,1)
   printf,77,'# -------- DOWN-SAMPLED --------'
   printf,77,' The parent file               : ',strtrim(fileDS,1)
   printf,77,' The outliers file             : ',strtrim(f1DS,1)
   printf,77,' The NONoutliers file          : ',strtrim(f2DS,1)
   printf,77,' The structure function data   : ',strtrim(f3DS,1)
   printf,77,' The color terms               : ',strtrim(f4DS,1)
   printf,77,' The power law characteristica : ',strtrim(f5DS,1)
   printf,77,'#================================================================================'
   
 endfor 
endif else begin  ; if only one file is given in the filenames file
   i=0
   file=FN[i]                                          ; Getting the i'th filename
   namedate,file,path,name,extension,date,dateus       ; chopping up input file name
   NT = '_multirun_'+name                              ; using file name as nametag

   if RS eq 1 then begin
      epochs = remsparse
      removesparsesamples,file,epochs,file_remsparse,/VERBOSE   ; removing sparsely sampled objects
   endif else begin
      file_remsparse = file
   endelse

   if VB eq 1 then magnification,INFILE=file_remsparse,f1,f2,f3,f4,f5,/VERBOSE,NAMETAG=NT,/NOBINNING,MAG=MAGin
   if VB eq 0 then magnification,INFILE=file_remsparse,f1,f2,f3,f4,f5,NAMETAG=NT,/NOBINNING,MAG=MAGin

   createFITSwOutliersMarked,file_remsparse,f1,FITSout,/VERBOSE
   PS1downsample,FITSout,fileDS,/deredPSF                        ; downsampling data

   if VB eq 1 then magnification,INFILE=fileDS,f1DS,f2DS,f3DS,f4DS,f5DS,/VERBOSE,NAMETAG=NT+'DS',/NOBINNING,MAG=MAGin
   if VB eq 0 then magnification,INFILE=fileDS,f1DS,f2DS,f3DS,f4DS,f5DS,NAMETAG=NT+'DS',/NOBINNING,MAG=MAGin

   ;========================================================================================
   ; printing output to screen if verbose is set
   if VB eq 1 then begin
      print,' '
      print,'================================================================================'
      print,' Parent file                   : ',strtrim(file,1)
      print,' File with sparse samples rem. : ',strtrim(file_remsparse,1)
      print,' The outliers file             : ',strtrim(f1,1)
      print,' The NONoutliers file          : ',strtrim(f2,1)
      print,' The structure function data   : ',strtrim(f3,1)
      print,' The color terms               : ',strtrim(f4,1)
      print,' The power law characteristica : ',strtrim(f5,1)
      print,' -------- DOWN-SAMPLED --------'
      print,' The parent file               : ',strtrim(fileDS,1)
      print,' The outliers file             : ',strtrim(f1DS,1)
      print,' The NONoutliers file          : ',strtrim(f2DS,1)
      print,' The structure function data   : ',strtrim(f3DS,1)
      print,' The color terms               : ',strtrim(f4DS,1)
      print,' The power law characteristica : ',strtrim(f5DS,1)
      print,'================================================================================'
   endif

   ;=======================================================================================
   ; printing output to file
   printf,77,' '
   printf,77,'#================================================================================'
   printf,77,' Parent file                   : ',strtrim(file,1)
   printf,77,' File with sparse samples rem. : ',strtrim(file_remsparse,1)
   printf,77,' The outliers file             : ',strtrim(f1,1)
   printf,77,' The NONoutliers file          : ',strtrim(f2,1)
   printf,77,' The structure function data   : ',strtrim(f3,1)
   printf,77,' The color terms               : ',strtrim(f4,1)
   printf,77,' The power law characteristica : ',strtrim(f5,1)
   printf,77,'# -------- DOWN-SAMPLED --------'
   printf,77,' The parent file               : ',strtrim(fileDS,1)
   printf,77,' The outliers file             : ',strtrim(f1DS,1)
   printf,77,' The NONoutliers file          : ',strtrim(f2DS,1)
   printf,77,' The structure function data   : ',strtrim(f3DS,1)
   printf,77,' The color terms               : ',strtrim(f4DS,1)
   printf,77,' The power law characteristica : ',strtrim(f5DS,1)
   printf,77,'#================================================================================'
endelse

print,' '
print,':: multirun_magnification.pro :: The output was written to the file ',output
print,' '
close,77
print,':: multirun_magnification.pro ::       -----------------------------------'
print,':: multirun_magnification.pro ::        END OF multirun_magnification.PRO  '
print,':: multirun_magnification.pro ::           ',systime(/UTC)
print,':: multirun_magnification.pro ::       -----------------------------------'
END
