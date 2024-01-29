local composer = require( "composer" )
local widget = require( "widget" )
local epub = require( "modules.epub" )
local epubviewer = require( "modules.epubviewer" )

local scene = composer.newScene()

local bookName = composer.getVariable( "bookName" )
local bookDir = composer.getVariable( "bookDir" )
book = epub.openBook( resources.dirBooks .. "/" .. bookName )


function scene:create( event )

    local sceneGroup = self.view

    local background = display.newImageRect(
        sceneGroup,
        "assets/background/back_dark.png",
        display.contentWidth,
        display.contentHeight
    )

    background.x = display.contentCenterX
    background.y = display.contentCenterY

    sceneGroup:insert( background )

    local btnHeight = display.contentHeight / 10 / 1.2

    local epubContent = epubviewer.newEpubContent(
        resources.offsetTop,
        0,
        display.contentWidth,
        display.contentHeight - btnHeight - 32 - 16 - resources.offsetTop,
        book
    )
    epubContent:changeHtml( book:getPagePath( book:getCurrentPage() ) )
    
    sceneGroup:insert( epubContent )

    local btnNext = widget.newButton({
        id = "btnNext",
        label = ">",
        labelColor = {
            default = resources.colors_transparent.white_1,
            over = resources.colors_transparent.white_2
        },
        shape = "roundedRect",
        width = display.contentWidth / 2,
        height = btnHeight,
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
        onRelease = function( event )
            book:getNextPage()
            epubContent:changeHtml( book:getPagePath( book:getCurrentPage() ) )
        end
    })

    btnNext.x = display.contentCenterX + display.contentWidth / 4
    btnNext.y = display.contentHeight - btnHeight / 2 - 16

    sceneGroup:insert( btnNext )

    local btnPrev = widget.newButton({
        id = "btnPrev",
        label = "<",
        labelColor = {
            default = resources.colors_transparent.white_1,
            over = resources.colors_transparent.white_2
        },
        shape = "roundedRect",
        width = display.contentWidth / 2,
        height = btnHeight,
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
        onRelease = function( event )
            book:getPrevPage()
            epubContent:changeHtml( book:getPagePath( book:getCurrentPage() ) )
        end
    })

    btnPrev.x = display.contentCenterX - display.contentWidth / 4
    btnPrev.y = display.contentHeight - btnHeight / 2 - 16

    sceneGroup:insert( btnPrev )
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