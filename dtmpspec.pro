pro dtmpspec,xv,yv,zv,labs,T,Tmax,Tmin,side,ph,phio,obselev,paper,fast,diskv,diskvf,plot,intot,intotx,en,spec,xv2,yv2,zv2,phf,xin,xout,yin,yout,zin,zout,nprof,iplot,see,Tclr,ifr,ibk
;This takes a disk with a given temperature profile, and calculates
;the emission that is seen by the observer
;RCH 7/04
; Comments added by KIS 2024

;make the new phf vector to plot the observed radiation
cdist=1.

;this is the new phi array, rotated by phio
phf=ph-phio ;phio is angc[i] from diskspecrest.pro, the disk phi
;ph is an array of values like 0.01, 0.02, etc up to 0.99, which was being multiplied by 2pi to get increments of the disk phi rotatin
;so changing the bigger disk phi array by whatever phi has been chosen, angc[i] a.k.a. phio

;Make the new X,Y vectors
xvf=xv ;xv was the array of disk x components and associated tilt angles
yvf=yv ;likewise for the rest
xv2=xv
zv2=zv

;get the number of angles and profiles
nang=n_elements(xv[*,0]) ;set nang (# disk phis) to be the number of rows (phis) in xv
nprof=n_elements(xv[0,*]) ;likewise for nprof

;this is an array to hold the observed flux from each part of the disk
intens=fltarr(nang,nprof) ;array of float zeros with size 100 x 100 or 128 x100 or something


;make the array to hold the energy and spectral info
;we will define the energies in keV, but will use erg in the
;calculation (in bbnorm)
enbins=1000 ;energy bins... in ergs presumably
emin=0.001 ;minimum energy
emax=100. ;maximum energy


keV=1.6021E-9 ;keV to ergs conversion factor


Tclrmin=100.
;this is for the color maps i believe
Tclrmax=255.

clrdisk=Tclrmax


for i =0,nang-1 do begin ;for each disk phi (not just 8 of them, the whole thing now)
;this is the x and v that the observer sees
    ;first we rotate with respect to phi

    xvf[i,*]=xv[i,*]*$ 
      cos(2.*!pi*phf[i])/cos(2.*!pi*ph[i]) ;the original disk tilt angles in x, y, z components were calculated like xv[i,*]=rv*cos(2.*!pi*ph[i])*cos(ang[i,*])
      ;so this is dividing out the cos original phi angle, and multiplying in the new (shifted) phi angles

    yvf[i,*]=yv[i,*]*$
      sin(2.*!pi*phf[i])/sin(2.*!pi*ph[i]) ;likewise for y components


    ;then we change the elevation angle
    xv2[i,*]=xvf[i,*]*cos(-obselev)-zv[i,*]*sin(-obselev) ;simple rotation transformation, putting in the observers rest frame

    yv2=yvf ;y doesn't change
    zv2[i,*]=zv[i,*]*cos(-obselev)+xvf[i,*]*sin(-obselev) ;likewise for z

endfor

xin=fltarr(nang) ;array of float zeros with size 100 or something
xout=xin ;likewise
yin=xin ;likewise

yout=xin ;etc.
zin=xin
zout=xin


xin=xv2[*,0] ;set xin to be the first row of xv2 (which is all the phis for the inner radius of the disk)
xout=xv2[*,nprof-1] ;set xout to be the last row of xv2 (all the phis for the outer radius of the disk)
yin=yv2[*,0] ;likewise for ys and zs
yout=yv2[*,nprof-1]
zin=zv2[*,0]
zout=zv2[*,nprof-1]

;find which parts are in the back or the front
ibk=where(xout le 0.) ;find the indices for the points on the outer disk that are at a negative x position (facing away from the observer)
ifr=where(xout ge 0.) ;find indices for points on the outer disk which are at a positive x position (facing towards observer)


Tclr=(T-Tmin)*(Tclrmax-Tclrmin)/(Tmax-Tmin)+Tclrmin
;T is the temperature profile of the disk, it was for many many beam phi angles defined in disktemp.pro, and then saved, and now restored for a particular beam phi
;Tmin and Tmax are the min and max overall across all of these profiles, they were defined out in diskspecrest.pro
; this is correcting the T's into values on a given scale that will be associated with their colors on the colormap

if diskv eq 'y' then begin ;if we do not have disk viewing info saved yet (which depends on maskit.pro)


    top=intarr(nang,nprof) ;array of int zeros with dimensions 100x100 i think


    for i=0,nang-1 do begin ; for each disk phi
        
        case i of
            0: inds=[nang-1,1] ;for the first disk phi, set inds to be this
            nang-1: inds=[nang-2,0] ;for last disk phi, set inds to be this
            else: inds=[i-1,i+1] ;for all other disk phi's between, set inds to be this
        endcase
        
;now we figure out if the disk is blocked or not, and which 
;side is illuminated
;this tells us if the disk is top-illuminated or bottom-illuminated
        for j=0,nprof-1 do begin ;for each of 100 increments (going from interior to exterior of the disk radially)
            
                                ;find the bounds in angle of this piece of the disk
            case j of 
                0: jnds=[0,1] ;for the inner disk radius, set jnds to be this
                nprof-1: jnds=[nprof-2,nprof-1] ;for the outer disk, set jnds to be this
                else: jnds=[j-1,j+1] ;otherwise, set jnds to be this
            endcase
            
            vec1=fltarr(3) ;this is an array of float zeros w length 3
            vec2=fltarr(3) ;likewise
            
            vec1[0]=xv2[i,jnds[1]]-xv2[i,jnds[0]] ;the x component of the first vector is the disk x-component just after the current one, minus the component just after
            ;(creating a little delta x of sorts)... we also did this before! in disktemp.pro
            vec1[1]=yv2[i,jnds[1]]-yv2[i,jnds[0]] ;likewise for the y component of vec1

            vec1[2]=zv2[i,jnds[1]]-zv2[i,jnds[0]] ;and the z component
            
            vec2[0]=xv2[inds[1],j]-xv2[inds[0],j] ;same idea for vector 2
            vec2[1]=yv2[inds[1],j]-yv2[inds[0],j]
            vec2[2]=zv2[inds[1],j]-zv2[inds[0],j]      
            
            orient=crossp(vec1,vec2) ;we recall that the cross product of two vectors has magnitude = the area of the parallelogram the vectors span
            ;but in this case we use it as a vector pointing to this area's *UP*/ in the direction of illumination and therefore emission of this area on the disk
            ;so this represents the direction this area segment of the disk is emitting light towards
    
            top[i,j]=fix(orient[0]/abs(orient[0])) ;dividing the value of the x-component of orient by the absolute value of the x-component gives us either +1 or -1
            ;so the array 'top' will have the value +1 for every part , and -1 for every bottom-illuminated portion of the disk
            ;since the x-component represents whether orient is facing away from or towards the observer--- i.e. top or bottom of the disk is emitting/ absorbing light
            ;the fix rounds down to an integer, so just making sure it definitely comes out as +-1 and not like 0.99999
            
            ;this is the fractional component of the area pointed toward us
            fsee=abs(orient[0])/sqrt(total(orient^2.)) ;the denomenator here is the area (forced to be positive) of our little area square/ the magnitude of the vector
            ;the numerator is the magnitude of the x component of the vector
            ;so this tells us how much light is emitting right at the observer (along the positive x axis, as it were) compared to the total
            
            if fsee lt 0.1 then begin ;and if the component of light coming towards or away from an observer is too small (<0.1) 
                top[i,j]=0 ;then change the value in the 'top' array to be zero, so we're saying effectively no light from this little square is reaching our observer
            endif

        endfor
    endfor


;this says whether we can see the illuminated side.  If see==1, we can
;see it, if see==-1 or zero, we can't see it.
    see=top*side ;recall 'top' tells us whether the light is being net emitted from the top or bottom of the disk, and 'side' tells us (see disktemp.pro) if we see the top or bottom
    ;both contain values -1 for bottom, +1 for top, and 0 for edge-on
    ;so if there's a segment where we see the bottom of the disk and the bottom is lit up, that gives us (-1)*(-1) and that points take the value +1 in 'see' (i.e. we see it)
    ;same idea for if the top is illuminated and we see the top
    ;if we have a mismatched pair, like top is lit but we see the bottom, or vice versa, then we get -1 in 'see' (we don't see it)
    ;if either value (in 'top' or 'side') was 0, then we get 0 in 'see', and we also don't see it
    
    iplot=maskit(nprof,nang,xv2,yv2,zv2) ;this is a function that was defined in maskit.pro
    ;iplot tells us again which parts of the disk are visible

    ;save the results of the visibility analysis
    save,iplot,see,fsee,filename=diskvf ;saving the plot, the array 'see' the final value of fsee for reasons unbeknownst to me
    ;and putting it in the disk viewing info info diskvf we've heard so much about
    ;so this diskvf can be reused once it exists/ doesn't need to be rewritten every time (if diskv = 'n')
    print,'Created disk viewing file'

endif else begin

    restore,diskvf ;bring back the saved disk viewing file for this particular orientation, etc. if it already exists

    print,'Restored disk viewing file'

endelse

;get the intensity
intens=fsee*labs ;intensity (this is an array) equals the luminosity for each point on this disk times the fraction of that luminosity that we see for each point

;find the total reprocessed intensity
intot=total(intens[where(iplot+see eq 2)]) ;total intensity for all the points we can see on the disk... iplot should have values like 1 then... bc the parts of the disk we see have
;values of 1 in see.


;define the intotx variable
intotx=0.D ;this is equal to 0., the D means its a double precision float
;meaning that IDL will remember it to more places (like 15 or 16 decimal places) than if it was a normal float (which would have like 7 or 8 decimal places)
;useful when we need a very precise value for a certain thing

;this runs the fast version, not saving spectral information
;but simply soft X-ray output
if fast eq 'y' then begin ;need to run this one bc otherwise the fact that my bbnorm doesn't work right will probably become an issue


bbfracgrid='bbfrac/bbf     0.300000_      10.00001101.idl'  ;the file i generated using bbfrac.pro
;you will need to generate a different file for your desired lower/ upper energy limits if they aren't 0.3-10 keV
restore,bbfracgrid ;pulling parameters from the file named above
;this file needs to be written if it doesn't already exist! Use bbfrac.pro
;restores variables: logT,bbfracv


    for i=0,nang-1 do begin ;for each disk phi
        for j=0,nprof-1 do begin ;for each disk radius
            
            if iplot[i,j]+see[i,j] eq 2 then begin ;if we see the emission from the disk
 
                intotx=intotx+intens[i,j]*bbfrac_inp(logT,bbfracv,T[i,j]) ;add the intensity times the function bbfrac_inp, which is defined in file bbfrac_inp.pro
                ;note that bc its a function not a procedure, it's written like fcn(variable1, variable2, ...) and will output one defined value
                ;unlike the procedures we've been using this far
                ; bbfrac_inp returns the fraction of the blackbody spectrum that is between two given energies (in this case 0.3 keV and 10 keV, see bbfracgrid file we restored above)
                ; so multiplying total intensity by that gives us intensity of each point on this disk within the desired energy range
                
            endif

        endfor    
    endfor

endif else begin

;This runs the SLOW version, but saves all the SPECTRA
;this makes the energy and spectral arrays
loge=(findgen(enbins)*((alog10(emax)-alog10(emin))/enbins))+alog10(emin) ;array of enbins amount of equally log-spaced energies, going from enmin to enmax
en=10.^loge ;the actual (nonlog) values of these
energ=en*keV ;convert from ergs to keV
energ =double(energ) ;make it a double just to be safe w math

spec=dblarr(enbins) ;an array of zeros w the same length as enbins


;find the total, integrated spectrum
for i=0,nang-1 do begin ;for each disk phi
    for j=0,nprof-1 do begin ;for each disk radius

        intens[i,j]=fsee*labs[i,j] ;

        if iplot[i,j]+see[i,j] eq 2 then begin ;if we can see this part of the disk

            spec=spec+intens[i,j]*bbnorm(T[i,j],energ) ;add the intensity of that area on the disk (at each energy from the list of energies (energ) specified above)
            ;spec starts out as all zeros, so we are just setting the values to be intens[i,j]*bbnorm(etc.) here, and the bbnorm part should come out as an array since we input the whole
            ;array of energies (energ)
            
        endif

    endfor    
endfor

xlo=0.3 ;a minimum energy
xhi=1.0 ;a maximum energy
endiff=diff(en) ;subtract subsequent elements of en from each other to create an approximate dE
spectot=total(spec[0:n_elements(spec)-2]*endiff) ;total intensity integrated over energies (summed for all points on this disk)
ix=where(en ge xlo and en lt xhi) ;indices where the energies in en are between xlo and xhi
specx=total(spec[ix]*endiff[ix]) ;total intensity integrated over the energies between xlo and xhi (summed for all points on the disk)

intotx=intot*specx/spectot ;specx/spectot is the fraction of the bbody flux contained within the given energy range for the whole disk
;intot was the total intensity of points on the disk that we can see
;so now intotx is the total intensity we see in the given energy range across visible areas of the whole disk


endelse


end






