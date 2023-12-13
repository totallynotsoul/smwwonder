@echo off
@echo SMWWonder Builder a0.05 by Soul
echo Place a clean unheadered/headered rom of SMW named "SMW.smc" in this foldere
md buildtools
copy SMW.smc wonder.smc
copy SMW.smc wonderTEMP.smc
"asar.exe" "sa1/sa1.asm" wonderbuild.smc
"buildtools\flips.exe" "buildtools/wonder.bps" "wonderTEMP.smc
"buildtools\Lunar Magic.exe" -ImportAllGraphics wonderbuild.smc
"buildtools\Lunar Magic.exe" -ImportMultLevels wonderbuild.smc "buildtools\Levels\"
"buildtools\Lunar Magic.exe" -TransferOverworld wonderbuild.smc "wonderTEMP.smc"
"buildtools\Lunar Magic.exe" -ImportAllMap16 wonderbuild.smc "buildtools\Map16.map16"
"buildtools\Lunar Magic.exe" -TransferLevelGlobalExAnim "wonderTEMP.smc" wonderbuild.smc
"buildtools\Lunar Magic.exe" -TransferOverworld wonderbuild.smc "wonderTEMP.smc"
"buildtools\Lunar Magic.exe" -TransferTitleScreen wonderbuild.smc "wonderTEMP.smc"
"buildtools\Lunar Magic.exe" -ImportSharedPalette wonderbuild.smc "buildtools\Shared.pal"
"Sprites/pixi.exe" "wonder.smc"
"uberasm/UberASMTool.exe" list.txt "../wonderbuild.smc"
"AMK/AddmusicK.exe" wonder.smc
"gps/gps.exe list.txt wonder.smc
echo Ignore this warning.
"asar.exe" "code/hexedits.asm" wonderbuild.smc
"asar.exe" "code/hdmafix1.asm" wonderbuild.smc
"asar.exe" "code/hdmafix2.asm" wonderbuild.smc
"asar.exe" "code/InlineLayer3Message.asm" wonderbuild.smc
"asar.exe" "code/nintendo_logo_expand.asm" wonderbuild.smc
"asar.exe" "code/NoTitleMovement.asm" wonderbuild.smc
"asar.exe" "code/optimize_2132_store.asm" wonderbuild.smc
"asar.exe" "code/ow_event_restore.asm" wonderbuild.smc
"asar.exe" "code/YoshiMsgPatch.asm" wonderbuild.smc
"asar.exe" "PEK/powerup.asm" wonder.smc
pause
