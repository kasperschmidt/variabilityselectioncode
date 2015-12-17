;+
;----------------------------
;   NAME
;----------------------------
; powerlawmcmc.pro
;----------------------------
;   PURPOSE/DESCRIPTION
;----------------------------
; Procedure fitting a set of input data to a power law
; returning the normalisation coefficient (amplitude A) and
; exponent (gamma) in a new fitresult array
;----------------------------
;   COMMENTS
;----------------------------
;
;----------------------------
;   INPUTS:
;----------------------------
; data       : structure containing data for N sets of data (on the form
;              data(N).dt(*), data(N).value(*) and data(N).valueerr(*))
;              to be fitted with a power law that has the form y=A*x^gamma
;              where value = y and dt = x.
;              With the NOBINNING option, value must be an array of magnitudes
;              and valueerr is an array of their errors
; N          : the number of data sets to be fitted
;----------------------------
;   OPTIONAL INPUTS:
;----------------------------
; /NOBINNING : Infer A and gamma from magnitude data directly
; seed       : seed=some integer to give (and run) with the same seed every time
; /PLOT      : Set /PLOT to plot the movement in the (A,gamma) space and the actual fits
;              NB: creates a plotseries for EVERY data bundle.
; /VERBOSE   : Set /VERBOSE to print information to the screen
; /POSTSCRIPT: set /POSTSCRIPT to make .eps files of plots
;----------------------------
;   OUTPUTS:
;----------------------------
; fitresult  : Array containing the exponents and the coefficients of the
;              power law fits to the inoput data on the form (N,14) where
;              fitresult(N,0)=A0       (best-fit sample A)              - for last half of sample
;              fitresult(N,1)=medianA  (median sample A)                - for last half of sample
;              fitresult(N,2)=Aerrplus (upper 68% confidence limit)     - for last half of sample
;              fitresult(N,3)=Aerrminus (lower 68% confidence limit)    - for last half of sample
;              fitresult(N,4)=gamma0       (best-fit sample gamma)      - for last half of sample
;              fitresult(N,5)=mediangamma  (median sample gamma)        - for last half of sample
;              fitresult(N,6)=gammaerrplus (upper 68% confidence limit) - for last half of sample
;              fitresult(N,7)=gammaerrminus (lower 68% confidence limit)- for last half of sample
;              fitresult(N,8)=The minimum reduced chi-squared value of the fit
;              fitresult(N,9)=Number of samples taken during fit
;              fitresult(N,10)=Aerrplus (95% confidence limit)          - for last half of sample
;              fitresult(N,11)=Aerrminus (95% confidence limit)         - for last half of sample
;              fitresult(N,12)=gammaerrplus (95% confidence limit)      - for last half of sample
;              fitresult(N,13)=gammaerrminus (95% confidence limit)     - for last half of sample
;   NB: if using the /NOBINNING option, "chisq" = -2 log Lhood(unnormalised)
;        = sum_i dm_i^2/(V^2 + sigma_i^2)
; A          : the individual As for all the MCMC steps
; gamma      : the individual gammas for all the MCMC steps
;----------------------------
;   EXAMPLES/USAGE
;----------------------------
; IDL> powerlawmcmc,data,N,fitresult,A,gamma,/NOBINNING
;----------------------------
;   BUGS
;----------------------------
;
;----------------------------
;   REVISION HISTORY
;----------------------------
; 2009-07-01  started by P. J. Marshall (UCSB) and K. B. Schmidt (MPIA)
; 2009-07-03  NOBINNING option added by P. J. Marshall (UCSB)
; 2009-07-07  plotting for N>1 enabled by K. B. Schmidt (MPIA)
; 2009-12-18  95% confidence limit added by K. B. Schmidt (MPIA)
;----------------------------
;   DEPENDENCIES
;----------------------------
;
;----------------------------
;-
PRO powerlawmcmc,data,N,fitresult,A,gamma, NOBINNING=NOBINNING, seed=seed, PLOT=PLOT, VERBOSE=VERBOSE, POSTSCRIPT=POSTSCRIPT

vb        = n_elements(VERBOSE)
disp      = n_elements(PLOT)
ps        = n_elements(POSTSCRIPT)
NOBINNING = n_elements(NOBINNING)
style     = NOBINNING

fitresult   = fltarr(N,14)           ;defining outpur array

for i=0l,N-1 do begin                ; Loop over objects
   xs = size(data[i].dt[*])          ; Get size of data set
   xsize = xs(1)
   ys = size(data[i].value[*])
   ysize = ys(1)
   es = size(data[i].valueerr[*])
   esize = es(1)

   if xsize ne ysize then begin      ;error message if no of x and y values are different
      print, ':: powerlawmcmc.pro :: Size of x and y components are not the same'
      print, ':: powerlawmcmc.pro :: for data set no. ',i,'fit cannot be performed'
   endif

   ;defining and filling x and y arrays for fitting: (x arrives in days, put in years)
   x = fltarr(xsize)
   y = fltarr(ysize)
   yerr = fltarr(esize)
   x = data[i].dt(*)/365.25
   y = data[i].value(*)
   yerr = data[i].valueerr(*)
   index = where(yerr gt 0)
   ;printing error message if all error values are 0 or less... something must be wrong!
   emptyarr = [-1]
   if index eq emptyarr then begin
      print,' '
      print,':: powerlawmcmc.pro :: All errors are 0 or < 0 in object ',i,'... something is wrong with input data!!'
      print,' '
   endif
   x = x[index]
   y = y[index]
   yerr = yerr[index]
   ndata = n_elements(index)
   if (NOBINNING) then begin
;  Need to compute magnitude differences, and their uncertainties.
;  Ignore correlations between errors!!
     m1 = y#(fltarr(ndata)*0.0 + 1.0)
     m2 = (fltarr(ndata)*0.0 + 1.0)#y
     dm = m1 - m2
     t1 = x#(fltarr(ndata)*0.0 + 1.0)
     t2 = (fltarr(ndata)*0.0 + 1.0)#x
     dt = abs(t1 - t2)
;  Following should really be covariance matrix............
     var1 = (yerr*yerr)#(fltarr(ndata)*0.0 + 1.0)
     var2 = (fltarr(ndata)*0.0 + 1.0)#(yerr*yerr)
     dmerr = sqrt(var1 + var2)
;  Extract lower left corner of these matrices back into y:
     imatrix = (intarr(ndata)+1)#indgen(ndata) - indgen(ndata)#(intarr(ndata)+1)
     index = where(imatrix gt 0)
     x = dt[index]
     y = dm[index]
     yerr = dmerr[index]
     ndata = n_elements(index)
   endif

;  Prepare for MCMC sampling run:
;  Define intial estimates of coefficients
   thetahere = [0.1,0.1]
   thetathere = fltarr(2)*0.0

;  Gaussian proposal distribution: not too big, not too small:;
   width = [0.05,0.05]
;  if (n_elements(seed) eq 0) then seed = 523123

;  How many samples?
   Nsamples = 1000
   A = fltarr(Nsamples)*0.0
   gamma = fltarr(Nsamples)*0.0

;  Starting temperature:
   lambda0 = 1e-3
   loglambda0 = alog(lambda0)
   lambda = lambda0

;  Compute log posterior at current position:
   chisqhere = chisq(thetahere,x,y,yerr,style)
   chisqmin = chisqhere
   logLhere = chisqhere[1] - chisqhere[0]/2.0
   logLmax = logLhere
   logphere = logAprior(thetahere[0]) + loggammaprior(thetahere[1]) $
              + lambda*logLhere

   if vb eq 1 then print, "initially, logL = ",logLhere,"  A = ",thetahere[0],"  gamma = ",thetahere[1],  "  logAprior = ",logAprior(thetahere[0]),"  loggammaprior = ",loggammaprior(thetahere[1]),"  chisq/2 = ",chisqhere/2.0

;  Start plot:
   if disp eq 1 then begin
      ;plotting a,gamma and fits to data for inspection of data and loop
      col=getcolor(/load)     ; get color table for plot
      device, retain=2        ; ensuring that plotting windows 'regenerate'

      !p.multi = [0,2,1]
      window, 1, xsize=1100, ysize=500
      plot, /xlog, A*0+thetahere[0],gamma*0+thetahere[1],psym=2$
              ,xrange=[1e-5,10.] , /xstyle $
              ,yrange = [0.,3.], /ystyle
      p1 = !P & x1 = !X & y1 = !Y
      if (NOBINNING) then begin
        plot,x,y,psym=4  $
              ,xrange=[0.,4.0] , /xstyle
      endif else begin
        plot,x,y,psym=4  $
              ,xrange=[0.,4.0] , /xstyle
        oploterror,x,y,yerr,psym=4, col=col.white, ERRCOLOR=col.green
      endelse
      p2 = !P & x2 = !X & y2 = !Y
   endif

; Start sampling:
   for k=0L,Nsamples-1 do begin
      if (k eq Nsamples/2) then begin
         width[0] = stddev(alog10(A[Nsamples/4:Nsamples/2-1]))/10.0
         width[1] = stddev(gamma[Nsamples/4:Nsamples/2])/10.0
         if vb eq 1 then print, "Final proposal distribution width = ",width
      endif

      ; Propose a new position over there:
      propose:
      dx = [(RandomN(seed,1)*width[0]),(RandomN(seed,1)*width[1])]
      thetathere[0] = 10.0^(alog10(thetahere[0]) + dx[0])
      thetathere[1] = thetahere[1] + dx[1]

      ; Compute log likelihood at proposed position:
      chisqthere = chisq(thetathere,x,y,yerr,style)
      logLthere = chisqthere[1] - chisqthere[0]/2.0
      ; Make sure all samples are drawn inside parameter volume!
      piA = logAprior(thetathere[0])
      pigamma = loggammaprior(thetathere[1])
      if (piA eq -1.0e32 or pigamma eq -1.0e32) then goto, propose
      ; Combine into log posterior:
      logpthere = piA + pigamma + lambda*logLthere

      ; Metropolis-Hastings:
      logalpha = logpthere - logphere
      if (logalpha gt 0.0) then begin
        thetahere = thetathere  ; Always move if new position has higher posterior PDF!
        chisqhere = chisqthere
        logLhere = logLthere
        logphere = logpthere
      endif else begin
        stay = alog(RandomU(seed,1)) - logalpha
        if (stay gt 0) then begin
          thetahere = thetahere ; Stay put if Prob ratio is not large enough
        endif else begin
          thetahere = thetathere ; Move (sometimes) - if Prob ratio is greater than random number
          chisqhere = chisqthere
          logLhere = logLthere
          logphere = logpthere
        endelse
      endelse

      ; Update temperature:
      if (k le Nsamples/2) then begin
        loglambda = loglambda0*(1.0 - float(k)/float(Nsamples/2))
      endif else begin
        loglambda = 0.0
      endelse
      lambda = exp(loglambda)
      ; Update posterior for next iteration:
      piA = logAprior(thetahere[0])
      pigamma = loggammaprior(thetahere[1])
      logLhere = chisqhere[1] - chisqhere[0]/2.0
      logphere = piA + pigamma + lambda*logLhere

      ; Add parameter vector to growing list of samples:
      A[k] = thetahere[0]
      gamma[k] = thetahere[1]

      ; Keep track of maximum likelihood and best parameters:
      if (logLhere gt logLmax) then begin
        logLmax = logLhere
        chisqmin = chisqhere
        bestA = A[k]
        bestgamma = gamma[k]
      endif
      if vb eq 1 then print, "sample ",k,"  logL = ",logLhere,"  A = ",A[k],"  gamma = ",gamma[k],"  lambda = ",lambda

      if disp eq 1 then begin
        if (k le Nsamples/2) then begin
            colour = col.red
        endif else begin
            colour = col.cyan
        endelse

        !P = p1 & !X = x1 & !Y = y1
        oplot,A*0+A[k],gamma*0+gamma[k],psym=2,col=colour

        !P = p2 & !X = x2 & !Y = y2
        powerlaw = A[k]*x^gamma[k]
        oplot,x,powerlaw,col=colour
      endif
   endfor

   tmp = A[Nsamples/2:Nsamples-1]
   Ns = n_elements(tmp)
   As = tmp[sort(tmp)]
   medianA = As[0.5*Ns]
   ; 68% confidence level
   lowerA = As[0.16*Ns]
   upperA = As[0.84*Ns]
   Aerrplus = upperA - medianA
   Aerrminus = medianA - lowerA
   ; 95% confidence level (2 sigma)
   lowerA2 = As[0.025*Ns]
   upperA2 = As[0.975*Ns]
   Aerrplus2 = upperA2 - medianA
   Aerrminus2 = medianA - lowerA2

   fitresult[i,0] = bestA
   fitresult[i,1] = medianA
   fitresult[i,2] = Aerrplus
   fitresult[i,3] = Aerrminus

   fitresult[i,10]= Aerrplus2
   fitresult[i,11]= Aerrminus2

   tmp = gamma[Nsamples/2:Nsamples-1]
   gammas = tmp[sort(tmp)]
   Ns = n_elements(tmp)
   mediangamma = gammas[0.5*Ns]
   ; 68% confidence level
   lowergamma = gammas[0.16*Ns]
   uppergamma = gammas[0.84*Ns]
   gammaerrplus = uppergamma - mediangamma
   gammaerrminus = mediangamma - lowergamma
   ; 95% confidence level (2 sigma)
   lowergamma2 = gammas[0.025*Ns]
   uppergamma2 = gammas[0.975*Ns]
   gammaerrplus2 = uppergamma2 - mediangamma
   gammaerrminus2 = mediangamma - lowergamma2

   fitresult(i,4) = bestgamma
   fitresult(i,5) = mediangamma
   fitresult(i,6) = gammaerrplus
   fitresult(i,7) = gammaerrminus

   fitresult(i,12)= gammaerrplus2
   fitresult(i,13)= gammaerrminus2

   fitresult(i,8) = chisqmin[0]/float(n_elements(x) - 2)
   fitresult(i,9) = Nsamples

   ;plotting data and best point with errorbars when all iterations have been done
   if (disp eq 1) then begin
      !P = p1 & !X = x1 & !Y = y1
      oplot,A*0+medianA,gamma*0+mediangamma,psym=2,col=col.white
        oploterror, A*0+medianA,gamma*0+mediangamma,A*0+Aerrplus, gamma*0+gammaerrplus,psym=4, col=col.white, ERRCOLOR=col.green, /HIBAR; , psym=3, /NOHAT
        oploterror, A*0+medianA,gamma*0+mediangamma,A*0+Aerrplus, gamma*0+gammaerrminus,psym=4, col=col.white, ERRCOLOR=col.green, /LOBAR; , psym=3, /NOHAT

      !P = p2 & !X = x2 & !Y = y2
      oplot,x,y,psym=4,col=col.white
      oploterror,x,y,yerr,psym=4, col=col.white, ERRCOLOR=col.green
   endif

; Start plot to postscript file:
   if ps eq 1 then begin
;       ---DEFINE OUTPUT FILE---
        num = STRTRIM(i+1,1)
        plot_name = 'idloutput/powerlawMCMC'+num+'.eps'
;       ---SET UP THE PLOT---
        set_plot, 'ps'
        device, xsize=35, ysize=20, file=plot_name, /encapsul,/color
        col=getcolor(/load)     ; get color table for plot
        ;plotting a,gamma and fits to data for inspection of data and loop
      !p.multi = [0,2,1]
      plot, /xlog, A,gamma,col=col.black, psym=2  
      oplot, A,gamma,col=col.red, psym=2
      oplot, A[Nsamples/2:Nsamples-1],gamma[Nsamples/2:Nsamples-1],col=col.cyan,psym=2
      oplot,A*0+medianA,gamma*0+mediangamma,psym=2,col=col.cyan
        oploterror, A*0+medianA,gamma*0+mediangamma,A*0+Aerrplus, gamma*0+gammaerrplus,psym=4, col=col.cyan, ERRCOLOR=col.green, /HIBAR; , psym=3, /NOHAT
        oploterror, A*0+medianA,gamma*0+mediangamma,A*0+Aerrplus, gamma*0+gammaerrminus,psym=4, col=col.cyan, ERRCOLOR=col.green, /LOBAR; , psym=3, /NOHAT

      plot, x,y,psym=4,col=col.black

;     Defining and calculating powerlaws for ps plot and overplotting them
      As = n_elements(A)
      powerlaws = fltarr(As,n_elements(x))

      for j = 0l,As/2-1 do begin
         powerlaws(j,*) = A(j)*x^(gamma(j))
         oplot,x,powerlaws(j,*),col=col.red
      endfor
      for h = As/2,As-1 do begin
         powerlaws(h,*) = A(h)*x^(gamma(h))
         oplot,x,powerlaws(h,*),col=col.cyan
      endfor

      if NOBINNING ne 1 then oploterror,x,y,yerr,psym=4, col=col.black, ERRCOLOR=col.green
      device, /close
      set_plot, 'x'
   endif
endfor

END

;--- Define the prior PDF for A:
FUNCTION logAprior,A
; Uniform prior:
;   if (A lt 0.0 or A gt 1.0) then begin
;     logf = -1.0e32
;   endif else begin
;     f = 1.
;     logf = alog(f)
;   endelse
; Jeffreys prior:
   logAmin = -5
   logAmax =  1
   logA = alog10(A)
   if (logA lt logAmin or logA gt logAmax) then begin
     logf = -1.0e32
   endif else begin
     logf = -logA
   endelse
   return, logf
END

;--- Define the prior PDF for gamma:
FUNCTION loggammaprior,gamma
   if (gamma lt 0.0) then begin
     logf = -1.0e32
   endif else begin
     f = 1.0/(1.0 + gamma*gamma)
     logf = alog(f)
   endelse
   return, logf
END

;--- Define the chi-squared, assuming Gaussian errors on y:
; This is really a function to compute likelihood - and in fact returns
; both the chisq and the normalisation of the likelihood, such that 
;   log likelihood = chisq[1] - chisq[0]/2.0
; BAROQUE!
FUNCTION chisq,theta,x,y,yerr,style

; ------------------------------------
; BINNED DATA:
if (style eq 0) then begin
   yp = theta[0] * x^theta[1]                      ; Predicted data
   chisq = [total((y - yp)*(y - yp)/(yerr*yerr))]  ; Misfit function
   logZ = 0.0     ;Don't bother with normalisation of likelihood...   

; ------------------------------------
; UNBINNED DATA, just dm +/- error:
endif else if (style eq 1) then begin
   sigma = theta[0] * x^theta[1]                    ; Model predicts intrinsic scatter sigma
   vareff = sigma*sigma + yerr*yerr
   logZ = -0.5*total(alog(2*!pi*vareff))            ; Normalisation terms
   chisq = [total(y*y/vareff)]                      ; "Misfit" chi-sq like term
endif
; ------------------------------------
chisq = [chisq,logZ]                                ; Package up the two components
return, chisq
END