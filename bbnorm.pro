

;This is a !NORMALIZED! blackbody spectrum

function bbnorm, T, E

cbb=3.824 ;this is 1/h^3c^2 / 1E57
k=1.3807E-16 ;boltzmann's constant


bbe=1.e20*(E^3.)/(exp(E/(k*T))-1.)

Ebin=diff(E)
bbint=total(bbe[0:n_elements(bbe)-2]*Ebin)
bbn=bbe/bbint

return, bbn

end

