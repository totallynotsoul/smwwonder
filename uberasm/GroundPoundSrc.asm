;this is where ugly stuff's stored

;Don't edit
;I'd move it to the bottom honestly, but errors...
;also, those checks don't work with binary values (%).
;Not actual input values!
!Up = $01;%00000001
!Down = $02;%00000010
!L = $04;%00000100
!R = $08;%00001000
!A = $10;%00010000
!B = $20;%00100000

;am i dumb or what? this doesn't work
;if and(!Button,(!Up|!Down|!B))
if !Button = !Up
  !ControllerTrigger = $16
elseif !Button = !Down
  !ControllerTrigger = $16
elseif !Button = !B
  !ControllerTrigger = $16
else
  !ControllerTrigger = $18
endif

;same but for cancel input
;if and(!CancelButton,(!Up|!Down|!B))
if !CancelButton = !Up
  !CancelControllerTrigger = $16
elseif !CancelButton = !Down
  !CancelControllerTrigger = $16
elseif !CancelButton = !B
  !CancelControllerTrigger = $16
else
  !CancelControllerTrigger = $18
endif

;probably a better way to do this but eh
if !Button = !Up
  !ButtonTrigger = $08
elseif !Button = !Down
  !ButtonTrigger = $04
elseif !Button = !L
  !ButtonTrigger = $20
elseif !Button = !R
  !ButtonTrigger = $10
else;if !Button = or(!B, !A)	;otherwise it's either A or B
  !ButtonTrigger = $80
endif

;same but for cancel
if !CancelButton = !Up
  !CancelButtonTrigger = $08
elseif !CancelButton = !Down
  !CancelButtonTrigger = $04
elseif !CancelButton = !L
  !CancelButtonTrigger = $20
elseif !CancelButton = !R
  !CancelButtonTrigger = $10
else;if !CancelButton = or(!B, !A)
  !CancelButtonTrigger = $80
endif