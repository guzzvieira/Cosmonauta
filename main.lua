--local composer = require("composer")
--local scene = composer.newScene( )



local physics = require( "physics" )
physics.start()
	physics.setGravity( 0, 0.1 )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

 
-- Seed the random number generator
math.randomseed( os.time() )


_W = display.contentWidth
_H = display.contentHeight
_W2 = display.contentCenterX
_H2 = display.contentCenterY


-- Initialize variables
local lives = 3
local score = 0
local died = false

local scroll=7
local bgScroll = {}

	
local asteroidsTable = {}
 
local gameLoopTimer
local livesText
local scoreText


---elementos da Tela em grupos
local backGroup = display.newGroup()  -- Elementos de fundo
local mainGroup = display.newGroup()  -- Asteróides
local uiGroup = display.newGroup()    -- Objetos de UI como pontuacao, etc...








-- ---------CENARIO

-- local bg1 = display.newImageRect("image/fundopreto.jpg", 320, 480)
-- bg1.x = _H*0.5
-- bg1.y = _W/2
 
-- local bg2 = display.newImageRect("image/fundopreto.jpg", 320, 480)
-- bg2.x = _H*0.5
-- bg2.y = bg1.y+480 

-- local bg3 = display.newImageRect("image/fundopreto.jpg", 320, 480)
-- bg3.x = _H*0.5
-- bg3.y = bg2.y+480 

-- local function move (event)
-- 	bg1.y=bg1.y+scrollSpeed
-- 	bg2.y=bg2.y+scrollSpeed
-- 	bg3.y=bg3.y+scrollSpeed
-- end


--  Runtime:addEventListener("enterFrame", move)


local bg = display.newImageRect(backGroup,"image/fundopreto.jpg", _W, _H)
  bg.x = _W2
  bg.y = _H2

local bg1 = display.newImageRect(backGroup,"image/fundopreto.jpg", _W, _H)
  bg1.x = _W2
  bg1.y = _H2

  bg2 = display.newImageRect(backGroup,"image/fundopreto.jpg", _W, _H)
  bg2.x = bg1.x + _W
  bg2.y = _H2

  bg3 = display.newImageRect(backGroup, "image/fundopreto.jpg", _W, _H)
  bg3.x = bg2.x + _W
  bg3.y = _H2


function bgScroll (event)
	bg1.x = bg1.x - scroll
	bg2.x = bg2.x - scroll
	bg3.x = bg3.x - scroll

  -- Movendo as imagens para o fim da tela
if (bg1.x + bg1.contentWidth) < 0 then
bg1:translate( _W * 3, 0 )
  end
if (bg2.x + bg2.contentWidth) < 0 then
bg2:translate( _W * 3, 0 )
  end
if (bg3.x + bg3.contentWidth) < 0 then
bg3:translate( _W * 3, 0 )
  end
end


----- Display lives and score
livesText = display.newText( uiGroup, "Vidas: " .. lives, 30, 20, native.systemFont, 10 )
scoreText = display.newText( uiGroup, "Pontos: " .. score, 90, 20, native.systemFont, 10 )


local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end





--------------ASTRONAUTA 

local astronauta = display.newImageRect(mainGroup,"image/astronauta.png", 50, 50 )
astronauta.x = 30
astronauta.y = display.contentHeight - 100 --para não sair da tela
astronauta.myName = "astronauta"

physics.addBody(astronauta, "dynamic", {radius=30,isSensor=true, friction='1', bounce=0.8} )


local function pulaAstronauta()
    astronauta:applyForce( 0.1, -0.35, astronauta.x, astronauta.y )
    astronauta:applyTorque(0.1)
end


astronauta:addEventListener( "tap", pulaAstronauta )


---------------METEORO
	
local function createAsteroid()

	local newAsteroid = display.newImageRect( mainGroup, "image/meteoro.png", 30, 30 )
	table.insert( asteroidsTable, newAsteroid )
	physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )
	newAsteroid.myName = "asteroid"

	local whereFrom = math.random( 3 )

	if ( whereFrom == 1 ) then
		-- From the left
		newAsteroid.x = -60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	elseif ( whereFrom == 2 ) then
		-- From the top
		newAsteroid.x = math.random( display.contentWidth )
		newAsteroid.y = -60
		newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		newAsteroid.x = display.contentWidth + 60
		newAsteroid.y = math.random( 500 )
		newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end

	newAsteroid:applyTorque( math.random( -6,6 ) )
end


local function gameLoop()

	bgScroll() 
		-- Create new asteroid
	createAsteroid()

	-- Remove asteroids which have drifted off screen
	for i = #asteroidsTable, 1, -1 do
		local thisAsteroid = asteroidsTable[i]

		if ( thisAsteroid.x < -100 or
			 thisAsteroid.x > display.contentWidth + 100 or
			 thisAsteroid.y < -100 or
			 thisAsteroid.y > display.contentHeight + 100 )
		then
			display.remove( thisAsteroid )
			table.remove( asteroidsTable, i )
		end
	end
end

gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )


local function restoreAstronauta()

	astronauta.isBodyActive = false
	astronauta.x = display.contentCenterX
	astronauta.y = display.contentHeight - 100

	-- Fade in the ship
	transition.to( astronauta, { alpha=1, time=4000,
		onComplete = function()
			astronauta.isBodyActive = true
			died = false
		end
	} )
end



local function onCollision( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
			 ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
		then
			-- Remove both the laser and asteroid
			display.remove( obj1 )
			display.remove( obj2 )

			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end

			-- Increase score
			score = score + 100
			scoreText.text = "Score: " .. score

		elseif ( ( obj1.myName == "astronauta" and obj2.myName == "asteroid" ) or
				 ( obj1.myName == "asteroid" and obj2.myName == "astronauta" ) )
		then
			if ( died == false ) then
				died = true

				-- Update lives
				lives = lives - 1
				livesText.text = "Vidas: " .. lives

				if ( lives == 0 ) then
					display.remove( astronauta)
				else
					astronauta.alpha = 0
					timer.performWithDelay( 1000, restoreAstronauta )
				end
			end
		end
	end
end

Runtime:addEventListener( "collision", onCollision )



