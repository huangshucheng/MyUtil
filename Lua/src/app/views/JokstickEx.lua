--[[  
虚拟摇杆类 Layer  
几种组合方式：  
1.固定位置   不自动隐藏  
2.固定位置   自动隐藏  
3.非固定位置 自动隐藏  
Init 初始化  
Release 释放  
SetEnable 启用  
IsEnable 是否启用  
--]] 

--[[
http://blog.csdn.net/a102111/article/details/60467352
]]
--local JoystickEx = class("JoystickEx", cc.Layer)
local JoystickEx = class("JoystickEx",function()  
    return cc.Layer:create()  
end)  

-- 8个方向  
JoystickEx.eDirection = {  
    None = 0,  
    U = 1,  
    UR = 2,  
    R = 3,  
    DR = 4,  
    D = 5,  
    DL = 6,  
    L = 7,  
    UL = 8  
}

function JoystickEx:ctor()
    
    self._rootNode = nil
    self._instance = nil  
    self._touchArea = nil  
    self._touchListener = nil  
    self._downPos = nil  
    self._isEnable = false  
    self._naviCallback = nil  
    self._rootNode = nil  
    self._naviBallNode = nil  
    self._radius = 0  
    self._naviPosition = nil -- nil时跟随点击位置  
    self._isAutoHide = true  -- 非点击或移动状态自动隐藏 
    self._isTouchBegin = false 
end

function JoystickEx:GetInstance()  
    if self._instance == nil then  
        self._instance = self.new()
    end  
    return self._instance
end  

function JoystickEx:ReleaseInstance()  
    if self._instance ~= nil then  
        self._instance:Release()  
        self._instance = nil  
    end  
end 

function JoystickEx:Release()  
    if self._touchListener ~= nil then  
        cc.EventDispatcher:removeEventListener(self._touchListener)  
        self._touchListener = nil  
    end  
  
    if self._naviCallback ~= nil then  
        self._naviCallback = nil  
    end  
end 

--[[参数表  
isEnable 是否启用  
isAutoHide 是否自动隐藏，如果没有固定位置，则此参数无效，按照自动隐藏处理  
naviPosition 摇杆位置，nil则跟随点击位置，否则有固定位置  
navBg 摇杆背景图
naviName 摇杆小图  
naviCallback 方向更改回调，回传角度与8个反向，参考eDirection，角度以右为0，上为90，下为-90  
]] 

-- 初始化 naviPosition nil则根据点击位置变化 有值则固定位置  
function JoystickEx:Init(isEnable,isAutoHide,naviPosition,naviBg,naviName,touchArea,naviCallback)  
    -- 没有固定位置 自动隐藏  
    --if not naviPosition then isAutoHide = true end  

    self._naviCallback = naviCallback  
    self._naviBallNode = display.newSprite(naviName)
    self._rootNode = display.newSprite(naviBg)

    if not self._naviBallNode or not self._rootNode then print("file is not exist") return false end

    self:addChild(self._rootNode , 1)
    self._rootNode:addChild(self._naviBallNode)
    self._radius = self._rootNode:getContentSize().width / 2
    self:SetNaviPosition(naviPosition)

    if not naviPosition then self:resetRootNodePos() end

    local _w = self._rootNode:getContentSize().width / 2
    local _h = self._rootNode:getContentSize().height / 2

    --self._naviBallNode:setScale(0.5)
    self._naviBallNode:setPosition(cc.p(_w ,_h))

    self:SetTouchArea(touchArea)  
    self:SetAutoHide(isAutoHide)  
    self:SetEnable(isEnable)  
    self._rootNode:setVisible(not self:IsAutoHide()) 

    self._touchListener = cc.EventListenerTouchOneByOne:create()  
    self._touchListener:registerScriptHandler(self.onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)  
    self._touchListener:registerScriptHandler(self.onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)  
    self._touchListener:registerScriptHandler(self.onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)  
    self._touchListener:registerScriptHandler(self.onTouchCanceled, cc.Handler.EVENT_TOUCH_CANCELLED)  
    local eventDispatcher = self:getEventDispatcher()  
    eventDispatcher:addEventListenerWithSceneGraphPriority(self._touchListener, self)  
    return true  
end

function JoystickEx:resetRootNodePos(pos)
    if not self._rootNode then return end
    pos = pos or  cc.p(self._rootNode:getContentSize().width,self._rootNode:getContentSize().height)
    self._rootNode:setPosition(pos)
end

function JoystickEx:setNodeOpacity(node,opacity)
    if not node then return end
    opacity = opacity or 255
    node:setOpacity(opacity)
    local childVec = node:getChildren()
    for _, var in pairs(childVec) do
        var:setOpacity(opacity)
    end
end

function JoystickEx:onExit()
    self.super.onExit(self)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self._touchListener)
end

-- 启用  
function JoystickEx:SetEnable(isEnable)  
    self._isEnable = isEnable
end  

-- 是否启用  
function JoystickEx:IsEnable()  
    return self._isEnable or false 
end 

-- 自动隐藏  
function JoystickEx:SetAutoHide(isAutoHide)  
    self._isAutoHide = isAutoHide  
end 

-- 是否自动隐藏  
function JoystickEx:IsAutoHide()  
    return self._isAutoHide  or false
end  
  
-- 设置位置  
function JoystickEx:SetNaviPosition(naviPosition)  
    self._naviPosition = naviPosition  
    if self._naviPosition ~= nil then  
        self._rootNode:setPosition(self._naviPosition)  
    end  
end

-- 位置是否跟随初始点击位置变动  
function JoystickEx:IsPosCanChange()  
    return (self._naviPosition == nil)  
end

-- 设置触摸区域  
function JoystickEx:SetTouchArea(touchArea)  
    if touchArea ~= nil then  
        self._touchArea = {}  
        self._touchArea.x = touchArea.x  
        self._touchArea.y = touchArea.y  
        self._touchArea.width = touchArea.width  
        self._touchArea.height = touchArea.height  
    else  
        self._touchArea = nil  
    end  
end

-- 触摸操作回调  
function JoystickEx.onTouchBegan(touch, event) 
    local self = JoystickEx._instance  
    if not self then return false end

    local needNextProcess = false 
    if not self:IsEnable() then  
        return needNextProcess  
    end  
  
    if self._touchArea ~= nil then  
        local touchPoint = touch:getLocation()  
        if cc.rectContainsPoint(self._touchArea, touchPoint) then  
            self._touchListener:setSwallowTouches(true)
            self._isTouchBegin = true  
            self:Update(touchPoint, false)    
            self:setNodeOpacity(self._rootNode,80)
            needNextProcess = true
            print("in area!")  
        else  
            self._touchListener:setSwallowTouches(false)  
            self:Update(nil, false)  
            print("not in area")  
            needNextProcess = false  
        end  
    end  
    print("touch begin")
    return needNextProcess  
end

function JoystickEx.onTouchMoved(touch, event) 
    if not JoystickEx._instance  then return end
    local self = JoystickEx._instance
    self._isTouchBegin = false 
    local touchPoint = touch:getLocation()  
    self:Update(touchPoint, true)  
end 

function JoystickEx.onTouchEnded(touch, event) 
    if not JoystickEx._instance  then return end
    local self = JoystickEx._instance
    self._isTouchBegin = false 
    if not self then return false end 
    self:Update(nil, false) 

    self:resetRootNodePos()
    self:setNodeOpacity(self._rootNode,255)
    print("touch end")
end 

function JoystickEx.onTouchCanceled(touch, event)
    if not JoystickEx._instance  then return end
    local self = JoystickEx._instance 
    self._isTouchBegin = false
    self:Update(nil, false)
    self:setNodeOpacity(self._rootNode,255)  
end 

function JoystickEx:Update(touchPos, isMove)  
    local direction, angle = self:UpdateData(touchPos, isMove)  
    local isShow = ((not self:IsAutoHide()) or (self._downPos ~= nil))  
    --self:UpdateUI(direction, angle, isShow)  
    self:UpdateUIForTouchPos(touchPos,direction, angle, isShow)
    if self._naviCallback ~= nil then  
        self._naviCallback(direction, angle)  
    end  
end
--[[
function JoystickEx:UpdateUI(direction, angle, isShow) 
    if not self._rootNode then return end 
    local _w = self._rootNode:getContentSize().width / 2
    local _h = self._rootNode:getContentSize().height / 2
    local ballPos = {x = _w , y = _h}  
    if isShow then  
        -- 球位置更新  
        if direction ~= self.eDirection.None then  
            local radians = math.rad(angle)  
            ballPos.x = math.cos(radians)*(self._radius) + _w
            ballPos.y = math.sin(radians)*(self._radius) + _h
            --ballPos.x = math.cos(radians)  + self._touchArea.width / 2      --todo  控制在框内自由转动
            --ballPos.y = math.sin(radians)  + self._touchArea.height / 2
        end  
        self._naviBallNode:setPosition(ballPos)  
        -- 显示更新  
        if self:IsPosCanChange() then  
            --self._rootNode:setPosition(self._downPos)  
            if self._downPos then
                self._rootNode:setPosition(cc.p(self._downPos))  
            end
        end  
    end  
    self._rootNode:setVisible(isShow)  
end  
]]
function JoystickEx:UpdateUIForTouchPos(touchPos,direction, angle, isShow) 
    if not self._rootNode then return end 
    local r_w = self._rootNode:getContentSize().width / 2
    local r_h = self._rootNode:getContentSize().height / 2

    local bg_X = self._rootNode:getPositionX()
    local bg_y = self._rootNode:getPositionY()

    touchPos = touchPos or {x = r_w,y = r_h}

    local touchX = touchPos.x
    local touchY = touchPos.y

    local _d = cc.pSub(cc.p(touchX,touchY), cc.p(bg_X,bg_y))
    local _dis = math.sqrt(_d.x * _d.x + _d.y * _d.y)

    if _dis <= 0 then _dis = 0 end
    if _dis >= self._radius then _dis = self._radius end

    local ballPos = {x = r_w , y = r_h}  
    print("ballpos before-> x:" .. ballPos.x .. "  ,y" .. ballPos.y)
    if isShow then  
        if self._isTouchBegin then direction = self.eDirection.None end
        if direction ~= self.eDirection.None then  
            local radians = math.rad(angle)  
            ballPos.x = math.cos(radians)*(_dis + 20) + r_w
            ballPos.y = math.sin(radians)*(_dis + 20) + r_h
        end  
     print("ballpos after-> x:" .. ballPos.x .. "  ,y" .. ballPos.y)
        self._naviBallNode:setPosition(ballPos)  
        if self:IsPosCanChange() then  
            if self._downPos then
                self._rootNode:setPosition(cc.p(self._downPos))  
            end
        end  
    end  
    self._rootNode:setVisible(isShow)  
end
  
function JoystickEx:UpdateData(touchPos, isMove)  
    local direction = self.eDirection.None  
    local angle = 0  
    local isNeedUpdate = false  
  
    if not isMove then  
        self._downPos = touchPos  
        if not self:IsAutoHide() then  
            isNeedUpdate = true  
        end  
    else
        isNeedUpdate = true  
    end  
  
    if isNeedUpdate then  
        if self._downPos ~= nil and touchPos ~= nil then  
            local centerPos = self._downPos  
            if not self:IsPosCanChange() then  
                centerPos = self._naviPosition  
            end  
            -- 弧度 转 角度  
            local radians = cc.pToAngleSelf(cc.pSub(touchPos, centerPos))  
            -- angle = radians*57.29577951 -- ((__ANGLE__) * 57.29577951f) // PI * 180 CC_RADIANS_TO_DEGREES  
            angle = math.deg(radians)  
            direction = self:AngleToDirection(angle)  
            --print("angle:"..tostring(angle))  
            --print("direction:"..tostring(direction))  
        else  
            print("downPos or touchPos is nil!")  
        end  
    end  
  
    return direction, angle  
end

-- 角度转方向  
function JoystickEx:AngleToDirection(angle)  
    local direction = self.eDirection.None  
  
    -- -22.5 22.5 67.5 112.5 157.5 -157.5 -112.5 -67.5 -22.5  
    --      R    DR   D     DL    L      UL     U     UR  
    if angle > -22.5 and angle <= 22.5 then  
        direction = self.eDirection.R  
    elseif angle > 22.5 and angle <= 67.5 then  
        direction = self.eDirection.DR  
    elseif angle > 67.5 and angle <= 112.5 then  
        direction = self.eDirection.D  
    elseif angle > 112.5 and angle <= 157.5 then  
        direction = self.eDirection.DL  
    elseif angle > 157.5 or angle <= -157.5 then  -- 特殊  
        direction = self.eDirection.L  
    elseif angle > -157.5 and angle <= -112.5 then  
        direction = self.eDirection.UL  
    elseif angle > -112.5 and angle <= -67.5 then  
        direction = self.eDirection.U  
    elseif angle > -67.5 and angle <= -22.5 then  
        direction = self.eDirection.UR  
    end  
  
    return direction  
end 

return JoystickEx