characterPosition: var #1
characterLastPosition: var #1
seed: var #1
seed1: var #1
fase: var #1
period: var #1

jmp main

;---- Inicio do Programa Principal -----

main:
	call PrintInitialScreen
	call WaitUntilSpaceIsPressed
	call PrintBlackScreen
	
	call seedMap
    
    initialSetup: 
		loadn r0, #41 ;--posicao inicial
		store characterPosition, r0
		
		loadn r0, #30
		store period, r0
		
		loadn r0, #0
		store seed1, r0
		
		loadn r0, #0
		loadn r1, #0
			
		Loop:
			load r2, period
			mod r2, r0, r2
			cmp r2, r1
			ceq MoveCharAndIncrementsCounter 
			
			call Delay
			inc r0
			jmp Loop
			
	MoveCharAndIncrementsCounter:
		push r5

		load r5, seed1
		inc r5
		store seed1, r5
		call MoveChar

		pop r5
		rts	
		
	End:
		call printFinalScreen
		
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
	rts	; espera até que o espaço seja pressionado, enquanto isso, incremmenta um contador "seed"

seedMap:
	push r0
	push r1
	push r2
	
	loadn r0, #7
	load r2,seed
	
	mod r0, r2, r0
	
	loadn r1, #0
	cmp r1,r0
	jeq seedFase1
	
	loadn r1, #1
	cmp r1,r0
	jeq seedFase2
	
	loadn r1, #2
	cmp r1,r0
	jeq seedFase3
	
	loadn r1, #3
	cmp r1,r0
	jeq seedFase4
	
	loadn r1, #4
	cmp r1,r0
	jeq seedFase5
	
	loadn r1, #5
	cmp r1,r0
	jeq seedFase6
	
	loadn r1, #6
	cmp r1,r0
	jeq seedFase7	

	
	seedFase1: 
	    loadn r0,#fase1
	    store fase, r0
	    jmp seedMapEnd
	seedFase2: 
	    loadn r0,#fase2
	    store fase, r0
	    jmp seedMapEnd
	seedFase3: 
	    loadn r0,#fase3
	    store fase, r0
	    jmp seedMapEnd
	seedFase4: 
	    loadn r0,#fase4
	    store fase, r0
	    jmp seedMapEnd    
	seedFase5: 
	    loadn r0,#fase5
	    store fase, r0
	    jmp seedMapEnd 
	seedFase6: 
	    loadn r0,#fase6
	    store fase, r0
	    jmp seedMapEnd   
	seedFase7: 
	    loadn r0,#fase7
	    store fase, r0
	    jmp seedMapEnd
	seedMapEnd:

    pop r2
	pop r1
	pop r0
	rts ; com base no contador "seed", seleciona um dos mapas
	
MoveChar: ; lida com toda interação de mover o char
	push r0
	push r1
	
	call CalcCharPosition
	
	load r0, characterPosition
	load r1, characterLastPosition

	cmp r0, r1
	jeq MoverChar_End
	
	call finishIfCan
	call randomEventsIfCan 
	call refreshBrightedArea
	call eraseChar
	call DrawChar
	
	MoverChar_End:
	pop r1
	pop r0
	rts; 
	
finishIfCan: ; finaliza o jogo se chegar na posição final
	push r0 
	push r1
	push r2
	push r3
	push r4
	
	loadn r4, #514 ;final charcode
	
	load r1, fase
	add r2, r1, r0
	loadi r3, r2
	
	cmp r3, r4
	jeq End
	
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
randomEventsIfCan: ; chama o handler de eventos se chegar na posição de eventos
	push r0 
	push r1
	push r2
	push r3
	push r4
	
	loadn r4, #3 ;random events charcode
	
	load r1, fase
	add r2, r1, r0
	loadi r3, r2
	
 	cmp r3, r4
	jne randomEventsIfCanEnd
	
	loadn r5, #3967 ;black block charcode
	storei r2, r5
	call handleRandomEvent
	
	randomEventsIfCanEnd:
	
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

handleRandomEvent: ; lança um evento aleatório no mapa, com base no contador "seed1"
	push r0
	push r1
	push r2
	push r3
	
	loadn r1, #4
	load r2, seed1 
	
	mod r1, r2, r1
	
	loadn r3, #0
	cmp r1, r3
	jeq handleEvent1
	
	loadn r3, #1
	cmp r1, r3
	jeq handleEvent2
	
	loadn r3, #2
	cmp r1, r3
	jeq handleEvent3
	
	loadn r3, #3
	cmp r1, r3
	jeq handleEvent4

	
	handleEvent1: 
		jmp initialSetup
	handleEvent2: 
		loadn r1, #200
		store period, r1
		jmp handleEventEnd
	handleEvent3:
		call printfaseScreen
		call MediumDelay
		call PrintBlackScreen
		jmp Loop
	handleEvent4:
		call PrintBlackScreen
		call GreaterDelay
		jmp Loop				
	 	
	handleEventEnd:
	
	pop r3
	pop r2
	pop r1
	pop r0
	rts

CalcCharPosition: ; "ouve" as teclas e calcula a nova posição
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
	rts; 

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

ensureMoveWontCollide: ; evita colisões no mapa 
	push r1
	push r2
	push r3
	push r4
	
	loadn r4, #0 ;block charcode
	load r1, fase
	
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

eraseChar: ; apaga o boneco
	push r0
	push r1
	push r2
	push r3
	
	load r0, characterLastPosition
	load r1, fase
	add r2, r1, r0
	loadi r3, r2
	
	outchar r3, r0 
	
	pop r3
	pop r2
	pop r1
	pop r0
	rts

DrawChar: ; desenha o boneco
	push r0
	push r1
	
	loadn r1, #1 ; Charcode que representa o personagem
	load r0, characterPosition
	outchar r1, r0
	store characterLastPosition, r0
	
	pop r1
	pop r2
	rts

refreshBrightedArea: ; faz o refresh da área visível do boneco
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	load r3, fase
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

MediumDelay:
	push r0
	push r1
	
	loadn r1, #500  
   GreaterDelay_volta2:				
	loadn R0, #10000	
   GreaterDelay_volta: 
	dec R0					
	jnz GreaterDelay_volta	
	dec R1
	jnz GreaterDelay_volta2
	
	pop R1
	pop R0
	rts 				

GreaterDelay:
	push r0
	push r1
	
	loadn r1, #500  
   GreaterDelay_volta2:				
	loadn R0, #30000	
   GreaterDelay_volta: 
	dec R0					
	jnz GreaterDelay_volta	
	dec R1
	jnz GreaterDelay_volta2
	
	pop R1
	pop R0
	rts 				
	
PrintInitialScreen:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #Pato
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

printfaseScreen:
	push R0
 	push R1
 	push R2
  	push R3

  	load R0, fase
  	loadn R1, #0
  	loadn R2, #1200

  	printfaseScreenLoop:

		add R3, R0, R1
		loadi R3, R3
		outchar R3, R1
		inc R1
		cmp R1, R2

		jne printfaseScreenLoop

  	pop R3
  	pop R2
  	pop R1
  	pop R0
  	rts
  	
printFinalScreen:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #Screen
  loadn R1, #0
  loadn R2, #1200

  printFinalScreenLoop:

    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2

    jne printFinalScreenLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts
  	
Pato : var #1200
  ;Linha 0
  static Pato + #0, #3967
  static Pato + #1, #3967
  static Pato + #2, #3967
  static Pato + #3, #3967
  static Pato + #4, #3967
  static Pato + #5, #3967
  static Pato + #6, #3967
  static Pato + #7, #3967
  static Pato + #8, #3967
  static Pato + #9, #3967
  static Pato + #10, #3967
  static Pato + #11, #3967
  static Pato + #12, #3967
  static Pato + #13, #3967
  static Pato + #14, #3967
  static Pato + #15, #3967
  static Pato + #16, #3967
  static Pato + #17, #3967
  static Pato + #18, #3967
  static Pato + #19, #3967
  static Pato + #20, #3967
  static Pato + #21, #3967
  static Pato + #22, #2816
  static Pato + #23, #2816
  static Pato + #24, #2816
  static Pato + #25, #2816
  static Pato + #26, #2816
  static Pato + #27, #2816
  static Pato + #28, #2816
  static Pato + #29, #2816
  static Pato + #30, #2816
  static Pato + #31, #2816
  static Pato + #32, #2816
  static Pato + #33, #2816
  static Pato + #34, #3967
  static Pato + #35, #3967
  static Pato + #36, #3967
  static Pato + #37, #3967
  static Pato + #38, #3967
  static Pato + #39, #3967

  ;Linha 1
  static Pato + #40, #3967
  static Pato + #41, #3967
  static Pato + #42, #3967
  static Pato + #43, #3967
  static Pato + #44, #3967
  static Pato + #45, #3967
  static Pato + #46, #3967
  static Pato + #47, #3967
  static Pato + #48, #3967
  static Pato + #49, #3967
  static Pato + #50, #3967
  static Pato + #51, #3967
  static Pato + #52, #127
  static Pato + #53, #127
  static Pato + #54, #127
  static Pato + #55, #127
  static Pato + #56, #3967
  static Pato + #57, #3967
  static Pato + #58, #3967
  static Pato + #59, #3967
  static Pato + #60, #3967
  static Pato + #61, #3967
  static Pato + #62, #2816
  static Pato + #63, #2816
  static Pato + #64, #2816
  static Pato + #65, #2816
  static Pato + #66, #2816
  static Pato + #67, #2816
  static Pato + #68, #2816
  static Pato + #69, #2816
  static Pato + #70, #2816
  static Pato + #71, #2816
  static Pato + #72, #2816
  static Pato + #73, #2816
  static Pato + #74, #3967
  static Pato + #75, #3967
  static Pato + #76, #3967
  static Pato + #77, #3967
  static Pato + #78, #3967
  static Pato + #79, #3967

  ;Linha 2
  static Pato + #80, #3967
  static Pato + #81, #3967
  static Pato + #82, #3967
  static Pato + #83, #3967
  static Pato + #84, #3967
  static Pato + #85, #3967
  static Pato + #86, #3967
  static Pato + #87, #3967
  static Pato + #88, #3967
  static Pato + #89, #3967
  static Pato + #90, #3967
  static Pato + #91, #3967
  static Pato + #92, #3967
  static Pato + #93, #3967
  static Pato + #94, #3967
  static Pato + #95, #3967
  static Pato + #96, #3967
  static Pato + #97, #3967
  static Pato + #98, #3967
  static Pato + #99, #3967
  static Pato + #100, #3967
  static Pato + #101, #3967
  static Pato + #102, #2816
  static Pato + #103, #2816
  static Pato + #104, #2816
  static Pato + #105, #2816
  static Pato + #106, #2816
  static Pato + #107, #2816
  static Pato + #108, #2816
  static Pato + #109, #2816
  static Pato + #110, #2816
  static Pato + #111, #2816
  static Pato + #112, #2816
  static Pato + #113, #2816
  static Pato + #114, #3967
  static Pato + #115, #3967
  static Pato + #116, #3967
  static Pato + #117, #3967
  static Pato + #118, #3967
  static Pato + #119, #3967

  ;Linha 3
  static Pato + #120, #3967
  static Pato + #121, #3967
  static Pato + #122, #3967
  static Pato + #123, #3967
  static Pato + #124, #3967
  static Pato + #125, #3967
  static Pato + #126, #3967
  static Pato + #127, #3967
  static Pato + #128, #3967
  static Pato + #129, #3967
  static Pato + #130, #3967
  static Pato + #131, #3967
  static Pato + #132, #3967
  static Pato + #133, #3967
  static Pato + #134, #3967
  static Pato + #135, #3967
  static Pato + #136, #3967
  static Pato + #137, #3967
  static Pato + #138, #3967
  static Pato + #139, #3967
  static Pato + #140, #3967
  static Pato + #141, #3967
  static Pato + #142, #2816
  static Pato + #143, #2816
  static Pato + #144, #2816
  static Pato + #145, #2816
  static Pato + #146, #2816
  static Pato + #147, #2816
  static Pato + #148, #3967
  static Pato + #149, #3967
  static Pato + #150, #2816
  static Pato + #151, #2816
  static Pato + #152, #2816
  static Pato + #153, #2816
  static Pato + #154, #2819
  static Pato + #155, #3967
  static Pato + #156, #3967
  static Pato + #157, #3967
  static Pato + #158, #3967
  static Pato + #159, #3967

  ;Linha 4
  static Pato + #160, #3967
  static Pato + #161, #3967
  static Pato + #162, #3967
  static Pato + #163, #3967
  static Pato + #164, #3967
  static Pato + #165, #3967
  static Pato + #166, #3967
  static Pato + #167, #3967
  static Pato + #168, #1792
  static Pato + #169, #1792
  static Pato + #170, #1792
  static Pato + #171, #1792
  static Pato + #172, #1792
  static Pato + #173, #1792
  static Pato + #174, #1792
  static Pato + #175, #1792
  static Pato + #176, #1792
  static Pato + #177, #1792
  static Pato + #178, #3967
  static Pato + #179, #3967
  static Pato + #180, #3967
  static Pato + #181, #3967
  static Pato + #182, #2816
  static Pato + #183, #2816
  static Pato + #184, #2816
  static Pato + #185, #2816
  static Pato + #186, #2816
  static Pato + #187, #2816
  static Pato + #188, #3967
  static Pato + #189, #3967
  static Pato + #190, #2816
  static Pato + #191, #2816
  static Pato + #192, #2816
  static Pato + #193, #2816
  static Pato + #194, #2560
  static Pato + #195, #2560
  static Pato + #196, #2560
  static Pato + #197, #2560
  static Pato + #198, #2560
  static Pato + #199, #2560

  ;Linha 5
  static Pato + #200, #3967
  static Pato + #201, #3967
  static Pato + #202, #3967
  static Pato + #203, #3967
  static Pato + #204, #3967
  static Pato + #205, #3967
  static Pato + #206, #3967
  static Pato + #207, #3967
  static Pato + #208, #3967
  static Pato + #209, #3967
  static Pato + #210, #3967
  static Pato + #211, #3967840
  static Pato + #212, #3967
  static Pato + #213, #3967
  static Pato + #214, #3967
  static Pato + #215, #3967
  static Pato + #216, #3967
  static Pato + #217, #3967
  static Pato + #218, #3967
  static Pato + #219, #3967
  static Pato + #220, #3967
  static Pato + #221, #3967
  static Pato + #222, #2816
  static Pato + #223, #2816
  static Pato + #224, #2816
  static Pato + #225, #2816
  static Pato + #226, #2816
  static Pato + #227, #2816
  static Pato + #228, #2816
  static Pato + #229, #2816
  static Pato + #230, #2816
  static Pato + #231, #2816
  static Pato + #232, #2816
  static Pato + #233, #2816
  static Pato + #234, #2560
  static Pato + #235, #2560
  static Pato + #236, #2560
  static Pato + #237, #2560
  static Pato + #238, #2560
  static Pato + #239, #2560

  ;Linha 6
  static Pato + #240, #3967
  static Pato + #241, #3967
  static Pato + #242, #3967
  static Pato + #243, #3967
  static Pato + #244, #3967
  static Pato + #245, #3967
  static Pato + #246, #3967
  static Pato + #247, #3967
  static Pato + #248, #3967
  static Pato + #249, #3967
  static Pato + #250, #3967
  static Pato + #251, #3967
  static Pato + #252, #3967
  static Pato + #253, #3967
  static Pato + #254, #3967
  static Pato + #255, #3967
  static Pato + #256, #3967
  static Pato + #257, #3967
  static Pato + #258, #3967
  static Pato + #259, #3967
  static Pato + #260, #3967
  static Pato + #261, #3967
  static Pato + #262, #2816
  static Pato + #263, #2816
  static Pato + #264, #2816
  static Pato + #265, #2816
  static Pato + #266, #2816
  static Pato + #267, #2816
  static Pato + #268, #2816
  static Pato + #269, #2816
  static Pato + #270, #2816
  static Pato + #271, #2816
  static Pato + #272, #2816
  static Pato + #273, #2816
  static Pato + #274, #2560
  static Pato + #275, #2560
  static Pato + #276, #2560
  static Pato + #277, #2560
  static Pato + #278, #2560
  static Pato + #279, #2560

  ;Linha 7
  static Pato + #280, #3967
  static Pato + #281, #3967
  static Pato + #282, #3967
  static Pato + #283, #3967
  static Pato + #284, #3967
  static Pato + #285, #3967
  static Pato + #286, #3967
  static Pato + #287, #3967
  static Pato + #288, #3967
  static Pato + #289, #3967
  static Pato + #290, #3967
  static Pato + #291, #3967
  static Pato + #292, #3967
  static Pato + #293, #3967
  static Pato + #294, #3967
  static Pato + #295, #3967
  static Pato + #296, #3967
  static Pato + #297, #3967
  static Pato + #298, #3967
  static Pato + #299, #2816
  static Pato + #300, #2816
  static Pato + #301, #2816
  static Pato + #302, #2816
  static Pato + #303, #2816
  static Pato + #304, #2816
  static Pato + #305, #2816
  static Pato + #306, #2816
  static Pato + #307, #2816
  static Pato + #308, #2816
  static Pato + #309, #2816
  static Pato + #310, #2816
  static Pato + #311, #2816
  static Pato + #312, #2816
  static Pato + #313, #2816
  static Pato + #314, #2560
  static Pato + #315, #2560
  static Pato + #316, #2560
  static Pato + #317, #2560
  static Pato + #318, #2560
  static Pato + #319, #2560

  ;Linha 8
  static Pato + #320, #3967
  static Pato + #321, #3967
  static Pato + #322, #1792
  static Pato + #323, #1792
  static Pato + #324, #1792
  static Pato + #325, #1792
  static Pato + #326, #1792
  static Pato + #327, #1792
  static Pato + #328, #1792
  static Pato + #329, #3967
  static Pato + #330, #3967
  static Pato + #331, #3967
  static Pato + #332, #3967
  static Pato + #333, #2816
  static Pato + #334, #2816
  static Pato + #335, #2816
  static Pato + #336, #2816
  static Pato + #337, #2816
  static Pato + #338, #2816
  static Pato + #339, #2816
  static Pato + #340, #2816
  static Pato + #341, #2816
  static Pato + #342, #2816
  static Pato + #343, #2816
  static Pato + #344, #2816
  static Pato + #345, #2816
  static Pato + #346, #2816
  static Pato + #347, #2816
  static Pato + #348, #2816
  static Pato + #349, #2816
  static Pato + #350, #2816
  static Pato + #351, #2816
  static Pato + #352, #2816
  static Pato + #353, #2816
  static Pato + #354, #3967
  static Pato + #355, #3967
  static Pato + #356, #3967
  static Pato + #357, #3967
  static Pato + #358, #3967
  static Pato + #359, #3967

  ;Linha 9
  static Pato + #360, #3967
  static Pato + #361, #3967
  static Pato + #362, #3967
  static Pato + #363, #3967
  static Pato + #364, #3967
  static Pato + #365, #3967
  static Pato + #366, #3967
  static Pato + #367, #3967
  static Pato + #368, #3967
  static Pato + #369, #3967
  static Pato + #370, #3967
  static Pato + #371, #3967
  static Pato + #372, #3967
  static Pato + #373, #2816
  static Pato + #374, #2816
  static Pato + #375, #2816
  static Pato + #376, #2816
  static Pato + #377, #2816
  static Pato + #378, #2816
  static Pato + #379, #2816
  static Pato + #380, #2816
  static Pato + #381, #2816
  static Pato + #382, #2816
  static Pato + #383, #2816
  static Pato + #384, #2816
  static Pato + #385, #2816
  static Pato + #386, #2816
  static Pato + #387, #2816
  static Pato + #388, #2816
  static Pato + #389, #2816
  static Pato + #390, #2816
  static Pato + #391, #2816
  static Pato + #392, #2816
  static Pato + #393, #2816
  static Pato + #394, #3967
  static Pato + #395, #3967
  static Pato + #396, #3967
  static Pato + #397, #3967
  static Pato + #398, #3967
  static Pato + #399, #3967

  ;Linha 10
  static Pato + #400, #3967
  static Pato + #401, #3967
  static Pato + #402, #3967
  static Pato + #403, #3967
  static Pato + #404, #3967
  static Pato + #405, #3967
  static Pato + #406, #3967
  static Pato + #407, #3967840
  static Pato + #408, #2816
  static Pato + #409, #2816
  static Pato + #410, #2816
  static Pato + #411, #2816
  static Pato + #412, #2816
  static Pato + #413, #2816
  static Pato + #414, #2816
  static Pato + #415, #2816
  static Pato + #416, #2816
  static Pato + #417, #2816
  static Pato + #418, #2816
  static Pato + #419, #2816
  static Pato + #420, #2816
  static Pato + #421, #2816
  static Pato + #422, #2816
  static Pato + #423, #2816
  static Pato + #424, #2816
  static Pato + #425, #2816
  static Pato + #426, #2816
  static Pato + #427, #2816
  static Pato + #428, #2816
  static Pato + #429, #2816
  static Pato + #430, #2816
  static Pato + #431, #2816
  static Pato + #432, #2816
  static Pato + #433, #2816
  static Pato + #434, #3967
  static Pato + #435, #3967
  static Pato + #436, #3967
  static Pato + #437, #3967
  static Pato + #438, #3967
  static Pato + #439, #3967

  ;Linha 11
  static Pato + #440, #3967
  static Pato + #441, #3967
  static Pato + #442, #3967
  static Pato + #443, #3967
  static Pato + #444, #3967
  static Pato + #445, #3967
  static Pato + #446, #3967
  static Pato + #447, #3967
  static Pato + #448, #2816
  static Pato + #449, #2816
  static Pato + #450, #2816
  static Pato + #451, #2816
  static Pato + #452, #2816
  static Pato + #453, #2816
  static Pato + #454, #2816
  static Pato + #455, #2816
  static Pato + #456, #2816
  static Pato + #457, #2816
  static Pato + #458, #2816
  static Pato + #459, #2816
  static Pato + #460, #2816
  static Pato + #461, #2816
  static Pato + #462, #2816
  static Pato + #463, #2816
  static Pato + #464, #2816
  static Pato + #465, #2816
  static Pato + #466, #2816
  static Pato + #467, #2816
  static Pato + #468, #2816
  static Pato + #469, #2816
  static Pato + #470, #2816
  static Pato + #471, #2816
  static Pato + #472, #2816
  static Pato + #473, #2816
  static Pato + #474, #3967
  static Pato + #475, #3967
  static Pato + #476, #3967
  static Pato + #477, #3967
  static Pato + #478, #3967
  static Pato + #479, #3967

  ;Linha 12
  static Pato + #480, #3967
  static Pato + #481, #3967
  static Pato + #482, #3967
  static Pato + #483, #3967
  static Pato + #484, #3967
  static Pato + #485, #3967
  static Pato + #486, #3967
  static Pato + #487, #3967
  static Pato + #488, #3967
  static Pato + #489, #2816
  static Pato + #490, #2816
  static Pato + #491, #2816
  static Pato + #492, #2816
  static Pato + #493, #2816
  static Pato + #494, #2816
  static Pato + #495, #2816
  static Pato + #496, #2816
  static Pato + #497, #2816
  static Pato + #498, #2816
  static Pato + #499, #2816
  static Pato + #500, #2816
  static Pato + #501, #2816
  static Pato + #502, #2816
  static Pato + #503, #2816
  static Pato + #504, #2816
  static Pato + #505, #2816
  static Pato + #506, #2816
  static Pato + #507, #2816
  static Pato + #508, #2816
  static Pato + #509, #2816
  static Pato + #510, #2816
  static Pato + #511, #2816
  static Pato + #512, #2816
  static Pato + #513, #2816
  static Pato + #514, #3967
  static Pato + #515, #3967
  static Pato + #516, #3967
  static Pato + #517, #3967
  static Pato + #518, #3967
  static Pato + #519, #3967

  ;Linha 13
  static Pato + #520, #3967
  static Pato + #521, #3967
  static Pato + #522, #3967
  static Pato + #523, #3967
  static Pato + #524, #3967
  static Pato + #525, #3967
  static Pato + #526, #3967
  static Pato + #527, #3967
  static Pato + #528, #3967
  static Pato + #529, #3967
  static Pato + #530, #2816
  static Pato + #531, #2816
  static Pato + #532, #2816
  static Pato + #533, #2816
  static Pato + #534, #2816
  static Pato + #535, #2816
  static Pato + #536, #2816
  static Pato + #537, #2816
  static Pato + #538, #2816
  static Pato + #539, #2816
  static Pato + #540, #2816
  static Pato + #541, #2816
  static Pato + #542, #2816
  static Pato + #543, #2816
  static Pato + #544, #2816
  static Pato + #545, #2816
  static Pato + #546, #2816
  static Pato + #547, #2816
  static Pato + #548, #2816
  static Pato + #549, #2816
  static Pato + #550, #2816
  static Pato + #551, #2816
  static Pato + #552, #2816
  static Pato + #553, #2816
  static Pato + #554, #3967
  static Pato + #555, #3967
  static Pato + #556, #3967
  static Pato + #557, #3967
  static Pato + #558, #3967
  static Pato + #559, #3967

  ;Linha 14
  static Pato + #560, #3967
  static Pato + #561, #3967
  static Pato + #562, #3967
  static Pato + #563, #3967
  static Pato + #564, #3967
  static Pato + #565, #3967
  static Pato + #566, #3967
  static Pato + #567, #3967
  static Pato + #568, #3967
  static Pato + #569, #3967
  static Pato + #570, #3967
  static Pato + #571, #2816
  static Pato + #572, #2816
  static Pato + #573, #2816
  static Pato + #574, #2816
  static Pato + #575, #2816
  static Pato + #576, #2816
  static Pato + #577, #2816
  static Pato + #578, #2816
  static Pato + #579, #2816
  static Pato + #580, #2816
  static Pato + #581, #2816
  static Pato + #582, #2816
  static Pato + #583, #2816
  static Pato + #584, #2816
  static Pato + #585, #2816
  static Pato + #586, #2816
  static Pato + #587, #2816
  static Pato + #588, #2816
  static Pato + #589, #2816
  static Pato + #590, #2816
  static Pato + #591, #2816
  static Pato + #592, #2816
  static Pato + #593, #2816
  static Pato + #594, #3967
  static Pato + #595, #3967
  static Pato + #596, #3967
  static Pato + #597, #3967
  static Pato + #598, #3967
  static Pato + #599, #3967

  ;Linha 15
  static Pato + #600, #3967
  static Pato + #601, #3967
  static Pato + #602, #3967
  static Pato + #603, #3967
  static Pato + #604, #3967
  static Pato + #605, #3967
  static Pato + #606, #3967
  static Pato + #607, #3967
  static Pato + #608, #3967
  static Pato + #609, #3967
  static Pato + #610, #3967
  static Pato + #611, #3967
  static Pato + #612, #2816
  static Pato + #613, #2816
  static Pato + #614, #2816
  static Pato + #615, #2816
  static Pato + #616, #2816
  static Pato + #617, #2816
  static Pato + #618, #2816
  static Pato + #619, #2816
  static Pato + #620, #2816
  static Pato + #621, #2816
  static Pato + #622, #2816
  static Pato + #623, #2816
  static Pato + #624, #2816
  static Pato + #625, #2816
  static Pato + #626, #2816
  static Pato + #627, #2816
  static Pato + #628, #2816
  static Pato + #629, #2816
  static Pato + #630, #2816
  static Pato + #631, #2816
  static Pato + #632, #2816
  static Pato + #633, #2816
  static Pato + #634, #3967
  static Pato + #635, #3967
  static Pato + #636, #3967
  static Pato + #637, #3967
  static Pato + #638, #3967
  static Pato + #639, #3967

  ;Linha 16
  static Pato + #640, #3967
  static Pato + #641, #1792
  static Pato + #642, #1792
  static Pato + #643, #1792
  static Pato + #644, #1792
  static Pato + #645, #1792
  static Pato + #646, #1792
  static Pato + #647, #1792
  static Pato + #648, #3967
  static Pato + #649, #3967
  static Pato + #650, #3967
  static Pato + #651, #3967
  static Pato + #652, #3967
  static Pato + #653, #2816
  static Pato + #654, #2816
  static Pato + #655, #2816
  static Pato + #656, #2816
  static Pato + #657, #2816
  static Pato + #658, #2816
  static Pato + #659, #2816
  static Pato + #660, #2816
  static Pato + #661, #2816
  static Pato + #662, #2816
  static Pato + #663, #2816
  static Pato + #664, #2816
  static Pato + #665, #2816
  static Pato + #666, #2816
  static Pato + #667, #2816
  static Pato + #668, #2816
  static Pato + #669, #2816
  static Pato + #670, #2816
  static Pato + #671, #2816
  static Pato + #672, #2816
  static Pato + #673, #2816
  static Pato + #674, #3967
  static Pato + #675, #3967
  static Pato + #676, #3967
  static Pato + #677, #3967
  static Pato + #678, #3967
  static Pato + #679, #3967

  ;Linha 17
  static Pato + #680, #3967
  static Pato + #681, #3967
  static Pato + #682, #3967
  static Pato + #683, #3967
  static Pato + #684, #3967
  static Pato + #685, #3967
  static Pato + #686, #3967
  static Pato + #687, #3967
  static Pato + #688, #3967
  static Pato + #689, #3967
  static Pato + #690, #3967
  static Pato + #691, #3967
  static Pato + #692, #3967
  static Pato + #693, #3967
  static Pato + #694, #2816
  static Pato + #695, #2816
  static Pato + #696, #2816
  static Pato + #697, #2816
  static Pato + #698, #2816
  static Pato + #699, #2816
  static Pato + #700, #2816
  static Pato + #701, #2816
  static Pato + #702, #2816
  static Pato + #703, #2816
  static Pato + #704, #2816
  static Pato + #705, #2816
  static Pato + #706, #2816
  static Pato + #707, #2816
  static Pato + #708, #2816
  static Pato + #709, #2816
  static Pato + #710, #2816
  static Pato + #711, #2816
  static Pato + #712, #2816
  static Pato + #713, #2816
  static Pato + #714, #3967
  static Pato + #715, #3967
  static Pato + #716, #3967
  static Pato + #717, #3967
  static Pato + #718, #3967
  static Pato + #719, #3967

  ;Linha 18
  static Pato + #720, #3967
  static Pato + #721, #3967
  static Pato + #722, #3967
  static Pato + #723, #3967
  static Pato + #724, #3967
  static Pato + #725, #3967
  static Pato + #726, #3967
  static Pato + #727, #3967
  static Pato + #728, #3967
  static Pato + #729, #3967
  static Pato + #730, #3967
  static Pato + #731, #3967
  static Pato + #732, #3967
  static Pato + #733, #3967
  static Pato + #734, #3967
  static Pato + #735, #3967
  static Pato + #736, #2816
  static Pato + #737, #2816
  static Pato + #738, #2816
  static Pato + #739, #2816
  static Pato + #740, #2816
  static Pato + #741, #2816
  static Pato + #742, #2816
  static Pato + #743, #2816
  static Pato + #744, #2816
  static Pato + #745, #2816
  static Pato + #746, #2816
  static Pato + #747, #2816
  static Pato + #748, #2816
  static Pato + #749, #2816
  static Pato + #750, #2816
  static Pato + #751, #2816
  static Pato + #752, #2816
  static Pato + #753, #2816
  static Pato + #754, #3967
  static Pato + #755, #3967
  static Pato + #756, #3967
  static Pato + #757, #3967
  static Pato + #758, #3967
  static Pato + #759, #3967

  ;Linha 19
  static Pato + #760, #3967
  static Pato + #761, #3967
  static Pato + #762, #3967
  static Pato + #763, #3967
  static Pato + #764, #3967
  static Pato + #765, #3967
  static Pato + #766, #3967
  static Pato + #767, #3967
  static Pato + #768, #3967
  static Pato + #769, #3967
  static Pato + #770, #3967
  static Pato + #771, #3967
  static Pato + #772, #3967
  static Pato + #773, #3967
  static Pato + #774, #3967
  static Pato + #775, #3967
  static Pato + #776, #3967
  static Pato + #777, #3967
  static Pato + #778, #3967
  static Pato + #779, #3967
  static Pato + #780, #3967
  static Pato + #781, #3967
  static Pato + #782, #768
  static Pato + #783, #768
  static Pato + #784, #768
  static Pato + #785, #768
  static Pato + #786, #3967
  static Pato + #787, #3967
  static Pato + #788, #3967
  static Pato + #789, #3967
  static Pato + #790, #3967
  static Pato + #791, #3967
  static Pato + #792, #3967
  static Pato + #793, #3967
  static Pato + #794, #3967
  static Pato + #795, #3967
  static Pato + #796, #3967
  static Pato + #797, #3967
  static Pato + #798, #3967
  static Pato + #799, #3967

  ;Linha 20
  static Pato + #800, #3967
  static Pato + #801, #3967
  static Pato + #802, #3967
  static Pato + #803, #3967
  static Pato + #804, #3967
  static Pato + #805, #3967
  static Pato + #806, #3967
  static Pato + #807, #3967
  static Pato + #808, #3967
  static Pato + #809, #3967
  static Pato + #810, #3967
  static Pato + #811, #3967
  static Pato + #812, #3967
  static Pato + #813, #3967
  static Pato + #814, #3967
  static Pato + #815, #3967
  static Pato + #816, #3967
  static Pato + #817, #3967
  static Pato + #818, #3967
  static Pato + #819, #3967
  static Pato + #820, #3967
  static Pato + #821, #3967
  static Pato + #822, #768
  static Pato + #823, #768
  static Pato + #824, #768
  static Pato + #825, #768
  static Pato + #826, #3967
  static Pato + #827, #3967
  static Pato + #828, #3967
  static Pato + #829, #3967
  static Pato + #830, #3967
  static Pato + #831, #3967
  static Pato + #832, #3967
  static Pato + #833, #3967
  static Pato + #834, #3967
  static Pato + #835, #3967
  static Pato + #836, #3967
  static Pato + #837, #3967
  static Pato + #838, #3967
  static Pato + #839, #3967

  ;Linha 21
  static Pato + #840, #3967
  static Pato + #841, #3967
  static Pato + #842, #3967
  static Pato + #843, #3967
  static Pato + #844, #3967
  static Pato + #845, #3967
  static Pato + #846, #3967
  static Pato + #847, #3967
  static Pato + #848, #3967
  static Pato + #849, #3967
  static Pato + #850, #3967
  static Pato + #851, #3967
  static Pato + #852, #3967
  static Pato + #853, #3967
  static Pato + #854, #3967
  static Pato + #855, #3967
  static Pato + #856, #3967
  static Pato + #857, #3967
  static Pato + #858, #3967
  static Pato + #859, #3967
  static Pato + #860, #3967
  static Pato + #861, #3967
  static Pato + #862, #768
  static Pato + #863, #768
  static Pato + #864, #768
  static Pato + #865, #768
  static Pato + #866, #259
  static Pato + #867, #259
  static Pato + #868, #259
  static Pato + #869, #259
  static Pato + #870, #259
  static Pato + #871, #259
  static Pato + #872, #259
  static Pato + #873, #259
  static Pato + #874, #259
  static Pato + #875, #3967
  static Pato + #876, #3967
  static Pato + #877, #3967
  static Pato + #878, #3967
  static Pato + #879, #3967

  ;Linha 22
  static Pato + #880, #256
  static Pato + #881, #256
  static Pato + #882, #256
  static Pato + #883, #256
  static Pato + #884, #256
  static Pato + #885, #256
  static Pato + #886, #256
  static Pato + #887, #256
  static Pato + #888, #256
  static Pato + #889, #256
  static Pato + #890, #256
  static Pato + #891, #256
  static Pato + #892, #256
  static Pato + #893, #256
  static Pato + #894, #256
  static Pato + #895, #256
  static Pato + #896, #256
  static Pato + #897, #256
  static Pato + #898, #256
  static Pato + #899, #256
  static Pato + #900, #256
  static Pato + #901, #256
  static Pato + #902, #256
  static Pato + #903, #256
  static Pato + #904, #256
  static Pato + #905, #256
  static Pato + #906, #256
  static Pato + #907, #256
  static Pato + #908, #256
  static Pato + #909, #256
  static Pato + #910, #256
  static Pato + #911, #256
  static Pato + #912, #256
  static Pato + #913, #256
  static Pato + #914, #256
  static Pato + #915, #256
  static Pato + #916, #256
  static Pato + #917, #256
  static Pato + #918, #256
  static Pato + #919, #256

  ;Linha 23
  static Pato + #920, #256
  static Pato + #921, #256
  static Pato + #922, #256
  static Pato + #923, #256
  static Pato + #924, #256
  static Pato + #925, #256
  static Pato + #926, #256
  static Pato + #927, #256
  static Pato + #928, #256
  static Pato + #929, #256
  static Pato + #930, #256
  static Pato + #931, #256
  static Pato + #932, #256
  static Pato + #933, #256
  static Pato + #934, #256
  static Pato + #935, #256
  static Pato + #936, #256
  static Pato + #937, #256
  static Pato + #938, #256
  static Pato + #939, #256
  static Pato + #940, #256
  static Pato + #941, #256
  static Pato + #942, #256
  static Pato + #943, #256
  static Pato + #944, #256
  static Pato + #945, #256
  static Pato + #946, #256
  static Pato + #947, #256
  static Pato + #948, #256
  static Pato + #949, #256
  static Pato + #950, #256
  static Pato + #951, #256
  static Pato + #952, #256
  static Pato + #953, #256
  static Pato + #954, #256
  static Pato + #955, #256
  static Pato + #956, #256
  static Pato + #957, #256
  static Pato + #958, #256
  static Pato + #959, #256

  ;Linha 24
  static Pato + #960, #3967
  static Pato + #961, #3967
  static Pato + #962, #3967
  static Pato + #963, #3967
  static Pato + #964, #3967
  static Pato + #965, #3967
  static Pato + #966, #3967
  static Pato + #967, #3967
  static Pato + #968, #3967
  static Pato + #969, #3967
  static Pato + #970, #3967
  static Pato + #971, #3967
  static Pato + #972, #3967
  static Pato + #973, #3967
  static Pato + #974, #3967
  static Pato + #975, #3967
  static Pato + #976, #3967
  static Pato + #977, #3967
  static Pato + #978, #3967
  static Pato + #979, #3967
  static Pato + #980, #3967
  static Pato + #981, #3967
  static Pato + #982, #3967
  static Pato + #983, #3967
  static Pato + #984, #3967
  static Pato + #985, #3967
  static Pato + #986, #3967
  static Pato + #987, #3967
  static Pato + #988, #3967
  static Pato + #989, #3967
  static Pato + #990, #3967
  static Pato + #991, #3967
  static Pato + #992, #3967
  static Pato + #993, #3967
  static Pato + #994, #3967
  static Pato + #995, #3967
  static Pato + #996, #3967
  static Pato + #997, #3967
  static Pato + #998, #3967
  static Pato + #999, #3967

  ;Linha 25
  static Pato + #1000, #0
  static Pato + #1001, #0
  static Pato + #1002, #0
  static Pato + #1003, #3967
  static Pato + #1004, #0
  static Pato + #1005, #0
  static Pato + #1006, #0
  static Pato + #1007, #0
  static Pato + #1008, #3967
  static Pato + #1009, #0
  static Pato + #1010, #0
  static Pato + #1011, #3967
  static Pato + #1012, #0
  static Pato + #1013, #0
  static Pato + #1014, #0
  static Pato + #1015, #3967
  static Pato + #1016, #0
  static Pato + #1017, #0
  static Pato + #1018, #0
  static Pato + #1019, #3967
  static Pato + #1020, #3967
  static Pato + #1021, #0
  static Pato + #1022, #0
  static Pato + #1023, #0
  static Pato + #1024, #3967
  static Pato + #1025, #0
  static Pato + #1026, #0
  static Pato + #1027, #0
  static Pato + #1028, #3967
  static Pato + #1029, #0
  static Pato + #1030, #0
  static Pato + #1031, #0
  static Pato + #1032, #3967
  static Pato + #1033, #0
  static Pato + #1034, #0
  static Pato + #1035, #0
  static Pato + #1036, #3967
  static Pato + #1037, #0
  static Pato + #1038, #0
  static Pato + #1039, #0

  ;Linha 26
  static Pato + #1040, #0
  static Pato + #1041, #3967
  static Pato + #1042, #0
  static Pato + #1043, #3967
  static Pato + #1044, #0
  static Pato + #1045, #3967
  static Pato + #1046, #3967
  static Pato + #1047, #0
  static Pato + #1048, #3967
  static Pato + #1049, #0
  static Pato + #1050, #3967
  static Pato + #1051, #3967
  static Pato + #1052, #0
  static Pato + #1053, #3967
  static Pato + #1054, #3967
  static Pato + #1055, #3967
  static Pato + #1056, #0
  static Pato + #1057, #3967
  static Pato + #1058, #3967
  static Pato + #1059, #3967
  static Pato + #1060, #3967
  static Pato + #1061, #0
  static Pato + #1062, #3967
  static Pato + #1063, #3967
  static Pato + #1064, #3967
  static Pato + #1065, #0
  static Pato + #1066, #3967
  static Pato + #1067, #0
  static Pato + #1068, #3967
  static Pato + #1069, #0
  static Pato + #1070, #3967
  static Pato + #1071, #0
  static Pato + #1072, #3967
  static Pato + #1073, #0
  static Pato + #1074, #3967
  static Pato + #1075, #3967
  static Pato + #1076, #3967
  static Pato + #1077, #0
  static Pato + #1078, #3967
  static Pato + #1079, #3967

  ;Linha 27
  static Pato + #1080, #0
  static Pato + #1081, #0
  static Pato + #1082, #0
  static Pato + #1083, #3967
  static Pato + #1084, #0
  static Pato + #1085, #0
  static Pato + #1086, #0
  static Pato + #1087, #0
  static Pato + #1088, #3967
  static Pato + #1089, #0
  static Pato + #1090, #0
  static Pato + #1091, #3967
  static Pato + #1092, #0
  static Pato + #1093, #0
  static Pato + #1094, #0
  static Pato + #1095, #3967
  static Pato + #1096, #0
  static Pato + #1097, #0
  static Pato + #1098, #0
  static Pato + #1099, #3967
  static Pato + #1100, #3967
  static Pato + #1101, #0
  static Pato + #1102, #0
  static Pato + #1103, #0
  static Pato + #1104, #3967
  static Pato + #1105, #0
  static Pato + #1106, #0
  static Pato + #1107, #0
  static Pato + #1108, #3967
  static Pato + #1109, #0
  static Pato + #1110, #0
  static Pato + #1111, #0
  static Pato + #1112, #3967
  static Pato + #1113, #0
  static Pato + #1114, #3967
  static Pato + #1115, #3967
  static Pato + #1116, #3967
  static Pato + #1117, #0
  static Pato + #1118, #0
  static Pato + #1119, #0

  ;Linha 28
  static Pato + #1120, #0
  static Pato + #1121, #3967
  static Pato + #1122, #3967
  static Pato + #1123, #3967
  static Pato + #1124, #0
  static Pato + #1125, #3967
  static Pato + #1126, #0
  static Pato + #1127, #3967
  static Pato + #1128, #3967
  static Pato + #1129, #0
  static Pato + #1130, #3967
  static Pato + #1131, #3967
  static Pato + #1132, #3967
  static Pato + #1133, #3967
  static Pato + #1134, #0
  static Pato + #1135, #3967
  static Pato + #1136, #3967
  static Pato + #1137, #3967
  static Pato + #1138, #0
  static Pato + #1139, #3967
  static Pato + #1140, #3967
  static Pato + #1141, #3967
  static Pato + #1142, #3967
  static Pato + #1143, #0
  static Pato + #1144, #3967
  static Pato + #1145, #0
  static Pato + #1146, #3967
  static Pato + #1147, #3967
  static Pato + #1148, #3967
  static Pato + #1149, #0
  static Pato + #1150, #3967
  static Pato + #1151, #0
  static Pato + #1152, #3967
  static Pato + #1153, #0
  static Pato + #1154, #3967
  static Pato + #1155, #3967
  static Pato + #1156, #3967
  static Pato + #1157, #0
  static Pato + #1158, #3967
  static Pato + #1159, #3967

  ;Linha 29
  static Pato + #1160, #0
  static Pato + #1161, #3967
  static Pato + #1162, #3967
  static Pato + #1163, #3967
  static Pato + #1164, #0
  static Pato + #1165, #3967
  static Pato + #1166, #3967
  static Pato + #1167, #0
  static Pato + #1168, #3967
  static Pato + #1169, #0
  static Pato + #1170, #0
  static Pato + #1171, #3967
  static Pato + #1172, #0
  static Pato + #1173, #0
  static Pato + #1174, #0
  static Pato + #1175, #3967
  static Pato + #1176, #0
  static Pato + #1177, #0
  static Pato + #1178, #0
  static Pato + #1179, #3967
  static Pato + #1180, #3967
  static Pato + #1181, #0
  static Pato + #1182, #0
  static Pato + #1183, #0
  static Pato + #1184, #3967
  static Pato + #1185, #0
  static Pato + #1186, #3967
  static Pato + #1187, #3967
  static Pato + #1188, #3967
  static Pato + #1189, #0
  static Pato + #1190, #3967
  static Pato + #1191, #0
  static Pato + #1192, #3967
  static Pato + #1193, #0
  static Pato + #1194, #0
  static Pato + #1195, #0
  static Pato + #1196, #3967
  static Pato + #1197, #0
  static Pato + #1198, #0
  static Pato + #1199, #0


Screen : var #1200
  ;Linha 0
  static Screen + #0, #3967
  static Screen + #1, #3967
  static Screen + #2, #3967
  static Screen + #3, #3967
  static Screen + #4, #3967
  static Screen + #5, #3967
  static Screen + #6, #3967
  static Screen + #7, #3967
  static Screen + #8, #3967
  static Screen + #9, #3967
  static Screen + #10, #3967
  static Screen + #11, #3967
  static Screen + #12, #3967
  static Screen + #13, #3967
  static Screen + #14, #3967
  static Screen + #15, #3967
  static Screen + #16, #3967
  static Screen + #17, #3967
  static Screen + #18, #3967
  static Screen + #19, #3967
  static Screen + #20, #3967
  static Screen + #21, #3967
  static Screen + #22, #3967
  static Screen + #23, #3967
  static Screen + #24, #3967
  static Screen + #25, #3967
  static Screen + #26, #3967
  static Screen + #27, #3967
  static Screen + #28, #3967
  static Screen + #29, #3967
  static Screen + #30, #3967
  static Screen + #31, #3967
  static Screen + #32, #3967
  static Screen + #33, #3967
  static Screen + #34, #3967
  static Screen + #35, #3967
  static Screen + #36, #3967
  static Screen + #37, #3967
  static Screen + #38, #3967
  static Screen + #39, #3967

  ;Linha 1
  static Screen + #40, #3967
  static Screen + #41, #3967
  static Screen + #42, #3967
  static Screen + #43, #3967
  static Screen + #44, #3967
  static Screen + #45, #3967
  static Screen + #46, #3967
  static Screen + #47, #3967
  static Screen + #48, #3967
  static Screen + #49, #3967
  static Screen + #50, #3967
  static Screen + #51, #3967
  static Screen + #52, #3967
  static Screen + #53, #3967
  static Screen + #54, #3967
  static Screen + #55, #3967
  static Screen + #56, #3967
  static Screen + #57, #3967
  static Screen + #58, #3967
  static Screen + #59, #3967
  static Screen + #60, #3967
  static Screen + #61, #3967
  static Screen + #62, #3967
  static Screen + #63, #3967
  static Screen + #64, #3967
  static Screen + #65, #3967
  static Screen + #66, #3967
  static Screen + #67, #3967
  static Screen + #68, #3967
  static Screen + #69, #3967
  static Screen + #70, #3967
  static Screen + #71, #3967
  static Screen + #72, #3967
  static Screen + #73, #3967
  static Screen + #74, #3967
  static Screen + #75, #3
  static Screen + #76, #3967
  static Screen + #77, #3967
  static Screen + #78, #3967
  static Screen + #79, #3967

  ;Linha 2
  static Screen + #80, #3967
  static Screen + #81, #3967
  static Screen + #82, #3967
  static Screen + #83, #3967
  static Screen + #84, #3967
  static Screen + #85, #3967
  static Screen + #86, #3967
  static Screen + #87, #3967
  static Screen + #88, #3967
  static Screen + #89, #3967
  static Screen + #90, #3967
  static Screen + #91, #3967
  static Screen + #92, #3967
  static Screen + #93, #3967
  static Screen + #94, #3967
  static Screen + #95, #3967
  static Screen + #96, #3967
  static Screen + #97, #3967
  static Screen + #98, #3967
  static Screen + #99, #3967
  static Screen + #100, #3967
  static Screen + #101, #3967
  static Screen + #102, #3967
  static Screen + #103, #3967
  static Screen + #104, #3967
  static Screen + #105, #3967
  static Screen + #106, #3967
  static Screen + #107, #3967
  static Screen + #108, #3967
  static Screen + #109, #3967
  static Screen + #110, #3967
  static Screen + #111, #3967
  static Screen + #112, #3967
  static Screen + #113, #3967
  static Screen + #114, #3967
  static Screen + #115, #3
  static Screen + #116, #3967
  static Screen + #117, #3967
  static Screen + #118, #3967
  static Screen + #119, #3967

  ;Linha 3
  static Screen + #120, #3967
  static Screen + #121, #3967
  static Screen + #122, #3967
  static Screen + #123, #3967
  static Screen + #124, #3967
  static Screen + #125, #3967
  static Screen + #126, #3967
  static Screen + #127, #3967
  static Screen + #128, #3967
  static Screen + #129, #3967
  static Screen + #130, #3967
  static Screen + #131, #3967
  static Screen + #132, #3967
  static Screen + #133, #3967
  static Screen + #134, #3967
  static Screen + #135, #3967
  static Screen + #136, #3967
  static Screen + #137, #3967
  static Screen + #138, #1
  static Screen + #139, #3967
  static Screen + #140, #3967
  static Screen + #141, #3967
  static Screen + #142, #3967
  static Screen + #143, #3967
  static Screen + #144, #3967
  static Screen + #145, #3967
  static Screen + #146, #3967
  static Screen + #147, #3967
  static Screen + #148, #3967
  static Screen + #149, #3967
  static Screen + #150, #3967
  static Screen + #151, #3967
  static Screen + #152, #3967
  static Screen + #153, #3967
  static Screen + #154, #3967
  static Screen + #155, #3
  static Screen + #156, #3967
  static Screen + #157, #3967
  static Screen + #158, #3967
  static Screen + #159, #3967

  ;Linha 4
  static Screen + #160, #3967
  static Screen + #161, #3967
  static Screen + #162, #3967
  static Screen + #163, #3967
  static Screen + #164, #3967
  static Screen + #165, #3967
  static Screen + #166, #3967
  static Screen + #167, #3967
  static Screen + #168, #3967
  static Screen + #169, #3967
  static Screen + #170, #3967
  static Screen + #171, #3967
  static Screen + #172, #3967
  static Screen + #173, #3967
  static Screen + #174, #3967
  static Screen + #175, #3967
  static Screen + #176, #3967
  static Screen + #177, #3967
  static Screen + #178, #3
  static Screen + #179, #3967
  static Screen + #180, #3967
  static Screen + #181, #3967
  static Screen + #182, #3967
  static Screen + #183, #3967
  static Screen + #184, #3
  static Screen + #185, #3967
  static Screen + #186, #3967
  static Screen + #187, #3
  static Screen + #188, #3967
  static Screen + #189, #3967
  static Screen + #190, #3967
  static Screen + #191, #3967
  static Screen + #192, #3
  static Screen + #193, #3
  static Screen + #194, #3967
  static Screen + #195, #3
  static Screen + #196, #3
  static Screen + #197, #3
  static Screen + #198, #3967
  static Screen + #199, #3967

  ;Linha 5
  static Screen + #200, #3967
  static Screen + #201, #3967
  static Screen + #202, #3967
  static Screen + #203, #3967
  static Screen + #204, #0
  static Screen + #205, #0
  static Screen + #206, #0
  static Screen + #207, #0
  static Screen + #208, #0
  static Screen + #209, #0
  static Screen + #210, #0
  static Screen + #211, #0
  static Screen + #212, #0
  static Screen + #213, #3967
  static Screen + #214, #3967
  static Screen + #215, #3967
  static Screen + #216, #3967
  static Screen + #217, #3967
  static Screen + #218, #0
  static Screen + #219, #3967
  static Screen + #220, #3967
  static Screen + #221, #3967
  static Screen + #222, #3967
  static Screen + #223, #3967
  static Screen + #224, #0
  static Screen + #225, #0
  static Screen + #226, #3
  static Screen + #227, #3
  static Screen + #228, #3967
  static Screen + #229, #3967
  static Screen + #230, #3
  static Screen + #231, #3
  static Screen + #232, #3
  static Screen + #233, #3
  static Screen + #234, #3
  static Screen + #235, #0
  static Screen + #236, #0
  static Screen + #237, #0
  static Screen + #238, #3967
  static Screen + #239, #3967

  ;Linha 6
  static Screen + #240, #3967
  static Screen + #241, #3967
  static Screen + #242, #3967
  static Screen + #243, #3967
  static Screen + #244, #0
  static Screen + #245, #3967
  static Screen + #246, #3967
  static Screen + #247, #3967
  static Screen + #248, #3967
  static Screen + #249, #3967
  static Screen + #250, #3967
  static Screen + #251, #3967
  static Screen + #252, #3967
  static Screen + #253, #3967
  static Screen + #254, #3967
  static Screen + #255, #3967
  static Screen + #256, #3967
  static Screen + #257, #3967
  static Screen + #258, #0
  static Screen + #259, #3967
  static Screen + #260, #3967
  static Screen + #261, #3967
  static Screen + #262, #3967
  static Screen + #263, #3967
  static Screen + #264, #0
  static Screen + #265, #0
  static Screen + #266, #0
  static Screen + #267, #3
  static Screen + #268, #3
  static Screen + #269, #3967
  static Screen + #270, #3
  static Screen + #271, #3
  static Screen + #272, #3
  static Screen + #273, #3
  static Screen + #274, #0
  static Screen + #275, #0
  static Screen + #276, #4
  static Screen + #277, #0
  static Screen + #278, #3967
  static Screen + #279, #3967

  ;Linha 7
  static Screen + #280, #3967
  static Screen + #281, #3967
  static Screen + #282, #3967
  static Screen + #283, #3967
  static Screen + #284, #0
  static Screen + #285, #3967
  static Screen + #286, #3967
  static Screen + #287, #3967
  static Screen + #288, #3967
  static Screen + #289, #3967
  static Screen + #290, #3967
  static Screen + #291, #3967
  static Screen + #292, #3967
  static Screen + #293, #3967
  static Screen + #294, #3967
  static Screen + #295, #3967
  static Screen + #296, #3967
  static Screen + #297, #3967
  static Screen + #298, #0
  static Screen + #299, #3967
  static Screen + #300, #3967
  static Screen + #301, #3967
  static Screen + #302, #3967
  static Screen + #303, #3967
  static Screen + #304, #0
  static Screen + #305, #3
  static Screen + #306, #0
  static Screen + #307, #0
  static Screen + #308, #3
  static Screen + #309, #3
  static Screen + #310, #3
  static Screen + #311, #3
  static Screen + #312, #3
  static Screen + #313, #0
  static Screen + #314, #0
  static Screen + #315, #3
  static Screen + #316, #3
  static Screen + #317, #0
  static Screen + #318, #3967
  static Screen + #319, #3967

  ;Linha 8
  static Screen + #320, #3967
  static Screen + #321, #3967
  static Screen + #322, #3967
  static Screen + #323, #3967
  static Screen + #324, #0
  static Screen + #325, #3967
  static Screen + #326, #3967
  static Screen + #327, #3967
  static Screen + #328, #3967
  static Screen + #329, #3967
  static Screen + #330, #3967
  static Screen + #331, #3967
  static Screen + #332, #3967
  static Screen + #333, #3967
  static Screen + #334, #3967
  static Screen + #335, #3967
  static Screen + #336, #3967
  static Screen + #337, #3967
  static Screen + #338, #0
  static Screen + #339, #3967
  static Screen + #340, #3967
  static Screen + #341, #3967
  static Screen + #342, #3967
  static Screen + #343, #3967
  static Screen + #344, #0
  static Screen + #345, #3
  static Screen + #346, #3
  static Screen + #347, #0
  static Screen + #348, #0
  static Screen + #349, #3
  static Screen + #350, #3
  static Screen + #351, #3
  static Screen + #352, #0
  static Screen + #353, #0
  static Screen + #354, #3
  static Screen + #355, #3967
  static Screen + #356, #3
  static Screen + #357, #0
  static Screen + #358, #3967
  static Screen + #359, #3967

  ;Linha 9
  static Screen + #360, #3967
  static Screen + #361, #3967
  static Screen + #362, #3967
  static Screen + #363, #3967
  static Screen + #364, #0
  static Screen + #365, #3
  static Screen + #366, #3967
  static Screen + #367, #3967
  static Screen + #368, #3967
  static Screen + #369, #3967
  static Screen + #370, #3967
  static Screen + #371, #3967
  static Screen + #372, #3967
  static Screen + #373, #3967
  static Screen + #374, #3967
  static Screen + #375, #3967
  static Screen + #376, #3967
  static Screen + #377, #3967
  static Screen + #378, #0
  static Screen + #379, #3967
  static Screen + #380, #3967
  static Screen + #381, #3967
  static Screen + #382, #3967
  static Screen + #383, #3967
  static Screen + #384, #0
  static Screen + #385, #3
  static Screen + #386, #3
  static Screen + #387, #3967
  static Screen + #388, #0
  static Screen + #389, #0
  static Screen + #390, #3
  static Screen + #391, #0
  static Screen + #392, #0
  static Screen + #393, #3
  static Screen + #394, #3
  static Screen + #395, #3
  static Screen + #396, #3
  static Screen + #397, #0
  static Screen + #398, #3967
  static Screen + #399, #3967

  ;Linha 10
  static Screen + #400, #3967
  static Screen + #401, #3967
  static Screen + #402, #3967
  static Screen + #403, #3967
  static Screen + #404, #0
  static Screen + #405, #3
  static Screen + #406, #3967
  static Screen + #407, #3967
  static Screen + #408, #3967
  static Screen + #409, #3967
  static Screen + #410, #3967
  static Screen + #411, #3967
  static Screen + #412, #3967
  static Screen + #413, #3967
  static Screen + #414, #3967
  static Screen + #415, #3967
  static Screen + #416, #3967
  static Screen + #417, #3967
  static Screen + #418, #0
  static Screen + #419, #3967
  static Screen + #420, #3967
  static Screen + #421, #3967
  static Screen + #422, #3967
  static Screen + #423, #3967
  static Screen + #424, #0
  static Screen + #425, #3
  static Screen + #426, #3967
  static Screen + #427, #3
  static Screen + #428, #3
  static Screen + #429, #0
  static Screen + #430, #0
  static Screen + #431, #0
  static Screen + #432, #3
  static Screen + #433, #3
  static Screen + #434, #3
  static Screen + #435, #3
  static Screen + #436, #3967
  static Screen + #437, #0
  static Screen + #438, #3967
  static Screen + #439, #3967

  ;Linha 11
  static Screen + #440, #3967
  static Screen + #441, #3967
  static Screen + #442, #3967
  static Screen + #443, #3967
  static Screen + #444, #0
  static Screen + #445, #3
  static Screen + #446, #3967
  static Screen + #447, #3967
  static Screen + #448, #3967
  static Screen + #449, #3967
  static Screen + #450, #3967
  static Screen + #451, #3967
  static Screen + #452, #3967
  static Screen + #453, #3967
  static Screen + #454, #3967
  static Screen + #455, #3967
  static Screen + #456, #3967
  static Screen + #457, #3967
  static Screen + #458, #0
  static Screen + #459, #3967
  static Screen + #460, #3967
  static Screen + #461, #3967
  static Screen + #462, #3967
  static Screen + #463, #3
  static Screen + #464, #0
  static Screen + #465, #3967
  static Screen + #466, #3967
  static Screen + #467, #3
  static Screen + #468, #3
  static Screen + #469, #3
  static Screen + #470, #0
  static Screen + #471, #3
  static Screen + #472, #3967
  static Screen + #473, #3967
  static Screen + #474, #3
  static Screen + #475, #3
  static Screen + #476, #3
  static Screen + #477, #0
  static Screen + #478, #3967
  static Screen + #479, #3967

  ;Linha 12
  static Screen + #480, #3967
  static Screen + #481, #3967
  static Screen + #482, #3967
  static Screen + #483, #3967
  static Screen + #484, #0
  static Screen + #485, #0
  static Screen + #486, #0
  static Screen + #487, #0
  static Screen + #488, #0
  static Screen + #489, #0
  static Screen + #490, #0
  static Screen + #491, #0
  static Screen + #492, #0
  static Screen + #493, #3967
  static Screen + #494, #3967
  static Screen + #495, #3967
  static Screen + #496, #3967
  static Screen + #497, #3967
  static Screen + #498, #0
  static Screen + #499, #3967
  static Screen + #500, #3967
  static Screen + #501, #3967
  static Screen + #502, #3
  static Screen + #503, #3
  static Screen + #504, #0
  static Screen + #505, #3967
  static Screen + #506, #3967
  static Screen + #507, #3967
  static Screen + #508, #3
  static Screen + #509, #3
  static Screen + #510, #3
  static Screen + #511, #3
  static Screen + #512, #3967
  static Screen + #513, #3
  static Screen + #514, #3
  static Screen + #515, #3
  static Screen + #516, #3
  static Screen + #517, #0
  static Screen + #518, #3
  static Screen + #519, #3967

  ;Linha 13
  static Screen + #520, #3967
  static Screen + #521, #3967
  static Screen + #522, #3967
  static Screen + #523, #3967
  static Screen + #524, #0
  static Screen + #525, #3
  static Screen + #526, #3967
  static Screen + #527, #3967
  static Screen + #528, #3967
  static Screen + #529, #3967
  static Screen + #530, #3967
  static Screen + #531, #3967
  static Screen + #532, #3967
  static Screen + #533, #3967
  static Screen + #534, #3967
  static Screen + #535, #3967
  static Screen + #536, #3967
  static Screen + #537, #3967
  static Screen + #538, #0
  static Screen + #539, #3967
  static Screen + #540, #3967
  static Screen + #541, #3967
  static Screen + #542, #3
  static Screen + #543, #3
  static Screen + #544, #0
  static Screen + #545, #3967
  static Screen + #546, #3967
  static Screen + #547, #3967
  static Screen + #548, #3
  static Screen + #549, #3
  static Screen + #550, #3967
  static Screen + #551, #3967
  static Screen + #552, #3967
  static Screen + #553, #3967
  static Screen + #554, #3
  static Screen + #555, #3
  static Screen + #556, #3967
  static Screen + #557, #0
  static Screen + #558, #3
  static Screen + #559, #3967

  ;Linha 14
  static Screen + #560, #3967
  static Screen + #561, #3967
  static Screen + #562, #3967
  static Screen + #563, #3967
  static Screen + #564, #0
  static Screen + #565, #3
  static Screen + #566, #3967
  static Screen + #567, #3967
  static Screen + #568, #3967
  static Screen + #569, #3967
  static Screen + #570, #3967
  static Screen + #571, #3967
  static Screen + #572, #3967
  static Screen + #573, #3967
  static Screen + #574, #3967
  static Screen + #575, #3967
  static Screen + #576, #3967
  static Screen + #577, #3967
  static Screen + #578, #0
  static Screen + #579, #3967
  static Screen + #580, #3967
  static Screen + #581, #3967
  static Screen + #582, #3
  static Screen + #583, #3
  static Screen + #584, #0
  static Screen + #585, #3967
  static Screen + #586, #3967
  static Screen + #587, #3967
  static Screen + #588, #3967
  static Screen + #589, #3
  static Screen + #590, #3
  static Screen + #591, #3967
  static Screen + #592, #3967
  static Screen + #593, #3967
  static Screen + #594, #3
  static Screen + #595, #3
  static Screen + #596, #3
  static Screen + #597, #0
  static Screen + #598, #3
  static Screen + #599, #3967

  ;Linha 15
  static Screen + #600, #3967
  static Screen + #601, #3967
  static Screen + #602, #3967
  static Screen + #603, #3967
  static Screen + #604, #0
  static Screen + #605, #3
  static Screen + #606, #3967
  static Screen + #607, #3967
  static Screen + #608, #3967
  static Screen + #609, #3967
  static Screen + #610, #3967
  static Screen + #611, #3967
  static Screen + #612, #3967
  static Screen + #613, #3967
  static Screen + #614, #3967
  static Screen + #615, #3967
  static Screen + #616, #3967
  static Screen + #617, #3967
  static Screen + #618, #0
  static Screen + #619, #3967
  static Screen + #620, #3967
  static Screen + #621, #3967
  static Screen + #622, #3
  static Screen + #623, #3
  static Screen + #624, #0
  static Screen + #625, #3967
  static Screen + #626, #3967
  static Screen + #627, #3967
  static Screen + #628, #3967
  static Screen + #629, #3
  static Screen + #630, #3
  static Screen + #631, #3967
  static Screen + #632, #3967
  static Screen + #633, #3967
  static Screen + #634, #3
  static Screen + #635, #3
  static Screen + #636, #3
  static Screen + #637, #0
  static Screen + #638, #3
  static Screen + #639, #3967

  ;Linha 16
  static Screen + #640, #3967
  static Screen + #641, #3967
  static Screen + #642, #3967
  static Screen + #643, #3967
  static Screen + #644, #0
  static Screen + #645, #3
  static Screen + #646, #3967
  static Screen + #647, #3967
  static Screen + #648, #3967
  static Screen + #649, #3967
  static Screen + #650, #3967
  static Screen + #651, #3967
  static Screen + #652, #3967
  static Screen + #653, #3967
  static Screen + #654, #3967
  static Screen + #655, #3967
  static Screen + #656, #3967
  static Screen + #657, #3967
  static Screen + #658, #0
  static Screen + #659, #3967
  static Screen + #660, #3967
  static Screen + #661, #3967
  static Screen + #662, #3
  static Screen + #663, #3
  static Screen + #664, #0
  static Screen + #665, #3967
  static Screen + #666, #3967
  static Screen + #667, #3967
  static Screen + #668, #3967
  static Screen + #669, #3
  static Screen + #670, #3
  static Screen + #671, #3967
  static Screen + #672, #3967
  static Screen + #673, #3
  static Screen + #674, #3
  static Screen + #675, #3
  static Screen + #676, #3967
  static Screen + #677, #0
  static Screen + #678, #3
  static Screen + #679, #3967

  ;Linha 17
  static Screen + #680, #3967
  static Screen + #681, #3967
  static Screen + #682, #3967
  static Screen + #683, #3967
  static Screen + #684, #0
  static Screen + #685, #3
  static Screen + #686, #3967
  static Screen + #687, #3967
  static Screen + #688, #3967
  static Screen + #689, #3967
  static Screen + #690, #3967
  static Screen + #691, #3967
  static Screen + #692, #3967
  static Screen + #693, #3967
  static Screen + #694, #3967
  static Screen + #695, #3967
  static Screen + #696, #3967
  static Screen + #697, #3967
  static Screen + #698, #0
  static Screen + #699, #3967
  static Screen + #700, #3967
  static Screen + #701, #3
  static Screen + #702, #3
  static Screen + #703, #3
  static Screen + #704, #0
  static Screen + #705, #3967
  static Screen + #706, #3967
  static Screen + #707, #3967
  static Screen + #708, #3967
  static Screen + #709, #3967
  static Screen + #710, #3967
  static Screen + #711, #3967
  static Screen + #712, #3967
  static Screen + #713, #3967
  static Screen + #714, #3967
  static Screen + #715, #3
  static Screen + #716, #3
  static Screen + #717, #0
  static Screen + #718, #3
  static Screen + #719, #3967

  ;Linha 18
  static Screen + #720, #3967
  static Screen + #721, #3967
  static Screen + #722, #3967
  static Screen + #723, #3967
  static Screen + #724, #0
  static Screen + #725, #3
  static Screen + #726, #3967
  static Screen + #727, #3967
  static Screen + #728, #3967
  static Screen + #729, #3967
  static Screen + #730, #3967
  static Screen + #731, #3967
  static Screen + #732, #3967
  static Screen + #733, #3967
  static Screen + #734, #3967
  static Screen + #735, #3967
  static Screen + #736, #3967
  static Screen + #737, #3967
  static Screen + #738, #0
  static Screen + #739, #3967
  static Screen + #740, #3967
  static Screen + #741, #3
  static Screen + #742, #3
  static Screen + #743, #3
  static Screen + #744, #0
  static Screen + #745, #3967
  static Screen + #746, #3967
  static Screen + #747, #3967
  static Screen + #748, #3967
  static Screen + #749, #3967
  static Screen + #750, #3967
  static Screen + #751, #3967
  static Screen + #752, #3967
  static Screen + #753, #3967
  static Screen + #754, #3
  static Screen + #755, #3
  static Screen + #756, #3
  static Screen + #757, #0
  static Screen + #758, #3967
  static Screen + #759, #3967

  ;Linha 19
  static Screen + #760, #3967
  static Screen + #761, #3967
  static Screen + #762, #3967
  static Screen + #763, #3967
  static Screen + #764, #0
  static Screen + #765, #3
  static Screen + #766, #3967
  static Screen + #767, #3967
  static Screen + #768, #3967
  static Screen + #769, #3967
  static Screen + #770, #3967
  static Screen + #771, #3967
  static Screen + #772, #3967
  static Screen + #773, #3967
  static Screen + #774, #3967
  static Screen + #775, #3967
  static Screen + #776, #3967
  static Screen + #777, #3967
  static Screen + #778, #0
  static Screen + #779, #3967
  static Screen + #780, #3967
  static Screen + #781, #3
  static Screen + #782, #3
  static Screen + #783, #3
  static Screen + #784, #0
  static Screen + #785, #3967
  static Screen + #786, #3967
  static Screen + #787, #3967
  static Screen + #788, #3967
  static Screen + #789, #3967
  static Screen + #790, #3967
  static Screen + #791, #3967
  static Screen + #792, #3967
  static Screen + #793, #3
  static Screen + #794, #3
  static Screen + #795, #3
  static Screen + #796, #3
  static Screen + #797, #0
  static Screen + #798, #3967
  static Screen + #799, #3967

  ;Linha 20
  static Screen + #800, #3967
  static Screen + #801, #3967
  static Screen + #802, #3967
  static Screen + #803, #3967
  static Screen + #804, #0
  static Screen + #805, #3967
  static Screen + #806, #3967
  static Screen + #807, #3967
  static Screen + #808, #3967
  static Screen + #809, #3967
  static Screen + #810, #3967
  static Screen + #811, #3967
  static Screen + #812, #3967
  static Screen + #813, #3967
  static Screen + #814, #3967
  static Screen + #815, #3967
  static Screen + #816, #3967
  static Screen + #817, #3967
  static Screen + #818, #0
  static Screen + #819, #3967
  static Screen + #820, #3967
  static Screen + #821, #3967
  static Screen + #822, #3
  static Screen + #823, #3
  static Screen + #824, #0
  static Screen + #825, #3967
  static Screen + #826, #3967
  static Screen + #827, #3967
  static Screen + #828, #3967
  static Screen + #829, #3967
  static Screen + #830, #3967
  static Screen + #831, #3967
  static Screen + #832, #3967
  static Screen + #833, #3
  static Screen + #834, #3
  static Screen + #835, #3
  static Screen + #836, #3
  static Screen + #837, #0
  static Screen + #838, #3967
  static Screen + #839, #3967

  ;Linha 21
  static Screen + #840, #3967
  static Screen + #841, #3967
  static Screen + #842, #3967
  static Screen + #843, #3967
  static Screen + #844, #0
  static Screen + #845, #3967
  static Screen + #846, #3967
  static Screen + #847, #3967
  static Screen + #848, #3967
  static Screen + #849, #3967
  static Screen + #850, #3967
  static Screen + #851, #3967
  static Screen + #852, #3967
  static Screen + #853, #3967
  static Screen + #854, #3967
  static Screen + #855, #3967
  static Screen + #856, #3967
  static Screen + #857, #3967
  static Screen + #858, #0
  static Screen + #859, #3967
  static Screen + #860, #3967
  static Screen + #861, #3967
  static Screen + #862, #3
  static Screen + #863, #3967
  static Screen + #864, #0
  static Screen + #865, #3967
  static Screen + #866, #3967
  static Screen + #867, #3967
  static Screen + #868, #3967
  static Screen + #869, #3967
  static Screen + #870, #3967
  static Screen + #871, #3967
  static Screen + #872, #3967
  static Screen + #873, #3967
  static Screen + #874, #3967
  static Screen + #875, #3
  static Screen + #876, #3
  static Screen + #877, #0
  static Screen + #878, #3967
  static Screen + #879, #3967

  ;Linha 22
  static Screen + #880, #3967
  static Screen + #881, #3967
  static Screen + #882, #3967
  static Screen + #883, #3967
  static Screen + #884, #0
  static Screen + #885, #3967
  static Screen + #886, #3967
  static Screen + #887, #3967
  static Screen + #888, #3967
  static Screen + #889, #3967
  static Screen + #890, #3967
  static Screen + #891, #3967
  static Screen + #892, #3967
  static Screen + #893, #3967
  static Screen + #894, #3967
  static Screen + #895, #3967
  static Screen + #896, #3967
  static Screen + #897, #3967
  static Screen + #898, #0
  static Screen + #899, #3967
  static Screen + #900, #3967
  static Screen + #901, #3967
  static Screen + #902, #3
  static Screen + #903, #3967
  static Screen + #904, #0
  static Screen + #905, #3
  static Screen + #906, #3
  static Screen + #907, #3
  static Screen + #908, #3
  static Screen + #909, #3
  static Screen + #910, #3
  static Screen + #911, #3
  static Screen + #912, #3
  static Screen + #913, #3
  static Screen + #914, #3
  static Screen + #915, #3
  static Screen + #916, #3
  static Screen + #917, #0
  static Screen + #918, #3967
  static Screen + #919, #3967

  ;Linha 23
  static Screen + #920, #3967
  static Screen + #921, #0
  static Screen + #922, #0
  static Screen + #923, #0
  static Screen + #924, #0
  static Screen + #925, #0
  static Screen + #926, #0
  static Screen + #927, #0
  static Screen + #928, #0
  static Screen + #929, #0
  static Screen + #930, #0
  static Screen + #931, #0
  static Screen + #932, #0
  static Screen + #933, #0
  static Screen + #934, #0
  static Screen + #935, #0
  static Screen + #936, #0
  static Screen + #937, #0
  static Screen + #938, #0
  static Screen + #939, #0
  static Screen + #940, #0
  static Screen + #941, #0
  static Screen + #942, #0
  static Screen + #943, #0
  static Screen + #944, #0
  static Screen + #945, #0
  static Screen + #946, #0
  static Screen + #947, #0
  static Screen + #948, #0
  static Screen + #949, #0
  static Screen + #950, #0
  static Screen + #951, #0
  static Screen + #952, #0
  static Screen + #953, #0
  static Screen + #954, #0
  static Screen + #955, #0
  static Screen + #956, #0
  static Screen + #957, #0
  static Screen + #958, #0
  static Screen + #959, #0

  ;Linha 24
  static Screen + #960, #3967
  static Screen + #961, #3967
  static Screen + #962, #3967
  static Screen + #963, #3967
  static Screen + #964, #2
  static Screen + #965, #2
  static Screen + #966, #3967
  static Screen + #967, #3967
  static Screen + #968, #3967
  static Screen + #969, #3967
  static Screen + #970, #3967
  static Screen + #971, #3967
  static Screen + #972, #3967
  static Screen + #973, #3967
  static Screen + #974, #3967
  static Screen + #975, #3967
  static Screen + #976, #3967
  static Screen + #977, #3967
  static Screen + #978, #3967
  static Screen + #979, #3967
  static Screen + #980, #3967
  static Screen + #981, #3967
  static Screen + #982, #3
  static Screen + #983, #3
  static Screen + #984, #3967
  static Screen + #985, #3967
  static Screen + #986, #3967
  static Screen + #987, #3967
  static Screen + #988, #3967
  static Screen + #989, #3967
  static Screen + #990, #3967
  static Screen + #991, #3967
  static Screen + #992, #3967
  static Screen + #993, #3967
  static Screen + #994, #3967
  static Screen + #995, #3
  static Screen + #996, #3967
  static Screen + #997, #2
  static Screen + #998, #3967
  static Screen + #999, #3967

  ;Linha 25
  static Screen + #1000, #3967
  static Screen + #1001, #3967
  static Screen + #1002, #3967
  static Screen + #1003, #3967
  static Screen + #1004, #3967
  static Screen + #1005, #2
  static Screen + #1006, #2
  static Screen + #1007, #3967
  static Screen + #1008, #3967
  static Screen + #1009, #3967
  static Screen + #1010, #3967
  static Screen + #1011, #3967
  static Screen + #1012, #3967
  static Screen + #1013, #3967
  static Screen + #1014, #3967
  static Screen + #1015, #3967
  static Screen + #1016, #3967
  static Screen + #1017, #3967
  static Screen + #1018, #3967
  static Screen + #1019, #3967
  static Screen + #1020, #3967
  static Screen + #1021, #3967
  static Screen + #1022, #3967
  static Screen + #1023, #3967
  static Screen + #1024, #3967
  static Screen + #1025, #3967
  static Screen + #1026, #3967
  static Screen + #1027, #3967
  static Screen + #1028, #3967
  static Screen + #1029, #3967
  static Screen + #1030, #3967
  static Screen + #1031, #3967
  static Screen + #1032, #3967
  static Screen + #1033, #3967
  static Screen + #1034, #3967
  static Screen + #1035, #2
  static Screen + #1036, #2
  static Screen + #1037, #2
  static Screen + #1038, #3967
  static Screen + #1039, #3967

  ;Linha 26
  static Screen + #1040, #3967
  static Screen + #1041, #3967
  static Screen + #1042, #3967
  static Screen + #1043, #3967
  static Screen + #1044, #3967
  static Screen + #1045, #3967
  static Screen + #1046, #2
  static Screen + #1047, #2
  static Screen + #1048, #2
  static Screen + #1049, #3967
  static Screen + #1050, #3967
  static Screen + #1051, #3967
  static Screen + #1052, #3967
  static Screen + #1053, #3967
  static Screen + #1054, #3967
  static Screen + #1055, #3967
  static Screen + #1056, #3967
  static Screen + #1057, #3967
  static Screen + #1058, #3967
  static Screen + #1059, #3967
  static Screen + #1060, #3967
  static Screen + #1061, #3967
  static Screen + #1062, #3967
  static Screen + #1063, #3967
  static Screen + #1064, #3967
  static Screen + #1065, #3967
  static Screen + #1066, #3967
  static Screen + #1067, #3967
  static Screen + #1068, #3967
  static Screen + #1069, #3967
  static Screen + #1070, #3967
  static Screen + #1071, #3967
  static Screen + #1072, #3967
  static Screen + #1073, #3967
  static Screen + #1074, #2
  static Screen + #1075, #2
  static Screen + #1076, #3967
  static Screen + #1077, #3967
  static Screen + #1078, #3967
  static Screen + #1079, #3967

  ;Linha 27
  static Screen + #1080, #3967
  static Screen + #1081, #3967
  static Screen + #1082, #3967
  static Screen + #1083, #3967
  static Screen + #1084, #3967
  static Screen + #1085, #3967
  static Screen + #1086, #3967
  static Screen + #1087, #3967
  static Screen + #1088, #2
  static Screen + #1089, #2
  static Screen + #1090, #2
  static Screen + #1091, #2
  static Screen + #1092, #2
  static Screen + #1093, #2
  static Screen + #1094, #2
  static Screen + #1095, #2
  static Screen + #1096, #2
  static Screen + #1097, #2
  static Screen + #1098, #2
  static Screen + #1099, #2
  static Screen + #1100, #3967
  static Screen + #1101, #2
  static Screen + #1102, #2
  static Screen + #1103, #2
  static Screen + #1104, #2
  static Screen + #1105, #2
  static Screen + #1106, #2
  static Screen + #1107, #2
  static Screen + #1108, #2
  static Screen + #1109, #2
  static Screen + #1110, #2
  static Screen + #1111, #2
  static Screen + #1112, #2
  static Screen + #1113, #2
  static Screen + #1114, #2
  static Screen + #1115, #3967
  static Screen + #1116, #3967
  static Screen + #1117, #3967
  static Screen + #1118, #3967
  static Screen + #1119, #3967

  ;Linha 28
  static Screen + #1120, #3967
  static Screen + #1121, #3967
  static Screen + #1122, #3967
  static Screen + #1123, #3967
  static Screen + #1124, #3967
  static Screen + #1125, #3967
  static Screen + #1126, #3967
  static Screen + #1127, #3967
  static Screen + #1128, #3967
  static Screen + #1129, #3967
  static Screen + #1130, #3967
  static Screen + #1131, #3967
  static Screen + #1132, #3967
  static Screen + #1133, #3967
  static Screen + #1134, #3967
  static Screen + #1135, #3967
  static Screen + #1136, #3967
  static Screen + #1137, #3967
  static Screen + #1138, #3967
  static Screen + #1139, #2
  static Screen + #1140, #2
  static Screen + #1141, #2
  static Screen + #1142, #3967
  static Screen + #1143, #3967
  static Screen + #1144, #3967
  static Screen + #1145, #3967
  static Screen + #1146, #3967
  static Screen + #1147, #3967
  static Screen + #1148, #3967
  static Screen + #1149, #3967
  static Screen + #1150, #3967
  static Screen + #1151, #3967
  static Screen + #1152, #3967
  static Screen + #1153, #3967
  static Screen + #1154, #3967
  static Screen + #1155, #3967
  static Screen + #1156, #3967
  static Screen + #1157, #3967
  static Screen + #1158, #3967
  static Screen + #1159, #3967

  ;Linha 29
  static Screen + #1160, #3967
  static Screen + #1161, #3967
  static Screen + #1162, #3967
  static Screen + #1163, #3967
  static Screen + #1164, #3967
  static Screen + #1165, #3967
  static Screen + #1166, #3967
  static Screen + #1167, #3967
  static Screen + #1168, #3967
  static Screen + #1169, #3967
  static Screen + #1170, #3967
  static Screen + #1171, #3967
  static Screen + #1172, #3967
  static Screen + #1173, #3967
  static Screen + #1174, #3967
  static Screen + #1175, #3967
  static Screen + #1176, #3967
  static Screen + #1177, #3967
  static Screen + #1178, #3967
  static Screen + #1179, #3967
  static Screen + #1180, #3967
  static Screen + #1181, #3967
  static Screen + #1182, #3967
  static Screen + #1183, #3967
  static Screen + #1184, #3967
  static Screen + #1185, #3967
  static Screen + #1186, #3967
  static Screen + #1187, #3967
  static Screen + #1188, #3967
  static Screen + #1189, #3967
  static Screen + #1190, #3967
  static Screen + #1191, #3967
  static Screen + #1192, #3967
  static Screen + #1193, #3967
  static Screen + #1194, #3967
  static Screen + #1195, #3967
  static Screen + #1196, #3967
  static Screen + #1197, #3967
  static Screen + #1198, #3967
  static Screen + #1199, #3967

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
  static fase1 + #41, #3967
  static fase1 + #42, #3967
  static fase1 + #43, #3967
  static fase1 + #44, #3967
  static fase1 + #45, #3967
  static fase1 + #46, #0
  static fase1 + #47, #3967
  static fase1 + #48, #3967
  static fase1 + #49, #3967
  static fase1 + #50, #3967
  static fase1 + #51, #3967
  static fase1 + #52, #3967
  static fase1 + #53, #3967
  static fase1 + #54, #0
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
  static fase1 + #67, #0
  static fase1 + #68, #3967
  static fase1 + #69, #3967
  static fase1 + #70, #3967
  static fase1 + #71, #3967
  static fase1 + #72, #3967
  static fase1 + #73, #3967
  static fase1 + #74, #3967
  static fase1 + #75, #3967
  static fase1 + #76, #127
  static fase1 + #77, #127
  static fase1 + #78, #127
  static fase1 + #79, #0

  ;Linha 2
  static fase1 + #80, #0
  static fase1 + #81, #3967
  static fase1 + #82, #0
  static fase1 + #83, #0
  static fase1 + #84, #3
  static fase1 + #85, #0
  static fase1 + #86, #0
  static fase1 + #87, #3967
  static fase1 + #88, #3967
  static fase1 + #89, #0
  static fase1 + #90, #0
  static fase1 + #91, #0
  static fase1 + #92, #3967
  static fase1 + #93, #3967
  static fase1 + #94, #0
  static fase1 + #95, #0
  static fase1 + #96, #0
  static fase1 + #97, #0
  static fase1 + #98, #3967
  static fase1 + #99, #3967
  static fase1 + #100, #0
  static fase1 + #101, #0
  static fase1 + #102, #0
  static fase1 + #103, #0
  static fase1 + #104, #0
  static fase1 + #105, #0
  static fase1 + #106, #0
  static fase1 + #107, #0
  static fase1 + #108, #3967
  static fase1 + #109, #3967
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
  static fase1 + #124, #3967
  static fase1 + #125, #3967
  static fase1 + #126, #0
  static fase1 + #127, #3967
  static fase1 + #128, #3967
  static fase1 + #129, #0
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
  static fase1 + #140, #0
  static fase1 + #141, #127
  static fase1 + #142, #127
  static fase1 + #143, #127
  static fase1 + #144, #127
  static fase1 + #145, #127
  static fase1 + #146, #127
  static fase1 + #147, #127
  static fase1 + #148, #3967
  static fase1 + #149, #3967
  static fase1 + #150, #3967
  static fase1 + #151, #3967
  static fase1 + #152, #3967
  static fase1 + #153, #3967
  static fase1 + #154, #3967
  static fase1 + #155, #3967
  static fase1 + #156, #3967
  static fase1 + #157, #0
  static fase1 + #158, #3967
  static fase1 + #159, #0

  ;Linha 4
  static fase1 + #160, #0
  static fase1 + #161, #3967
  static fase1 + #162, #0
  static fase1 + #163, #0
  static fase1 + #164, #0
  static fase1 + #165, #0
  static fase1 + #166, #0
  static fase1 + #167, #127
  static fase1 + #168, #3967
  static fase1 + #169, #0
  static fase1 + #170, #0
  static fase1 + #171, #0
  static fase1 + #172, #0
  static fase1 + #173, #0
  static fase1 + #174, #3967
  static fase1 + #175, #0
  static fase1 + #176, #3967
  static fase1 + #177, #3967
  static fase1 + #178, #3967
  static fase1 + #179, #127
  static fase1 + #180, #0
  static fase1 + #181, #0
  static fase1 + #182, #0
  static fase1 + #183, #0
  static fase1 + #184, #0
  static fase1 + #185, #0
  static fase1 + #186, #0
  static fase1 + #187, #0
  static fase1 + #188, #0
  static fase1 + #189, #0
  static fase1 + #190, #0
  static fase1 + #191, #0
  static fase1 + #192, #0
  static fase1 + #193, #0
  static fase1 + #194, #0
  static fase1 + #195, #0
  static fase1 + #196, #0
  static fase1 + #197, #0
  static fase1 + #198, #3967
  static fase1 + #199, #0

  ;Linha 5
  static fase1 + #200, #0
  static fase1 + #201, #2
  static fase1 + #202, #3967
  static fase1 + #203, #3967
  static fase1 + #204, #3967
  static fase1 + #205, #0
  static fase1 + #206, #3967
  static fase1 + #207, #3967
  static fase1 + #208, #3967
  static fase1 + #209, #0
  static fase1 + #210, #3967
  static fase1 + #211, #3967
  static fase1 + #212, #3967
  static fase1 + #213, #0
  static fase1 + #214, #3967
  static fase1 + #215, #0
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
  static fase1 + #227, #0
  static fase1 + #228, #3967
  static fase1 + #229, #3967
  static fase1 + #230, #3
  static fase1 + #231, #3967
  static fase1 + #232, #3967
  static fase1 + #233, #0
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
  static fase1 + #243, #3967
  static fase1 + #244, #0
  static fase1 + #245, #0
  static fase1 + #246, #3967
  static fase1 + #247, #3967
  static fase1 + #248, #0
  static fase1 + #249, #0
  static fase1 + #250, #3967
  static fase1 + #251, #0
  static fase1 + #252, #0
  static fase1 + #253, #0
  static fase1 + #254, #3967
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
  static fase1 + #267, #0
  static fase1 + #268, #3967
  static fase1 + #269, #3967
  static fase1 + #270, #0
  static fase1 + #271, #3967
  static fase1 + #272, #3967
  static fase1 + #273, #0
  static fase1 + #274, #3967
  static fase1 + #275, #127
  static fase1 + #276, #3967
  static fase1 + #277, #0
  static fase1 + #278, #3967
  static fase1 + #279, #0

  ;Linha 7
  static fase1 + #280, #0
  static fase1 + #281, #3967
  static fase1 + #282, #0
  static fase1 + #283, #3967
  static fase1 + #284, #0
  static fase1 + #285, #3967
  static fase1 + #286, #3967
  static fase1 + #287, #3967
  static fase1 + #288, #3967
  static fase1 + #289, #3967
  static fase1 + #290, #3967
  static fase1 + #291, #0
  static fase1 + #292, #3967
  static fase1 + #293, #3967
  static fase1 + #294, #3
  static fase1 + #295, #3967
  static fase1 + #296, #3967
  static fase1 + #297, #3967
  static fase1 + #298, #0
  static fase1 + #299, #3967
  static fase1 + #300, #3967
  static fase1 + #301, #3967
  static fase1 + #302, #3967
  static fase1 + #303, #3967
  static fase1 + #304, #3967
  static fase1 + #305, #3967
  static fase1 + #306, #3967
  static fase1 + #307, #0
  static fase1 + #308, #3967
  static fase1 + #309, #3967
  static fase1 + #310, #0
  static fase1 + #311, #127
  static fase1 + #312, #3967
  static fase1 + #313, #0
  static fase1 + #314, #3967
  static fase1 + #315, #127
  static fase1 + #316, #3967
  static fase1 + #317, #0
  static fase1 + #318, #127
  static fase1 + #319, #0

  ;Linha 8
  static fase1 + #320, #0
  static fase1 + #321, #3967
  static fase1 + #322, #0
  static fase1 + #323, #3967
  static fase1 + #324, #0
  static fase1 + #325, #3967
  static fase1 + #326, #0
  static fase1 + #327, #3967
  static fase1 + #328, #0
  static fase1 + #329, #0
  static fase1 + #330, #0
  static fase1 + #331, #0
  static fase1 + #332, #0
  static fase1 + #333, #0
  static fase1 + #334, #0
  static fase1 + #335, #0
  static fase1 + #336, #0
  static fase1 + #337, #0
  static fase1 + #338, #0
  static fase1 + #339, #3967
  static fase1 + #340, #3967
  static fase1 + #341, #0
  static fase1 + #342, #0
  static fase1 + #343, #0
  static fase1 + #344, #0
  static fase1 + #345, #0
  static fase1 + #346, #0
  static fase1 + #347, #0
  static fase1 + #348, #3967
  static fase1 + #349, #3967
  static fase1 + #350, #0
  static fase1 + #351, #127
  static fase1 + #352, #3967
  static fase1 + #353, #3967
  static fase1 + #354, #3967
  static fase1 + #355, #127
  static fase1 + #356, #3967
  static fase1 + #357, #0
  static fase1 + #358, #127
  static fase1 + #359, #0

  ;Linha 9
  static fase1 + #360, #0
  static fase1 + #361, #3967
  static fase1 + #362, #0
  static fase1 + #363, #3967
  static fase1 + #364, #0
  static fase1 + #365, #3967
  static fase1 + #366, #0
  static fase1 + #367, #3967
  static fase1 + #368, #0
  static fase1 + #369, #3967
  static fase1 + #370, #3967
  static fase1 + #371, #3967
  static fase1 + #372, #3967
  static fase1 + #373, #3967
  static fase1 + #374, #0
  static fase1 + #375, #3967
  static fase1 + #376, #3967
  static fase1 + #377, #127
  static fase1 + #378, #127
  static fase1 + #379, #3967
  static fase1 + #380, #3967
  static fase1 + #381, #0
  static fase1 + #382, #0
  static fase1 + #383, #3967
  static fase1 + #384, #3967
  static fase1 + #385, #0
  static fase1 + #386, #3967
  static fase1 + #387, #3967
  static fase1 + #388, #3967
  static fase1 + #389, #3967
  static fase1 + #390, #0
  static fase1 + #391, #0
  static fase1 + #392, #0
  static fase1 + #393, #0
  static fase1 + #394, #0
  static fase1 + #395, #0
  static fase1 + #396, #0
  static fase1 + #397, #0
  static fase1 + #398, #127
  static fase1 + #399, #0

  ;Linha 10
  static fase1 + #400, #0
  static fase1 + #401, #3967
  static fase1 + #402, #0
  static fase1 + #403, #3967
  static fase1 + #404, #0
  static fase1 + #405, #3967
  static fase1 + #406, #0
  static fase1 + #407, #3967
  static fase1 + #408, #0
  static fase1 + #409, #3967
  static fase1 + #410, #0
  static fase1 + #411, #0
  static fase1 + #412, #0
  static fase1 + #413, #3967
  static fase1 + #414, #0
  static fase1 + #415, #3967
  static fase1 + #416, #3967
  static fase1 + #417, #3967
  static fase1 + #418, #3967
  static fase1 + #419, #0
  static fase1 + #420, #0
  static fase1 + #421, #0
  static fase1 + #422, #0
  static fase1 + #423, #3967
  static fase1 + #424, #3967
  static fase1 + #425, #0
  static fase1 + #426, #0
  static fase1 + #427, #0
  static fase1 + #428, #3967
  static fase1 + #429, #3967
  static fase1 + #430, #0
  static fase1 + #431, #3967
  static fase1 + #432, #3967
  static fase1 + #433, #127
  static fase1 + #434, #3967
  static fase1 + #435, #3967
  static fase1 + #436, #3967
  static fase1 + #437, #0
  static fase1 + #438, #3967
  static fase1 + #439, #0

  ;Linha 11
  static fase1 + #440, #0
  static fase1 + #441, #3967
  static fase1 + #442, #0
  static fase1 + #443, #3967
  static fase1 + #444, #0
  static fase1 + #445, #0
  static fase1 + #446, #0
  static fase1 + #447, #3
  static fase1 + #448, #0
  static fase1 + #449, #3967
  static fase1 + #450, #0
  static fase1 + #451, #3967
  static fase1 + #452, #0
  static fase1 + #453, #3967
  static fase1 + #454, #0
  static fase1 + #455, #3967
  static fase1 + #456, #0
  static fase1 + #457, #0
  static fase1 + #458, #0
  static fase1 + #459, #0
  static fase1 + #460, #3967
  static fase1 + #461, #3967
  static fase1 + #462, #0
  static fase1 + #463, #3967
  static fase1 + #464, #3967
  static fase1 + #465, #3967
  static fase1 + #466, #3967
  static fase1 + #467, #3967
  static fase1 + #468, #3967
  static fase1 + #469, #3967
  static fase1 + #470, #0
  static fase1 + #471, #3967
  static fase1 + #472, #3967
  static fase1 + #473, #0
  static fase1 + #474, #3967
  static fase1 + #475, #3967
  static fase1 + #476, #3967
  static fase1 + #477, #0
  static fase1 + #478, #0
  static fase1 + #479, #0

  ;Linha 12
  static fase1 + #480, #0
  static fase1 + #481, #3967
  static fase1 + #482, #0
  static fase1 + #483, #3967
  static fase1 + #484, #3967
  static fase1 + #485, #3967
  static fase1 + #486, #0
  static fase1 + #487, #3967
  static fase1 + #488, #0
  static fase1 + #489, #3967
  static fase1 + #490, #0
  static fase1 + #491, #3967
  static fase1 + #492, #0
  static fase1 + #493, #3967
  static fase1 + #494, #0
  static fase1 + #495, #3967
  static fase1 + #496, #0
  static fase1 + #497, #3967
  static fase1 + #498, #3967
  static fase1 + #499, #3967
  static fase1 + #500, #3967
  static fase1 + #501, #3967
  static fase1 + #502, #0
  static fase1 + #503, #0
  static fase1 + #504, #0
  static fase1 + #505, #0
  static fase1 + #506, #0
  static fase1 + #507, #0
  static fase1 + #508, #3967
  static fase1 + #509, #3967
  static fase1 + #510, #0
  static fase1 + #511, #3967
  static fase1 + #512, #3967
  static fase1 + #513, #0
  static fase1 + #514, #3967
  static fase1 + #515, #0
  static fase1 + #516, #3967
  static fase1 + #517, #0
  static fase1 + #518, #3967
  static fase1 + #519, #0

  ;Linha 13
  static fase1 + #520, #0
  static fase1 + #521, #0
  static fase1 + #522, #0
  static fase1 + #523, #3967
  static fase1 + #524, #0
  static fase1 + #525, #3967
  static fase1 + #526, #0
  static fase1 + #527, #3967
  static fase1 + #528, #0
  static fase1 + #529, #3967
  static fase1 + #530, #0
  static fase1 + #531, #3967
  static fase1 + #532, #0
  static fase1 + #533, #3967
  static fase1 + #534, #0
  static fase1 + #535, #3967
  static fase1 + #536, #0
  static fase1 + #537, #3967
  static fase1 + #538, #0
  static fase1 + #539, #3967
  static fase1 + #540, #3967
  static fase1 + #541, #3967
  static fase1 + #542, #0
  static fase1 + #543, #3967
  static fase1 + #544, #3967
  static fase1 + #545, #3967
  static fase1 + #546, #3967
  static fase1 + #547, #3967
  static fase1 + #548, #3967
  static fase1 + #549, #3967
  static fase1 + #550, #3
  static fase1 + #551, #3967
  static fase1 + #552, #3967
  static fase1 + #553, #0
  static fase1 + #554, #3967
  static fase1 + #555, #0
  static fase1 + #556, #3967
  static fase1 + #557, #0
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
  static fase1 + #567, #3967
  static fase1 + #568, #0
  static fase1 + #569, #127
  static fase1 + #570, #0
  static fase1 + #571, #3967
  static fase1 + #572, #0
  static fase1 + #573, #3967
  static fase1 + #574, #3967
  static fase1 + #575, #3967
  static fase1 + #576, #0
  static fase1 + #577, #3967
  static fase1 + #578, #0
  static fase1 + #579, #3967
  static fase1 + #580, #0
  static fase1 + #581, #3967
  static fase1 + #582, #0
  static fase1 + #583, #3967
  static fase1 + #584, #3967
  static fase1 + #585, #3967
  static fase1 + #586, #127
  static fase1 + #587, #0
  static fase1 + #588, #3967
  static fase1 + #589, #3967
  static fase1 + #590, #0
  static fase1 + #591, #0
  static fase1 + #592, #0
  static fase1 + #593, #0
  static fase1 + #594, #3967
  static fase1 + #595, #0
  static fase1 + #596, #3967
  static fase1 + #597, #0
  static fase1 + #598, #3967
  static fase1 + #599, #0

  ;Linha 15
  static fase1 + #600, #0
  static fase1 + #601, #3967
  static fase1 + #602, #0
  static fase1 + #603, #3967
  static fase1 + #604, #0
  static fase1 + #605, #3967
  static fase1 + #606, #3967
  static fase1 + #607, #3967
  static fase1 + #608, #0
  static fase1 + #609, #3967
  static fase1 + #610, #0
  static fase1 + #611, #3967
  static fase1 + #612, #3967
  static fase1 + #613, #3967
  static fase1 + #614, #3967
  static fase1 + #615, #3967
  static fase1 + #616, #0
  static fase1 + #617, #3967
  static fase1 + #618, #0
  static fase1 + #619, #3967
  static fase1 + #620, #0
  static fase1 + #621, #3967
  static fase1 + #622, #3967
  static fase1 + #623, #3967
  static fase1 + #624, #3967
  static fase1 + #625, #3967
  static fase1 + #626, #127
  static fase1 + #627, #0
  static fase1 + #628, #3967
  static fase1 + #629, #3967
  static fase1 + #630, #0
  static fase1 + #631, #3967
  static fase1 + #632, #3967
  static fase1 + #633, #3
  static fase1 + #634, #3967
  static fase1 + #635, #0
  static fase1 + #636, #3967
  static fase1 + #637, #3967
  static fase1 + #638, #3967
  static fase1 + #639, #0

  ;Linha 16
  static fase1 + #640, #0
  static fase1 + #641, #3967
  static fase1 + #642, #0
  static fase1 + #643, #0
  static fase1 + #644, #0
  static fase1 + #645, #3967
  static fase1 + #646, #0
  static fase1 + #647, #0
  static fase1 + #648, #0
  static fase1 + #649, #3
  static fase1 + #650, #0
  static fase1 + #651, #3840
  static fase1 + #652, #0
  static fase1 + #653, #0
  static fase1 + #654, #0
  static fase1 + #655, #0
  static fase1 + #656, #0
  static fase1 + #657, #3967
  static fase1 + #658, #0
  static fase1 + #659, #3967
  static fase1 + #660, #0
  static fase1 + #661, #0
  static fase1 + #662, #0
  static fase1 + #663, #0
  static fase1 + #664, #0
  static fase1 + #665, #0
  static fase1 + #666, #0
  static fase1 + #667, #0
  static fase1 + #668, #3967
  static fase1 + #669, #3967
  static fase1 + #670, #0
  static fase1 + #671, #3967
  static fase1 + #672, #3967
  static fase1 + #673, #3967
  static fase1 + #674, #0
  static fase1 + #675, #0
  static fase1 + #676, #0
  static fase1 + #677, #0
  static fase1 + #678, #3967
  static fase1 + #679, #0

  ;Linha 17
  static fase1 + #680, #0
  static fase1 + #681, #3967
  static fase1 + #682, #3967
  static fase1 + #683, #3967
  static fase1 + #684, #3967
  static fase1 + #685, #3967
  static fase1 + #686, #3967
  static fase1 + #687, #127
  static fase1 + #688, #0
  static fase1 + #689, #3967
  static fase1 + #690, #0
  static fase1 + #691, #3967
  static fase1 + #692, #127
  static fase1 + #693, #3967
  static fase1 + #694, #0
  static fase1 + #695, #3967
  static fase1 + #696, #0
  static fase1 + #697, #3967
  static fase1 + #698, #0
  static fase1 + #699, #3967
  static fase1 + #700, #0
  static fase1 + #701, #3967
  static fase1 + #702, #3967
  static fase1 + #703, #3967
  static fase1 + #704, #3967
  static fase1 + #705, #3967
  static fase1 + #706, #127
  static fase1 + #707, #0
  static fase1 + #708, #3967
  static fase1 + #709, #3967
  static fase1 + #710, #0
  static fase1 + #711, #3967
  static fase1 + #712, #3967
  static fase1 + #713, #3967
  static fase1 + #714, #0
  static fase1 + #715, #514
  static fase1 + #716, #127
  static fase1 + #717, #0
  static fase1 + #718, #3967
  static fase1 + #719, #0

  ;Linha 18
  static fase1 + #720, #0
  static fase1 + #721, #3967
  static fase1 + #722, #3967
  static fase1 + #723, #3967
  static fase1 + #724, #3967
  static fase1 + #725, #3967
  static fase1 + #726, #3967
  static fase1 + #727, #127
  static fase1 + #728, #0
  static fase1 + #729, #3967
  static fase1 + #730, #0
  static fase1 + #731, #127
  static fase1 + #732, #127
  static fase1 + #733, #127
  static fase1 + #734, #0
  static fase1 + #735, #3967
  static fase1 + #736, #0
  static fase1 + #737, #3967
  static fase1 + #738, #0
  static fase1 + #739, #3967
  static fase1 + #740, #0
  static fase1 + #741, #3967
  static fase1 + #742, #3967
  static fase1 + #743, #3967
  static fase1 + #744, #3967
  static fase1 + #745, #3967
  static fase1 + #746, #3967
  static fase1 + #747, #3967
  static fase1 + #748, #3967
  static fase1 + #749, #3967
  static fase1 + #750, #0
  static fase1 + #751, #3967
  static fase1 + #752, #3967
  static fase1 + #753, #3967
  static fase1 + #754, #0
  static fase1 + #755, #127
  static fase1 + #756, #127
  static fase1 + #757, #0
  static fase1 + #758, #3967
  static fase1 + #759, #0

  ;Linha 19
  static fase1 + #760, #0
  static fase1 + #761, #3967
  static fase1 + #762, #0
  static fase1 + #763, #0
  static fase1 + #764, #0
  static fase1 + #765, #0
  static fase1 + #766, #0
  static fase1 + #767, #0
  static fase1 + #768, #0
  static fase1 + #769, #127
  static fase1 + #770, #0
  static fase1 + #771, #127
  static fase1 + #772, #127
  static fase1 + #773, #0
  static fase1 + #774, #0
  static fase1 + #775, #3967
  static fase1 + #776, #0
  static fase1 + #777, #0
  static fase1 + #778, #0
  static fase1 + #779, #0
  static fase1 + #780, #0
  static fase1 + #781, #3967
  static fase1 + #782, #3967
  static fase1 + #783, #0
  static fase1 + #784, #0
  static fase1 + #785, #0
  static fase1 + #786, #0
  static fase1 + #787, #0
  static fase1 + #788, #127
  static fase1 + #789, #127
  static fase1 + #790, #0
  static fase1 + #791, #3967
  static fase1 + #792, #3967
  static fase1 + #793, #3967
  static fase1 + #794, #0
  static fase1 + #795, #127
  static fase1 + #796, #3967
  static fase1 + #797, #0
  static fase1 + #798, #3967
  static fase1 + #799, #0

  ;Linha 20
  static fase1 + #800, #0
  static fase1 + #801, #0
  static fase1 + #802, #0
  static fase1 + #803, #3967
  static fase1 + #804, #3967
  static fase1 + #805, #3967
  static fase1 + #806, #3967
  static fase1 + #807, #3967
  static fase1 + #808, #0
  static fase1 + #809, #127
  static fase1 + #810, #0
  static fase1 + #811, #0
  static fase1 + #812, #0
  static fase1 + #813, #0
  static fase1 + #814, #3967
  static fase1 + #815, #3967
  static fase1 + #816, #0
  static fase1 + #817, #3967
  static fase1 + #818, #0
  static fase1 + #819, #3967
  static fase1 + #820, #3967
  static fase1 + #821, #3967
  static fase1 + #822, #3967
  static fase1 + #823, #0
  static fase1 + #824, #3967
  static fase1 + #825, #0
  static fase1 + #826, #3967
  static fase1 + #827, #3967
  static fase1 + #828, #3967
  static fase1 + #829, #3967
  static fase1 + #830, #0
  static fase1 + #831, #3967
  static fase1 + #832, #3967
  static fase1 + #833, #3967
  static fase1 + #834, #0
  static fase1 + #835, #3967
  static fase1 + #836, #3967
  static fase1 + #837, #0
  static fase1 + #838, #3967
  static fase1 + #839, #0

  ;Linha 21
  static fase1 + #840, #0
  static fase1 + #841, #3967
  static fase1 + #842, #3967
  static fase1 + #843, #3967
  static fase1 + #844, #0
  static fase1 + #845, #0
  static fase1 + #846, #0
  static fase1 + #847, #3967
  static fase1 + #848, #0
  static fase1 + #849, #3967
  static fase1 + #850, #3967
  static fase1 + #851, #3967
  static fase1 + #852, #127
  static fase1 + #853, #0
  static fase1 + #854, #3967
  static fase1 + #855, #0
  static fase1 + #856, #0
  static fase1 + #857, #127
  static fase1 + #858, #0
  static fase1 + #859, #3967
  static fase1 + #860, #3967
  static fase1 + #861, #3967
  static fase1 + #862, #3967
  static fase1 + #863, #0
  static fase1 + #864, #3967
  static fase1 + #865, #0
  static fase1 + #866, #3967
  static fase1 + #867, #3967
  static fase1 + #868, #3967
  static fase1 + #869, #3967
  static fase1 + #870, #0
  static fase1 + #871, #3967
  static fase1 + #872, #3967
  static fase1 + #873, #3967
  static fase1 + #874, #0
  static fase1 + #875, #3967
  static fase1 + #876, #3967
  static fase1 + #877, #0
  static fase1 + #878, #3967
  static fase1 + #879, #0

  ;Linha 22
  static fase1 + #880, #0
  static fase1 + #881, #3967
  static fase1 + #882, #0
  static fase1 + #883, #0
  static fase1 + #884, #0
  static fase1 + #885, #3967
  static fase1 + #886, #0
  static fase1 + #887, #0
  static fase1 + #888, #0
  static fase1 + #889, #0
  static fase1 + #890, #0
  static fase1 + #891, #0
  static fase1 + #892, #127
  static fase1 + #893, #0
  static fase1 + #894, #3967
  static fase1 + #895, #3
  static fase1 + #896, #3967
  static fase1 + #897, #127
  static fase1 + #898, #3967
  static fase1 + #899, #3967
  static fase1 + #900, #3967
  static fase1 + #901, #3967
  static fase1 + #902, #3967
  static fase1 + #903, #0
  static fase1 + #904, #3967
  static fase1 + #905, #0
  static fase1 + #906, #3967
  static fase1 + #907, #0
  static fase1 + #908, #0
  static fase1 + #909, #3967
  static fase1 + #910, #0
  static fase1 + #911, #0
  static fase1 + #912, #3967
  static fase1 + #913, #3967
  static fase1 + #914, #0
  static fase1 + #915, #3967
  static fase1 + #916, #3967
  static fase1 + #917, #0
  static fase1 + #918, #3967
  static fase1 + #919, #0

  ;Linha 23
  static fase1 + #920, #0
  static fase1 + #921, #3967
  static fase1 + #922, #127
  static fase1 + #923, #3967
  static fase1 + #924, #0
  static fase1 + #925, #3967
  static fase1 + #926, #3967
  static fase1 + #927, #3967
  static fase1 + #928, #3967
  static fase1 + #929, #3967
  static fase1 + #930, #3967
  static fase1 + #931, #0
  static fase1 + #932, #3967
  static fase1 + #933, #0
  static fase1 + #934, #0
  static fase1 + #935, #0
  static fase1 + #936, #0
  static fase1 + #937, #0
  static fase1 + #938, #0
  static fase1 + #939, #0
  static fase1 + #940, #0
  static fase1 + #941, #0
  static fase1 + #942, #3967
  static fase1 + #943, #0
  static fase1 + #944, #3967
  static fase1 + #945, #3967
  static fase1 + #946, #3967
  static fase1 + #947, #0
  static fase1 + #948, #0
  static fase1 + #949, #3967
  static fase1 + #950, #3967
  static fase1 + #951, #0
  static fase1 + #952, #3967
  static fase1 + #953, #3967
  static fase1 + #954, #0
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
  static fase1 + #966, #0
  static fase1 + #967, #3967
  static fase1 + #968, #3967
  static fase1 + #969, #3967
  static fase1 + #970, #3967
  static fase1 + #971, #0
  static fase1 + #972, #3967
  static fase1 + #973, #0
  static fase1 + #974, #3967
  static fase1 + #975, #3967
  static fase1 + #976, #3967
  static fase1 + #977, #0
  static fase1 + #978, #3967
  static fase1 + #979, #3967
  static fase1 + #980, #3967
  static fase1 + #981, #3967
  static fase1 + #982, #3967
  static fase1 + #983, #0
  static fase1 + #984, #3967
  static fase1 + #985, #0
  static fase1 + #986, #0
  static fase1 + #987, #0
  static fase1 + #988, #0
  static fase1 + #989, #0
  static fase1 + #990, #3967
  static fase1 + #991, #0
  static fase1 + #992, #3967
  static fase1 + #993, #3967
  static fase1 + #994, #0
  static fase1 + #995, #3967
  static fase1 + #996, #3967
  static fase1 + #997, #3967
  static fase1 + #998, #3967
  static fase1 + #999, #0

  ;Linha 25
  static fase1 + #1000, #0
  static fase1 + #1001, #3967
  static fase1 + #1002, #0
  static fase1 + #1003, #3967
  static fase1 + #1004, #0
  static fase1 + #1005, #3967
  static fase1 + #1006, #0
  static fase1 + #1007, #3967
  static fase1 + #1008, #0
  static fase1 + #1009, #0
  static fase1 + #1010, #3967
  static fase1 + #1011, #0
  static fase1 + #1012, #3967
  static fase1 + #1013, #3967
  static fase1 + #1014, #3967
  static fase1 + #1015, #0
  static fase1 + #1016, #127
  static fase1 + #1017, #0
  static fase1 + #1018, #3967
  static fase1 + #1019, #0
  static fase1 + #1020, #0
  static fase1 + #1021, #0
  static fase1 + #1022, #0
  static fase1 + #1023, #0
  static fase1 + #1024, #3967
  static fase1 + #1025, #0
  static fase1 + #1026, #0
  static fase1 + #1027, #3967
  static fase1 + #1028, #3967
  static fase1 + #1029, #0
  static fase1 + #1030, #3967
  static fase1 + #1031, #0
  static fase1 + #1032, #3967
  static fase1 + #1033, #3967
  static fase1 + #1034, #0
  static fase1 + #1035, #0
  static fase1 + #1036, #0
  static fase1 + #1037, #0
  static fase1 + #1038, #0
  static fase1 + #1039, #0

  ;Linha 26
  static fase1 + #1040, #0
  static fase1 + #1041, #3967
  static fase1 + #1042, #0
  static fase1 + #1043, #3967
  static fase1 + #1044, #3967
  static fase1 + #1045, #3967
  static fase1 + #1046, #0
  static fase1 + #1047, #3967
  static fase1 + #1048, #0
  static fase1 + #1049, #3967
  static fase1 + #1050, #3967
  static fase1 + #1051, #3967
  static fase1 + #1052, #3967
  static fase1 + #1053, #127
  static fase1 + #1054, #3967
  static fase1 + #1055, #0
  static fase1 + #1056, #3967
  static fase1 + #1057, #0
  static fase1 + #1058, #3967
  static fase1 + #1059, #3
  static fase1 + #1060, #3967
  static fase1 + #1061, #3967
  static fase1 + #1062, #3967
  static fase1 + #1063, #0
  static fase1 + #1064, #3967
  static fase1 + #1065, #3967
  static fase1 + #1066, #3967
  static fase1 + #1067, #3967
  static fase1 + #1068, #3967
  static fase1 + #1069, #0
  static fase1 + #1070, #3967
  static fase1 + #1071, #0
  static fase1 + #1072, #3967
  static fase1 + #1073, #3967
  static fase1 + #1074, #3967
  static fase1 + #1075, #3967
  static fase1 + #1076, #0
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
  static fase1 + #1087, #0
  static fase1 + #1088, #0
  static fase1 + #1089, #0
  static fase1 + #1090, #0
  static fase1 + #1091, #0
  static fase1 + #1092, #0
  static fase1 + #1093, #0
  static fase1 + #1094, #0
  static fase1 + #1095, #0
  static fase1 + #1096, #0
  static fase1 + #1097, #0
  static fase1 + #1098, #0
  static fase1 + #1099, #0
  static fase1 + #1100, #0
  static fase1 + #1101, #3967
  static fase1 + #1102, #0
  static fase1 + #1103, #0
  static fase1 + #1104, #0
  static fase1 + #1105, #0
  static fase1 + #1106, #0
  static fase1 + #1107, #0
  static fase1 + #1108, #0
  static fase1 + #1109, #0
  static fase1 + #1110, #0
  static fase1 + #1111, #0
  static fase1 + #1112, #0
  static fase1 + #1113, #0
  static fase1 + #1114, #0
  static fase1 + #1115, #0
  static fase1 + #1116, #0
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
  static fase1 + #1134, #127
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
  static fase1 + #1153, #3
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

fase2 : var #1200
  ;Linha 0
  static fase2 + #0, #0
  static fase2 + #1, #0
  static fase2 + #2, #0
  static fase2 + #3, #0
  static fase2 + #4, #0
  static fase2 + #5, #0
  static fase2 + #6, #0
  static fase2 + #7, #0
  static fase2 + #8, #0
  static fase2 + #9, #0
  static fase2 + #10, #0
  static fase2 + #11, #0
  static fase2 + #12, #0
  static fase2 + #13, #0
  static fase2 + #14, #0
  static fase2 + #15, #0
  static fase2 + #16, #0
  static fase2 + #17, #0
  static fase2 + #18, #0
  static fase2 + #19, #0
  static fase2 + #20, #0
  static fase2 + #21, #0
  static fase2 + #22, #0
  static fase2 + #23, #0
  static fase2 + #24, #0
  static fase2 + #25, #0
  static fase2 + #26, #0
  static fase2 + #27, #0
  static fase2 + #28, #0
  static fase2 + #29, #0
  static fase2 + #30, #0
  static fase2 + #31, #0
  static fase2 + #32, #0
  static fase2 + #33, #0
  static fase2 + #34, #0
  static fase2 + #35, #0
  static fase2 + #36, #0
  static fase2 + #37, #0
  static fase2 + #38, #0
  static fase2 + #39, #0

  ;Linha 1
  static fase2 + #40, #0
  static fase2 + #41, #127
  static fase2 + #42, #31
  static fase2 + #43, #31
  static fase2 + #44, #31
  static fase2 + #45, #31
  static fase2 + #46, #31
  static fase2 + #47, #31
  static fase2 + #48, #31
  static fase2 + #49, #31
  static fase2 + #50, #127
  static fase2 + #51, #127
  static fase2 + #52, #127
  static fase2 + #53, #3967
  static fase2 + #54, #3967
  static fase2 + #55, #3967
  static fase2 + #56, #3967
  static fase2 + #57, #3967
  static fase2 + #58, #3967
  static fase2 + #59, #3967
  static fase2 + #60, #3967
  static fase2 + #61, #3967
  static fase2 + #62, #127
  static fase2 + #63, #127
  static fase2 + #64, #3967
  static fase2 + #65, #127
  static fase2 + #66, #127
  static fase2 + #67, #0
  static fase2 + #68, #3967
  static fase2 + #69, #3967
  static fase2 + #70, #127
  static fase2 + #71, #3967
  static fase2 + #72, #127
  static fase2 + #73, #127
  static fase2 + #74, #127
  static fase2 + #75, #127
  static fase2 + #76, #127
  static fase2 + #77, #127
  static fase2 + #78, #127
  static fase2 + #79, #0

  ;Linha 2
  static fase2 + #80, #0
  static fase2 + #81, #3967
  static fase2 + #82, #3967
  static fase2 + #83, #3967
  static fase2 + #84, #3967
  static fase2 + #85, #3967
  static fase2 + #86, #3967
  static fase2 + #87, #3967
  static fase2 + #88, #3967
  static fase2 + #89, #3967
  static fase2 + #90, #3967
  static fase2 + #91, #3967
  static fase2 + #92, #3967
  static fase2 + #93, #3967
  static fase2 + #94, #3967
  static fase2 + #95, #3967
  static fase2 + #96, #3967
  static fase2 + #97, #3967
  static fase2 + #98, #3967
  static fase2 + #99, #3967
  static fase2 + #100, #3967
  static fase2 + #101, #3967
  static fase2 + #102, #3967
  static fase2 + #103, #3967
  static fase2 + #104, #3967
  static fase2 + #105, #3967
  static fase2 + #106, #3967
  static fase2 + #107, #0
  static fase2 + #108, #3967
  static fase2 + #109, #3967
  static fase2 + #110, #3967
  static fase2 + #111, #3967
  static fase2 + #112, #3967
  static fase2 + #113, #3967
  static fase2 + #114, #3967
  static fase2 + #115, #3967
  static fase2 + #116, #3967
  static fase2 + #117, #3967
  static fase2 + #118, #3967
  static fase2 + #119, #0

  ;Linha 3
  static fase2 + #120, #0
  static fase2 + #121, #3967
  static fase2 + #122, #3967
  static fase2 + #123, #3967
  static fase2 + #124, #3967
  static fase2 + #125, #3967
  static fase2 + #126, #3967
  static fase2 + #127, #3967
  static fase2 + #128, #3967
  static fase2 + #129, #3967
  static fase2 + #130, #3967
  static fase2 + #131, #3967
  static fase2 + #132, #3967
  static fase2 + #133, #3967
  static fase2 + #134, #3967
  static fase2 + #135, #3967
  static fase2 + #136, #3967
  static fase2 + #137, #3967
  static fase2 + #138, #3967
  static fase2 + #139, #3967
  static fase2 + #140, #3967
  static fase2 + #141, #3967
  static fase2 + #142, #3967
  static fase2 + #143, #3967
  static fase2 + #144, #3967
  static fase2 + #145, #3967
  static fase2 + #146, #3967
  static fase2 + #147, #0
  static fase2 + #148, #127
  static fase2 + #149, #3967
  static fase2 + #150, #3967
  static fase2 + #151, #3967
  static fase2 + #152, #3967
  static fase2 + #153, #3967
  static fase2 + #154, #3967
  static fase2 + #155, #3967
  static fase2 + #156, #3967
  static fase2 + #157, #3967
  static fase2 + #158, #31
  static fase2 + #159, #0

  ;Linha 4
  static fase2 + #160, #0
  static fase2 + #161, #0
  static fase2 + #162, #0
  static fase2 + #163, #0
  static fase2 + #164, #0
  static fase2 + #165, #0
  static fase2 + #166, #0
  static fase2 + #167, #0
  static fase2 + #168, #0
  static fase2 + #169, #3967
  static fase2 + #170, #3967
  static fase2 + #171, #3967
  static fase2 + #172, #3967
  static fase2 + #173, #0
  static fase2 + #174, #0
  static fase2 + #175, #0
  static fase2 + #176, #0
  static fase2 + #177, #0
  static fase2 + #178, #0
  static fase2 + #179, #0
  static fase2 + #180, #0
  static fase2 + #181, #0
  static fase2 + #182, #0
  static fase2 + #183, #3967
  static fase2 + #184, #3967
  static fase2 + #185, #3967
  static fase2 + #186, #3967
  static fase2 + #187, #0
  static fase2 + #188, #0
  static fase2 + #189, #0
  static fase2 + #190, #0
  static fase2 + #191, #0
  static fase2 + #192, #0
  static fase2 + #193, #0
  static fase2 + #194, #0
  static fase2 + #195, #0
  static fase2 + #196, #3967
  static fase2 + #197, #3967
  static fase2 + #198, #31
  static fase2 + #199, #0

  ;Linha 5
  static fase2 + #200, #0
  static fase2 + #201, #127
  static fase2 + #202, #3967
  static fase2 + #203, #3967
  static fase2 + #204, #3967
  static fase2 + #205, #3967
  static fase2 + #206, #3967
  static fase2 + #207, #3967
  static fase2 + #208, #0
  static fase2 + #209, #3967
  static fase2 + #210, #3967
  static fase2 + #211, #3967
  static fase2 + #212, #3967
  static fase2 + #213, #0
  static fase2 + #214, #3967
  static fase2 + #215, #3967
  static fase2 + #216, #3967
  static fase2 + #217, #3967
  static fase2 + #218, #3967
  static fase2 + #219, #3967
  static fase2 + #220, #3967
  static fase2 + #221, #3967
  static fase2 + #222, #3967
  static fase2 + #223, #3967
  static fase2 + #224, #3967
  static fase2 + #225, #3967
  static fase2 + #226, #3967
  static fase2 + #227, #3967
  static fase2 + #228, #127
  static fase2 + #229, #3967
  static fase2 + #230, #3967
  static fase2 + #231, #0
  static fase2 + #232, #3967
  static fase2 + #233, #3967
  static fase2 + #234, #3967
  static fase2 + #235, #0
  static fase2 + #236, #3967
  static fase2 + #237, #3967
  static fase2 + #238, #31
  static fase2 + #239, #0

  ;Linha 6
  static fase2 + #240, #0
  static fase2 + #241, #127
  static fase2 + #242, #3967
  static fase2 + #243, #3967
  static fase2 + #244, #3967
  static fase2 + #245, #3967
  static fase2 + #246, #3967
  static fase2 + #247, #3967
  static fase2 + #248, #0
  static fase2 + #249, #3967
  static fase2 + #250, #3967
  static fase2 + #251, #3967
  static fase2 + #252, #3967
  static fase2 + #253, #0
  static fase2 + #254, #3967
  static fase2 + #255, #3967
  static fase2 + #256, #3967
  static fase2 + #257, #3967
  static fase2 + #258, #3967
  static fase2 + #259, #3967
  static fase2 + #260, #3967
  static fase2 + #261, #3967
  static fase2 + #262, #3967
  static fase2 + #263, #3967
  static fase2 + #264, #3967
  static fase2 + #265, #3967
  static fase2 + #266, #3967
  static fase2 + #267, #3967
  static fase2 + #268, #3967
  static fase2 + #269, #3967
  static fase2 + #270, #3967
  static fase2 + #271, #0
  static fase2 + #272, #3967
  static fase2 + #273, #3967
  static fase2 + #274, #3967
  static fase2 + #275, #0
  static fase2 + #276, #3967
  static fase2 + #277, #3967
  static fase2 + #278, #31
  static fase2 + #279, #0

  ;Linha 7
  static fase2 + #280, #0
  static fase2 + #281, #127
  static fase2 + #282, #3967
  static fase2 + #283, #3967
  static fase2 + #284, #3967
  static fase2 + #285, #3967
  static fase2 + #286, #3967
  static fase2 + #287, #3967
  static fase2 + #288, #0
  static fase2 + #289, #3967
  static fase2 + #290, #3967
  static fase2 + #291, #3967
  static fase2 + #292, #3967
  static fase2 + #293, #0
  static fase2 + #294, #0
  static fase2 + #295, #0
  static fase2 + #296, #0
  static fase2 + #297, #0
  static fase2 + #298, #0
  static fase2 + #299, #0
  static fase2 + #300, #0
  static fase2 + #301, #0
  static fase2 + #302, #0
  static fase2 + #303, #0
  static fase2 + #304, #3967
  static fase2 + #305, #3
  static fase2 + #306, #3967
  static fase2 + #307, #0
  static fase2 + #308, #0
  static fase2 + #309, #0
  static fase2 + #310, #0
  static fase2 + #311, #0
  static fase2 + #312, #3967
  static fase2 + #313, #3967
  static fase2 + #314, #3967
  static fase2 + #315, #0
  static fase2 + #316, #3967
  static fase2 + #317, #3967
  static fase2 + #318, #31
  static fase2 + #319, #0

  ;Linha 8
  static fase2 + #320, #0
  static fase2 + #321, #127
  static fase2 + #322, #3967
  static fase2 + #323, #3967
  static fase2 + #324, #3967
  static fase2 + #325, #3967
  static fase2 + #326, #3967
  static fase2 + #327, #3967
  static fase2 + #328, #0
  static fase2 + #329, #3967
  static fase2 + #330, #3967
  static fase2 + #331, #3967
  static fase2 + #332, #3967
  static fase2 + #333, #0
  static fase2 + #334, #3967
  static fase2 + #335, #3967
  static fase2 + #336, #3967
  static fase2 + #337, #3967
  static fase2 + #338, #3967
  static fase2 + #339, #3967
  static fase2 + #340, #3967
  static fase2 + #341, #3967
  static fase2 + #342, #3967
  static fase2 + #343, #3967
  static fase2 + #344, #3967
  static fase2 + #345, #3967
  static fase2 + #346, #3967
  static fase2 + #347, #3967
  static fase2 + #348, #3967
  static fase2 + #349, #3967
  static fase2 + #350, #3967
  static fase2 + #351, #3967
  static fase2 + #352, #3967
  static fase2 + #353, #3967
  static fase2 + #354, #3840
  static fase2 + #355, #0
  static fase2 + #356, #3967
  static fase2 + #357, #3967
  static fase2 + #358, #31
  static fase2 + #359, #0

  ;Linha 9
  static fase2 + #360, #0
  static fase2 + #361, #127
  static fase2 + #362, #3967
  static fase2 + #363, #0
  static fase2 + #364, #0
  static fase2 + #365, #0
  static fase2 + #366, #0
  static fase2 + #367, #0
  static fase2 + #368, #0
  static fase2 + #369, #0
  static fase2 + #370, #0
  static fase2 + #371, #0
  static fase2 + #372, #0
  static fase2 + #373, #0
  static fase2 + #374, #3967
  static fase2 + #375, #3967
  static fase2 + #376, #3967
  static fase2 + #377, #3967
  static fase2 + #378, #0
  static fase2 + #379, #0
  static fase2 + #380, #0
  static fase2 + #381, #0
  static fase2 + #382, #0
  static fase2 + #383, #0
  static fase2 + #384, #0
  static fase2 + #385, #0
  static fase2 + #386, #0
  static fase2 + #387, #0
  static fase2 + #388, #0
  static fase2 + #389, #0
  static fase2 + #390, #0
  static fase2 + #391, #0
  static fase2 + #392, #0
  static fase2 + #393, #0
  static fase2 + #394, #0
  static fase2 + #395, #0
  static fase2 + #396, #3967
  static fase2 + #397, #3967
  static fase2 + #398, #3967
  static fase2 + #399, #0

  ;Linha 10
  static fase2 + #400, #0
  static fase2 + #401, #127
  static fase2 + #402, #3967
  static fase2 + #403, #0
  static fase2 + #404, #3967
  static fase2 + #405, #3967
  static fase2 + #406, #3967
  static fase2 + #407, #3967
  static fase2 + #408, #3967
  static fase2 + #409, #3967
  static fase2 + #410, #3967
  static fase2 + #411, #3967
  static fase2 + #412, #3967
  static fase2 + #413, #3967
  static fase2 + #414, #3967
  static fase2 + #415, #3967
  static fase2 + #416, #3967
  static fase2 + #417, #3967
  static fase2 + #418, #0
  static fase2 + #419, #3967
  static fase2 + #420, #3967
  static fase2 + #421, #3967
  static fase2 + #422, #3967
  static fase2 + #423, #3967
  static fase2 + #424, #3967
  static fase2 + #425, #3967
  static fase2 + #426, #3967
  static fase2 + #427, #3967
  static fase2 + #428, #3967
  static fase2 + #429, #3967
  static fase2 + #430, #3967
  static fase2 + #431, #3967
  static fase2 + #432, #3967
  static fase2 + #433, #3967
  static fase2 + #434, #3967
  static fase2 + #435, #0
  static fase2 + #436, #3967
  static fase2 + #437, #3967
  static fase2 + #438, #3967
  static fase2 + #439, #0

  ;Linha 11
  static fase2 + #440, #0
  static fase2 + #441, #3967
  static fase2 + #442, #3967
  static fase2 + #443, #0
  static fase2 + #444, #3967
  static fase2 + #445, #3967
  static fase2 + #446, #3967
  static fase2 + #447, #3967
  static fase2 + #448, #0
  static fase2 + #449, #0
  static fase2 + #450, #0
  static fase2 + #451, #0
  static fase2 + #452, #3967
  static fase2 + #453, #0
  static fase2 + #454, #3967
  static fase2 + #455, #3967
  static fase2 + #456, #3967
  static fase2 + #457, #3967
  static fase2 + #458, #0
  static fase2 + #459, #3967
  static fase2 + #460, #3967
  static fase2 + #461, #3967
  static fase2 + #462, #3967
  static fase2 + #463, #3967
  static fase2 + #464, #3967
  static fase2 + #465, #3967
  static fase2 + #466, #3967
  static fase2 + #467, #3967
  static fase2 + #468, #3967
  static fase2 + #469, #3967
  static fase2 + #470, #3967
  static fase2 + #471, #3967
  static fase2 + #472, #3967
  static fase2 + #473, #3967
  static fase2 + #474, #3967
  static fase2 + #475, #0
  static fase2 + #476, #3967
  static fase2 + #477, #3967
  static fase2 + #478, #3967
  static fase2 + #479, #0

  ;Linha 12
  static fase2 + #480, #0
  static fase2 + #481, #3967
  static fase2 + #482, #3967
  static fase2 + #483, #0
  static fase2 + #484, #3967
  static fase2 + #485, #3967
  static fase2 + #486, #3967
  static fase2 + #487, #3967
  static fase2 + #488, #0
  static fase2 + #489, #3840
  static fase2 + #490, #3840
  static fase2 + #491, #0
  static fase2 + #492, #3967
  static fase2 + #493, #0
  static fase2 + #494, #3967
  static fase2 + #495, #3967
  static fase2 + #496, #3967
  static fase2 + #497, #3967
  static fase2 + #498, #0
  static fase2 + #499, #3967
  static fase2 + #500, #3967
  static fase2 + #501, #3967
  static fase2 + #502, #3840
  static fase2 + #503, #3840
  static fase2 + #504, #3840
  static fase2 + #505, #3967
  static fase2 + #506, #3967
  static fase2 + #507, #3967
  static fase2 + #508, #3967
  static fase2 + #509, #3967
  static fase2 + #510, #3967
  static fase2 + #511, #3967
  static fase2 + #512, #3967
  static fase2 + #513, #3967
  static fase2 + #514, #3967
  static fase2 + #515, #0
  static fase2 + #516, #3967
  static fase2 + #517, #3967
  static fase2 + #518, #3967
  static fase2 + #519, #0

  ;Linha 13
  static fase2 + #520, #0
  static fase2 + #521, #3967
  static fase2 + #522, #3967
  static fase2 + #523, #0
  static fase2 + #524, #3967
  static fase2 + #525, #3967
  static fase2 + #526, #3967
  static fase2 + #527, #3967
  static fase2 + #528, #0
  static fase2 + #529, #3967
  static fase2 + #530, #3967
  static fase2 + #531, #0
  static fase2 + #532, #3967
  static fase2 + #533, #0
  static fase2 + #534, #3967
  static fase2 + #535, #3967
  static fase2 + #536, #3967
  static fase2 + #537, #3967
  static fase2 + #538, #0
  static fase2 + #539, #3967
  static fase2 + #540, #3967
  static fase2 + #541, #3967
  static fase2 + #542, #0
  static fase2 + #543, #0
  static fase2 + #544, #0
  static fase2 + #545, #0
  static fase2 + #546, #0
  static fase2 + #547, #0
  static fase2 + #548, #0
  static fase2 + #549, #0
  static fase2 + #550, #0
  static fase2 + #551, #0
  static fase2 + #552, #3967
  static fase2 + #553, #3967
  static fase2 + #554, #3967
  static fase2 + #555, #0
  static fase2 + #556, #3967
  static fase2 + #557, #3967
  static fase2 + #558, #3967
  static fase2 + #559, #0

  ;Linha 14
  static fase2 + #560, #0
  static fase2 + #561, #3967
  static fase2 + #562, #3967
  static fase2 + #563, #0
  static fase2 + #564, #3967
  static fase2 + #565, #3967
  static fase2 + #566, #3967
  static fase2 + #567, #3967
  static fase2 + #568, #0
  static fase2 + #569, #3967
  static fase2 + #570, #3967
  static fase2 + #571, #0
  static fase2 + #572, #3967
  static fase2 + #573, #0
  static fase2 + #574, #3967
  static fase2 + #575, #3967
  static fase2 + #576, #3967
  static fase2 + #577, #3967
  static fase2 + #578, #0
  static fase2 + #579, #3967
  static fase2 + #580, #3967
  static fase2 + #581, #3967
  static fase2 + #582, #3967
  static fase2 + #583, #3967
  static fase2 + #584, #3967
  static fase2 + #585, #3967
  static fase2 + #586, #3967
  static fase2 + #587, #3967
  static fase2 + #588, #3967
  static fase2 + #589, #3967
  static fase2 + #590, #3967
  static fase2 + #591, #0
  static fase2 + #592, #3967
  static fase2 + #593, #3967
  static fase2 + #594, #3967
  static fase2 + #595, #0
  static fase2 + #596, #3967
  static fase2 + #597, #3967
  static fase2 + #598, #3967
  static fase2 + #599, #0

  ;Linha 15
  static fase2 + #600, #0
  static fase2 + #601, #3967
  static fase2 + #602, #3967
  static fase2 + #603, #0
  static fase2 + #604, #3967
  static fase2 + #605, #3967
  static fase2 + #606, #3967
  static fase2 + #607, #3967
  static fase2 + #608, #0
  static fase2 + #609, #3967
  static fase2 + #610, #3967
  static fase2 + #611, #0
  static fase2 + #612, #3840
  static fase2 + #613, #0
  static fase2 + #614, #3840
  static fase2 + #615, #3967
  static fase2 + #616, #3967
  static fase2 + #617, #3967
  static fase2 + #618, #0
  static fase2 + #619, #3967
  static fase2 + #620, #3967
  static fase2 + #621, #3967
  static fase2 + #622, #3967
  static fase2 + #623, #3967
  static fase2 + #624, #3967
  static fase2 + #625, #3967
  static fase2 + #626, #3967
  static fase2 + #627, #3967
  static fase2 + #628, #3967
  static fase2 + #629, #3967
  static fase2 + #630, #3967
  static fase2 + #631, #0
  static fase2 + #632, #3967
  static fase2 + #633, #3967
  static fase2 + #634, #3967
  static fase2 + #635, #0
  static fase2 + #636, #3967
  static fase2 + #637, #3967
  static fase2 + #638, #3967
  static fase2 + #639, #0

  ;Linha 16
  static fase2 + #640, #0
  static fase2 + #641, #3967
  static fase2 + #642, #3967
  static fase2 + #643, #0
  static fase2 + #644, #3967
  static fase2 + #645, #3967
  static fase2 + #646, #3967
  static fase2 + #647, #3967
  static fase2 + #648, #0
  static fase2 + #649, #3967
  static fase2 + #650, #3967
  static fase2 + #651, #0
  static fase2 + #652, #3967
  static fase2 + #653, #0
  static fase2 + #654, #3840
  static fase2 + #655, #3967
  static fase2 + #656, #3967
  static fase2 + #657, #3967
  static fase2 + #658, #0
  static fase2 + #659, #3840
  static fase2 + #660, #3840
  static fase2 + #661, #3840
  static fase2 + #662, #3840
  static fase2 + #663, #3840
  static fase2 + #664, #3840
  static fase2 + #665, #3840
  static fase2 + #666, #3840
  static fase2 + #667, #3840
  static fase2 + #668, #3840
  static fase2 + #669, #3840
  static fase2 + #670, #3967
  static fase2 + #671, #0
  static fase2 + #672, #3967
  static fase2 + #673, #3967
  static fase2 + #674, #3967
  static fase2 + #675, #0
  static fase2 + #676, #3840
  static fase2 + #677, #3840
  static fase2 + #678, #3840
  static fase2 + #679, #0

  ;Linha 17
  static fase2 + #680, #0
  static fase2 + #681, #3967
  static fase2 + #682, #3967
  static fase2 + #683, #0
  static fase2 + #684, #0
  static fase2 + #685, #0
  static fase2 + #686, #3967
  static fase2 + #687, #3967
  static fase2 + #688, #0
  static fase2 + #689, #3967
  static fase2 + #690, #3967
  static fase2 + #691, #0
  static fase2 + #692, #3967
  static fase2 + #693, #0
  static fase2 + #694, #3840
  static fase2 + #695, #3967
  static fase2 + #696, #3967
  static fase2 + #697, #3967
  static fase2 + #698, #0
  static fase2 + #699, #0
  static fase2 + #700, #0
  static fase2 + #701, #0
  static fase2 + #702, #0
  static fase2 + #703, #0
  static fase2 + #704, #0
  static fase2 + #705, #0
  static fase2 + #706, #0
  static fase2 + #707, #0
  static fase2 + #708, #0
  static fase2 + #709, #0
  static fase2 + #710, #0
  static fase2 + #711, #0
  static fase2 + #712, #3967
  static fase2 + #713, #3967
  static fase2 + #714, #3967
  static fase2 + #715, #0
  static fase2 + #716, #0
  static fase2 + #717, #0
  static fase2 + #718, #0
  static fase2 + #719, #0

  ;Linha 18
  static fase2 + #720, #0
  static fase2 + #721, #3967
  static fase2 + #722, #3967
  static fase2 + #723, #0
  static fase2 + #724, #3967
  static fase2 + #725, #3967
  static fase2 + #726, #3967
  static fase2 + #727, #3967
  static fase2 + #728, #0
  static fase2 + #729, #3967
  static fase2 + #730, #3967
  static fase2 + #731, #0
  static fase2 + #732, #3967
  static fase2 + #733, #0
  static fase2 + #734, #3840
  static fase2 + #735, #3967
  static fase2 + #736, #3967
  static fase2 + #737, #3967
  static fase2 + #738, #3967
  static fase2 + #739, #3967
  static fase2 + #740, #3840
  static fase2 + #741, #3840
  static fase2 + #742, #3967
  static fase2 + #743, #3967
  static fase2 + #744, #3967
  static fase2 + #745, #3967
  static fase2 + #746, #3967
  static fase2 + #747, #3967
  static fase2 + #748, #3967
  static fase2 + #749, #3967
  static fase2 + #750, #3967
  static fase2 + #751, #0
  static fase2 + #752, #3967
  static fase2 + #753, #3967
  static fase2 + #754, #3967
  static fase2 + #755, #3
  static fase2 + #756, #3967
  static fase2 + #757, #3967
  static fase2 + #758, #3967
  static fase2 + #759, #0

  ;Linha 19
  static fase2 + #760, #0
  static fase2 + #761, #3967
  static fase2 + #762, #3967
  static fase2 + #763, #0
  static fase2 + #764, #3967
  static fase2 + #765, #3967
  static fase2 + #766, #3967
  static fase2 + #767, #3967
  static fase2 + #768, #0
  static fase2 + #769, #3967
  static fase2 + #770, #3967
  static fase2 + #771, #0
  static fase2 + #772, #3967
  static fase2 + #773, #0
  static fase2 + #774, #3840
  static fase2 + #775, #3840
  static fase2 + #776, #3840
  static fase2 + #777, #3967
  static fase2 + #778, #3967
  static fase2 + #779, #3967
  static fase2 + #780, #3967
  static fase2 + #781, #3967
  static fase2 + #782, #3967
  static fase2 + #783, #3967
  static fase2 + #784, #3967
  static fase2 + #785, #3967
  static fase2 + #786, #3967
  static fase2 + #787, #3967
  static fase2 + #788, #3967
  static fase2 + #789, #3967
  static fase2 + #790, #3967
  static fase2 + #791, #0
  static fase2 + #792, #3967
  static fase2 + #793, #3967
  static fase2 + #794, #3967
  static fase2 + #795, #0
  static fase2 + #796, #3967
  static fase2 + #797, #3967
  static fase2 + #798, #3967
  static fase2 + #799, #0

  ;Linha 20
  static fase2 + #800, #0
  static fase2 + #801, #3967
  static fase2 + #802, #3967
  static fase2 + #803, #0
  static fase2 + #804, #3967
  static fase2 + #805, #3967
  static fase2 + #806, #3967
  static fase2 + #807, #3967
  static fase2 + #808, #0
  static fase2 + #809, #3
  static fase2 + #810, #0
  static fase2 + #811, #0
  static fase2 + #812, #3967
  static fase2 + #813, #0
  static fase2 + #814, #3840
  static fase2 + #815, #3967
  static fase2 + #816, #3967
  static fase2 + #817, #3967
  static fase2 + #818, #3967
  static fase2 + #819, #3967
  static fase2 + #820, #3967
  static fase2 + #821, #3967
  static fase2 + #822, #3967
  static fase2 + #823, #3967
  static fase2 + #824, #3967
  static fase2 + #825, #3967
  static fase2 + #826, #3967
  static fase2 + #827, #3967
  static fase2 + #828, #3967
  static fase2 + #829, #3967
  static fase2 + #830, #3967
  static fase2 + #831, #0
  static fase2 + #832, #3967
  static fase2 + #833, #3967
  static fase2 + #834, #3967
  static fase2 + #835, #0
  static fase2 + #836, #3967
  static fase2 + #837, #3967
  static fase2 + #838, #3967
  static fase2 + #839, #0

  ;Linha 21
  static fase2 + #840, #0
  static fase2 + #841, #3967
  static fase2 + #842, #3967
  static fase2 + #843, #0
  static fase2 + #844, #3967
  static fase2 + #845, #3967
  static fase2 + #846, #3967
  static fase2 + #847, #3967
  static fase2 + #848, #0
  static fase2 + #849, #3967
  static fase2 + #850, #3967
  static fase2 + #851, #3967
  static fase2 + #852, #3967
  static fase2 + #853, #0
  static fase2 + #854, #3967
  static fase2 + #855, #3967
  static fase2 + #856, #3967
  static fase2 + #857, #3967
  static fase2 + #858, #3967
  static fase2 + #859, #3967
  static fase2 + #860, #3967
  static fase2 + #861, #3967
  static fase2 + #862, #3967
  static fase2 + #863, #3967
  static fase2 + #864, #3967
  static fase2 + #865, #3967
  static fase2 + #866, #3967
  static fase2 + #867, #3967
  static fase2 + #868, #3967
  static fase2 + #869, #3967
  static fase2 + #870, #3967
  static fase2 + #871, #0
  static fase2 + #872, #3967
  static fase2 + #873, #3967
  static fase2 + #874, #3967
  static fase2 + #875, #0
  static fase2 + #876, #3967
  static fase2 + #877, #3967
  static fase2 + #878, #3967
  static fase2 + #879, #0

  ;Linha 22
  static fase2 + #880, #0
  static fase2 + #881, #3967
  static fase2 + #882, #3967
  static fase2 + #883, #0
  static fase2 + #884, #0
  static fase2 + #885, #0
  static fase2 + #886, #3967
  static fase2 + #887, #3967
  static fase2 + #888, #0
  static fase2 + #889, #0
  static fase2 + #890, #0
  static fase2 + #891, #0
  static fase2 + #892, #0
  static fase2 + #893, #0
  static fase2 + #894, #0
  static fase2 + #895, #0
  static fase2 + #896, #0
  static fase2 + #897, #0
  static fase2 + #898, #0
  static fase2 + #899, #0
  static fase2 + #900, #0
  static fase2 + #901, #0
  static fase2 + #902, #0
  static fase2 + #903, #0
  static fase2 + #904, #0
  static fase2 + #905, #0
  static fase2 + #906, #0
  static fase2 + #907, #0
  static fase2 + #908, #0
  static fase2 + #909, #3967
  static fase2 + #910, #3967
  static fase2 + #911, #0
  static fase2 + #912, #3967
  static fase2 + #913, #3967
  static fase2 + #914, #3967
  static fase2 + #915, #0
  static fase2 + #916, #3967
  static fase2 + #917, #3967
  static fase2 + #918, #3967
  static fase2 + #919, #0

  ;Linha 23
  static fase2 + #920, #0
  static fase2 + #921, #3967
  static fase2 + #922, #3967
  static fase2 + #923, #3967
  static fase2 + #924, #3967
  static fase2 + #925, #0
  static fase2 + #926, #3967
  static fase2 + #927, #3967
  static fase2 + #928, #3967
  static fase2 + #929, #3967
  static fase2 + #930, #3967
  static fase2 + #931, #3840
  static fase2 + #932, #3840
  static fase2 + #933, #3840
  static fase2 + #934, #3840
  static fase2 + #935, #3840
  static fase2 + #936, #3967
  static fase2 + #937, #3967
  static fase2 + #938, #3967
  static fase2 + #939, #3967
  static fase2 + #940, #3967
  static fase2 + #941, #3967
  static fase2 + #942, #3967
  static fase2 + #943, #0
  static fase2 + #944, #3967
  static fase2 + #945, #3967
  static fase2 + #946, #3967
  static fase2 + #947, #3967
  static fase2 + #948, #0
  static fase2 + #949, #3967
  static fase2 + #950, #3967
  static fase2 + #951, #0
  static fase2 + #952, #3967
  static fase2 + #953, #3967
  static fase2 + #954, #3967
  static fase2 + #955, #0
  static fase2 + #956, #3967
  static fase2 + #957, #3967
  static fase2 + #958, #3967
  static fase2 + #959, #0

  ;Linha 24
  static fase2 + #960, #0
  static fase2 + #961, #3967
  static fase2 + #962, #3967
  static fase2 + #963, #3967
  static fase2 + #964, #3967
  static fase2 + #965, #0
  static fase2 + #966, #3967
  static fase2 + #967, #0
  static fase2 + #968, #0
  static fase2 + #969, #0
  static fase2 + #970, #0
  static fase2 + #971, #0
  static fase2 + #972, #0
  static fase2 + #973, #0
  static fase2 + #974, #0
  static fase2 + #975, #0
  static fase2 + #976, #0
  static fase2 + #977, #0
  static fase2 + #978, #0
  static fase2 + #979, #0
  static fase2 + #980, #0
  static fase2 + #981, #3967
  static fase2 + #982, #3967
  static fase2 + #983, #0
  static fase2 + #984, #3
  static fase2 + #985, #0
  static fase2 + #986, #0
  static fase2 + #987, #0
  static fase2 + #988, #0
  static fase2 + #989, #3967
  static fase2 + #990, #3967
  static fase2 + #991, #0
  static fase2 + #992, #514
  static fase2 + #993, #514
  static fase2 + #994, #514
  static fase2 + #995, #0
  static fase2 + #996, #3967
  static fase2 + #997, #3967
  static fase2 + #998, #3967
  static fase2 + #999, #0

  ;Linha 25
  static fase2 + #1000, #0
  static fase2 + #1001, #3840
  static fase2 + #1002, #3840
  static fase2 + #1003, #3840
  static fase2 + #1004, #0
  static fase2 + #1005, #0
  static fase2 + #1006, #3
  static fase2 + #1007, #0
  static fase2 + #1008, #3967
  static fase2 + #1009, #3
  static fase2 + #1010, #3967
  static fase2 + #1011, #3967
  static fase2 + #1012, #3967
  static fase2 + #1013, #3967
  static fase2 + #1014, #3967
  static fase2 + #1015, #3967
  static fase2 + #1016, #3967
  static fase2 + #1017, #3967
  static fase2 + #1018, #3967
  static fase2 + #1019, #3967
  static fase2 + #1020, #0
  static fase2 + #1021, #3967
  static fase2 + #1022, #3967
  static fase2 + #1023, #0
  static fase2 + #1024, #3967
  static fase2 + #1025, #3967
  static fase2 + #1026, #3967
  static fase2 + #1027, #3967
  static fase2 + #1028, #0
  static fase2 + #1029, #3967
  static fase2 + #1030, #3
  static fase2 + #1031, #0
  static fase2 + #1032, #0
  static fase2 + #1033, #0
  static fase2 + #1034, #0
  static fase2 + #1035, #0
  static fase2 + #1036, #3967
  static fase2 + #1037, #3967
  static fase2 + #1038, #3967
  static fase2 + #1039, #0

  ;Linha 26
  static fase2 + #1040, #0
  static fase2 + #1041, #3967
  static fase2 + #1042, #3967
  static fase2 + #1043, #3967
  static fase2 + #1044, #0
  static fase2 + #1045, #3967
  static fase2 + #1046, #3967
  static fase2 + #1047, #0
  static fase2 + #1048, #3967
  static fase2 + #1049, #0
  static fase2 + #1050, #3967
  static fase2 + #1051, #3967
  static fase2 + #1052, #3967
  static fase2 + #1053, #3967
  static fase2 + #1054, #3967
  static fase2 + #1055, #3967
  static fase2 + #1056, #127
  static fase2 + #1057, #127
  static fase2 + #1058, #127
  static fase2 + #1059, #3967
  static fase2 + #1060, #0
  static fase2 + #1061, #3967
  static fase2 + #1062, #3967
  static fase2 + #1063, #0
  static fase2 + #1064, #0
  static fase2 + #1065, #0
  static fase2 + #1066, #3967
  static fase2 + #1067, #3967
  static fase2 + #1068, #0
  static fase2 + #1069, #3967
  static fase2 + #1070, #3967
  static fase2 + #1071, #3967
  static fase2 + #1072, #3967
  static fase2 + #1073, #3967
  static fase2 + #1074, #3967
  static fase2 + #1075, #3967
  static fase2 + #1076, #3967
  static fase2 + #1077, #3967
  static fase2 + #1078, #3967
  static fase2 + #1079, #0

  ;Linha 27
  static fase2 + #1080, #0
  static fase2 + #1081, #3967
  static fase2 + #1082, #3967
  static fase2 + #1083, #3967
  static fase2 + #1084, #0
  static fase2 + #1085, #3967
  static fase2 + #1086, #3967
  static fase2 + #1087, #0
  static fase2 + #1088, #3967
  static fase2 + #1089, #0
  static fase2 + #1090, #0
  static fase2 + #1091, #0
  static fase2 + #1092, #0
  static fase2 + #1093, #0
  static fase2 + #1094, #0
  static fase2 + #1095, #0
  static fase2 + #1096, #0
  static fase2 + #1097, #0
  static fase2 + #1098, #0
  static fase2 + #1099, #0
  static fase2 + #1100, #0
  static fase2 + #1101, #3967
  static fase2 + #1102, #3967
  static fase2 + #1103, #3967
  static fase2 + #1104, #3967
  static fase2 + #1105, #0
  static fase2 + #1106, #3967
  static fase2 + #1107, #3967
  static fase2 + #1108, #0
  static fase2 + #1109, #3967
  static fase2 + #1110, #3967
  static fase2 + #1111, #3967
  static fase2 + #1112, #3967
  static fase2 + #1113, #3967
  static fase2 + #1114, #3967
  static fase2 + #1115, #3967
  static fase2 + #1116, #3967
  static fase2 + #1117, #3967
  static fase2 + #1118, #3967
  static fase2 + #1119, #0

  ;Linha 28
  static fase2 + #1120, #0
  static fase2 + #1121, #3967
  static fase2 + #1122, #3967
  static fase2 + #1123, #3967
  static fase2 + #1124, #3967
  static fase2 + #1125, #3967
  static fase2 + #1126, #3967
  static fase2 + #1127, #0
  static fase2 + #1128, #3967
  static fase2 + #1129, #3967
  static fase2 + #1130, #3967
  static fase2 + #1131, #3967
  static fase2 + #1132, #3967
  static fase2 + #1133, #3967
  static fase2 + #1134, #3967
  static fase2 + #1135, #3967
  static fase2 + #1136, #3967
  static fase2 + #1137, #127
  static fase2 + #1138, #3967
  static fase2 + #1139, #3967
  static fase2 + #1140, #3967
  static fase2 + #1141, #3967
  static fase2 + #1142, #3967
  static fase2 + #1143, #3967
  static fase2 + #1144, #3967
  static fase2 + #1145, #0
  static fase2 + #1146, #3967
  static fase2 + #1147, #3967
  static fase2 + #1148, #127
  static fase2 + #1149, #3967
  static fase2 + #1150, #3967
  static fase2 + #1151, #3967
  static fase2 + #1152, #3967
  static fase2 + #1153, #3967
  static fase2 + #1154, #3967
  static fase2 + #1155, #3967
  static fase2 + #1156, #3967
  static fase2 + #1157, #3967
  static fase2 + #1158, #3967
  static fase2 + #1159, #0

  ;Linha 29
  static fase2 + #1160, #0
  static fase2 + #1161, #0
  static fase2 + #1162, #0
  static fase2 + #1163, #0
  static fase2 + #1164, #0
  static fase2 + #1165, #0
  static fase2 + #1166, #0
  static fase2 + #1167, #0
  static fase2 + #1168, #0
  static fase2 + #1169, #0
  static fase2 + #1170, #0
  static fase2 + #1171, #0
  static fase2 + #1172, #0
  static fase2 + #1173, #0
  static fase2 + #1174, #0
  static fase2 + #1175, #0
  static fase2 + #1176, #0
  static fase2 + #1177, #0
  static fase2 + #1178, #0
  static fase2 + #1179, #0
  static fase2 + #1180, #0
  static fase2 + #1181, #0
  static fase2 + #1182, #0
  static fase2 + #1183, #0
  static fase2 + #1184, #0
  static fase2 + #1185, #0
  static fase2 + #1186, #0
  static fase2 + #1187, #0
  static fase2 + #1188, #0
  static fase2 + #1189, #0
  static fase2 + #1190, #0
  static fase2 + #1191, #0
  static fase2 + #1192, #0
  static fase2 + #1193, #0
  static fase2 + #1194, #0
  static fase2 + #1195, #0
  static fase2 + #1196, #0
  static fase2 + #1197, #0
  static fase2 + #1198, #0
  static fase2 + #1199, #0


fase3 : var #1200
  ;Linha 0
  static fase3 + #0, #0
  static fase3 + #1, #0
  static fase3 + #2, #0
  static fase3 + #3, #0
  static fase3 + #4, #0
  static fase3 + #5, #0
  static fase3 + #6, #0
  static fase3 + #7, #0
  static fase3 + #8, #0
  static fase3 + #9, #0
  static fase3 + #10, #0
  static fase3 + #11, #0
  static fase3 + #12, #0
  static fase3 + #13, #0
  static fase3 + #14, #0
  static fase3 + #15, #0
  static fase3 + #16, #0
  static fase3 + #17, #0
  static fase3 + #18, #0
  static fase3 + #19, #0
  static fase3 + #20, #0
  static fase3 + #21, #0
  static fase3 + #22, #0
  static fase3 + #23, #0
  static fase3 + #24, #0
  static fase3 + #25, #0
  static fase3 + #26, #0
  static fase3 + #27, #0
  static fase3 + #28, #0
  static fase3 + #29, #0
  static fase3 + #30, #0
  static fase3 + #31, #0
  static fase3 + #32, #0
  static fase3 + #33, #0
  static fase3 + #34, #0
  static fase3 + #35, #0
  static fase3 + #36, #0
  static fase3 + #37, #0
  static fase3 + #38, #0
  static fase3 + #39, #0

  ;Linha 1
  static fase3 + #40, #0
  static fase3 + #41, #3967
  static fase3 + #42, #3967
  static fase3 + #43, #3967
  static fase3 + #44, #3967
  static fase3 + #45, #3967
  static fase3 + #46, #3967
  static fase3 + #47, #3967
  static fase3 + #48, #3967
  static fase3 + #49, #127
  static fase3 + #50, #127
  static fase3 + #51, #127
  static fase3 + #52, #127
  static fase3 + #53, #127
  static fase3 + #54, #127
  static fase3 + #55, #127
  static fase3 + #56, #127
  static fase3 + #57, #3
  static fase3 + #58, #127
  static fase3 + #59, #127
  static fase3 + #60, #3967
  static fase3 + #61, #3967
  static fase3 + #62, #3967
  static fase3 + #63, #3967
  static fase3 + #64, #3967
  static fase3 + #65, #3967
  static fase3 + #66, #3967
  static fase3 + #67, #3967
  static fase3 + #68, #3967
  static fase3 + #69, #3967
  static fase3 + #70, #3967
  static fase3 + #71, #3967
  static fase3 + #72, #3967
  static fase3 + #73, #3967
  static fase3 + #74, #3967
  static fase3 + #75, #3967
  static fase3 + #76, #3967
  static fase3 + #77, #3967
  static fase3 + #78, #3967
  static fase3 + #79, #0

  ;Linha 2
  static fase3 + #80, #0
  static fase3 + #81, #3967
  static fase3 + #82, #3967
  static fase3 + #83, #3967
  static fase3 + #84, #3967
  static fase3 + #85, #3967
  static fase3 + #86, #3967
  static fase3 + #87, #3967
  static fase3 + #88, #3967
  static fase3 + #89, #3967
  static fase3 + #90, #3967
  static fase3 + #91, #3967
  static fase3 + #92, #3967
  static fase3 + #93, #3967
  static fase3 + #94, #3967
  static fase3 + #95, #3967
  static fase3 + #96, #3967
  static fase3 + #97, #3967
  static fase3 + #98, #3967
  static fase3 + #99, #3967
  static fase3 + #100, #3967
  static fase3 + #101, #3967
  static fase3 + #102, #3967
  static fase3 + #103, #3967
  static fase3 + #104, #3967
  static fase3 + #105, #3967
  static fase3 + #106, #3967
  static fase3 + #107, #3967
  static fase3 + #108, #3967
  static fase3 + #109, #3967
  static fase3 + #110, #3967
  static fase3 + #111, #3
  static fase3 + #112, #3967
  static fase3 + #113, #3967
  static fase3 + #114, #3967
  static fase3 + #115, #3967
  static fase3 + #116, #3967
  static fase3 + #117, #3967
  static fase3 + #118, #3967
  static fase3 + #119, #0

  ;Linha 3
  static fase3 + #120, #0
  static fase3 + #121, #0
  static fase3 + #122, #0
  static fase3 + #123, #0
  static fase3 + #124, #0
  static fase3 + #125, #3967
  static fase3 + #126, #3967
  static fase3 + #127, #3967
  static fase3 + #128, #3967
  static fase3 + #129, #0
  static fase3 + #130, #0
  static fase3 + #131, #0
  static fase3 + #132, #0
  static fase3 + #133, #0
  static fase3 + #134, #0
  static fase3 + #135, #0
  static fase3 + #136, #0
  static fase3 + #137, #0
  static fase3 + #138, #0
  static fase3 + #139, #0
  static fase3 + #140, #0
  static fase3 + #141, #0
  static fase3 + #142, #0
  static fase3 + #143, #0
  static fase3 + #144, #0
  static fase3 + #145, #0
  static fase3 + #146, #0
  static fase3 + #147, #3967
  static fase3 + #148, #3967
  static fase3 + #149, #3967
  static fase3 + #150, #3967
  static fase3 + #151, #0
  static fase3 + #152, #0
  static fase3 + #153, #0
  static fase3 + #154, #0
  static fase3 + #155, #0
  static fase3 + #156, #0
  static fase3 + #157, #0
  static fase3 + #158, #0
  static fase3 + #159, #0

  ;Linha 4
  static fase3 + #160, #0
  static fase3 + #161, #3967
  static fase3 + #162, #127
  static fase3 + #163, #3967
  static fase3 + #164, #3967
  static fase3 + #165, #3967
  static fase3 + #166, #3967
  static fase3 + #167, #3967
  static fase3 + #168, #3967
  static fase3 + #169, #3967
  static fase3 + #170, #3967
  static fase3 + #171, #0
  static fase3 + #172, #3967
  static fase3 + #173, #3967
  static fase3 + #174, #3967
  static fase3 + #175, #127
  static fase3 + #176, #127
  static fase3 + #177, #127
  static fase3 + #178, #0
  static fase3 + #179, #3967
  static fase3 + #180, #3967
  static fase3 + #181, #3967
  static fase3 + #182, #3967
  static fase3 + #183, #3967
  static fase3 + #184, #3967
  static fase3 + #185, #3967
  static fase3 + #186, #3967
  static fase3 + #187, #3967
  static fase3 + #188, #3967
  static fase3 + #189, #3967
  static fase3 + #190, #3967
  static fase3 + #191, #3967
  static fase3 + #192, #3967
  static fase3 + #193, #3967
  static fase3 + #194, #0
  static fase3 + #195, #3967
  static fase3 + #196, #3967
  static fase3 + #197, #127
  static fase3 + #198, #127
  static fase3 + #199, #0

  ;Linha 5
  static fase3 + #200, #0
  static fase3 + #201, #3967
  static fase3 + #202, #127
  static fase3 + #203, #3967
  static fase3 + #204, #3967
  static fase3 + #205, #3967
  static fase3 + #206, #3967
  static fase3 + #207, #3967
  static fase3 + #208, #3967
  static fase3 + #209, #3967
  static fase3 + #210, #3967
  static fase3 + #211, #0
  static fase3 + #212, #3967
  static fase3 + #213, #3967
  static fase3 + #214, #3967
  static fase3 + #215, #3967
  static fase3 + #216, #3967
  static fase3 + #217, #3967
  static fase3 + #218, #0
  static fase3 + #219, #3967
  static fase3 + #220, #3967
  static fase3 + #221, #3967
  static fase3 + #222, #3967
  static fase3 + #223, #3
  static fase3 + #224, #3967
  static fase3 + #225, #3967
  static fase3 + #226, #3967
  static fase3 + #227, #3967
  static fase3 + #228, #3967
  static fase3 + #229, #3967
  static fase3 + #230, #3967
  static fase3 + #231, #3967
  static fase3 + #232, #3967
  static fase3 + #233, #3967
  static fase3 + #234, #0
  static fase3 + #235, #3967
  static fase3 + #236, #3967
  static fase3 + #237, #3967
  static fase3 + #238, #3967
  static fase3 + #239, #0

  ;Linha 6
  static fase3 + #240, #0
  static fase3 + #241, #3967
  static fase3 + #242, #127
  static fase3 + #243, #3967
  static fase3 + #244, #3967
  static fase3 + #245, #3967
  static fase3 + #246, #3967
  static fase3 + #247, #3967
  static fase3 + #248, #3967
  static fase3 + #249, #3967
  static fase3 + #250, #3967
  static fase3 + #251, #0
  static fase3 + #252, #3967
  static fase3 + #253, #3967
  static fase3 + #254, #3967
  static fase3 + #255, #3967
  static fase3 + #256, #3967
  static fase3 + #257, #3967
  static fase3 + #258, #0
  static fase3 + #259, #3967
  static fase3 + #260, #3967
  static fase3 + #261, #3967
  static fase3 + #262, #3967
  static fase3 + #263, #3967
  static fase3 + #264, #3967
  static fase3 + #265, #0
  static fase3 + #266, #0
  static fase3 + #267, #0
  static fase3 + #268, #0
  static fase3 + #269, #0
  static fase3 + #270, #0
  static fase3 + #271, #0
  static fase3 + #272, #0
  static fase3 + #273, #0
  static fase3 + #274, #0
  static fase3 + #275, #3967
  static fase3 + #276, #3967
  static fase3 + #277, #3967
  static fase3 + #278, #3967
  static fase3 + #279, #0

  ;Linha 7
  static fase3 + #280, #0
  static fase3 + #281, #3967
  static fase3 + #282, #127
  static fase3 + #283, #0
  static fase3 + #284, #3967
  static fase3 + #285, #3967
  static fase3 + #286, #3
  static fase3 + #287, #3967
  static fase3 + #288, #0
  static fase3 + #289, #3967
  static fase3 + #290, #3967
  static fase3 + #291, #0
  static fase3 + #292, #3967
  static fase3 + #293, #3967
  static fase3 + #294, #3967
  static fase3 + #295, #3967
  static fase3 + #296, #3967
  static fase3 + #297, #127
  static fase3 + #298, #0
  static fase3 + #299, #3967
  static fase3 + #300, #3967
  static fase3 + #301, #3967
  static fase3 + #302, #3967
  static fase3 + #303, #3967
  static fase3 + #304, #3967
  static fase3 + #305, #3967
  static fase3 + #306, #3967
  static fase3 + #307, #3967
  static fase3 + #308, #3967
  static fase3 + #309, #3967
  static fase3 + #310, #3967
  static fase3 + #311, #3967
  static fase3 + #312, #3967
  static fase3 + #313, #3
  static fase3 + #314, #3967
  static fase3 + #315, #3967
  static fase3 + #316, #3967
  static fase3 + #317, #3967
  static fase3 + #318, #3967
  static fase3 + #319, #0

  ;Linha 8
  static fase3 + #320, #0
  static fase3 + #321, #127
  static fase3 + #322, #127
  static fase3 + #323, #0
  static fase3 + #324, #3967
  static fase3 + #325, #3967
  static fase3 + #326, #3967
  static fase3 + #327, #3967
  static fase3 + #328, #0
  static fase3 + #329, #3967
  static fase3 + #330, #3967
  static fase3 + #331, #0
  static fase3 + #332, #3967
  static fase3 + #333, #3967
  static fase3 + #334, #3967
  static fase3 + #335, #3967
  static fase3 + #336, #3967
  static fase3 + #337, #127
  static fase3 + #338, #0
  static fase3 + #339, #3967
  static fase3 + #340, #3967
  static fase3 + #341, #3967
  static fase3 + #342, #3967
  static fase3 + #343, #3967
  static fase3 + #344, #3967
  static fase3 + #345, #3967
  static fase3 + #346, #3967
  static fase3 + #347, #3967
  static fase3 + #348, #3967
  static fase3 + #349, #3967
  static fase3 + #350, #3967
  static fase3 + #351, #3967
  static fase3 + #352, #3967
  static fase3 + #353, #0
  static fase3 + #354, #0
  static fase3 + #355, #0
  static fase3 + #356, #0
  static fase3 + #357, #0
  static fase3 + #358, #0
  static fase3 + #359, #0

  ;Linha 9
  static fase3 + #360, #0
  static fase3 + #361, #127
  static fase3 + #362, #127
  static fase3 + #363, #0
  static fase3 + #364, #3967
  static fase3 + #365, #3967
  static fase3 + #366, #3967
  static fase3 + #367, #3967
  static fase3 + #368, #0
  static fase3 + #369, #3967
  static fase3 + #370, #3967
  static fase3 + #371, #0
  static fase3 + #372, #3967
  static fase3 + #373, #3967
  static fase3 + #374, #3967
  static fase3 + #375, #3967
  static fase3 + #376, #3967
  static fase3 + #377, #127
  static fase3 + #378, #0
  static fase3 + #379, #3967
  static fase3 + #380, #3967
  static fase3 + #381, #3967
  static fase3 + #382, #3967
  static fase3 + #383, #3967
  static fase3 + #384, #3967
  static fase3 + #385, #3967
  static fase3 + #386, #3967
  static fase3 + #387, #3967
  static fase3 + #388, #3967
  static fase3 + #389, #3967
  static fase3 + #390, #3967
  static fase3 + #391, #3967
  static fase3 + #392, #3967
  static fase3 + #393, #3967
  static fase3 + #394, #3967
  static fase3 + #395, #3967
  static fase3 + #396, #3967
  static fase3 + #397, #3967
  static fase3 + #398, #3967
  static fase3 + #399, #0

  ;Linha 10
  static fase3 + #400, #0
  static fase3 + #401, #127
  static fase3 + #402, #127
  static fase3 + #403, #0
  static fase3 + #404, #3967
  static fase3 + #405, #3967
  static fase3 + #406, #3967
  static fase3 + #407, #3967
  static fase3 + #408, #0
  static fase3 + #409, #3967
  static fase3 + #410, #3967
  static fase3 + #411, #0
  static fase3 + #412, #3967
  static fase3 + #413, #3967
  static fase3 + #414, #3967
  static fase3 + #415, #3967
  static fase3 + #416, #3967
  static fase3 + #417, #127
  static fase3 + #418, #0
  static fase3 + #419, #3967
  static fase3 + #420, #3967
  static fase3 + #421, #3967
  static fase3 + #422, #3967
  static fase3 + #423, #3967
  static fase3 + #424, #3967
  static fase3 + #425, #3967
  static fase3 + #426, #3967
  static fase3 + #427, #3967
  static fase3 + #428, #3967
  static fase3 + #429, #3967
  static fase3 + #430, #3967
  static fase3 + #431, #3967
  static fase3 + #432, #3967
  static fase3 + #433, #3967
  static fase3 + #434, #3967
  static fase3 + #435, #3967
  static fase3 + #436, #3967
  static fase3 + #437, #3967
  static fase3 + #438, #3967
  static fase3 + #439, #0

  ;Linha 11
  static fase3 + #440, #0
  static fase3 + #441, #127
  static fase3 + #442, #127
  static fase3 + #443, #0
  static fase3 + #444, #3967
  static fase3 + #445, #3967
  static fase3 + #446, #3967
  static fase3 + #447, #3967
  static fase3 + #448, #3967
  static fase3 + #449, #3967
  static fase3 + #450, #3967
  static fase3 + #451, #0
  static fase3 + #452, #3967
  static fase3 + #453, #3967
  static fase3 + #454, #0
  static fase3 + #455, #3967
  static fase3 + #456, #3967
  static fase3 + #457, #127
  static fase3 + #458, #0
  static fase3 + #459, #0
  static fase3 + #460, #0
  static fase3 + #461, #0
  static fase3 + #462, #0
  static fase3 + #463, #0
  static fase3 + #464, #3967
  static fase3 + #465, #3967
  static fase3 + #466, #0
  static fase3 + #467, #0
  static fase3 + #468, #0
  static fase3 + #469, #0
  static fase3 + #470, #0
  static fase3 + #471, #0
  static fase3 + #472, #0
  static fase3 + #473, #0
  static fase3 + #474, #3840
  static fase3 + #475, #3840
  static fase3 + #476, #0
  static fase3 + #477, #3967
  static fase3 + #478, #3967
  static fase3 + #479, #0

  ;Linha 12
  static fase3 + #480, #0
  static fase3 + #481, #127
  static fase3 + #482, #127
  static fase3 + #483, #0
  static fase3 + #484, #3967
  static fase3 + #485, #3967
  static fase3 + #486, #3967
  static fase3 + #487, #3967
  static fase3 + #488, #3967
  static fase3 + #489, #3967
  static fase3 + #490, #3967
  static fase3 + #491, #0
  static fase3 + #492, #3967
  static fase3 + #493, #3967
  static fase3 + #494, #0
  static fase3 + #495, #3967
  static fase3 + #496, #3967
  static fase3 + #497, #127
  static fase3 + #498, #0
  static fase3 + #499, #3967
  static fase3 + #500, #3967
  static fase3 + #501, #3967
  static fase3 + #502, #3967
  static fase3 + #503, #0
  static fase3 + #504, #3967
  static fase3 + #505, #3
  static fase3 + #506, #0
  static fase3 + #507, #3967
  static fase3 + #508, #3967
  static fase3 + #509, #3967
  static fase3 + #510, #3967
  static fase3 + #511, #3967
  static fase3 + #512, #3840
  static fase3 + #513, #0
  static fase3 + #514, #3840
  static fase3 + #515, #3
  static fase3 + #516, #0
  static fase3 + #517, #3967
  static fase3 + #518, #3967
  static fase3 + #519, #0

  ;Linha 13
  static fase3 + #520, #0
  static fase3 + #521, #3967
  static fase3 + #522, #127
  static fase3 + #523, #0
  static fase3 + #524, #3967
  static fase3 + #525, #3967
  static fase3 + #526, #3967
  static fase3 + #527, #3967
  static fase3 + #528, #0
  static fase3 + #529, #3967
  static fase3 + #530, #3967
  static fase3 + #531, #0
  static fase3 + #532, #3967
  static fase3 + #533, #3967
  static fase3 + #534, #0
  static fase3 + #535, #3967
  static fase3 + #536, #3967
  static fase3 + #537, #3967
  static fase3 + #538, #0
  static fase3 + #539, #3967
  static fase3 + #540, #3967
  static fase3 + #541, #3967
  static fase3 + #542, #3967
  static fase3 + #543, #0
  static fase3 + #544, #3967
  static fase3 + #545, #3967
  static fase3 + #546, #0
  static fase3 + #547, #3967
  static fase3 + #548, #3967
  static fase3 + #549, #3967
  static fase3 + #550, #3967
  static fase3 + #551, #3967
  static fase3 + #552, #3967
  static fase3 + #553, #0
  static fase3 + #554, #3840
  static fase3 + #555, #3840
  static fase3 + #556, #0
  static fase3 + #557, #3967
  static fase3 + #558, #3967
  static fase3 + #559, #0

  ;Linha 14
  static fase3 + #560, #0
  static fase3 + #561, #3967
  static fase3 + #562, #127
  static fase3 + #563, #0
  static fase3 + #564, #3967
  static fase3 + #565, #3967
  static fase3 + #566, #3967
  static fase3 + #567, #3967
  static fase3 + #568, #0
  static fase3 + #569, #3967
  static fase3 + #570, #3967
  static fase3 + #571, #0
  static fase3 + #572, #3967
  static fase3 + #573, #3967
  static fase3 + #574, #0
  static fase3 + #575, #3967
  static fase3 + #576, #3967
  static fase3 + #577, #3967
  static fase3 + #578, #0
  static fase3 + #579, #3967
  static fase3 + #580, #3967
  static fase3 + #581, #3967
  static fase3 + #582, #3967
  static fase3 + #583, #0
  static fase3 + #584, #3967
  static fase3 + #585, #3967
  static fase3 + #586, #0
  static fase3 + #587, #3967
  static fase3 + #588, #3967
  static fase3 + #589, #3967
  static fase3 + #590, #0
  static fase3 + #591, #3967
  static fase3 + #592, #3967
  static fase3 + #593, #0
  static fase3 + #594, #3840
  static fase3 + #595, #3840
  static fase3 + #596, #0
  static fase3 + #597, #3967
  static fase3 + #598, #3967
  static fase3 + #599, #0

  ;Linha 15
  static fase3 + #600, #0
  static fase3 + #601, #3967
  static fase3 + #602, #127
  static fase3 + #603, #0
  static fase3 + #604, #3967
  static fase3 + #605, #3967
  static fase3 + #606, #3967
  static fase3 + #607, #3967
  static fase3 + #608, #0
  static fase3 + #609, #3967
  static fase3 + #610, #3967
  static fase3 + #611, #3967
  static fase3 + #612, #3967
  static fase3 + #613, #3967
  static fase3 + #614, #0
  static fase3 + #615, #3967
  static fase3 + #616, #3967
  static fase3 + #617, #3967
  static fase3 + #618, #0
  static fase3 + #619, #3967
  static fase3 + #620, #3967
  static fase3 + #621, #3967
  static fase3 + #622, #3967
  static fase3 + #623, #0
  static fase3 + #624, #3967
  static fase3 + #625, #3967
  static fase3 + #626, #0
  static fase3 + #627, #3967
  static fase3 + #628, #3967
  static fase3 + #629, #3967
  static fase3 + #630, #0
  static fase3 + #631, #3967
  static fase3 + #632, #3967
  static fase3 + #633, #0
  static fase3 + #634, #3840
  static fase3 + #635, #3840
  static fase3 + #636, #0
  static fase3 + #637, #3967
  static fase3 + #638, #3967
  static fase3 + #639, #0

  ;Linha 16
  static fase3 + #640, #0
  static fase3 + #641, #3967
  static fase3 + #642, #127
  static fase3 + #643, #0
  static fase3 + #644, #3967
  static fase3 + #645, #3967
  static fase3 + #646, #3967
  static fase3 + #647, #3967
  static fase3 + #648, #0
  static fase3 + #649, #3967
  static fase3 + #650, #3967
  static fase3 + #651, #3967
  static fase3 + #652, #3967
  static fase3 + #653, #3967
  static fase3 + #654, #0
  static fase3 + #655, #3967
  static fase3 + #656, #3967
  static fase3 + #657, #3967
  static fase3 + #658, #0
  static fase3 + #659, #3967
  static fase3 + #660, #3967
  static fase3 + #661, #3967
  static fase3 + #662, #3967
  static fase3 + #663, #0
  static fase3 + #664, #3967
  static fase3 + #665, #3967
  static fase3 + #666, #0
  static fase3 + #667, #3967
  static fase3 + #668, #3967
  static fase3 + #669, #3967
  static fase3 + #670, #0
  static fase3 + #671, #3967
  static fase3 + #672, #3967
  static fase3 + #673, #0
  static fase3 + #674, #3840
  static fase3 + #675, #3967
  static fase3 + #676, #0
  static fase3 + #677, #3967
  static fase3 + #678, #3967
  static fase3 + #679, #0

  ;Linha 17
  static fase3 + #680, #0
  static fase3 + #681, #3967
  static fase3 + #682, #127
  static fase3 + #683, #0
  static fase3 + #684, #3967
  static fase3 + #685, #3967
  static fase3 + #686, #3967
  static fase3 + #687, #3967
  static fase3 + #688, #0
  static fase3 + #689, #3967
  static fase3 + #690, #3967
  static fase3 + #691, #0
  static fase3 + #692, #3967
  static fase3 + #693, #3967
  static fase3 + #694, #0
  static fase3 + #695, #3967
  static fase3 + #696, #3967
  static fase3 + #697, #3967
  static fase3 + #698, #0
  static fase3 + #699, #3967
  static fase3 + #700, #3967
  static fase3 + #701, #3967
  static fase3 + #702, #3967
  static fase3 + #703, #0
  static fase3 + #704, #3967
  static fase3 + #705, #3967
  static fase3 + #706, #0
  static fase3 + #707, #3967
  static fase3 + #708, #3967
  static fase3 + #709, #3967
  static fase3 + #710, #0
  static fase3 + #711, #3967
  static fase3 + #712, #3967
  static fase3 + #713, #0
  static fase3 + #714, #3840
  static fase3 + #715, #3967
  static fase3 + #716, #0
  static fase3 + #717, #3967
  static fase3 + #718, #3967
  static fase3 + #719, #0

  ;Linha 18
  static fase3 + #720, #0
  static fase3 + #721, #3967
  static fase3 + #722, #127
  static fase3 + #723, #0
  static fase3 + #724, #0
  static fase3 + #725, #0
  static fase3 + #726, #0
  static fase3 + #727, #0
  static fase3 + #728, #0
  static fase3 + #729, #3967
  static fase3 + #730, #3967
  static fase3 + #731, #0
  static fase3 + #732, #0
  static fase3 + #733, #0
  static fase3 + #734, #0
  static fase3 + #735, #3967
  static fase3 + #736, #3967
  static fase3 + #737, #3967
  static fase3 + #738, #0
  static fase3 + #739, #3967
  static fase3 + #740, #3967
  static fase3 + #741, #3967
  static fase3 + #742, #3967
  static fase3 + #743, #3967
  static fase3 + #744, #3967
  static fase3 + #745, #3967
  static fase3 + #746, #0
  static fase3 + #747, #3967
  static fase3 + #748, #3967
  static fase3 + #749, #3967
  static fase3 + #750, #0
  static fase3 + #751, #3967
  static fase3 + #752, #3967
  static fase3 + #753, #0
  static fase3 + #754, #3840
  static fase3 + #755, #3967
  static fase3 + #756, #0
  static fase3 + #757, #3
  static fase3 + #758, #3967
  static fase3 + #759, #0

  ;Linha 19
  static fase3 + #760, #0
  static fase3 + #761, #127
  static fase3 + #762, #127
  static fase3 + #763, #0
  static fase3 + #764, #3967
  static fase3 + #765, #3967
  static fase3 + #766, #3967
  static fase3 + #767, #3967
  static fase3 + #768, #3967
  static fase3 + #769, #3967
  static fase3 + #770, #3967
  static fase3 + #771, #0
  static fase3 + #772, #3967
  static fase3 + #773, #3967
  static fase3 + #774, #3
  static fase3 + #775, #3967
  static fase3 + #776, #3967
  static fase3 + #777, #3967
  static fase3 + #778, #0
  static fase3 + #779, #3967
  static fase3 + #780, #3967
  static fase3 + #781, #3967
  static fase3 + #782, #3967
  static fase3 + #783, #0
  static fase3 + #784, #3967
  static fase3 + #785, #3967
  static fase3 + #786, #127
  static fase3 + #787, #3967
  static fase3 + #788, #3967
  static fase3 + #789, #3967
  static fase3 + #790, #0
  static fase3 + #791, #3967
  static fase3 + #792, #3967
  static fase3 + #793, #0
  static fase3 + #794, #3840
  static fase3 + #795, #3967
  static fase3 + #796, #0
  static fase3 + #797, #3967
  static fase3 + #798, #3967
  static fase3 + #799, #0

  ;Linha 20
  static fase3 + #800, #0
  static fase3 + #801, #127
  static fase3 + #802, #127
  static fase3 + #803, #0
  static fase3 + #804, #3967
  static fase3 + #805, #3967
  static fase3 + #806, #3967
  static fase3 + #807, #3
  static fase3 + #808, #3967
  static fase3 + #809, #3967
  static fase3 + #810, #3967
  static fase3 + #811, #0
  static fase3 + #812, #3967
  static fase3 + #813, #3967
  static fase3 + #814, #0
  static fase3 + #815, #3967
  static fase3 + #816, #3967
  static fase3 + #817, #3967
  static fase3 + #818, #0
  static fase3 + #819, #3967
  static fase3 + #820, #3967
  static fase3 + #821, #3967
  static fase3 + #822, #3967
  static fase3 + #823, #0
  static fase3 + #824, #3967
  static fase3 + #825, #3967
  static fase3 + #826, #127
  static fase3 + #827, #3967
  static fase3 + #828, #3967
  static fase3 + #829, #3967
  static fase3 + #830, #0
  static fase3 + #831, #3967
  static fase3 + #832, #3967
  static fase3 + #833, #0
  static fase3 + #834, #3840
  static fase3 + #835, #3967
  static fase3 + #836, #0
  static fase3 + #837, #3967
  static fase3 + #838, #3967
  static fase3 + #839, #0

  ;Linha 21
  static fase3 + #840, #0
  static fase3 + #841, #127
  static fase3 + #842, #127
  static fase3 + #843, #0
  static fase3 + #844, #3967
  static fase3 + #845, #3967
  static fase3 + #846, #3967
  static fase3 + #847, #0
  static fase3 + #848, #3967
  static fase3 + #849, #3967
  static fase3 + #850, #3967
  static fase3 + #851, #0
  static fase3 + #852, #3967
  static fase3 + #853, #3967
  static fase3 + #854, #0
  static fase3 + #855, #3967
  static fase3 + #856, #3967
  static fase3 + #857, #3967
  static fase3 + #858, #0
  static fase3 + #859, #3967
  static fase3 + #860, #3967
  static fase3 + #861, #3967
  static fase3 + #862, #3967
  static fase3 + #863, #0
  static fase3 + #864, #3
  static fase3 + #865, #3967
  static fase3 + #866, #0
  static fase3 + #867, #3967
  static fase3 + #868, #3967
  static fase3 + #869, #3967
  static fase3 + #870, #3967
  static fase3 + #871, #3967
  static fase3 + #872, #3967
  static fase3 + #873, #0
  static fase3 + #874, #3840
  static fase3 + #875, #3967
  static fase3 + #876, #0
  static fase3 + #877, #3967
  static fase3 + #878, #3967
  static fase3 + #879, #0

  ;Linha 22
  static fase3 + #880, #0
  static fase3 + #881, #127
  static fase3 + #882, #127
  static fase3 + #883, #0
  static fase3 + #884, #3967
  static fase3 + #885, #3967
  static fase3 + #886, #3967
  static fase3 + #887, #0
  static fase3 + #888, #3967
  static fase3 + #889, #3967
  static fase3 + #890, #3967
  static fase3 + #891, #0
  static fase3 + #892, #3967
  static fase3 + #893, #3967
  static fase3 + #894, #0
  static fase3 + #895, #3967
  static fase3 + #896, #3967
  static fase3 + #897, #3967
  static fase3 + #898, #0
  static fase3 + #899, #3967
  static fase3 + #900, #3967
  static fase3 + #901, #3967
  static fase3 + #902, #3967
  static fase3 + #903, #127
  static fase3 + #904, #3967
  static fase3 + #905, #3967
  static fase3 + #906, #0
  static fase3 + #907, #3967
  static fase3 + #908, #3967
  static fase3 + #909, #3967
  static fase3 + #910, #3
  static fase3 + #911, #3967
  static fase3 + #912, #3967
  static fase3 + #913, #0
  static fase3 + #914, #3840
  static fase3 + #915, #3967
  static fase3 + #916, #0
  static fase3 + #917, #3967
  static fase3 + #918, #3967
  static fase3 + #919, #0

  ;Linha 23
  static fase3 + #920, #0
  static fase3 + #921, #3967
  static fase3 + #922, #127
  static fase3 + #923, #0
  static fase3 + #924, #3967
  static fase3 + #925, #3967
  static fase3 + #926, #3967
  static fase3 + #927, #0
  static fase3 + #928, #3967
  static fase3 + #929, #3967
  static fase3 + #930, #3967
  static fase3 + #931, #0
  static fase3 + #932, #3967
  static fase3 + #933, #3967
  static fase3 + #934, #0
  static fase3 + #935, #3967
  static fase3 + #936, #3967
  static fase3 + #937, #3967
  static fase3 + #938, #0
  static fase3 + #939, #3967
  static fase3 + #940, #3967
  static fase3 + #941, #3967
  static fase3 + #942, #3967
  static fase3 + #943, #0
  static fase3 + #944, #3967
  static fase3 + #945, #3967
  static fase3 + #946, #0
  static fase3 + #947, #3967
  static fase3 + #948, #3967
  static fase3 + #949, #3967
  static fase3 + #950, #0
  static fase3 + #951, #3967
  static fase3 + #952, #3967
  static fase3 + #953, #0
  static fase3 + #954, #3840
  static fase3 + #955, #3967
  static fase3 + #956, #0
  static fase3 + #957, #3967
  static fase3 + #958, #3967
  static fase3 + #959, #0

  ;Linha 24
  static fase3 + #960, #0
  static fase3 + #961, #3967
  static fase3 + #962, #127
  static fase3 + #963, #0
  static fase3 + #964, #127
  static fase3 + #965, #127
  static fase3 + #966, #127
  static fase3 + #967, #0
  static fase3 + #968, #127
  static fase3 + #969, #3967
  static fase3 + #970, #3967
  static fase3 + #971, #3967
  static fase3 + #972, #3967
  static fase3 + #973, #3967
  static fase3 + #974, #3967
  static fase3 + #975, #3967
  static fase3 + #976, #3967
  static fase3 + #977, #3967
  static fase3 + #978, #0
  static fase3 + #979, #3967
  static fase3 + #980, #3967
  static fase3 + #981, #3967
  static fase3 + #982, #3967
  static fase3 + #983, #0
  static fase3 + #984, #3967
  static fase3 + #985, #3967
  static fase3 + #986, #0
  static fase3 + #987, #3967
  static fase3 + #988, #3967
  static fase3 + #989, #3967
  static fase3 + #990, #0
  static fase3 + #991, #3967
  static fase3 + #992, #3967
  static fase3 + #993, #3
  static fase3 + #994, #3840
  static fase3 + #995, #3967
  static fase3 + #996, #0
  static fase3 + #997, #3967
  static fase3 + #998, #3967
  static fase3 + #999, #0

  ;Linha 25
  static fase3 + #1000, #0
  static fase3 + #1001, #3967
  static fase3 + #1002, #127
  static fase3 + #1003, #0
  static fase3 + #1004, #0
  static fase3 + #1005, #0
  static fase3 + #1006, #0
  static fase3 + #1007, #0
  static fase3 + #1008, #0
  static fase3 + #1009, #0
  static fase3 + #1010, #3967
  static fase3 + #1011, #3967
  static fase3 + #1012, #3967
  static fase3 + #1013, #3967
  static fase3 + #1014, #3967
  static fase3 + #1015, #3967
  static fase3 + #1016, #0
  static fase3 + #1017, #0
  static fase3 + #1018, #0
  static fase3 + #1019, #3967
  static fase3 + #1020, #3967
  static fase3 + #1021, #3967
  static fase3 + #1022, #3967
  static fase3 + #1023, #0
  static fase3 + #1024, #3967
  static fase3 + #1025, #3967
  static fase3 + #1026, #0
  static fase3 + #1027, #3967
  static fase3 + #1028, #3967
  static fase3 + #1029, #3967
  static fase3 + #1030, #0
  static fase3 + #1031, #3967
  static fase3 + #1032, #3967
  static fase3 + #1033, #3
  static fase3 + #1034, #3840
  static fase3 + #1035, #3967
  static fase3 + #1036, #0
  static fase3 + #1037, #3967
  static fase3 + #1038, #3967
  static fase3 + #1039, #0

  ;Linha 26
  static fase3 + #1040, #0
  static fase3 + #1041, #3967
  static fase3 + #1042, #127
  static fase3 + #1043, #0
  static fase3 + #1044, #3967
  static fase3 + #1045, #3967
  static fase3 + #1046, #127
  static fase3 + #1047, #3967
  static fase3 + #1048, #3967
  static fase3 + #1049, #3967
  static fase3 + #1050, #3967
  static fase3 + #1051, #3967
  static fase3 + #1052, #3967
  static fase3 + #1053, #3967
  static fase3 + #1054, #3967
  static fase3 + #1055, #3967
  static fase3 + #1056, #3967
  static fase3 + #1057, #3967
  static fase3 + #1058, #0
  static fase3 + #1059, #3967
  static fase3 + #1060, #3967
  static fase3 + #1061, #3967
  static fase3 + #1062, #3967
  static fase3 + #1063, #0
  static fase3 + #1064, #0
  static fase3 + #1065, #0
  static fase3 + #1066, #0
  static fase3 + #1067, #0
  static fase3 + #1068, #0
  static fase3 + #1069, #0
  static fase3 + #1070, #0
  static fase3 + #1071, #3967
  static fase3 + #1072, #3967
  static fase3 + #1073, #0
  static fase3 + #1074, #3840
  static fase3 + #1075, #3967
  static fase3 + #1076, #0
  static fase3 + #1077, #3967
  static fase3 + #1078, #3967
  static fase3 + #1079, #0

  ;Linha 27
  static fase3 + #1080, #0
  static fase3 + #1081, #3967
  static fase3 + #1082, #3967
  static fase3 + #1083, #0
  static fase3 + #1084, #3967
  static fase3 + #1085, #3967
  static fase3 + #1086, #0
  static fase3 + #1087, #0
  static fase3 + #1088, #0
  static fase3 + #1089, #0
  static fase3 + #1090, #0
  static fase3 + #1091, #3967
  static fase3 + #1092, #3967
  static fase3 + #1093, #0
  static fase3 + #1094, #0
  static fase3 + #1095, #0
  static fase3 + #1096, #0
  static fase3 + #1097, #0
  static fase3 + #1098, #0
  static fase3 + #1099, #3967
  static fase3 + #1100, #3967
  static fase3 + #1101, #3967
  static fase3 + #1102, #3967
  static fase3 + #1103, #3967
  static fase3 + #1104, #3967
  static fase3 + #1105, #3967
  static fase3 + #1106, #3967
  static fase3 + #1107, #3967
  static fase3 + #1108, #3967
  static fase3 + #1109, #3967
  static fase3 + #1110, #3967
  static fase3 + #1111, #3967
  static fase3 + #1112, #3967
  static fase3 + #1113, #0
  static fase3 + #1114, #3840
  static fase3 + #1115, #3967
  static fase3 + #1116, #3967
  static fase3 + #1117, #3967
  static fase3 + #1118, #3967
  static fase3 + #1119, #0

  ;Linha 28
  static fase3 + #1120, #0
  static fase3 + #1121, #3967
  static fase3 + #1122, #3967
  static fase3 + #1123, #3967
  static fase3 + #1124, #3967
  static fase3 + #1125, #3967
  static fase3 + #1126, #3967
  static fase3 + #1127, #3967
  static fase3 + #1128, #3967
  static fase3 + #1129, #3967
  static fase3 + #1130, #3967
  static fase3 + #1131, #3967
  static fase3 + #1132, #3967
  static fase3 + #1133, #3967
  static fase3 + #1134, #3967
  static fase3 + #1135, #3967
  static fase3 + #1136, #3967
  static fase3 + #1137, #3967
  static fase3 + #1138, #3967
  static fase3 + #1139, #3967
  static fase3 + #1140, #3967
  static fase3 + #1141, #3967
  static fase3 + #1142, #3967
  static fase3 + #1143, #3967
  static fase3 + #1144, #3967
  static fase3 + #1145, #3967
  static fase3 + #1146, #3967
  static fase3 + #1147, #3967
  static fase3 + #1148, #3967
  static fase3 + #1149, #3967
  static fase3 + #1150, #3967
  static fase3 + #1151, #3967
  static fase3 + #1152, #3967
  static fase3 + #1153, #0
  static fase3 + #1154, #3840
  static fase3 + #1155, #3967
  static fase3 + #1156, #3967
  static fase3 + #1157, #3967
  static fase3 + #1158, #514
  static fase3 + #1159, #0

  ;Linha 29
  static fase3 + #1160, #0
  static fase3 + #1161, #0
  static fase3 + #1162, #0
  static fase3 + #1163, #0
  static fase3 + #1164, #0
  static fase3 + #1165, #0
  static fase3 + #1166, #0
  static fase3 + #1167, #0
  static fase3 + #1168, #0
  static fase3 + #1169, #0
  static fase3 + #1170, #0
  static fase3 + #1171, #0
  static fase3 + #1172, #0
  static fase3 + #1173, #0
  static fase3 + #1174, #0
  static fase3 + #1175, #0
  static fase3 + #1176, #0
  static fase3 + #1177, #0
  static fase3 + #1178, #0
  static fase3 + #1179, #0
  static fase3 + #1180, #0
  static fase3 + #1181, #0
  static fase3 + #1182, #0
  static fase3 + #1183, #0
  static fase3 + #1184, #0
  static fase3 + #1185, #0
  static fase3 + #1186, #0
  static fase3 + #1187, #0
  static fase3 + #1188, #0
  static fase3 + #1189, #0
  static fase3 + #1190, #0
  static fase3 + #1191, #0
  static fase3 + #1192, #0
  static fase3 + #1193, #0
  static fase3 + #1194, #0
  static fase3 + #1195, #0
  static fase3 + #1196, #0
  static fase3 + #1197, #0
  static fase3 + #1198, #0
  static fase3 + #1199, #0
  
  fase4 : var #1200
  ;Linha 0
  static fase4 + #0, #0
  static fase4 + #1, #0
  static fase4 + #2, #0
  static fase4 + #3, #0
  static fase4 + #4, #0
  static fase4 + #5, #0
  static fase4 + #6, #0
  static fase4 + #7, #0
  static fase4 + #8, #0
  static fase4 + #9, #0
  static fase4 + #10, #0
  static fase4 + #11, #0
  static fase4 + #12, #0
  static fase4 + #13, #0
  static fase4 + #14, #0
  static fase4 + #15, #0
  static fase4 + #16, #0
  static fase4 + #17, #0
  static fase4 + #18, #0
  static fase4 + #19, #0
  static fase4 + #20, #0
  static fase4 + #21, #0
  static fase4 + #22, #0
  static fase4 + #23, #0
  static fase4 + #24, #0
  static fase4 + #25, #0
  static fase4 + #26, #0
  static fase4 + #27, #0
  static fase4 + #28, #0
  static fase4 + #29, #0
  static fase4 + #30, #0
  static fase4 + #31, #0
  static fase4 + #32, #0
  static fase4 + #33, #0
  static fase4 + #34, #0
  static fase4 + #35, #0
  static fase4 + #36, #0
  static fase4 + #37, #0
  static fase4 + #38, #0
  static fase4 + #39, #0

  ;Linha 1
  static fase4 + #40, #0
  static fase4 + #41, #3967
  static fase4 + #42, #3967
  static fase4 + #43, #3840
  static fase4 + #44, #0
  static fase4 + #45, #3967
  static fase4 + #46, #0
  static fase4 + #47, #0
  static fase4 + #48, #0
  static fase4 + #49, #0
  static fase4 + #50, #0
  static fase4 + #51, #0
  static fase4 + #52, #0
  static fase4 + #53, #0
  static fase4 + #54, #3967
  static fase4 + #55, #3967
  static fase4 + #56, #3967
  static fase4 + #57, #0
  static fase4 + #58, #3967
  static fase4 + #59, #3967
  static fase4 + #60, #3967
  static fase4 + #61, #3967
  static fase4 + #62, #3967
  static fase4 + #63, #3967
  static fase4 + #64, #3967
  static fase4 + #65, #3967
  static fase4 + #66, #3967
  static fase4 + #67, #3967
  static fase4 + #68, #3967
  static fase4 + #69, #3967
  static fase4 + #70, #3967
  static fase4 + #71, #3967
  static fase4 + #72, #3840
  static fase4 + #73, #3840
  static fase4 + #74, #3840
  static fase4 + #75, #3840
  static fase4 + #76, #0
  static fase4 + #77, #3840
  static fase4 + #78, #3840
  static fase4 + #79, #0

  ;Linha 2
  static fase4 + #80, #0
  static fase4 + #81, #3967
  static fase4 + #82, #3967
  static fase4 + #83, #3840
  static fase4 + #84, #0
  static fase4 + #85, #3967
  static fase4 + #86, #0
  static fase4 + #87, #0
  static fase4 + #88, #0
  static fase4 + #89, #0
  static fase4 + #90, #0
  static fase4 + #91, #0
  static fase4 + #92, #0
  static fase4 + #93, #0
  static fase4 + #94, #3967
  static fase4 + #95, #3967
  static fase4 + #96, #3967
  static fase4 + #97, #0
  static fase4 + #98, #3967
  static fase4 + #99, #3967
  static fase4 + #100, #3967
  static fase4 + #101, #3967
  static fase4 + #102, #3967
  static fase4 + #103, #3967
  static fase4 + #104, #3967
  static fase4 + #105, #3967
  static fase4 + #106, #3967
  static fase4 + #107, #3967
  static fase4 + #108, #3967
  static fase4 + #109, #3967
  static fase4 + #110, #3967
  static fase4 + #111, #3967
  static fase4 + #112, #3967
  static fase4 + #113, #0
  static fase4 + #114, #3967
  static fase4 + #115, #3967
  static fase4 + #116, #0
  static fase4 + #117, #3967
  static fase4 + #118, #3967
  static fase4 + #119, #0

  ;Linha 3
  static fase4 + #120, #0
  static fase4 + #121, #3967
  static fase4 + #122, #3967
  static fase4 + #123, #3840
  static fase4 + #124, #0
  static fase4 + #125, #3967
  static fase4 + #126, #3967
  static fase4 + #127, #3
  static fase4 + #128, #3967
  static fase4 + #129, #3967
  static fase4 + #130, #3967
  static fase4 + #131, #3967
  static fase4 + #132, #3967
  static fase4 + #133, #3967
  static fase4 + #134, #3967
  static fase4 + #135, #3967
  static fase4 + #136, #3967
  static fase4 + #137, #0
  static fase4 + #138, #3967
  static fase4 + #139, #3967
  static fase4 + #140, #3967
  static fase4 + #141, #3967
  static fase4 + #142, #3967
  static fase4 + #143, #3967
  static fase4 + #144, #3967
  static fase4 + #145, #3967
  static fase4 + #146, #3967
  static fase4 + #147, #3967
  static fase4 + #148, #3967
  static fase4 + #149, #3967
  static fase4 + #150, #3967
  static fase4 + #151, #3967
  static fase4 + #152, #3967
  static fase4 + #153, #0
  static fase4 + #154, #3967
  static fase4 + #155, #3967
  static fase4 + #156, #3967
  static fase4 + #157, #3967
  static fase4 + #158, #3967
  static fase4 + #159, #0

  ;Linha 4
  static fase4 + #160, #0
  static fase4 + #161, #3967
  static fase4 + #162, #3967
  static fase4 + #163, #3840
  static fase4 + #164, #0
  static fase4 + #165, #3967
  static fase4 + #166, #0
  static fase4 + #167, #0
  static fase4 + #168, #0
  static fase4 + #169, #0
  static fase4 + #170, #0
  static fase4 + #171, #0
  static fase4 + #172, #0
  static fase4 + #173, #0
  static fase4 + #174, #3967
  static fase4 + #175, #3967
  static fase4 + #176, #3967
  static fase4 + #177, #0
  static fase4 + #178, #3967
  static fase4 + #179, #3967
  static fase4 + #180, #3967
  static fase4 + #181, #0
  static fase4 + #182, #0
  static fase4 + #183, #0
  static fase4 + #184, #0
  static fase4 + #185, #0
  static fase4 + #186, #0
  static fase4 + #187, #0
  static fase4 + #188, #0
  static fase4 + #189, #3967
  static fase4 + #190, #3967
  static fase4 + #191, #0
  static fase4 + #192, #0
  static fase4 + #193, #0
  static fase4 + #194, #0
  static fase4 + #195, #0
  static fase4 + #196, #0
  static fase4 + #197, #0
  static fase4 + #198, #0
  static fase4 + #199, #0

  ;Linha 5
  static fase4 + #200, #0
  static fase4 + #201, #3967
  static fase4 + #202, #3967
  static fase4 + #203, #3840
  static fase4 + #204, #0
  static fase4 + #205, #3967
  static fase4 + #206, #3967
  static fase4 + #207, #3967
  static fase4 + #208, #3967
  static fase4 + #209, #0
  static fase4 + #210, #3967
  static fase4 + #211, #3967
  static fase4 + #212, #3967
  static fase4 + #213, #0
  static fase4 + #214, #3967
  static fase4 + #215, #3967
  static fase4 + #216, #3967
  static fase4 + #217, #0
  static fase4 + #218, #3967
  static fase4 + #219, #3967
  static fase4 + #220, #3967
  static fase4 + #221, #0
  static fase4 + #222, #3967
  static fase4 + #223, #3967
  static fase4 + #224, #3967
  static fase4 + #225, #3
  static fase4 + #226, #3967
  static fase4 + #227, #3967
  static fase4 + #228, #3967
  static fase4 + #229, #3967
  static fase4 + #230, #3967
  static fase4 + #231, #3967
  static fase4 + #232, #3967
  static fase4 + #233, #3967
  static fase4 + #234, #3967
  static fase4 + #235, #3967
  static fase4 + #236, #3967
  static fase4 + #237, #3967
  static fase4 + #238, #3967
  static fase4 + #239, #0

  ;Linha 6
  static fase4 + #240, #0
  static fase4 + #241, #3967
  static fase4 + #242, #3967
  static fase4 + #243, #3840
  static fase4 + #244, #0
  static fase4 + #245, #3967
  static fase4 + #246, #3967
  static fase4 + #247, #3967
  static fase4 + #248, #3967
  static fase4 + #249, #0
  static fase4 + #250, #3967
  static fase4 + #251, #3967
  static fase4 + #252, #3967
  static fase4 + #253, #0
  static fase4 + #254, #3967
  static fase4 + #255, #3967
  static fase4 + #256, #3967
  static fase4 + #257, #0
  static fase4 + #258, #3967
  static fase4 + #259, #3967
  static fase4 + #260, #3967
  static fase4 + #261, #0
  static fase4 + #262, #3967
  static fase4 + #263, #3967
  static fase4 + #264, #3967
  static fase4 + #265, #0
  static fase4 + #266, #0
  static fase4 + #267, #3967
  static fase4 + #268, #3967
  static fase4 + #269, #3967
  static fase4 + #270, #3967
  static fase4 + #271, #3967
  static fase4 + #272, #3967
  static fase4 + #273, #3967
  static fase4 + #274, #3967
  static fase4 + #275, #3967
  static fase4 + #276, #3967
  static fase4 + #277, #3967
  static fase4 + #278, #3967
  static fase4 + #279, #0

  ;Linha 7
  static fase4 + #280, #0
  static fase4 + #281, #3967
  static fase4 + #282, #3967
  static fase4 + #283, #3967
  static fase4 + #284, #0
  static fase4 + #285, #0
  static fase4 + #286, #0
  static fase4 + #287, #3967
  static fase4 + #288, #3967
  static fase4 + #289, #0
  static fase4 + #290, #3967
  static fase4 + #291, #3967
  static fase4 + #292, #3967
  static fase4 + #293, #0
  static fase4 + #294, #3967
  static fase4 + #295, #3967
  static fase4 + #296, #3967
  static fase4 + #297, #0
  static fase4 + #298, #3967
  static fase4 + #299, #3967
  static fase4 + #300, #3967
  static fase4 + #301, #0
  static fase4 + #302, #3967
  static fase4 + #303, #3967
  static fase4 + #304, #3967
  static fase4 + #305, #0
  static fase4 + #306, #3967
  static fase4 + #307, #3967
  static fase4 + #308, #3967
  static fase4 + #309, #3967
  static fase4 + #310, #3967
  static fase4 + #311, #3967
  static fase4 + #312, #3967
  static fase4 + #313, #3967
  static fase4 + #314, #3967
  static fase4 + #315, #0
  static fase4 + #316, #0
  static fase4 + #317, #0
  static fase4 + #318, #0
  static fase4 + #319, #0

  ;Linha 8
  static fase4 + #320, #0
  static fase4 + #321, #3967
  static fase4 + #322, #3967
  static fase4 + #323, #3967
  static fase4 + #324, #3967
  static fase4 + #325, #3967
  static fase4 + #326, #3967
  static fase4 + #327, #3967
  static fase4 + #328, #3967
  static fase4 + #329, #0
  static fase4 + #330, #3967
  static fase4 + #331, #3967
  static fase4 + #332, #3967
  static fase4 + #333, #0
  static fase4 + #334, #3967
  static fase4 + #335, #3967
  static fase4 + #336, #3967
  static fase4 + #337, #0
  static fase4 + #338, #3967
  static fase4 + #339, #3967
  static fase4 + #340, #3967
  static fase4 + #341, #0
  static fase4 + #342, #3967
  static fase4 + #343, #3967
  static fase4 + #344, #3967
  static fase4 + #345, #0
  static fase4 + #346, #0
  static fase4 + #347, #0
  static fase4 + #348, #3967
  static fase4 + #349, #3967
  static fase4 + #350, #0
  static fase4 + #351, #3967
  static fase4 + #352, #3967
  static fase4 + #353, #3967
  static fase4 + #354, #3967
  static fase4 + #355, #3967
  static fase4 + #356, #3967
  static fase4 + #357, #3967
  static fase4 + #358, #3967
  static fase4 + #359, #0

  ;Linha 9
  static fase4 + #360, #0
  static fase4 + #361, #3967
  static fase4 + #362, #3967
  static fase4 + #363, #3967
  static fase4 + #364, #3967
  static fase4 + #365, #3967
  static fase4 + #366, #3967
  static fase4 + #367, #3967
  static fase4 + #368, #3967
  static fase4 + #369, #0
  static fase4 + #370, #3967
  static fase4 + #371, #3967
  static fase4 + #372, #3967
  static fase4 + #373, #0
  static fase4 + #374, #3967
  static fase4 + #375, #3967
  static fase4 + #376, #3967
  static fase4 + #377, #3967
  static fase4 + #378, #3967
  static fase4 + #379, #3967
  static fase4 + #380, #3967
  static fase4 + #381, #0
  static fase4 + #382, #3967
  static fase4 + #383, #3967
  static fase4 + #384, #3967
  static fase4 + #385, #3967
  static fase4 + #386, #3967
  static fase4 + #387, #0
  static fase4 + #388, #3967
  static fase4 + #389, #3967
  static fase4 + #390, #0
  static fase4 + #391, #0
  static fase4 + #392, #0
  static fase4 + #393, #0
  static fase4 + #394, #0
  static fase4 + #395, #0
  static fase4 + #396, #0
  static fase4 + #397, #3967
  static fase4 + #398, #3967
  static fase4 + #399, #0

  ;Linha 10
  static fase4 + #400, #0
  static fase4 + #401, #3967
  static fase4 + #402, #3967
  static fase4 + #403, #3967
  static fase4 + #404, #3967
  static fase4 + #405, #3967
  static fase4 + #406, #3967
  static fase4 + #407, #3967
  static fase4 + #408, #3967
  static fase4 + #409, #0
  static fase4 + #410, #3967
  static fase4 + #411, #3967
  static fase4 + #412, #3967
  static fase4 + #413, #0
  static fase4 + #414, #3967
  static fase4 + #415, #3967
  static fase4 + #416, #3967
  static fase4 + #417, #3967
  static fase4 + #418, #3967
  static fase4 + #419, #3967
  static fase4 + #420, #3967
  static fase4 + #421, #0
  static fase4 + #422, #3967
  static fase4 + #423, #3967
  static fase4 + #424, #3967
  static fase4 + #425, #3967
  static fase4 + #426, #3967
  static fase4 + #427, #0
  static fase4 + #428, #3967
  static fase4 + #429, #3967
  static fase4 + #430, #0
  static fase4 + #431, #3967
  static fase4 + #432, #3967
  static fase4 + #433, #3967
  static fase4 + #434, #3967
  static fase4 + #435, #3967
  static fase4 + #436, #0
  static fase4 + #437, #3967
  static fase4 + #438, #3967
  static fase4 + #439, #0

  ;Linha 11
  static fase4 + #440, #0
  static fase4 + #441, #3967
  static fase4 + #442, #3967
  static fase4 + #443, #3967
  static fase4 + #444, #0
  static fase4 + #445, #0
  static fase4 + #446, #0
  static fase4 + #447, #0
  static fase4 + #448, #0
  static fase4 + #449, #0
  static fase4 + #450, #3967
  static fase4 + #451, #3967
  static fase4 + #452, #3967
  static fase4 + #453, #0
  static fase4 + #454, #0
  static fase4 + #455, #0
  static fase4 + #456, #0
  static fase4 + #457, #0
  static fase4 + #458, #0
  static fase4 + #459, #0
  static fase4 + #460, #0
  static fase4 + #461, #0
  static fase4 + #462, #3967
  static fase4 + #463, #3967
  static fase4 + #464, #3967
  static fase4 + #465, #3967
  static fase4 + #466, #3967
  static fase4 + #467, #0
  static fase4 + #468, #3967
  static fase4 + #469, #3967
  static fase4 + #470, #0
  static fase4 + #471, #3967
  static fase4 + #472, #3967
  static fase4 + #473, #3967
  static fase4 + #474, #3
  static fase4 + #475, #3967
  static fase4 + #476, #0
  static fase4 + #477, #3967
  static fase4 + #478, #3967
  static fase4 + #479, #0

  ;Linha 12
  static fase4 + #480, #0
  static fase4 + #481, #3967
  static fase4 + #482, #3967
  static fase4 + #483, #3967
  static fase4 + #484, #3967
  static fase4 + #485, #3967
  static fase4 + #486, #3967
  static fase4 + #487, #3967
  static fase4 + #488, #3967
  static fase4 + #489, #3967
  static fase4 + #490, #3967
  static fase4 + #491, #3967
  static fase4 + #492, #3967
  static fase4 + #493, #0
  static fase4 + #494, #3967
  static fase4 + #495, #3967
  static fase4 + #496, #3967
  static fase4 + #497, #3967
  static fase4 + #498, #3967
  static fase4 + #499, #3967
  static fase4 + #500, #3967
  static fase4 + #501, #3967
  static fase4 + #502, #3967
  static fase4 + #503, #3967
  static fase4 + #504, #3
  static fase4 + #505, #3967
  static fase4 + #506, #3967
  static fase4 + #507, #0
  static fase4 + #508, #3967
  static fase4 + #509, #3967
  static fase4 + #510, #0
  static fase4 + #511, #3967
  static fase4 + #512, #3967
  static fase4 + #513, #0
  static fase4 + #514, #0
  static fase4 + #515, #0
  static fase4 + #516, #0
  static fase4 + #517, #3967
  static fase4 + #518, #3967
  static fase4 + #519, #0

  ;Linha 13
  static fase4 + #520, #0
  static fase4 + #521, #3967
  static fase4 + #522, #3967
  static fase4 + #523, #3967
  static fase4 + #524, #3967
  static fase4 + #525, #3967
  static fase4 + #526, #3967
  static fase4 + #527, #3967
  static fase4 + #528, #3967
  static fase4 + #529, #3967
  static fase4 + #530, #3967
  static fase4 + #531, #3967
  static fase4 + #532, #3967
  static fase4 + #533, #0
  static fase4 + #534, #3967
  static fase4 + #535, #3967
  static fase4 + #536, #3967
  static fase4 + #537, #3967
  static fase4 + #538, #3967
  static fase4 + #539, #3967
  static fase4 + #540, #3840
  static fase4 + #541, #3840
  static fase4 + #542, #3840
  static fase4 + #543, #3840
  static fase4 + #544, #3840
  static fase4 + #545, #3840
  static fase4 + #546, #3840
  static fase4 + #547, #0
  static fase4 + #548, #3967
  static fase4 + #549, #3967
  static fase4 + #550, #0
  static fase4 + #551, #3967
  static fase4 + #552, #3967
  static fase4 + #553, #0
  static fase4 + #554, #3967
  static fase4 + #555, #3967
  static fase4 + #556, #3967
  static fase4 + #557, #3967
  static fase4 + #558, #3967
  static fase4 + #559, #0

  ;Linha 14
  static fase4 + #560, #0
  static fase4 + #561, #3967
  static fase4 + #562, #3967
  static fase4 + #563, #3967
  static fase4 + #564, #3967
  static fase4 + #565, #3967
  static fase4 + #566, #3967
  static fase4 + #567, #3967
  static fase4 + #568, #3967
  static fase4 + #569, #3967
  static fase4 + #570, #3967
  static fase4 + #571, #3967
  static fase4 + #572, #127
  static fase4 + #573, #0
  static fase4 + #574, #3967
  static fase4 + #575, #3967
  static fase4 + #576, #3967
  static fase4 + #577, #3967
  static fase4 + #578, #3967
  static fase4 + #579, #3967
  static fase4 + #580, #3967
  static fase4 + #581, #3967
  static fase4 + #582, #3967
  static fase4 + #583, #3967
  static fase4 + #584, #3967
  static fase4 + #585, #3967
  static fase4 + #586, #3967
  static fase4 + #587, #0
  static fase4 + #588, #3967
  static fase4 + #589, #3967
  static fase4 + #590, #0
  static fase4 + #591, #3967
  static fase4 + #592, #3967
  static fase4 + #593, #0
  static fase4 + #594, #3967
  static fase4 + #595, #3967
  static fase4 + #596, #3967
  static fase4 + #597, #3967
  static fase4 + #598, #3
  static fase4 + #599, #0

  ;Linha 15
  static fase4 + #600, #0
  static fase4 + #601, #3967
  static fase4 + #602, #3967
  static fase4 + #603, #3967
  static fase4 + #604, #3967
  static fase4 + #605, #3967
  static fase4 + #606, #3967
  static fase4 + #607, #3967
  static fase4 + #608, #3967
  static fase4 + #609, #3967
  static fase4 + #610, #3967
  static fase4 + #611, #3967
  static fase4 + #612, #127
  static fase4 + #613, #0
  static fase4 + #614, #0
  static fase4 + #615, #0
  static fase4 + #616, #0
  static fase4 + #617, #0
  static fase4 + #618, #0
  static fase4 + #619, #0
  static fase4 + #620, #0
  static fase4 + #621, #0
  static fase4 + #622, #0
  static fase4 + #623, #0
  static fase4 + #624, #0
  static fase4 + #625, #0
  static fase4 + #626, #0
  static fase4 + #627, #0
  static fase4 + #628, #3967
  static fase4 + #629, #3967
  static fase4 + #630, #0
  static fase4 + #631, #3967
  static fase4 + #632, #3967
  static fase4 + #633, #0
  static fase4 + #634, #3967
  static fase4 + #635, #3967
  static fase4 + #636, #3967
  static fase4 + #637, #3967
  static fase4 + #638, #3967
  static fase4 + #639, #0

  ;Linha 16
  static fase4 + #640, #0
  static fase4 + #641, #0
  static fase4 + #642, #0
  static fase4 + #643, #0
  static fase4 + #644, #0
  static fase4 + #645, #0
  static fase4 + #646, #0
  static fase4 + #647, #0
  static fase4 + #648, #0
  static fase4 + #649, #0
  static fase4 + #650, #3967
  static fase4 + #651, #3967
  static fase4 + #652, #127
  static fase4 + #653, #0
  static fase4 + #654, #3967
  static fase4 + #655, #3967
  static fase4 + #656, #3967
  static fase4 + #657, #3967
  static fase4 + #658, #3967
  static fase4 + #659, #3967
  static fase4 + #660, #3967
  static fase4 + #661, #3967
  static fase4 + #662, #3967
  static fase4 + #663, #3967
  static fase4 + #664, #3967
  static fase4 + #665, #3967
  static fase4 + #666, #3967
  static fase4 + #667, #0
  static fase4 + #668, #3967
  static fase4 + #669, #3967
  static fase4 + #670, #0
  static fase4 + #671, #3967
  static fase4 + #672, #3967
  static fase4 + #673, #0
  static fase4 + #674, #0
  static fase4 + #675, #0
  static fase4 + #676, #0
  static fase4 + #677, #3967
  static fase4 + #678, #3967
  static fase4 + #679, #0

  ;Linha 17
  static fase4 + #680, #0
  static fase4 + #681, #3967
  static fase4 + #682, #3967
  static fase4 + #683, #3967
  static fase4 + #684, #3967
  static fase4 + #685, #3967
  static fase4 + #686, #3967
  static fase4 + #687, #3967
  static fase4 + #688, #3967
  static fase4 + #689, #0
  static fase4 + #690, #3967
  static fase4 + #691, #3967
  static fase4 + #692, #3967
  static fase4 + #693, #0
  static fase4 + #694, #3967
  static fase4 + #695, #3967
  static fase4 + #696, #3967
  static fase4 + #697, #3967
  static fase4 + #698, #3967
  static fase4 + #699, #3967
  static fase4 + #700, #3967
  static fase4 + #701, #3967
  static fase4 + #702, #3967
  static fase4 + #703, #3967
  static fase4 + #704, #3967
  static fase4 + #705, #3967
  static fase4 + #706, #3967
  static fase4 + #707, #0
  static fase4 + #708, #3967
  static fase4 + #709, #3967
  static fase4 + #710, #0
  static fase4 + #711, #3967
  static fase4 + #712, #3967
  static fase4 + #713, #3967
  static fase4 + #714, #3967
  static fase4 + #715, #3967
  static fase4 + #716, #0
  static fase4 + #717, #3967
  static fase4 + #718, #3967
  static fase4 + #719, #0

  ;Linha 18
  static fase4 + #720, #0
  static fase4 + #721, #3967
  static fase4 + #722, #3
  static fase4 + #723, #3967
  static fase4 + #724, #3967
  static fase4 + #725, #3967
  static fase4 + #726, #3967
  static fase4 + #727, #3967
  static fase4 + #728, #3967
  static fase4 + #729, #0
  static fase4 + #730, #3967
  static fase4 + #731, #3967
  static fase4 + #732, #3967
  static fase4 + #733, #0
  static fase4 + #734, #3967
  static fase4 + #735, #3967
  static fase4 + #736, #3967
  static fase4 + #737, #3967
  static fase4 + #738, #3967
  static fase4 + #739, #3967
  static fase4 + #740, #3967
  static fase4 + #741, #3967
  static fase4 + #742, #3967
  static fase4 + #743, #3967
  static fase4 + #744, #3967
  static fase4 + #745, #3967
  static fase4 + #746, #3967
  static fase4 + #747, #3967
  static fase4 + #748, #3967
  static fase4 + #749, #3967
  static fase4 + #750, #0
  static fase4 + #751, #0
  static fase4 + #752, #0
  static fase4 + #753, #3967
  static fase4 + #754, #3967
  static fase4 + #755, #3967
  static fase4 + #756, #0
  static fase4 + #757, #3967
  static fase4 + #758, #3967
  static fase4 + #759, #0

  ;Linha 19
  static fase4 + #760, #0
  static fase4 + #761, #3967
  static fase4 + #762, #0
  static fase4 + #763, #0
  static fase4 + #764, #0
  static fase4 + #765, #0
  static fase4 + #766, #3967
  static fase4 + #767, #3967
  static fase4 + #768, #3967
  static fase4 + #769, #0
  static fase4 + #770, #0
  static fase4 + #771, #0
  static fase4 + #772, #0
  static fase4 + #773, #0
  static fase4 + #774, #3967
  static fase4 + #775, #3967
  static fase4 + #776, #3967
  static fase4 + #777, #3967
  static fase4 + #778, #3967
  static fase4 + #779, #3967
  static fase4 + #780, #3967
  static fase4 + #781, #0
  static fase4 + #782, #0
  static fase4 + #783, #0
  static fase4 + #784, #0
  static fase4 + #785, #3967
  static fase4 + #786, #3967
  static fase4 + #787, #3967
  static fase4 + #788, #3967
  static fase4 + #789, #3967
  static fase4 + #790, #3967
  static fase4 + #791, #3967
  static fase4 + #792, #3967
  static fase4 + #793, #3967
  static fase4 + #794, #3967
  static fase4 + #795, #3967
  static fase4 + #796, #0
  static fase4 + #797, #3967
  static fase4 + #798, #3967
  static fase4 + #799, #0

  ;Linha 20
  static fase4 + #800, #0
  static fase4 + #801, #3967
  static fase4 + #802, #3967
  static fase4 + #803, #3967
  static fase4 + #804, #3967
  static fase4 + #805, #0
  static fase4 + #806, #3967
  static fase4 + #807, #3967
  static fase4 + #808, #3967
  static fase4 + #809, #3967
  static fase4 + #810, #3967
  static fase4 + #811, #3967
  static fase4 + #812, #3967
  static fase4 + #813, #3967
  static fase4 + #814, #3967
  static fase4 + #815, #3967
  static fase4 + #816, #3967
  static fase4 + #817, #3
  static fase4 + #818, #3967
  static fase4 + #819, #3967
  static fase4 + #820, #3967
  static fase4 + #821, #0
  static fase4 + #822, #3967
  static fase4 + #823, #3967
  static fase4 + #824, #0
  static fase4 + #825, #0
  static fase4 + #826, #0
  static fase4 + #827, #0
  static fase4 + #828, #0
  static fase4 + #829, #0
  static fase4 + #830, #0
  static fase4 + #831, #0
  static fase4 + #832, #0
  static fase4 + #833, #3967
  static fase4 + #834, #3967
  static fase4 + #835, #0
  static fase4 + #836, #0
  static fase4 + #837, #0
  static fase4 + #838, #0
  static fase4 + #839, #0

  ;Linha 21
  static fase4 + #840, #0
  static fase4 + #841, #3967
  static fase4 + #842, #3967
  static fase4 + #843, #3967
  static fase4 + #844, #3967
  static fase4 + #845, #0
  static fase4 + #846, #3967
  static fase4 + #847, #3967
  static fase4 + #848, #3967
  static fase4 + #849, #3967
  static fase4 + #850, #3967
  static fase4 + #851, #3967
  static fase4 + #852, #3967
  static fase4 + #853, #3967
  static fase4 + #854, #3967
  static fase4 + #855, #3967
  static fase4 + #856, #3967
  static fase4 + #857, #3967
  static fase4 + #858, #3967
  static fase4 + #859, #3967
  static fase4 + #860, #3967
  static fase4 + #861, #0
  static fase4 + #862, #3967
  static fase4 + #863, #3967
  static fase4 + #864, #3967
  static fase4 + #865, #3967
  static fase4 + #866, #3967
  static fase4 + #867, #3967
  static fase4 + #868, #3967
  static fase4 + #869, #3
  static fase4 + #870, #3967
  static fase4 + #871, #3967
  static fase4 + #872, #3967
  static fase4 + #873, #3967
  static fase4 + #874, #3967
  static fase4 + #875, #0
  static fase4 + #876, #3967
  static fase4 + #877, #3967
  static fase4 + #878, #3967
  static fase4 + #879, #0

  ;Linha 22
  static fase4 + #880, #0
  static fase4 + #881, #3967
  static fase4 + #882, #3967
  static fase4 + #883, #3967
  static fase4 + #884, #3967
  static fase4 + #885, #0
  static fase4 + #886, #3967
  static fase4 + #887, #3967
  static fase4 + #888, #3967
  static fase4 + #889, #3967
  static fase4 + #890, #3967
  static fase4 + #891, #3967
  static fase4 + #892, #3967
  static fase4 + #893, #3967
  static fase4 + #894, #3967
  static fase4 + #895, #3967
  static fase4 + #896, #3967
  static fase4 + #897, #3840
  static fase4 + #898, #3840
  static fase4 + #899, #3967
  static fase4 + #900, #3967
  static fase4 + #901, #0
  static fase4 + #902, #3967
  static fase4 + #903, #3967
  static fase4 + #904, #3967
  static fase4 + #905, #3967
  static fase4 + #906, #0
  static fase4 + #907, #0
  static fase4 + #908, #0
  static fase4 + #909, #0
  static fase4 + #910, #0
  static fase4 + #911, #3967
  static fase4 + #912, #3967
  static fase4 + #913, #3967
  static fase4 + #914, #3967
  static fase4 + #915, #0
  static fase4 + #916, #3967
  static fase4 + #917, #3967
  static fase4 + #918, #3967
  static fase4 + #919, #0

  ;Linha 23
  static fase4 + #920, #0
  static fase4 + #921, #3967
  static fase4 + #922, #3967
  static fase4 + #923, #3967
  static fase4 + #924, #3967
  static fase4 + #925, #0
  static fase4 + #926, #0
  static fase4 + #927, #0
  static fase4 + #928, #0
  static fase4 + #929, #0
  static fase4 + #930, #0
  static fase4 + #931, #0
  static fase4 + #932, #0
  static fase4 + #933, #0
  static fase4 + #934, #0
  static fase4 + #935, #0
  static fase4 + #936, #0
  static fase4 + #937, #0
  static fase4 + #938, #0
  static fase4 + #939, #0
  static fase4 + #940, #0
  static fase4 + #941, #0
  static fase4 + #942, #3967
  static fase4 + #943, #3967
  static fase4 + #944, #0
  static fase4 + #945, #0
  static fase4 + #946, #0
  static fase4 + #947, #3967
  static fase4 + #948, #3967
  static fase4 + #949, #3967
  static fase4 + #950, #0
  static fase4 + #951, #3967
  static fase4 + #952, #3967
  static fase4 + #953, #3967
  static fase4 + #954, #3967
  static fase4 + #955, #0
  static fase4 + #956, #3967
  static fase4 + #957, #3967
  static fase4 + #958, #3967
  static fase4 + #959, #0

  ;Linha 24
  static fase4 + #960, #0
  static fase4 + #961, #3967
  static fase4 + #962, #3967
  static fase4 + #963, #3967
  static fase4 + #964, #3967
  static fase4 + #965, #3967
  static fase4 + #966, #3967
  static fase4 + #967, #3967
  static fase4 + #968, #3967
  static fase4 + #969, #3967
  static fase4 + #970, #3967
  static fase4 + #971, #3967
  static fase4 + #972, #3967
  static fase4 + #973, #3967
  static fase4 + #974, #3967
  static fase4 + #975, #3967
  static fase4 + #976, #3967
  static fase4 + #977, #3967
  static fase4 + #978, #3967
  static fase4 + #979, #3967
  static fase4 + #980, #3967
  static fase4 + #981, #0
  static fase4 + #982, #3967
  static fase4 + #983, #3967
  static fase4 + #984, #0
  static fase4 + #985, #3967
  static fase4 + #986, #3967
  static fase4 + #987, #3967
  static fase4 + #988, #3967
  static fase4 + #989, #3967
  static fase4 + #990, #0
  static fase4 + #991, #3967
  static fase4 + #992, #3967
  static fase4 + #993, #3967
  static fase4 + #994, #3967
  static fase4 + #995, #0
  static fase4 + #996, #3967
  static fase4 + #997, #3967
  static fase4 + #998, #3967
  static fase4 + #999, #0

  ;Linha 25
  static fase4 + #1000, #0
  static fase4 + #1001, #3967
  static fase4 + #1002, #3967
  static fase4 + #1003, #3967
  static fase4 + #1004, #3967
  static fase4 + #1005, #3967
  static fase4 + #1006, #3967
  static fase4 + #1007, #3967
  static fase4 + #1008, #3967
  static fase4 + #1009, #3967
  static fase4 + #1010, #3967
  static fase4 + #1011, #3967
  static fase4 + #1012, #3967
  static fase4 + #1013, #3967
  static fase4 + #1014, #3967
  static fase4 + #1015, #3967
  static fase4 + #1016, #3967
  static fase4 + #1017, #3967
  static fase4 + #1018, #3967
  static fase4 + #1019, #3967
  static fase4 + #1020, #3967
  static fase4 + #1021, #0
  static fase4 + #1022, #3967
  static fase4 + #1023, #3967
  static fase4 + #1024, #0
  static fase4 + #1025, #3967
  static fase4 + #1026, #3967
  static fase4 + #1027, #3967
  static fase4 + #1028, #0
  static fase4 + #1029, #0
  static fase4 + #1030, #0
  static fase4 + #1031, #3967
  static fase4 + #1032, #3967
  static fase4 + #1033, #0
  static fase4 + #1034, #0
  static fase4 + #1035, #0
  static fase4 + #1036, #3967
  static fase4 + #1037, #3967
  static fase4 + #1038, #3967
  static fase4 + #1039, #0

  ;Linha 26
  static fase4 + #1040, #0
  static fase4 + #1041, #3967
  static fase4 + #1042, #3967
  static fase4 + #1043, #3967
  static fase4 + #1044, #3967
  static fase4 + #1045, #3967
  static fase4 + #1046, #3967
  static fase4 + #1047, #3967
  static fase4 + #1048, #3967
  static fase4 + #1049, #3967
  static fase4 + #1050, #3967
  static fase4 + #1051, #3967
  static fase4 + #1052, #3967
  static fase4 + #1053, #3967
  static fase4 + #1054, #3967
  static fase4 + #1055, #3967
  static fase4 + #1056, #3967
  static fase4 + #1057, #3967
  static fase4 + #1058, #3967
  static fase4 + #1059, #3967
  static fase4 + #1060, #3967
  static fase4 + #1061, #0
  static fase4 + #1062, #3
  static fase4 + #1063, #3967
  static fase4 + #1064, #0
  static fase4 + #1065, #3967
  static fase4 + #1066, #3967
  static fase4 + #1067, #3967
  static fase4 + #1068, #3967
  static fase4 + #1069, #3967
  static fase4 + #1070, #3967
  static fase4 + #1071, #3967
  static fase4 + #1072, #3967
  static fase4 + #1073, #3967
  static fase4 + #1074, #3967
  static fase4 + #1075, #3
  static fase4 + #1076, #3967
  static fase4 + #1077, #3967
  static fase4 + #1078, #31
  static fase4 + #1079, #0

  ;Linha 27
  static fase4 + #1080, #0
  static fase4 + #1081, #3967
  static fase4 + #1082, #3967
  static fase4 + #1083, #3967
  static fase4 + #1084, #3967
  static fase4 + #1085, #3967
  static fase4 + #1086, #3967
  static fase4 + #1087, #3967
  static fase4 + #1088, #3967
  static fase4 + #1089, #3967
  static fase4 + #1090, #3967
  static fase4 + #1091, #3967
  static fase4 + #1092, #3967
  static fase4 + #1093, #3967
  static fase4 + #1094, #3967
  static fase4 + #1095, #3967
  static fase4 + #1096, #3967
  static fase4 + #1097, #3967
  static fase4 + #1098, #3967
  static fase4 + #1099, #3967
  static fase4 + #1100, #3967
  static fase4 + #1101, #3967
  static fase4 + #1102, #3967
  static fase4 + #1103, #3967
  static fase4 + #1104, #0
  static fase4 + #1105, #3967
  static fase4 + #1106, #3967
  static fase4 + #1107, #3967
  static fase4 + #1108, #0
  static fase4 + #1109, #3967
  static fase4 + #1110, #3967
  static fase4 + #1111, #3967
  static fase4 + #1112, #3967
  static fase4 + #1113, #0
  static fase4 + #1114, #0
  static fase4 + #1115, #0
  static fase4 + #1116, #0
  static fase4 + #1117, #0
  static fase4 + #1118, #0
  static fase4 + #1119, #0

  ;Linha 28
  static fase4 + #1120, #0
  static fase4 + #1121, #3967
  static fase4 + #1122, #3967
  static fase4 + #1123, #3967
  static fase4 + #1124, #3967
  static fase4 + #1125, #3967
  static fase4 + #1126, #3967
  static fase4 + #1127, #3967
  static fase4 + #1128, #3967
  static fase4 + #1129, #3967
  static fase4 + #1130, #3967
  static fase4 + #1131, #3967
  static fase4 + #1132, #3967
  static fase4 + #1133, #3967
  static fase4 + #1134, #3967
  static fase4 + #1135, #3967
  static fase4 + #1136, #3967
  static fase4 + #1137, #3967
  static fase4 + #1138, #3967
  static fase4 + #1139, #3967
  static fase4 + #1140, #3967
  static fase4 + #1141, #3967
  static fase4 + #1142, #3967
  static fase4 + #1143, #3967
  static fase4 + #1144, #0
  static fase4 + #1145, #3967
  static fase4 + #1146, #3967
  static fase4 + #1147, #3967
  static fase4 + #1148, #0
  static fase4 + #1149, #3967
  static fase4 + #1150, #3967
  static fase4 + #1151, #3967
  static fase4 + #1152, #3967
  static fase4 + #1153, #3967
  static fase4 + #1154, #31
  static fase4 + #1155, #31
  static fase4 + #1156, #31
  static fase4 + #1157, #3967
  static fase4 + #1158, #514
  static fase4 + #1159, #0

  ;Linha 29
  static fase4 + #1160, #0
  static fase4 + #1161, #0
  static fase4 + #1162, #0
  static fase4 + #1163, #0
  static fase4 + #1164, #0
  static fase4 + #1165, #0
  static fase4 + #1166, #0
  static fase4 + #1167, #0
  static fase4 + #1168, #0
  static fase4 + #1169, #0
  static fase4 + #1170, #0
  static fase4 + #1171, #0
  static fase4 + #1172, #0
  static fase4 + #1173, #0
  static fase4 + #1174, #0
  static fase4 + #1175, #0
  static fase4 + #1176, #0
  static fase4 + #1177, #0
  static fase4 + #1178, #0
  static fase4 + #1179, #0
  static fase4 + #1180, #0
  static fase4 + #1181, #0
  static fase4 + #1182, #0
  static fase4 + #1183, #0
  static fase4 + #1184, #0
  static fase4 + #1185, #0
  static fase4 + #1186, #0
  static fase4 + #1187, #0
  static fase4 + #1188, #0
  static fase4 + #1189, #0
  static fase4 + #1190, #0
  static fase4 + #1191, #0
  static fase4 + #1192, #0
  static fase4 + #1193, #0
  static fase4 + #1194, #0
  static fase4 + #1195, #0
  static fase4 + #1196, #0
  static fase4 + #1197, #0
  static fase4 + #1198, #0
  static fase4 + #1199, #0

fase5 : var #1200
  ;Linha 0
  static fase5 + #0, #0
  static fase5 + #1, #0
  static fase5 + #2, #0
  static fase5 + #3, #0
  static fase5 + #4, #0
  static fase5 + #5, #0
  static fase5 + #6, #0
  static fase5 + #7, #0
  static fase5 + #8, #0
  static fase5 + #9, #0
  static fase5 + #10, #0
  static fase5 + #11, #0
  static fase5 + #12, #0
  static fase5 + #13, #0
  static fase5 + #14, #0
  static fase5 + #15, #0
  static fase5 + #16, #0
  static fase5 + #17, #0
  static fase5 + #18, #0
  static fase5 + #19, #0
  static fase5 + #20, #0
  static fase5 + #21, #0
  static fase5 + #22, #0
  static fase5 + #23, #0
  static fase5 + #24, #0
  static fase5 + #25, #0
  static fase5 + #26, #0
  static fase5 + #27, #0
  static fase5 + #28, #0
  static fase5 + #29, #0
  static fase5 + #30, #0
  static fase5 + #31, #0
  static fase5 + #32, #0
  static fase5 + #33, #0
  static fase5 + #34, #0
  static fase5 + #35, #0
  static fase5 + #36, #0
  static fase5 + #37, #0
  static fase5 + #38, #0
  static fase5 + #39, #0

  ;Linha 1
  static fase5 + #40, #0
  static fase5 + #41, #3967
  static fase5 + #42, #3967
  static fase5 + #43, #3967
  static fase5 + #44, #3967
  static fase5 + #45, #3967
  static fase5 + #46, #0
  static fase5 + #47, #3967
  static fase5 + #48, #3967
  static fase5 + #49, #3967
  static fase5 + #50, #3967
  static fase5 + #51, #3967
  static fase5 + #52, #3967
  static fase5 + #53, #0
  static fase5 + #54, #3967
  static fase5 + #55, #3967
  static fase5 + #56, #3967
  static fase5 + #57, #3967
  static fase5 + #58, #3967
  static fase5 + #59, #3967
  static fase5 + #60, #3967
  static fase5 + #61, #3967
  static fase5 + #62, #3967
  static fase5 + #63, #3967
  static fase5 + #64, #3967
  static fase5 + #65, #3967
  static fase5 + #66, #3967
  static fase5 + #67, #3967
  static fase5 + #68, #0
  static fase5 + #69, #3967
  static fase5 + #70, #3967
  static fase5 + #71, #3967
  static fase5 + #72, #3967
  static fase5 + #73, #3967
  static fase5 + #74, #3967
  static fase5 + #75, #3967
  static fase5 + #76, #3967
  static fase5 + #77, #3967
  static fase5 + #78, #3967
  static fase5 + #79, #0

  ;Linha 2
  static fase5 + #80, #0
  static fase5 + #81, #3967
  static fase5 + #82, #3967
  static fase5 + #83, #3967
  static fase5 + #84, #3967
  static fase5 + #85, #3967
  static fase5 + #86, #0
  static fase5 + #87, #3967
  static fase5 + #88, #3967
  static fase5 + #89, #3967
  static fase5 + #90, #3967
  static fase5 + #91, #3967
  static fase5 + #92, #3967
  static fase5 + #93, #0
  static fase5 + #94, #3967
  static fase5 + #95, #3967
  static fase5 + #96, #3967
  static fase5 + #97, #3967
  static fase5 + #98, #3967
  static fase5 + #99, #3967
  static fase5 + #100, #3967
  static fase5 + #101, #3967
  static fase5 + #102, #3967
  static fase5 + #103, #3967
  static fase5 + #104, #3967
  static fase5 + #105, #3967
  static fase5 + #106, #3967
  static fase5 + #107, #3967
  static fase5 + #108, #0
  static fase5 + #109, #3967
  static fase5 + #110, #3967
  static fase5 + #111, #3967
  static fase5 + #112, #3967
  static fase5 + #113, #3967
  static fase5 + #114, #3967
  static fase5 + #115, #3967
  static fase5 + #116, #3967
  static fase5 + #117, #3967
  static fase5 + #118, #3967
  static fase5 + #119, #0

  ;Linha 3
  static fase5 + #120, #0
  static fase5 + #121, #3967
  static fase5 + #122, #3967
  static fase5 + #123, #3967
  static fase5 + #124, #3967
  static fase5 + #125, #3967
  static fase5 + #126, #0
  static fase5 + #127, #3967
  static fase5 + #128, #3967
  static fase5 + #129, #3967
  static fase5 + #130, #3967
  static fase5 + #131, #3967
  static fase5 + #132, #3967
  static fase5 + #133, #0
  static fase5 + #134, #0
  static fase5 + #135, #3967
  static fase5 + #136, #3967
  static fase5 + #137, #3967
  static fase5 + #138, #3967
  static fase5 + #139, #3967
  static fase5 + #140, #3967
  static fase5 + #141, #3967
  static fase5 + #142, #3967
  static fase5 + #143, #0
  static fase5 + #144, #3967
  static fase5 + #145, #3967
  static fase5 + #146, #3967
  static fase5 + #147, #3967
  static fase5 + #148, #0
  static fase5 + #149, #3967
  static fase5 + #150, #3967
  static fase5 + #151, #3967
  static fase5 + #152, #3967
  static fase5 + #153, #3967
  static fase5 + #154, #3967
  static fase5 + #155, #3967
  static fase5 + #156, #3967
  static fase5 + #157, #3967
  static fase5 + #158, #3967
  static fase5 + #159, #0

  ;Linha 4
  static fase5 + #160, #0
  static fase5 + #161, #3967
  static fase5 + #162, #3967
  static fase5 + #163, #3967
  static fase5 + #164, #3967
  static fase5 + #165, #3967
  static fase5 + #166, #0
  static fase5 + #167, #3967
  static fase5 + #168, #3967
  static fase5 + #169, #3967
  static fase5 + #170, #3967
  static fase5 + #171, #3967
  static fase5 + #172, #3967
  static fase5 + #173, #3967
  static fase5 + #174, #0
  static fase5 + #175, #0
  static fase5 + #176, #0
  static fase5 + #177, #0
  static fase5 + #178, #0
  static fase5 + #179, #0
  static fase5 + #180, #0
  static fase5 + #181, #0
  static fase5 + #182, #0
  static fase5 + #183, #0
  static fase5 + #184, #3967
  static fase5 + #185, #3967
  static fase5 + #186, #3967
  static fase5 + #187, #3967
  static fase5 + #188, #0
  static fase5 + #189, #3967
  static fase5 + #190, #3967
  static fase5 + #191, #3967
  static fase5 + #192, #3967
  static fase5 + #193, #3967
  static fase5 + #194, #3967
  static fase5 + #195, #3967
  static fase5 + #196, #3967
  static fase5 + #197, #3967
  static fase5 + #198, #3967
  static fase5 + #199, #0

  ;Linha 5
  static fase5 + #200, #0
  static fase5 + #201, #3967
  static fase5 + #202, #3967
  static fase5 + #203, #3967
  static fase5 + #204, #3967
  static fase5 + #205, #3967
  static fase5 + #206, #0
  static fase5 + #207, #3967
  static fase5 + #208, #3967
  static fase5 + #209, #3967
  static fase5 + #210, #3967
  static fase5 + #211, #3967
  static fase5 + #212, #3967
  static fase5 + #213, #3967
  static fase5 + #214, #3967
  static fase5 + #215, #3967
  static fase5 + #216, #3967
  static fase5 + #217, #3967
  static fase5 + #218, #3967
  static fase5 + #219, #3
  static fase5 + #220, #3967
  static fase5 + #221, #3967
  static fase5 + #222, #3967
  static fase5 + #223, #3967
  static fase5 + #224, #3967
  static fase5 + #225, #3967
  static fase5 + #226, #3967
  static fase5 + #227, #3967
  static fase5 + #228, #0
  static fase5 + #229, #3967
  static fase5 + #230, #3967
  static fase5 + #231, #0
  static fase5 + #232, #3967
  static fase5 + #233, #3967
  static fase5 + #234, #3967
  static fase5 + #235, #0
  static fase5 + #236, #3967
  static fase5 + #237, #3967
  static fase5 + #238, #3967
  static fase5 + #239, #0

  ;Linha 6
  static fase5 + #240, #0
  static fase5 + #241, #3967
  static fase5 + #242, #3967
  static fase5 + #243, #3967
  static fase5 + #244, #3967
  static fase5 + #245, #3967
  static fase5 + #246, #0
  static fase5 + #247, #3967
  static fase5 + #248, #3967
  static fase5 + #249, #3967
  static fase5 + #250, #3967
  static fase5 + #251, #3967
  static fase5 + #252, #3967
  static fase5 + #253, #3967
  static fase5 + #254, #3967
  static fase5 + #255, #3967
  static fase5 + #256, #3967
  static fase5 + #257, #3967
  static fase5 + #258, #3967
  static fase5 + #259, #3967
  static fase5 + #260, #3967
  static fase5 + #261, #3967
  static fase5 + #262, #3967
  static fase5 + #263, #3967
  static fase5 + #264, #3967
  static fase5 + #265, #3967
  static fase5 + #266, #3967
  static fase5 + #267, #3967
  static fase5 + #268, #0
  static fase5 + #269, #3967
  static fase5 + #270, #3967
  static fase5 + #271, #0
  static fase5 + #272, #3967
  static fase5 + #273, #3967
  static fase5 + #274, #3967
  static fase5 + #275, #0
  static fase5 + #276, #3967
  static fase5 + #277, #3
  static fase5 + #278, #3967
  static fase5 + #279, #0

  ;Linha 7
  static fase5 + #280, #0
  static fase5 + #281, #3967
  static fase5 + #282, #3967
  static fase5 + #283, #3967
  static fase5 + #284, #3967
  static fase5 + #285, #3967
  static fase5 + #286, #0
  static fase5 + #287, #3967
  static fase5 + #288, #3967
  static fase5 + #289, #3967
  static fase5 + #290, #3967
  static fase5 + #291, #3967
  static fase5 + #292, #3967
  static fase5 + #293, #3967
  static fase5 + #294, #3967
  static fase5 + #295, #3967
  static fase5 + #296, #3967
  static fase5 + #297, #3967
  static fase5 + #298, #3967
  static fase5 + #299, #3967
  static fase5 + #300, #3967
  static fase5 + #301, #3967
  static fase5 + #302, #3967
  static fase5 + #303, #3967
  static fase5 + #304, #3967
  static fase5 + #305, #3967
  static fase5 + #306, #3967
  static fase5 + #307, #3967
  static fase5 + #308, #0
  static fase5 + #309, #3967
  static fase5 + #310, #3967
  static fase5 + #311, #0
  static fase5 + #312, #3967
  static fase5 + #313, #3967
  static fase5 + #314, #3967
  static fase5 + #315, #0
  static fase5 + #316, #3967
  static fase5 + #317, #3967
  static fase5 + #318, #3967
  static fase5 + #319, #0

  ;Linha 8
  static fase5 + #320, #0
  static fase5 + #321, #3967
  static fase5 + #322, #127
  static fase5 + #323, #127
  static fase5 + #324, #127
  static fase5 + #325, #3967
  static fase5 + #326, #0
  static fase5 + #327, #3967
  static fase5 + #328, #3967
  static fase5 + #329, #3967
  static fase5 + #330, #3967
  static fase5 + #331, #3967
  static fase5 + #332, #3967
  static fase5 + #333, #0
  static fase5 + #334, #0
  static fase5 + #335, #0
  static fase5 + #336, #0
  static fase5 + #337, #0
  static fase5 + #338, #0
  static fase5 + #339, #0
  static fase5 + #340, #0
  static fase5 + #341, #0
  static fase5 + #342, #0
  static fase5 + #343, #0
  static fase5 + #344, #0
  static fase5 + #345, #3967
  static fase5 + #346, #3967
  static fase5 + #347, #3967
  static fase5 + #348, #0
  static fase5 + #349, #3967
  static fase5 + #350, #3967
  static fase5 + #351, #0
  static fase5 + #352, #3967
  static fase5 + #353, #3967
  static fase5 + #354, #3967
  static fase5 + #355, #0
  static fase5 + #356, #0
  static fase5 + #357, #3967
  static fase5 + #358, #3967
  static fase5 + #359, #0

  ;Linha 9
  static fase5 + #360, #0
  static fase5 + #361, #3967
  static fase5 + #362, #3967
  static fase5 + #363, #3967
  static fase5 + #364, #3967
  static fase5 + #365, #3967
  static fase5 + #366, #3967
  static fase5 + #367, #3967
  static fase5 + #368, #3967
  static fase5 + #369, #3967
  static fase5 + #370, #3967
  static fase5 + #371, #3967
  static fase5 + #372, #3967
  static fase5 + #373, #3967
  static fase5 + #374, #3967
  static fase5 + #375, #3967
  static fase5 + #376, #3967
  static fase5 + #377, #3967
  static fase5 + #378, #3967
  static fase5 + #379, #3967
  static fase5 + #380, #3967
  static fase5 + #381, #3967
  static fase5 + #382, #3967
  static fase5 + #383, #3967
  static fase5 + #384, #0
  static fase5 + #385, #3967
  static fase5 + #386, #3967
  static fase5 + #387, #3967
  static fase5 + #388, #0
  static fase5 + #389, #3967
  static fase5 + #390, #3
  static fase5 + #391, #0
  static fase5 + #392, #3967
  static fase5 + #393, #3967
  static fase5 + #394, #3967
  static fase5 + #395, #3967
  static fase5 + #396, #0
  static fase5 + #397, #3967
  static fase5 + #398, #3967
  static fase5 + #399, #0

  ;Linha 10
  static fase5 + #400, #0
  static fase5 + #401, #3967
  static fase5 + #402, #3967
  static fase5 + #403, #3967
  static fase5 + #404, #3967
  static fase5 + #405, #3967
  static fase5 + #406, #3967
  static fase5 + #407, #3967
  static fase5 + #408, #3967
  static fase5 + #409, #3
  static fase5 + #410, #3967
  static fase5 + #411, #3967
  static fase5 + #412, #3967
  static fase5 + #413, #3967
  static fase5 + #414, #3967
  static fase5 + #415, #3967
  static fase5 + #416, #3967
  static fase5 + #417, #3967
  static fase5 + #418, #3967
  static fase5 + #419, #3967
  static fase5 + #420, #3967
  static fase5 + #421, #3967
  static fase5 + #422, #3967
  static fase5 + #423, #3967
  static fase5 + #424, #0
  static fase5 + #425, #3967
  static fase5 + #426, #3967
  static fase5 + #427, #3967
  static fase5 + #428, #0
  static fase5 + #429, #3967
  static fase5 + #430, #127
  static fase5 + #431, #0
  static fase5 + #432, #3967
  static fase5 + #433, #3967
  static fase5 + #434, #3967
  static fase5 + #435, #3967
  static fase5 + #436, #0
  static fase5 + #437, #3967
  static fase5 + #438, #3967
  static fase5 + #439, #0

  ;Linha 11
  static fase5 + #440, #0
  static fase5 + #441, #3967
  static fase5 + #442, #3967
  static fase5 + #443, #3967
  static fase5 + #444, #3967
  static fase5 + #445, #3967
  static fase5 + #446, #3967
  static fase5 + #447, #3967
  static fase5 + #448, #3967
  static fase5 + #449, #3967
  static fase5 + #450, #3967
  static fase5 + #451, #3967
  static fase5 + #452, #3967
  static fase5 + #453, #3967
  static fase5 + #454, #3967
  static fase5 + #455, #3967
  static fase5 + #456, #3967
  static fase5 + #457, #3967
  static fase5 + #458, #3967
  static fase5 + #459, #3967
  static fase5 + #460, #3967
  static fase5 + #461, #3967
  static fase5 + #462, #3967
  static fase5 + #463, #3967
  static fase5 + #464, #0
  static fase5 + #465, #3967
  static fase5 + #466, #3967
  static fase5 + #467, #3967
  static fase5 + #468, #0
  static fase5 + #469, #3967
  static fase5 + #470, #3967
  static fase5 + #471, #0
  static fase5 + #472, #3967
  static fase5 + #473, #3967
  static fase5 + #474, #3967
  static fase5 + #475, #3967
  static fase5 + #476, #3967
  static fase5 + #477, #3967
  static fase5 + #478, #127
  static fase5 + #479, #0

  ;Linha 12
  static fase5 + #480, #0
  static fase5 + #481, #3967
  static fase5 + #482, #3967
  static fase5 + #483, #3967
  static fase5 + #484, #3967
  static fase5 + #485, #3967
  static fase5 + #486, #3967
  static fase5 + #487, #3967
  static fase5 + #488, #3967
  static fase5 + #489, #3967
  static fase5 + #490, #3967
  static fase5 + #491, #3967
  static fase5 + #492, #3967
  static fase5 + #493, #3967
  static fase5 + #494, #3967
  static fase5 + #495, #3967
  static fase5 + #496, #3967
  static fase5 + #497, #3967
  static fase5 + #498, #3967
  static fase5 + #499, #3967
  static fase5 + #500, #3967
  static fase5 + #501, #3967
  static fase5 + #502, #3967
  static fase5 + #503, #3967
  static fase5 + #504, #0
  static fase5 + #505, #3967
  static fase5 + #506, #3967
  static fase5 + #507, #3967
  static fase5 + #508, #0
  static fase5 + #509, #3967
  static fase5 + #510, #3967
  static fase5 + #511, #0
  static fase5 + #512, #0
  static fase5 + #513, #0
  static fase5 + #514, #0
  static fase5 + #515, #0
  static fase5 + #516, #0
  static fase5 + #517, #0
  static fase5 + #518, #0
  static fase5 + #519, #0

  ;Linha 13
  static fase5 + #520, #0
  static fase5 + #521, #0
  static fase5 + #522, #0
  static fase5 + #523, #0
  static fase5 + #524, #0
  static fase5 + #525, #0
  static fase5 + #526, #0
  static fase5 + #527, #0
  static fase5 + #528, #0
  static fase5 + #529, #0
  static fase5 + #530, #0
  static fase5 + #531, #0
  static fase5 + #532, #0
  static fase5 + #533, #0
  static fase5 + #534, #3967
  static fase5 + #535, #3967
  static fase5 + #536, #3967
  static fase5 + #537, #3967
  static fase5 + #538, #3967
  static fase5 + #539, #0
  static fase5 + #540, #3967
  static fase5 + #541, #3967
  static fase5 + #542, #3967
  static fase5 + #543, #3967
  static fase5 + #544, #0
  static fase5 + #545, #3967
  static fase5 + #546, #3967
  static fase5 + #547, #3967
  static fase5 + #548, #0
  static fase5 + #549, #3967
  static fase5 + #550, #3967
  static fase5 + #551, #3967
  static fase5 + #552, #3967
  static fase5 + #553, #3967
  static fase5 + #554, #3967
  static fase5 + #555, #3967
  static fase5 + #556, #3967
  static fase5 + #557, #3967
  static fase5 + #558, #127
  static fase5 + #559, #0

  ;Linha 14
  static fase5 + #560, #0
  static fase5 + #561, #3967
  static fase5 + #562, #3967
  static fase5 + #563, #3967
  static fase5 + #564, #3967
  static fase5 + #565, #3967
  static fase5 + #566, #3967
  static fase5 + #567, #3967
  static fase5 + #568, #3967
  static fase5 + #569, #3967
  static fase5 + #570, #3967
  static fase5 + #571, #3967
  static fase5 + #572, #3967
  static fase5 + #573, #0
  static fase5 + #574, #3967
  static fase5 + #575, #3967
  static fase5 + #576, #3967
  static fase5 + #577, #3967
  static fase5 + #578, #3967
  static fase5 + #579, #0
  static fase5 + #580, #3967
  static fase5 + #581, #3967
  static fase5 + #582, #3967
  static fase5 + #583, #3967
  static fase5 + #584, #0
  static fase5 + #585, #3967
  static fase5 + #586, #3967
  static fase5 + #587, #3967
  static fase5 + #588, #0
  static fase5 + #589, #3967
  static fase5 + #590, #3967
  static fase5 + #591, #3967
  static fase5 + #592, #3967
  static fase5 + #593, #3967
  static fase5 + #594, #3967
  static fase5 + #595, #3967
  static fase5 + #596, #3967
  static fase5 + #597, #3967
  static fase5 + #598, #127
  static fase5 + #599, #0

  ;Linha 15
  static fase5 + #600, #0
  static fase5 + #601, #3967
  static fase5 + #602, #3967
  static fase5 + #603, #3967
  static fase5 + #604, #3967
  static fase5 + #605, #3967
  static fase5 + #606, #3967
  static fase5 + #607, #3967
  static fase5 + #608, #3967
  static fase5 + #609, #3967
  static fase5 + #610, #3967
  static fase5 + #611, #3967
  static fase5 + #612, #3967
  static fase5 + #613, #0
  static fase5 + #614, #3967
  static fase5 + #615, #3967
  static fase5 + #616, #3967
  static fase5 + #617, #3967
  static fase5 + #618, #3967
  static fase5 + #619, #0
  static fase5 + #620, #3967
  static fase5 + #621, #3967
  static fase5 + #622, #3967
  static fase5 + #623, #3967
  static fase5 + #624, #0
  static fase5 + #625, #3967
  static fase5 + #626, #3967
  static fase5 + #627, #3967
  static fase5 + #628, #3967
  static fase5 + #629, #3967
  static fase5 + #630, #3967
  static fase5 + #631, #3967
  static fase5 + #632, #3967
  static fase5 + #633, #3967
  static fase5 + #634, #3967
  static fase5 + #635, #3967
  static fase5 + #636, #3967
  static fase5 + #637, #127
  static fase5 + #638, #127
  static fase5 + #639, #0

  ;Linha 16
  static fase5 + #640, #0
  static fase5 + #641, #3967
  static fase5 + #642, #3967
  static fase5 + #643, #3967
  static fase5 + #644, #0
  static fase5 + #645, #0
  static fase5 + #646, #0
  static fase5 + #647, #0
  static fase5 + #648, #0
  static fase5 + #649, #0
  static fase5 + #650, #3967
  static fase5 + #651, #3967
  static fase5 + #652, #3967
  static fase5 + #653, #0
  static fase5 + #654, #3967
  static fase5 + #655, #3967
  static fase5 + #656, #3
  static fase5 + #657, #3967
  static fase5 + #658, #3967
  static fase5 + #659, #0
  static fase5 + #660, #3967
  static fase5 + #661, #3967
  static fase5 + #662, #3967
  static fase5 + #663, #3967
  static fase5 + #664, #0
  static fase5 + #665, #3967
  static fase5 + #666, #3967
  static fase5 + #667, #3967
  static fase5 + #668, #3967
  static fase5 + #669, #3967
  static fase5 + #670, #3967
  static fase5 + #671, #3967
  static fase5 + #672, #3967
  static fase5 + #673, #3967
  static fase5 + #674, #3967
  static fase5 + #675, #3967
  static fase5 + #676, #3967
  static fase5 + #677, #127
  static fase5 + #678, #127
  static fase5 + #679, #0

  ;Linha 17
  static fase5 + #680, #0
  static fase5 + #681, #3967
  static fase5 + #682, #3967
  static fase5 + #683, #3967
  static fase5 + #684, #3967
  static fase5 + #685, #3967
  static fase5 + #686, #127
  static fase5 + #687, #3967
  static fase5 + #688, #3967
  static fase5 + #689, #3967
  static fase5 + #690, #3967
  static fase5 + #691, #3967
  static fase5 + #692, #3967
  static fase5 + #693, #0
  static fase5 + #694, #3967
  static fase5 + #695, #3967
  static fase5 + #696, #3967
  static fase5 + #697, #3967
  static fase5 + #698, #3967
  static fase5 + #699, #0
  static fase5 + #700, #3967
  static fase5 + #701, #3967
  static fase5 + #702, #3
  static fase5 + #703, #3967
  static fase5 + #704, #0
  static fase5 + #705, #0
  static fase5 + #706, #0
  static fase5 + #707, #0
  static fase5 + #708, #0
  static fase5 + #709, #0
  static fase5 + #710, #0
  static fase5 + #711, #0
  static fase5 + #712, #0
  static fase5 + #713, #3967
  static fase5 + #714, #3967
  static fase5 + #715, #3967
  static fase5 + #716, #3967
  static fase5 + #717, #127
  static fase5 + #718, #127
  static fase5 + #719, #0

  ;Linha 18
  static fase5 + #720, #0
  static fase5 + #721, #3967
  static fase5 + #722, #3967
  static fase5 + #723, #3967
  static fase5 + #724, #3967
  static fase5 + #725, #3967
  static fase5 + #726, #127
  static fase5 + #727, #3967
  static fase5 + #728, #3967
  static fase5 + #729, #3967
  static fase5 + #730, #3967
  static fase5 + #731, #3967
  static fase5 + #732, #3967
  static fase5 + #733, #0
  static fase5 + #734, #3967
  static fase5 + #735, #3967
  static fase5 + #736, #3967
  static fase5 + #737, #3967
  static fase5 + #738, #3967
  static fase5 + #739, #0
  static fase5 + #740, #3967
  static fase5 + #741, #3967
  static fase5 + #742, #3967
  static fase5 + #743, #3967
  static fase5 + #744, #3967
  static fase5 + #745, #3967
  static fase5 + #746, #3967
  static fase5 + #747, #3
  static fase5 + #748, #3967
  static fase5 + #749, #3967
  static fase5 + #750, #127
  static fase5 + #751, #127
  static fase5 + #752, #0
  static fase5 + #753, #0
  static fase5 + #754, #0
  static fase5 + #755, #0
  static fase5 + #756, #0
  static fase5 + #757, #3
  static fase5 + #758, #127
  static fase5 + #759, #0

  ;Linha 19
  static fase5 + #760, #0
  static fase5 + #761, #3967
  static fase5 + #762, #3967
  static fase5 + #763, #3967
  static fase5 + #764, #3967
  static fase5 + #765, #127
  static fase5 + #766, #0
  static fase5 + #767, #3967
  static fase5 + #768, #3967
  static fase5 + #769, #3967
  static fase5 + #770, #3967
  static fase5 + #771, #3967
  static fase5 + #772, #3967
  static fase5 + #773, #3967
  static fase5 + #774, #3967
  static fase5 + #775, #3967
  static fase5 + #776, #3967
  static fase5 + #777, #3967
  static fase5 + #778, #3967
  static fase5 + #779, #0
  static fase5 + #780, #3967
  static fase5 + #781, #3967
  static fase5 + #782, #3967
  static fase5 + #783, #3967
  static fase5 + #784, #3967
  static fase5 + #785, #3967
  static fase5 + #786, #3967
  static fase5 + #787, #3967
  static fase5 + #788, #3967
  static fase5 + #789, #3967
  static fase5 + #790, #3967
  static fase5 + #791, #127
  static fase5 + #792, #0
  static fase5 + #793, #3967
  static fase5 + #794, #3967
  static fase5 + #795, #3967
  static fase5 + #796, #3967
  static fase5 + #797, #127
  static fase5 + #798, #127
  static fase5 + #799, #0

  ;Linha 20
  static fase5 + #800, #0
  static fase5 + #801, #3967
  static fase5 + #802, #3967
  static fase5 + #803, #3967
  static fase5 + #804, #3967
  static fase5 + #805, #127
  static fase5 + #806, #0
  static fase5 + #807, #3967
  static fase5 + #808, #3967
  static fase5 + #809, #3967
  static fase5 + #810, #3967
  static fase5 + #811, #3967
  static fase5 + #812, #3967
  static fase5 + #813, #3967
  static fase5 + #814, #3967
  static fase5 + #815, #3967
  static fase5 + #816, #3967
  static fase5 + #817, #3967
  static fase5 + #818, #3967
  static fase5 + #819, #0
  static fase5 + #820, #3967
  static fase5 + #821, #3967
  static fase5 + #822, #3967
  static fase5 + #823, #3967
  static fase5 + #824, #3967
  static fase5 + #825, #0
  static fase5 + #826, #0
  static fase5 + #827, #0
  static fase5 + #828, #0
  static fase5 + #829, #0
  static fase5 + #830, #3967
  static fase5 + #831, #3967
  static fase5 + #832, #0
  static fase5 + #833, #3967
  static fase5 + #834, #3967
  static fase5 + #835, #3967
  static fase5 + #836, #3967
  static fase5 + #837, #3967
  static fase5 + #838, #127
  static fase5 + #839, #0

  ;Linha 21
  static fase5 + #840, #0
  static fase5 + #841, #3967
  static fase5 + #842, #3967
  static fase5 + #843, #3967
  static fase5 + #844, #3967
  static fase5 + #845, #127
  static fase5 + #846, #0
  static fase5 + #847, #3967
  static fase5 + #848, #3967
  static fase5 + #849, #3967
  static fase5 + #850, #3967
  static fase5 + #851, #3967
  static fase5 + #852, #3967
  static fase5 + #853, #3967
  static fase5 + #854, #3967
  static fase5 + #855, #3967
  static fase5 + #856, #3967
  static fase5 + #857, #3967
  static fase5 + #858, #3967
  static fase5 + #859, #0
  static fase5 + #860, #3967
  static fase5 + #861, #3967
  static fase5 + #862, #3967
  static fase5 + #863, #3967
  static fase5 + #864, #3967
  static fase5 + #865, #0
  static fase5 + #866, #127
  static fase5 + #867, #127
  static fase5 + #868, #127
  static fase5 + #869, #0
  static fase5 + #870, #3967
  static fase5 + #871, #3967
  static fase5 + #872, #0
  static fase5 + #873, #3967
  static fase5 + #874, #3967
  static fase5 + #875, #3967
  static fase5 + #876, #3967
  static fase5 + #877, #3967
  static fase5 + #878, #127
  static fase5 + #879, #0

  ;Linha 22
  static fase5 + #880, #0
  static fase5 + #881, #3967
  static fase5 + #882, #3967
  static fase5 + #883, #3967
  static fase5 + #884, #3967
  static fase5 + #885, #3967
  static fase5 + #886, #0
  static fase5 + #887, #3967
  static fase5 + #888, #3967
  static fase5 + #889, #3967
  static fase5 + #890, #0
  static fase5 + #891, #0
  static fase5 + #892, #0
  static fase5 + #893, #0
  static fase5 + #894, #0
  static fase5 + #895, #0
  static fase5 + #896, #3967
  static fase5 + #897, #3967
  static fase5 + #898, #3967
  static fase5 + #899, #0
  static fase5 + #900, #3967
  static fase5 + #901, #3967
  static fase5 + #902, #3967
  static fase5 + #903, #3967
  static fase5 + #904, #3967
  static fase5 + #905, #0
  static fase5 + #906, #127
  static fase5 + #907, #127
  static fase5 + #908, #127
  static fase5 + #909, #0
  static fase5 + #910, #3967
  static fase5 + #911, #3967
  static fase5 + #912, #0
  static fase5 + #913, #3967
  static fase5 + #914, #3967
  static fase5 + #915, #0
  static fase5 + #916, #0
  static fase5 + #917, #0
  static fase5 + #918, #0
  static fase5 + #919, #0

  ;Linha 23
  static fase5 + #920, #0
  static fase5 + #921, #3967
  static fase5 + #922, #3967
  static fase5 + #923, #3
  static fase5 + #924, #3967
  static fase5 + #925, #3967
  static fase5 + #926, #0
  static fase5 + #927, #3967
  static fase5 + #928, #3967
  static fase5 + #929, #3967
  static fase5 + #930, #3967
  static fase5 + #931, #3967
  static fase5 + #932, #3
  static fase5 + #933, #3967
  static fase5 + #934, #3967
  static fase5 + #935, #3967
  static fase5 + #936, #3967
  static fase5 + #937, #3967
  static fase5 + #938, #3967
  static fase5 + #939, #3967
  static fase5 + #940, #3967
  static fase5 + #941, #3967
  static fase5 + #942, #3967
  static fase5 + #943, #3967
  static fase5 + #944, #3967
  static fase5 + #945, #0
  static fase5 + #946, #0
  static fase5 + #947, #0
  static fase5 + #948, #0
  static fase5 + #949, #0
  static fase5 + #950, #3967
  static fase5 + #951, #3967
  static fase5 + #952, #0
  static fase5 + #953, #3967
  static fase5 + #954, #3967
  static fase5 + #955, #3967
  static fase5 + #956, #127
  static fase5 + #957, #3967
  static fase5 + #958, #3967
  static fase5 + #959, #0

  ;Linha 24
  static fase5 + #960, #0
  static fase5 + #961, #3967
  static fase5 + #962, #3967
  static fase5 + #963, #3967
  static fase5 + #964, #3967
  static fase5 + #965, #3967
  static fase5 + #966, #0
  static fase5 + #967, #127
  static fase5 + #968, #127
  static fase5 + #969, #127
  static fase5 + #970, #3967
  static fase5 + #971, #3967
  static fase5 + #972, #3967
  static fase5 + #973, #3967
  static fase5 + #974, #3967
  static fase5 + #975, #3967
  static fase5 + #976, #3967
  static fase5 + #977, #3967
  static fase5 + #978, #3967
  static fase5 + #979, #3967
  static fase5 + #980, #3967
  static fase5 + #981, #3967
  static fase5 + #982, #3967
  static fase5 + #983, #3967
  static fase5 + #984, #3967
  static fase5 + #985, #3967
  static fase5 + #986, #3967
  static fase5 + #987, #3
  static fase5 + #988, #3967
  static fase5 + #989, #3967
  static fase5 + #990, #3967
  static fase5 + #991, #3967
  static fase5 + #992, #0
  static fase5 + #993, #3967
  static fase5 + #994, #3967
  static fase5 + #995, #3
  static fase5 + #996, #3967
  static fase5 + #997, #3967
  static fase5 + #998, #3967
  static fase5 + #999, #0

  ;Linha 25
  static fase5 + #1000, #0
  static fase5 + #1001, #3967
  static fase5 + #1002, #3967
  static fase5 + #1003, #3967
  static fase5 + #1004, #3967
  static fase5 + #1005, #3967
  static fase5 + #1006, #0
  static fase5 + #1007, #0
  static fase5 + #1008, #0
  static fase5 + #1009, #0
  static fase5 + #1010, #0
  static fase5 + #1011, #0
  static fase5 + #1012, #0
  static fase5 + #1013, #0
  static fase5 + #1014, #0
  static fase5 + #1015, #0
  static fase5 + #1016, #0
  static fase5 + #1017, #0
  static fase5 + #1018, #0
  static fase5 + #1019, #0
  static fase5 + #1020, #0
  static fase5 + #1021, #0
  static fase5 + #1022, #0
  static fase5 + #1023, #0
  static fase5 + #1024, #0
  static fase5 + #1025, #0
  static fase5 + #1026, #0
  static fase5 + #1027, #0
  static fase5 + #1028, #0
  static fase5 + #1029, #0
  static fase5 + #1030, #0
  static fase5 + #1031, #0
  static fase5 + #1032, #0
  static fase5 + #1033, #0
  static fase5 + #1034, #0
  static fase5 + #1035, #0
  static fase5 + #1036, #0
  static fase5 + #1037, #3967
  static fase5 + #1038, #3967
  static fase5 + #1039, #0

  ;Linha 26
  static fase5 + #1040, #0
  static fase5 + #1041, #3967
  static fase5 + #1042, #3967
  static fase5 + #1043, #3967
  static fase5 + #1044, #3967
  static fase5 + #1045, #3967
  static fase5 + #1046, #3967
  static fase5 + #1047, #3967
  static fase5 + #1048, #3967
  static fase5 + #1049, #3967
  static fase5 + #1050, #3967
  static fase5 + #1051, #0
  static fase5 + #1052, #3967
  static fase5 + #1053, #3967
  static fase5 + #1054, #3967
  static fase5 + #1055, #3967
  static fase5 + #1056, #3967
  static fase5 + #1057, #3967
  static fase5 + #1058, #3967
  static fase5 + #1059, #3967
  static fase5 + #1060, #3967
  static fase5 + #1061, #3967
  static fase5 + #1062, #3967
  static fase5 + #1063, #3967
  static fase5 + #1064, #3967
  static fase5 + #1065, #3967
  static fase5 + #1066, #3967
  static fase5 + #1067, #3967
  static fase5 + #1068, #3967
  static fase5 + #1069, #3967
  static fase5 + #1070, #3967
  static fase5 + #1071, #3967
  static fase5 + #1072, #3967
  static fase5 + #1073, #3967
  static fase5 + #1074, #3967
  static fase5 + #1075, #3967
  static fase5 + #1076, #3967
  static fase5 + #1077, #3967
  static fase5 + #1078, #3967
  static fase5 + #1079, #0

  ;Linha 27
  static fase5 + #1080, #0
  static fase5 + #1081, #3967
  static fase5 + #1082, #3967
  static fase5 + #1083, #3967
  static fase5 + #1084, #3967
  static fase5 + #1085, #3967
  static fase5 + #1086, #3967
  static fase5 + #1087, #3
  static fase5 + #1088, #3967
  static fase5 + #1089, #3967
  static fase5 + #1090, #3967
  static fase5 + #1091, #0
  static fase5 + #1092, #3967
  static fase5 + #1093, #3967
  static fase5 + #1094, #3967
  static fase5 + #1095, #3967
  static fase5 + #1096, #3967
  static fase5 + #1097, #3967
  static fase5 + #1098, #3967
  static fase5 + #1099, #3967
  static fase5 + #1100, #3967
  static fase5 + #1101, #3967
  static fase5 + #1102, #3967
  static fase5 + #1103, #3967
  static fase5 + #1104, #3967
  static fase5 + #1105, #3
  static fase5 + #1106, #3967
  static fase5 + #1107, #3967
  static fase5 + #1108, #3967
  static fase5 + #1109, #3967
  static fase5 + #1110, #3967
  static fase5 + #1111, #3967
  static fase5 + #1112, #3967
  static fase5 + #1113, #3967
  static fase5 + #1114, #3967
  static fase5 + #1115, #3967
  static fase5 + #1116, #3967
  static fase5 + #1117, #3967
  static fase5 + #1118, #3967
  static fase5 + #1119, #0

  ;Linha 28
  static fase5 + #1120, #0
  static fase5 + #1121, #3967
  static fase5 + #1122, #3967
  static fase5 + #1123, #3967
  static fase5 + #1124, #3967
  static fase5 + #1125, #3967
  static fase5 + #1126, #3967
  static fase5 + #1127, #3967
  static fase5 + #1128, #3967
  static fase5 + #1129, #3967
  static fase5 + #1130, #3967
  static fase5 + #1131, #0
  static fase5 + #1132, #3967
  static fase5 + #1133, #3967
  static fase5 + #1134, #3967
  static fase5 + #1135, #3967
  static fase5 + #1136, #3967
  static fase5 + #1137, #3967
  static fase5 + #1138, #3967
  static fase5 + #1139, #3967
  static fase5 + #1140, #3967
  static fase5 + #1141, #3967
  static fase5 + #1142, #3967
  static fase5 + #1143, #3967
  static fase5 + #1144, #3967
  static fase5 + #1145, #3967
  static fase5 + #1146, #3967
  static fase5 + #1147, #3967
  static fase5 + #1148, #3967
  static fase5 + #1149, #3967
  static fase5 + #1150, #3967
  static fase5 + #1151, #127
  static fase5 + #1152, #127
  static fase5 + #1153, #127
  static fase5 + #1154, #127
  static fase5 + #1155, #127
  static fase5 + #1156, #3967
  static fase5 + #1157, #3967
  static fase5 + #1158, #514
  static fase5 + #1159, #0

  ;Linha 29
  static fase5 + #1160, #0
  static fase5 + #1161, #0
  static fase5 + #1162, #0
  static fase5 + #1163, #0
  static fase5 + #1164, #0
  static fase5 + #1165, #0
  static fase5 + #1166, #0
  static fase5 + #1167, #0
  static fase5 + #1168, #0
  static fase5 + #1169, #0
  static fase5 + #1170, #0
  static fase5 + #1171, #0
  static fase5 + #1172, #0
  static fase5 + #1173, #0
  static fase5 + #1174, #0
  static fase5 + #1175, #0
  static fase5 + #1176, #0
  static fase5 + #1177, #0
  static fase5 + #1178, #0
  static fase5 + #1179, #0
  static fase5 + #1180, #0
  static fase5 + #1181, #0
  static fase5 + #1182, #0
  static fase5 + #1183, #0
  static fase5 + #1184, #0
  static fase5 + #1185, #0
  static fase5 + #1186, #0
  static fase5 + #1187, #0
  static fase5 + #1188, #0
  static fase5 + #1189, #0
  static fase5 + #1190, #0
  static fase5 + #1191, #0
  static fase5 + #1192, #0
  static fase5 + #1193, #0
  static fase5 + #1194, #0
  static fase5 + #1195, #0
  static fase5 + #1196, #0
  static fase5 + #1197, #0
  static fase5 + #1198, #0
  static fase5 + #1199, #0

fase6 : var #1200
  ;Linha 0
  static fase6 + #0, #0
  static fase6 + #1, #0
  static fase6 + #2, #0
  static fase6 + #3, #0
  static fase6 + #4, #0
  static fase6 + #5, #0
  static fase6 + #6, #0
  static fase6 + #7, #0
  static fase6 + #8, #0
  static fase6 + #9, #0
  static fase6 + #10, #0
  static fase6 + #11, #0
  static fase6 + #12, #0
  static fase6 + #13, #0
  static fase6 + #14, #0
  static fase6 + #15, #0
  static fase6 + #16, #0
  static fase6 + #17, #0
  static fase6 + #18, #0
  static fase6 + #19, #0
  static fase6 + #20, #0
  static fase6 + #21, #0
  static fase6 + #22, #0
  static fase6 + #23, #0
  static fase6 + #24, #0
  static fase6 + #25, #0
  static fase6 + #26, #0
  static fase6 + #27, #0
  static fase6 + #28, #0
  static fase6 + #29, #0
  static fase6 + #30, #0
  static fase6 + #31, #0
  static fase6 + #32, #0
  static fase6 + #33, #0
  static fase6 + #34, #0
  static fase6 + #35, #0
  static fase6 + #36, #0
  static fase6 + #37, #0
  static fase6 + #38, #0
  static fase6 + #39, #0

  ;Linha 1
  static fase6 + #40, #0
  static fase6 + #41, #3967
  static fase6 + #42, #3967
  static fase6 + #43, #3967
  static fase6 + #44, #0
  static fase6 + #45, #3967
  static fase6 + #46, #3967
  static fase6 + #47, #3967
  static fase6 + #48, #3967
  static fase6 + #49, #3967
  static fase6 + #50, #3967
  static fase6 + #51, #3967
  static fase6 + #52, #3967
  static fase6 + #53, #3967
  static fase6 + #54, #3967
  static fase6 + #55, #3967
  static fase6 + #56, #3967
  static fase6 + #57, #3967
  static fase6 + #58, #3967
  static fase6 + #59, #3967
  static fase6 + #60, #3967
  static fase6 + #61, #3967
  static fase6 + #62, #3967
  static fase6 + #63, #3967
  static fase6 + #64, #3
  static fase6 + #65, #3840
  static fase6 + #66, #3967
  static fase6 + #67, #3967
  static fase6 + #68, #3967
  static fase6 + #69, #3967
  static fase6 + #70, #3967
  static fase6 + #71, #3967
  static fase6 + #72, #3967
  static fase6 + #73, #3967
  static fase6 + #74, #3967
  static fase6 + #75, #3967
  static fase6 + #76, #3967
  static fase6 + #77, #3967
  static fase6 + #78, #3967
  static fase6 + #79, #0

  ;Linha 2
  static fase6 + #80, #0
  static fase6 + #81, #3967
  static fase6 + #82, #3967
  static fase6 + #83, #3967
  static fase6 + #84, #0
  static fase6 + #85, #0
  static fase6 + #86, #0
  static fase6 + #87, #0
  static fase6 + #88, #0
  static fase6 + #89, #0
  static fase6 + #90, #0
  static fase6 + #91, #0
  static fase6 + #92, #0
  static fase6 + #93, #0
  static fase6 + #94, #0
  static fase6 + #95, #0
  static fase6 + #96, #0
  static fase6 + #97, #0
  static fase6 + #98, #0
  static fase6 + #99, #0
  static fase6 + #100, #0
  static fase6 + #101, #0
  static fase6 + #102, #0
  static fase6 + #103, #0
  static fase6 + #104, #0
  static fase6 + #105, #0
  static fase6 + #106, #0
  static fase6 + #107, #0
  static fase6 + #108, #0
  static fase6 + #109, #3967
  static fase6 + #110, #3967
  static fase6 + #111, #3967
  static fase6 + #112, #3967
  static fase6 + #113, #3967
  static fase6 + #114, #3967
  static fase6 + #115, #3967
  static fase6 + #116, #3967
  static fase6 + #117, #3967
  static fase6 + #118, #3967
  static fase6 + #119, #0

  ;Linha 3
  static fase6 + #120, #0
  static fase6 + #121, #3967
  static fase6 + #122, #3967
  static fase6 + #123, #3967
  static fase6 + #124, #3967
  static fase6 + #125, #3967
  static fase6 + #126, #3967
  static fase6 + #127, #3967
  static fase6 + #128, #3967
  static fase6 + #129, #3967
  static fase6 + #130, #3967
  static fase6 + #131, #3967
  static fase6 + #132, #3967
  static fase6 + #133, #3967
  static fase6 + #134, #3967
  static fase6 + #135, #3967
  static fase6 + #136, #3967
  static fase6 + #137, #3967
  static fase6 + #138, #3967
  static fase6 + #139, #3967
  static fase6 + #140, #3967
  static fase6 + #141, #3840
  static fase6 + #142, #3840
  static fase6 + #143, #3840
  static fase6 + #144, #3840
  static fase6 + #145, #3840
  static fase6 + #146, #3840
  static fase6 + #147, #3967
  static fase6 + #148, #3967
  static fase6 + #149, #3967
  static fase6 + #150, #3967
  static fase6 + #151, #3967
  static fase6 + #152, #3967
  static fase6 + #153, #3967
  static fase6 + #154, #3967
  static fase6 + #155, #3967
  static fase6 + #156, #3967
  static fase6 + #157, #3967
  static fase6 + #158, #3967
  static fase6 + #159, #0

  ;Linha 4
  static fase6 + #160, #0
  static fase6 + #161, #3967
  static fase6 + #162, #3967
  static fase6 + #163, #3967
  static fase6 + #164, #0
  static fase6 + #165, #0
  static fase6 + #166, #0
  static fase6 + #167, #0
  static fase6 + #168, #0
  static fase6 + #169, #0
  static fase6 + #170, #0
  static fase6 + #171, #0
  static fase6 + #172, #0
  static fase6 + #173, #0
  static fase6 + #174, #0
  static fase6 + #175, #0
  static fase6 + #176, #0
  static fase6 + #177, #0
  static fase6 + #178, #0
  static fase6 + #179, #0
  static fase6 + #180, #0
  static fase6 + #181, #0
  static fase6 + #182, #0
  static fase6 + #183, #0
  static fase6 + #184, #0
  static fase6 + #185, #0
  static fase6 + #186, #0
  static fase6 + #187, #0
  static fase6 + #188, #0
  static fase6 + #189, #0
  static fase6 + #190, #0
  static fase6 + #191, #0
  static fase6 + #192, #0
  static fase6 + #193, #0
  static fase6 + #194, #3967
  static fase6 + #195, #3967
  static fase6 + #196, #3967
  static fase6 + #197, #3967
  static fase6 + #198, #3967
  static fase6 + #199, #0

  ;Linha 5
  static fase6 + #200, #0
  static fase6 + #201, #3967
  static fase6 + #202, #3967
  static fase6 + #203, #3967
  static fase6 + #204, #3967
  static fase6 + #205, #3967
  static fase6 + #206, #3967
  static fase6 + #207, #3
  static fase6 + #208, #3967
  static fase6 + #209, #3967
  static fase6 + #210, #3967
  static fase6 + #211, #3967
  static fase6 + #212, #3967
  static fase6 + #213, #3967
  static fase6 + #214, #3967
  static fase6 + #215, #0
  static fase6 + #216, #3967
  static fase6 + #217, #3967
  static fase6 + #218, #3967
  static fase6 + #219, #3967
  static fase6 + #220, #3967
  static fase6 + #221, #3967
  static fase6 + #222, #3967
  static fase6 + #223, #3967
  static fase6 + #224, #3967
  static fase6 + #225, #3967
  static fase6 + #226, #3967
  static fase6 + #227, #3
  static fase6 + #228, #3967
  static fase6 + #229, #3967
  static fase6 + #230, #3967
  static fase6 + #231, #0
  static fase6 + #232, #3967
  static fase6 + #233, #3967
  static fase6 + #234, #3967
  static fase6 + #235, #3967
  static fase6 + #236, #3967
  static fase6 + #237, #3967
  static fase6 + #238, #3967
  static fase6 + #239, #0

  ;Linha 6
  static fase6 + #240, #0
  static fase6 + #241, #3967
  static fase6 + #242, #3967
  static fase6 + #243, #3967
  static fase6 + #244, #0
  static fase6 + #245, #0
  static fase6 + #246, #0
  static fase6 + #247, #0
  static fase6 + #248, #0
  static fase6 + #249, #0
  static fase6 + #250, #0
  static fase6 + #251, #0
  static fase6 + #252, #0
  static fase6 + #253, #0
  static fase6 + #254, #0
  static fase6 + #255, #0
  static fase6 + #256, #3967
  static fase6 + #257, #3967
  static fase6 + #258, #3967
  static fase6 + #259, #3967
  static fase6 + #260, #3967
  static fase6 + #261, #3967
  static fase6 + #262, #0
  static fase6 + #263, #0
  static fase6 + #264, #0
  static fase6 + #265, #0
  static fase6 + #266, #0
  static fase6 + #267, #0
  static fase6 + #268, #0
  static fase6 + #269, #0
  static fase6 + #270, #0
  static fase6 + #271, #0
  static fase6 + #272, #3967
  static fase6 + #273, #3967
  static fase6 + #274, #3967
  static fase6 + #275, #3967
  static fase6 + #276, #3967
  static fase6 + #277, #3967
  static fase6 + #278, #3967
  static fase6 + #279, #0

  ;Linha 7
  static fase6 + #280, #0
  static fase6 + #281, #3967
  static fase6 + #282, #3967
  static fase6 + #283, #3967
  static fase6 + #284, #3967
  static fase6 + #285, #3967
  static fase6 + #286, #3967
  static fase6 + #287, #3967
  static fase6 + #288, #3967
  static fase6 + #289, #3967
  static fase6 + #290, #3967
  static fase6 + #291, #3967
  static fase6 + #292, #3967
  static fase6 + #293, #3967
  static fase6 + #294, #3967
  static fase6 + #295, #3967
  static fase6 + #296, #3967
  static fase6 + #297, #3967
  static fase6 + #298, #3967
  static fase6 + #299, #3967
  static fase6 + #300, #3967
  static fase6 + #301, #3967
  static fase6 + #302, #0
  static fase6 + #303, #3967
  static fase6 + #304, #3967
  static fase6 + #305, #3967
  static fase6 + #306, #3967
  static fase6 + #307, #3967
  static fase6 + #308, #3967
  static fase6 + #309, #3967
  static fase6 + #310, #3967
  static fase6 + #311, #3967
  static fase6 + #312, #3967
  static fase6 + #313, #3967
  static fase6 + #314, #3967
  static fase6 + #315, #3967
  static fase6 + #316, #3967
  static fase6 + #317, #3967
  static fase6 + #318, #3967
  static fase6 + #319, #0

  ;Linha 8
  static fase6 + #320, #0
  static fase6 + #321, #3967
  static fase6 + #322, #0
  static fase6 + #323, #0
  static fase6 + #324, #0
  static fase6 + #325, #0
  static fase6 + #326, #0
  static fase6 + #327, #0
  static fase6 + #328, #0
  static fase6 + #329, #0
  static fase6 + #330, #0
  static fase6 + #331, #0
  static fase6 + #332, #0
  static fase6 + #333, #0
  static fase6 + #334, #0
  static fase6 + #335, #0
  static fase6 + #336, #0
  static fase6 + #337, #0
  static fase6 + #338, #0
  static fase6 + #339, #0
  static fase6 + #340, #0
  static fase6 + #341, #0
  static fase6 + #342, #0
  static fase6 + #343, #0
  static fase6 + #344, #0
  static fase6 + #345, #0
  static fase6 + #346, #0
  static fase6 + #347, #0
  static fase6 + #348, #0
  static fase6 + #349, #0
  static fase6 + #350, #0
  static fase6 + #351, #0
  static fase6 + #352, #0
  static fase6 + #353, #0
  static fase6 + #354, #3967
  static fase6 + #355, #3967
  static fase6 + #356, #3967
  static fase6 + #357, #3967
  static fase6 + #358, #3967
  static fase6 + #359, #0

  ;Linha 9
  static fase6 + #360, #0
  static fase6 + #361, #3967
  static fase6 + #362, #3967
  static fase6 + #363, #3967
  static fase6 + #364, #0
  static fase6 + #365, #3967
  static fase6 + #366, #3967
  static fase6 + #367, #3967
  static fase6 + #368, #3967
  static fase6 + #369, #3967
  static fase6 + #370, #3967
  static fase6 + #371, #3967
  static fase6 + #372, #3967
  static fase6 + #373, #3967
  static fase6 + #374, #3967
  static fase6 + #375, #3967
  static fase6 + #376, #3967
  static fase6 + #377, #3967
  static fase6 + #378, #3967
  static fase6 + #379, #3967
  static fase6 + #380, #3967
  static fase6 + #381, #3967
  static fase6 + #382, #3967
  static fase6 + #383, #3967
  static fase6 + #384, #3967
  static fase6 + #385, #3967
  static fase6 + #386, #3967
  static fase6 + #387, #3967
  static fase6 + #388, #3967
  static fase6 + #389, #3967
  static fase6 + #390, #3967
  static fase6 + #391, #3967
  static fase6 + #392, #3967
  static fase6 + #393, #3967
  static fase6 + #394, #3967
  static fase6 + #395, #3967
  static fase6 + #396, #3967
  static fase6 + #397, #3967
  static fase6 + #398, #3967
  static fase6 + #399, #0

  ;Linha 10
  static fase6 + #400, #0
  static fase6 + #401, #0
  static fase6 + #402, #0
  static fase6 + #403, #3
  static fase6 + #404, #0
  static fase6 + #405, #3967
  static fase6 + #406, #3967
  static fase6 + #407, #3967
  static fase6 + #408, #3967
  static fase6 + #409, #3967
  static fase6 + #410, #3967
  static fase6 + #411, #3967
  static fase6 + #412, #3967
  static fase6 + #413, #3967
  static fase6 + #414, #3967
  static fase6 + #415, #3967
  static fase6 + #416, #3967
  static fase6 + #417, #3967
  static fase6 + #418, #3967
  static fase6 + #419, #3967
  static fase6 + #420, #3967
  static fase6 + #421, #3967
  static fase6 + #422, #3967
  static fase6 + #423, #3967
  static fase6 + #424, #3967
  static fase6 + #425, #3967
  static fase6 + #426, #3967
  static fase6 + #427, #3967
  static fase6 + #428, #3967
  static fase6 + #429, #3967
  static fase6 + #430, #3967
  static fase6 + #431, #3967
  static fase6 + #432, #3967
  static fase6 + #433, #3967
  static fase6 + #434, #3967
  static fase6 + #435, #3967
  static fase6 + #436, #3967
  static fase6 + #437, #3967
  static fase6 + #438, #3967
  static fase6 + #439, #0

  ;Linha 11
  static fase6 + #440, #0
  static fase6 + #441, #3840
  static fase6 + #442, #3967
  static fase6 + #443, #3967
  static fase6 + #444, #0
  static fase6 + #445, #3967
  static fase6 + #446, #3967
  static fase6 + #447, #3967
  static fase6 + #448, #0
  static fase6 + #449, #0
  static fase6 + #450, #0
  static fase6 + #451, #0
  static fase6 + #452, #0
  static fase6 + #453, #0
  static fase6 + #454, #0
  static fase6 + #455, #0
  static fase6 + #456, #0
  static fase6 + #457, #0
  static fase6 + #458, #0
  static fase6 + #459, #0
  static fase6 + #460, #0
  static fase6 + #461, #0
  static fase6 + #462, #0
  static fase6 + #463, #0
  static fase6 + #464, #0
  static fase6 + #465, #0
  static fase6 + #466, #0
  static fase6 + #467, #0
  static fase6 + #468, #0
  static fase6 + #469, #0
  static fase6 + #470, #0
  static fase6 + #471, #0
  static fase6 + #472, #0
  static fase6 + #473, #0
  static fase6 + #474, #3967
  static fase6 + #475, #3967
  static fase6 + #476, #3967
  static fase6 + #477, #3967
  static fase6 + #478, #3967
  static fase6 + #479, #0

  ;Linha 12
  static fase6 + #480, #0
  static fase6 + #481, #3840
  static fase6 + #482, #3967
  static fase6 + #483, #3967
  static fase6 + #484, #0
  static fase6 + #485, #3967
  static fase6 + #486, #3967
  static fase6 + #487, #3967
  static fase6 + #488, #3840
  static fase6 + #489, #3840
  static fase6 + #490, #3840
  static fase6 + #491, #3840
  static fase6 + #492, #3840
  static fase6 + #493, #3840
  static fase6 + #494, #3840
  static fase6 + #495, #3840
  static fase6 + #496, #3840
  static fase6 + #497, #3840
  static fase6 + #498, #3840
  static fase6 + #499, #3840
  static fase6 + #500, #3840
  static fase6 + #501, #3840
  static fase6 + #502, #3840
  static fase6 + #503, #3840
  static fase6 + #504, #3840
  static fase6 + #505, #3840
  static fase6 + #506, #3840
  static fase6 + #507, #3840
  static fase6 + #508, #3840
  static fase6 + #509, #3840
  static fase6 + #510, #3840
  static fase6 + #511, #3840
  static fase6 + #512, #3840
  static fase6 + #513, #0
  static fase6 + #514, #3967
  static fase6 + #515, #3967
  static fase6 + #516, #3967
  static fase6 + #517, #3967
  static fase6 + #518, #3967
  static fase6 + #519, #0

  ;Linha 13
  static fase6 + #520, #0
  static fase6 + #521, #3840
  static fase6 + #522, #3967
  static fase6 + #523, #3967
  static fase6 + #524, #0
  static fase6 + #525, #3967
  static fase6 + #526, #3967
  static fase6 + #527, #3967
  static fase6 + #528, #3967
  static fase6 + #529, #3967
  static fase6 + #530, #3967
  static fase6 + #531, #3967
  static fase6 + #532, #3840
  static fase6 + #533, #3840
  static fase6 + #534, #3840
  static fase6 + #535, #3840
  static fase6 + #536, #3967
  static fase6 + #537, #3967
  static fase6 + #538, #3967
  static fase6 + #539, #3967
  static fase6 + #540, #3967
  static fase6 + #541, #3967
  static fase6 + #542, #3967
  static fase6 + #543, #3967
  static fase6 + #544, #3967
  static fase6 + #545, #3967
  static fase6 + #546, #3967
  static fase6 + #547, #3840
  static fase6 + #548, #3840
  static fase6 + #549, #3840
  static fase6 + #550, #3840
  static fase6 + #551, #3967
  static fase6 + #552, #3967
  static fase6 + #553, #0
  static fase6 + #554, #3967
  static fase6 + #555, #3
  static fase6 + #556, #0
  static fase6 + #557, #3967
  static fase6 + #558, #3967
  static fase6 + #559, #0

  ;Linha 14
  static fase6 + #560, #0
  static fase6 + #561, #3840
  static fase6 + #562, #0
  static fase6 + #563, #0
  static fase6 + #564, #0
  static fase6 + #565, #0
  static fase6 + #566, #0
  static fase6 + #567, #0
  static fase6 + #568, #0
  static fase6 + #569, #0
  static fase6 + #570, #0
  static fase6 + #571, #0
  static fase6 + #572, #0
  static fase6 + #573, #0
  static fase6 + #574, #0
  static fase6 + #575, #0
  static fase6 + #576, #0
  static fase6 + #577, #0
  static fase6 + #578, #0
  static fase6 + #579, #0
  static fase6 + #580, #0
  static fase6 + #581, #0
  static fase6 + #582, #0
  static fase6 + #583, #0
  static fase6 + #584, #0
  static fase6 + #585, #0
  static fase6 + #586, #0
  static fase6 + #587, #0
  static fase6 + #588, #0
  static fase6 + #589, #0
  static fase6 + #590, #0
  static fase6 + #591, #3840
  static fase6 + #592, #3967
  static fase6 + #593, #0
  static fase6 + #594, #3967
  static fase6 + #595, #3967
  static fase6 + #596, #0
  static fase6 + #597, #3967
  static fase6 + #598, #3967
  static fase6 + #599, #0

  ;Linha 15
  static fase6 + #600, #0
  static fase6 + #601, #3840
  static fase6 + #602, #3967
  static fase6 + #603, #3840
  static fase6 + #604, #0
  static fase6 + #605, #3967
  static fase6 + #606, #3967
  static fase6 + #607, #3967
  static fase6 + #608, #3967
  static fase6 + #609, #3967
  static fase6 + #610, #3
  static fase6 + #611, #3967
  static fase6 + #612, #3967
  static fase6 + #613, #3967
  static fase6 + #614, #3967
  static fase6 + #615, #3967
  static fase6 + #616, #3967
  static fase6 + #617, #3967
  static fase6 + #618, #3967
  static fase6 + #619, #3967
  static fase6 + #620, #3967
  static fase6 + #621, #3967
  static fase6 + #622, #3967
  static fase6 + #623, #3967
  static fase6 + #624, #3967
  static fase6 + #625, #3967
  static fase6 + #626, #3967
  static fase6 + #627, #3967
  static fase6 + #628, #3967
  static fase6 + #629, #3967
  static fase6 + #630, #0
  static fase6 + #631, #3967
  static fase6 + #632, #3967
  static fase6 + #633, #0
  static fase6 + #634, #3967
  static fase6 + #635, #3967
  static fase6 + #636, #0
  static fase6 + #637, #3967
  static fase6 + #638, #3967
  static fase6 + #639, #0

  ;Linha 16
  static fase6 + #640, #0
  static fase6 + #641, #127
  static fase6 + #642, #127
  static fase6 + #643, #3840
  static fase6 + #644, #0
  static fase6 + #645, #3967
  static fase6 + #646, #3967
  static fase6 + #647, #3967
  static fase6 + #648, #3967
  static fase6 + #649, #0
  static fase6 + #650, #0
  static fase6 + #651, #0
  static fase6 + #652, #0
  static fase6 + #653, #0
  static fase6 + #654, #0
  static fase6 + #655, #0
  static fase6 + #656, #0
  static fase6 + #657, #0
  static fase6 + #658, #0
  static fase6 + #659, #0
  static fase6 + #660, #0
  static fase6 + #661, #0
  static fase6 + #662, #0
  static fase6 + #663, #3967
  static fase6 + #664, #3967
  static fase6 + #665, #3967
  static fase6 + #666, #3967
  static fase6 + #667, #3967
  static fase6 + #668, #3967
  static fase6 + #669, #3967
  static fase6 + #670, #0
  static fase6 + #671, #3967
  static fase6 + #672, #3967
  static fase6 + #673, #0
  static fase6 + #674, #3967
  static fase6 + #675, #3967
  static fase6 + #676, #0
  static fase6 + #677, #3967
  static fase6 + #678, #3967
  static fase6 + #679, #0

  ;Linha 17
  static fase6 + #680, #0
  static fase6 + #681, #3840
  static fase6 + #682, #3967
  static fase6 + #683, #3840
  static fase6 + #684, #0
  static fase6 + #685, #3967
  static fase6 + #686, #3967
  static fase6 + #687, #3967
  static fase6 + #688, #3967
  static fase6 + #689, #0
  static fase6 + #690, #127
  static fase6 + #691, #3967
  static fase6 + #692, #3967
  static fase6 + #693, #3967
  static fase6 + #694, #3967
  static fase6 + #695, #3967
  static fase6 + #696, #3967
  static fase6 + #697, #3
  static fase6 + #698, #3967
  static fase6 + #699, #3967
  static fase6 + #700, #3967
  static fase6 + #701, #3967
  static fase6 + #702, #3967
  static fase6 + #703, #3967
  static fase6 + #704, #3967
  static fase6 + #705, #3967
  static fase6 + #706, #3967
  static fase6 + #707, #3967
  static fase6 + #708, #3967
  static fase6 + #709, #3967
  static fase6 + #710, #0
  static fase6 + #711, #3967
  static fase6 + #712, #3967
  static fase6 + #713, #0
  static fase6 + #714, #3967
  static fase6 + #715, #3967
  static fase6 + #716, #0
  static fase6 + #717, #3967
  static fase6 + #718, #3967
  static fase6 + #719, #0

  ;Linha 18
  static fase6 + #720, #0
  static fase6 + #721, #0
  static fase6 + #722, #0
  static fase6 + #723, #3
  static fase6 + #724, #0
  static fase6 + #725, #3967
  static fase6 + #726, #3967
  static fase6 + #727, #3967
  static fase6 + #728, #3967
  static fase6 + #729, #0
  static fase6 + #730, #3840
  static fase6 + #731, #3840
  static fase6 + #732, #0
  static fase6 + #733, #0
  static fase6 + #734, #0
  static fase6 + #735, #0
  static fase6 + #736, #0
  static fase6 + #737, #0
  static fase6 + #738, #0
  static fase6 + #739, #0
  static fase6 + #740, #0
  static fase6 + #741, #0
  static fase6 + #742, #0
  static fase6 + #743, #0
  static fase6 + #744, #0
  static fase6 + #745, #0
  static fase6 + #746, #0
  static fase6 + #747, #0
  static fase6 + #748, #3967
  static fase6 + #749, #3967
  static fase6 + #750, #0
  static fase6 + #751, #3967
  static fase6 + #752, #3967
  static fase6 + #753, #0
  static fase6 + #754, #3967
  static fase6 + #755, #3967
  static fase6 + #756, #0
  static fase6 + #757, #3967
  static fase6 + #758, #3967
  static fase6 + #759, #0

  ;Linha 19
  static fase6 + #760, #0
  static fase6 + #761, #3840
  static fase6 + #762, #3967
  static fase6 + #763, #3967
  static fase6 + #764, #0
  static fase6 + #765, #3967
  static fase6 + #766, #3967
  static fase6 + #767, #3967
  static fase6 + #768, #3967
  static fase6 + #769, #0
  static fase6 + #770, #3840
  static fase6 + #771, #3967
  static fase6 + #772, #3967
  static fase6 + #773, #3967
  static fase6 + #774, #3967
  static fase6 + #775, #3967
  static fase6 + #776, #3967
  static fase6 + #777, #3967
  static fase6 + #778, #3967
  static fase6 + #779, #3967
  static fase6 + #780, #3967
  static fase6 + #781, #3967
  static fase6 + #782, #3967
  static fase6 + #783, #3
  static fase6 + #784, #3967
  static fase6 + #785, #3967
  static fase6 + #786, #3840
  static fase6 + #787, #3840
  static fase6 + #788, #3840
  static fase6 + #789, #3967
  static fase6 + #790, #0
  static fase6 + #791, #3967
  static fase6 + #792, #3967
  static fase6 + #793, #0
  static fase6 + #794, #3967
  static fase6 + #795, #3967
  static fase6 + #796, #0
  static fase6 + #797, #3967
  static fase6 + #798, #3967
  static fase6 + #799, #0

  ;Linha 20
  static fase6 + #800, #0
  static fase6 + #801, #3840
  static fase6 + #802, #3967
  static fase6 + #803, #3967
  static fase6 + #804, #0
  static fase6 + #805, #3967
  static fase6 + #806, #3967
  static fase6 + #807, #3967
  static fase6 + #808, #3967
  static fase6 + #809, #0
  static fase6 + #810, #0
  static fase6 + #811, #0
  static fase6 + #812, #0
  static fase6 + #813, #0
  static fase6 + #814, #0
  static fase6 + #815, #0
  static fase6 + #816, #0
  static fase6 + #817, #0
  static fase6 + #818, #0
  static fase6 + #819, #0
  static fase6 + #820, #0
  static fase6 + #821, #0
  static fase6 + #822, #0
  static fase6 + #823, #0
  static fase6 + #824, #0
  static fase6 + #825, #0
  static fase6 + #826, #0
  static fase6 + #827, #0
  static fase6 + #828, #0
  static fase6 + #829, #0
  static fase6 + #830, #0
  static fase6 + #831, #3967
  static fase6 + #832, #3967
  static fase6 + #833, #0
  static fase6 + #834, #3967
  static fase6 + #835, #3967
  static fase6 + #836, #0
  static fase6 + #837, #3967
  static fase6 + #838, #3967
  static fase6 + #839, #0

  ;Linha 21
  static fase6 + #840, #0
  static fase6 + #841, #3840
  static fase6 + #842, #0
  static fase6 + #843, #0
  static fase6 + #844, #0
  static fase6 + #845, #3967
  static fase6 + #846, #3967
  static fase6 + #847, #3967
  static fase6 + #848, #3967
  static fase6 + #849, #3840
  static fase6 + #850, #3840
  static fase6 + #851, #3967
  static fase6 + #852, #3967
  static fase6 + #853, #3967
  static fase6 + #854, #3967
  static fase6 + #855, #3967
  static fase6 + #856, #3967
  static fase6 + #857, #3967
  static fase6 + #858, #3967
  static fase6 + #859, #3967
  static fase6 + #860, #3967
  static fase6 + #861, #3967
  static fase6 + #862, #3967
  static fase6 + #863, #3967
  static fase6 + #864, #3967
  static fase6 + #865, #3967
  static fase6 + #866, #3967
  static fase6 + #867, #3967
  static fase6 + #868, #3967
  static fase6 + #869, #3967
  static fase6 + #870, #3967
  static fase6 + #871, #3967
  static fase6 + #872, #3967
  static fase6 + #873, #0
  static fase6 + #874, #3967
  static fase6 + #875, #3967
  static fase6 + #876, #0
  static fase6 + #877, #3967
  static fase6 + #878, #3967
  static fase6 + #879, #0

  ;Linha 22
  static fase6 + #880, #0
  static fase6 + #881, #3967
  static fase6 + #882, #3967
  static fase6 + #883, #3967
  static fase6 + #884, #0
  static fase6 + #885, #3967
  static fase6 + #886, #3967
  static fase6 + #887, #3967
  static fase6 + #888, #3967
  static fase6 + #889, #3967
  static fase6 + #890, #3967
  static fase6 + #891, #3967
  static fase6 + #892, #3967
  static fase6 + #893, #3967
  static fase6 + #894, #3967
  static fase6 + #895, #3967
  static fase6 + #896, #3967
  static fase6 + #897, #3967
  static fase6 + #898, #3967
  static fase6 + #899, #3967
  static fase6 + #900, #3967
  static fase6 + #901, #3967
  static fase6 + #902, #3967
  static fase6 + #903, #3967
  static fase6 + #904, #3967
  static fase6 + #905, #3967
  static fase6 + #906, #3967
  static fase6 + #907, #3967
  static fase6 + #908, #3967
  static fase6 + #909, #3967
  static fase6 + #910, #3967
  static fase6 + #911, #3967
  static fase6 + #912, #3967
  static fase6 + #913, #0
  static fase6 + #914, #0
  static fase6 + #915, #0
  static fase6 + #916, #0
  static fase6 + #917, #3967
  static fase6 + #918, #3967
  static fase6 + #919, #0

  ;Linha 23
  static fase6 + #920, #0
  static fase6 + #921, #0
  static fase6 + #922, #0
  static fase6 + #923, #3
  static fase6 + #924, #0
  static fase6 + #925, #3967
  static fase6 + #926, #3967
  static fase6 + #927, #3967
  static fase6 + #928, #3967
  static fase6 + #929, #3967
  static fase6 + #930, #3967
  static fase6 + #931, #3967
  static fase6 + #932, #3967
  static fase6 + #933, #3967
  static fase6 + #934, #3967
  static fase6 + #935, #3840
  static fase6 + #936, #3840
  static fase6 + #937, #3840
  static fase6 + #938, #3840
  static fase6 + #939, #3840
  static fase6 + #940, #3840
  static fase6 + #941, #3840
  static fase6 + #942, #3967
  static fase6 + #943, #3967
  static fase6 + #944, #3967
  static fase6 + #945, #3967
  static fase6 + #946, #3967
  static fase6 + #947, #3967
  static fase6 + #948, #3967
  static fase6 + #949, #3967
  static fase6 + #950, #3967
  static fase6 + #951, #3967
  static fase6 + #952, #3967
  static fase6 + #953, #0
  static fase6 + #954, #3967
  static fase6 + #955, #3967
  static fase6 + #956, #3967
  static fase6 + #957, #3967
  static fase6 + #958, #3967
  static fase6 + #959, #0

  ;Linha 24
  static fase6 + #960, #0
  static fase6 + #961, #3967
  static fase6 + #962, #3967
  static fase6 + #963, #3967
  static fase6 + #964, #0
  static fase6 + #965, #3967
  static fase6 + #966, #3967
  static fase6 + #967, #0
  static fase6 + #968, #0
  static fase6 + #969, #0
  static fase6 + #970, #0
  static fase6 + #971, #0
  static fase6 + #972, #0
  static fase6 + #973, #0
  static fase6 + #974, #0
  static fase6 + #975, #0
  static fase6 + #976, #0
  static fase6 + #977, #0
  static fase6 + #978, #0
  static fase6 + #979, #0
  static fase6 + #980, #0
  static fase6 + #981, #0
  static fase6 + #982, #0
  static fase6 + #983, #0
  static fase6 + #984, #0
  static fase6 + #985, #0
  static fase6 + #986, #0
  static fase6 + #987, #0
  static fase6 + #988, #0
  static fase6 + #989, #0
  static fase6 + #990, #0
  static fase6 + #991, #0
  static fase6 + #992, #0
  static fase6 + #993, #0
  static fase6 + #994, #3967
  static fase6 + #995, #3967
  static fase6 + #996, #3967
  static fase6 + #997, #3967
  static fase6 + #998, #3967
  static fase6 + #999, #0

  ;Linha 25
  static fase6 + #1000, #0
  static fase6 + #1001, #3967
  static fase6 + #1002, #0
  static fase6 + #1003, #0
  static fase6 + #1004, #0
  static fase6 + #1005, #3967
  static fase6 + #1006, #3967
  static fase6 + #1007, #3967
  static fase6 + #1008, #3967
  static fase6 + #1009, #0
  static fase6 + #1010, #3967
  static fase6 + #1011, #3967
  static fase6 + #1012, #3
  static fase6 + #1013, #3967
  static fase6 + #1014, #3967
  static fase6 + #1015, #3967
  static fase6 + #1016, #3967
  static fase6 + #1017, #3967
  static fase6 + #1018, #3967
  static fase6 + #1019, #3967
  static fase6 + #1020, #3967
  static fase6 + #1021, #3967
  static fase6 + #1022, #3967
  static fase6 + #1023, #3967
  static fase6 + #1024, #3967
  static fase6 + #1025, #3967
  static fase6 + #1026, #3967
  static fase6 + #1027, #3967
  static fase6 + #1028, #3
  static fase6 + #1029, #3967
  static fase6 + #1030, #3967
  static fase6 + #1031, #3967
  static fase6 + #1032, #3967
  static fase6 + #1033, #3967
  static fase6 + #1034, #3967
  static fase6 + #1035, #3967
  static fase6 + #1036, #3967
  static fase6 + #1037, #3967
  static fase6 + #1038, #3967
  static fase6 + #1039, #0

  ;Linha 26
  static fase6 + #1040, #0
  static fase6 + #1041, #3967
  static fase6 + #1042, #3
  static fase6 + #1043, #3967
  static fase6 + #1044, #0
  static fase6 + #1045, #3967
  static fase6 + #1046, #3967
  static fase6 + #1047, #3967
  static fase6 + #1048, #3967
  static fase6 + #1049, #0
  static fase6 + #1050, #0
  static fase6 + #1051, #0
  static fase6 + #1052, #0
  static fase6 + #1053, #0
  static fase6 + #1054, #0
  static fase6 + #1055, #0
  static fase6 + #1056, #0
  static fase6 + #1057, #0
  static fase6 + #1058, #0
  static fase6 + #1059, #0
  static fase6 + #1060, #0
  static fase6 + #1061, #0
  static fase6 + #1062, #0
  static fase6 + #1063, #0
  static fase6 + #1064, #0
  static fase6 + #1065, #0
  static fase6 + #1066, #0
  static fase6 + #1067, #0
  static fase6 + #1068, #0
  static fase6 + #1069, #0
  static fase6 + #1070, #0
  static fase6 + #1071, #0
  static fase6 + #1072, #0
  static fase6 + #1073, #3967
  static fase6 + #1074, #3967
  static fase6 + #1075, #3967
  static fase6 + #1076, #3967
  static fase6 + #1077, #3967
  static fase6 + #1078, #3967
  static fase6 + #1079, #0

  ;Linha 27
  static fase6 + #1080, #0
  static fase6 + #1081, #0
  static fase6 + #1082, #0
  static fase6 + #1083, #3967
  static fase6 + #1084, #0
  static fase6 + #1085, #3967
  static fase6 + #1086, #3967
  static fase6 + #1087, #3967
  static fase6 + #1088, #3967
  static fase6 + #1089, #0
  static fase6 + #1090, #3967
  static fase6 + #1091, #3967
  static fase6 + #1092, #3967
  static fase6 + #1093, #3967
  static fase6 + #1094, #3967
  static fase6 + #1095, #3967
  static fase6 + #1096, #3967
  static fase6 + #1097, #3967
  static fase6 + #1098, #3967
  static fase6 + #1099, #3967
  static fase6 + #1100, #3967
  static fase6 + #1101, #3967
  static fase6 + #1102, #3967
  static fase6 + #1103, #3967
  static fase6 + #1104, #3967
  static fase6 + #1105, #3967
  static fase6 + #1106, #3967
  static fase6 + #1107, #3967
  static fase6 + #1108, #3967
  static fase6 + #1109, #3967
  static fase6 + #1110, #3967
  static fase6 + #1111, #3967
  static fase6 + #1112, #3967
  static fase6 + #1113, #3967
  static fase6 + #1114, #3967
  static fase6 + #1115, #3967
  static fase6 + #1116, #3967
  static fase6 + #1117, #3967
  static fase6 + #1118, #3967
  static fase6 + #1119, #0

  ;Linha 28
  static fase6 + #1120, #0
  static fase6 + #1121, #3967
  static fase6 + #1122, #3967
  static fase6 + #1123, #3967
  static fase6 + #1124, #0
  static fase6 + #1125, #639
  static fase6 + #1126, #514
  static fase6 + #1127, #514
  static fase6 + #1128, #639
  static fase6 + #1129, #0
  static fase6 + #1130, #3967
  static fase6 + #1131, #3967
  static fase6 + #1132, #3967
  static fase6 + #1133, #3967
  static fase6 + #1134, #3967
  static fase6 + #1135, #3967
  static fase6 + #1136, #3967
  static fase6 + #1137, #3967
  static fase6 + #1138, #3967
  static fase6 + #1139, #3967
  static fase6 + #1140, #3967
  static fase6 + #1141, #3967
  static fase6 + #1142, #3967
  static fase6 + #1143, #3967
  static fase6 + #1144, #3967
  static fase6 + #1145, #3967
  static fase6 + #1146, #3967
  static fase6 + #1147, #3967
  static fase6 + #1148, #3967
  static fase6 + #1149, #3967
  static fase6 + #1150, #3967
  static fase6 + #1151, #3967
  static fase6 + #1152, #3967
  static fase6 + #1153, #3967
  static fase6 + #1154, #3967
  static fase6 + #1155, #3967
  static fase6 + #1156, #3967
  static fase6 + #1157, #3967
  static fase6 + #1158, #3967
  static fase6 + #1159, #0

  ;Linha 29
  static fase6 + #1160, #0
  static fase6 + #1161, #0
  static fase6 + #1162, #0
  static fase6 + #1163, #0
  static fase6 + #1164, #0
  static fase6 + #1165, #0
  static fase6 + #1166, #0
  static fase6 + #1167, #0
  static fase6 + #1168, #0
  static fase6 + #1169, #0
  static fase6 + #1170, #0
  static fase6 + #1171, #0
  static fase6 + #1172, #0
  static fase6 + #1173, #0
  static fase6 + #1174, #0
  static fase6 + #1175, #0
  static fase6 + #1176, #0
  static fase6 + #1177, #0
  static fase6 + #1178, #0
  static fase6 + #1179, #0
  static fase6 + #1180, #0
  static fase6 + #1181, #0
  static fase6 + #1182, #0
  static fase6 + #1183, #0
  static fase6 + #1184, #0
  static fase6 + #1185, #0
  static fase6 + #1186, #0
  static fase6 + #1187, #0
  static fase6 + #1188, #0
  static fase6 + #1189, #0
  static fase6 + #1190, #0
  static fase6 + #1191, #0
  static fase6 + #1192, #0
  static fase6 + #1193, #0
  static fase6 + #1194, #0
  static fase6 + #1195, #0
  static fase6 + #1196, #0
  static fase6 + #1197, #0
  static fase6 + #1198, #0
  static fase6 + #1199, #0

fase7 : var #1200
  ;Linha 0
  static fase7 + #0, #0
  static fase7 + #1, #0
  static fase7 + #2, #0
  static fase7 + #3, #0
  static fase7 + #4, #0
  static fase7 + #5, #0
  static fase7 + #6, #0
  static fase7 + #7, #0
  static fase7 + #8, #0
  static fase7 + #9, #0
  static fase7 + #10, #0
  static fase7 + #11, #0
  static fase7 + #12, #0
  static fase7 + #13, #0
  static fase7 + #14, #0
  static fase7 + #15, #0
  static fase7 + #16, #0
  static fase7 + #17, #0
  static fase7 + #18, #0
  static fase7 + #19, #0
  static fase7 + #20, #0
  static fase7 + #21, #0
  static fase7 + #22, #0
  static fase7 + #23, #0
  static fase7 + #24, #0
  static fase7 + #25, #0
  static fase7 + #26, #0
  static fase7 + #27, #0
  static fase7 + #28, #0
  static fase7 + #29, #0
  static fase7 + #30, #0
  static fase7 + #31, #0
  static fase7 + #32, #0
  static fase7 + #33, #0
  static fase7 + #34, #0
  static fase7 + #35, #0
  static fase7 + #36, #0
  static fase7 + #37, #0
  static fase7 + #38, #0
  static fase7 + #39, #0

  ;Linha 1
  static fase7 + #40, #0
  static fase7 + #41, #3967
  static fase7 + #42, #3967
  static fase7 + #43, #3967
  static fase7 + #44, #3967
  static fase7 + #45, #0
  static fase7 + #46, #3967
  static fase7 + #47, #3967
  static fase7 + #48, #3967
  static fase7 + #49, #3967
  static fase7 + #50, #0
  static fase7 + #51, #3
  static fase7 + #52, #3967
  static fase7 + #53, #3967
  static fase7 + #54, #3967
  static fase7 + #55, #3967
  static fase7 + #56, #3967
  static fase7 + #57, #3967
  static fase7 + #58, #3967
  static fase7 + #59, #3967
  static fase7 + #60, #3967
  static fase7 + #61, #3967
  static fase7 + #62, #3967
  static fase7 + #63, #3967
  static fase7 + #64, #3967
  static fase7 + #65, #3967
  static fase7 + #66, #3967
  static fase7 + #67, #3967
  static fase7 + #68, #3967
  static fase7 + #69, #0
  static fase7 + #70, #3967
  static fase7 + #71, #3967
  static fase7 + #72, #3967
  static fase7 + #73, #3967
  static fase7 + #74, #3967
  static fase7 + #75, #3967
  static fase7 + #76, #3967
  static fase7 + #77, #3967
  static fase7 + #78, #3967
  static fase7 + #79, #0

  ;Linha 2
  static fase7 + #80, #0
  static fase7 + #81, #3967
  static fase7 + #82, #3967
  static fase7 + #83, #3967
  static fase7 + #84, #3967
  static fase7 + #85, #0
  static fase7 + #86, #3967
  static fase7 + #87, #3967
  static fase7 + #88, #3967
  static fase7 + #89, #3967
  static fase7 + #90, #0
  static fase7 + #91, #3967
  static fase7 + #92, #3967
  static fase7 + #93, #3967
  static fase7 + #94, #3967
  static fase7 + #95, #3967
  static fase7 + #96, #3967
  static fase7 + #97, #3967
  static fase7 + #98, #3967
  static fase7 + #99, #3967
  static fase7 + #100, #3967
  static fase7 + #101, #3967
  static fase7 + #102, #3967
  static fase7 + #103, #3967
  static fase7 + #104, #3967
  static fase7 + #105, #3967
  static fase7 + #106, #3967
  static fase7 + #107, #3967
  static fase7 + #108, #3967
  static fase7 + #109, #0
  static fase7 + #110, #3967
  static fase7 + #111, #3967
  static fase7 + #112, #3967
  static fase7 + #113, #3967
  static fase7 + #114, #3
  static fase7 + #115, #3967
  static fase7 + #116, #3967
  static fase7 + #117, #3967
  static fase7 + #118, #3967
  static fase7 + #119, #0

  ;Linha 3
  static fase7 + #120, #0
  static fase7 + #121, #3840
  static fase7 + #122, #3967
  static fase7 + #123, #3967
  static fase7 + #124, #3967
  static fase7 + #125, #0
  static fase7 + #126, #0
  static fase7 + #127, #0
  static fase7 + #128, #3967
  static fase7 + #129, #3967
  static fase7 + #130, #0
  static fase7 + #131, #0
  static fase7 + #132, #0
  static fase7 + #133, #3967
  static fase7 + #134, #3967
  static fase7 + #135, #3967
  static fase7 + #136, #3967
  static fase7 + #137, #3967
  static fase7 + #138, #0
  static fase7 + #139, #0
  static fase7 + #140, #0
  static fase7 + #141, #0
  static fase7 + #142, #0
  static fase7 + #143, #0
  static fase7 + #144, #3967
  static fase7 + #145, #3967
  static fase7 + #146, #3967
  static fase7 + #147, #3967
  static fase7 + #148, #3967
  static fase7 + #149, #0
  static fase7 + #150, #3967
  static fase7 + #151, #3967
  static fase7 + #152, #3967
  static fase7 + #153, #3967
  static fase7 + #154, #0
  static fase7 + #155, #3967
  static fase7 + #156, #3967
  static fase7 + #157, #3967
  static fase7 + #158, #3967
  static fase7 + #159, #0

  ;Linha 4
  static fase7 + #160, #0
  static fase7 + #161, #3840
  static fase7 + #162, #3967
  static fase7 + #163, #3967
  static fase7 + #164, #3967
  static fase7 + #165, #3967
  static fase7 + #166, #3967
  static fase7 + #167, #3967
  static fase7 + #168, #3967
  static fase7 + #169, #3967
  static fase7 + #170, #3967
  static fase7 + #171, #3967
  static fase7 + #172, #3967
  static fase7 + #173, #3967
  static fase7 + #174, #3967
  static fase7 + #175, #3967
  static fase7 + #176, #3967
  static fase7 + #177, #3967
  static fase7 + #178, #0
  static fase7 + #179, #3967
  static fase7 + #180, #3967
  static fase7 + #181, #3967
  static fase7 + #182, #3967
  static fase7 + #183, #3967
  static fase7 + #184, #3967
  static fase7 + #185, #3967
  static fase7 + #186, #3967
  static fase7 + #187, #3967
  static fase7 + #188, #3967
  static fase7 + #189, #0
  static fase7 + #190, #3967
  static fase7 + #191, #3967
  static fase7 + #192, #3967
  static fase7 + #193, #3967
  static fase7 + #194, #0
  static fase7 + #195, #3967
  static fase7 + #196, #3967
  static fase7 + #197, #3967
  static fase7 + #198, #3967
  static fase7 + #199, #0

  ;Linha 5
  static fase7 + #200, #0
  static fase7 + #201, #3840
  static fase7 + #202, #3840
  static fase7 + #203, #3967
  static fase7 + #204, #3967
  static fase7 + #205, #3967
  static fase7 + #206, #3967
  static fase7 + #207, #3967
  static fase7 + #208, #3967
  static fase7 + #209, #3967
  static fase7 + #210, #3967
  static fase7 + #211, #3967
  static fase7 + #212, #3967
  static fase7 + #213, #3967
  static fase7 + #214, #3967
  static fase7 + #215, #3967
  static fase7 + #216, #3967
  static fase7 + #217, #3967
  static fase7 + #218, #0
  static fase7 + #219, #3
  static fase7 + #220, #3967
  static fase7 + #221, #3967
  static fase7 + #222, #3967
  static fase7 + #223, #3967
  static fase7 + #224, #3967
  static fase7 + #225, #3967
  static fase7 + #226, #3967
  static fase7 + #227, #3967
  static fase7 + #228, #3967
  static fase7 + #229, #0
  static fase7 + #230, #0
  static fase7 + #231, #0
  static fase7 + #232, #0
  static fase7 + #233, #0
  static fase7 + #234, #0
  static fase7 + #235, #3967
  static fase7 + #236, #3967
  static fase7 + #237, #3967
  static fase7 + #238, #3967
  static fase7 + #239, #0

  ;Linha 6
  static fase7 + #240, #0
  static fase7 + #241, #0
  static fase7 + #242, #0
  static fase7 + #243, #127
  static fase7 + #244, #3967
  static fase7 + #245, #127
  static fase7 + #246, #0
  static fase7 + #247, #0
  static fase7 + #248, #0
  static fase7 + #249, #0
  static fase7 + #250, #0
  static fase7 + #251, #0
  static fase7 + #252, #0
  static fase7 + #253, #0
  static fase7 + #254, #0
  static fase7 + #255, #0
  static fase7 + #256, #0
  static fase7 + #257, #0
  static fase7 + #258, #0
  static fase7 + #259, #0
  static fase7 + #260, #0
  static fase7 + #261, #0
  static fase7 + #262, #0
  static fase7 + #263, #0
  static fase7 + #264, #3967
  static fase7 + #265, #3967
  static fase7 + #266, #3967
  static fase7 + #267, #3967
  static fase7 + #268, #3967
  static fase7 + #269, #3967
  static fase7 + #270, #3967
  static fase7 + #271, #3967
  static fase7 + #272, #3967
  static fase7 + #273, #3967
  static fase7 + #274, #3967
  static fase7 + #275, #3967
  static fase7 + #276, #3967
  static fase7 + #277, #3967
  static fase7 + #278, #3967
  static fase7 + #279, #0

  ;Linha 7
  static fase7 + #280, #0
  static fase7 + #281, #3967
  static fase7 + #282, #3967
  static fase7 + #283, #3967
  static fase7 + #284, #3967
  static fase7 + #285, #3967
  static fase7 + #286, #3967
  static fase7 + #287, #3967
  static fase7 + #288, #3967
  static fase7 + #289, #0
  static fase7 + #290, #3967
  static fase7 + #291, #3
  static fase7 + #292, #3967
  static fase7 + #293, #3840
  static fase7 + #294, #3840
  static fase7 + #295, #3840
  static fase7 + #296, #3840
  static fase7 + #297, #3840
  static fase7 + #298, #3967
  static fase7 + #299, #3967
  static fase7 + #300, #3967
  static fase7 + #301, #3967
  static fase7 + #302, #3840
  static fase7 + #303, #0
  static fase7 + #304, #3967
  static fase7 + #305, #3967
  static fase7 + #306, #3967
  static fase7 + #307, #3967
  static fase7 + #308, #3967
  static fase7 + #309, #3967
  static fase7 + #310, #3967
  static fase7 + #311, #3967
  static fase7 + #312, #3967
  static fase7 + #313, #3967
  static fase7 + #314, #3967
  static fase7 + #315, #3967
  static fase7 + #316, #3967
  static fase7 + #317, #3967
  static fase7 + #318, #3967
  static fase7 + #319, #0

  ;Linha 8
  static fase7 + #320, #0
  static fase7 + #321, #3967
  static fase7 + #322, #3967
  static fase7 + #323, #3967
  static fase7 + #324, #3967
  static fase7 + #325, #3967
  static fase7 + #326, #3967
  static fase7 + #327, #3967
  static fase7 + #328, #3967
  static fase7 + #329, #0
  static fase7 + #330, #3967
  static fase7 + #331, #3967
  static fase7 + #332, #3967
  static fase7 + #333, #3967
  static fase7 + #334, #3967
  static fase7 + #335, #3967
  static fase7 + #336, #3967
  static fase7 + #337, #3967
  static fase7 + #338, #3967
  static fase7 + #339, #3967
  static fase7 + #340, #3967
  static fase7 + #341, #3967
  static fase7 + #342, #3840
  static fase7 + #343, #0
  static fase7 + #344, #3967
  static fase7 + #345, #3967
  static fase7 + #346, #3967
  static fase7 + #347, #3967
  static fase7 + #348, #3967
  static fase7 + #349, #3967
  static fase7 + #350, #3967
  static fase7 + #351, #3967
  static fase7 + #352, #3967
  static fase7 + #353, #3967
  static fase7 + #354, #3967
  static fase7 + #355, #3967
  static fase7 + #356, #3967
  static fase7 + #357, #3967
  static fase7 + #358, #3967
  static fase7 + #359, #0

  ;Linha 9
  static fase7 + #360, #0
  static fase7 + #361, #3967
  static fase7 + #362, #0
  static fase7 + #363, #0
  static fase7 + #364, #0
  static fase7 + #365, #0
  static fase7 + #366, #0
  static fase7 + #367, #3967
  static fase7 + #368, #3967
  static fase7 + #369, #0
  static fase7 + #370, #127
  static fase7 + #371, #127
  static fase7 + #372, #127
  static fase7 + #373, #127
  static fase7 + #374, #3
  static fase7 + #375, #127
  static fase7 + #376, #127
  static fase7 + #377, #127
  static fase7 + #378, #127
  static fase7 + #379, #127
  static fase7 + #380, #127
  static fase7 + #381, #127
  static fase7 + #382, #3967
  static fase7 + #383, #0
  static fase7 + #384, #0
  static fase7 + #385, #0
  static fase7 + #386, #0
  static fase7 + #387, #0
  static fase7 + #388, #0
  static fase7 + #389, #0
  static fase7 + #390, #0
  static fase7 + #391, #0
  static fase7 + #392, #0
  static fase7 + #393, #0
  static fase7 + #394, #0
  static fase7 + #395, #127
  static fase7 + #396, #127
  static fase7 + #397, #3967
  static fase7 + #398, #3967
  static fase7 + #399, #0

  ;Linha 10
  static fase7 + #400, #0
  static fase7 + #401, #3967
  static fase7 + #402, #3967
  static fase7 + #403, #3967
  static fase7 + #404, #3
  static fase7 + #405, #3967
  static fase7 + #406, #3967
  static fase7 + #407, #3967
  static fase7 + #408, #3967
  static fase7 + #409, #0
  static fase7 + #410, #3967
  static fase7 + #411, #3967
  static fase7 + #412, #3967
  static fase7 + #413, #3967
  static fase7 + #414, #3967
  static fase7 + #415, #3967
  static fase7 + #416, #3967
  static fase7 + #417, #3967
  static fase7 + #418, #3967
  static fase7 + #419, #3967
  static fase7 + #420, #3967
  static fase7 + #421, #127
  static fase7 + #422, #3967
  static fase7 + #423, #3967
  static fase7 + #424, #3967
  static fase7 + #425, #3967
  static fase7 + #426, #3967
  static fase7 + #427, #3967
  static fase7 + #428, #3967
  static fase7 + #429, #3967
  static fase7 + #430, #3967
  static fase7 + #431, #3967
  static fase7 + #432, #3967
  static fase7 + #433, #3967
  static fase7 + #434, #3967
  static fase7 + #435, #3967
  static fase7 + #436, #3967
  static fase7 + #437, #3967
  static fase7 + #438, #3967
  static fase7 + #439, #0

  ;Linha 11
  static fase7 + #440, #0
  static fase7 + #441, #3967
  static fase7 + #442, #3967
  static fase7 + #443, #3967
  static fase7 + #444, #0
  static fase7 + #445, #0
  static fase7 + #446, #0
  static fase7 + #447, #0
  static fase7 + #448, #0
  static fase7 + #449, #0
  static fase7 + #450, #0
  static fase7 + #451, #0
  static fase7 + #452, #0
  static fase7 + #453, #0
  static fase7 + #454, #0
  static fase7 + #455, #0
  static fase7 + #456, #0
  static fase7 + #457, #0
  static fase7 + #458, #0
  static fase7 + #459, #0
  static fase7 + #460, #3967
  static fase7 + #461, #127
  static fase7 + #462, #3967
  static fase7 + #463, #3
  static fase7 + #464, #3967
  static fase7 + #465, #3967
  static fase7 + #466, #3967
  static fase7 + #467, #3967
  static fase7 + #468, #3967
  static fase7 + #469, #3967
  static fase7 + #470, #3967
  static fase7 + #471, #3967
  static fase7 + #472, #3967
  static fase7 + #473, #3967
  static fase7 + #474, #3967
  static fase7 + #475, #3967
  static fase7 + #476, #3967
  static fase7 + #477, #3967
  static fase7 + #478, #3967
  static fase7 + #479, #0

  ;Linha 12
  static fase7 + #480, #0
  static fase7 + #481, #3967
  static fase7 + #482, #3967
  static fase7 + #483, #3967
  static fase7 + #484, #3967
  static fase7 + #485, #3967
  static fase7 + #486, #3967
  static fase7 + #487, #3967
  static fase7 + #488, #3967
  static fase7 + #489, #0
  static fase7 + #490, #3967
  static fase7 + #491, #3967
  static fase7 + #492, #3967
  static fase7 + #493, #3967
  static fase7 + #494, #3967
  static fase7 + #495, #3967
  static fase7 + #496, #3967
  static fase7 + #497, #3967
  static fase7 + #498, #127
  static fase7 + #499, #0
  static fase7 + #500, #3967
  static fase7 + #501, #3967
  static fase7 + #502, #3967
  static fase7 + #503, #0
  static fase7 + #504, #3967
  static fase7 + #505, #3967
  static fase7 + #506, #3967
  static fase7 + #507, #3967
  static fase7 + #508, #0
  static fase7 + #509, #0
  static fase7 + #510, #0
  static fase7 + #511, #0
  static fase7 + #512, #0
  static fase7 + #513, #0
  static fase7 + #514, #0
  static fase7 + #515, #0
  static fase7 + #516, #0
  static fase7 + #517, #0
  static fase7 + #518, #0
  static fase7 + #519, #0

  ;Linha 13
  static fase7 + #520, #0
  static fase7 + #521, #3967
  static fase7 + #522, #0
  static fase7 + #523, #0
  static fase7 + #524, #0
  static fase7 + #525, #0
  static fase7 + #526, #3967
  static fase7 + #527, #3967
  static fase7 + #528, #3967
  static fase7 + #529, #0
  static fase7 + #530, #3967
  static fase7 + #531, #3967
  static fase7 + #532, #3967
  static fase7 + #533, #3967
  static fase7 + #534, #3967
  static fase7 + #535, #3967
  static fase7 + #536, #3967
  static fase7 + #537, #3967
  static fase7 + #538, #127
  static fase7 + #539, #0
  static fase7 + #540, #3967
  static fase7 + #541, #3967
  static fase7 + #542, #3967
  static fase7 + #543, #0
  static fase7 + #544, #3967
  static fase7 + #545, #3967
  static fase7 + #546, #3967
  static fase7 + #547, #3967
  static fase7 + #548, #0
  static fase7 + #549, #3967
  static fase7 + #550, #3967
  static fase7 + #551, #3967
  static fase7 + #552, #3967
  static fase7 + #553, #3967
  static fase7 + #554, #3967
  static fase7 + #555, #3967
  static fase7 + #556, #3967
  static fase7 + #557, #3967
  static fase7 + #558, #3967
  static fase7 + #559, #0

  ;Linha 14
  static fase7 + #560, #0
  static fase7 + #561, #3967
  static fase7 + #562, #3967
  static fase7 + #563, #3967
  static fase7 + #564, #3
  static fase7 + #565, #3967
  static fase7 + #566, #3967
  static fase7 + #567, #3967
  static fase7 + #568, #3967
  static fase7 + #569, #0
  static fase7 + #570, #3967
  static fase7 + #571, #3967
  static fase7 + #572, #3967
  static fase7 + #573, #3967
  static fase7 + #574, #3967
  static fase7 + #575, #3967
  static fase7 + #576, #0
  static fase7 + #577, #0
  static fase7 + #578, #0
  static fase7 + #579, #0
  static fase7 + #580, #3967
  static fase7 + #581, #127
  static fase7 + #582, #127
  static fase7 + #583, #0
  static fase7 + #584, #127
  static fase7 + #585, #127
  static fase7 + #586, #127
  static fase7 + #587, #127
  static fase7 + #588, #0
  static fase7 + #589, #3967
  static fase7 + #590, #127
  static fase7 + #591, #127
  static fase7 + #592, #127
  static fase7 + #593, #127
  static fase7 + #594, #127
  static fase7 + #595, #3967
  static fase7 + #596, #3967
  static fase7 + #597, #3967
  static fase7 + #598, #3967
  static fase7 + #599, #0

  ;Linha 15
  static fase7 + #600, #0
  static fase7 + #601, #0
  static fase7 + #602, #0
  static fase7 + #603, #0
  static fase7 + #604, #0
  static fase7 + #605, #0
  static fase7 + #606, #3967
  static fase7 + #607, #3967
  static fase7 + #608, #3967
  static fase7 + #609, #0
  static fase7 + #610, #3967
  static fase7 + #611, #3967
  static fase7 + #612, #3967
  static fase7 + #613, #3967
  static fase7 + #614, #3967
  static fase7 + #615, #3
  static fase7 + #616, #3967
  static fase7 + #617, #3967
  static fase7 + #618, #127
  static fase7 + #619, #127
  static fase7 + #620, #127
  static fase7 + #621, #127
  static fase7 + #622, #127
  static fase7 + #623, #0
  static fase7 + #624, #127
  static fase7 + #625, #127
  static fase7 + #626, #127
  static fase7 + #627, #127
  static fase7 + #628, #0
  static fase7 + #629, #127
  static fase7 + #630, #127
  static fase7 + #631, #127
  static fase7 + #632, #127
  static fase7 + #633, #127
  static fase7 + #634, #127
  static fase7 + #635, #127
  static fase7 + #636, #127
  static fase7 + #637, #127
  static fase7 + #638, #3967
  static fase7 + #639, #0

  ;Linha 16
  static fase7 + #640, #0
  static fase7 + #641, #3967
  static fase7 + #642, #3967
  static fase7 + #643, #3967
  static fase7 + #644, #3967
  static fase7 + #645, #3967
  static fase7 + #646, #3967
  static fase7 + #647, #3967
  static fase7 + #648, #3967
  static fase7 + #649, #0
  static fase7 + #650, #3967
  static fase7 + #651, #3967
  static fase7 + #652, #3967
  static fase7 + #653, #3967
  static fase7 + #654, #0
  static fase7 + #655, #3967
  static fase7 + #656, #3967
  static fase7 + #657, #3967
  static fase7 + #658, #127
  static fase7 + #659, #127
  static fase7 + #660, #3967
  static fase7 + #661, #3967
  static fase7 + #662, #3967
  static fase7 + #663, #3967
  static fase7 + #664, #3967
  static fase7 + #665, #3967
  static fase7 + #666, #3967
  static fase7 + #667, #3967
  static fase7 + #668, #0
  static fase7 + #669, #3967
  static fase7 + #670, #3967
  static fase7 + #671, #3967
  static fase7 + #672, #3967
  static fase7 + #673, #3967
  static fase7 + #674, #3967
  static fase7 + #675, #3967
  static fase7 + #676, #3
  static fase7 + #677, #3967
  static fase7 + #678, #3967
  static fase7 + #679, #0

  ;Linha 17
  static fase7 + #680, #0
  static fase7 + #681, #3967
  static fase7 + #682, #3967
  static fase7 + #683, #0
  static fase7 + #684, #0
  static fase7 + #685, #0
  static fase7 + #686, #0
  static fase7 + #687, #0
  static fase7 + #688, #3967
  static fase7 + #689, #0
  static fase7 + #690, #3967
  static fase7 + #691, #3967
  static fase7 + #692, #3967
  static fase7 + #693, #3967
  static fase7 + #694, #0
  static fase7 + #695, #3967
  static fase7 + #696, #127
  static fase7 + #697, #127
  static fase7 + #698, #127
  static fase7 + #699, #3967
  static fase7 + #700, #3967
  static fase7 + #701, #3967
  static fase7 + #702, #3967
  static fase7 + #703, #3967
  static fase7 + #704, #3967
  static fase7 + #705, #3967
  static fase7 + #706, #3967
  static fase7 + #707, #3967
  static fase7 + #708, #0
  static fase7 + #709, #3967
  static fase7 + #710, #3967
  static fase7 + #711, #3967
  static fase7 + #712, #3967
  static fase7 + #713, #3967
  static fase7 + #714, #3967
  static fase7 + #715, #3967
  static fase7 + #716, #3967
  static fase7 + #717, #3967
  static fase7 + #718, #3967
  static fase7 + #719, #0

  ;Linha 18
  static fase7 + #720, #0
  static fase7 + #721, #3967
  static fase7 + #722, #3967
  static fase7 + #723, #3967
  static fase7 + #724, #3
  static fase7 + #725, #3967
  static fase7 + #726, #3967
  static fase7 + #727, #3967
  static fase7 + #728, #3967
  static fase7 + #729, #0
  static fase7 + #730, #3967
  static fase7 + #731, #3967
  static fase7 + #732, #3967
  static fase7 + #733, #3967
  static fase7 + #734, #0
  static fase7 + #735, #0
  static fase7 + #736, #0
  static fase7 + #737, #0
  static fase7 + #738, #0
  static fase7 + #739, #0
  static fase7 + #740, #0
  static fase7 + #741, #0
  static fase7 + #742, #0
  static fase7 + #743, #0
  static fase7 + #744, #0
  static fase7 + #745, #0
  static fase7 + #746, #0
  static fase7 + #747, #0
  static fase7 + #748, #0
  static fase7 + #749, #0
  static fase7 + #750, #0
  static fase7 + #751, #0
  static fase7 + #752, #0
  static fase7 + #753, #0
  static fase7 + #754, #3967
  static fase7 + #755, #3967
  static fase7 + #756, #3967
  static fase7 + #757, #3967
  static fase7 + #758, #3967
  static fase7 + #759, #0

  ;Linha 19
  static fase7 + #760, #0
  static fase7 + #761, #0
  static fase7 + #762, #0
  static fase7 + #763, #0
  static fase7 + #764, #0
  static fase7 + #765, #0
  static fase7 + #766, #0
  static fase7 + #767, #0
  static fase7 + #768, #0
  static fase7 + #769, #0
  static fase7 + #770, #3967
  static fase7 + #771, #3967
  static fase7 + #772, #127
  static fase7 + #773, #127
  static fase7 + #774, #0
  static fase7 + #775, #127
  static fase7 + #776, #127
  static fase7 + #777, #127
  static fase7 + #778, #0
  static fase7 + #779, #3967
  static fase7 + #780, #3967
  static fase7 + #781, #3967
  static fase7 + #782, #3967
  static fase7 + #783, #3967
  static fase7 + #784, #3967
  static fase7 + #785, #3967
  static fase7 + #786, #3967
  static fase7 + #787, #3967
  static fase7 + #788, #0
  static fase7 + #789, #3967
  static fase7 + #790, #3967
  static fase7 + #791, #3967
  static fase7 + #792, #3967
  static fase7 + #793, #3967
  static fase7 + #794, #3967
  static fase7 + #795, #3967
  static fase7 + #796, #3967
  static fase7 + #797, #3967
  static fase7 + #798, #3967
  static fase7 + #799, #0

  ;Linha 20
  static fase7 + #800, #0
  static fase7 + #801, #3967
  static fase7 + #802, #3967
  static fase7 + #803, #3967
  static fase7 + #804, #0
  static fase7 + #805, #3967
  static fase7 + #806, #3967
  static fase7 + #807, #3967
  static fase7 + #808, #3967
  static fase7 + #809, #127
  static fase7 + #810, #3967
  static fase7 + #811, #3967
  static fase7 + #812, #3967
  static fase7 + #813, #3967
  static fase7 + #814, #0
  static fase7 + #815, #3967
  static fase7 + #816, #3967
  static fase7 + #817, #3967
  static fase7 + #818, #0
  static fase7 + #819, #3967
  static fase7 + #820, #3967
  static fase7 + #821, #3
  static fase7 + #822, #3967
  static fase7 + #823, #3967
  static fase7 + #824, #3967
  static fase7 + #825, #3967
  static fase7 + #826, #3967
  static fase7 + #827, #3967
  static fase7 + #828, #0
  static fase7 + #829, #3967
  static fase7 + #830, #3967
  static fase7 + #831, #3967
  static fase7 + #832, #3967
  static fase7 + #833, #3967
  static fase7 + #834, #3967
  static fase7 + #835, #3967
  static fase7 + #836, #3967
  static fase7 + #837, #3967
  static fase7 + #838, #3967
  static fase7 + #839, #0

  ;Linha 21
  static fase7 + #840, #0
  static fase7 + #841, #3967
  static fase7 + #842, #3967
  static fase7 + #843, #3967
  static fase7 + #844, #0
  static fase7 + #845, #3967
  static fase7 + #846, #3967
  static fase7 + #847, #3967
  static fase7 + #848, #3967
  static fase7 + #849, #3967
  static fase7 + #850, #3967
  static fase7 + #851, #3967
  static fase7 + #852, #3967
  static fase7 + #853, #3967
  static fase7 + #854, #0
  static fase7 + #855, #3967
  static fase7 + #856, #3967
  static fase7 + #857, #3967
  static fase7 + #858, #0
  static fase7 + #859, #3967
  static fase7 + #860, #3967
  static fase7 + #861, #3967
  static fase7 + #862, #3967
  static fase7 + #863, #3967
  static fase7 + #864, #3967
  static fase7 + #865, #3967
  static fase7 + #866, #3967
  static fase7 + #867, #3967
  static fase7 + #868, #0
  static fase7 + #869, #3967
  static fase7 + #870, #3967
  static fase7 + #871, #3967
  static fase7 + #872, #0
  static fase7 + #873, #0
  static fase7 + #874, #0
  static fase7 + #875, #0
  static fase7 + #876, #3967
  static fase7 + #877, #3967
  static fase7 + #878, #3967
  static fase7 + #879, #0

  ;Linha 22
  static fase7 + #880, #0
  static fase7 + #881, #3967
  static fase7 + #882, #3967
  static fase7 + #883, #3967
  static fase7 + #884, #0
  static fase7 + #885, #3967
  static fase7 + #886, #3967
  static fase7 + #887, #3967
  static fase7 + #888, #3967
  static fase7 + #889, #3967
  static fase7 + #890, #3967
  static fase7 + #891, #3967
  static fase7 + #892, #3967
  static fase7 + #893, #3967
  static fase7 + #894, #0
  static fase7 + #895, #3967
  static fase7 + #896, #3967
  static fase7 + #897, #3967
  static fase7 + #898, #0
  static fase7 + #899, #0
  static fase7 + #900, #0
  static fase7 + #901, #0
  static fase7 + #902, #0
  static fase7 + #903, #0
  static fase7 + #904, #3967
  static fase7 + #905, #3967
  static fase7 + #906, #3967
  static fase7 + #907, #3967
  static fase7 + #908, #0
  static fase7 + #909, #3967
  static fase7 + #910, #3967
  static fase7 + #911, #3967
  static fase7 + #912, #0
  static fase7 + #913, #514
  static fase7 + #914, #3967
  static fase7 + #915, #0
  static fase7 + #916, #3967
  static fase7 + #917, #3967
  static fase7 + #918, #3967
  static fase7 + #919, #0

  ;Linha 23
  static fase7 + #920, #0
  static fase7 + #921, #3967
  static fase7 + #922, #3967
  static fase7 + #923, #3967
  static fase7 + #924, #0
  static fase7 + #925, #3
  static fase7 + #926, #3967
  static fase7 + #927, #0
  static fase7 + #928, #0
  static fase7 + #929, #0
  static fase7 + #930, #0
  static fase7 + #931, #0
  static fase7 + #932, #0
  static fase7 + #933, #0
  static fase7 + #934, #0
  static fase7 + #935, #3967
  static fase7 + #936, #3967
  static fase7 + #937, #3967
  static fase7 + #938, #3967
  static fase7 + #939, #3967
  static fase7 + #940, #3967
  static fase7 + #941, #0
  static fase7 + #942, #3967
  static fase7 + #943, #3967
  static fase7 + #944, #3967
  static fase7 + #945, #3967
  static fase7 + #946, #3967
  static fase7 + #947, #3967
  static fase7 + #948, #0
  static fase7 + #949, #3967
  static fase7 + #950, #3967
  static fase7 + #951, #3967
  static fase7 + #952, #0
  static fase7 + #953, #3967
  static fase7 + #954, #3967
  static fase7 + #955, #0
  static fase7 + #956, #3967
  static fase7 + #957, #3967
  static fase7 + #958, #3967
  static fase7 + #959, #0

  ;Linha 24
  static fase7 + #960, #0
  static fase7 + #961, #3967
  static fase7 + #962, #3967
  static fase7 + #963, #3967
  static fase7 + #964, #0
  static fase7 + #965, #3967
  static fase7 + #966, #3967
  static fase7 + #967, #3967
  static fase7 + #968, #3967
  static fase7 + #969, #3967
  static fase7 + #970, #3967
  static fase7 + #971, #3967
  static fase7 + #972, #3967
  static fase7 + #973, #3967
  static fase7 + #974, #3967
  static fase7 + #975, #3967
  static fase7 + #976, #3967
  static fase7 + #977, #3967
  static fase7 + #978, #3967
  static fase7 + #979, #3967
  static fase7 + #980, #3967
  static fase7 + #981, #0
  static fase7 + #982, #3967
  static fase7 + #983, #3967
  static fase7 + #984, #3967
  static fase7 + #985, #3967
  static fase7 + #986, #3967
  static fase7 + #987, #3967
  static fase7 + #988, #3
  static fase7 + #989, #3967
  static fase7 + #990, #3967
  static fase7 + #991, #3967
  static fase7 + #992, #0
  static fase7 + #993, #3967
  static fase7 + #994, #3967
  static fase7 + #995, #0
  static fase7 + #996, #3967
  static fase7 + #997, #3967
  static fase7 + #998, #3967
  static fase7 + #999, #0

  ;Linha 25
  static fase7 + #1000, #0
  static fase7 + #1001, #3967
  static fase7 + #1002, #3967
  static fase7 + #1003, #3967
  static fase7 + #1004, #0
  static fase7 + #1005, #3967
  static fase7 + #1006, #3967
  static fase7 + #1007, #3967
  static fase7 + #1008, #3967
  static fase7 + #1009, #3967
  static fase7 + #1010, #3967
  static fase7 + #1011, #3967
  static fase7 + #1012, #3967
  static fase7 + #1013, #3967
  static fase7 + #1014, #3
  static fase7 + #1015, #3967
  static fase7 + #1016, #3967
  static fase7 + #1017, #3967
  static fase7 + #1018, #3967
  static fase7 + #1019, #3967
  static fase7 + #1020, #3967
  static fase7 + #1021, #0
  static fase7 + #1022, #3967
  static fase7 + #1023, #3967
  static fase7 + #1024, #3967
  static fase7 + #1025, #3967
  static fase7 + #1026, #3967
  static fase7 + #1027, #3967
  static fase7 + #1028, #3967
  static fase7 + #1029, #3967
  static fase7 + #1030, #3967
  static fase7 + #1031, #3967
  static fase7 + #1032, #0
  static fase7 + #1033, #3967
  static fase7 + #1034, #3967
  static fase7 + #1035, #3
  static fase7 + #1036, #3967
  static fase7 + #1037, #3967
  static fase7 + #1038, #3967
  static fase7 + #1039, #0

  ;Linha 26
  static fase7 + #1040, #0
  static fase7 + #1041, #3967
  static fase7 + #1042, #3967
  static fase7 + #1043, #3967
  static fase7 + #1044, #0
  static fase7 + #1045, #3967
  static fase7 + #1046, #3967
  static fase7 + #1047, #3967
  static fase7 + #1048, #0
  static fase7 + #1049, #0
  static fase7 + #1050, #0
  static fase7 + #1051, #0
  static fase7 + #1052, #0
  static fase7 + #1053, #0
  static fase7 + #1054, #0
  static fase7 + #1055, #0
  static fase7 + #1056, #0
  static fase7 + #1057, #3967
  static fase7 + #1058, #3967
  static fase7 + #1059, #3967
  static fase7 + #1060, #3967
  static fase7 + #1061, #0
  static fase7 + #1062, #3967
  static fase7 + #1063, #3967
  static fase7 + #1064, #3967
  static fase7 + #1065, #3967
  static fase7 + #1066, #0
  static fase7 + #1067, #0
  static fase7 + #1068, #0
  static fase7 + #1069, #0
  static fase7 + #1070, #3967
  static fase7 + #1071, #3967
  static fase7 + #1072, #0
  static fase7 + #1073, #3967
  static fase7 + #1074, #3967
  static fase7 + #1075, #0
  static fase7 + #1076, #0
  static fase7 + #1077, #0
  static fase7 + #1078, #0
  static fase7 + #1079, #0

  ;Linha 27
  static fase7 + #1080, #0
  static fase7 + #1081, #3967
  static fase7 + #1082, #3967
  static fase7 + #1083, #3967
  static fase7 + #1084, #3967
  static fase7 + #1085, #3967
  static fase7 + #1086, #3967
  static fase7 + #1087, #3967
  static fase7 + #1088, #3967
  static fase7 + #1089, #3967
  static fase7 + #1090, #3967
  static fase7 + #1091, #3967
  static fase7 + #1092, #3967
  static fase7 + #1093, #3967
  static fase7 + #1094, #3967
  static fase7 + #1095, #3967
  static fase7 + #1096, #0
  static fase7 + #1097, #3967
  static fase7 + #1098, #3967
  static fase7 + #1099, #3967
  static fase7 + #1100, #3967
  static fase7 + #1101, #3
  static fase7 + #1102, #3967
  static fase7 + #1103, #3967
  static fase7 + #1104, #3967
  static fase7 + #1105, #3967
  static fase7 + #1106, #0
  static fase7 + #1107, #3967
  static fase7 + #1108, #3967
  static fase7 + #1109, #3967
  static fase7 + #1110, #3967
  static fase7 + #1111, #3967
  static fase7 + #1112, #0
  static fase7 + #1113, #3967
  static fase7 + #1114, #3967
  static fase7 + #1115, #3967
  static fase7 + #1116, #3967
  static fase7 + #1117, #3967
  static fase7 + #1118, #3967
  static fase7 + #1119, #0

  ;Linha 28
  static fase7 + #1120, #0
  static fase7 + #1121, #3967
  static fase7 + #1122, #3967
  static fase7 + #1123, #3967
  static fase7 + #1124, #3967
  static fase7 + #1125, #3967
  static fase7 + #1126, #3967
  static fase7 + #1127, #3967
  static fase7 + #1128, #3967
  static fase7 + #1129, #3967
  static fase7 + #1130, #3967
  static fase7 + #1131, #3967
  static fase7 + #1132, #3967
  static fase7 + #1133, #3967
  static fase7 + #1134, #3967
  static fase7 + #1135, #3967
  static fase7 + #1136, #0
  static fase7 + #1137, #3967
  static fase7 + #1138, #3967
  static fase7 + #1139, #3967
  static fase7 + #1140, #3967
  static fase7 + #1141, #3967
  static fase7 + #1142, #3967
  static fase7 + #1143, #3967
  static fase7 + #1144, #3967
  static fase7 + #1145, #3967
  static fase7 + #1146, #0
  static fase7 + #1147, #3967
  static fase7 + #1148, #3967
  static fase7 + #1149, #3967
  static fase7 + #1150, #3967
  static fase7 + #1151, #3967
  static fase7 + #1152, #0
  static fase7 + #1153, #3967
  static fase7 + #1154, #3967
  static fase7 + #1155, #3
  static fase7 + #1156, #3840
  static fase7 + #1157, #3840
  static fase7 + #1158, #3840
  static fase7 + #1159, #0

  ;Linha 29
  static fase7 + #1160, #0
  static fase7 + #1161, #0
  static fase7 + #1162, #0
  static fase7 + #1163, #0
  static fase7 + #1164, #0
  static fase7 + #1165, #0
  static fase7 + #1166, #0
  static fase7 + #1167, #0
  static fase7 + #1168, #0
  static fase7 + #1169, #0
  static fase7 + #1170, #0
  static fase7 + #1171, #0
  static fase7 + #1172, #0
  static fase7 + #1173, #0
  static fase7 + #1174, #0
  static fase7 + #1175, #0
  static fase7 + #1176, #0
  static fase7 + #1177, #0
  static fase7 + #1178, #0
  static fase7 + #1179, #0
  static fase7 + #1180, #0
  static fase7 + #1181, #0
  static fase7 + #1182, #0
  static fase7 + #1183, #0
  static fase7 + #1184, #0
  static fase7 + #1185, #0
  static fase7 + #1186, #0
  static fase7 + #1187, #0
  static fase7 + #1188, #0
  static fase7 + #1189, #0
  static fase7 + #1190, #0
  static fase7 + #1191, #0
  static fase7 + #1192, #0
  static fase7 + #1193, #0
  static fase7 + #1194, #0
  static fase7 + #1195, #0
  static fase7 + #1196, #0
  static fase7 + #1197, #0
  static fase7 + #1198, #0
  static fase7 + #1199, #0

