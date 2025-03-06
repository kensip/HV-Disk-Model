function bbfrac_inp,logT,bbfracv,T

;we assume that logT is evenly spaced in log space
Tl=alog10(T) ;this is just taking the log of T

nT=n_elements(logT) ;logT was defined in bbfrac.pro--- should be restored when you restore the file generated from bbfrac.pro
Tfirst=logT[0] ;lowest T in the array
Tlast=logT[nT-1] ;highest T in the array

igood=indgen(4)+fix(nT*(Tl-Tfirst)/(Tlast-Tfirst))-2 

;do the (logarithmic) interpolation

ilow=igood[where(logT[igood] lt Tl)] ;but in any case from here on it's exactly the same as in bbfrac.pro, see comments there
ihi=igood[where(logT[igood] ge Tl)]

lowT=logT[ilow[n_elements(ilow)-1]]
lowbbfr=bbfracv[ilow[n_elements(ilow)-1]]
hiT=logT[ihi[0]]
hibbfr=bbfracv[ihi[0]]

bbfracout=(hibbfr-lowbbfr)/(hiT-lowT)*(Tl-lowT)+lowbbfr

return,bbfracout

end
