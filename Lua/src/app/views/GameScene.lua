
local GameScene = class("GameScene", cc.load("mvc").ViewBase)

function GameScene:onCreate()
        self._spRotate = display.newSprite("navstick.png")
        self._spRotate:move(cc.p(250,250))
        self._spRotate:addTo(self)
        self:addUI()
end

function GameScene:addUI()
    local joystick = require('app.views.JokstickEx'):GetInstance()
    if not joystick then return end
    self:addChild(joystick)
    ---[[测试虚拟摇杆 ]]   
   local function onNaviCallback(direction , angle)
        if self._spRotate then
            self._spRotate:setRotation(-angle)
        end
        --print("angle->" .. angle)
    end  
    joystick:Init(true, false, cc.p(display.cx, display.cy),"MB_YAOGAN.png","BT_YAOGAN.png",onNaviCallback)  
end

return GameScene
