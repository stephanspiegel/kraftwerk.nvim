local function check()
    require("kraftwerk.system").check_health()
end

return {
    check = check
}
