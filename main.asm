; Hello World - Escreve mensagem armazenada na memoria na tela


; ------- TABELA DE CORES -------
; adicione ao caracter para Selecionar a cor correspondente

; 0 branco                          0000 0000
; 256 marrom                        0001 0000
; 512 verde                         0010 0000
; 768 oliva                         0011 0000
; 1024 azul marinho                 0100 0000
; 1280 roxo                         0101 0000
; 1536 teal                         0110 0000
; 1792 prata                        0111 0000
; 2048 cinza                        1000 0000
; 2304 vermelho                     1001 0000
; 2560 lima                         1010 0000
; 2816 amarelo                      1011 0000
; 3072 azul                         1100 0000
; 3328 rosa                         1101 0000
; 3584 aqua                         1110 0000
; 3840 branco                       1111 0000


characterPosition: var #1
characterLastPosition: var #1
seed: var #1

jmp main

;---- Inicio do Programa Principal -----

main:
	call PrintInitialScreen
	call WaitUntilSpaceIsPressed
	call PrintBlackScreen
    
	loadn r0, #41 ;--posicao inicial
	store characterPosition, r0	
	
	loadn r0, #0
	loadn r1, #0
		
	Loop:
		loadn r2, #30
		mod r2, r0, r2
		cmp r2, r1
		ceq MoveChar 
		
		call Delay
		inc r0
		jmp Loop
	
	halt
	
;---- Fim do Programa Principal -----
	
WaitUntilSpaceIsPressed:
	push r0
	push r1	
	push r2
	
	loadn r0, #' '
	loadn r2, #0
	
	hangLoop:
	    inc r2
		inchar r1
		cmp r0, r1
		jeq WaitUntilSpaceIsPressed_End
		jmp hangLoop
		
	WaitUntilSpaceIsPressed_End:	
	store seed, r2
	
	pop r2	
	pop r1
	pop r0
	rts	
	
MoveChar: 
	push r0
	push r1
	
	call CalcCharPosition
	
	load r0, characterPosition
	load r1, characterLastPosition
		
	cmp r0, r1
	jeq MoverChar_End
	
	call refreshBrightedArea
	call eraseChar
	call DrawChar
	
	MoverChar_End:
	pop r1
	pop r0
	rts

CalcCharPosition: 
	push r0
	push r1
	push r2
	push r3
	push r4
	
	load r0, characterPosition
	
	inchar r1
	
	loadn r2, #'w'
	cmp r1, r2
	jeq CalcCharPositionUp
	
	loadn r2, #'a'
	cmp r1, r2
	jeq CalcCharPositionLeft
	
	loadn r2, #'s'
	cmp r1, r2
	jeq CalcCharPositionDown

	loadn r2, #'d'
	cmp r1, r2
	jeq CalcCharPositionRight
	
	checkCollision: 
		call ensureMoveWontCollide
	
	CalcCharPosition_End:
	store characterPosition, r0
	CalcCharPosition_KeepSamePosition_End:
	
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

CalcCharPositionUp: 
	loadn r1, #40
	cmp r0, r1
	jle checkCollision
	sub r0, r0, r1
	jmp checkCollision

CalcCharPositionLeft: 
	loadn r1, #40
	loadn r2, #0
	mod r1, r0, r1
	cmp r1, r2
	jeq checkCollision
	dec r0
	jmp checkCollision

CalcCharPositionDown: 
	loadn r1, #1159
	cmp r0, r1
	jgr checkCollision
	loadn r1, #40
	add r0, r0, r1
	jmp checkCollision

CalcCharPositionRight: 
	loadn r1, #40
	loadn r2, #39
	mod r1, r0, r1
	cmp r1, r2
	jeq checkCollision
	inc r0
	jmp checkCollision

ensureMoveWontCollide:
	push r1
	push r2
	push r3
	push r4
	
	loadn r4, #0 ;block charcode
	loadn r1, #fase1
	
	add r2, r1, r0
	loadi r3, r2
	
	cmp r3, r4
	jne ensureMoveWontCollide_End 
	load r0, characterPosition
	
	ensureMoveWontCollide_End:
	pop r4
	pop r3
	pop r2
	pop r1
	rts

eraseChar: 
	push r0
	push r1
	push r2
	push r3
	
	load r0, characterLastPosition
	loadn r1, #fase1
	add r2, r1, r0
	loadi r3, r2
	
	outchar r3, r0 
	
	pop r3
	pop r2
	pop r1
	pop r0
	rts

DrawChar:
	push r0
	push r1
	
	loadn r1, #1 ; Charcode que representa o personagem
	load r0, characterPosition
	outchar r1, r0
	store characterLastPosition, r0
	
	pop r1
	pop r2
	rts

refreshBrightedArea: 
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	loadn r3, #fase1
	;---------------------------------
	; apagando a área relativa a posição anterior
	loadn r5, #3967 ;black char  
	
	loadn r6, #1	
	
	;;esquerda
	mov r4, r1
	sub r4, r4, r6
	outchar r5, r4
	
	;;esquerda-esquerda
	loadn r7, #40
	
	sub r4, r4, r6
	mod r2, r4, r7
	loadn r7, #39
	cmp r2, r7
	
	jeg skipClearLeftLeft  
	
	outchar r5, r4
	
	skipClearLeftLeft:
	
	;;direita
	mov r4, r1
	add r4, r4, r6
	outchar r5, r4
	
	;;direita-direita
	loadn r7, #40
	
	add r4, r4, r6
	mod r2, r4, r7
	loadn r7, #1
	cmp r2, r7
	
	jel skipEraseRightRight  
	
	outchar r5, r4
	
	skipEraseRightRight:

	loadn r6, #40	
	
	;;cima
	mov r4, r1
	sub r4, r4, r6
	outchar r5, r4
	
	;;cima-cima
	
	loadn r7, #0
	
	sub r4, r4, r6
	cmp r4, r7
	
	jel skipEraseUpUp
	
	outchar r5, r4
	
	skipEraseUpUp: 
	
	;;baixo
	mov r4, r1
	add r4, r4, r6
	outchar r5, r4
	
	;;baixo-baixo
	
	loadn r7, #1199
	
	add r4, r4, r6
	cmp r4, r7
	
	jeg skipEraseDownDown
	
	outchar r5, r4
	
	skipEraseDownDown:
	
	loadn r6, #39	
	
	;;diagonal principal - direita
	mov r4, r1
	sub r4, r4, r6
	outchar r5, r4
	
	;;diagonal principal - esquerda
	mov r4, r1
	add r4, r4, r6
	outchar r5, r4
	
	loadn r6, #41	
	
	;;diagonal secundária - esquerda
	mov r4, r1
	sub r4, r4, r6
	outchar r5, r4
	
	;;diagonal secundária - direita
	mov r4, r1
	add r4, r4, r6
	outchar r5, r4
	
	;---------------------------------
	; mostrando a área relativa a posição atual

	loadn r6, #1
	
	;;esquerda
	mov r4, r0
	sub r4, r4, r6
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	;;esquerda-esquerda
	loadn r7, #40
	
	sub r4, r4, r6
	mod r2, r4, r7
	loadn r7, #39
	cmp r2, r7
	
	jeg skipPrintLeftLeft  
	
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	skipPrintLeftLeft:
	
	;;direita
	mov r4, r0
	add r4, r4, r6
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	;;direita-direita
	loadn r7, #40
	
	add r4, r4, r6
	mod r2, r4, r7
	loadn r7, #1
	cmp r2, r7
	
	jel skipPrintRightRight  
	
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	skipPrintRightRight:
	
	loadn r6, #40

	;;cima
	mov r4, r0
	sub r4, r4, r6
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	;;cima-cima
	
	loadn r7, #0
	
	sub r4, r4, r6
	cmp r4, r7
	
	jel skipPrintUpUp
	
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	skipPrintUpUp: 
	
	;;baixo
	mov r4, r0
	add r4, r4, r6
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	;;baixo-baixo
	
	loadn r7, #1199
	
	add r4, r4, r6
	cmp r4, r7
	
	jeg skipPrintDownDown
	
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	skipPrintDownDown:
	
	loadn r6, #41

	;;diagonal principal - esquerda
	mov r4, r0
	add r4, r4, r6
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	;;diagonal principal - direita
	mov r4, r0
	sub r4, r4, r6
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	loadn r6, #39

	;;diagonal secundária - esquerda
	mov r4, r0
	add r4, r4, r6
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	;;diagonal secundária - direita
	loadn r6, #39
	mov r4, r0
	sub r4, r4, r6
	add r5, r3, r4
	loadi r5, r5
	outchar r5, r4
	
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

Delay:
	push r0
	push r1
	
	loadn r1, #5  
   Delay_volta2:				
	loadn R0, #3000	
   Delay_volta: 
	dec R0					
	jnz Delay_volta	
	dec R1
	jnz Delay_volta2
	
	pop R1
	pop R0
	rts				
	
PrintInitialScreen:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #inicial
  loadn R1, #0
  loadn R2, #1200

  PrintInitialScreenLoop:

    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2

    jne PrintInitialScreenLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts

PrintBlackScreen:
  push R0
  push R1
  push R2
  push R3
  
  loadn R0, #3967 ;; black char
  loadn R1, #0
  loadn R2, #1200

  PrintBlackScreenLoop:
  	outchar R0, R1
  	inc R1
    cmp R1, R2
    jne PrintBlackScreenLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts

printfase1Screen:
	push R0
 	push R1
 	push R2
  	push R3

  	loadn R0, #fase1
  	loadn R1, #0
  	loadn R2, #1200

  	printfase1ScreenLoop:

		add R3, R0, R1
		loadi R3, R3
		outchar R3, R1
		inc R1
		cmp R1, R2

		jne printfase1ScreenLoop

  	pop R3
  	pop R2
  	pop R1
  	pop R0
  	rts
  	
inicial : var #1200
;Linha 0
static inicial + #0, #3967
static inicial + #1, #3967
static inicial + #2, #3967
static inicial + #3, #3967
static inicial + #4, #3967
static inicial + #5, #3967
static inicial + #6, #3967
static inicial + #7, #3967
static inicial + #8, #3967
static inicial + #9, #3967
static inicial + #10, #3967
static inicial + #11, #3967
static inicial + #12, #3967
static inicial + #13, #3967
static inicial + #14, #3967
static inicial + #15, #3967
static inicial + #16, #3967
static inicial + #17, #3967
static inicial + #18, #3967
static inicial + #19, #3967
static inicial + #20, #3967
static inicial + #21, #3967
static inicial + #22, #3967
static inicial + #23, #3967
static inicial + #24, #3967
static inicial + #25, #3967
static inicial + #26, #3967
static inicial + #27, #3967
static inicial + #28, #3967
static inicial + #29, #3967
static inicial + #30, #3967
static inicial + #31, #3967
static inicial + #32, #3967
static inicial + #33, #3967
static inicial + #34, #3967
static inicial + #35, #3967
static inicial + #36, #3967
static inicial + #37, #3967
static inicial + #38, #3967
static inicial + #39, #3967

;Linha 1
static inicial + #40, #3967
static inicial + #41, #3967
static inicial + #42, #3967
static inicial + #43, #3967
static inicial + #44, #3967
static inicial + #45, #3967
static inicial + #46, #3967
static inicial + #47, #3967
static inicial + #48, #3967
static inicial + #49, #3967
static inicial + #50, #3967
static inicial + #51, #3967
static inicial + #52, #3967
static inicial + #53, #3967
static inicial + #54, #3967
static inicial + #55, #3967
static inicial + #56, #3967
static inicial + #57, #3967
static inicial + #58, #3967
static inicial + #59, #3967
static inicial + #60, #3967
static inicial + #61, #3967
static inicial + #62, #3967
static inicial + #63, #3967
static inicial + #64, #3967
static inicial + #65, #3967
static inicial + #66, #3967
static inicial + #67, #3967
static inicial + #68, #3967
static inicial + #69, #3967
static inicial + #70, #3967
static inicial + #71, #3967
static inicial + #72, #3967
static inicial + #73, #3967
static inicial + #74, #3967
static inicial + #75, #3967
static inicial + #76, #3967
static inicial + #77, #3967
static inicial + #78, #3967
static inicial + #79, #3967

;Linha 2
static inicial + #80, #3967
static inicial + #81, #3967
static inicial + #82, #3967
static inicial + #83, #3967
static inicial + #84, #3967
static inicial + #85, #3967
static inicial + #86, #3967
static inicial + #87, #3967
static inicial + #88, #3967
static inicial + #89, #3967
static inicial + #90, #3967
static inicial + #91, #3967
static inicial + #92, #3967
static inicial + #93, #3967
static inicial + #94, #3967
static inicial + #95, #3967
static inicial + #96, #3967
static inicial + #97, #3967
static inicial + #98, #3967
static inicial + #99, #3967
static inicial + #100, #3967
static inicial + #101, #3967
static inicial + #102, #3967
static inicial + #103, #3967
static inicial + #104, #3967
static inicial + #105, #3967
static inicial + #106, #3967
static inicial + #107, #3967
static inicial + #108, #3967
static inicial + #109, #3967
static inicial + #110, #3967
static inicial + #111, #3967
static inicial + #112, #3967
static inicial + #113, #3967
static inicial + #114, #3967
static inicial + #115, #3967
static inicial + #116, #3967
static inicial + #117, #3967
static inicial + #118, #3967
static inicial + #119, #3967

;Linha 3
static inicial + #120, #3967
static inicial + #121, #3967
static inicial + #122, #3967
static inicial + #123, #3967
static inicial + #124, #3967
static inicial + #125, #3967
static inicial + #126, #3967
static inicial + #127, #3967
static inicial + #128, #3967
static inicial + #129, #3967
static inicial + #130, #3967
static inicial + #131, #3967
static inicial + #132, #3967
static inicial + #133, #3967
static inicial + #134, #3967
static inicial + #135, #3967
static inicial + #136, #3967
static inicial + #137, #3967
static inicial + #138, #3967
static inicial + #139, #3967
static inicial + #140, #3967
static inicial + #141, #3967
static inicial + #142, #3967
static inicial + #143, #3967
static inicial + #144, #3967
static inicial + #145, #3967
static inicial + #146, #3967
static inicial + #147, #3967
static inicial + #148, #3967
static inicial + #149, #3967
static inicial + #150, #3967
static inicial + #151, #3967
static inicial + #152, #3967
static inicial + #153, #3967
static inicial + #154, #3967
static inicial + #155, #3967
static inicial + #156, #3967
static inicial + #157, #3967
static inicial + #158, #3967
static inicial + #159, #3967

;Linha 4
static inicial + #160, #3967
static inicial + #161, #3967
static inicial + #162, #3967
static inicial + #163, #3967
static inicial + #164, #3967
static inicial + #165, #3967
static inicial + #166, #3967
static inicial + #167, #3967
static inicial + #168, #3967
static inicial + #169, #3967
static inicial + #170, #3967
static inicial + #171, #3967
static inicial + #172, #3967
static inicial + #173, #3967
static inicial + #174, #3967
static inicial + #175, #3967
static inicial + #176, #3967
static inicial + #177, #3967
static inicial + #178, #3967
static inicial + #179, #3967
static inicial + #180, #3967
static inicial + #181, #3967
static inicial + #182, #3967
static inicial + #183, #3967
static inicial + #184, #3967
static inicial + #185, #3967
static inicial + #186, #3967
static inicial + #187, #3967
static inicial + #188, #3967
static inicial + #189, #3967
static inicial + #190, #3967
static inicial + #191, #3967
static inicial + #192, #3967
static inicial + #193, #3967
static inicial + #194, #3967
static inicial + #195, #3967
static inicial + #196, #3967
static inicial + #197, #3967
static inicial + #198, #3967
static inicial + #199, #3967

;Linha 5
static inicial + #200, #3967
static inicial + #201, #3967
static inicial + #202, #3967
static inicial + #203, #3967
static inicial + #204, #3967
static inicial + #205, #3967
static inicial + #206, #3967
static inicial + #207, #3967
static inicial + #208, #3967
static inicial + #209, #3967
static inicial + #210, #3967
static inicial + #211, #3967
static inicial + #212, #3967
static inicial + #213, #3967
static inicial + #214, #3967
static inicial + #215, #3967
static inicial + #216, #3967
static inicial + #217, #3967
static inicial + #218, #3967
static inicial + #219, #3967
static inicial + #220, #3967
static inicial + #221, #3967
static inicial + #222, #3967
static inicial + #223, #3967
static inicial + #224, #3967
static inicial + #225, #3967
static inicial + #226, #3967
static inicial + #227, #3967
static inicial + #228, #3967
static inicial + #229, #3967
static inicial + #230, #3967
static inicial + #231, #3967
static inicial + #232, #3967
static inicial + #233, #3967
static inicial + #234, #3967
static inicial + #235, #3967
static inicial + #236, #3967
static inicial + #237, #3967
static inicial + #238, #3967
static inicial + #239, #3967

;Linha 6
static inicial + #240, #3967
static inicial + #241, #3967
static inicial + #242, #3967
static inicial + #243, #3967
static inicial + #244, #3967
static inicial + #245, #3967
static inicial + #246, #3967
static inicial + #247, #3967
static inicial + #248, #3967
static inicial + #249, #3967
static inicial + #250, #3967
static inicial + #251, #3967
static inicial + #252, #3967
static inicial + #253, #3967
static inicial + #254, #3967
static inicial + #255, #3967
static inicial + #256, #3967
static inicial + #257, #3967
static inicial + #258, #3967
static inicial + #259, #3967
static inicial + #260, #3967
static inicial + #261, #3967
static inicial + #262, #3967
static inicial + #263, #3967
static inicial + #264, #3967
static inicial + #265, #3967
static inicial + #266, #3967
static inicial + #267, #3967
static inicial + #268, #3967
static inicial + #269, #3967
static inicial + #270, #3967
static inicial + #271, #3967
static inicial + #272, #3967
static inicial + #273, #3967
static inicial + #274, #3967
static inicial + #275, #3967
static inicial + #276, #3967
static inicial + #277, #3967
static inicial + #278, #3967
static inicial + #279, #3967

;Linha 7
static inicial + #280, #3967
static inicial + #281, #3967
static inicial + #282, #3967
static inicial + #283, #0
static inicial + #284, #0
static inicial + #285, #0
static inicial + #286, #0
static inicial + #287, #0
static inicial + #288, #0
static inicial + #289, #0
static inicial + #290, #0
static inicial + #291, #0
static inicial + #292, #3967
static inicial + #293, #3967
static inicial + #294, #3967
static inicial + #295, #3967
static inicial + #296, #3967
static inicial + #297, #3967
static inicial + #298, #3967
static inicial + #299, #3967
static inicial + #300, #3967
static inicial + #301, #3967
static inicial + #302, #3967
static inicial + #303, #3967
static inicial + #304, #3967
static inicial + #305, #3967
static inicial + #306, #3967
static inicial + #307, #3967
static inicial + #308, #3967
static inicial + #309, #3967
static inicial + #310, #3967
static inicial + #311, #3967
static inicial + #312, #3967
static inicial + #313, #3967
static inicial + #314, #3967
static inicial + #315, #3967
static inicial + #316, #3967
static inicial + #317, #3967
static inicial + #318, #3967
static inicial + #319, #3967

;Linha 8
static inicial + #320, #3967
static inicial + #321, #3967
static inicial + #322, #3967
static inicial + #323, #0
static inicial + #324, #3967
static inicial + #325, #3967
static inicial + #326, #3967
static inicial + #327, #3967
static inicial + #328, #3967
static inicial + #329, #3967
static inicial + #330, #3967
static inicial + #331, #3967
static inicial + #332, #3967
static inicial + #333, #3967
static inicial + #334, #3967
static inicial + #335, #3967
static inicial + #336, #3967
static inicial + #337, #3967
static inicial + #338, #3967
static inicial + #339, #3967
static inicial + #340, #3967
static inicial + #341, #3967
static inicial + #342, #3967
static inicial + #343, #3967
static inicial + #344, #3967
static inicial + #345, #3967
static inicial + #346, #3967
static inicial + #347, #3967
static inicial + #348, #3967
static inicial + #349, #3967
static inicial + #350, #3967
static inicial + #351, #3967
static inicial + #352, #3967
static inicial + #353, #3967
static inicial + #354, #3967
static inicial + #355, #3967
static inicial + #356, #3967
static inicial + #357, #3967
static inicial + #358, #3967
static inicial + #359, #3967

;Linha 9
static inicial + #360, #3967
static inicial + #361, #3967
static inicial + #362, #3967
static inicial + #363, #0
static inicial + #364, #3967
static inicial + #365, #3967
static inicial + #366, #3967
static inicial + #367, #3967
static inicial + #368, #3967
static inicial + #369, #3967
static inicial + #370, #3967
static inicial + #371, #3967
static inicial + #372, #3967
static inicial + #373, #3967
static inicial + #374, #3967
static inicial + #375, #3967
static inicial + #376, #3967
static inicial + #377, #3967
static inicial + #378, #3967
static inicial + #379, #3967
static inicial + #380, #3967
static inicial + #381, #3967
static inicial + #382, #3967
static inicial + #383, #3967
static inicial + #384, #3967
static inicial + #385, #3967
static inicial + #386, #3967
static inicial + #387, #3967
static inicial + #388, #3967
static inicial + #389, #3967
static inicial + #390, #3967
static inicial + #391, #3967
static inicial + #392, #3967
static inicial + #393, #3967
static inicial + #394, #3967
static inicial + #395, #3967
static inicial + #396, #3967
static inicial + #397, #3967
static inicial + #398, #3967
static inicial + #399, #3967

;Linha 10
static inicial + #400, #3967
static inicial + #401, #3967
static inicial + #402, #3967
static inicial + #403, #0
static inicial + #404, #3967
static inicial + #405, #3967
static inicial + #406, #3967
static inicial + #407, #3967
static inicial + #408, #3967
static inicial + #409, #3967
static inicial + #410, #3967
static inicial + #411, #3967
static inicial + #412, #3967
static inicial + #413, #3967
static inicial + #414, #3967
static inicial + #415, #3967
static inicial + #416, #3967
static inicial + #417, #3967
static inicial + #418, #3967
static inicial + #419, #3967
static inicial + #420, #3967
static inicial + #421, #3967
static inicial + #422, #3967
static inicial + #423, #3967
static inicial + #424, #3967
static inicial + #425, #3967
static inicial + #426, #3967
static inicial + #427, #3967
static inicial + #428, #3967
static inicial + #429, #3967
static inicial + #430, #3967
static inicial + #431, #3967
static inicial + #432, #3967
static inicial + #433, #3967
static inicial + #434, #3967
static inicial + #435, #3967
static inicial + #436, #3967
static inicial + #437, #3967
static inicial + #438, #3967
static inicial + #439, #3967

;Linha 11
static inicial + #440, #3967
static inicial + #441, #3967
static inicial + #442, #3967
static inicial + #443, #0
static inicial + #444, #3967
static inicial + #445, #3967
static inicial + #446, #3967
static inicial + #447, #3967
static inicial + #448, #3967
static inicial + #449, #3967
static inicial + #450, #3967
static inicial + #451, #3967
static inicial + #452, #3967
static inicial + #453, #3967
static inicial + #454, #3967
static inicial + #455, #3967
static inicial + #456, #3967
static inicial + #457, #3967
static inicial + #458, #3967
static inicial + #459, #3967
static inicial + #460, #3967
static inicial + #461, #3967
static inicial + #462, #3967
static inicial + #463, #3967
static inicial + #464, #3967
static inicial + #465, #3967
static inicial + #466, #3967
static inicial + #467, #3967
static inicial + #468, #3967
static inicial + #469, #3967
static inicial + #470, #3967
static inicial + #471, #3967
static inicial + #472, #3967
static inicial + #473, #3967
static inicial + #474, #3967
static inicial + #475, #3967
static inicial + #476, #3967
static inicial + #477, #3967
static inicial + #478, #3967
static inicial + #479, #3967

;Linha 12
static inicial + #480, #3967
static inicial + #481, #3967
static inicial + #482, #3967
static inicial + #483, #0
static inicial + #484, #0
static inicial + #485, #0
static inicial + #486, #0
static inicial + #487, #0
static inicial + #488, #0
static inicial + #489, #0
static inicial + #490, #0
static inicial + #491, #0
static inicial + #492, #3967
static inicial + #493, #0
static inicial + #494, #0
static inicial + #495, #0
static inicial + #496, #0
static inicial + #497, #0
static inicial + #498, #3967
static inicial + #499, #3967
static inicial + #500, #3967
static inicial + #501, #0
static inicial + #502, #0
static inicial + #503, #0
static inicial + #504, #3967
static inicial + #505, #3967
static inicial + #506, #3967
static inicial + #507, #3967
static inicial + #508, #0
static inicial + #509, #0
static inicial + #510, #0
static inicial + #511, #0
static inicial + #512, #3967
static inicial + #513, #0
static inicial + #514, #0
static inicial + #515, #0
static inicial + #516, #0
static inicial + #517, #3967
static inicial + #518, #3967
static inicial + #519, #3967

;Linha 13
static inicial + #520, #3967
static inicial + #521, #3967
static inicial + #522, #3967
static inicial + #523, #3967
static inicial + #524, #3967
static inicial + #525, #3967
static inicial + #526, #3967
static inicial + #527, #3967
static inicial + #528, #3967
static inicial + #529, #3967
static inicial + #530, #3967
static inicial + #531, #0
static inicial + #532, #3967
static inicial + #533, #0
static inicial + #534, #3967
static inicial + #535, #3967
static inicial + #536, #3967
static inicial + #537, #0
static inicial + #538, #3967
static inicial + #539, #3967
static inicial + #540, #3967
static inicial + #541, #0
static inicial + #542, #3967
static inicial + #543, #0
static inicial + #544, #3967
static inicial + #545, #3967
static inicial + #546, #3967
static inicial + #547, #3967
static inicial + #548, #0
static inicial + #549, #3967
static inicial + #550, #3967
static inicial + #551, #3967
static inicial + #552, #3967
static inicial + #553, #0
static inicial + #554, #3967
static inicial + #555, #3967
static inicial + #556, #3967
static inicial + #557, #3967
static inicial + #558, #3967
static inicial + #559, #3967

;Linha 14
static inicial + #560, #3967
static inicial + #561, #3967
static inicial + #562, #3967
static inicial + #563, #3967
static inicial + #564, #3967
static inicial + #565, #3967
static inicial + #566, #3967
static inicial + #567, #3967
static inicial + #568, #3967
static inicial + #569, #3967
static inicial + #570, #3967
static inicial + #571, #0
static inicial + #572, #3967
static inicial + #573, #0
static inicial + #574, #3967
static inicial + #575, #3967
static inicial + #576, #3967
static inicial + #577, #0
static inicial + #578, #3967
static inicial + #579, #3967
static inicial + #580, #3967
static inicial + #581, #0
static inicial + #582, #3967
static inicial + #583, #0
static inicial + #584, #3967
static inicial + #585, #3967
static inicial + #586, #3967
static inicial + #587, #0
static inicial + #588, #0
static inicial + #589, #3967
static inicial + #590, #3967
static inicial + #591, #3967
static inicial + #592, #3967
static inicial + #593, #0
static inicial + #594, #3967
static inicial + #595, #3967
static inicial + #596, #3967
static inicial + #597, #3967
static inicial + #598, #3967
static inicial + #599, #3967

;Linha 15
static inicial + #600, #3967
static inicial + #601, #3967
static inicial + #602, #3967
static inicial + #603, #3967
static inicial + #604, #3967
static inicial + #605, #3967
static inicial + #606, #3967
static inicial + #607, #3967
static inicial + #608, #3967
static inicial + #609, #3967
static inicial + #610, #3967
static inicial + #611, #0
static inicial + #612, #3967
static inicial + #613, #0
static inicial + #614, #3967
static inicial + #615, #3967
static inicial + #616, #3967
static inicial + #617, #0
static inicial + #618, #3967
static inicial + #619, #3967
static inicial + #620, #0
static inicial + #621, #3967
static inicial + #622, #3967
static inicial + #623, #3967
static inicial + #624, #0
static inicial + #625, #3967
static inicial + #626, #3967
static inicial + #627, #0
static inicial + #628, #3967
static inicial + #629, #3967
static inicial + #630, #3967
static inicial + #631, #3967
static inicial + #632, #3967
static inicial + #633, #0
static inicial + #634, #3967
static inicial + #635, #3967
static inicial + #636, #3967
static inicial + #637, #3967
static inicial + #638, #3967
static inicial + #639, #3967

;Linha 16
static inicial + #640, #3967
static inicial + #641, #3967
static inicial + #642, #3967
static inicial + #643, #3967
static inicial + #644, #3967
static inicial + #645, #3967
static inicial + #646, #3967
static inicial + #647, #3967
static inicial + #648, #3967
static inicial + #649, #3967
static inicial + #650, #3967
static inicial + #651, #0
static inicial + #652, #3967
static inicial + #653, #0
static inicial + #654, #3967
static inicial + #655, #3967
static inicial + #656, #3967
static inicial + #657, #0
static inicial + #658, #3967
static inicial + #659, #3967
static inicial + #660, #0
static inicial + #661, #3967
static inicial + #662, #3967
static inicial + #663, #3967
static inicial + #664, #0
static inicial + #665, #3967
static inicial + #666, #3967
static inicial + #667, #0
static inicial + #668, #3967
static inicial + #669, #3967
static inicial + #670, #3967
static inicial + #671, #3967
static inicial + #672, #3967
static inicial + #673, #0
static inicial + #674, #3967
static inicial + #675, #3967
static inicial + #676, #3967
static inicial + #677, #3967
static inicial + #678, #3967
static inicial + #679, #3967

;Linha 17
static inicial + #680, #3967
static inicial + #681, #3967
static inicial + #682, #3967
static inicial + #683, #3967
static inicial + #684, #3967
static inicial + #685, #3967
static inicial + #686, #3967
static inicial + #687, #3967
static inicial + #688, #3967
static inicial + #689, #3967
static inicial + #690, #3967
static inicial + #691, #0
static inicial + #692, #3967
static inicial + #693, #0
static inicial + #694, #0
static inicial + #695, #0
static inicial + #696, #0
static inicial + #697, #0
static inicial + #698, #3967
static inicial + #699, #3967
static inicial + #700, #0
static inicial + #701, #3967
static inicial + #702, #3967
static inicial + #703, #3967
static inicial + #704, #0
static inicial + #705, #3967
static inicial + #706, #3967
static inicial + #707, #0
static inicial + #708, #3967
static inicial + #709, #3967
static inicial + #710, #3967
static inicial + #711, #3967
static inicial + #712, #3967
static inicial + #713, #0
static inicial + #714, #0
static inicial + #715, #0
static inicial + #716, #0
static inicial + #717, #3967
static inicial + #718, #3967
static inicial + #719, #3967

;Linha 18
static inicial + #720, #3967
static inicial + #721, #3967
static inicial + #722, #3967
static inicial + #723, #3967
static inicial + #724, #3967
static inicial + #725, #3967
static inicial + #726, #3967
static inicial + #727, #3967
static inicial + #728, #3967
static inicial + #729, #3967
static inicial + #730, #3967
static inicial + #731, #0
static inicial + #732, #3967
static inicial + #733, #0
static inicial + #734, #3967
static inicial + #735, #3967
static inicial + #736, #3967
static inicial + #737, #3967
static inicial + #738, #3967
static inicial + #739, #3967
static inicial + #740, #0
static inicial + #741, #3967
static inicial + #742, #3967
static inicial + #743, #3967
static inicial + #744, #0
static inicial + #745, #3967
static inicial + #746, #3967
static inicial + #747, #0
static inicial + #748, #0
static inicial + #749, #3967
static inicial + #750, #3967
static inicial + #751, #3967
static inicial + #752, #3967
static inicial + #753, #0
static inicial + #754, #3967
static inicial + #755, #3967
static inicial + #756, #3967
static inicial + #757, #3967
static inicial + #758, #3967
static inicial + #759, #3967

;Linha 19
static inicial + #760, #3967
static inicial + #761, #3967
static inicial + #762, #3967
static inicial + #763, #3967
static inicial + #764, #3967
static inicial + #765, #3967
static inicial + #766, #3967
static inicial + #767, #3967
static inicial + #768, #3967
static inicial + #769, #3967
static inicial + #770, #3967
static inicial + #771, #0
static inicial + #772, #3967
static inicial + #773, #0
static inicial + #774, #3967
static inicial + #775, #3967
static inicial + #776, #3967
static inicial + #777, #3967
static inicial + #778, #3967
static inicial + #779, #0
static inicial + #780, #0
static inicial + #781, #0
static inicial + #782, #0
static inicial + #783, #0
static inicial + #784, #0
static inicial + #785, #0
static inicial + #786, #3967
static inicial + #787, #3967
static inicial + #788, #0
static inicial + #789, #3967
static inicial + #790, #3967
static inicial + #791, #3967
static inicial + #792, #3967
static inicial + #793, #0
static inicial + #794, #3967
static inicial + #795, #3967
static inicial + #796, #3967
static inicial + #797, #3967
static inicial + #798, #3967
static inicial + #799, #3967

;Linha 20
static inicial + #800, #3967
static inicial + #801, #3967
static inicial + #802, #3967
static inicial + #803, #3967
static inicial + #804, #3967
static inicial + #805, #3967
static inicial + #806, #3967
static inicial + #807, #3967
static inicial + #808, #3967
static inicial + #809, #3967
static inicial + #810, #3967
static inicial + #811, #0
static inicial + #812, #3967
static inicial + #813, #0
static inicial + #814, #3967
static inicial + #815, #3967
static inicial + #816, #3967
static inicial + #817, #3967
static inicial + #818, #3967
static inicial + #819, #0
static inicial + #820, #3967
static inicial + #821, #3967
static inicial + #822, #3967
static inicial + #823, #3967
static inicial + #824, #3967
static inicial + #825, #0
static inicial + #826, #3967
static inicial + #827, #3967
static inicial + #828, #0
static inicial + #829, #3967
static inicial + #830, #3967
static inicial + #831, #3967
static inicial + #832, #3967
static inicial + #833, #0
static inicial + #834, #3967
static inicial + #835, #3967
static inicial + #836, #3967
static inicial + #837, #3967
static inicial + #838, #3967
static inicial + #839, #3967

;Linha 21
static inicial + #840, #3967
static inicial + #841, #3967
static inicial + #842, #3967
static inicial + #843, #3967
static inicial + #844, #3967
static inicial + #845, #3967
static inicial + #846, #3967
static inicial + #847, #3967
static inicial + #848, #3967
static inicial + #849, #3967
static inicial + #850, #3967
static inicial + #851, #0
static inicial + #852, #3967
static inicial + #853, #0
static inicial + #854, #3967
static inicial + #855, #3967
static inicial + #856, #3967
static inicial + #857, #3967
static inicial + #858, #0
static inicial + #859, #3967
static inicial + #860, #3967
static inicial + #861, #3967
static inicial + #862, #3967
static inicial + #863, #3967
static inicial + #864, #3967
static inicial + #865, #3967
static inicial + #866, #0
static inicial + #867, #3967
static inicial + #868, #0
static inicial + #869, #0
static inicial + #870, #3967
static inicial + #871, #3967
static inicial + #872, #3967
static inicial + #873, #0
static inicial + #874, #3967
static inicial + #875, #3967
static inicial + #876, #3967
static inicial + #877, #3967
static inicial + #878, #3967
static inicial + #879, #3967

;Linha 22
static inicial + #880, #3967
static inicial + #881, #3967
static inicial + #882, #3967
static inicial + #883, #0
static inicial + #884, #0
static inicial + #885, #0
static inicial + #886, #0
static inicial + #887, #0
static inicial + #888, #0
static inicial + #889, #0
static inicial + #890, #0
static inicial + #891, #0
static inicial + #892, #3967
static inicial + #893, #0
static inicial + #894, #3967
static inicial + #895, #3967
static inicial + #896, #3967
static inicial + #897, #3967
static inicial + #898, #0
static inicial + #899, #3967
static inicial + #900, #3967
static inicial + #901, #3967
static inicial + #902, #3967
static inicial + #903, #3967
static inicial + #904, #3967
static inicial + #905, #3967
static inicial + #906, #0
static inicial + #907, #3967
static inicial + #908, #3967
static inicial + #909, #0
static inicial + #910, #0
static inicial + #911, #0
static inicial + #912, #3967
static inicial + #913, #0
static inicial + #914, #0
static inicial + #915, #0
static inicial + #916, #0
static inicial + #917, #3967
static inicial + #918, #3967
static inicial + #919, #3967

;Linha 23
static inicial + #920, #3967
static inicial + #921, #3967
static inicial + #922, #3967
static inicial + #923, #3967
static inicial + #924, #3967
static inicial + #925, #3967
static inicial + #926, #3967
static inicial + #927, #3967
static inicial + #928, #3967
static inicial + #929, #3967
static inicial + #930, #3967
static inicial + #931, #3967
static inicial + #932, #3967
static inicial + #933, #3967
static inicial + #934, #3967
static inicial + #935, #3967
static inicial + #936, #3967
static inicial + #937, #3967
static inicial + #938, #3967
static inicial + #939, #3967
static inicial + #940, #3967
static inicial + #941, #3967
static inicial + #942, #3967
static inicial + #943, #3967
static inicial + #944, #3967
static inicial + #945, #3967
static inicial + #946, #3967
static inicial + #947, #3967
static inicial + #948, #3967
static inicial + #949, #3967
static inicial + #950, #3967
static inicial + #951, #3967
static inicial + #952, #3967
static inicial + #953, #3967
static inicial + #954, #3967
static inicial + #955, #3967
static inicial + #956, #3967
static inicial + #957, #3967
static inicial + #958, #3967
static inicial + #959, #3967

;Linha 24
static inicial + #960, #3967
static inicial + #961, #3967
static inicial + #962, #3967
static inicial + #963, #3967
static inicial + #964, #3967
static inicial + #965, #3967
static inicial + #966, #3967
static inicial + #967, #3967
static inicial + #968, #3967
static inicial + #969, #3967
static inicial + #970, #3967
static inicial + #971, #3967
static inicial + #972, #3967
static inicial + #973, #3967
static inicial + #974, #3967
static inicial + #975, #3967
static inicial + #976, #3967
static inicial + #977, #3967
static inicial + #978, #3967
static inicial + #979, #3967
static inicial + #980, #3967
static inicial + #981, #3967
static inicial + #982, #3967
static inicial + #983, #3967
static inicial + #984, #3967
static inicial + #985, #3967
static inicial + #986, #3967
static inicial + #987, #3967
static inicial + #988, #3967
static inicial + #989, #3967
static inicial + #990, #3967
static inicial + #991, #3967
static inicial + #992, #3967
static inicial + #993, #3967
static inicial + #994, #3967
static inicial + #995, #3967
static inicial + #996, #3967
static inicial + #997, #3967
static inicial + #998, #3967
static inicial + #999, #3967

;Linha 25
static inicial + #1000, #3967
static inicial + #1001, #3967
static inicial + #1002, #3967
static inicial + #1003, #3967
static inicial + #1004, #3967
static inicial + #1005, #3967
static inicial + #1006, #3967
static inicial + #1007, #3967
static inicial + #1008, #3967
static inicial + #1009, #3967
static inicial + #1010, #3967
static inicial + #1011, #3967
static inicial + #1012, #3967
static inicial + #1013, #3967
static inicial + #1014, #3967
static inicial + #1015, #3967
static inicial + #1016, #3967
static inicial + #1017, #3967
static inicial + #1018, #3967
static inicial + #1019, #3967
static inicial + #1020, #3967
static inicial + #1021, #3967
static inicial + #1022, #3967
static inicial + #1023, #3967
static inicial + #1024, #3967
static inicial + #1025, #3967
static inicial + #1026, #3967
static inicial + #1027, #3967
static inicial + #1028, #3967
static inicial + #1029, #3967
static inicial + #1030, #3967
static inicial + #1031, #3967
static inicial + #1032, #3967
static inicial + #1033, #3967
static inicial + #1034, #3967
static inicial + #1035, #3967
static inicial + #1036, #3967
static inicial + #1037, #3967
static inicial + #1038, #3967
static inicial + #1039, #3967

;Linha 26
static inicial + #1040, #3967
static inicial + #1041, #3967
static inicial + #1042, #3967
static inicial + #1043, #3967
static inicial + #1044, #3967
static inicial + #1045, #3967
static inicial + #1046, #3967
static inicial + #1047, #3967
static inicial + #1048, #3967
static inicial + #1049, #3967
static inicial + #1050, #3967
static inicial + #1051, #3967
static inicial + #1052, #3967
static inicial + #1053, #3967
static inicial + #1054, #3967
static inicial + #1055, #3967
static inicial + #1056, #3967
static inicial + #1057, #3967
static inicial + #1058, #3967
static inicial + #1059, #3967
static inicial + #1060, #3967
static inicial + #1061, #3967
static inicial + #1062, #3967
static inicial + #1063, #3967
static inicial + #1064, #3967
static inicial + #1065, #3967
static inicial + #1066, #3967
static inicial + #1067, #3967
static inicial + #1068, #3967
static inicial + #1069, #3967
static inicial + #1070, #3967
static inicial + #1071, #3967
static inicial + #1072, #3967
static inicial + #1073, #3967
static inicial + #1074, #3967
static inicial + #1075, #3967
static inicial + #1076, #3967
static inicial + #1077, #3967
static inicial + #1078, #3967
static inicial + #1079, #3967

;Linha 27
static inicial + #1080, #3967
static inicial + #1081, #3967
static inicial + #1082, #3967
static inicial + #1083, #3967
static inicial + #1084, #3967
static inicial + #1085, #3967
static inicial + #1086, #3967
static inicial + #1087, #3967
static inicial + #1088, #3967
static inicial + #1089, #3967
static inicial + #1090, #3967
static inicial + #1091, #3967
static inicial + #1092, #3967
static inicial + #1093, #3967
static inicial + #1094, #3967
static inicial + #1095, #3967
static inicial + #1096, #3967
static inicial + #1097, #3967
static inicial + #1098, #3967
static inicial + #1099, #3967
static inicial + #1100, #3967
static inicial + #1101, #3967
static inicial + #1102, #3967
static inicial + #1103, #3967
static inicial + #1104, #3967
static inicial + #1105, #3967
static inicial + #1106, #3967
static inicial + #1107, #3967
static inicial + #1108, #3967
static inicial + #1109, #3967
static inicial + #1110, #3967
static inicial + #1111, #3967
static inicial + #1112, #3967
static inicial + #1113, #3967
static inicial + #1114, #3967
static inicial + #1115, #3967
static inicial + #1116, #3967
static inicial + #1117, #3967
static inicial + #1118, #3967
static inicial + #1119, #3967

;Linha 28
static inicial + #1120, #3967
static inicial + #1121, #3967
static inicial + #1122, #3967
static inicial + #1123, #3967
static inicial + #1124, #3967
static inicial + #1125, #3967
static inicial + #1126, #3967
static inicial + #1127, #3967
static inicial + #1128, #3967
static inicial + #1129, #3967
static inicial + #1130, #3967
static inicial + #1131, #3967
static inicial + #1132, #3967
static inicial + #1133, #3967
static inicial + #1134, #3967
static inicial + #1135, #3967
static inicial + #1136, #3967
static inicial + #1137, #3967
static inicial + #1138, #3967
static inicial + #1139, #3967
static inicial + #1140, #3967
static inicial + #1141, #3967
static inicial + #1142, #3967
static inicial + #1143, #3967
static inicial + #1144, #3967
static inicial + #1145, #3967
static inicial + #1146, #3967
static inicial + #1147, #3967
static inicial + #1148, #3967
static inicial + #1149, #3967
static inicial + #1150, #3967
static inicial + #1151, #3967
static inicial + #1152, #3967
static inicial + #1153, #3967
static inicial + #1154, #3967
static inicial + #1155, #3967
static inicial + #1156, #3967
static inicial + #1157, #3967
static inicial + #1158, #3967
static inicial + #1159, #3967

;Linha 29
static inicial + #1160, #3967
static inicial + #1161, #3967
static inicial + #1162, #3967
static inicial + #1163, #3967
static inicial + #1164, #3967
static inicial + #1165, #3967
static inicial + #1166, #3967
static inicial + #1167, #3967
static inicial + #1168, #3967
static inicial + #1169, #3967
static inicial + #1170, #3967
static inicial + #1171, #3967
static inicial + #1172, #3967
static inicial + #1173, #3967
static inicial + #1174, #3967
static inicial + #1175, #3967
static inicial + #1176, #3967
static inicial + #1177, #3967
static inicial + #1178, #3967
static inicial + #1179, #3967
static inicial + #1180, #3967
static inicial + #1181, #3967
static inicial + #1182, #3967
static inicial + #1183, #3967
static inicial + #1184, #3967
static inicial + #1185, #3967
static inicial + #1186, #3967
static inicial + #1187, #3967
static inicial + #1188, #3967
static inicial + #1189, #3967
static inicial + #1190, #3967
static inicial + #1191, #3967
static inicial + #1192, #3967
static inicial + #1193, #3967
static inicial + #1194, #3967
static inicial + #1195, #3967
static inicial + #1196, #3967
static inicial + #1197, #3967
static inicial + #1198, #3967
static inicial + #1199, #3967

fase1 : var #1200
;Linha 0
static fase1 + #0, #0
static fase1 + #1, #0
static fase1 + #2, #0
static fase1 + #3, #0
static fase1 + #4, #0
static fase1 + #5, #0
static fase1 + #6, #0
static fase1 + #7, #0
static fase1 + #8, #0
static fase1 + #9, #0
static fase1 + #10, #0
static fase1 + #11, #0
static fase1 + #12, #0
static fase1 + #13, #0
static fase1 + #14, #0
static fase1 + #15, #0
static fase1 + #16, #0
static fase1 + #17, #0
static fase1 + #18, #0
static fase1 + #19, #0
static fase1 + #20, #0
static fase1 + #21, #0
static fase1 + #22, #0
static fase1 + #23, #0
static fase1 + #24, #0
static fase1 + #25, #0
static fase1 + #26, #0
static fase1 + #27, #0
static fase1 + #28, #0
static fase1 + #29, #0
static fase1 + #30, #0
static fase1 + #31, #0
static fase1 + #32, #0
static fase1 + #33, #0
static fase1 + #34, #0
static fase1 + #35, #0
static fase1 + #36, #0
static fase1 + #37, #0
static fase1 + #38, #0
static fase1 + #39, #0

;Linha 1
static fase1 + #40, #0
static fase1 + #41, #1
static fase1 + #42, #3967
static fase1 + #43, #3967
static fase1 + #44, #3967
static fase1 + #45, #3967
static fase1 + #46, #3967
static fase1 + #47, #3967
static fase1 + #48, #3967
static fase1 + #49, #3967
static fase1 + #50, #3967
static fase1 + #51, #3967
static fase1 + #52, #3967
static fase1 + #53, #3967
static fase1 + #54, #3967
static fase1 + #55, #3967
static fase1 + #56, #3967
static fase1 + #57, #3967
static fase1 + #58, #3967
static fase1 + #59, #3967
static fase1 + #60, #3967
static fase1 + #61, #3967
static fase1 + #62, #3967
static fase1 + #63, #3967
static fase1 + #64, #3967
static fase1 + #65, #3967
static fase1 + #66, #3967
static fase1 + #67, #3967
static fase1 + #68, #3967
static fase1 + #69, #3967
static fase1 + #70, #3967
static fase1 + #71, #3967
static fase1 + #72, #3967
static fase1 + #73, #3967
static fase1 + #74, #3967
static fase1 + #75, #3967
static fase1 + #76, #3967
static fase1 + #77, #3967
static fase1 + #78, #3967
static fase1 + #79, #0

;Linha 2
static fase1 + #80, #0
static fase1 + #81, #3967
static fase1 + #82, #0
static fase1 + #83, #0
static fase1 + #84, #0
static fase1 + #85, #3967
static fase1 + #86, #0
static fase1 + #87, #0
static fase1 + #88, #0
static fase1 + #89, #0
static fase1 + #90, #0
static fase1 + #91, #0
static fase1 + #92, #0
static fase1 + #93, #3967
static fase1 + #94, #0
static fase1 + #95, #0
static fase1 + #96, #0
static fase1 + #97, #0
static fase1 + #98, #0
static fase1 + #99, #0
static fase1 + #100, #0
static fase1 + #101, #0
static fase1 + #102, #0
static fase1 + #103, #0
static fase1 + #104, #0
static fase1 + #105, #0
static fase1 + #106, #0
static fase1 + #107, #0
static fase1 + #108, #0
static fase1 + #109, #0
static fase1 + #110, #0
static fase1 + #111, #0
static fase1 + #112, #0
static fase1 + #113, #0
static fase1 + #114, #0
static fase1 + #115, #0
static fase1 + #116, #0
static fase1 + #117, #0
static fase1 + #118, #3967
static fase1 + #119, #0

;Linha 3
static fase1 + #120, #0
static fase1 + #121, #3967
static fase1 + #122, #0
static fase1 + #123, #3967
static fase1 + #124, #0
static fase1 + #125, #3967
static fase1 + #126, #3967
static fase1 + #127, #3967
static fase1 + #128, #3967
static fase1 + #129, #3967
static fase1 + #130, #3967
static fase1 + #131, #3967
static fase1 + #132, #3967
static fase1 + #133, #3967
static fase1 + #134, #3967
static fase1 + #135, #3967
static fase1 + #136, #3967
static fase1 + #137, #3967
static fase1 + #138, #3967
static fase1 + #139, #3967
static fase1 + #140, #3967
static fase1 + #141, #3967
static fase1 + #142, #3967
static fase1 + #143, #3967
static fase1 + #144, #3967
static fase1 + #145, #3967
static fase1 + #146, #3967
static fase1 + #147, #3967
static fase1 + #148, #3967
static fase1 + #149, #3967
static fase1 + #150, #3967
static fase1 + #151, #3967
static fase1 + #152, #3967
static fase1 + #153, #3967
static fase1 + #154, #3967
static fase1 + #155, #3967
static fase1 + #156, #3967
static fase1 + #157, #3967
static fase1 + #158, #3967
static fase1 + #159, #0

;Linha 4
static fase1 + #160, #0
static fase1 + #161, #3967
static fase1 + #162, #0
static fase1 + #163, #3967
static fase1 + #164, #0
static fase1 + #165, #3967
static fase1 + #166, #0
static fase1 + #167, #0
static fase1 + #168, #0
static fase1 + #169, #0
static fase1 + #170, #0
static fase1 + #171, #0
static fase1 + #172, #0
static fase1 + #173, #0
static fase1 + #174, #0
static fase1 + #175, #0
static fase1 + #176, #0
static fase1 + #177, #0
static fase1 + #178, #0
static fase1 + #179, #0
static fase1 + #180, #3967
static fase1 + #181, #3967
static fase1 + #182, #3967
static fase1 + #183, #3967
static fase1 + #184, #3967
static fase1 + #185, #3967
static fase1 + #186, #3967
static fase1 + #187, #3967
static fase1 + #188, #3967
static fase1 + #189, #3967
static fase1 + #190, #3967
static fase1 + #191, #3967
static fase1 + #192, #3967
static fase1 + #193, #3967
static fase1 + #194, #3967
static fase1 + #195, #3967
static fase1 + #196, #3967
static fase1 + #197, #3967
static fase1 + #198, #3967
static fase1 + #199, #0

;Linha 5
static fase1 + #200, #0
static fase1 + #201, #3967
static fase1 + #202, #0
static fase1 + #203, #3967
static fase1 + #204, #3967
static fase1 + #205, #3967
static fase1 + #206, #3967
static fase1 + #207, #3967
static fase1 + #208, #3967
static fase1 + #209, #3967
static fase1 + #210, #3967
static fase1 + #211, #3967
static fase1 + #212, #3967
static fase1 + #213, #3967
static fase1 + #214, #3967
static fase1 + #215, #3967
static fase1 + #216, #3967
static fase1 + #217, #3967
static fase1 + #218, #3967
static fase1 + #219, #3967
static fase1 + #220, #3967
static fase1 + #221, #3967
static fase1 + #222, #3967
static fase1 + #223, #3967
static fase1 + #224, #3967
static fase1 + #225, #3967
static fase1 + #226, #3967
static fase1 + #227, #3967
static fase1 + #228, #3967
static fase1 + #229, #3967
static fase1 + #230, #3967
static fase1 + #231, #3967
static fase1 + #232, #3967
static fase1 + #233, #3967
static fase1 + #234, #3967
static fase1 + #235, #3967
static fase1 + #236, #3967
static fase1 + #237, #3967
static fase1 + #238, #3967
static fase1 + #239, #0

;Linha 6
static fase1 + #240, #0
static fase1 + #241, #3967
static fase1 + #242, #0
static fase1 + #243, #0
static fase1 + #244, #0
static fase1 + #245, #0
static fase1 + #246, #0
static fase1 + #247, #0
static fase1 + #248, #0
static fase1 + #249, #0
static fase1 + #250, #0
static fase1 + #251, #3967
static fase1 + #252, #0
static fase1 + #253, #0
static fase1 + #254, #0
static fase1 + #255, #0
static fase1 + #256, #0
static fase1 + #257, #0
static fase1 + #258, #0
static fase1 + #259, #0
static fase1 + #260, #0
static fase1 + #261, #0
static fase1 + #262, #3967
static fase1 + #263, #3967
static fase1 + #264, #3967
static fase1 + #265, #3967
static fase1 + #266, #3967
static fase1 + #267, #3967
static fase1 + #268, #3967
static fase1 + #269, #3967
static fase1 + #270, #3967
static fase1 + #271, #3967
static fase1 + #272, #3967
static fase1 + #273, #3967
static fase1 + #274, #3967
static fase1 + #275, #3967
static fase1 + #276, #3967
static fase1 + #277, #3967
static fase1 + #278, #3967
static fase1 + #279, #0

;Linha 7
static fase1 + #280, #0
static fase1 + #281, #3967
static fase1 + #282, #3967
static fase1 + #283, #3967
static fase1 + #284, #3967
static fase1 + #285, #3967
static fase1 + #286, #3967
static fase1 + #287, #3967
static fase1 + #288, #3967
static fase1 + #289, #3967
static fase1 + #290, #3967
static fase1 + #291, #3967
static fase1 + #292, #3967
static fase1 + #293, #3967
static fase1 + #294, #3967
static fase1 + #295, #3967
static fase1 + #296, #3967
static fase1 + #297, #3967
static fase1 + #298, #3967
static fase1 + #299, #3967
static fase1 + #300, #3967
static fase1 + #301, #3967
static fase1 + #302, #3967
static fase1 + #303, #3967
static fase1 + #304, #3967
static fase1 + #305, #3967
static fase1 + #306, #3967
static fase1 + #307, #3967
static fase1 + #308, #3967
static fase1 + #309, #3967
static fase1 + #310, #3967
static fase1 + #311, #3967
static fase1 + #312, #3967
static fase1 + #313, #3967
static fase1 + #314, #3967
static fase1 + #315, #3967
static fase1 + #316, #3967
static fase1 + #317, #3967
static fase1 + #318, #3967
static fase1 + #319, #0

;Linha 8
static fase1 + #320, #0
static fase1 + #321, #3967
static fase1 + #322, #0
static fase1 + #323, #0
static fase1 + #324, #0
static fase1 + #325, #0
static fase1 + #326, #0
static fase1 + #327, #0
static fase1 + #328, #0
static fase1 + #329, #0
static fase1 + #330, #0
static fase1 + #331, #0
static fase1 + #332, #0
static fase1 + #333, #0
static fase1 + #334, #0
static fase1 + #335, #3967
static fase1 + #336, #0
static fase1 + #337, #3967
static fase1 + #338, #3967
static fase1 + #339, #3967
static fase1 + #340, #3967
static fase1 + #341, #3967
static fase1 + #342, #3967
static fase1 + #343, #3967
static fase1 + #344, #3967
static fase1 + #345, #3967
static fase1 + #346, #3967
static fase1 + #347, #3967
static fase1 + #348, #3967
static fase1 + #349, #3967
static fase1 + #350, #3967
static fase1 + #351, #3967
static fase1 + #352, #3967
static fase1 + #353, #3967
static fase1 + #354, #3967
static fase1 + #355, #3967
static fase1 + #356, #3967
static fase1 + #357, #3967
static fase1 + #358, #3967
static fase1 + #359, #0

;Linha 9
static fase1 + #360, #0
static fase1 + #361, #3967
static fase1 + #362, #0
static fase1 + #363, #3967
static fase1 + #364, #3967
static fase1 + #365, #3967
static fase1 + #366, #3967
static fase1 + #367, #3967
static fase1 + #368, #3967
static fase1 + #369, #3967
static fase1 + #370, #3967
static fase1 + #371, #3967
static fase1 + #372, #3967
static fase1 + #373, #3967
static fase1 + #374, #3967
static fase1 + #375, #3967
static fase1 + #376, #3967
static fase1 + #377, #3967
static fase1 + #378, #3967
static fase1 + #379, #3967
static fase1 + #380, #3967
static fase1 + #381, #3967
static fase1 + #382, #3967
static fase1 + #383, #3967
static fase1 + #384, #3967
static fase1 + #385, #3967
static fase1 + #386, #3967
static fase1 + #387, #3967
static fase1 + #388, #3967
static fase1 + #389, #3967
static fase1 + #390, #3967
static fase1 + #391, #3967
static fase1 + #392, #3967
static fase1 + #393, #3967
static fase1 + #394, #3967
static fase1 + #395, #3967
static fase1 + #396, #3967
static fase1 + #397, #3967
static fase1 + #398, #3967
static fase1 + #399, #0

;Linha 10
static fase1 + #400, #0
static fase1 + #401, #3967
static fase1 + #402, #0
static fase1 + #403, #0
static fase1 + #404, #0
static fase1 + #405, #0
static fase1 + #406, #0
static fase1 + #407, #0
static fase1 + #408, #0
static fase1 + #409, #0
static fase1 + #410, #3967
static fase1 + #411, #0
static fase1 + #412, #0
static fase1 + #413, #0
static fase1 + #414, #0
static fase1 + #415, #0
static fase1 + #416, #0
static fase1 + #417, #0
static fase1 + #418, #3967
static fase1 + #419, #0
static fase1 + #420, #0
static fase1 + #421, #0
static fase1 + #422, #0
static fase1 + #423, #0
static fase1 + #424, #0
static fase1 + #425, #3967
static fase1 + #426, #3967
static fase1 + #427, #3967
static fase1 + #428, #3967
static fase1 + #429, #3967
static fase1 + #430, #3967
static fase1 + #431, #3967
static fase1 + #432, #3967
static fase1 + #433, #3967
static fase1 + #434, #3967
static fase1 + #435, #3967
static fase1 + #436, #3967
static fase1 + #437, #3967
static fase1 + #438, #3967
static fase1 + #439, #0

;Linha 11
static fase1 + #440, #0
static fase1 + #441, #3967
static fase1 + #442, #0
static fase1 + #443, #3967
static fase1 + #444, #3967
static fase1 + #445, #3967
static fase1 + #446, #3967
static fase1 + #447, #3967
static fase1 + #448, #3967
static fase1 + #449, #3967
static fase1 + #450, #3967
static fase1 + #451, #3967
static fase1 + #452, #3967
static fase1 + #453, #3967
static fase1 + #454, #3967
static fase1 + #455, #3967
static fase1 + #456, #3967
static fase1 + #457, #3967
static fase1 + #458, #3967
static fase1 + #459, #3967
static fase1 + #460, #3967
static fase1 + #461, #3967
static fase1 + #462, #3967
static fase1 + #463, #3967
static fase1 + #464, #3967
static fase1 + #465, #3967
static fase1 + #466, #3967
static fase1 + #467, #3967
static fase1 + #468, #3967
static fase1 + #469, #3967
static fase1 + #470, #3967
static fase1 + #471, #3967
static fase1 + #472, #3967
static fase1 + #473, #3967
static fase1 + #474, #3967
static fase1 + #475, #3967
static fase1 + #476, #3967
static fase1 + #477, #3967
static fase1 + #478, #3967
static fase1 + #479, #0

;Linha 12
static fase1 + #480, #0
static fase1 + #481, #3967
static fase1 + #482, #0
static fase1 + #483, #3967
static fase1 + #484, #0
static fase1 + #485, #0
static fase1 + #486, #0
static fase1 + #487, #0
static fase1 + #488, #0
static fase1 + #489, #0
static fase1 + #490, #0
static fase1 + #491, #3967
static fase1 + #492, #3967
static fase1 + #493, #3967
static fase1 + #494, #3967
static fase1 + #495, #3967
static fase1 + #496, #3967
static fase1 + #497, #3967
static fase1 + #498, #3967
static fase1 + #499, #3967
static fase1 + #500, #3967
static fase1 + #501, #3967
static fase1 + #502, #3967
static fase1 + #503, #3967
static fase1 + #504, #3967
static fase1 + #505, #3967
static fase1 + #506, #3967
static fase1 + #507, #3967
static fase1 + #508, #3967
static fase1 + #509, #3967
static fase1 + #510, #3967
static fase1 + #511, #3967
static fase1 + #512, #3967
static fase1 + #513, #3967
static fase1 + #514, #3967
static fase1 + #515, #3967
static fase1 + #516, #3967
static fase1 + #517, #3967
static fase1 + #518, #3967
static fase1 + #519, #0

;Linha 13
static fase1 + #520, #0
static fase1 + #521, #3967
static fase1 + #522, #3967
static fase1 + #523, #3967
static fase1 + #524, #0
static fase1 + #525, #3967
static fase1 + #526, #3967
static fase1 + #527, #3967
static fase1 + #528, #3967
static fase1 + #529, #514
static fase1 + #530, #0
static fase1 + #531, #3967
static fase1 + #532, #3967
static fase1 + #533, #3967
static fase1 + #534, #3967
static fase1 + #535, #3967
static fase1 + #536, #3967
static fase1 + #537, #3967
static fase1 + #538, #3967
static fase1 + #539, #3967
static fase1 + #540, #3967
static fase1 + #541, #3967
static fase1 + #542, #3967
static fase1 + #543, #3967
static fase1 + #544, #3967
static fase1 + #545, #3967
static fase1 + #546, #3967
static fase1 + #547, #3967
static fase1 + #548, #3967
static fase1 + #549, #3967
static fase1 + #550, #3967
static fase1 + #551, #3967
static fase1 + #552, #3967
static fase1 + #553, #3967
static fase1 + #554, #3967
static fase1 + #555, #3967
static fase1 + #556, #3967
static fase1 + #557, #3967
static fase1 + #558, #3967
static fase1 + #559, #0

;Linha 14
static fase1 + #560, #0
static fase1 + #561, #3967
static fase1 + #562, #0
static fase1 + #563, #3967
static fase1 + #564, #0
static fase1 + #565, #3967
static fase1 + #566, #0
static fase1 + #567, #0
static fase1 + #568, #0
static fase1 + #569, #0
static fase1 + #570, #0
static fase1 + #571, #3967
static fase1 + #572, #3967
static fase1 + #573, #3967
static fase1 + #574, #3967
static fase1 + #575, #3967
static fase1 + #576, #3967
static fase1 + #577, #3967
static fase1 + #578, #3967
static fase1 + #579, #3967
static fase1 + #580, #3967
static fase1 + #581, #3967
static fase1 + #582, #3967
static fase1 + #583, #3967
static fase1 + #584, #3967
static fase1 + #585, #3967
static fase1 + #586, #3967
;Linha 19
static fase1 + #760, #0
static fase1 + #761, #3967
static fase1 + #762, #0
static fase1 + #763, #3967
static fase1 + #764, #0
static fase1 + #765, #3967
static fase1 + #766, #3967
static fase1 + #767, #3967
static fase1 + #768, #3967
static fase1 + #769, #3967
static fase1 + #770, #3967
static fase1 + #771, #3967
static fase1 + #772, #3967
static fase1 + #773, #3967
static fase1 + #774, #3967
static fase1 + #775, #3967
static fase1 + #776, #3967
static fase1 + #777, #3967
static fase1 + #778, #3967
static fase1 + #779, #3967
static fase1 + #780, #3967
static fase1 + #781, #3967
static fase1 + #782, #3967
static fase1 + #783, #3967
static fase1 + #784, #3967
static fase1 + #785, #3967
static fase1 + #786, #3967
static fase1 + #787, #3967
static fase1 + #788, #3967
static fase1 + #789, #3967
static fase1 + #790, #3967
static fase1 + #791, #3967
static fase1 + #792, #3967
static fase1 + #793, #3967
static fase1 + #794, #3967
static fase1 + #795, #3967
static fase1 + #796, #3967
static fase1 + #797, #3967
static fase1 + #798, #3967
static fase1 + #799, #0

;Linha 20
static fase1 + #800, #0
static fase1 + #801, #3967
static fase1 + #802, #0
static fase1 + #803, #3967
static fase1 + #804, #0
static fase1 + #805, #3967
static fase1 + #806, #3967
static fase1 + #807, #3967
static fase1 + #808, #3967
static fase1 + #809, #3967
static fase1 + #810, #3967
static fase1 + #811, #3967
static fase1 + #812, #3967
static fase1 + #813, #3967
static fase1 + #814, #3967
static fase1 + #815, #3967
static fase1 + #816, #3967
static fase1 + #817, #3967
static fase1 + #818, #3967
static fase1 + #819, #3967
static fase1 + #820, #3967
static fase1 + #821, #3967
static fase1 + #822, #3967
static fase1 + #823, #3967
static fase1 + #824, #3967
static fase1 + #825, #3967
static fase1 + #826, #3967
static fase1 + #827, #3967
static fase1 + #828, #3967
static fase1 + #829, #3967
static fase1 + #830, #3967
static fase1 + #831, #3967
static fase1 + #832, #3967
static fase1 + #833, #3967
static fase1 + #834, #3967
static fase1 + #835, #3967
static fase1 + #836, #3967
static fase1 + #837, #3967
static fase1 + #838, #3967
static fase1 + #839, #0

;Linha 21
static fase1 + #840, #0
static fase1 + #841, #3967
static fase1 + #842, #0
static fase1 + #843, #3967
static fase1 + #844, #0
static fase1 + #845, #3967
static fase1 + #846, #3967
static fase1 + #847, #3967
static fase1 + #848, #3967
static fase1 + #849, #3967
static fase1 + #850, #3967
static fase1 + #851, #3967
static fase1 + #852, #3967
static fase1 + #853, #3967
static fase1 + #854, #3967
static fase1 + #855, #3967
static fase1 + #856, #3967
static fase1 + #857, #3967
static fase1 + #858, #3967
static fase1 + #859, #3967
static fase1 + #860, #3967
static fase1 + #861, #3967
static fase1 + #862, #3967
static fase1 + #863, #3967
static fase1 + #864, #3967
static fase1 + #865, #3967
static fase1 + #866, #3967
static fase1 + #867, #3967
static fase1 + #868, #3967
static fase1 + #869, #3967
static fase1 + #870, #3967
static fase1 + #871, #3967
static fase1 + #872, #3967
static fase1 + #873, #3967
static fase1 + #874, #3967
static fase1 + #875, #3967
static fase1 + #876, #3967
static fase1 + #877, #3967
static fase1 + #878, #3967
static fase1 + #879, #0

;Linha 22
static fase1 + #880, #0
static fase1 + #881, #3967
static fase1 + #882, #0
static fase1 + #883, #3967
static fase1 + #884, #0
static fase1 + #885, #3967
static fase1 + #886, #3967
static fase1 + #887, #3967
static fase1 + #888, #3967
static fase1 + #889, #3967
static fase1 + #890, #3967
static fase1 + #891, #3967
static fase1 + #892, #3967
static fase1 + #893, #3967
static fase1 + #894, #3967
static fase1 + #895, #3967
static fase1 + #896, #3967
static fase1 + #897, #3967
static fase1 + #898, #3967
static fase1 + #899, #3967
static fase1 + #900, #3967
static fase1 + #901, #3967
static fase1 + #902, #3967
static fase1 + #903, #3967
static fase1 + #904, #3967
static fase1 + #905, #3967
static fase1 + #906, #3967
static fase1 + #907, #3967
static fase1 + #908, #3967
static fase1 + #909, #3967
static fase1 + #910, #3967
static fase1 + #911, #3967
static fase1 + #912, #3967
static fase1 + #913, #3967
static fase1 + #914, #3967
static fase1 + #915, #3967
static fase1 + #916, #3967
static fase1 + #917, #3967
static fase1 + #918, #3967
static fase1 + #919, #0

;Linha 23
static fase1 + #920, #0
static fase1 + #921, #3967
static fase1 + #922, #0
static fase1 + #923, #3967
static fase1 + #924, #0
static fase1 + #925, #3967
static fase1 + #926, #3967
static fase1 + #927, #3967
static fase1 + #928, #3967
static fase1 + #929, #3967
static fase1 + #930, #3967
static fase1 + #931, #3967
static fase1 + #932, #3967
static fase1 + #933, #3967
static fase1 + #934, #3967
static fase1 + #935, #3967
static fase1 + #936, #3967
static fase1 + #937, #3967
static fase1 + #938, #3967
static fase1 + #939, #3967
static fase1 + #940, #3967
static fase1 + #941, #3967
static fase1 + #942, #3967
static fase1 + #943, #3967
static fase1 + #944, #3967
static fase1 + #945, #3967
static fase1 + #946, #3967
static fase1 + #947, #3967
static fase1 + #948, #3967
static fase1 + #949, #3967
static fase1 + #950, #3967
static fase1 + #951, #3967
static fase1 + #952, #3967
static fase1 + #953, #3967
static fase1 + #954, #3967
static fase1 + #955, #3967
static fase1 + #956, #3967
static fase1 + #957, #3967
static fase1 + #958, #3967
static fase1 + #959, #0

;Linha 24
static fase1 + #960, #0
static fase1 + #961, #3967
static fase1 + #962, #0
static fase1 + #963, #3967
static fase1 + #964, #0
static fase1 + #965, #3967
static fase1 + #966, #3967
static fase1 + #967, #3967
static fase1 + #968, #3967
static fase1 + #969, #3967
static fase1 + #970, #3967
static fase1 + #971, #3967
static fase1 + #972, #3967
static fase1 + #973, #3967
static fase1 + #974, #3967
static fase1 + #975, #3967
static fase1 + #976, #3967
static fase1 + #977, #3967
static fase1 + #978, #3967
static fase1 + #979, #3967
static fase1 + #980, #3967
static fase1 + #981, #3967
static fase1 + #982, #3967
static fase1 + #983, #3967
static fase1 + #984, #3967
static fase1 + #985, #3967
static fase1 + #986, #3967
static fase1 + #987, #3967
static fase1 + #988, #3967
static fase1 + #989, #3967
static fase1 + #990, #3967
static fase1 + #991, #3967
static fase1 + #992, #3967
static fase1 + #993, #3967
static fase1 + #994, #3967
static fase1 + #995, #3967
static fase1 + #996, #3967
static fase1 + #997, #3967
static fase1 + #998, #3967
static fase1 + #999, #0

;Linha 25
static fase1 + #1000, #0
static fase1 + #1001, #3967
static fase1 + #1002, #0
static fase1 + #1003, #0
static fase1 + #1004, #0
static fase1 + #1005, #0
static fase1 + #1006, #0
static fase1 + #1007, #0
static fase1 + #1008, #0
static fase1 + #1009, #0
static fase1 + #1010, #0
static fase1 + #1011, #0
static fase1 + #1012, #0
static fase1 + #1013, #0
static fase1 + #1014, #0
static fase1 + #1015, #3967
static fase1 + #1016, #3967
static fase1 + #1017, #3967
static fase1 + #1018, #3967
static fase1 + #1019, #3967
static fase1 + #1020, #3967
static fase1 + #1021, #3967
static fase1 + #1022, #3967
static fase1 + #1023, #3967
static fase1 + #1024, #3967
static fase1 + #1025, #3967
static fase1 + #1026, #3967
static fase1 + #1027, #3967
static fase1 + #1028, #3967
static fase1 + #1029, #3967
static fase1 + #1030, #3967
static fase1 + #1031, #3967
static fase1 + #1032, #3967
static fase1 + #1033, #3967
static fase1 + #1034, #3967
static fase1 + #1035, #3967
static fase1 + #1036, #3967
static fase1 + #1037, #3967
static fase1 + #1038, #3967
static fase1 + #1039, #0

;Linha 26
static fase1 + #1040, #0
static fase1 + #1041, #3967
static fase1 + #1042, #3967
static fase1 + #1043, #3967
static fase1 + #1044, #3967
static fase1 + #1045, #3967
static fase1 + #1046, #3967
static fase1 + #1047, #3967
static fase1 + #1048, #3967
static fase1 + #1049, #3967
static fase1 + #1050, #3967
static fase1 + #1051, #3967
static fase1 + #1052, #3967
static fase1 + #1053, #3967
static fase1 + #1054, #3967
static fase1 + #1055, #3967
static fase1 + #1056, #3967
static fase1 + #1057, #3967
static fase1 + #1058, #3967
static fase1 + #1059, #3967
static fase1 + #1060, #3967
static fase1 + #1061, #3967
static fase1 + #1062, #3967
static fase1 + #1063, #3967
static fase1 + #1064, #3967
static fase1 + #1065, #3967
static fase1 + #1066, #3967
static fase1 + #1067, #3967
static fase1 + #1068, #3967
static fase1 + #1069, #3967
static fase1 + #1070, #3967
static fase1 + #1071, #3967
static fase1 + #1072, #3967
static fase1 + #1073, #3967
static fase1 + #1074, #3967
static fase1 + #1075, #3967
static fase1 + #1076, #3967
static fase1 + #1077, #3967
static fase1 + #1078, #3967
static fase1 + #1079, #0

;Linha 27
static fase1 + #1080, #0
static fase1 + #1081, #3967
static fase1 + #1082, #0
static fase1 + #1083, #0
static fase1 + #1084, #0
static fase1 + #1085, #0
static fase1 + #1086, #0
static fase1 + #1087, #3967
static fase1 + #1088, #3967
static fase1 + #1089, #3967
static fase1 + #1090, #3967
static fase1 + #1091, #3967
static fase1 + #1092, #3967
static fase1 + #1093, #3967
static fase1 + #1094, #3967
static fase1 + #1095, #3967
static fase1 + #1096, #3967
static fase1 + #1097, #3967
static fase1 + #1098, #3967
static fase1 + #1099, #3967
static fase1 + #1100, #3967
static fase1 + #1101, #3967
static fase1 + #1102, #3967
static fase1 + #1103, #3967
static fase1 + #1104, #3967
static fase1 + #1105, #3967
static fase1 + #1106, #3967
static fase1 + #1107, #3967
static fase1 + #1108, #3967
static fase1 + #1109, #3967
static fase1 + #1110, #3967
static fase1 + #1111, #3967
static fase1 + #1112, #3967
static fase1 + #1113, #3967
static fase1 + #1114, #3967
static fase1 + #1115, #3967
static fase1 + #1116, #3967
static fase1 + #1117, #3967
static fase1 + #1118, #3967
static fase1 + #1119, #0

;Linha 28
static fase1 + #1120, #0
static fase1 + #1121, #3967
static fase1 + #1122, #3967
static fase1 + #1123, #3967
static fase1 + #1124, #3967
static fase1 + #1125, #3967
static fase1 + #1126, #3967
static fase1 + #1127, #3967
static fase1 + #1128, #3967
static fase1 + #1129, #3967
static fase1 + #1130, #3967
static fase1 + #1131, #3967
static fase1 + #1132, #3967
static fase1 + #1133, #3967
static fase1 + #1134, #3967
static fase1 + #1135, #3967
static fase1 + #1136, #3967
static fase1 + #1137, #3967
static fase1 + #1138, #3967
static fase1 + #1139, #3967
static fase1 + #1140, #3967
static fase1 + #1141, #3967
static fase1 + #1142, #3967
static fase1 + #1143, #3967
static fase1 + #1144, #3967
static fase1 + #1145, #3967
static fase1 + #1146, #3967
static fase1 + #1147, #3967
static fase1 + #1148, #3967
static fase1 + #1149, #3967
static fase1 + #1150, #3967
static fase1 + #1151, #3967
static fase1 + #1152, #3967
static fase1 + #1153, #3967
static fase1 + #1154, #3967
static fase1 + #1155, #3967
static fase1 + #1156, #3967
static fase1 + #1157, #3967
static fase1 + #1158, #3967
static fase1 + #1159, #0

;Linha 29
static fase1 + #1160, #0
static fase1 + #1161, #0
static fase1 + #1162, #0
static fase1 + #1163, #0
static fase1 + #1164, #0
static fase1 + #1165, #0
static fase1 + #1166, #0
static fase1 + #1167, #0
static fase1 + #1168, #0
static fase1 + #1169, #0
static fase1 + #1170, #0
static fase1 + #1171, #0
static fase1 + #1172, #0
static fase1 + #1173, #0
static fase1 + #1174, #0
static fase1 + #1175, #0
static fase1 + #1176, #0
static fase1 + #1177, #0
static fase1 + #1178, #0
static fase1 + #1179, #0
static fase1 + #1180, #0
static fase1 + #1181, #0
static fase1 + #1182, #0
static fase1 + #1183, #0
static fase1 + #1184, #0
static fase1 + #1185, #0
static fase1 + #1186, #0
static fase1 + #1187, #0
static fase1 + #1188, #0
static fase1 + #1189, #0
static fase1 + #1190, #0
static fase1 + #1191, #0
static fase1 + #1192, #0
static fase1 + #1193, #0
static fase1 + #1194, #0
static fase1 + #1195, #0
static fase1 + #1196, #0
static fase1 + #1197, #0
static fase1 + #1198, #0
static fase1 + #1199, #0
static fase1 + #587, #3967
static fase1 + #588, #3967
static fase1 + #589, #3967
static fase1 + #590, #3967
static fase1 + #591, #3967
static fase1 + #592, #3967
static fase1 + #593, #3967
static fase1 + #594, #3967
static fase1 + #595, #3967
static fase1 + #596, #3967
static fase1 + #597, #3967
static fase1 + #598, #3967
static fase1 + #599, #0

;Linha 15
static fase1 + #600, #0
static fase1 + #601, #3967
static fase1 + #602, #0
static fase1 + #603, #3967
static fase1 + #604, #0
static fase1 + #605, #3967
static fase1 + #606, #0
static fase1 + #607, #3967
static fase1 + #608, #3967
static fase1 + #609, #3967
static fase1 + #610, #3967
static fase1 + #611, #3967
static fase1 + #612, #3967
static fase1 + #613, #3967
static fase1 + #614, #3967
static fase1 + #615, #3967
static fase1 + #616, #3967
static fase1 + #617, #3967
static fase1 + #618, #3967
static fase1 + #619, #3967
static fase1 + #620, #3967
static fase1 + #621, #3967
static fase1 + #622, #3967
static fase1 + #623, #3967
static fase1 + #624, #3967
static fase1 + #625, #3967
static fase1 + #626, #3967
static fase1 + #627, #3967
static fase1 + #628, #3967
static fase1 + #629, #3967
static fase1 + #630, #3967
static fase1 + #631, #3967
static fase1 + #632, #3967
static fase1 + #633, #3967
static fase1 + #634, #3967
static fase1 + #635, #3967
static fase1 + #636, #3967
static fase1 + #637, #3967
static fase1 + #638, #3967
static fase1 + #639, #0

;Linha 16
static fase1 + #640, #0
static fase1 + #641, #3967
static fase1 + #642, #0
static fase1 + #643, #3967
static fase1 + #644, #0
static fase1 + #645, #3967
static fase1 + #646, #3967
static fase1 + #647, #3967
static fase1 + #648, #3967
static fase1 + #649, #3967
static fase1 + #650, #3967
static fase1 + #651, #3967
static fase1 + #652, #3967
static fase1 + #653, #3967
static fase1 + #654, #3967
static fase1 + #655, #3967
static fase1 + #656, #3967
static fase1 + #657, #3967
static fase1 + #658, #3967
static fase1 + #659, #3967
static fase1 + #660, #3967
static fase1 + #661, #3967
static fase1 + #662, #3967
static fase1 + #663, #3967
static fase1 + #664, #3967
static fase1 + #665, #3967
static fase1 + #666, #3967
static fase1 + #667, #3967
static fase1 + #668, #3967
static fase1 + #669, #3967
static fase1 + #670, #3967
static fase1 + #671, #3967
static fase1 + #672, #3967
static fase1 + #673, #3967
static fase1 + #674, #3967
static fase1 + #675, #3967
static fase1 + #676, #3967
static fase1 + #677, #3967
static fase1 + #678, #3967
static fase1 + #679, #0

;Linha 17
static fase1 + #680, #0
static fase1 + #681, #3967
static fase1 + #682, #0
static fase1 + #683, #3967
static fase1 + #684, #0
static fase1 + #685, #3967
static fase1 + #686, #3967
static fase1 + #687, #3967
static fase1 + #688, #3967
static fase1 + #689, #3967
static fase1 + #690, #3967
static fase1 + #691, #3967
static fase1 + #692, #3967
static fase1 + #693, #3967
static fase1 + #694, #3967
static fase1 + #695, #3967
static fase1 + #696, #3967
static fase1 + #697, #3967
static fase1 + #698, #3967
static fase1 + #699, #3967
static fase1 + #700, #3967
static fase1 + #701, #3967
static fase1 + #702, #3967
static fase1 + #703, #3967
static fase1 + #704, #3967
static fase1 + #705, #3967
static fase1 + #706, #3967
static fase1 + #707, #3967
static fase1 + #708, #3967
static fase1 + #709, #3967
static fase1 + #710, #3967
static fase1 + #711, #3967
static fase1 + #712, #3967
static fase1 + #713, #3967
static fase1 + #714, #3967
static fase1 + #715, #3967
static fase1 + #716, #3967
static fase1 + #717, #3967
static fase1 + #718, #3967
static fase1 + #719, #0

;Linha 18
static fase1 + #720, #0
static fase1 + #721, #3967
static fase1 + #722, #3967
static fase1 + #723, #3967
static fase1 + #724, #0
static fase1 + #725, #3967
static fase1 + #726, #3967
static fase1 + #727, #3967
static fase1 + #728, #3967
static fase1 + #729, #3967
static fase1 + #730, #3967
static fase1 + #731, #3967
static fase1 + #732, #3967
static fase1 + #733, #3967
static fase1 + #734, #3967
static fase1 + #735, #3967
static fase1 + #736, #3967
static fase1 + #737, #3967
static fase1 + #738, #3967
static fase1 + #739, #3967
static fase1 + #740, #3967
static fase1 + #741, #3967
static fase1 + #742, #3967
static fase1 + #743, #3967
static fase1 + #744, #3967
static fase1 + #745, #3967
static fase1 + #746, #3967
static fase1 + #747, #3967
static fase1 + #748, #3967
static fase1 + #749, #3967
static fase1 + #750, #3967
static fase1 + #751, #3967
static fase1 + #752, #3967
static fase1 + #753, #3967
static fase1 + #754, #3967
static fase1 + #755, #3967
static fase1 + #756, #3967
static fase1 + #757, #3967
static fase1 + #758, #3967
static fase1 + #759, #0
