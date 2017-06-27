local TouchLayer = class("TouchLayer", cc.Layer)  

function TouchLayer:ctor()
    self._joyStick = nil
    self._touchListener = nil
    self:initUI()
    self:initTouchEvent()
end

function TouchLayer:initUI()
    self._joyStick = require("app.views.JoyStickObj"):create()
    if self._joyStick then
        self:addChild(self._joyStick)
        self._joyStick:setPosition(cc.p(140,200))
    end
end

function TouchLayer:onExit()
    self.super.onExit(self)
    local eventDispatcher = self:getEventDispatcher()
    if self._touchListener then
        eventDispatcher:removeEventListener(self._touchListener)
    end
end

function TouchLayer:initTouchEvent()

    local function onTouchBegan(touch, event)
    print("touch begin " )
    local ptT = touch:getLocation()
        if not self._joyStick:isActive() then
            self._joyStick:setPosition(ptT);
            self._joyStick:TouchBegin(ptT);
        end
        return true
    end

   local function onTouchMoved(touch, event)
        local ptT = touch:getLocation()
        local ptChg	= self._joyStick:TouchMove(ptT);
        --跟随手指移动点移动
        --self._joyStick:setPosition(cc.p(self._joyStick:getPositionX() + ptChg.x, self._joyStick:getPositionY() + ptChg.y))
    end

    local function onTouchEnded(touch, event)
        self._joyStick:TouchEnd()
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