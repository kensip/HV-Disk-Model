function diff, x

;this simply takes the difference of successive elements of an array
;the array must be one-dimensional for now
;RCH 12/11/03

x1=x[0:(n_elements(x)-2)]
x2=x[1:(n_elements(x)-1)]

return,x2-x1

end
