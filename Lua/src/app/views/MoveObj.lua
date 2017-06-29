local MoveObj = class("MoveObj", cc.Node) 

function MoveObj:ctor(fileName)   
    self._isMoving = false 
    self._spRotate = display.newSprite(fileName)
    if not self._spRotate then return end
    self._spRotate:move(cc.p(0,0))
    self._spRotate:addTo(self)
    self._spRotate:setScale(1.5)
end

function MoveObj:setObjRotation(angle)
    if not self._spRotate then return end
    self._spRotate:setRotation(angle)
end

function MoveObj:isMoving()
    return self._isMoving
end

function MoveObj:setMoving(ismove)
    self._isMoving = ismove
end

return MoveObj

