function bbfrac,enlo,enhi,T

;This takes an energy range enlo to enhi (in keV), 
;a temperature (in K), and calculates the fraction of
;the total blackbody curve that is emitted in this energy range

;the calculation is first performed on a grid, and then 
;the absolute answer is interpolated from the grid
;RCH 8/9/04
; Comments added by KIS 2024

;name the file for this energy range, and check to see if it exists
enlo=float(enlo)
enhi=float(enhi)
senlo=string(enlo) ;convert these values to strings
senhi=string(enhi) 

fname='bbf'+senlo+'_'+senhi+'1101.idl' ;this is the name of the file we're going to save at the end of this
ftop='/Applications/NV5/idlscripts/HVdiskmodel/ks/bbfrac/' ;and the directory it will go in
spawn,'mkdir '+ftop ;if the directory already exists, this should just fail/ will not overwrite


r=file_which(ftop,fname) ;this checks if there is already a file called this in said directory

;if the file doesn't exist, we do the calculation
if r eq '' then begin

    print,'Making grid for:'
    print,'enlo: '+senlo+' keV'
    print,'enhi: '+senhi+' keV'

    ;make the arrays for the temperature and energy
    keV=1.6021E-9 ;conversion from keV to ergs
    Tmin=1.e4 ;arbitrary min temperature
    Tmax=1.e8 ;likewise
    Tbins=10000 ;number of temperature bins

    logT= (findgen(Tbins)*((alog10(Tmax)-alog10(Tmin))/Tbins))+alog10(Tmin) ;an array of evenly (log)-spaced temperatures which count up in 10000 increments from log(Tmin) to log(Tmax)
    Tv=10.^logT ;now make T an array of the actual T's associated with those evenly space logT's
 
    enbins=1000 ;number of energy bins
    emin=0.001 ;minimum energy
    emax=100. ;maximum energy

    loge=(findgen(enbins)*((alog10(emax)-alog10(emin))/enbins))+alog10(emin) ;same as logT but for the energies
    en=10.^loge ;same as T but for the energies
    energ=en*keV ;now converting the energies from keV to ergs

    endiff=diff(energ) ;diff is a command that no longer exists in IDL, but from context clues it is meant to be the difference between each point (like a dE)

    ix=where(en ge enlo and en lt enhi) ;indices of elements in en that have energies between the limits (enlo and enhi)

    bbfracv=dblarr(n_elements(Tv)) ;double precision array of float zeros with same size as the list of temperatures, Tv (which has the same size as logT)

    ;go through each temperature and do the calculation
    for i=0,n_elements(Tv)-1 do begin ;for each temperature

        spec=bbnorm(Tv[i],energ)
        ;in any case, must be taking the SED of a normalized blackbody curve at the given temperature, at all the energies (analogous to wavelengths) in the list 
        ; 
    spectot=total(spec[0:n_elements(spec)-2]*endiff) ;ohh i think endiff is like a dE between the energies. and then this is a rough integral of like flux over the energy range to get total flux
    specx=total(spec[ix]*endiff[ix]) ;same idea as line above, but now this is the total integrated flux for Just energies between enlo and enhi

        bbfracv[i]=specx/spectot ;this is what fraction of the total flux is contained between enlo and enhi
        ;and it is going into bbfracv so at the end bbfracv will contain that value for each of the temperatures we consider (Tv)

    endfor

    ;save the bb fraction vector (fracv)
    save,logT,bbfracv,filename=ftop+fname ;save the array of (log) temperatures and bbfracv to a file that's called something like 'bbf00.30_00.70.idl'

endif

;now restore the bbfracv file
restore,ftop+fname ;restore the parameters from the file we just saved

;do the (logarithmic) interpolation
Tl=alog10(T) ;Tl is the log of T (this is the temperature that was inputted)
ilow=where(logT lt Tl) ;indices corresponding to all values in the array logT (created in this procdure) less than (log of) the inputted T
ihi=where(logT ge Tl) ;likewise, indices for all logT's greater than inputted T

lowT=logT[ilow[n_elements(ilow)-1]] ;selecting out the value in logT that is *just* below the inputted T
lowbbfr=bbfracv[ilow[n_elements(ilow)-1]] ;selecting out the value in bbfracv corresponding to lowT
hiT=logT[ihi[0]] ;likewise, selecting the value just above the inputted T
hibbfr=bbfracv[ihi[0]]

bbfracout=(hibbfr-lowbbfr)/(hiT-lowT)*(Tl-lowT)+lowbbfr ;this is interpolating (in logspace for the T's) to find the exact(-ish) bbfracv value that would correspond to our exact inputted T

return,bbfracout ;in a function (such as this), return specificies the output values that will result
;so if we put bbfrac(enlo,enhi,T) in an equation somewhere else, it would substitute in this value

end

function enstr,en 
;now we're defining a completely separate function, this one turns energy values into convenient strings

if en lt 10. then begin
    
    str='0'+string(en,format='(F4.2)') ;if the energy is < 10, write it like '05'

endif else begin
    str=string(en,format='(F5.2)') ;otherwise write it like '10'

endelse

return,str ;output the appropriate string

end
