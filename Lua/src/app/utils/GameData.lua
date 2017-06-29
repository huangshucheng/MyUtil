local GameData =  class("GameData")

function GameData:ctor()
    self._fx = 0
    self._fy = 0
    self._moveSpeed = 150
    self._moveDir = cc.p(0,0)

    self._winWidth = 960
    self._winHeight = 640
    self._spaceDis = 60
end

function GameData:Update(dt)
    self._fx = self._fx + self._moveDir.x * self._moveSpeed / 60
	self._fy = self._fy + self._moveDir.y * self._moveSpeed / 60
    --print("x: " .. self._fx .. "y: " .. self._fy)
	if self._fx <= self._spaceDis + 20 then self._fx	= self._spaceDis + 20 end
    if self._fx >= self._winWidth + 100  then self._fx = self._winWidth + 100  end
	if self._fy <= self._spaceDis + 20 then self._fy = self._spaceDis + 20 end
    if self._fy >= self._winHeight + 40 then self._fy = self._winHeight + 40 end
end

function GameData:ToughChgDir(movDir)
    self._moveDir.x = movDir.x
    self._moveDir.y = movDir.y
end

return GameData