local echo = require("kraftwerk.util.echo")

local function build_table(json)
    echo.warn("Not implemented yet")
    return {
        "ERROR",
        "=====",
        "",
        "Table format is not implemented yet"
    }
end

return {
    build_table = build_table
}
