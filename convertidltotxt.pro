; Kendall Sippy, 2024
; Converting necessary info to plot the disk into .txt files (in a csv format) so it can be plotted in Python instead

pro convertidltotxt,bdir

spawn,'ls '+bdir,dlist1 ;topdir was a directory set in fit_inp pro
dlist2=dlist1[where(strmatch(dlist1,'*obs*'))] ; this is seraching dlist1 for any string that follow the form something+'obs'+something

for d=0,n_elements(dlist2)-1 do begin
    dname =dlist2[d]+'/'
    print,dname

    diskpl = file_which(bdir+dname,'diskplotpar_0.000.idl')
    if diskpl eq '' then begin ;if there is no file to plot, do nothing
    endif else begin

        alreadyran = file_which(bdir+dname+'diskphi_0.000/diskplotpar_0.000_yv2.txt') ;if this has already been run on this particular simulation
        if alreadyran eq '' then begin


            phis = ['0.000','0.125','0.250','0.375','0.500','0.625','0.750','0.875']

            for n=0,n_elements(phis)-1 do begin

                print,'phi ='+phis[n]
  
                folder = 'diskphi_'+phis[n]+'/'
                fname = 'diskplotpar_'+phis[n]

                restore,bdir+dname+fname+'.idl'
                print,'Restoring disk parameters'
                ;xv2,yv2,zv2,phf,xin,xout,yin,yout,zin,zout,nprof,iplot,see,T,Tclr,ifr,ibk,nang,angc,filename = bdir+'diskplotpar_'+strang[i]+'.idl' 

                yv2_fname = string(fname)+'_yv2.txt'
                zv2_fname = string(fname)+'_zv2.txt'
                xout_fname = string(fname)+'_xout.txt'
                Tclr_fname = string(fname)+'_Tclr.txt'
                ifr_fname = string(fname)+'_ifr.txt'
                ibk_fname = string(fname)+'_ibk.txt'
                yout_fname = string(fname)+'_yout.txt'
                yin_fname = string(fname)+'_yin.txt'
                zin_fname = string(fname)+'_zin.txt'
                zout_fname = string(fname)+'_zout.txt'
                iplot_fname = string(fname)+'_iplot.txt'
                see_fname = string(fname)+'_see.txt'
                T_fname = string(fname)+'_T.txt'

                ;then below I am turning them all into a csv format in these .txt files, line by line

                openw,1,bdir+dname+folder+yv2_fname
                for i=0,n_elements(yv2[0,*])-1 do begin ;for each row
                    linestr = ''
                    for j=0,n_elements(yv2[*,0])-1 do begin
                        linestr = linestr + string(yv2[i,j])+','
                        ; print,linestr
                    endfor
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote yv2'

                openw,1,bdir+dname+folder+zv2_fname
                for i=0,n_elements(zv2[0,*])-1 do begin ;for each row
                    linestr = ''
                    for j=0,n_elements(zv2[*,0])-1 do begin
                        linestr = linestr + string(zv2[i,j])+','
                        ; print,linestr
                    endfor
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote zv2'

                openw,1,bdir+dname+folder+xout_fname
                linestr = ''
                for i=0,n_elements(xout[*])-1 do begin ;for each row
                    linestr = string(xout[i])
                        ; print,linestr
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote xout'

                openw,1,bdir+dname+folder+Tclr_fname
                for i=0,n_elements(Tclr[0,*])-1 do begin ;for each row
                    linestr = ''
                    for j=0,n_elements(Tclr[*,0])-1 do begin
                        linestr = linestr + string(Tclr[i,j])+','
                        ; print,linestr
                    endfor
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote Tclr'

                openw,1,bdir+dname+folder+ifr_fname
                linestr = ''
                for i=0,n_elements(ifr[*])-1 do begin ;for each row
                    linestr = string(ifr[i])
                        ; print,linestr
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote ifr'

                openw,1,bdir+dname+folder+ibk_fname
                linestr = ''
                for i=0,n_elements(ibk[*])-1 do begin ;for each row
                    linestr = string(ibk[i])
                        ; print,linestr
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote ibk'

                openw,1,bdir+dname+folder+yout_fname
                linestr = ''
                for i=0,n_elements(yout[*])-1 do begin ;for each row
                    linestr = string(yout[i])
                        ; print,linestr
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote yout'

                openw,1,bdir+dname+folder+yin_fname
                linestr = ''
                for i=0,n_elements(yin[*])-1 do begin ;for each row
                    linestr = string(yin[i])
                        ; print,linestr
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote yin'

                openw,1,bdir+dname+folder+zin_fname
                linestr = ''
                for i=0,n_elements(zin[*])-1 do begin ;for each row
                    linestr = string(zin[i])
                        ; print,linestr
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote zin'

                openw,1,bdir+dname+folder+zout_fname
                linestr = ''
                for i=0,n_elements(zout[*])-1 do begin ;for each row
                    linestr = string(zout[i])
                        ; print,linestr
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote zout'

                openw,1,bdir+dname+folder+iplot_fname
                for i=0,n_elements(iplot[0,*])-1 do begin ;for each row
                    linestr = ''
                    for j=0,n_elements(iplot[*,0])-1 do begin
                        linestr = linestr + string(iplot[i,j])+','
                        ; print,linestr
                    endfor
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote iplot'

                openw,1,bdir+dname+folder+see_fname
                for i=0,n_elements(see[0,*])-1 do begin ;for each row
                    linestr = ''
                    for j=0,n_elements(see[*,0])-1 do begin
                        linestr = linestr + string(see[i,j])+','
                        ; print,linestr
                    endfor
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote see'

                openw,1,bdir+dname+folder+T_fname
                for i=0,n_elements(T[0,*])-1 do begin ;for each row
                    linestr = ''
                    for j=0,n_elements(T[*,0])-1 do begin
                        linestr = linestr + string(T[i,j])+','
                        ; print,linestr
                    endfor
                    printf,1,linestr
                endfor
                close,1
                print,'Wrote T'
        

            endfor
        endif
    endelse
endfor

end