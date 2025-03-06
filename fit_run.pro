;This creates input files for doing a set of simulated profiles for
;several disk and beam shapes
;RCH 12/03/04
; Comments added by KIS 2024


; multiplot,/default


spawn,'ls '+topdir,dlist1 ;topdir was a directory set in fit_inp pro
dlist=dlist1[where(strmatch(dlist1,'*obs*'))] ; this is seraching dlist1 for any string that follow the form something+'obs'+something
; and setting the new variable dlist to be the a list of only the elements in dlist1 which meet this condition

for i=0,n_elements(dlist)-1 do begin ;for each of the directories in dlist

;get the directory name
dname=topdir+dlist[i]+'/' ;the name of the particular directory we care about

ranalready=file_which(dname,'diskbeam.idl') ;diskbeam.idl is produced into the disktempsave.pro part, this is basically just to determine if we already ran this one

    if ranalready eq '' then begin ;if no file is found

    ;make the disk temperature files
        disktempsave,dname ; this is calling a procedure 'disktempsave' which is contained in the file disktempsave.pro, and applying it to the directory in question

    ;plot it and get the profiles
        diskspecrest,dname ; likewise calling a procedure 'diskspecrest' from another file
    
    ;so both disktempsave and diskspecrest need to be compiled before this will run
    
    ;remove the disk temperature files because they take up a lot of space 
        spawn,'rm -f '+dname+'dtemp*.idl'

    endif else begin
        goto,endit
    endelse

endit:

plotalready = file_which(dname,'diskphi_0.875/simpp_0.875.csv') ;determine whether we already have .csv files of pulse profs
if plotalready eq '' then begin
    eraseit='y' ;setting this variable which is probably used in one of the procedures below
    fitplotprof_single,dname,eraseit ;running the procedure 'fitplotprof_single' from another file

endif

;The disk files will save regardless & then we can convert to .txts and plot in Python, no need for this unless you want to see disk plots in IDL as it runs
; diskpl = file_which(dname,'diskphi_0.000/diskplotpar_0.000.idl')
; if diskpl eq '' then begin
; endif else begin
; plotdisk,dname
; endelse


endfor

end
