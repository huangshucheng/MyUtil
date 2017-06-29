local TouchLayer = class("TouchLayer", cc.Layer)  

local GameData = require("app.utils.GameData")

function TouchLayer:ctor()
    self._spRotate = nil
    self._joyStick = nil
    self._drawLayer = nil
    self._touchListener = nil
    self._gameData = GameData:create()
    self:initUI()
    self:initTouchEvent()
end

function TouchLayer:initUI()
    --self._spRotate = display.newSprite("navstick.png")
    self._spRotate = require("app.views.MoveObj").new("navstick.png")
    self._spRotate:move(cc.p(500,300))
    self._spRotate:addTo(self,1)

    self._drawLayer = require("app.views.DrawLayer"):create()
    self:addChild(self._drawLayer)
    self._drawLayer:setMoveObj(self._spRotate)

    self._joyStick = require("app.views.JoyStickObj"):create()
    if self._joyStick then
        self:addChild(self._joyStick)
        self._joyStick:setPosition(cc.p(140,200))
    end

   self._scheduleId = CCDirector:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        self:schedule(dt)
   end, 0, false)
end

function TouchLayer:schedule(dt)
    --print("schedule " .. dt)
    self._gameData:Update(dt)
    self._gameData:ToughChgDir(self._joyStick:GetCommand())
   -- self._spRotate:Update()
    self:refrishUI()
    local pos = self._joyStick:GetCommand()
    --self._spRotate:setMoving( not pos.x == 0 and pos.y == 0)
    if pos.x == 0 and pos.y == 0 then
        self._spRotate:setMoving(false)
       -- print("stop")
    else
        self._spRotate:setMoving(true)
       -- print("move")
    end
    self._drawLayer:Update()
end


function TouchLayer:refrishUI()
    if self._spRotate then
        self._spRotate:setPosition(cc.p(self._gameData._fx,self._gameData._fy))
    end
end

function TouchLayer:onExit()
    self.super.onExit(self)
    local eventDispatcher = self:getEventDispatcher()
    if self._touchListener then
        eventDispatcher:removeEventListener(self._touchListener)
    end
    if self._scheduleId then
        CCDirector:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleId)
        self._scheduleId = nil
    end
end

function TouchLayer:initTouchEvent()

    local function onTouchBegan(touch, event)
        print("touch begin " )
        local ptT = touch:getLocation()
        if not self._joyStick:isActive() then
            self._joyStick:setPosition(ptT)
            self._joyStick:TouchBegin(ptT)
        end
        local rot = self._joyStick:GetDir360(ptT)
        print("begin->rot--->  " ..rot)
        --self._spRotate:setRotation(-rot)
        return true
    end

   local function onTouchMoved(touch, event)
        local ptT = touch:getLocation()
        local ptChg	= self._joyStick:TouchMove(ptT)
        --跟随手指移动点移动
        --self._joyStick:setPosition(cc.p(self._joyStick:getPositionX() + ptChg.x, self._joyStick:getPositionY() + ptChg.y))
        --print("dir---360>  " .. self._joyStick:GetDir360(ptT))
        --print("dir---4,Lean  >  " .. self._joyStick:GetDirLean4(ptT))
        --print("dir---4  >  " .. self._joyStick:GetDir4(ptT))
        --print("dir---8>  " .. self._joyStick:GetDir8(ptT))

        local rot = self._joyStick:GetDir360(ptT)
        print("rot--->  " ..rot)
        self._spRotate:setObjRotation(-rot)
    end

    local function onTouchEnded(touch, event)
        self._joyStick:TouchEnd()
        local ptT = touch:getLocation()
        local rot = self._joyStick:GetDir360(ptT)
        print("end->rot--->  " ..rot)
    end

    local function onTouchCanceled(touch, event)
        self._joyStick:TouchEnd()
    end

    self._touchListener = cc.EventListenerTouchOneByOne:create()  
    self._touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)  
    self._touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)  
    self._touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)  
    self._touchListener:registerScriptHandler(onTouchCanceled, cc.Handler.EVENT_TOUCH_CANCELLED)  
    local eventDispatcher = self:getEventDispatcher()  
    eventDispatcher:addEventListenerWithSceneGraphPriority(self._touchListener, self)  

end

return TouchLayer