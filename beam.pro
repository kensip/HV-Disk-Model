;This attempts to make a beam pattern with a Gaussian profile
;RCH 7/17/04
; Comments added by KIS 2024

pro beam,nth,nphi,long1,lat1,sigma1,th1,norm1,long2,lat2,sigma2,th2,norm2,obselev,floor,vth,vphi,nbeam

ctop=255. ;specific to the color gradient, for dividing it into sections later
loadct,3 ;this loads in a color gradient table that is preset in IDL, specifically #3 is a black to red to orange to white 'temperature' gradient
; presumably for plots later

vth=-!pi/2.+dindgen(nth)*(!pi/(nth-1)) ;dindgen generates an array of integers to 1 decimal place of the given size (100 in this case)
; vth is an array of the theta angles we'll use (not steps, actual angle values in radians)
;starting from pi/2 (the 'north pole' as it were)
vphi=dindgen(nphi)*2.*!pi/nphi+0.0001*2.*!pi ;likewise this is the array of phi angles we'll use (not steps, angle values in radians)
;starting from some very small phi angle, not actually 0, probably bc it messes up some calculation later to have 0 here

;this calculates the solid angle covered by each point
;this is only a function of theta, so it is a 1-d vector
thstep=!pi/(nth-1) ;dividing the vertical angles (theta in spherical polar coords) into 99 steps/ sections
phistep=2.*!pi/nphi ;likewise dividing the horizontal angles (phi in spherical polar) into 99 steps/ sections
sang=thstep*phistep*abs(cos(vth)) ;the total solid angle step for each segment of disk rotation (dOmega = dtheta sin(theta) dphi)

;make the array for the beam and other arrays
beam=fltarr(nth,nphi) ;makes an array of zeros that's 100 by 100 (nth =100, nphi=100)
nbeam=beam ;set nbeam to be that array
dist1=fltarr(nth,nphi) ;make an array of zeros that's 100 by 100
dist2=dist1 ;set dist2 to be that array

for i = 0,nth-1 do begin  ;for each step of disk rotation
dist1[i,*]= sphdist(long1,lat1,vphi,vth[i],degrees='') ;angular distance of beam 1 (at position (long1, lat1)) at any given timestep from another angle on a sphere (theta,phi) (i.e. (vth,vphi))

dist2[i,*]=sphdist(long2,lat2,vphi,vth[i],degrees='') ;likewise for beam 2
;so 100 different phi values go down the columns of the arrays dist1 and dist2, and then 100 different theta values go across the rows
;marking degrees='' so it will do radians
 

endfor

dist1= double(dist1)
dist2 = double(dist2)
th1 = double(th1)
th2=double(th2)
sigma1=double(sigma1)
sigma2=double(sigma2)
;make the beam pattern

    beam1=norm1*exp(-(dist1-th1)^2./(2.*sigma1^2.)) ;norm1 is a constant, th1 is the opening angle of the beam, dist1 is as described above, sigma1 is the beam width (also an angle)
    beam2=norm2*exp(-(dist2-th2)^2./(2.*sigma2^2.))
    ; these are just gaussians!
    ; so we assume the pencil beam's like 'brightness' in any given direction from its center falls off as a Gaussian
    ; a normal distribution around the place the beam points at (long and lat), with (literally) variance (a.k.a width) sigma
    ; and the 3 makes it so the beam is 3x brighter than the isotropic hard component that will be included later


beam=floor+beam1+beam2 ;this is the total beam pattern, the isotropic radiation (floor) plus the angular arrays describing the strength of each beam's emission

;normalize the beam pattern
beamint=0.
for i=0,nth-1 do begin ;for each row in the beam array
beamint=beamint+total(beam[i,*]*sang) ; multiply the beam values by the solid angle step sizes (dOmega) and add onto the total
endfor

nbeam=beam/beamint ;now nbeam is the normalized beam profile, where we're divided it so that it will (numerically) integrate over dOmega to 1 now

;this is a check [to make sure its normalized now]
nbeamint=0.
for i=0,nth-1 do begin
nbeamint=nbeamint+total(nbeam[i,*]*sang)
endfor

;make the colors for the plot
clrbeam=nbeam*ctop/max(nbeam) ;assigning a color to each point in the beam profile based on the strength of the beam at that point relative to the maximum beam strength in the array
;the ctop (constant, =255) is something specific to the color gradient profile to get it to work later on for plotting the colors

rv=1. ;radius of the vectors defined below... just to keep things normalized


;make the x,y, and z vectors
xv=beam ;set the values of all the vectors to be the beam array, this is just to make them all 100x100 arrays
yv=beam
zv=beam
xv2=xv
yv2=yv
zv2=zv

;fill in the x y and z vectors
for i=0,nth-1 do begin ;for each step
    xv[i,*]=rv*cos(vphi)*cos(vth[i]) ;defining the x component of the beam profile everywhere on the beam prof. grid (defn of x relate to spherical polar coords)
    yv[i,*]=rv*sin(vphi)*cos(vth[i]) ;likewise for the y component of the beam
    zv[i,*]=rv*sin(vth[i]) ;likewise for the z component of the beam

    xv2[i,*]=xv[i,*]*cos(-obselev)-zv[i,*]*sin(-obselev) ;assume the observer is on the x axis, and correct for the observer elevation
    ;putting it from the neutron star's frame to the observer ref. frame, simple rotation matrix
    yv2=yv ;y component stays the same bc of above assumption
    zv2[i,*]=zv[i,*]*cos(-obselev)+xv[i,*]*sin(-obselev)  ;correct for the observer elevation in the z component--- i.e. putting it in the observer ref. frame
    
endfor

end
