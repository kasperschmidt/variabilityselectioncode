
This is the README file for the variability selection algorithm presented by [Schmidt et al. (2010) ApJ 714:1194](http://adsabs.harvard.edu/abs/2010ApJ...714.1194S)

## Description 

The variability selection code contained in the tarball together with this README file concists
of several different routines. Each routine is shortly described in its header. The code is 
written in IDL and should be selfcontained. However, there are a few requirements to be able
to run the code (see below).

The routines are created with the purpose of testing the possibility of finding quasars with
variability in Pan-STARRS1 using SDSS data. Many of the routines therefore 'expects' data/input
in a 'SDSS data format', i.e., multiple bands and fits columns named as in the SDSS CasJobs 
catalogs. The variability selection is however single banded and having data from multiple
bands is therefore not required to use the code (dublicating the first band data to create 
'fake' columns for the other bands is an easy way to work around the input requirements).

The basic steps of the (default) code are the following:

1. Fits data is read and prepared for the input (possibly removing sparsely sampled objects).
2. Outliers from the data are removed via a medianizing of the photometric signals.
   Files containing the outliers and the NON-outliers are created.
3. Data without outliers is turned into structure function (like) data pairs.
4. These data pairs are fitted to a power law via MCMC and written to an output file
   named 'powerlawfit_characteristica_DATEandTIME_NAMETAG'.
4. Input data is downsampled to a Pan-STARRS1 cadence and step 2)-4) is repeated for this
   downsampled data. The output files are added DS to indicate the downsampling.

As described under 'Modifying Default Output' below the steps above can be changed with 
various keywords in the individual routines. The sequence outlined above is what the 
code will step through when running the program wothout modifications.

## Running the code 
The easiest way to run the code is to use the `multirun_magnification.pro`. This procedure
runs the code on one or several fits files which are listed in a simple text file (including 
the full path). Running this file by the follwing commands in an IDL envoirenment is all it
takes:

```
IDL> .com multirun_magnification.pro
IDL> .com multirun_magnification.pro    ; second time to re-compile with functions defined
IDL> multirun_magnification,'/path/to/directory/variabilityselection/filenames.txt',output,REMSPARSE=20,/VERBOSE
```
The tarball includes a 'working-example'. This example concists of the fits file 
`SDSSstripe82objects.fits` and the file filenamesexample.txt. The file contains epochs for
146 objects from SDSS stripe 82 downloaded from the publically available CasJobs server.
Setting the right path in the file `filenamesexample.txt` and running is as described above 
runs the (default) code as it was intented. The columns in the fits file are the minimum 
requirement to run the (default) code. This minimum requirement is described below.

## The input data 
The content of the input fits files are described in the following. The files concist of 
several objects measured at multiple epochs. Each line should correpond to one epoch for one
object. The individual epochs for a given object are 'bundled' together via the headobjid. 
Thus each epoch should have a `UNIQUE` id and each object a `UNIQUE` `headid`. Before running the
code the inout data should be sorted wrt. to the headobjid.

The (default) minimum required columns of the input fits file are:

```
objid            headobjid        z                ra               dec
MJD_u            MJD_g            MJD_r            MJD_i            MJD_z
PSFmag_u         PSFmag_g         PSFmag_r         PSFmag_i         PSFmag_z
PSFmagerr_u      PSFmagerr_g      PSFmagerr_r      PSFmagerr_i      PSFmagerr_z
deredPSFmag_u    deredPSFmag_g    deredPSFmag_r    deredPSFmag_i    deredPSFmag_z             
psfSigma1_u      psfSigma1_g      psfSigma1_r      psfSigma1_i      psfSigma1_z      
```
These correspond to:

* 1)     The unique IDs of the individual epochs.
* 2)     The IDs relating epochs of the same objects together.
* 3)     The estimated redshift at the given epoch (the object redshift).
* 4)     The right ascension in degrees.
* 5)     The declination in degrees.
* 6-10)  The MJDs of the individual measured epochs in the five (SDSS) bands.
* 7-15)  The PSF magnitudes of the individual measured epochs in the five (SDSS) bands.
* 16-20) The photometric error on the PSF magnitudes in the five (SDSS) bands.
* 21-25) The exctinction corrected PSF magnitudes of the individual measured epochs 
       in the five (SDSS) bands.
* 25-30) The seeing divided by the PSF FWHM of the individual measured epochs in the five 
        (SDSS) bands. In SDSS this is given as 'psfSigma1_u' corresponding to the inner 
        gaussian sigma for the composite fit).

As mentioned the variability selection is single banded and data from 5 bands is therefore
NOT needed. Using the r-columns for the real data and filling the rest with artificial data
(for instance by dublicating the r-band data) gives the desired result for the measurements 
in the r-band column.

## Requirements 
To run the code there are a few requirements. First of al it requires an up to date
(March 2010) version of the NASA IDL Astronomy library (http://idlastro.gsfc.nasa.gov/) to
run successfully. 
Seondly, a modified version of the `READCOL.pro` procedure is contained in the tarball. This
procedure is able to read long integer values as strings and is used to read long (SDSS) IDs 
of the epochs and objects. This version of `READCOL.pro` should be on the IDL path before
any other versions of `READCOL.pro`. Is that not the case by simply keeping it in the directory 
please make sure that this is so.
Lastly, the code needs getcolor.pro (also included in the tarball) to create the MCMC plots.

## Modifying Default Output 
The code is characterized by having been build step by step, and there are therefore several
ways to modify the output. This is done by various options, flags and keywords to the different
routines in the code. The possible changes of the output are described below. The default 
choices used when running the un-modified code as described above are marked with a *.
The programs are listed in the order they are called. For more details please refer to the 
headers of the individual routines.

```
-- multirun_magnification.pro
   REMSPARSE    Removing sparsely sampled objects from input.
   VERBOSE      Printing information to the screen.

-- removesparsesamples.pro
  *VERBOSE      Printing information to the screen.

-- magnification.pro
  *NAMETAG      Using a manually set and easy recognisable nametag in output file names
   ERRORFLOOR   Setting this flag puts an error floor on the magnitude errors.
  *MAG          Determines the magnitudes used in the calculations (set to de-reddened PSF 
                mags by default, i.e., fits columns named deredPSFmag).
  *NOBINNING    Keyword determining if binned structure functions or actual data pairs 
                (i.e. non-binned structure functions) are used in acchieving the power law 
                characteristica.
  *VERBOSE      Printing information to the screen.

-- bundlplot_Dmagoutliers.pro
   MAGCUT       Keyword to manually set the tollerance magnitude difference when medianizing
                light curves (default it 0.25 mag).

-- bundlplot_structurefctsNONout.pro
   WSTRUC       Creating an output file with the structure function details.
  *PWRLAWFILE   Enabeling the creationg of a file containing the results from the MCMC power
                law fits to the structure functions.
(*)NOBINNING    Choosing between binned and non-binned structure functions (default is
                determined by the keyword set in magnification.pro).
  *NOCOLOR      Disabeling the creation of a file containing the colors for the individual
                epochs.
  *VERBOSE      Printing information to the screen.

-- extractSubvector.pro
   REMOVEDENT   Returning array with the entries removed and not only the entries left after
                extracting the subvector.
   VERBOSE      Printing information to the screen.

-- structurefctSTR.pro
   PS1BIN       Using 4 bins suitable for a Pan-STARRS1 cadence instead of the default 10
                equally spaced bins in log.

-- nobin_datastruc.pro
   VERBOSE      Printing information to the screen.

-- writecolors.pro
   OUTNAME      Set to a string to manually give the output name.
   VERBOSE      Printing information to the screen.

-- powerlawmcmc.pro
(*)NOBINNING    Determing whether to fit binned or non-binned data (default determined by
                keyword set in bundlplot_structurefctsNONout.pro).
   SEED         Using a specific seed when running the MCMC (good for testing)
   PLOT         Plots the movement of the fit in the power law parameter space for each
                individual object.
   POSTSCRIPT   If plot is set this plots to postscript files instead of to the screen.
   VERBOSE      Printing information to the screen.

-- createFITSwOutliersMarked.pro
   VERBOSE      Printing information to the screen

-- PS1downsample.pro
  *DEREDPSF     Marking the de-reddened PSF magnitudes as well as the PSF magnitudes
                when downsampling the input data.
   VERBOSE      Printing information to the screen.
```


For further details please refer to [Schmidt et al. (2010)](http://adsabs.harvard.edu/abs/2010ApJ...714.1194S)
