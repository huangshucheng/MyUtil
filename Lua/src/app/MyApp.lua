
local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(os.time())
    print("myapp oncerate")
end

return MyApp
