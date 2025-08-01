# Model Information and History

This is a geometric model representing a warped, precessing accretion disk around an X-ray pulsar. It has been successfully used to reproduce the energy-resolved pulse profiles of SMC X-1, Her X-1, and LMC X-4.

The code was originally developed by Ryan C. Hickox and presented in Hickox & Vrtilek (2005). This paper describes many features of the model and can be found here: https://iopscience.iop.org/article/10.1086/491596 .
Further information on the model can also be found in Brumback et al. (2020) and Sippy et al. (in prep).

This is the first version of this model that is publicly available, with documentation written by Kendall I. Sippy. 

# Installation

You will need IDL installed on your computer, with a working license, to run this code. There are future plans to translate the model into Python to make it more accessible.

Download all files included above. No other IDL astronomy software is required to run this code--- I have included copies of any strictly necessary IDL astronomy software in this repository (authors of these software are noted within files). 

All files except fitplotprof_single.pro, plotdisk.pro, convertidltotxt.pro, and pythondiskplots.ipynb are part of the simulation itself. Those latter files will be used to plot the pulse profiles in IDL and export the model pulse profiles to a Python-readable format, plot the disk in IDL, export the accretion disk plots to a Python-readable format, and plot the accretion disk geometry in Python, respectively.

# Generating the Blackbody Fraction File
Before running the model for the first time, you will need to generate an array that contains the fraction of the total blackbody radiation is emitted within a given energy band (rows), if the source has a given temperature (columns). The file bbfrac.pro generates this grid of values, which is then interpolated upon to ultimately calculate the intensity of reprocessed emission from the accretion disk.

Open the file bbfrac.pro and set the following:
1. The name of the output file ('fname')
2. The folder the output file will go to ('ftop')

Then compile and run this procedure, with your desired minimum and maximum energy (the lowest energy of your soft X-ray bin, and the highest energy of your hard X-ray bin), and any temperature between $10^4$ K and $10^8$ K. Compile the bbfrac.pro file and then run the function using the following script:

```.compile bbfrac.pro```

```bbfrac(elo,ehi,T) ```

Now go into the file dtmpspec.pro and replace the variable 'bbfracgrid' with the path to the file you just generated. Save dtmpspec.pro before proceeding. You can also change the lower and upper energy limits desginated for the soft X-ray portion of the model's pulse profile (radiation from the disk) by changing the variables 'xlo' and 'xhi' in dtmpspec.pro--- they are set at 0.3 keV and 1 keV by default.

This step does not need to be repeated for subsequent model runs, unless you are changing the energy limits you desire in your model pulse profiles.

# Setting Model Parameters
All parameters are set via the fit_inp.pro file. The accretion column parameters are called 'beam' parameters throughout. All angles should be inputted in degrees.

Open the file fit_inp.pro and set the following:
1. The name of the output folder for all model output ('topdir')
2. Fan or pencil beam--- set the variable 'fan' to be either 'y' or 'n'.
3. Plotting the pulse profiles and disk in IDL (or not)--- set 'plotd' and 'plotpps' to 'y' or 'n' accordingly. It may helpful to see the plots in IDL if you are doing one simulation at a time or are new to the model. Data will be exported into a Python-readable form regardless of if these are run.
4. Constant parameters--- the observer elevation ('obselevdeg') and source luminosity ('lum38', in units of $10^{38}$ erg/s) should be set to constants according to the source you are modeling.
5. Variable beam parameters--- the latitude of beam 1 ('beamangdeg1'), latitude of beam 2 ('beamangdeg2'), and longitude of beam 2 relative to beam 1 ('long2vdeg', beam 1 longitude is always set to 0). These intrinsically allow for dipolar or non-dipolar accretion column orientations. Set to one value, or an array of several values. Be sure to avoid setting them to integers; always type '20.' rather than '20'.
6. Variable disk parameters--- the inner tilt angle ('tiltindeg'), outer tilt angle ('tiltoutdeg'), and twist angle/ phase offset between the inner and outer disk ('phsoffvdeg'). These can be set to multiple values or a single value, as with the beam parameters.
7. Other parameters--- for a general analysis, these parameters may be held at the prescribed values, but they can also be varied if the user desires. These are: the inner ('rin') and outer radii ('rout') of the accretion disk, given in units of $10^8$ cm, the beam widths ('sigma1' and 'sigma2'), the opening angle of the fan beam ('thvdeg', the opening angle of the pencil beam should be kept at 0), and the ratio of the beam luminosities to the constant non-pulsating luminosity ('norm1' and 'norm2'). See Hickox & Vrtilek (2005) for justification of the standard values for these variables.

Note that there are different blocks of code to set variable parameters for fan vs. pencil beam geometries, so be sure you enter the disk and beam parameters in the correct section for the type of simulation you wish to run.

Save the file, then compile and run this procedure using the following script:

```.compile fit_inp.pro```

```.run fit_inp.pro```

Running fit_inp.pro multiple times with the same set of input parameters will _not_ overwrite any already-run simulations with those parameters.

# Running the Simulation
The simulation is run via the fit_run.pro file. The model parameters must already be set (via compiling and running fit_inp.pro within the same IDL session) before running this file. Run as follows:

```.compile fit_run.pro ```

```.run fit_run.pro ```

The fit_run.pro file will run simulations for all parameter combinations that haven't been previously run. The parameters it considers in this determination are only those included in the automatically generated folder names for simulations, i.e. the beam opening angle, the _variable_ parameters I described above, and the observer elevation. If you are changing other parameters besides these, I recommend creating a new directory for those simulation outputs (and changing the output directory accordingly in fit_inp.pro). 

If you have elected to plot the accretion disk geometry in IDL, the simulation will pause as it shows you each plot, and you will need to direct it to continue by typing:

```.cont ```

**If IDL is terminated while running a simulation:** before starting again be sure to go into the folder of the simulation that was partially completed, and delete the file 'diskbeam.idl'. The existence of this file in a given folder (with its particular parameters in the folder name) is how fit_run.pro determines whether the simulation has been run already, so it will leave that simulation incomplete unless you delete this file. Then restart IDL, and compile and run fit_inp.pro and fit_run.pro again as usual.

**If you wish to re-run all simulations:** go into fit_run.pro and comment out the line that defines 'ranalready', and comment in the line below that says ranalready=''. This will now re-run all simulations in your 'topdir' folder.

**If you wish to re-run particular simulations:** go into the simulation output folders and delete 'diskbeam.idl' files, then run fit_run.pro as usual. Alternatively, you can go into fit_run.pro and comment out the line defining 'dlist', and instead just define 'dlist' as a particular folder or a list of folders, then comment out of the line that defines 'ranalready' and set ranalready='', so fit_run.pro will re-run these.

# Plotting Pulse Profiles in Python
The file fitplotprof_single.pro generates a .csv file of the hard and soft X-ray model pulse profile at each disk phase (8 pulse profiles total per model run). These files are outputted into each simulation folder, under the sub-folders 'diskphi_0.000', 'diskphi_0.125', etc. They can be plotted in Python like any .csv file and compared to data.

# Plotting the Disk in Python
The information needed to plot the disk is stored in the 'diskplotpar_0.000.idl', 'diskplotpar_0.125.idl', etc. files within each model folder (8 files per model). These can be converted to a csv format that is readable to Python using convertidltotxt.pro. Compile and run convertidltotxt.pro, and it will automatically run on any simulations that it hasn't run on previously (checked via the existence of one of the output .txt files within a given observation folder). The .txt files containing the necessary data will output into the 'diskphi_0.000', etc. folders within each simulation folder.

```.compile convertidltotxt.pro```

```convertidltotx,bdir```

You may need to redefine the variable 'bdir', which should be the same as the variable 'topdir' from fit_inp.pro--- the path to the folder the simulation output is saved to.

Then, use the Python notebook included to plot the disk. Within this file, be sure to change:
1. The path to your params.txt file, which lists all the simulations you have run. It is overwritten every time you run fit_inp.pro, so for a large batch of simulations it is best to run them all at once and save a copy of the resulting params.txt elsewhere. This is in the variable 'files', located in the first block of code under the plotdisk function. The path needs to be set like so:
```files=pd.read_csv("/path/to/params.txt",sep=',')```
under your desired 'source' name. The source names can be changed, those are just telling the plotdisk function which params.txt file to draw from.
2. The path to the output folder where all of your simulation folders are located. This is the variable called 'path'.
3. Your desired save location and save file name for plots. This is located in the fig.savefig command under "if save=='y':", and should be set like so:
```fig.savefig('/path/I/want/to/save/to/filename.png')```
I have my filename set to use an inputted figure title, and to automatically include today's date. It will need to be changed twice, once in the segment of code for plotting all disk positions, and again in the segment of code for plotting just one disk position.
4. The observer elevation, if yours is not $20^o$. This should be changed in the variable 'foldername'. 

Further details on inputs for the plotting function in Python are noted within the Python notebook file.
