pro diskspecrest,bdir

;This plots views of the heated accretion disk
;RCH 7/16/04
; Comments added by KIS 2024

restore,bdir+'par.idl' ;restore parameters from par.idl file
;brings back the following parameters: rin,rout,tiltin,tiltout,phsoff,npoints,nprof,nth,nphi,nang,long1,lat1,long2,lat2,sigma1,sigma2,th1,th2,norm1,norm2,floor,rinphys,lum38,obselev

;some preliminary unit conversions, yes we do need to do these again bc we just reloaded in all the parameters that are in radians
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

nang=8 ;number of disk phi's to plot, since we're not going to do all 128
ang=findgen(nang)/nang ;increments going up like 1/8, 2/8, etc. (in floats)
inp=''
paper='n'
plot='n' 
fast='y' 


;this is the correction that gives us the actual angles we see
;this may have to be corrected for other things.  However, since
;angc is defined as opposite to ang, this takes care of the counter-
;precessing accretion disk
angc=0.67-ang  

strang=string(ang,format='(F5.3)') ;a string of the angles in question

ntemps=128 ;same as nang before, number of beam rotation bins= number of disk temperatures + emitted luminosities that were produced in disktempsave.pro

;load the "red temperature" color table
loadct,3

;restore the beam parameters from the diskbeam.idl file, saved by disktempsave.pro
restore,bdir+'diskbeam.idl'
;brings back the following beam parameters: nth,nphi,long1,lat1,long2,lat2,sigma1,sigma2,th1,th2,norm1,norm2,obselev,thbeam,phbeam,nbeam,params,rinphys,lum38

;figure out where the observer is looking on the beam
thobsdiff=abs(double(thbeam)-double(obselev)) ;the difference between the observer elevation angle and the array of thetas (also called vth) that were created in beam.pro
ithobs=where(thobsdiff eq min(thobsdiff)) ;save the index of where this difference is smallest-- i.e. identify the index of the value in thbeam that's closest to where obselev is


;get the max and min temps for the colormaps right
Tmax=0. ;initial limits, to be changed in the following... setting Tmax low and Tmin high so the values will definitely get changed
Tmin=1.e20

for k=0,ntemps-1 do begin ;for each of the beam rotation increments/ resulting temp profiles (i believe they are not additive, its just a discrete profile for each beam rotation position)

    restore,bdir+'dtemp_'+`${k,'%3.3I'}`+'.idl' ;restore the temperature profile info saved in all these many files
    ;including parameters: ph,illum,xv,yv,zv,labs,T,side
    
    Tmin1=min(T[where(T gt 0.)]) ;set Tmin1 to be the lowest positive T value
    
    Tmax1=max(T) ;set Tmax1 to be the highest T value
    
    if Tmax1 gt Tmax then Tmax=Tmax1 ;if the Tmax1 value at this beam position is greater than the previous overall Tmax, replace it with Tmax1
    if Tmin1 lt Tmin then Tmin=Tmin1 ;likewise for Tmin
    
endfor

;now the Tmax and Tmin disk temps we're assigning to the colormap are the actual overall max and min across all the beam positions


;this plots the disk at various phi angles
for i=0,nang-1 do begin ;for each disk phi

loadct,3 ;loading the same colormap again

    ;plot some of the results, but not all
    print,fix((i-1)/5.) ;
    print,ceil((i-1)/5.)    

    ;this is the angle that the DISK is rotated

    print,'disk angle phi: '+strang[i] ;print the particular disk phi we're considering right now

    ;make a directory to hold the plots and info
    spawn,'mkdir '+bdir+'diskphi_'+strang[i] ; create a directory that's something like 'test/bunchofstuff/diskphi_0.125'

    ;make two arrays to hold the pulse profiles
    inrep=fltarr(ntemps) ;float array of zeros size 128
    inrepx=inrep ;same array
    instar=inrep ;same array

    diskvf=bdir+'diskphi_'+strang[i]+'/diskvf.idl' ;same of a file we're going to create/ save stuff to later


    for j=0,ntemps-1 do begin ;for each temperature profile
        ;this loads the beam profiles for this beam angle
        restore,bdir+'dtemp_'+`${j,'%3.3I'}`+'.idl' ;restore parameters for each beam position
        ;including parameters: ph,illum,xv,yv,zv,labs,T,side
        

        print,'   beam angle no. '+`${j,'%3.3I'}`+'/'+`${ntemps,'%3.3I'}` ;so this will be like we're at beam angle 1/128, 2/128, etc.

                                ;find what the observer sees of the
                                ;beam.  We have to rotate the beam
                                ;along with the disk
        ;rotate the beam array

        if angc[i] ge 0. then begin ;if disk phi is positive
            beamoff=abs(phbeam-2.*!pi*angc[i]) ;set beamoff (new variable) to be all the potential beam phis minus the disk phi
            beamoff=double(beamoff)
        endif else begin
            beamoff=abs(phbeam-(2.*!pi+2.*!pi*angc[i])) ;otherwise if the disk phi is negative, then add 2pi to it before subtracting to make it be like within 0-2pi
            beamoff=double(beamoff)
        endelse

        irot=where(beamoff eq min(beamoff)) ;irot is the index of whatever the min value in beamoff was (minimum dist between disk phi and beam phi)
        illumhere =illum[ithobs,irot[0]]
        illumhere=double(illumhere)
        instar[j]=4.*!pi*illumhere ;ithobs is the index of the value in thbeam that's closest to where obselev is
        ;so [ithobs,irot[0]] is the theta,phi corrdinates of the position closest to the beam in the array illum!
        ;the multiplying that closest (approximated) luminosity of the *BEAM* (illum) by 4pi to get instar

        ;multiplying by the whole integral of solid angles all the way around a sphere (which is 4pi), so this would get rid of the 'per solid angle' part of the units

             
;if the disk viewing information has already been saved, load it
        rdiskf=file_which(bdir,diskvf) ;finding the file with the disk viewing info

        ;rdiskf=''
        if rdiskf eq '' then begin ;if no file is found

            diskv='y' 
        endif else begin
            diskv='n'
        endelse

         ;calculated the observed view of the disk
        dtmpspec,xv,yv,zv,labs,T,Tmax,Tmin,side,ph,angc[i],obselev,paper,fast,diskv,diskvf,plot,intot,intotx,en,spec,xv2,yv2,zv2,phf,xin,xout,yin,yout,zin,zout,nprof,iplot,see,Tclr,ifr,ibk


    ;get the pulse profile information
        inrep[j]=intot ;save intot for the given (jth) temp profile
        inrepx[j]=intotx ;save intotx for the given (jth) tmep profile
        ;intot was the total intensity of points on the disk that we can see
        ;so now intotx is the total intensity we see in the given energy range across visible areas of the whole disk

        if fast ne 'y' then begin
        save,en,spec,filename=bdir+'diskphi_'+strang[i]+'/spec_'+`${j,'%3.3I'}`+'.idl'
    endif

    endfor

        ;saving all the necessary parameters to plot the disk later
        save,xv2,yv2,zv2,phf,xin,xout,yin,yout,zin,zout,nprof,iplot,see,T,Tclr,ifr,ibk,nang,angc,filename = bdir+'diskplotpar_'+strang[i]+'.idl' 
        ; so this will technically just save the disk image for the Final beam position, which I think should be ok

        ;save the profiles, and the spectrum
        save,inrep,inrepx,instar,filename=bdir+'diskphi_'+strang[i]+'/inprof.idl'

angcinp=angc[i] 
endfor

end








