local composer = require( "composer" )
 
local scene = composer.newScene()


local function gotoGame()
    composer.gotoScene( "game" )
end


local function gotoSobre()
    composer.gotoScene( "highscores" )
end

function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
    local background = display.newImageRect( sceneGroup, "mainscreen.png", 800, 1400 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY


    local playButton = display.newImageRect( sceneGroup, "botaoPlay.png")
    playButton.x = display.contentCenterX
    playButton.y = display.contentCenterY

    local aboutButton = display.newText( sceneGroup, "botaoSobre")
    aboutButton.x= display.contentCenterX
	aboutButton.y = display.contentCenterY    


	playButton:addEventListener( "tap", gotoGame )
    aboutButton:addEventListener( "tap", gotoSobre )
end

