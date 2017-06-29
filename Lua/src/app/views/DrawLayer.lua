local DrawLayer = class("DrawLayer", cc.Layer)  

function DrawLayer:ctor()
    self._moveObj = nil
    self:initUI()
end

function DrawLayer:setMoveObj(moveObj)
    self._moveObj = moveObj
end

function DrawLayer:initUI()
    self.myDrawNode= cc.DrawNode:create()  
    self:addChild(self.myDrawNode)  
    self.myDrawNode:setPosition(cc.p(0,0))
end

function DrawLayer:Update()
    if not self._moveObj then return end
    local x , y = self._moveObj:getPosition()
    --print('x---> ' .. x .. '  ,y--->' .. y) 
    if self._moveObj:isMoving() then
        self.myDrawNode:drawDot(cc.p(x,y), 3, cc.c4f(1,1,1,1))
    end
end

return DrawLayer