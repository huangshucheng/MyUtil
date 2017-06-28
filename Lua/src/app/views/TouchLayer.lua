local TouchLayer = class("TouchLayer", cc.Layer)  

local GameData = require("app.utils.GameData")

function TouchLayer:ctor()
    self._spRotate = nil
    self._joyStick = nil
    self._touchListener = nil
    self._gameData = GameData:create()
    self:initUI()
    self:initTouchEvent()
end

function TouchLayer:initUI()
    self._spRotate = display.newSprite("navstick.png")
    self._spRotate:move(cc.p(500,300))
    self._spRotate:addTo(self)
    self._spRotate:setScale(5.0)

    self._joyStick = require("app.views.JoyStickObj"):create()
    if self._joyStick then
        self:addChild(self._joyStick)
        self._joyStick:setPosition(cc.p(140,200))
    end

--   self:scheduleUpdateWithPriorityLua(function(dt)
--        self:schedule(dt)
--   end,0)

   self._scheduleId = CCDirector:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        self:schedule(dt)
   end, 0, false)
end

function TouchLayer:schedule(dt)
    print("schedule " .. dt)
    self._gameData:Updata(dt)
    self:refrishUI()
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
        self._spRotate:setRotation(-rot)
       -- self._gameData:ToughChgDir(rot)
    end

    local function onTouchEnded(touch, event)
        self._joyStick:TouchEnd()
        local ptT = touch:getLocation()

        local rot = self._joyStick:GetDir360(ptT)
        print("end->rot--->  " ..rot)
        --self._spRotate:setRotation(-rot)
        print("tou.h end ")
    end

    local function onTouchCanceled(touch, event)
        self._joyStick:TouchEnd()
        print("touch cancel ")
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