!FreeSpace1 = $308000 
!FreeSpace2 = $318000 
!FreeSpace3 = $328000 
!FreeSpace4 = $338000 
;…

org !FreeSpace1

db "ST","AR"			
dw End-Start-$01		
dw End-Start-$01^$FFFF	

Start:
incbin GFXName1.bin ;replace this for your GFX name
End:	

org !FreeSpace2

db "ST","AR"			
dw End-Start-$01		
dw End-Start-$01^$FFFF	


Start:
incbin GFXName2.bin ;replace this for your GFX name
End:	
org !FreeSpace3

db "ST","AR"			
dw End-Start-$01		
dw End-Start-$01^$FFFF	

Start:
incbin GFXName3.bin ;replace this for your GFX name
End:	

org !FreeSpace4

db "ST","AR"			
dw End-Start-$01		
dw End-Start-$01^$FFFF	

Start:
incbin GFXName4.bin ;replace this for your GFX name
End:	

;…
