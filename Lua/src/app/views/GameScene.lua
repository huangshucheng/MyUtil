
local GameScene = class("GameScene", cc.load("mvc").ViewBase)

--local joystick = require('app.views.JoystickEx')

function GameScene:onCreate()
    self:addUI()
end

function GameScene:addUI()
--[[
    self._joystick = joystick:GetInstance()
    if not self._joystick then return end
    self:addChild(self._joystick)
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
    ]]
    local touchlayer = require("app.views.TouchLayer"):create()
    self:addChild(touchlayer)
end

function GameScene:onExit()
    --self._joystick:ReleaseInstance()
end

return GameScene
