pro diskwarp,params,npoints,nprof,ph,ang,xv,yv,zv
;this calculates the shape of the disk and returns the X and Y values
;to disktemp.pro
;RCH 8/20/04
; Comments added by KIS 2024

ninner=fix(nprof) ;set ninner to be an integer 100

;parameters of disk
rin=params[0] ;params was an array containing all of these variables, now calling each one back out of said array
rout=params[1]
tiltin=params[2]
tiltout=params[3]
phsoff=params[4]

amp=findgen(nprof)*(tiltout-tiltin)/(nprof-1)+tiltin ;findgen creates a float array of integer values from 0 to 99 in this case
; then (tiltout-tiltin)/99 gives us the increment size for the disk tilt angle changing as we go from the inner radius to the outer, in 100 increments
;then adding that to tiltin is like we start at the angle tiltin and we're counting up (or down) to tiltout by steps of the given size, 100 times
ang=fltarr(npoints,nprof) ;another array of 100x100 float zeros
xv=ang ;set all of these to also be arrays of 100x100 float zeros
yv=ang
zv=ang

;make the vector of radii
rv=rin+(rout-rin)/(nprof-1)*findgen(nprof) ;the radii associated with the steps we are taking from the inner disk to the outer disk (100 increments)
;find the approriate values of phase to use

ph=findgen(npoints)/(npoints)+0.0001 ;array of values like 0.01, 0.02, etc up to 0.99
; but starting not quite on zero to fix some divide by zero error probably
; these are like phase angles as we're rotating the disk around in 100 increments

out=tiltout*sin(2.*!pi*ph) ;the actual tilt of the outer disk to the normal plane at any given increment, varying by phase angle (this is an array)
in=tiltin*sin((2.*!pi*ph)+phsoff) ;likewise for the inner disk, adding in the phase offset between inner and outer disks


;fill in the angles of the profiles to plot
off=findgen(ninner)*phsoff/(ninner-1) ;100 increments that step up from 0 to the phase offset angle... 
;also related to how we are counting up from the inner disk to the outer disk in 100 steps
iw=indgen(ninner) ;100 integers from 0 to 100
if ninner lt nprof then $ ;which should be true bc both are 100
inw=ninner+indgen(nprof-ninner) ;but if nprof was greater than ninner, this is an array of the remaining integers needed to get up to the value of nprof
;fill in the angles of the profiles to plot
for i=0,npoints-1 do begin 
    ang[i,iw]=-amp*sin(2.*!pi*ph[i]+off) ;for each row in this 100x100 array, set the value at the incremental tilt angles times the sine of the phase angle plus the offset angle
    ;so going down each column, the increasing increments of tilt angle/ offset angle are kind of connected to each other, as we step from the inner to outer disk
    ;and the phase angles vary going across the array, so each row is a different phase angle as we rotate the disk around
    ; so these are all the actual tilt angles corrected for the warp, phase offset, and the rotation of the disk
    
    if ninner lt nprof then $ ;if ninner is less than nprof
    ang[i,inw]=asin(rv[ninner-1]/rv[inw]*sin(ang[i,ninner-1])) ;adding the remaining entries we would need for any values over 100
    ;sets the last however many columns to be the same as the 99th column (i.e. the disk's rotation is now stopped)--- see line setting zv, then it all makes sense
endfor

;make the x and y profiles for everything else
for i=0,npoints-1 do begin 
xv[i,*]=rv*cos(2.*!pi*ph[i])*cos(ang[i,*]) ;the x components of the disk's extent
yv[i,*]=rv*sin(2.*!pi*ph[i])*cos(ang[i,*]) ;the y components of the disk's extent
zv[i,*]=rv*sin(ang[i,*]) ;the z component of the disk's extent
endfor


end
