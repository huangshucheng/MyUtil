local CalUtil = {}

function CalUtil.CalcDistance( nX1, nY1, nX2, nY2)
    return math.sqrt((nX1-nX2)*(nX1-nX2)+(nY1-nY2)*(nY1-nY2))
end

function CalUtil.CalcDistance2( nX1, nY1, nX2, nY2)
	return (nX1-nX2)*(nX1-nX2)+(nY1-nY2)*(nY1-nY2)*225/100
end

function CalUtil._calc360Direction( nX1, nY1, nX2, nY2)
	local dx = nX2 - nX1
	local dy = nY2 - nY1
	if dx == 0 and dy == 0 then return 180 end
	if dx ~= 0 then
		local r = math.atan2(dy, dx)
		local angle
		if r >= 0 then
			angle = 180.0 * r / math.pi + 22.5
		else
			angle = 180.0 + 180.0 * ( math.pi + r ) / math.pi + 22.5
        end
		return ( angle + 68 ) % 360
	else
		if dy >= 0 then return 180 else return 0 end
    end
	return 0
end

function CalUtil._calc8Direction( nX1, nY1, nX2, nY2)
	local dx = nX2 - nX1
	local dy = nY2 - nY1
    if dx == 0 and dy == 0 then return 4 end
	if dx ~= 0 then
		local r = math.atan2(dy,dx)
		local angle
		if r >= 0 then
            angle = 180.0 * r / math.pi + 22.5
		else
            angle = 180.0 + 180.0 * ( math.pi + r) / math.pi + 22.5
        end
		return (angle / 45 + 2) % 8
	else
		if dy >= 0 then return 4 else return 0 end
	end
	return 0
end

function CalUtil._calc4Direction( nX1, nY1, nX2, nY2)
	local dx = nX2 - nX1
	local dy = nY2 - nY1
	if dx == 0 and dy == 0 then return 4 end
	local nRtl	= 3
	if dx ~= 0 then
		local r = math.atan2(dy,dx)
		local angle
		if r >= 0 then
            angle = 180.0 * r / math.pi + 45
		else
            angle = 180.0 + 180.0 * ( math.pi + r) / math.pi + 45
        end
		nRtl =( angle / 90 + 1) % 4
	else
		if dy >= 0 then return 4 else return 0 end
	end
    if nRtl == 1 then nRtl = 2
	elseif nRtl == 2 then nRtl = 4
	elseif nRtl == 3 then nRtl = 6
    end
	return nRtl
end

function CalUtil._calc4LeanDirection( nX1, nY1, nX2, nY2)
	local dx = nX2 - nX1
	local dy = nY2 - nY1
	if dx == 0 and dy == 0 then return 5 end
	local nRtl	= 1
	if dx ~= 0 then
		local r = math.atan2(dy,dx)
		local angle
		if r >= 0 then
            angle = 180.0 * r / math.pi + 45
		else
            angle = 180.0 + 180.0 * ( math.pi + r) / math.pi + 45
        end
		nRtl =( angle / 45 + 1) % 8
	else
		if dy >= 0 then return 5 else return 1 end
	end
    if nRtl == 0 then nRtl = 1
	elseif nRtl == 2 then nRtl = 3
	elseif nRtl == 4 then nRtl = 5
    elseif nRtl == 6 then nRtl = 7
    end
	return nRtl
end

function CalUtil.CalcDirection( fX1, fY1, fX2, fY2, bType )
	if bType == 2  then
		return CalUtil._calc4Direction(fX1,fY1,fX2,fY2) --四分方向，正下方偏左为起点 0
	elseif bType == 4 then
		return CalUtil._calc4LeanDirection(fX1,fY1,fX2,fY2) --四个方向，正下方为起点0
	elseif bType == 360 then
		return CalUtil._calc360Direction(fX1,fY1,fX2,fY2)   --360度方向 正下方为起点0
	else
		return CalUtil._calc8Direction(fX1,fY1,fX2,fY2) --八方向 正下方偏左为起点 0
    end
end

return CalUtil