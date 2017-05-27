
local composer = require("composer")
local scene = composer.newScene( )
local creditsBG
local menuBtn


function scene:create( event )
	local sceneGroup = self.view	

	local somBG = audio.loadStream( "sound/DST-EndingCredits.mp3" )
  	audio.play(somBG, {loops = -1, channel = 1})  

	creditsBG = display.newImageRect( "image/creditsBG1.png", _W, _H )
	creditsBG.x = _W2
	creditsBG.y = _H2
	sceneGroup:insert(creditsBG)

	menuBtn = display.newImage( "image/returnBtn.png")
	menuBtn.x = _W2 + 205
	menuBtn.y = _H2 + 142
	sceneGroup:insert(menuBtn)


end
	
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	local previousScene = composer.getSceneName( "previous" )
    composer.removeScene( previousScene )
    composer.removeScene( "menu")


	if (phase == "did") then
		menuBtn:addEventListener( "tap", menuGame )
	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		menuBtn:removeEventListener( "tap", menuGame )
	end
end



local options = {
	
	effect = "fade", time = 250
}


local options1 = {
	
	effect = "fromRight", time = 500
}

function menuGame( )
	audio.stop( 1 )		
	composer.gotoScene( "menu", options )
	
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene

