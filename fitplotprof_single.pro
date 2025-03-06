;McKinley Brumback 4/11/19
;A plotting routine to compliment fitplotprof_new where each profile is plotted in its 
;own window -> this allows for easier comparison to observed pulse profiles
;This will produce 8 plots!!
pro fitplotprof_single,bdir,eraseit,plotpps

get_lun, lun ;open a file and assign it a LUN (logical unit number)
print,lun
free_lun, lun ;detach that file from the LUN
close, lun ;close that file

;plot margins
l=0.13
tb=0.18
r=0.07

;set values for loop
nang=8 ;we're plotting 8 disk phi's
ang=findgen(nang)/nang ;array counting up by eigths from 0 to 7/8
inp=''
strang=string(ang,format='(F5.3)') ;string of the angle, from ang
offs=intarr(nang) ;array of integers counting up to 8

;start loop to load and plot each profile
for i=0,nang-1 do begin ;for each disk phi
	a=i+1.
	stri=strtrim(string(i),2) ;these are for the plots later
	stra=strtrim(string(a),2)

	;load in data
 	print,'restoring '+bdir+'diskphi_'+strang[i]+'/inprof.idl' 
    restore,bdir+'diskphi_'+strang[i]+'/inprof.idl'  ;restore this file that gives the luminosity of beam and disk over the beam rotation
	;including inrep,inrepx,instar
	;inrep is total intensity of points on the disk we can see
	;inrepx is the same thing but only within the energy range specified
	;instar is something about the beam/ star brightness

 	;this ERASES the diskvf.idl file (to save space)
 	if eraseit eq 'y' then begin
 		spawn,'rm -f '+bdir+'diskphi_'+strang[i]+'/diskvf.idl'
 	endif
 
 	ntemps=n_elements(instar)


;figure out the offset for the plot
	offsi=where(instar eq max(instar)) ;find index where we have max beam brightness
	offs[i]=offsi[0]-19 ;each integer counting up to 8 now has the value of whatever index was the brightest, minus 19...
	;something about changing the phase offsets to match btwn profiles
	if offs[i] lt 0 then begin
   		print,'going negative!'+string(offs[i])
   		offs[i]=ntemps+offs[i] ;flip the phasees back around to be positive
	endif

	ntemps=n_elements(instar)

	if offs[i] eq 0 then begin
   		io=[offs[i]+indgen(ntemps-offs[i])]
	endif else begin
   		;this are the indices (including the offset)
   		io=[offs[i]+indgen(ntemps-offs[i]),indgen(offs[i])]
	endelse

    x=findgen(ntemps)/ntemps 
    x2=[findgen(ntemps)/ntemps,1.+findgen(ntemps)/ntemps]
    ystar=instar[io]/mean(instar) ;normalized flux from the star
    ystar2=[ystar,ystar]
    yrep=inrepx[io]/mean(inrepx) ;normalized flux from the disk
    yrep2=[yrep,yrep]
    
    ;this is to write output data for simulated pulse profiles in .csv files. comment out for normal model runs
	get_lun, lun
	openw, lun, bdir+'diskphi_'+strang[i]+'/simpp_' + strang[i] + '.csv'
	ndat = n_elements(yrep2)
	print, strang[i]
	for j=0,ndat-1 do begin
		printf, lun, strtrim(string(x2[j]),2) + ',' + strtrim(string(ystar2[j]),2) + ',' + strtrim(string(yrep2[j]),2)
		;print into the file, 'disk phase', 'normalized brightness of the star', 'normalized brightness of the disk
	endfor    
  	free_lun, lun
  	close, lun
    
    print, "finished!"
    pname1= 'p' + stri 
    pname2= 'p' + stra
    tname1= 't' + stri
    
	; ;plot using modern methods, in different window for each iteration
	; If you want to see the plots in IDL
	if plotpps eq 'y' then begin
 	pname1=plot(x2,ystar2,ystyle=1,thick=3,xtitle="Phase",ytitle='Relative intensity (hard solid, soft dotted)') ;plot the hard x-ray (beam) component
 	pname2=plot(x2,yrep2,linestyle=1,thick=4,/overplot) ;plot the soft x-ray (disk) component
 	tname1=text(0.18,0.18,'Diskphase '+strang[i]) ;title
	endif
 
 endfor
 
 end