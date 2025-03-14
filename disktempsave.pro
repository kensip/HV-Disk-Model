pro disktempsave,bdir 
;This calculates disk temperature profiles for a particular beam
;shape, and saves them in .idl files
;RCH 7/20/04
; Comments added by KIS 2024

;restore the parameters from the file
restore,bdir+'par.idl' ;procedure takes an input bdir, which is a directory where it can find the parameters we set with fit_inp (the par.idl file)
; the restore command restores the values that all the parameters were set to in this file
;including rin,rout,tiltin,tiltout,phsoff,npoints,nprof,nth,nphi,nang,long1,lat1,long2,lat2,sigma1,sigma2,th1,th2,norm1,norm2,floor,rinphys,lum38,obselev

;some preliminary unit conversions
tiltin=tiltin*((2.*!pi)/360.)
tiltout=tiltout*((2.*!pi)/360.)
phsoff=phsoff*((2.*!pi)/360.)
obselev=obselev*((2.*!pi)/360.)
sigma1=sigma1*((2.*!pi)/360.)
sigma2=sigma2*((2.*!pi)/360.)
long1=long1*((2.*!pi)/360.)
long2=long2*((2.*!pi)/360.)
th1=th1*((2.*!pi)/360.)
th2=th2*((2.*!pi)/360.)
lat1=lat1*((2.*!pi)/360.)
lat2=lat2*((2.*!pi)/360.)

;beam rotation angles
nang=128. ;rotating the beam around in 128 (angular) increments. This was also set in fit_inp pro (and is set in par.idl), so this is just changing the value of that variable again
istep=nphi/nang ;the number of increments we're rotating the disk by divided by the increments for the beam
; specifically dividing the disk angles by the beam angles means that we are assuming the beam goes all the way around at least once within each increment of disk rotation
;i.e. that the beam rotates much much faster than the disk, which is a completely valid assumption

inp=''
j=0 ;this is an index used in the loop later on, it's being reset to zero here
iang=fix(indgen(nang)*istep)
;indgen generates an array of the specified shape filled with integer values counting up, then by multiplying by istep, we now have an array of 128 values counting up by intervals of istep
; ; then 'fix' converts to an integer, so this rounds down all the values in the array to integers
; in any case iang is literally just an array with length 128 containing integers from 0 to 100, with several values repeated due to the rounding


params=[rin,rout,tiltin,tiltout,phsoff] ;these variables now have whatever values were saved in the par.idl file
;making an array of these relevant parameters

;make two arrays to hold the pulse profiles
instar=fltarr(nang) ;this is like np.zeros, creates an array with the shape of nang (128) but all zeros


;make the beam
beam,nth,nphi,long1,lat1,sigma1,th1,norm1,long2,lat2,sigma2,th2,norm2,obselev,floor,thbeam,phbeam,nbeam ;running a procedure called 'beam' that takes all of these variables
; variables can also be defined Within the given procedure and will then have saved value after the procedure runs
; so the ones that haven't been defined yet here (thbeam, phbeam, nbeam) are going to be defined in the beam procedure

; **they're called thbeam and phbeam here, but vth and vphi in the beam.pro procedure--- just an array of theta and phi angles going in steps around the sphere
; and nbeam is the normalized beam profile

save,nth,nphi,long1,lat1,long2,lat2,sigma1,sigma2,th1,th2,norm1,norm2,obselev,thbeam,phbeam,nbeam,params,rinphys,lum38,$
 filename=bdir+'diskbeam.idl' ;save all of these variables to a file called diskbeam.idl within the directory we're using

;make an array to hold the emitted luminosities
lemitv=fltarr(nang) ;another array of zeros with the shape of nang (128)

;this heats the disk with the beam rotating
startloop: ;this is part of another 'goto'
;rotate the beam
nbeam2=nbeam 
ij=iang[j] ;each (integer) angle as we're rotating around
if ij ne 0 and ij ne nphi-1 then begin ;skip the cases were its 0 and 99 (which are the beginning and end of the array)
nbeam2[*,0:nphi-ij-1]=nbeam[*,(ij):nphi-1] ;nbeam and nbeam2 are arrays with length nphi-1, we're taking the last (nphi-ij-1) values of nbeam to be the first (nphi-ij-1) values in nbeam2
nbeam2[*,(nphi-ij):nphi-1]=nbeam[*,0:ij-1] ;now setting the first (ij-1) values of nbeam to be the last (ij-1) values of nbeam

;so basically nbeam2 is set to equal nbeam, then it's reset so its the two halves of nbeam values but in the opposite order
;so it's not even being flipped each time, it's bc nbeam is always the same, so nbeam2 is being set every time to be the same flipped version of nbeam
; except the first and last iterations where it does not occur
endif
illum=nbeam2*lum38 ;illum is now an array with the luminosity (pulled from par.idl) times the beam distribution values in nbeam2

;This creates a disk and heats it with a (for now) isotropic X-ray source
disktemp,params,npoints,nprof,rinphys,thbeam,phbeam,illum,ph,xv,yv,zv,labs,T,side,lemit ;calling a procedure 'disktemp' 


;xv, yv, zv were defined in 'beam' procedure
;rest not seen here should be defined within the disktemp procedure
save,ph,illum,xv,yv,zv,labs,T,side,filename=bdir+'dtemp_'+`${j,'%3.3I'}`+'.idl'
;saving some variables resulting from the running of 'disktemp' to another file, named after the interval of beam rotation that we're on rn

;put the emitted luminosity in the vector
lemitv[j]=lemit ;set each value of lemitv (for each increment of beam rotation) to be whatever was outputting running disktemp
;disktemp is going to be run once for each beam rotation segement, assuming the disk is effectively stationary on the timescale of the beam rotation

j=j+1 ;now add one to this index

    if j eq nang then goto,endit ;if we've gone through all of the angle increments, then go to the end of the program

goto,startloop ;otherwise restart the loop

endit:

;save the absorbed (also = emitted) luminosity of the disk
save,lemitv,filename=bdir+'lemit.idl' ;as vector showing how much it absorbs/ emits at each increment of beam rotation

get_lun, lun
openw, lun, bdir+'lemit.csv'
ndat = n_elements(lemitv)
for j=0,ndat-1 do begin
	printf, lun, string(j) + ',' + string(lemitv[j])
		;print into the file, 'disk phase', 'normalized brightness of the star', 'normalized brightness of the disk'
endfor    
free_lun, lun
close, lun

end




