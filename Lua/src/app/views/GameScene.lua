
local GameScene = class("GameScene", cc.load("mvc").ViewBase)

local joystick = nil

function GameScene:onCreate()
        
    self._joystick = nil

    self._spRotate = display.newSprite("navstick.png")
    self._spRotate:move(cc.p(500,300))
    self._spRotate:addTo(self)
    self:addUI()
end

function GameScene:addUI()
    self._joystick = require('app.views.JokstickEx'):GetInstance()
    if not self._joystick then return end
    self:addChild(self._joystick)
    ---[[测试虚拟摇杆 ]]   
   local function onNaviCallback(direction , angle)
        if self._spRotate then
            self._spRotate:setRotation(-angle)
        end
        --print("angle->" .. angle)
    end  
    --self._joystick:Init(true, false, cc.p(display.cx, display.cy),"MB_YAOGAN.png","BT_YAOGAN.png",onNaviCallback) 
    --self._joystick:Init(true, true, cc.p(display.cx, display.cy),"MB_YAOGAN.png","BT_YAOGAN.png",onNaviCallback) 
    local toucharea = {x = 0,y = 0,width = display.width / 3 ,height = display.height / 2}
    self._joystick:Init(true, false, nil,"MB_YAOGAN.png","BT_YAOGAN.png",toucharea,onNaviCallback)  
    self._joystick:SetEnable(true)
end

function GameScene:onExit()
    self.super.onExit(self)
    self._joystick:ReleaseInstance()
end

return GameScene
