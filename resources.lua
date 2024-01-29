local native = require("native")


local resources = {}


--
-- General
--

resources.dirBooks = "books"
resources.waitTime = 500000000

--
-- Coordinates
--
resources.offsetTop = 64

--
-- Fonts
--
resources.fonts = {}

-- `assets/fonts/Courier Prime Code.ttf`
-- resources.fonts["default"] = native.newFont( "assets/fonts/Courier Prime Code.ttf" )
resources.fonts = {
    default = "assets/fonts/Courier Prime Code.ttf",
    book = {
        title = "assets/fonts/Courier Prime Code.ttf",
        text = "assets/fonts/Courier Prime Code.ttf",
        italic = "assets/fonts/Courier Prime Code.ttf",
        bold = "assets/fonts/Courier Prime Code.ttf"
    }
}

-- Sizes of fonts
resources.fontSizes = {
    default = 64,
    book = {
        title = 96,
        text = 64
    }
}

-- Main colors for ui: gray, black, white
resources.colors = {
    gray = { 0.5, 0.5, 0.5 },
    black = { 0, 0, 0 },
    white = { 1, 1, 1 },
    black_1 = { 0.1, 0.1, 0.1 },
    white_1 = { 0.9, 0.9, 0.9 },
    black_2 = { 0.2, 0.2, 0.2 },
    white_2 = { 0.8, 0.8, 0.8 },
}

resources.colors_transparent = {
    gray = { 0.5, 0.5, 0.5, 0.75 },
    black = { 0, 0, 0, 0.75 },
    white = { 1, 1, 1, 0.75 },
    black_1 = { 0.1, 0.1, 0.1, 0.75 },
    white_1 = { 0.9, 0.9, 0.9, 0.75 },
    black_2 = { 0.2, 0.2, 0.2, 0.75 },
    white_2 = { 0.8, 0.8, 0.8, 0.75 },
}

resources.colors_transparent_1 = {
    gray = { 0.5, 0.5, 0.5, 0.5 },
    black = { 0, 0, 0, 0.5 },
    white = { 1, 1, 1, 0.5 },
    black_1 = { 0.1, 0.1, 0.1, 0.5 },
    white_1 = { 0.9, 0.9, 0.9, 0.5 },
    black_2 = { 0.2, 0.2, 0.2, 0.5 },
    white_2 = { 0.8, 0.8, 0.8, 0.5 },
}

resources.colors_transparent_2 = {
    gray = { 0.5, 0.5, 0.5, 0.25 },
    black = { 0, 0, 0, 0.25 },
    white = { 1, 1, 1, 0.25 },
    black_1 = { 0.1, 0.1, 0.1, 0.25 },
    white_1 = { 0.9, 0.9, 0.9, 0.25 },
    black_2 = { 0.2, 0.2, 0.2, 0.25 },
    white_2 = { 0.8, 0.8, 0.8, 0.25 },
}

return resources