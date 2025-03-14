function maskit,nprof,nang,xv2,yv2,zv2
;this masks out the parts of the disk we cannot see
;RCH 1/3/05
; Comments added by KIS 2024

;recall that xv2 is the array of x-components of disk position, containing associated tilt angles, which has been transformed into the observer's frame of view
;likewise for others

xsrt=sort(-xv2) ;this tells us the INDICES of the elements in xv2 in order from lowest to highest-- but by putting the negative here they're now being sorted highest to lowest effectively
; and this was a 2D array--- 'sort' sorts ALL the values in every row + column, and gives them a list of 1D indices
; like instead of the first column being [0:8,0], it's [0:8], and the second column is no longer [0:8,1], it's now [9:16], etc.
ysrt=sort(yv2) ;likewise
zsrt=sort(zv2)

jxv=fix(xsrt/nang) ;divide the list of indices by the number of disk phi angles, and then round that down to the nearest integer
ixv=xsrt-nang*jxv ;if we didn't do the 'fix' step above, this would be equal to zero
;this is like reverse engineering the rows and columns that were originally in xv2, etc.
;jxv will be 0 for the first 8 indices (phis) (what was originally column 0), then 1 for the next 8 indices (same phis) (what was originally column 1), and so on
;jxv corresponds to what were originally the columns (disk radii) in xv2, etc.
;ixv likewise corresponds to what were originally the rows (disk phis) in xv2, etc.

;but importantly both jxv and ixv are long, 1D lists of numbers that tell us the original coordinates of the points, now sorted
;so if we hadn't sorted the things at all, jxv would look like [0,0,0,0,0,0,0,0,1,1,1, etc.]

bdone=intarr(nang,nprof) ;array of integer zeros with dimensions of disk phis by disk radii (so like 8 x 100)
iplot=1+intarr(nang,nprof) ;now it's an array of integer 1's

for j1=0,nprof-1 do begin ;for each disk radius

    for i1=0,nang-1 do begin ;for each disk phi
    ;see if we've already flagged this one

    ii=i1+nang*j1 ;so now we're taking ixv and jxv (which were a reverse-engineering of the original indices), and reverse-reverse-engineering the new indices (those we need for xsrt, etc.)
    ix=ixv[ii] ;this tells us the original disk phi/ row coordinate of a given tilt angle in xv2
    jx=jxv[ii] ;likewise for the disk radius index

    ;so the pair [ix,jx] would tell us the position of the orgiinal value in the array xv2

    if bdone[ix,jx] eq 1 then goto,next1 ;if this has already been run for a given ix,jx, then skip the next part (so as to not overwite it)
    ;we initially set bdone to be an array of zeros, so if it hasn't been touched yet than a given value should be 0 still

    ;this hasn't been covered, so set to visible
    iplot[ix,jx]=1 ;if we've reached this point, then this ix,jx pair hasn't been covered yet
    ;set the associated value in iplot to be 1 (which it should already be from the defn of iplot but whatever)

    ;work out the area we want to cover, including end effects
    case ix of
        0: ixnds=[nang-1,1] ;if ix=0, set ixnds to be this ;i.e. if we're in the first row of xv2
        nang-1: ixnds=[nang-2,0] ;if we're at the last ix, set ixnds to this ;if we're in the last row
        else: ixnds=[ix-1,ix+1] ;otherwise set to this
    endcase

    case jx of  ;likewise for jx
        0: jxnds=[0,1] ;if we're in the first column
        nprof-1: jxnds=[nprof-2,nprof-1] ;if we're in the last column
        else: jxnds=[jx-1,jx+1] ;otherwise
    endcase 

    cy=fltarr(4) ;make cy an array of float zeros w length 4
    cz=fltarr(4) ;make cz an array of float zeros w length 4
            
    yii=yv2[ix,jx] ;find the associated y component that goes with the x we'be been talking about
    zii=zv2[ix,jx] ;likewise for z

    sz=2. ;set sz to be 2

    cy[0]=(yv2[ixnds[1],jxnds[1]]+yii)/sz ; yv2[ixnds[1],jxnds[1]] is the values of y for the ix and jx just above our ix,jx
    ;then adding to the current y (yii), and divide in 2, so averaging them 
    cy[1]=(yv2[ixnds[0],jxnds[1]]+yii)/sz ;likewise now for ix before and jx after ours
    cy[2]=(yv2[ixnds[0],jxnds[0]]+yii)/sz ;likewise for ix before and jx before
    cy[3]=(yv2[ixnds[1],jxnds[0]]+yii)/sz ;likewise for ix after and jx before

    cz[0]=(zv2[ixnds[1],jxnds[1]]+zii)/sz ;same thing for z's
    cz[1]=(zv2[ixnds[0],jxnds[1]]+zii)/sz
    cz[2]=(zv2[ixnds[0],jxnds[0]]+zii)/sz 
    cz[3]=(zv2[ixnds[1],jxnds[0]]+zii)/sz

    ;the above are representing the y and z values of points in a little square area around our current point

    ;find the points covered by the points you're looking at
    ib=where(bdone ne 1 and yv2 ge min(cy) and yv2 le max(cy) $ ;so if yv2 is between the min and max of cy (has the potential to be blocking this point in the y dimension)
             and zv2 ge min(cz) and zv2 le max(cz)) ;likewise for z's
             ;and also make sure bdone isn't already =1, which shouldn't be the case given conditions above, but just to be safe
             ;ib saves the indices of values where this is true
    bdone[xsrt[ii]]=1 ;xsrt[ii] is the 1D coordinate of the associated point xv2, so we're grabbing the associated point for a given disk phi and radius in bdone and setting that equal to 1
    ;indicating that this point is now 'done'

    ibg=where(ib ne xsrt[ii]) ;ibg are the indices of all the ib points Except the one we are looking at right now, xsrt[ii]

    if ibg[0] gt -1 then begin ;ibg is indices so they have to be <-1 unless ibg is an empty array, so this is saying like if there were any points that met the above conditions
        ib=ib[ibg] ;set ib to be the indices within it other than the current point we're talking about
    endif else begin ;otherwise (if ibg is empty)
        ib=-1 ;this is just a placeholder value to represent that ibg was empty
    endelse

    if total(ib) gt -1 then begin ;if ibg isn't empty (if any points met the above conditions/ have the potential to block the current point)

        testp=arepointsinpolygon([cy,cy[0]],[cz,cz[0]],yv2[ib],zv2[ib]) ;is this being blocked by other parts of disk

        ib2=where(testp ne 0) ;indices of points on the disk that are within the polygon, i.e. that you can't see
        


goto,noplot ;skip over the lines below that are plotting stuff

        myplot =plot([cy,cy[0]],[cz,cz[0]]);color=clr1
        over = scatterplot([1.,1.]*yv2[xsrt[ii]],[1.,1.]*zv2[xsrt[ii]],/OVERPLOT,SYMBOL="*",SYM_SIZE=2.0)
        over2 =scatterplot(yv2[ib],zv2[ib],/OVERPLOT,SYMBOL="*",SYM_SIZE=1.0)

        if ib2[0] gt -1 then begin ;if there are points in ib2 (if any of the points are hidden)
            over3 =scatterplot(yv2[ib[ib2]],zv2[ib[ib2]],/OVERPLOT,SYMBOL="+",SYM_SIZE+1.0)
        endif

        stop

noplot:
        if ib2[0] gt -1 then begin  ;if there are values in ib2
            ib3=ib[ib2] ;set ib3 to be only indices from ib that satisfy the conditions of ib2
            iplot[ib3]=0 ;set iplot to be 0 for any points with indices included in ib3
            bdone[ib3]=1 ;set bdone to be one (i.e. we are done with this point) for those same points
         endif
    endif

next1: ;this is where we skip to if the ix,jx index pair has already been run above
endfor

endfor

;remove any solitary pieces
for i2=0,nang-1 do begin ;for each disk phi

    ipltest=iplot[i2,1:(nprof-2)] + $ ;take the row associated with this phi, and all the radii points from pt 1 up to 2 from the end (really 1 from the end)
               iplot[i2,2:(nprof-1)] + $ ;the row associated w this phi, all radii points from pt 2 up to the last point
               iplot[i2,0:(nprof-3)] ;the row associated w this phi, all radii points from pt 0 (first point) up to 3 from the end (really 2 from the end)

    ; so we add all of those up, and the values in iplot are either 0 or 1, so the min we could get is 0 and the max is 3
    ; by shifting around, we are basically finding the total of iplot values for a point and the two point on either side of it, for every point in a given row of iplot

    isol=where(ipltest ne 0 and ipltest ne 3) ;indices where ipltest has values either 1 or 2
    ;so if that total were 0, that means the point and both points next to it are not visible, and if it's 3 that means all three of them are visible
    ;so the isolated points are considered ones where it was something like 011, 101, 010, 001, etc.

    iplot[i2,isol+1]=0 ;set the corresponding points to the isolated points (identified by their indices in isol) to be 0 (not visible) in iplot
endfor

return,iplot
end
