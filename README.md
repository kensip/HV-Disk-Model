# Model Information and History

This is a geometric model representing a warped, precessing accretion disk around an X-ray pulsar. It has been successfully used to reproduce the energy-resolved pulse profiles of SMC X-1, Her X-1, and LMC X-4.

The code was originally developed by Ryan C. Hickox and presented in Hickox & Vrtilek (2005). This paper describes many features of the model and can be found here: https://iopscience.iop.org/article/10.1086/491596 .
Further information on the model can also be found in Brumback et al. (2020) and Sippy et al. (in prep). All code was authored by Ryan C. Hickox, with the exception of fitplotprof_single.pro which was added by McKinley C. Brumback, and convertidltotxt.pro and pythondiskplots.ipynb which were added by Kendall I. Sippy.

This is the first version of this model that is publicly available, with documentation written by Kendall I. Sippy. 

# Installation

You will need IDL installed on your computer, with a working license, to run this code. There are future plans to translate the model into Python to make it more accessible.

Download all files included above. No other IDL astronomy software is required to run this code--- I have included copies of any strictly necessary IDL astronomy software in this repository, and modified the code to eliminate others. All files except fitplotprof_single, convertidltotxt.pro, and pythondiskplots.ipynb are part of the simulation itself. Those latter files will be used to export the model pulse profiles to a Python-readable format, export the accretion disk plots to a Python-readable format, and plot the accretion disk geometry in Python, respectively.

# Generating the Blackbody Fraction File
Open the file bbfrac.pro and set the following:
1. The name of the output file ('fname')
2. The folder the output file will go to ('ftop')

Then run this procedure, with your desired minimum and maximum energy (the lowest energy of your soft X-ray bin, and the highest energy of your hard X-ray bin), and any temperature between $10^4 \, K$ and $10^8 \, K$. Compile the bbfrac.pro file and then run the function using the following script:

``` bbfrac(elo,ehi,T) ```

Now go into the file dtmpspec.pro and replace the variable 'bbfracgrid' with the path to the file you just generated. Save this file before proceeding.

# Setting Model Parameters
All parameters are set via the fit_inp.pro file. 

Open the file fit_inp.pro and set the following:
1. The name of the output folder for all model output ('topdir')
2. All disk and beam parameters (labelled with comments)-- describe in more detail.

Note that there are different blocks of code to set parameters for fan or pencil beam geometries, so be sure you enter the disk and beam parameters in the correct section for the type of simulation you wish to run.

Save, compile, and run this procedure using the following script:

``` .compile fit_inp.pro```
``` .run fit_inp.pro```

# Running the Simulation
The simulation is run via the fit_run.pro file. The model parameters must already be set (via compiling and running fit_inp.pro within the same IDL session) before running this file.
