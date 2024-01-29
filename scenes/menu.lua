local composer = require( "composer" )
local widget = require( "widget" )
local lfs = require( "lfs" )
local fileManager = require( "plugin.cnkFileManager" )

local scene = composer.newScene()

local bookDir = system.pathForFile( nil, system.CachesDirectory )

local gScrollViewBooks = nil


local function createBookDir()
    if ( lfs.chdir( bookDir ) ) then
        lfs.mkdir( resources.dirBooks )
        bookDir = bookDir .. "/" .. resources.dirBooks
    end
end


local function handleBtnBookRelease( event )
    if ( "ended" == event.phase ) then

        composer.setVariable( "bookName", event.target.id )
        composer.setVariable( "bookDir", bookDir )
        composer.removeScene( "scenes.menu" )
        composer.gotoScene( "scenes.book" )
    end
end


local function getAppVersion()

    return system.getInfo( "appVersionString" )
end


local function updateBookList( scrollView, path )

    local files = {}

    for file in lfs.dir( path ) do
        if ( file ~= "." and file ~= ".." ) then
            local filePath = path .. "/" .. file
            local attr = lfs.attributes( filePath )
            if ( attr.mode ~= "directory" ) then
                local extension = string.match( file, "^.+(%..+)$" )
                if ( extension == ".epub" ) then
                    table.insert( files, file )
                    print( "[+] Found book: " .. file )
                end
            end
        end
    end


    for i, file in ipairs( files ) do

        local file_short = file
        if ( string.len( file ) > 20 ) then
            file_short = string.sub( file, 1, 20 ) .. "..."
        end

        local btn = widget.newButton({
            id = file,
            label = file_short,
            labelColor = {
                default = resources.colors_transparent.white_1,
                over = resources.colors_transparent.white_2
            },
            shape = "roundedRect",
            width = scrollView.btnWidth,
            height = scrollView.btnHeight,
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
            onRelease = handleBtnBookRelease
        })

        btn.x = display.contentCenterX
        btn.y = scrollView.btnHeight * i + 32 * i

        scrollView:insert( btn )
    end
    
end


local function handleBtnAddRelease( event )

    if ( "ended" == event.phase ) then

        -- Look for a *.epub
        local path = bookDir
        local fileName = nil
        local headerText = nil
        local mimeType = "application/epub+zip"
        local onlyOpenable = true
        local onlyDocuments = nil
        local dumyMode = false
        fileManager.pickFile(
            path,
            function( event )
                if ( event.isError ) then
                    print( "Error picking file" )
                elseif ( event.done ) then
                    if ( event.done == "ok" ) then
                        updateBookList( gScrollViewBooks, bookDir )
                    end
                end
            end,
            fileName,
            headerText,
            mimeType,
            onlyOpenable,
            onlyDocuments,
            dumyMode
        )
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

    local textVersion = display.newText({
        text = "v" .. getAppVersion(),
        x = display.contentWidth - 256,
        y = 48,
        font = resources.fonts["default"],
        fontSize = 64,
        align = "right"
    })

    sceneGroup:insert( textVersion )

    local btnAdd = widget.newButton({
        id = "btnAdd",
        label = "Add book",
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
        onRelease = handleBtnAddRelease
    })

    btnAdd.x = display.contentCenterX
    btnAdd.y = display.contentHeight - btnAdd.height / 2 - 32

    sceneGroup:insert( btnAdd )

    -- Scroll view
    local scrollView = widget.newScrollView({
        id = "scrollView",
        top = resources.offsetTop,
        left = 0,
        width = display.contentWidth,
        height = display.contentHeight - btnAdd.height - 64 - resources.offsetTop,
        scrollWidth = display.contentWidth,
        scrollHeight = 1000,
        horizontalScrollDisabled = true,
        verticalScrollDisabled = false,
        hideBackground = true,
    })

    scrollView.btnHeight = display.contentHeight / 10 / 1.6
    scrollView.btnWidth = display.contentWidth - 64
    gScrollViewBooks = scrollView

    btnAdd.scrollView = scrollView

    -- Create book directory
    createBookDir()

    updateBookList( scrollView, bookDir )

    -- Insert scroll view into scene group
    sceneGroup:insert( scrollView )
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