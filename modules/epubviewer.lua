--[[
    Library to view html pages of an epub book
]]--


local widget = require( "widget" )
local epub = require( "modules.epub" )
local htmlparser = require( "external.htmlparser" )


local epubviewer = {}


local function correctImagePath( htmlPath, imagePath )

    local path = string.match( htmlPath, "(.*)/.*" )
    path = path .. "/" .. imagePath

    return path
end


local function getFileContent( filePath )

    local file = io.open( filePath, "r" )
    local fileContent = file:read( "*a" )
    file:close()

    return fileContent
end


local function takeTextUntilTag( text )
    
    if ( string.sub( text, 1, 1 ) == "<" ) then

        return ""
    end

    local result = string.match( text, "([^<]+)" )
    if ( result ) then

        return result
    end

    return ""
end


local function removeFirstTaggedText( taggedText )

    local pattern = "<[^>]+>"
    local result = taggedText:gsub( pattern, "", 1 )
    return result
end


local function isLineBreakTag( tagName )
    
    if ( tagName == "br" or tagName == "hr" ) then

        return true
    end

    return false
end


function findSubstring( str, substring )
    local strLen = #str
    local subLen = #substring

    for i = 1, strLen - subLen + 1 do
        local match = true

        for j = 1, subLen do
            if string.sub(str, i + j - 1, i + j - 1) ~= string.sub(substring, j, j) then
                match = false
                break
            end
        end

        if match then
            return i
        end
    end

    return -1
end


function removeFirstSubstring( str, substring )

    local index = findSubstring( str, substring )
    if ( index ~= -1 ) then

        local result = string.sub( str, 1, index - 1 )
        result = result .. string.sub( str, index + #substring, #str )

        return result
    end

    return str
end



local function parseParagraph( epubContent, nodeP )

    local result = ""
    local remainText = nodeP:getcontent()
    local temp = ""

    temp = takeTextUntilTag( remainText )
    if ( temp ~= "" ) then

        result = result .. temp
    end

    if ( isLineBreakTag( nodeP.name ) ) then

        result = result .. "\n"
    end

    remainText = string.gsub( remainText, result, "", 1 )

    for i, node in ipairs( nodeP.nodes ) do

        if ( isLineBreakTag( node.name ) ) then

            result = result .. "\n"
        end

        if ( node.nodes ) then
            
            local paragraph = parseParagraph( epubContent, node )
            if ( paragraph ~= "" ) then

                result = result .. paragraph
            end
        end

        if ( isLineBreakTag( node.name ) ) then

            result = result .. "\n"
        end

        remainText = removeFirstSubstring( remainText, node:gettext() )

        temp = takeTextUntilTag( remainText )
        if ( temp ~= "" ) then

            result = result .. temp
        end
    end

    return result
end


local function parseHtmlData( epubContent, nodeData )

    for i, node in ipairs( nodeData.nodes ) do

        if ( node.nodes ) then

            parseHtmlData( epubContent, node )
        end

        if ( node.name == "p" or node.name == "blockquote" ) then

            local text = parseParagraph( epubContent, node )

            local textText = display.newText({
                text = text,
                x = epubContent.x,
                y = epubContent.itemY,
                width = epubContent.itemWidth,
                height = 0,
                font = resources.fonts.book.text,
                fontSize = resources.fontSizes.book.text
            })
            textText:setFillColor( unpack( resources.colors.white_1 ) )

            textText.y = textText.height / 2 + epubContent.itemY
            epubContent.itemY = epubContent.itemY + textText.height
            epubContent.displayGroup:insert( textText )
            epubContent:setScrollHeight( epubContent.itemY )
        elseif ( node.name == string.match( node.name, "^h%d$" ) ) then
                
            local text = parseParagraph( epubContent, node )

            local textText = display.newText({
                text = text,
                x = epubContent.x,
                y = epubContent.itemY,
                width = epubContent.itemWidth,
                height = 0,
                font = resources.fonts.book.title,
                fontSize = resources.fontSizes.book.title
            })
            textText:setFillColor( unpack( resources.colors.white_1 ) )

            textText.y = textText.height / 2 + epubContent.itemY
            epubContent.itemY = epubContent.itemY + textText.height
            epubContent.displayGroup:insert( textText )
            epubContent:setScrollHeight( epubContent.itemY )
        elseif ( node.name == "img" ) then

            local imagePath = correctImagePath( epubContent.htmlPath, node.attributes["src"] )

            --! Too small images:
            -- local image = display.newImage( imagePath, system.CachesDirectory )

            --! So justify images according to the screen resolution:
            local image = display.newImageRect( imagePath, system.CachesDirectory,
                display.contentWidth, epubContent.height )
            if image ~= nil then
                image.x = epubContent.x
                image.y = epubContent.itemY + image.height / 2
                epubContent.itemY = epubContent.itemY + image.height
                epubContent.displayGroup:insert( image )
                epubContent:setScrollHeight( epubContent.itemY )
            end
        end
    end
end


local function parseHtml( epubContent )

    local htmlPath = epubContent.htmlPath
    local htmlData = getFileContent( system.pathForFile( htmlPath, system.CachesDirectory ) )

    local root = htmlparser.parse( htmlData )
    parseHtmlData( epubContent, root )
end



function epubviewer.newEpubContent( top, left, width, height, epubBook )

    local epubContent = widget.newScrollView({
        id = "epubContent",
        top = top or 0,
        left = left or 0,
        width = width or display.contentWidth,
        height = height or display.contentHeight,
        scrollWidth = display.contentWidth,
        scrollHeight = 100000,
        horizontalScrollDisabled = true,
        verticalScrollDisabled = false,
        hideBackground = true,
    })

    epubContent.htmlPath = ""
    epubContent.book = epubBook

    epubContent.itemStartY = 0
    epubContent.itemWidth = display.contentWidth - 64
    epubContent.itemX = display.contentCenterX
    epubContent.itemY = epubContent.itemStartY

    epubContent.displayGroup = display.newGroup()

    epubContent:insert( epubContent.displayGroup )


    function epubContent:changeHtml( htmlPath )

        self:clearHtml()

        epubContent.htmlPath = htmlPath
        parseHtml( self )
    end
    
    function epubContent:clearHtml()

        for i = self.displayGroup.numChildren, 1, -1 do
            self.displayGroup[i]:removeSelf()
        end

        self.itemY = self.itemStartY
        self:setScrollHeight( self.itemY )
        self:scrollToPosition({
            y = 0,
            time = 0
        })

        self.htmlPath = ""
    end

    return epubContent
end


return epubviewer