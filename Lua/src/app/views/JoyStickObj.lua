local JoyStickObj = class("JoyStickObj", cc.Node) 

 local CalUtil = require("app.utils.CalUtil")

function JoyStickObj:ctor()
    print("JoyStickObj------->oncreate")
    self._ptHold = cc.p(0,0)    --  开始点击位置
    self._bInTouch = false      --  按钮点击开始
    self._fx = 0                -- 0-1
    self._fy = 0                -- 0-1
    self._fDisMax = 60          -- 半径
    self._spBg = nil            --  背景
    self._spJoys = nil          --  移动点
    self._radius_bg = {_w = 0,_h = 0}       --背景宽高
    self:initUI()               
end

function JoyStickObj:initUI()
    self._spBg = display.newSprite("MB_YAOGAN.png")
    self._radius_bg._w = self._spBg:getContentSize().width / 2
    self._radius_bg._h = self._spBg:getContentSize().height / 2
    self._fDisMax = self._radius_bg._w
    --print("radius-> _w:" .. self._radius_bg._w .. '   _h:' .. self._radius_bg._h)
    self._spBg:addTo(self)
    self._spJoys = display.newSprite('BT_YAOGAN.png')
    self._spBg:addChild(self._spJoys)
    self._spJoys:setPosition(cc.p(self._radius_bg._w,self._radius_bg._h))
    --self:setJoyStickOpacity(50)
end

function JoyStickObj:setJoyStickOpacity(opacity)
    self:setOpacity(opacity)
    self._spBg:setOpacity(opacity)
    self._spJoys:setOpacity(opacity)
end

function JoyStickObj:TouchBegin(ptBegin)
    self._ptHold = ptBegin
    self._bInTouch = true
end

function JoyStickObj:TouchMove(ptMove)
    local	fXChg	= ptMove.x - self._ptHold.x
	local	fYChg	= ptMove.y - self._ptHold.y
    local   ptRt = cc.p(0,0)
    local   fDis = math.sqrt(fXChg*fXChg + fYChg*fYChg)
    if fDis < self._fDisMax then
        self._fx = fXChg
        self._fy = fYChg
        ptRt.x = 0
        ptRt.y = 0
    else
        self._fx = fXChg * self._fDisMax / fDis
        self._fy = fYChg * self._fDisMax / fDis
        ptRt.x = fXChg - self._fx
        ptRt.y = fYChg - self._fy
        --self._ptHold = cc.p(self._ptHold.x + ptRt.x , self._ptHold.y + ptRt.y)
    end
    self._spJoys:setPosition(cc.p(self._fx + self._radius_bg._w,self._fy + self._radius_bg._h))
    return ptRt
end

function JoyStickObj:TouchEnd()
    self._bInTouch = false
    if not self:isActive() then
        self._spJoys:setPosition(cc.p(self._radius_bg._w,self._radius_bg._h))
    end
end

function JoyStickObj:Update()
    self:setVisible(self._bInTouch)
--[[
    if not self:isActive() then
        if self._fx > 3 or self._fy > 3 then
            self._fx = self._fx * 8 / 10
            self._fy = self._fy * 8 / 10
            self._spJoys:setPosition(cc.p(self._fx + 75,self._fy + 75))
        else
            self._fx = 0
            self._fy = 0
            self._spJoys:setPosition(cc.p(self._fx + 75,self._fy + 75))
        end
    end
    ]]
end

function JoyStickObj:isActive()
    return self._bInTouch
end
--[[获取当前操作]]
function JoyStickObj:GetCommand()
    return cc.p(self._fx / self._fDisMax,self._fy / self._fDisMax);
end
--[[获取当前方向]]
function JoyStickObj:GetDir360(ptMove)
    if not ptMove then return end
	return CalUtil.CalcDirection(self._ptHold.x,self._ptHold.y,ptMove.x,ptMove.y,360)
end

function JoyStickObj:GetDirLean4(ptMove)
    if not ptMove then return end
	return CalUtil.CalcDirection(self._ptHold.x,self._ptHold.y,ptMove.x,ptMove.y,4)
end

function JoyStickObj:GetDir4(ptMove)
    if not ptMove then return end
	return CalUtil.CalcDirection(self._ptHold.x,self._ptHold.y,ptMove.x,ptMove.y,2)
end

function JoyStickObj:GetDir8(ptMove)
    if not ptMove then return end
	return CalUtil.CalcDirection(self._ptHold.x,self._ptHold.y,ptMove.x,ptMove.y,nil)
end
return JoyStickObj
