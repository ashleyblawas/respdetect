C =

          1.00 1374877976.00          0.00  738963208.00
          2.00 1374881055.00          0.01  652500580.00
          3.00 1374883773.00          0.77  672010260.00
          4.00 1374886573.00          0.81  730496968.00
          5.00 1374889617.00          0.55  649056464.00

[S,fn,id] = d3makettab(recdir,prefix,'wav')

S =

          1.00 1374877976.00          0.00  738963208.00
          2.00 1374881055.00          0.01  652500580.00
          3.00 1374883773.00          0.77  672010260.00
          4.00 1374886573.00          0.81  730496968.00
          5.00 1374889617.00          0.55  649056464.00


fn = 

    'bw207a001'    'bw207a002'    'bw207a003'    'bw207a004'    'bw207a005'


id =

  419634708.00

S-C

ans =

             0             0          0.00             0
             0             0         -0.00             0
             0             0          0.00             0
             0             0          0.00             0
             0             0         -0.00             0

R = tag3audit(tag,recdir,prefix,5000)
 Ending audit program
 Remember to save data using saveaudit(tag,R)

R = 

        cue: []
    comment: []

R = tag3audit(tag,recdir,prefix,5110)
 -> 5111.9		diff to last = 5111.9		p =   81.7		freq. = 13.02 kHz
 -> 5112.1		diff to last =    0.2		p =   81.8		freq. = 13.30 kHz
 -> 5113.9		diff to last =    1.8		p =   83.2		freq. = 12.73 kHz
 Ending audit program
 Remember to save data using saveaudit(tag,R)

R = 

        cue: []
    comment: []

R = tag3audit(tag,recdir,prefix,5110)
 -> 5112.0		diff to last = 5112.0		p =   81.7		freq. = 5.89 kHz
 -> 5112.1		diff to last =    0.2		p =   81.9		freq. = 6.03 kHz
 -> 5113.8		diff to last =    1.7		p =   83.2		freq. = 7.17 kHz
 Ending audit program
 Remember to save data using saveaudit(tag,R)