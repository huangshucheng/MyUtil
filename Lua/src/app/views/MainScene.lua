
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
     
    local sp =  display.newSprite("HelloWorld.png")
        sp:move(display.center)
        sp:addTo(self)

    local delay = cc.DelayTime:create(2.0)
    local hide = cc.Hide:create()
    local moveTo = cc.MoveTo:create(2.0,cc.p(800,300))
    sp:runAction(cc.Sequence:create(moveTo,delay,hide))

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
end

return MainScene
