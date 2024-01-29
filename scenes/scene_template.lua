local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()


function scene:create( event )

    local sceneGroup = self.view
end


function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

end


function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

end


function scene:destroy( event )

    local sceneGroup = self.view

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene