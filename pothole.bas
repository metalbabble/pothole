 set kernel_options player1colors pfcolors background no_blank_lines
 include div_mul.asm
 
 rem *********************************************************
 rem * POT HOLE by Brian Shea - http://www.metalbabble.com/  *
 rem *********************************************************

 const scorefade=1

 rem *********************
 rem Variable aliases
 rem *********************

 dim p1_x = b
 dim p1_y = c
 dim safeTemp = d
 dim safeTemp2 = e

 dim potHoleX = f
 dim potHoleY = g 

 dim anim = h
 dim npcMode = i

 dim rand16 = j

 dim extraSpeed = k
 dim extraSpeedCounter = l

 dim life = m

newGame
 player0:
 %00000000
end
 player1:
 %00000000
end
 ballx = 250 : bally= 250

 rem *********************
 rem INTRO
 rem *********************
 playfield:
 ................................
 ................................
 ................................
 XX...XX..XXX.X.X..XX..X...XXX..X
 X.X.X..X..X..X.X.X..X.X...X....X
 XX..X..X..X..XXX.X..X.X...XX...X
 X...X..X..X..X.X.X..X.X...X.....
 X....XX...X..X.X..XX..XXX.XXX..X
 ................................
 ................................
 ................................
end

intro
 pfcolors:
 $A0
 $A2
 $A4
 $A6
 $A8
 $AA
 $AC
 $AE
 $06
 $05
 $04
end
 drawscreen
 if joy0fire then goto gamePreInit
 safeTemp = safeTemp + 1
 goto intro

 rem *********************
 rem GAME INIT
 rem *********************
gamePreInit
  score = 0
  life = 6

gameInit
 COLUBK = 8
 COLUP0 = $EF
 COLUP1 = $EF
 scorecolor = $FC

 player1x = 5
 player1y = 47
 
 player0x = 151
 player0y = 151

 potHoleX = 151
 potHoleY = 0

 anim = 0

 npcMode = 0
 extraSpeed = 0
 extraSpeedCounter = 0

 pfclear

 pfcolors:
 $96
 $98
 $9A
 $9C
 $9E
 $0E
 $08
 $07
 $06
 $05
 $04
end

 player1color:
 $00
 $00
 $40
 $42
 $44
 $AA
 $AC
 $40
end

 player1:
 %01000100
 %11101110
 %11111111
 %11111111
 %11111110
 %11111000
 %11111000
 %11110000
end




 rem *******************************
 rem MAIN LOOP
 rem *******************************

main
 gosub selectLevel

 rem handle movement
 p1_x = 0
 if joy0left then p1_x = 255
 if joy0right then p1_x = 1
 if joy0right then gosub sndAccelerate else gosub sndStop1
 player1x = player1x + p1_x

 p1_y = 0
 if joy0up then p1_y = 255
 if joy0down then p1_y = 1
 player1y = player1y + p1_y
 if p1_y = 0 then gosub sndStop0 else gosub sndSkid

 rem lose speed if no input
 safeTemp = anim // 2
 if safeTemp = 0 && p1_x = 0 then player1x = player1x - 1

 rem increase movement of npc
 if safeTemp = 0 then player0x = player0x - 1

 rem keep in boundries
 if player1y < 42 then player1y = 42
 if player1y > 80 then player1y = 80
 if player1x > 150 then player1x = 150
 if player1x < 5 then player1x = 5

 rem moving pot hole (ball)
 safeTemp = extraSpeed + 1
 potHoleX = potHoleX - 1 - extraSpeed
 if potHoleX < safeTemp then potHoleY = rand
 if potHoleY < 48 then potHoleY = 48
 if potHoleY > 80 then potHoleY = 80
 if potHoleX < safeTemp then potHoleX = 151
 ballheight = 8 
 ballx = potHoleX
 bally = potHoleY
 
 rem MOVE player 0 (bonuses/npc sprites)
 safeTemp = extraSpeed + 1
 if player0x < safeTemp then player0y = rand
 if player0y < 42 then player0y = 42
 if player0y > 80 then player0y = 80
 if player0x < safeTemp then gosub randomizeNpc
 if player0x < safeTemp then player0x = 151 
 player0x = player0x - 1 - extraSpeed
 
 if npcMode = 0 then gosub animateSparkle else gosub animateOtherCar

 gosub setSpriteScales

 rem check collisions
 if collision(ball, player1) then goto crashed
 if collision(player0, player1) && npcMode = 0 then gosub getPoint
 if collision(player0, player1) && npcMode = 1 then gosub crashed

 rem DRAW SCREEN 
 drawscreen

 rem slowly increase the speed
 if anim > 19 then extraSpeedCounter = extraSpeedCounter + 1
 if extraSpeedCounter > 50 then extraSpeed = extraSpeed + 1
 if extraSpeedCounter > 50 then extraSpeedCounter = 0


 rem update animation counter
 anim = anim + 1
 if anim > 20 then anim = 0
 
 goto main




 rem **************************
 rem GAMEPLAY SUPPORT
 rem **************************

selectLevel
 if extraSpeed = 2 then  pfcolors:
 $86
 $88
 $8A
 $8C
 $8E
 $0E
 $08
 $07
 $06
 $05
 $04
end

 if extraSpeed = 4 then  pfcolors:
 $56
 $58
 $5A
 $5C
 $5E
 $0E
 $08
 $07
 $06
 $05
 $04
end
 return

setSpriteScales
 rem strech car and set ball size
 NUSIZ1 = $25
 CTRLPF = $31
 return

getPoint
 for safeTemp = 1 to 5
	safeTemp2 = 10 - safeTemp
	AUDV1=8:AUDC1=4:AUDF1=safeTemp2
     score = score + 1
	gosub setSpriteScales
	drawscreen
 next
 player0y=rand16
 player0x=151
 gosub sndStop1
 return

crashed
 gosub sndStop1
 gosub sndKaboom
 for safeTemp = 1 to 30
 	gosub setSpriteScales
	 player1color:
end
	COLUP1 = rand
 	drawscreen
 next
 gosub sndStop0
 gosub sndStop1
 life = life - 1
 if life = 1 then goto newGame else goto gameInit

animateOtherCar
 player0:
 %01000100
 %11111110
 %11111111
 %11111111
 %01000010
 %01000100
 %00111000
 %00000000
end
 return


randomizeNpc
 safeTemp = rand16
 if safeTemp < 120 then npcMode = 0 else npcMode = 1
 return

animateSparkle
 if anim=10 then player0:
 %00000000
 %00000000
 %00000000
 %00010000
 %10111010
 %00010000
 %00000000
 %00000000
end
 if anim=20 then player0:
 %00000000
 %00000000
 %00000000
 %00101000
 %00010000
 %00101000
 %00000000
 %00000000
end
 return




 rem ******************************
 rem SOUND EFFECTS
 rem ******************************
sndAccelerate
  AUDV1=6:AUDC1=2:AUDF1=3
  return

sndSkid
  AUDV0=5:AUDC0=3:AUDF0=2
  return

sndPoint
  AUDV1=8:AUDC1=4:AUDF1=10
  return

sndKaboom
  AUDV1=12:AUDC1=3:AUDF1=4
  return
  
sndStop0
  AUDV0=0
  return
  
sndStop1
  AUDV1=0
  return


