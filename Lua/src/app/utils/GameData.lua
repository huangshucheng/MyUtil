local GameData =  class("GameData")

function GameData:ctor()
    self._fx = 0
    self._fy = 0
    self._moveSpeed = 15
    self._moveDir = cc.p(1,1)

    self._winWidth = 960
    self._winHeight = 640
    self._spaceDis = 65
end

function GameData:Updata(dt)
    self._fx = self._fx + self._moveDir.x * self._moveSpeed / 60
	self._fy = self._fy + self._moveDir.y * self._moveSpeed / 60
   -- self._fx = self._fx + 0.2
	--self._fy = self._fy + 0.2
    print("x: " .. self._fx .. "y: " .. self._fy)

	if self._fx < self._spaceDis+120 then self._fx	= self._spaceDis+120 end
    if self._fx > self._winWidth-120 then self._fx = self._winWidth-120 end
	if self._fy < self._spaceDis+80 then self._fy   = self._spaceDis+80 end
    if self._fy > self._winWidth-80 then self._fy	= self._winWidth-80 end
end

function GameData:ToughChgDir(movDir)
    --self._moveDir.x = movDir.x
    --self._moveDir.y = movDir.y
end

return GameData