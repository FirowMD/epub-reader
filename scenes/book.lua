local composer = require( "composer" )
local widget = require( "widget" )
local epub = require( "modules.epub" )

local scene = composer.newScene()

local bookName = composer.getVariable( "bookName" )
local bookDir = composer.getVariable( "bookDir" )

local function handleBtnBackRelease( event )

    if ( "ended" == event.phase ) then
        composer.removeScene( "scenes.book" )
        composer.gotoScene( "scenes.menu" )
    end
end


local function handleBtnStartReadingRelease( event )

    if ( "ended" == event.phase ) then
        composer.removeScene( "scenes.book" )
        composer.gotoScene( "scenes.reading" )
    end
end


function scene:create( event )

    local sceneGroup = self.view

    local background = display.newImageRect(
        sceneGroup,
        "assets/background/back_menu.png",
        display.contentWidth,
        display.contentHeight
    )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    sceneGroup:insert( background )

    local scrollViewBookName = widget.newScrollView({
        id = "scrollViewBookName",
        top = resources.offsetTop,
        left = 0,
        width = display.contentWidth,
        height = 256,
        scrollWidth = display.contentWidth,
        scrollHeight = 1000,
        horizontalScrollDisabled = true,
        verticalScrollDisabled = false,
        hideBackground = false,
        backgroundColor = resources.colors_transparent_1.black,
    })

    local textBookName = display.newText({
        text = bookName,
        x = display.contentCenterX,
        y = scrollViewBookName.height / 2,
        width = display.contentWidth - 64,
        height = 0,
        font = resources.fonts["default"],
        fontSize = 64,
        align = "center",
    })

    scrollViewBookName:insert( textBookName )

    sceneGroup:insert( scrollViewBookName )

    local btnStartReading = widget.newButton({
        id = "btnStartReading",
        label = "Start reading",
        labelColor = {
            default = resources.colors_transparent.white_1,
            over = resources.colors_transparent.white_2
        },
        shape = "roundedRect",
        width = display.contentWidth - 64,
        height = display.contentHeight / 10 / 1.2,
        cornerRadius = 2,
        strokeColor = {
            default = resources.colors_transparent.white,
            over = resources.colors_transparent.white_2
        },
        fillColor = {
            default = resources.colors_transparent.black_1,
            over = resources.colors_transparent.black_2
        },
        strokeWidth = 4,
        font = resources.fonts["default"],
        fontSize = 64,
        onRelease = handleBtnStartReadingRelease
    })

    btnStartReading.x = display.contentCenterX
    btnStartReading.y = scrollViewBookName.y + scrollViewBookName.height / 2 +
        btnStartReading.height / 2 + 32

    sceneGroup:insert( btnStartReading )

    local btnBack = widget.newButton({
        id = "btnBack",
        label = "Back",
        labelColor = {
            default = resources.colors_transparent.white_1,
            over = resources.colors_transparent.white_2
        },
        shape = "roundedRect",
        width = display.contentWidth - 64,
        height = display.contentHeight / 10 / 1.5,
        cornerRadius = 2,
        strokeColor = {
            default = resources.colors_transparent.white,
            over = resources.colors_transparent.white_2
        },
        fillColor = {
            default = resources.colors_transparent.black_1,
            over = resources.colors_transparent.black_2
        },
        strokeWidth = 4,
        font = resources.fonts["default"],
        fontSize = 64,
        onRelease = handleBtnBackRelease
    })

    btnBack.x = display.contentCenterX
    btnBack.y = display.contentHeight - btnBack.height / 2 - 32

    sceneGroup:insert( btnBack )
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