;This creates input files for doing a set of simulated profiles for
;several disk and beam shapes
;RCH 12/03/04
;Comments added by KIS 2024

;to begin with we will adjust the DISK TWIST and the BEAM ANGLE

;this defines the directory where the output for this run is stored
; be sure to change for different runs
topdir='/Users/ksippy/Desktop/diskexperiments/'

; creating the top directory in question
spawn,'mkdir '+topdir ;if the directory already exists, this should just fail/ will not overwrite

;this selects whether or not we'll use a fan or pencil beam
fan='y'

;whether we want to plot the disk and pulse profs in IDL at the end (I would typically just plot in Python)
plotd = 'y'
plotpps = 'y'

;These are the FAN BEAM properties ;the way it's set up now we can only have fan OR pencil beams
;disk properties
if fan eq 'y' then begin
rin=0.8 ;inner disk radius = magnetosphere radius, in units of 1e+8 cm
rout=1. ; outer disk radius
tiltindeg=[20.] ; tilt angle of inner disk (degrees)
tiltoutdeg=[30.] ; tilt angle of outer disk (degrees)
phsoffvdeg=[-170.] ;phase offset between inner and outer disk (degrees)
obselevdeg=[20.] ; elevation angle of the observer relative to normal plane (degrees)
; can also set these to have a series of values, like [-5., -10], if you want to test multiple things

;beam properties
sigma2=30. ;width of beam 1 (degrees)
sigma1=30. ;width of beam 2
long1=0. ;longitude of beam 1 (set to zero and then make beam 2 relative to this)
long2vdeg=[180.] ;longitude of beam 2 (degrees) relative to beam 1
thvdeg=[30.] ;opening angle (the fan beam is wide, for pencil beam this is always 0) (degrees)
beamangdeg1=[-40.] ;latitude angle for beam 1 (degrees), to define its position along w the longitude
beamangdeg2=[70.] ;likewise for beam 2 (degrees), NOT relative to beam 1
;beamangdeg's take negative values as well
endif else begin ;can put these all on one line in IDL, indentation and orientation don't really matter, just order

;These are the PENCIL BEAM properties
;disk properties
rin=0.8 ; radius of inner disk = magnetosphere radius (units of 10^8 cm)
rout=1. ;radius of outer disk
tiltindeg=[10.,20.] ; angle of inner disk
tiltoutdeg=[30.,45.] ;angle of outer disk
phsoffvdeg=[-100.,-110.,-120.,-130.,-140.,-150.,-160.,-170.] ; phase offset between inner and outer disks
obselevdeg=[20.] ;observer elevation off the normal plane in degrees

;beam properties
sigma1=60. ; width of beam 1 (used to be radians, I changed it to deg here & put in a line to convert in beam.pro)
sigma2=60. ; width of beam 2
long1=0. ;longitude position of beam 1 (set to 0)
long2vdeg=[160.,170.,180.] ;longitude position of beam 2, relative to beam 1
thvdeg=0. ;opening angle (pencil beam is always 0)
beamangdeg1=[-50.,-40.,40.,50.,60.] ;latitude angle of beam 1 (degrees)
beamangdeg2=[50.,60.,70.] ;latitude angle of beam 2 (degrees), NOT relative to beam 1 
endelse

;more beam properties
norm1=3. ;constant for the gaussian profile of the beam (see beam.pro)--- 3 because we're setting the beam intensity to be 3 times the isotropic hard radiation
norm2=3. ;likewise
floor=1. ;floor refers to relative strength of the isotropic hard radiation component

;disk angles
npoints=100 ; rotating the disk around in 100 increments
nprof=100 
nth=npoints 
nphi=npoints 

;beam rotation angles
nang=128. ; rotating the beams around in 128 increments


rinphys=1.e8 ;unit conversion, like the inner disk radius is 10^8 cm
lum38=3. ;luminosity in units of 10^{38} erg/s
icnt=0 ;starting the index of how many parameters files we're saved off at zero

openw,4,topdir+'params.txt' ;this is going to be a .txt file that contains a giant list of all simulations you've created
;useful for if you're running many simulations over a large parameter space and need to reference them later

;go through the disk twists and the beam angles and all the other
;parameters, and make directories
;and parameter files
for iobs=0,n_elements(obselevdeg)-1 do begin ;for however many obselevv's have been specified (potentially an array of them to be tested)
    obselev=obselevdeg[iobs] ;select each value from the array
    if obselev lt 0 then begin ; if the phase offset angle is negative
        strobs=`obsm${-obselevdeg[iobs],'%2.2I'}` ;creates a string like 'obsm100', the m indicating that its Minus 100
    endif else begin ;otherwise
       strobs=`obs${obselevdeg[iobs],'%2.2I'}` ;create this string which is obs plus the string form of the obselev angle rounded to 2 digits, so like 'obs05'
    endelse

for itin=0,n_elements(tiltindeg)-1 do begin ; likewise for inner disk tilt angles
    tiltin=tiltindeg[itin]
    strtin=`tin${tiltindeg[itin],'%2.2I'}` ; creates a string like 'tin10'

for itout=0,n_elements(tiltoutdeg)-1 do begin ;likewise for outer disk tilt angles
    tiltout=tiltoutdeg[itout]
    strtout=`tout${tiltoutdeg[itout],'%2.2I'}` ;creates a string like 'tout30'

for ith=0,n_elements(thvdeg)-1 do begin ;likewise for opening angle of beams
    th1=thvdeg[ith]
    th2=th1 ;the first and second beams are assumed to have the same opening angle in all cases
    strth=`th${thvdeg[ith],'%2.2I'}` ;creates a string like 'th00'

for i=0,n_elements(phsoffvdeg)-1 do begin  ; likewise for phase offset angles
           phsoff=phsoffvdeg[i]
        if phsoff lt 0 then begin ; if the phase offset angle is negative
            strphs=`twm${-phsoffvdeg[i],'%3.3I'}` ;creates a string like 'twm100', the m indicating that its Minus 100
        endif else begin ;otherwise
           strphs=`tw${phsoffvdeg[i],'%3.3I'}` ;creates a string like 'tw139' for positive angles
         endelse

for ibm1=0,n_elements(beamangdeg1)-1 do begin ;this is like cycling through the beamang1 values still, formatting is just crazy

for ibm2=0,n_elements(beamangdeg2)-1 do begin ;likewise for (latitude) beam angles

        ;set the values
        lat1=beamangdeg1[ibm1] 
        lat2=beamangdeg2[ibm2]

        if beamangdeg1[ibm1] lt 0 then bm1str='m' else bm1str='_' ;if beam angle 1 is negative then add the 'm' string to the final phrase, otherwise have an underscore in place of the m
        if beamangdeg2[ibm2] lt 0 then bm2str='m' else bm2str='_' ;likewise for beam angle 2
        strbm='bm1'+bm1str+`${abs(beamangdeg1[ibm1]),'%2.2I'}`+'bm2'+bm2str+`${abs(beamangdeg2[ibm2]),'%2.2I'}` ;creates a string like 'bm1_00bm2_60' (if both are positive)

        for ilng=0,n_elements(long2vdeg)-1 do begin ;likewise for longitude angles of beams
            long2=long2vdeg[ilng] ;only identifying the second beam's longitude angle, since its relative to the first beam
            strlng=`lng${long2vdeg[ilng],'%3.3I'}` ;creates a string like 'lng210'


        dirname=topdir+strobs+strtin+strtout+strphs+strth+strbm+strlng ;setting the name of the directory to be all of these variable strings smushed together
   

        ;make the directory
        spawn,'mkdir '+dirname ;creating this new directory with the name listed above
        
        ;write the parameters down to a file we can read
        openw,2,dirname+'/par.dat' ;create a new file inside the new directory called par.dat which lists the parameters
        printf,2,'INPUT to warp disk shape: '+dirname ;writing the directory/ experiment name into the file
        printf,2,'#UTC: '+systime(/utc) ;the time at which par.dat was created
        printf,2,'' ;enter

        printf,2,'DISK PARAMETERS:' ;writing the disk parameters-- these are all the values that the previous for loops are selecting from the vector/ array list of inputted values
        ;so if there are multiple values, it will write a new file for each one in here
        printf,2,'rin='+string(rin) ;inner radius
        printf,2,'rout='+string(rout) ;outer radius
        printf,2,'tiltin='+string(tiltin) ;inner disk tilt
        printf,2,'tiltout='+string(tiltout) ;outer disk tilt
        printf,2,'phsoff='+string(phsoff) ;phase offset between inner and outer--- nesting of for loops does not work the same was as Python--- until 'endfor' is written, the loop is still running regardless of indentation
        printf,2,'npoints='+string(npoints) ;number of disk increments
        printf,2,'nprof='+string(nprof) 
        printf,2,'nth='+string(nth) 
        printf,2,'nphi='+string(nphi) 
        printf,2,''  ;enter
    
;beam rotation angles
        printf,2,'BEAM PARAMETERS:' ;writing the beam parameters
        printf,2,'nang='+string(nang) ;number of beam angle increments
        
        printf,2,'long1='+string(long1) ;longitude of beam 1
        printf,2,'lat1='+string(lat1) ;latitude of beam 1
        printf,2,'long2='+string(long2) ;longitude of beam 2
        printf,2,'lat2='+string(lat2) ;latitude of beam 2
        printf,2,'sigma1='+string(sigma1) ;width of beam 1
        printf,2,'sigma2='+string(sigma2) ;width of beam 2
        printf,2,'th1='+string(th1) ;opening angle of beam 1
        printf,2,'th2='+string(th2) ;opening anlge of beam 2 (defined as = opening angle of beam 1)
        printf,2,'norm1='+string(norm1) 
        printf,2,'norm2='+string(norm2) 
        printf,2,'floor='+string(floor) 
        
        printf,2,'rinphys='+string(rinphys) 
        printf,2,'lum38='+string(lum38) 

        printf,2,'' ;space
        printf,2,'obselev='+string(obselev) ;observer elevation angle

        close,2

        printf,4,"perm"+string(icnt)+string(lat1)+","+string(lat2)+","+string(long2)+","+string(th1)+","+string(phsoff)+","+string(tiltin)+","+string(tiltout)
        ;including relevant info in our big params.txt file

        save,rin,rout,tiltin,tiltout,phsoff,npoints,nprof,nth,nphi,$
             nang,long1,lat1,long2,lat2,sigma1,sigma2,th1,th2,norm1,norm2,floor,$
             rinphys,lum38,obselev,filename=dirname+'/par.idl' ;save all of these variable values in to the par.idl file 
             ; one par.idl file created in each experiment directory for each time this runs
             ; this creates the save file in question if it does not already exist
             ; then if you later write 'restore, par.idl' you should be able to restore the values of the all of these variables to whatever was saved

        icnt=icnt+1 ;this is an index to say how many interations of the making a directory for each set of parameters we have overall
        ;so if we made 2 new directories, the first one would be labeled '000' and the second would be '001', etc.
        
endfor
endfor
endfor 
endfor
endfor
endfor
endfor
endfor

close,4

writeit:
;This creates the par.dat files which save the parameters from all the runs
;write the parameters (for all the runs) down to a file we can read
openw,3,topdir+'/allpar.dat' ;so now we also have a par.dat in the top directory, which is listing All the combinations that were tried here
printf,3,'INPUT to warp disk shape (multiple runs): '+topdir ;from there all same as what I commented above
printf,3,'#UTC: '+systime(/utc)
printf,3,''

printf,3,'DISK PARAMETERS:'
printf,3,'rin='+strjoin(string(rin))
printf,3,'rout='+strjoin(string(rout))
printf,3,'tiltin='+strjoin(string(tiltindeg))
printf,3,'tiltout='+strjoin(string(tiltoutdeg))
printf,3,'phsoff='+strjoin(string(phsoffvdeg))
printf,3,'npoints='+strjoin(string(npoints))
printf,3,'nprof='+strjoin(string(nprof))
printf,3,'nth='+strjoin(string(nth))
printf,3,'nphi='+strjoin(string(nphi))
printf,3,''  

;beam rotation angles
printf,3,'BEAM PARAMETERS:'
printf,3,'nang='+strjoin(string(nang))

printf,3,'beam angles 1='+strjoin(string(beamangdeg1)) ; latitudes
printf,3,'beam angles 2='+strjoin(string(beamangdeg2))
printf,3,'long1='+strjoin(string(long1))
printf,3,'long2='+strjoin(string(long2vdeg))
printf,3,'sigma1='+strjoin(string(sigma1))
printf,3,'sigma2='+strjoin(string(sigma2))
printf,3,'th1='+strjoin(string(thvdeg)) 
printf,3,'th2='+strjoin(string(thvdeg))
printf,3,'norm1='+strjoin(string(norm1))
printf,3,'norm2='+strjoin(string(norm2))
printf,3,'floor='+strjoin(string(floor))

printf,3,'rinphys='+strjoin(string(rinphys))
printf,3,'lum38='+strjoin(string(lum38))

printf,3,''
printf,3,'obselev='+strjoin(string(obselevdeg))

close,3

end ;ending the program
