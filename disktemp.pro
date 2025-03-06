;this draws a disk and calculates the temperature of the disk 
;given an input radiation field.
;RCH 1/26/04
; Comments added by KIS 2024

pro disktemp,params,npoints,nprof,rinphys,thil,phil,illum,ph,xv,yv,zv,labs,T,side,lemit

;PHYSICAL CONSTANTS--------
kpc242=9.523 ; value of 1 kpc^2 in units of 10^{42} cm^2
k=1.3807E-16 ;the boltzmann constant (k from kT), in cm2 g s-2 K  (CGS)
SBsigma=5.6705E-5 ;stefan-boltzmann constant in erg⋅cm−2⋅s−1⋅K−4 (CGS units)
keV=1.6021E-9 ;value of 1 keV in ergs
;L38=illum

;the top value for the color index
ctop=255. ;also defined in beam.pro


;this tells us which side is illuminated
side=intarr(npoints,nprof) ;create an array of integer zeros with size 100 by 100
T=dblarr(npoints,nprof)  ;create an array of float zeros (0.0) with size 100 by 100

;these are arrays for the solid angle and energy absorbed for each
;disk element
sang=T ;set this to also be an array of float zeros
labs=T ;likewise

;calculate the shape of the disk
diskwarp,params,npoints,nprof,ph,ang,xv,yv,zv

;we are always going to assume there are constant steps in phi
phistep=fltarr(npoints)+ph[1]-ph[0] ;array of floats, increment sizes = to the step between the firs two phi (disk rotation angle) steps

;go through and calculate which illumination array elements correspond
;to which points on the disk
iphi=intarr(npoints) ;array of 100 integer values
ith=intarr(npoints,nprof) ;array of 100x100 integer values
illum2=fltarr(npoints,nprof) ;array of 100x100 float integer values

for i=0,npoints-1 do begin
    idfphi=0  ;resetting this to be zero to begin so finding the min works
    difphi=abs(2.*!pi*ph[i]-phil) ;phil is what we're calling phbeam now, which was also called vphi in beam.pro... it's an array of phi angles for the beam going all the way around
    ; so this is the difference between our disk rotation angles ph[i] an our beam rotation angles phil
    ;going through all the beam angles (phil) and taking the disk angles ph[i] one by one
    idifphi=where(difphi eq min(difphi)) ;set this to be whatever the INDEX of the smallest value in difphi is
    iphi[i]=idifphi[0] ;then the values in iphi are set to those indices

    for j=0,nprof-1 do begin
        difth=abs(ang[i,j]-thil) ;same thing for theta angles, difference between disk (ang[i,j]) and beam (thil) angles
        idifth=where(difth eq min(difth))
        ith[i,j]=idifth[0] ;set a value in ith to be the index of the closest theta
        illum2[i,j]=illum[idifth[0],idifphi[0]] ;set illum2 to be the corresponding value in illum (beam brightness) that is closest in position to the disk position angles
    endfor

endfor

;calculate the temperature profiles for each phi angle
for i=0,npoints-1 do begin

;this is the profile for this particular phi
    p1=ang[i,*] ;select a given phi angle (point the disk is at in its rotation), and the whole range of disk radius steps will go across

;this is the inner angle
    angin=p1[0] ;the inner disk tilt angle
    anghi=angin ;set these to be equal to that value
    anglo=angin ;these are all being reset to the inner disk tilt angle each time/ for each phi
    ;so they will only count up or down in value as we move radially out from the inner to outer disk, and then will reset for the next phi

    ;determine the bounds in phi of this particular piece of the disk
    case i of ;this is like a super annoying if then statement
        0: inds=[npoints-1,1] ; if i=0, set inds to be an array like [99,1]
        npoints-1: inds=[npoints-2,0] ; if i=99, set inds to be [98,0]
        else: inds=[i-1,i+1] ;otherwise, set inds to be this (for example if i=2, inds=[1,3])
    endcase


    ;these arrays represent are the side of each array element
    vec1=fltarr(3) ;float array of zeros, length 3
    vec2=fltarr(3) ;likewise

;now we figure out if the disk is blocked or not, and which 
;side is illuminated
    for j=0,nprof-1 do begin 

        ;find the bounds in angle of this piece of the disk
        case j of 
            0: jnds=[0,1] ;if j=0, set jnds to be [0,1]
            nprof-1: jnds=[nprof-2,nprof-1] ; if j=99, set jnds to be [98,99]
            else: jnds=[j-1,j+1] ;otherwise set it as idns was above
        endcase

;this tells us if we see the top of the disk
        if p1[j] gt anghi then begin ;if the jth disk tilt value going from inner disk to outer disk (at a given phi) is greater than the inner disk tilt angle
            anghi=p1[j] ;set anghi to be equal to that tilt angle
            side[i,j]=1 ;set the [i,j] value of side to be 1
            ; i believe this is indicating a value of 1 in side means that the we see this section of the disk from the top, and then -1 will indicate we see it from the bottom
        endif 

;this tells us if we see the bottom of the disk
        if ang[i,j] lt anglo then begin ;analogous to above
            anglo=p1[j]
            side[i,j]=-1
        endif
     
        ;make a ROUGH estimate of the solid
        ;angle from the central source
        sang[i,j]=abs((2.*!pi*phistep[i])*(ang[i,jnds[1]]-ang[i,jnds[0]])/2.*$
                      cos(ang[i])) 
        ;(2.*!pi*phistep[i]) is the increments of phi counting up around the disk, converted to radians, so this is like delta phi
        ;(ang[i,jnds[1]]-ang[i,jnds[0]]) is subtracting the tilt angle value for the given phi BEFORE the current (jth) one from the one AFTER the current (jth)
        ; so this ^^ is kind of like a delta for that angle... alpha let's say, basically
        ; so the whole thing is cos(alpha)*delta(alpha)*delta(phi), which is the integral of a solid angle (tho using the tilt angle b4 and after makes it rough)
        ; i.e. dOmega = sin(theta) dtheta dphi
        ; 
        ; sang tells us the solid angle around the star subtended by different sections of the disk due to their tilt angles


        

;now calculate the temperature


        if side[i,j] ne 0 then begin ;all relevant values corresponding to disk phi + tilt angle pairs will be set to -1 or 1, so this should run in virtually all cases
            ; unless in the case where it is being hit edge on and side[i,j] would in fact have the value 0

            ;the luminosity absorbed by this patch is just
            ;the intensity[i,j] times the solid angle
            labs[i,j]=illum2[i,j]*sang[i,j] ;illum2 has the corresponding value in illum (beam brightness) that is closest in position to the disk position angles
            ; the luminosity absorbed at a give point on the disk is equal to the solid angle subtended by that second time the intensity of the beam at that position
            ;assuming all are constant
 
                                ;estimate the area of the region
            vec1[0]=xv[i,jnds[1]]-xv[i,jnds[0]] ;using the x, y, z coords that we made for sections of the beam in diskwarp.pro, taking the value before and after each point on 
            ;the disk, and subtracting those to make a little square around our current position on the disk, basically
            ;vec1 gives us a little vector telling us how the x,y,z coords change taking a tiny segment going outwards in the radial direction
            vec1[1]=yv[i,jnds[1]]-yv[i,jnds[0]]
            vec1[2]=zv[i,jnds[1]]-zv[i,jnds[0]]

            vec2[0]=xv[inds[1],j]-xv[inds[0],j] ;same idea but taking a segment going around in the phi direction
            vec2[1]=yv[inds[1],j]-yv[inds[0],j]
            vec2[2]=zv[inds[1],j]-zv[inds[0],j]   

            orient=crossp(vec1,vec2) ;the crossproduct of these two vectors gives us the rough area of a little square around our current disk position
            ;we recall that the crossproduct magnitude is equal to the area of a parallelogram with sides = the vectors!!!!
        ;this is an estimate of the area
        ;note we include the physical size of the region here
            area=rinphys^2.*sqrt(orient[0]^2.+orient[1]^2.+orient[2]^2.) ;now applying the correction for r into physical units (into cm)
            ;and taking the magnitude of the crossprod vector to get an actual area

            T[i,j]=(1.E38)^(1./4.)*(labs[i,j]/(SBsigma*area))^(1./4.) ; sigma T^4 = F << Stefan-Boltzmann law
            ;where F = L/A = dE/dAdt
            ;so this is that same equation rearranged to solve for T, and also correcting luminosity (labs) into 10^{38} erg/s bc before it was divided by that or something

        endif
        
    endfor

endfor

;calculate the emitted radiation
lemit=total(labs[where(side ne 0)]) ;the total emitted radiation = the total of absorbed radiation (cutting out any segments that were hit edge on and absorbed no light)


end















