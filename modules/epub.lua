local lfs = require( "lfs" )
local zip = require( "plugin.zip" )
local xml2lua = require( "external.xml2lua" )

local epub = {}


function epub.getFileName( filePath )
    local fileName = string.match( filePath, ".*/(.*)" )
    return fileName
end


function epub.getFileDir( filePath )
    local fileDir = string.match( filePath, "(.*)/.*" )
    return fileDir
end


local function isEpubFile( mimetypePath )
    local file = io.open( mimetypePath, "r" )
    if file:read( "*a" ) ~= "application/epub+zip" then
        file:close()
        return false
    end
    file:close()
    return true
end


local function getOpfPath( containerXmlPath )

    print( "=======================================" )
    print( containerXmlPath )
    print( "=======================================" )

    local file = io.open( containerXmlPath, "r" )
    local xmlContent = file:read( "*a" )
    file:close()

    local xmlhandler = require( "external.xmlhandler.tree" )
    local xmlParser = xml2lua.parser( xmlhandler )

    xmlParser:parse( xmlContent )

    local containerXml = xmlhandler.root.container
    local rootfiles = containerXml.rootfiles
    local opfPath = nil


    for i,v in pairs( rootfiles ) do
        if i == "rootfile" then
            opfPath = v._attr["full-path"]
        end
    end

    return opfPath
end


local function getParsedOpf( opfData )
    local xmlhandler = require( "external.xmlhandler.tree" )
    local xmlParser = xml2lua.parser( xmlhandler )

    xmlParser:parse( opfData )
    
    return xmlhandler.root.package
end


local function getOpfMetadata( opfPackageXml )

    local metadata = {}

    local metadataXml = opfPackageXml.metadata

    for i,v in pairs( metadataXml ) do
        if i == "dc:identifier" then
            metadata.identifier = v
        elseif i == "dc:date" then
            metadata.date = v
        elseif i == "dc:rights" then
            metadata.rights = v
        elseif i == "dc:publisher" then
            metadata.publisher = v
        elseif i == "dc:contributor" then
            metadata.contributor = v
        elseif i == "dc:title" then
            metadata.title = v
        elseif i == "dc:description" then
            metadata.description = v
        elseif i == "dc:language" then
            metadata.language = v
        elseif i == "dc:subject" then
            metadata.subject = v
        elseif i == "dc:source" then
            metadata.source = v
        elseif i == "dc:creator" then
            metadata.creator = v
        end
    end

    return metadata
end

local function printMetadata( metadata )

    for i,v in pairs( metadata ) do
        if i == "identifier" then
            print( "identifier" )
            for i,v in pairs( v ) do
                print( i, v )
            end
        elseif i == "creator" then
            print( "creator" )
            for i,v in pairs( v ) do
                print( i, v )
            end
        elseif i == "date" then
            print( i, v )
        elseif i == "subject" then
            print( "subject" )
            for i,v in pairs( v ) do
                print( i, v )
            end
        elseif i == "publisher" then
            print( i, v )
        elseif i == "title" then
            print( i, v )
        elseif i == "contributor" then
            print( i, v )
        elseif i == "rights" then
            print( i, v )
        elseif i == "description" then
            print( i, v )
        elseif i == "language" then
            print( i, v )
        elseif i == "source" then
            print( i, v )
        end
    end
end


local function getOpfManifest( opfPackageXml )

    local manifest = {}

    local manifestXml = opfPackageXml.manifest
    local itemTable = manifestXml.item

    for i,v in pairs( itemTable ) do
        manifest[v._attr["id"]] = v._attr["href"]
    end

    return manifest
end


local function printManifest( manifest )

    for i,v in pairs( manifest ) do
        print( i, v )
    end
end


local function getOpfSpine( opfPackageXml )

    local spine = {}

    local spineXml = opfPackageXml.spine
    local itemrefTable = spineXml.itemref

    for i,v in pairs( itemrefTable ) do
        table.insert( spine, v._attr["idref"] )
    end

    return spine
end


local function printSpine( spine )

    for i,v in ipairs( spine ) do
        print( i, v )
    end
end


local function getOpfTable( opfPath )
    local opfFile = io.open( system.pathForFile( opfPath, system.CachesDirectory ), "r" )
    local opfData = opfFile:read( "*a" )
    opfFile:close()

    local opfPackageXml = getParsedOpf( opfData )

    local opfTable = {
        metadata = getOpfMetadata( opfPackageXml ),
        manifest = getOpfManifest( opfPackageXml ),
        spine = getOpfSpine( opfPackageXml ),
        epubPath = epub.getFileDir( opfPath ),
    }

    return opfTable
end


local function changeCssFont( opfTable )
    if opfTable.epubPath == nil then
        return nil
    end

    local cssCode = [[
    /* Apply font to the body element */
    body {
      font-family: 'Courier', sans-serif;
    }
    ]]

    for i, v in pairs( opfTable.manifest ) do
        print( i, v )

        if string.match( v, "%.css" ) then
            
            local fullPath = system.pathForFile( opfTable.epubPath .. "/" .. v, system.CachesDirectory )
            local file = io.open( fullPath, "a" )
            file:write( cssCode )
            file:close()
        end
    end
end


local function getHtmlPages( opfTable )
    local htmlPages = {}

    for i, v in ipairs( opfTable.spine ) do
        local htmlPage = {
            id = v,
            path = opfTable.manifest[v],
        }
        table.insert( htmlPages, htmlPage )
    end

    return htmlPages
end


local function unzipEpub( filePath )
    print( "Unzipping...", filePath )

    local zipOptions = {
        zipFile = filePath,
        zipBaseDir = system.CachesDirectory,
        dstBaseDir = system.CachesDirectory,
        listener = function( event )
            if event.isError then
                native.showAlert( "Error", "Unzip error", { "OK" } )
            end
        end
    }

    zip.uncompress( zipOptions )
end


local function sleep( timeToSleep )
    local a = 1
    for i = 1, timeToSleep do
        a = a + 1
    end
end


function epub.getEpubData( filePath )
    local epubData = {}

    unzipEpub( filePath )
    
    -- We can't wait for `listener` in zip.uncompress
    -- So the only way is to wait for some time
    sleep( resources.waitTime )

    if not isEpubFile( system.pathForFile( "mimetype", system.CachesDirectory ) ) then
        print( "Not epub file" )
        return nil
    end

    local opfPath = getOpfPath(
        system.pathForFile( "META-INF/container.xml", system.CachesDirectory )
    )
    epubData.opfTable = getOpfTable( opfPath )

    changeCssFont( epubData.opfTable )

    epubData.htmlPages = getHtmlPages( epubData.opfTable )

    for i, v in ipairs( epubData.htmlPages ) do
        print( i, v.id, v.path )
    end

    return epubData
end

function epub.openBook( filePath )

    local book = {
        filePath = filePath,
        fileName = epub.getFileName( filePath ),
        epubData = epub.getEpubData( filePath ),
        page = 1,
    }


    function book:getPageCount()
        return #self.epubData.htmlPages
    end

    function book:getPageHtml( pageNumber )
        if pageNumber < 1 or pageNumber > self:getPageCount() then
            return nil
        end

        local page = self.epubData.htmlPages[pageNumber]
        local pagePath = self.epubData.opfTable.epubPath .. "/" .. page.path
        local pageFile = io.open( system.pathForFile( pagePath, system.CachesDirectory ), "r" )
        local pageData = pageFile:read( "*a" )
        pageFile:close()

        return pageData
    end

    function book:getPagePath( pageNumber )
        if pageNumber < 1 or pageNumber > self:getPageCount() then
            return nil
        end

        local page = self.epubData.htmlPages[pageNumber]
        local pagePath = self.epubData.opfTable.epubPath .. "/" .. page.path

        print("[+] Request page: " .. pagePath )

        return pagePath
    end

    function book:changeCurrentPage( pageNumber )
        if pageNumber < 1 or pageNumber > self:getPageCount() then
            return nil
        end

        self.page = pageNumber
    end

    function book:getCurrentPage()
        return self.page
    end

    function book:getNextPage()
        if self.page < self:getPageCount() then
            if self:getPagePath( self.page + 1 ) then
                book:changeCurrentPage( self.page + 1 )
                return res
            end
        end
    end

    function book:getPrevPage()
        if self.page > 1 then
            if self:getPagePath( self.page - 1 ) then
                book:changeCurrentPage( self.page - 1 )
                return res
            end
        end
    end

    return book
end


return epub