If you want to use uberASMTool or uberasm patch and Mode50more you must dot the next:

UberASMTool:

1. Open UberASMTool Folder
2. Open asm Folder
3. Open base Folder
4. Open main.asm
5. Erase the line "incsrc statusbar.asm"

uberasm patch:

1. Open uberasm Folder
2. Open "asar_patch.asm"
3. Change:

!statusbar       = !true

for 

!statusbar       = !false

4. Change:

!statusbar_drawn       = !true

for 

!statusbar_drawn       = !false

5. Change:

!nmi       = !true

for 

!nmi       = !false