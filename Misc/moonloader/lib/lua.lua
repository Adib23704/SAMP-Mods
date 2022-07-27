-- finds a lua library and returns the entrypoint 
local function find(lib)
    local path = LUA_PATH or os.getenv("LUA_PATH") or "?;?.lua"
    local f, e1
    for p in string.gfind(path, "[^;]+") do
      local n = string.gsub(p, "%?", lib)
      f, e1 = loadfile(n)
      if f then break end
    end
    return f, e1
end

-- new "require" function
function require(name)
    if not _LOADED[name] then
        local f = assert(find(name))
        local m = {}
        setmetatable(m, {__index = _G})
        setfenv(f, m)
        f()
        _LOADED[name] = m
    end
    return _LOADED[name]
end

_LOADEDLIB = {}

-- finds a dynamic library and returns the entrypoint 
local function findlib(lib, init)
    init = init or "luaopen_" .. lib
    local path = LUA_PATHLIB or os.getenv("LUA_PATHLIB") or 
        "?;?.dll;?.so;?.dylib"
    local f, e1, e2
    for p in string.gfind(path, "[^;]+") do
      local n = string.gsub(p, "%?", lib)
      f, e1, e2 = loadlib(n, init)
      if f then break end
    end
    return f, e1, e2
end

-- works just like "require", but for dynamic libraries
function requirelib(lib, init, namespace)
    local entrypoint = _LOADEDLIB[lib]
    if not entrypoint then entrypoint = assert(findlib(lib, init)) end
    namespace = namespace or {}
    local globals = _G
    setmetatable(namespace, {__index = globals})
    setfenv(0, namespace)
    entrypoint()
    globals.setfenv(0, globals)
    _LOADEDLIB[lib] = entrypoint
    return namespace
end
