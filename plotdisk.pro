pro plotdisk,bdir

;this code was originally in dtmpspec.pro, I moved it out into another file
;Comments by KIS 2024

spawn,'ls '+bdir,dlist1 ;topdir was a directory set in fit_inp pro
dlist2=dlist1[where(strmatch(dlist1,'diskplotpar*'))] ; this is seraching dlist1 for any string that follow the form something+'obs'+something

clrdisk=255

for i_d=0,n_elements(dlist2)-1 do begin

    print,dlist2[i_d]
    restore,bdir+dlist2[i_d]

;Plot the DISK (if so desired) 

    ; plot it again, this time without plotting the blocked regions
    plot,yv2[0,[0,1]],zv2[0,[0,1]],$
             linestyle=ls, yrange=[-1.2, 1.2], xrange=[-1.4, 1.4],$
             xstyle=1,ystyle=1,$
             color=clrdisk

    
        for i=0,n_elements(phf)-1 do begin
    
    ;plot the whole disk first
            interval=5.
            if fix(i/interval) eq ceil(i/interval) then begin
                oplot,yv2[i,*],zv2[i,*], linestyle=ls, color=clrdisk
            endif
    
    
            if xout[i] gt 0. then begin
                
                ls=0
                
            endif else begin
                ls=1
            endelse
            
            for j=0,nprof-2 do begin
     
            if iplot[i,j] eq 1 and see[i,j] eq 1 and T[i,j] ge 0. then begin
                oplot,yv2[i,[j,j+1]],zv2[i,[j,j+1]], $;linestyle=ls$
                  color=Tclr[i,j]
    
               endif
    
           endfor
           
    
       endfor
    
    
    ;plot the inner and outer rings
    ;fix the front and back indices so the rings come out OK
       icutf=where(diff(ifr) ne 1)
       icutf=icutf[0]
    
    
       if icutf ge 0 then begin
           ifr2=[ifr[(icutf+1):(n_elements(ifr)-1)], ifr[0:icutf]]
           ifr=ifr2
       endif
       
       if yout[ifr[n_elements(ifr)-1]] eq yout[ifr[0]] then begin
           ifr2=ifr[0:n_elements(ifr)-2]
           ifr=ifr2
       endif
       
       icutb=where(diff(ibk) ne 1)
    
       icutb=icutb[0]
       if icutb ge 0 then begin
           ibk=[ibk[(icutb+1):n_elements(ibk)-1], ibk[0:icutb]]
       endif
    
       if yout[ibk[n_elements(ibk)-1]] eq yout[ibk[0]] then begin
           ibk=ibk[0:n_elements(ibk)-2]
           
       endif
    
    
    ;plot it
    
       oplot,yin[ifr],zin[ifr],color=clrdisk
       oplot,yin[ibk],zin[ibk],linestyle=1,color=clrdisk
       oplot,yout[ifr],zout[ifr],color=clrdisk
       oplot,yout[ibk],zout[ibk],linestyle=1,color=clrdisk
    
        ;plot the star
        oplot,[0.,0.],[0.,0.],psym=2

    stop

endfor

end
    