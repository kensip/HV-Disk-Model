# Model Information and History

This is a geometric model representing a warped, precessing accretion disk around an X-ray pulsar. It has been successfully used to reproduce the energy-resolved pulse profiles of SMC X-1, Her X-1, and LMC X-4.

The code was originally developed by Ryan C. Hickox and presented in Hickox & Vrtilek (2005). This paper describes many features of the model and can be found here: https://iopscience.iop.org/article/10.1086/491596 .
Further information on the model can also be found in Brumback et al. (2020) and Sippy et al. (in prep). All code was authored by Ryan C. Hickox, with the exception of fitplotprof_single.pro which was added by McKinley C. Brumback, and convertidltotxt.pro and pythondiskplots.ipynb which were added by Kendall I. Sippy.

This is the first version of this model that is publicly available, with documentation written by Kendall I. Sippy. 

# Installation

You will need IDL installed on your computer, with a working license, to run this code. There are future plans to translate the model into Python to make it more accessible.

Download all files included above. No other IDL astronomy software is required to run this code--- I have included copies of any strictly necessary IDL astronomy software in this repository, and modified the code to eliminate others. All files except fitplotprof_single, convertidltotxt.pro, and pythondiskplots.ipynb are part of the simulation itself. Those latter files will be used to export the model pulse profiles to a Python-readable format, export the accretion disk plots to a Python-readable format, and plot the accretion disk geometry in Python, respectively.

# Setting Model Parameters
All parameters are set via the fit_inp.pro file. Be sure to change the 'topdir' (where you want model output files to save) before running. All model parameters are set by typing their values into this file. Note that there are different blocks of code to set parameters for fan or pencil beam settings, so be sure you enter the parameters in the correct section for the type of simulation you wish to run.

# Generating the Blackbody Fraction File

# Running the Simulation
The simulation is run via the fit_run.pro file. The model parameters must already be set (via running fit_inp.pro within the same IDL session) before running this file.
