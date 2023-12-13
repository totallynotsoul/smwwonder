!FreeSpace = $308000 

org !FreeSpace

db "ST","AR"			
dw End-Start-$01		
dw End-Start-$01^$FFFF	

Start:
incbin APlayerGFX.bin ;replace this for your GFX name
End:
