;Codigo para gerar numeros aleatorios

jmp main

welcome: string "Bem vindo a maze crawler, aperte qualquer tecla para comecar"
congrats: string "parabens, voce venceu!#aperte qualquer tecla para recomecar" ; o indicador de fim de linha eh '#' nesse caso
passosStr: string "passos dados:"
seed : var #1
rngA: var #1
mapa : var #400
mapaTamanho: var #1
mapaGerado : var #1
vizinhos: var #4
saidaMapa: var #1
static seed+#0,#3
static rngA+#0,#33
static mapaTamanho+#0,#400
position: var #1
gg: var #1
step: var #1

main:
	call limpaMapa
	call createMap
	call printMap
	;call victory
	call titleScreen
	main_loop:
		;configura inicio do jogo
		loadn r7, #0
		store gg, r7
		store position,r7
		store step, r7
		loadn r0,#passosStr
		loadn r1,#1000
		loadn r2,#'\0'
		loadn r3,#0
		loadn r4,#0
		main_loop_passos:
			add r7,r0,r3
			loadi r7,r7
			cmp r7,r2
			jeq main_loop_saiPassos
			add r4,r1,r3
			outchar r7,r4
			inc r3
			jmp main_loop_passos

		add r1,r1,r3
		loadn r0,#0
		outchar r0,r1

		main_loop_saiPassos:
		;gera o mapa
		call clearScreen
		call limpaMapa
		call createMap

		push r0
		push r1
		load r0, position
		loadn r1, #3		;coraqui
		call printCoord
		pop r1
		pop r0

		call extloop
		call victory
		loadn r0,#1
		cmp r0,r7
		jeq main_loop
	halt

;void clearScreen()
clearScreen:
	push r0
	push r1
	push r2
	loadn r0,#' '
	loadn r1,#0
	loadn r2,#1200
	clearScreen_loop:
		outchar r0,r1
		inc r1
		cmp r1,r2
		jle clearScreen_loop
	pop r2
	pop r1
	pop r0
	rts

;void title_screen()
titleScreen:
	push r0
	push r1
	push r2
	push r3
	loadn r0,#welcome
	loadn r1,#10
	loadn r3,#','
	titleScreen_printLoop1:
		loadi r2,r0
		cmp r2,r3
		jeq titleScreen_saiLoop1
		outchar r2,r1
		inc r1
		inc r0
		jmp titleScreen_printLoop1
	titleScreen_saiLoop1:
	inc r0
	inc r0
	loadn r1,#43
	loadn r3,#'\0'
	titleScreen_printLoop2:
		loadi r2,r0
		cmp r2,r3
		jeq titleScreen_saiLoop2
		outchar r2,r1
		inc r1
		inc r0
		jmp titleScreen_printLoop2
	titleScreen_saiLoop2:
	loadn r0,#0
	loadn r1,#0
	titleScreen_waitLoop:
		inc r0
		inchar r2
		cmp r1,r2
		jne titleScreen_saiWaitLoop
		jmp titleScreen_waitLoop
	titleScreen_saiWaitLoop:
	loadn r1,#65535
	and r0,r0,r1
	store seed,r0
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;void printMap()
printMap:
	push r0
	push r1
	push r2
	loadn r0,#0
	loadn r1,#0
	load r2,mapaTamanho
	printMap_loop:
		call printCoord
		inc r0
		cmp r0,r2
		jle printMap_loop
	pop r2
	pop r1
	pop r0
	rts

;coid victory()
victory:
	push r0
	push r1
	push r2
	push r3
	loadn r0,#congrats
	loadn r1,#10
	loadn r3,#'#'
	victory_printLoop1:
		loadi r2,r0
		cmp r2,r3
		jeq victory_saiLoop1
		outchar r2,r1
		inc r1
		inc r0
		jmp victory_printLoop1
	victory_saiLoop1:
	inc r0
	loadn r1,#43
	loadn r3,#'\0'
	victory_printLoop2:
		loadi r2,r0
		cmp r2,r3
		jeq victory_saiLoop2
		outchar r2,r1
		inc r1
		inc r0
		jmp victory_printLoop2
	victory_saiLoop2:
	load r0,step
	loadn r1,#1013
	call debug
	loadn r3,#'s'
	loadn r0,#'n'
	loadn r1,#0
	victory_waitLoop:
		inchar r2
		cmp r3,r2
		jeq victory_exitYes
		cmp r3,r0
		jeq victory_exitNo
		jmp victory_waitLoop
	victory_exitYes:
		loadn r7,#1
		jmp victory_exit
	victory_exitNo:
		loadn r7,#0
	victory_exit:
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;void create_map()
createMap:
	push r0
	push r1
	loadn r0,#0
	store mapaGerado,r0
	;r0=rng()%400
	call rng
	;		loadn r7,#0
	mov r0,r7
	load r7,mapaTamanho
	mod r0,r0,r7
	call DFS
	;define a saida
	call rng
	loadn r0,#20
	mod r0,r7,r0
	loadn r7,#20
	mul r0,r0,r7
	loadn r7,#19
	add r0,r0,r7
	store saidaMapa, r0
	;carrega direcao de saida
	loadn r1,#4
	call adicionaDirecao
	pop r1
	pop r0
	rts



;void DFS(int pos); recursiva
DFS:
	push r1
	loadn r1,#0
	call contaVizinhos
	cmp r7,r1
	jne DFS_corpo
		pop r1
		rts
	DFS_corpo:
	;escolheDirecao
	push r0
	mov r0,r7
	call rng
	mod r7,r7,r0
	loadn r1,#vizinhos
	add r7,r1,r7
	loadi r7,r7
	mov r1,r7
	pop r0
	;r0 tem a coordenada atual, r1 tem a direcao
	call adicionaDirecao
	call mudaR0
	call inverteDirecao
	call adicionaDirecao
	call DFS
	call mudaR0
	call inverteDirecao
	call DFS
	pop r1
	rts

;void printCoord(int coord,int cor)
printCoord:
	push r2
	push r3
	call convGlobal
	mov r3, r7
	loadn r2, #mapa
	add r2, r2, r0
	loadi r2, r2
	loadn r7,#256
	mul r7,r7,r1
	add r2,r2,r7
	outchar r2, r3
	pop r3
	pop r2
	rts

;void limpaMapa (), printa zero no mapa todo	
limpaMapa:
	push r0
	push r1
	push r2
	push r3
	loadn r0,#mapa
	loadn r7,#0
	loadn r2,#0
	load r3,mapaTamanho
	limpaMapa_loop:
		add r1,r0,r7
		storei r1,r2
		inc r7
		cmp r7,r3
		jle limpaMapa_loop
	pop r3
	pop r2
	pop r1
	pop r0
	rts
	
;int convGlobal (int coord)
convGlobal:
	push r0
	push r1
	;r0=(5+r0/20)*40+(10+r0%20)
	loadn r7,#20
	mod r1,r0,r7
	div r0,r0,r7
	loadn r7,#5
	add r0,r0,r7
	loadn r7,#40
	mul r0,r0,r7
	loadn r7,#10
	add r1,r1,r7
	add r7,r0,r1
	pop r1
	pop r0
	rts

;void inverteDirecao(*r1)
inverteDirecao:
	loadn r7,#4
	cmp r1,r7
	jle inverteDirecao_vertical
		loadn r7,#12
		xor r1,r1,r7
		jmp inverteDirecao_end
	inverteDirecao_vertical:
		loadn r7,#3
		xor r1,r1,r7
	inverteDirecao_end:
	rts
	
;void mudaR0(*r0,r1)
mudaR0:
	push r1
	loadn r7,#4
	cmp r1,r7
	jle mudaR0_vertical
	jeq mudaR0_direita
		dec r0
		jmp mudaR0_end
	mudaR0_direita:
		inc r0
		jmp mudaR0_end
	mudaR0_vertical:
		loadn r7,#20
		dec r1
		jz mudaR0_vertical_cima
			add r0,r0,r7
			jmp mudaR0_end
		mudaR0_vertical_cima:
			sub r0,r0,r7
	mudaR0_end:
	pop r1
	rts

;int contaVizinhos(int pos);
contaVizinhos:
	push r1
	push r2
	push r3
	push r4
	push r5
	loadn r1,#mapa
	loadn r2,#vizinhos
	loadn r3,#0
	loadn r5,#0
	;contaVizinhos_cima
	loadn r7,#20
	;calcula se a direcao "cima" eh uma direcao possivel
	cmp r0,r7
	jle contaVizinhos_baixo
	;calcula se a posicao nessa direcao nao foi descoberta ainda
	loadn r4,#20 ;r4=-20
	add r7,r1,r0 ;carrega a cordenada atual
	sub r7,r7,r4 ;mexe na direcao cima
	loadi r7,r7
	cmp r7,r5 ;compara r7 com 0
	jne contaVizinhos_baixo
		;se nao foi, adiciona direcao como possivel
		loadn r4,#1
		add r7,r2,r3
		storei r7,r4
		inc r3
	contaVizinhos_baixo:
	loadn r4,#20
	;se a direcao "baixo" nao for possivel, pula
	loadn r7,#379
	cmp r0,r7
	jgr contaVizinhos_esquerda
	;se a posicao ja foi descoberta, nao soma
	add r7,r1,r0
	add r7,r7,r4
	loadi r7,r7
	cmp r7,r5
	jne contaVizinhos_esquerda
		loadn r4,#2
		add r7,r2,r3
		storei r7,r4
		inc r3
	contaVizinhos_esquerda:
	loadn r7,#20
	mod r7,r0,r7
	jz contaVizinhos_direita
	add r7,r1,r0
	dec r7
	loadi r7,r7
	cmp r7,r5
	jne contaVizinhos_direita
		loadn r4,#8
		add r7,r2,r3
		storei r7,r4
		inc r3
	contaVizinhos_direita:
	loadn r7,#20
	loadn r4,#19
	mod r7,r0,r7
	cmp r4,r7
	jeq contaVizinhos_fim
	add r7,r1,r0
	inc r7
	loadi r7,r7
	cmp r7,r5
	jne contaVizinhos_fim
		loadn r4,#4
		add r7,r2,r3
		storei r7,r4
		inc r3
	contaVizinhos_fim:
	mov r7,r3
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	rts


;void adicionaDirecao(int coord,int dir)
adicionaDirecao:
	push r2
	push r3
	loadn r2,#mapa
	add r2,r2,r0
	loadi r3,r2
	add r3,r3,r1
	storei r2,r3
	pop r3
	pop r2
	rts

;int rng()
rng:
	push r0
	push r1
	load r0,seed
	load r1,rngA
	mul r7,r0,r1
	inc r7
	jno rng_no ;se nao deu overflow na multiplicacao, pula as proximas linhas
		loadn r1,#65535
		and r7,r7,r1
	rng_no:
	store seed,r7
	pop r1
	pop r0
	rts

;void debug(int n, int pos)
debug:
	push r0
	push r1
	push r2 ;numero maxim
	push r3
	push r4
	push r5
	push r6
	loadn r2,#1
	loadn r3,#10
	loadn r5,#1
	loadn r6,#'0'
	cmp r0,r2
	jle debug_print_last
	debug_loop:
		mul r2,r2,r3
		cmp r0,r2
		jeg debug_loop
	debug_print_loop:
		mod r4,r0,r2
		div r2,r2,r3
		cmp r2,r5
		jeq debug_print_last
		div r4,r4,r2
		add r4,r4,r6
		outchar r4,r1
		inc r1
		jmp debug_print_loop
	debug_print_last:
		mod r4,r0,r3
		add r4,r4,r6
		outchar r4,r1
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2 
	pop r1
	pop r0
	rts

up:
	load r7, position
	loadn r6, #20
	sub r7, r7, r6
	store position, r7
	loadn r7,#1
	rts
	
down:
	load r7, position
	loadn r6, #20
	add r7, r7, r6
	store position, r7
	loadn r7,#1
	rts
	
left:
	load r7, position
	loadn r6, #1
	sub r7, r7, r6
	store position, r7
	loadn r7,#1
	rts
	
right:
	load r7, position
	loadn r6, #1
	add r7, r7, r6
	store position, r7
	loadn r7,#1
	rts
	
;check_valid move	
moveLeft:
	loadn r5, #20
	load r4, position
	mod r7, r4, r5
	loadn r6, #0
	cmp r6, r7
	jeq moveLeft_exit
		loadn r5, #mapa
		add r5, r5, r4
		loadi r7, r5
		loadn r6, #8
		and r7, r7, r6
		loadn r7,#0
		cnz left
	moveLeft_exit:
	rts

moveRight:
	loadn r5, #20
	load r4, position
	mod r7, r4, r5
	loadn r6, #19
	cmp r6, r7
	jeq moveRight_checkWin
		loadn r5, #mapa
		add r5, r5, r4
		loadi r7, r5
		loadn r6, #4
		and r7, r7, r6
		loadn r7,#0
		cnz right
		jmp moveRight_exit
	moveRight_checkWin:
		load r7, saidaMapa
		cmp r4, r7
		jeq youWin
	moveRight_exit:
	rts
	
youWin:
	;print the winning screen
	loadn r7, #1
	store gg, r7
	rts
	
moveUp:
	loadn r6, #20
	load r7, position
	cmp r7, r6
	jle moveUp_exit
		loadn r5, #mapa
		add r5, r5, r7
		loadi r7, r5
		loadn r6, #1
		and r7, r7, r6
		loadn r7,#0
		cnz up
	moveUp_exit:
	rts

moveDown:
	loadn r6, #380
	load r7, position
	cmp r7, r6
	jeg moveDown_exit
		loadn r5, #mapa
		add r5, r5, r7
		loadi r7, r5
		loadn r6, #2
		and r7, r7, r6
		loadn r7,#0
		cnz down
	moveDown_exit:
	rts

;void(int position)
extloop:
	push r4
	push r5
	push r6
	
				loadn r4,#'0'
				loadn r5,#0
	loadn r6,#255
	extLoop_readLoop:	
		inchar r7
		cmp r6,r7
		jeq extLoop_readLoop

	;up
	loadn r6, #'w'
	cmp r7, r6
	jne extLoop_down
	call moveUp
	;checa se se mexeu
	loadn r6,#1
	cmp r6,r7
	jeq extLoop_moveUp
	jmp extLoop_noMove


	extLoop_down:
	;down
	loadn r6, #'s'
	cmp r7, r6
	jne extLoop_left
	call moveDown
	loadn r6,#1
	cmp r6,r7
	jeq extLoop_moveDown
	jmp extLoop_noMove



	;left
	extLoop_left:
	loadn r6, #'a'
	cmp r7, r6
	jne extLoop_right
	call moveLeft
	loadn r6,#1
	cmp r6,r7
	jeq extLoop_moveLeft
	jmp extLoop_noMove



	;right
	extLoop_right:
	loadn r6, #'d'
	cmp r7, r6
	ceq moveRight
	loadn r6,#1
	cmp r6,r7
	jeq extLoop_moveRight
	jmp extLoop_noMove
	
	extLoop_moveUp:
		push r0
		push r1
		load r7,position
		loadn r6,#20
		add r7,r7,r6
		mov r0,r7
		loadn r1, #0
		call printCoord
		pop r1
		pop r0
		jmp extLoop_newCoord

	extLoop_moveDown:
		push r0
		push r1
		load r7,position
		loadn r6,#20
		sub r7,r7,r6
		mov r0,r7
		loadn r1, #0
		call printCoord
		pop r1
		pop r0
		jmp extLoop_newCoord

	extLoop_moveLeft:
		push r0
		push r1
		load r7,position
		inc r7
		mov r0,r7
		loadn r1, #0
		call printCoord
		pop r1
		pop r0
		jmp extLoop_newCoord

	extLoop_moveRight:
		push r0
		push r1
		load r7,position
		dec r7
		mov r0,r7
		loadn r1, #0
		call printCoord
		pop r1
		pop r0
		jmp extLoop_newCoord

	extLoop_newCoord:
		push r0
		push r1
		load r0, position
		loadn r1, #3;;;;;;coraqui
		call printCoord
		pop r1
		pop r0

		load r7,step
		inc r7
		store step,r7
	
		loadn r7, #1
		load r6, gg
		cmp r7, r6
		jeq endGame
		call delay
	extLoop_noMove:
		pop r6
		pop r5
		pop r4
		jmp extloop

	endGame:
		pop r6
		pop r5
		pop r4
		rts


delay:
	push r0
	push r1
	loadn r1,#255
	delay_loop:
		inchar r0
		cmp r0,r1
		jne delay_loop
	pop r1
	pop r0
	rts
