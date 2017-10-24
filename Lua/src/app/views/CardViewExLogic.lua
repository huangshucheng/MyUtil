--[[
掼蛋数据缓存以及数据逻辑处理脚本
数据缓存格式备注：
table =
{
	table = {},
	table = {},
	...
	table = {}
}
]]

local CardViewExLogic = {
	cardDatas = {},				-- 手牌数据缓存数组
	thsIdx = nil,					-- 检索同花顺起始索引
	thsDatas = nil,					-- 存储所有同花顺数据
	hintDatas = nil,				-- 存储所有提示可用手牌数据
	hintIdx = nil,					-- 检索可用手牌起始索引
}

--[[
clone - function for test deep clone
]]
function clone(object)
	local lookup_table = {}
	local function copyObj(object)
		if type(object) ~= 'table' then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end

		local new_table = {}
		lookup_table[object] = new_table
		for key, val in pairs(object) do
			new_table[copyObj(key)] = copyObj(val)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return copyObj(object)
end

--------------------------------------------------------------------------------------------------------------------------------------
--[[
dumpInfo - 打印手牌信息
]]
function CardViewExLogic:dumpInfo()
	local idx = 1
	for k, v in pairs(self.cardDatas) do
		local s = string.format('%s : ', k)

		for _k, _v in pairs(v) do
			s = string.format('%s [%d]%d(%d %d)', s, idx, _v, _v%16, math.floor(_v/16))
			idx = idx + 1
		end

		print(s)
	end
end

--[[
nums - 获取手牌数量
参数：
1.手牌数据
]]
function CardViewExLogic:nums(t)
	if not t then return 0 end
	local cnt = 0
	for k, v in pairs(t) do
		cnt = cnt + 1
	end
	return cnt
end

--[[
rmByCard - 删除手牌
参数：
1.手牌
]]
function CardViewExLogic:rmByCard(card)
	for i = 1, #self.cardDatas do
		local subcard = self.cardDatas[i]
		local rm = false

		for j = 1, #subcard do
			if subcard[j] == card then
				table.remove(subcard, j)
				rm = true
				break
			end
		end

		if #subcard == 0 then
			table.remove(self.cardDatas, i)
			break
		end

		if rm then
			break
		end
	end
end

--[[
rmByCards - 删除指定手牌
参数：
1.手牌
]]
function CardViewExLogic:rmByCards(cards)
	for i = 1, #cards do
		self:rmByCard(cards[i])
	end
end

--[[
rmByIdx - 删除指定位置索引上的手牌数据
参数：
1.位置索引
]]
function CardViewExLogic:rmByIdx(idx)
	local n = CardViewExLogic:nums(self.cardDatas)
	local s = 0

	for i = 1, n do
		if s + CardViewExLogic:nums(self.cardDatas[i]) >= idx then
			table.remove(self.cardDatas[i], idx - s)

			if CardViewExLogic:nums(self.cardDatas[i]) == 0 then table.remove(self.cardDatas, i) end
			break
		end

		s = s + CardViewExLogic:nums(self.cardDatas[i])
	end
end

--[[
rmByIndices - 一次性删除所有指定位置的手牌数据
参数：
1.位置索引序列
]]
function CardViewExLogic:rmByIndices(indices)
	if not indices or #indices == 0 then return end

	local n = CardViewExLogic:nums(self.cardDatas)

	table.sort(indices)
	for i = 1, #indices do
		local idx = indices[i]

		local s = 0
		for j = 1, n do
			if s + CardViewExLogic:nums(self.cardDatas[j]) >= idx then
				self.cardDatas[j][idx - s] = 0 -- Set value to be zero for remove

				break
			end

			s = s + CardViewExLogic:nums(self.cardDatas[j])
		end
	end

	print('After mark index of card ==================================>')
	self:dumpInfo()

	-- Remove card datas with reverse indices
	for i = #self.cardDatas, 1, -1 do
		local subs = self.cardDatas[i]

		for j = #subs, 1, -1 do
			if subs[j] == 0 then
				table.remove(subs, j)
			end
		end

		if #subs == 0 then table.remove(self.cardDatas, i) end
	end

	print('After remove of card ======================================>')
	self:dumpInfo()
end

--[[
getVerticalHits - 根据选中的手牌获取命中的列索引
参数：
1.选中的手牌
返回：
1.命中的列数据
]]
function CardViewExLogic:getVerticalHits(selecs)
	if not selecs or #selecs == 0 then return {} end

	local hits = {}
	local used = {}
	table.sort(selecs)
	for i = 1, #selecs do
		local idx = selecs[i]

		local s = 0
		for j = 1, #self.cardDatas do
			if s < idx and s + #self.cardDatas[j] >= idx and not used[j] then
				local hit = {}

				for k = 1, #self.cardDatas[j] do table.insert(hit, s + k) end

				table.insert(hits, hit)
				used[j] = true
				break
			end

			s = s + #self.cardDatas[j]
		end
	end

	return hits
end

--[[
getHorizontalHits - 根据选中的额手牌获取需要刷新视图的行索引
参数：
1.选中的手牌
返回：
1.命中的行数据
]]
function CardViewExLogic:getHorizontalHits(selecs)
	if not selecs or #selecs > 1 then return end
	
	local hits_left = {}
	
	local sidx = selecs[1]
	local scnt = 0
	while scnt < 3 do
		sidx = sidx - 1
		if sidx <= 0 then break end
		
		table.insert(hits_left, sidx)
		scnt = scnt + 1
	end
	
	local cardcnt = 0
	for i = 1, #self.cardDatas do cardcnt = cardcnt + #self.cardDatas[i]	end
	
	local hits_right = {}
	
	local sidx = selecs[1]
	local scnt = 0
	while scnt < 3 do
		sidx = sidx + 1
		if sidx > cardcnt then break end
		
		table.insert(hits_right, sidx)
		scnt = scnt + 1
	end
	
	return hits_left, hits_right
end

--[[
getByidx - 获取指定位置索引上的手牌数据
参数：
1.位置索引
]]
function CardViewExLogic:getByidx(idx)
	local n = CardViewExLogic:nums(self.cardDatas)
	local s = 0

	for i = 1, n do
		if s + CardViewExLogic:nums(self.cardDatas[i]) >= idx then
			return self.cardDatas[i][idx - s]
		end

		s = s + CardViewExLogic:nums(self.cardDatas[i])
	end
end

--[[
suitsAll - 获取当前手牌中所有可用的百搭牌
参数：
1.牌级
2.使用标记
]]
function CardViewExLogic:suitsAll(lv, tused)
	local sc = 3 * 16 + lv
	local idx = 0
	local tsc = {}

	for i = 1, #self.cardDatas do
		local subs = self.cardDatas[i]

		for j = 1, #subs do
			idx = idx + 1
			if sc == subs[j] and not tused[idx] then table.insert(tsc, idx) end
		end
	end

	return tsc
end

--[[
suits - 被选中手牌中是否存在可用的百搭牌
参数：
1.手牌索引序列
2.使用标记
3.牌等级
4.临时使用标记
]]
function CardViewExLogic:suits(selecs, used, lv, tused)
	local s = 3 * 16 + lv
	local ts = {}

	for i = 1, #selecs do
		local c = self:getByidx(selecs[i])

		if c == s and not used[selecs[i]] and not tused[selecs[i]] then table.insert(ts, selecs[i]) end
	end
	return ts
end

--[[
getCardSize - 获取手牌总数
]]
function CardViewExLogic:getCardSize()
	local s = 0
	for i = 1, #self.cardDatas do
		s = s + #self.cardDatas[i]
	end
	return s
end

--[[
getCardsIndices - 根据手牌获取所在索引位置
参数：
1.cards - 指定手牌序列
返回：
返回命中的位置索引table
]]
function CardViewExLogic:getCardsIndices(cards)
	if not cards or #cards == 0 then return {} end

	local function search(c, used)
		local s = 0
		for i = 1, #self.cardDatas do
			local subcard = self.cardDatas[i]
			for j = 1, #subcard do
				if subcard[j] == c and not used[s + j] then return s + j end
			end
			s = s + #subcard
		end
	end
	local tc = {}
	local used = {}
	for i = 1, #cards do
		local p = search(cards[i], used)
		if p then
			table.insert(tc, p)
			used[p] = true
		end
	end
	return tc
end

------------------------------------------------------------------------------------------------------------------------------
-- 华丽分割线

--[[
normalise - 规整化手牌数据
参数：
1.待规整的手牌数据
2.当前级牌
]]
function CardViewExLogic:normalise(cards, lv)
	if not cards then return end

	self.cardDatas = {}
	self:resetThs()
	self:resetHint()

	for _, c in pairs(cards) do
		local cv = c % 16

		if cv == 1 or cv == 14 or cv == 15 or cv == lv then
			cv = cv + 16
		end

		local n = CardViewExLogic:nums(self.cardDatas)
		if n == 0 then
			table.insert(self.cardDatas, { c })
		else
			for i = 1, n do
				local scv = self.cardDatas[i][1] % 16
				if scv == 1 or scv == 14 or scv == 15 or scv == lv then
					scv = scv + 16
				end

				if cv == scv then
					table.insert(self.cardDatas[i], c) -- insert into exist vertical list
					break
				elseif i == 1 and cv > scv then
					table.insert(self.cardDatas, 1, { c }) -- insert a new vertical list into first pos
					break
				elseif i == n and cv < scv then
					table.insert(self.cardDatas, { c }) -- insert a new vertical list into last pos
					break
				elseif cv < scv then
					local lscv = self.cardDatas[i+1][1] % 16
					if lscv == 1 or lscv == 14 or lscv == 15 or lscv == lv then
						lscv = lscv + 16
					end
					if cv > lscv then
						table.insert(self.cardDatas, i + 1, { c }) -- insert a new vertical list between i and i + 1 pos to be new i + 1
						break
					end
				end
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------
--[[
arrange - 理牌
参数：
1.选择的手牌位置索引
2.牌等级
]]
function CardViewExLogic:arrange(selecs, lv)
	self:resetHint()

	local used = {}

	local kings = self:has4king(selecs, used, lv)
	local ths1 = self:thsAll(selecs, used, lv, 1)
	local ths2 = self:thsAll(selecs, used, lv, 2)
	local bombs = self:bombAll(selecs, used, lv)

	-- Dump Information after arrange -----------------------------------------------------------------------------
	-- beautiful split line
	local kingval = {}
	if kings then
		local str = 'King idx: { '
		for i = 1, #kings do
			local c = self:getByidx(kings[i])
			str = string.format('%s %d(%d %d)', str, kings[i], c%16, math.floor(c/16))

			table.insert(kingval, c)
		end
		print(str .. ' }')
	else
		print('King is nil')
	end
	local ths1val = {}
	if ths1 then
		local str = 'Ths1 idx: {\n'
		for i = 1, #ths1 do
			str = string.format('%s %d: {', str, i)
			local subths = {}
			local subs = ths1[i]
			for j = 1, #subs do
				local c = self:getByidx(subs[j])
				str = string.format('%s %d(%d %d)', str, subs[j], c%16, math.floor(c/16))

				table.insert(subths, c)
			end
			str = string.format('%s}\n', str)

			table.insert(ths1val, subths)
		end
		print(str .. '}')
	else
		print('Ths1 is nil')
	end
	local ths2val = {}
	if ths2 then
		local str = 'Ths2 idx: {\n'
		for i = 1, #ths2 do
			str = string.format('%s %d: {', str, i)
			local subths = {}
			local subs = ths2[i]
			for j = 1, #subs do
				local c = self:getByidx(subs[j])
				str = string.format('%s %d(%d %d)', str, subs[j], c%16, math.floor(c/16))

				table.insert(subths, c)
			end
			str = string.format('%s}\n', str)

			table.insert(ths2val, subths)
		end
		print(str .. '}')
	else
		print('Ths2 is nil')
	end
	local bombval = {}
	if bombs then
		local str = 'Bomb idx: {\n'
		for i = 1, #bombs do
			str = string.format('%s %d: {', str, i)
			local subbomb = {}
			local subs = bombs[i]
			for j = 1, #subs do
				local c = self:getByidx(subs[j])
				str = string.format('%s %d(%d %d)', str, subs[j], c%16, math.floor(c/16))

				table.insert(subbomb, c)
			end
			str = string.format('%s}\n', str)

			table.insert(bombval, subbomb)
		end
		print(str .. '}')
	else
		print('Bomb is nil')
	end
	-----------------------------------------------------------------------------------------------------------------
	-- beautiful split line

	local sn = #kingval
	for i = 1, #ths1val do -- add ths1 cards size
		sn = sn + #ths1[i]
	end
	for i = 1, #ths2val do -- add ths2 cards size
		sn = sn + #ths2[i]
	end
	for i = 1, #bombval do -- add bombs cards size
		sn = sn + #bombs[i]
	end

	if sn == #selecs then
		self:rmByIndices(selecs)

		local b = 0
		-- insert bombs whose count <= 5
		for i = #bombval, 1, -1 do
			if #bombval[i] <= 5 then table.insert(self.cardDatas, 1, bombval[i])
			else
				b = i
				break
			end
		end
		-- insert ths1val
		for i = #ths1val, 1, -1 do
			table.insert(self.cardDatas, 1, ths1val[i])
		end
		-- insert ths2val
		for i = #ths2val, 1, -1 do
			table.insert(self.cardDatas, 1, ths2val[i])
		end
		-- insert bombs whose count > 5
		for i = b, 1, -1 do
			table.insert(self.cardDatas, 1, bombval[i])
		end
		-- insert fourking
		if #kingval == 4 then
			table.insert(self.cardDatas, 1, kingval)
		end
	else
		local st = self:sortAll(selecs, lv)

		self:rmByIndices(selecs)
		table.insert(self.cardDatas, st)

		-- Dump Information after arrange -----------------------------------------------------------------------------
		-- beautiful split line
		local str = 'Sort list { '
		for i = 1, #st do
			local c = st[i]
			str = string.format('%s %d(%d %d)', str, selecs[i], c%16, math.floor(c/16))
		end
		print(str .. ' }')
	end

	print('After arrange card ====================================>')
	self:dumpInfo()
end

--[[
overlappedCard - 获得重叠的位置索引
参数：
1.选择的手牌位置索引
返回：
1.重叠的牌的数量
]]
function CardViewExLogic:overlappedCard(selecs)
	local overlapped = 0
	for i = 1, #selecs do
		for j = i + 1, #selecs do
			if selecs[i] == selecs[j] then overlapped = overlapped + 1 end
		end
	end
	return overlapped
end


--[[
fourking - 被选择的手牌中是否存在4王炸
参数：
1.选择的手牌索引
2.使用标记
3.牌等级
]]
function CardViewExLogic:has4king(selecs, used, lv)
	local kings = {}

	for k, v in pairs(selecs) do
		local c = self:getByidx(v)

		if c == 0X5E or c == 0X5F then table.insert(kings, v) end
	end

	if #kings == 4 then
		for i = 1, 4 do
			used[kings[i]] = true
		end

		local str = 'has4king used : { '
		for _k, _v in pairs(used) do
			str = string.format('%s %d', str, _k)
		end
		print(str .. ' }')

		return kings
	end
end

--[[
thsAll - 被选择的手牌中所有同花顺（百搭牌不可重复使用）
参数：
1.选择的手牌索引
2.使用标记
3.牌等级
4.使用的最大百搭牌的数量，最高为2
]]
function CardViewExLogic:thsAll(selecs, used, lv, maxs)
	local ths = {}

	local str = 'thsAll cards: { '
	local scs = {}
	for i = 1, #selecs do
		local c = self:getByidx(selecs[i])
		table.insert(scs, c)

		str = string.format('%s %d(%d %d)', str, c, c%16, math.floor(c/16))
	end
	print(str .. ' }')

	local function search(c, tused)
		for i = 1, #scs do
			local idx = selecs[i]
			if c == scs[i] and not used[idx] and not tused[idx] then
				return selecs[i]
			end
		end
	end

	local tmax = maxs
	for v = 14, 5, -1 do
		for col = 1, 4 do
			local nlost = 0
			local tused = {}

			for sv = v, v - 4, -1 do
				if sv == 14 then sv = 1 end
				local c = sv + col * 16

				local ret = search(c, tused)
				if ret then
					tused[ret] = true
				else
					nlost = nlost + 1
				end -- end of if
			end -- end of for

			local ts = self:suits(selecs, used, lv, tused)
			maxs = tmax
			if maxs > #ts then maxs = #ts end
			if nlost <= maxs then
				local subth = {}

				local s = 1
				for sv = v - 4, v do
					if sv == 14 then sv = 1 end
					local find = false

					for _k, _v in pairs(tused) do
						if self:getByidx(_k)%16 == sv then
							table.insert(subth, _k)
							used[_k] = true

							find = true
							break
						end
					end

					if not find then
						table.insert(subth, ts[s])
						used[ts[s]] = true
						s = s + 1
					end
				end

				-- for _k, _v in pairs(tused) do
					-- table.insert(subth, _k)
					-- used[_k] = true
				-- end
				-- for i = 1, nlost do
					-- table.insert(subth, ts[i])
					-- used[ts[i]] = true
				-- end

				table.insert(ths, subth)
			end -- end of if
		end -- end color for
	end -- end value for

	--[[
	if #ths > 0 then
		-- sort all ths
		table.sort(ths,	function (a, b)
							local ca = self:getByidx(a[1])%16
							local cb = self:getByidx(b[1])%16
							for i = 1, #a do
								local c = self:getByidx(a[i])
								if c%16 ~= lv and math.floor(c/16) ~= 3 then
									ca = c%16 + (i - 1)
								end
							end
							for i = 1, #b do
								local c = self:getByidx(b[i])
								if c%16 ~= lv and math.floor(c/16) ~= 3 then
									cb = c%16 + (i - 1)
								end
							end

							return a > b
						end
						)
	end
	--]]

	return ths
end

--[[
bombAll - 被选择的手牌中所有炸弹（百搭牌不可重复使用）
参数：
1.选择的手牌索引
2.使用标记
3.牌等级
]]
function CardViewExLogic:bombAll(selecs, used, lv)
	local bombs = {}

	local str = 'bombAll selecs cards: { '
	local scs = {}
	for i = 1, #selecs do
		local c = self:getByidx(selecs[i])
		table.insert(scs, c)

		str = string.format('%s %d', str, c)
	end
	print(str .. ' }')

	local function search(c, tused)
		for i = 1, #selecs do
			local idx = selecs[i]
			if c == scs[i]%16 and not used[idx] and not tused[idx] then
				return selecs[i]
			end
		end
	end

	local s = 0
	for v = 14, 2, -1 do
		local nlost = 0
		local tused = {}

		if v == 14 then v = 1 end

		for t = 1, 8 do
			local c = v

			local ret = search(c, tused)
			if ret then
				tused[ret] = true
			else
				nlost = nlost + 1
			end
		end

		local ts = self:suits(selecs, used, lv, tused)
		if nlost <= 4 then
			local bomb = {}

			for _k, _v in pairs(tused) do
				table.insert(bomb, _k)
				used[_k] = true
			end

			table.insert(bombs, bomb)
			s = s + #bomb
		else
			nlost = nlost - 4

			if nlost <= #ts then
				local bomb = {}

				for _k, _v in pairs(tused) do
					table.insert(bomb, _k)
					used[_k] = true
				end
				for i = 1, nlost do
					table.insert(bomb, ts[i])
					used[ts[i]] = true
				end

				table.insert(bombs, bomb)
				s = s + #bomb
			end
		end

		if #selecs - s < 4 then break end
	end

	if #bombs > 0 then
		-- sort bombs
		table.sort(bombs, 	function (a, b)
								if #a == #b then
									local ca = self:getByidx(a[1])%16
									local cb = self:getByidx(b[1])%16
									if ca == 1 or ca == lv then ca = ca + 16 end
									if cb == 1 or cb == lv then cb = cb + 16 end

									return ca > cb
								else
									return #a > #b
								end
							end
							)
		-- if exist suits card then insert into max bomb
		local ts = self:suits(selecs, used, lv, {})
		for i = 1, #ts do
			table.insert(bombs[1], ts[i])
			used[ts[i]] = true
		end
	end

	-- Log bomb
	print('all bombs in selecs = {')
	for i = 1, #bombs do
		local subbombs = bombs[i]
		local str = string.format('  [%d] = {', i)
		for j = 1, #subbombs do
			local c = self:getByidx(subbombs[j])
			str = string.format('%s [%d](%d %d)', str, subbombs[j], math.floor(c/16), c%16)
		end
		print(str .. '}')
	end
	print('}')

	return bombs
end

--[[
sortAll - 升序排列被选择的手牌
参数：
1.选择的手牌索引
2.牌等级
]]
function CardViewExLogic:sortAll(selecs, lv)
	local ts = self:suits(selecs, {}, lv, {})

	table.sort(selecs, 	function (a, b)
							local ca = self:getByidx(a)%16
							local cb = self:getByidx(b)%16
							if ca == 15 or ca == 14 or ca == 1 or ca == lv then ca = ca + 16 end
							if cb == 15 or cb == 14 or cb == 1 or cb == lv then cb = cb + 16 end
							return ca < cb
						end
						)
	-- insert datas
	local t = {}
	for i = 1, #selecs do
		table.insert(t, self:getByidx(selecs[i]))
	end

	-- self:rmByIndices(selecs)
	-- table.insert(self.cardDatas, t)

	return t
end

--------------------------------------------------------------------------------------------------------------------------------------
--[[
pre4king - 获取当前手牌四王
参数：
1.牌等级
]]
function CardViewExLogic:pre4king()
	local kings = {}
	local sm = 0
	for i = 1, #self.cardDatas do
		local subcard = self.cardDatas[i]
		for j = 1, #subcard do
			if subcard[j] == 0x5e or subcard[j] == 0x5f then table.insert(kings, sm + j) end
		end
		sm = sm + #subcard
	end
	if #kings == 4 then return kings end
end
--[[
prebombs - 获取当前手牌所有的炸弹（百搭牌可重复使用）
参数：
1.牌等级
]]
function CardViewExLogic:prebombs(lv)
	local function search(c, used)
		local sm = 0
		for i = 1, #self.cardDatas do
			local subcard = self.cardDatas[i]
			for j = 1, #subcard do
				if subcard[j]%16 == c and not used[sm + j] then return sm + j end
			end
			sm = sm + #subcard
		end
	end

	local ts = self:suitsAll(lv, {})
	local bombs = {}

	for v = 14, 2, -1 do
		local nlost = 0
		local used = {}
		local tt = {}
		local added = false

		local sv = v
		if sv == 14 then sv = 1 end
		for t = 1, 8 do
			local ret = search(sv, used)
			if ret then
				used[ret] = true
				if self:isSuit(self:getByidx(ret), lv) then nlost = nlost + 1 end
				table.insert(tt, ret)
				-- if #tt >= 4 then table.insert(bombs, clone(tt)) end
			else
				if #tt >= 4 and not added then
					added = true
					table.insert(bombs, clone(tt))
				end
				nlost = nlost + 1
				if nlost <= #ts then
					used[ts[nlost]] = true
					table.insert(tt, ts[nlost])
					if #tt >= 4 then
						added = true
						table.insert(bombs, clone(tt))
					end
				end
			end
		end
	end

	-- sort bombs
	if #bombs > 0 then
		-- sort bombs
		table.sort(bombs, function (a, b)
							if #a == #b then
								local ca = self:getByidx(a[1])%16
								local cb = self:getByidx(b[1])%16
								if ca == 1 then ca = ca + 16 end
								if cb == 1 then cb = cb + 16 end
								if ca == lv then
									if cb == lv then return ca > cb
									else return ca + 16 > cb
									end
								elseif cb == lv then
									if ca == lv then return ca > cb
									else return ca > cb + 16
									end
								else return ca > cb
								end
							else return #a > #b
							end
						end)
	end

	-- log bombs
	print('pre bombs = {')
	for i = 1, #bombs do
		local subbomb = bombs[i]
		local str = string.format('  [%d] = {', i)
		for j = 1, #subbomb do
			local c = self:getByidx(subbomb[j])
			str = string.format('%s [%d](%d %d)', str, subbomb[j], math.floor(c/16), c%16)
		end
		print(str .. '}')
	end
	print('}')

	return bombs
end


--[[
preths - 获取当前手牌所有的同花顺（百搭牌可重复使用）
参数：
1.牌等级
]]
function CardViewExLogic:preths(lv)
	local function search(c, used)
		local sm = 0
		for i = 1, #self.cardDatas do
			local subdatas = self.cardDatas[i]
			for j = 1, #subdatas do
				if subdatas[j] == c and not used[sm + j] then return sm + j end
			end

			sm = sm + #subdatas
		end
	end

	local ts = self:suitsAll(lv, {})
	self.thsDatas = {}

	for v = 14, 5, -1 do
		for cl = 1, 4 do
			local nlost = 0
			local used = {}
			local tt = {}

			for sv = v, v - 4, -1 do
				if sv == 14 then sv = 1 end

				local c = cl * 16 + sv
				local ret = search(c, used)
				if ret then
					used[ret] = true
					if self:isSuit(c, lv) then nlost = nlost + 1 end
					table.insert(tt, ret)
				else
					nlost = nlost + 1
					if nlost <= #ts then
						used[ts[nlost]] = true
						table.insert(tt, ts[nlost])
					end
				end
			end

			if nlost == 0 or nlost <= #ts then
				table.insert(self.thsDatas, tt)
			end
		end
	end

	print('pre ths = {')
	for i = 1, #self.thsDatas do
		local str = '[' .. i .. '] = {'
		for j = 1, #self.thsDatas[i] do
			local c = self:getByidx(self.thsDatas[i][j])
			str = str .. '[' .. self.thsDatas[i][j] .. ']' .. c%16 .. ' ' .. math.floor(c/16) .. ', '
		end
		print(str .. '}')
	end
	print('}')

	return self.thsDatas
end

--[[
nextThs - 获取下一组同花顺
参数：
1.牌级
返回：
1.下一组同花顺数据
]]
function CardViewExLogic:nextThs(lv)
	self.thsIdx = self.thsIdx or 1
	if not self.thsDatas then self:preths(lv) end

	if #self.thsDatas == 0 then return {}
	else
		local ths = self.thsDatas[self.thsIdx]

		self.thsIdx = self.thsIdx + 1
		if self.thsIdx > #self.thsDatas then self.thsIdx = 1 end
		return ths
	end
end

--[[
resetThs - 清空预算出的同花顺【在牌型发生变化的时候 —— 包括理牌、出牌之后调用】
]]
function CardViewExLogic:resetThs()
	self.thsIdx = nil
	self.thsDatas = nil
end

--------------------------------------------------------------------------------------------------------------------------------------
-- 华丽分割线

--[[
牌型
]]
local Card_nil = -1
local Card_4King = 0
local Card_Ths = 1
local Card_Sz = 2
local Card_Bomb = 3
local Card_33 = 4
local Card_32 = 5
local Card_222 = 6
local Card_2 = 7
local Card_1 = 8
local Card_3 = 9
local Card_0 = 10

--[[
preSz - 获取所有的顺子
参数：
1.牌级
]]
function CardViewExLogic:preSz(lv)
	local function search(c, used)
		local sm = 0
		for i = 1, #self.cardDatas do
			local subdatas = self.cardDatas[i]
			for j = 1, #subdatas do
				if subdatas[j] % 16 == c and not used[sm + j] then return sm + j end
			end

			sm = sm + #subdatas
		end
	end

	local ts = self:suitsAll(lv, {})
	local tc = {}

	for v = 5, 14 do
		local nlost = 0
		local used = {}
		local tt = {}

		for sv = v, v - 4, -1 do
			if sv == 14 then sv = 1 end

			local ret = search(sv, used)
			if ret then
				used[ret] = true
				if self:isSuit(self:getByidx(ret), lv) then nlost = nlost + 1 end
				table.insert(tt, ret)
			else
				nlost = nlost + 1
				if nlost <= #ts then
					used[ts[nlost]] = true
					table.insert(tt, ts[nlost])
				end
			end
		end

		if nlost == 0 or nlost <= #ts then
			table.insert(tc, tt)
		end
	end
	return tc
end

--[[
pre33 - 获取所有的钢板
参数：
1.牌级
]]
function CardViewExLogic:pre33(lv)
	local function search(c, used)
		local sm = 0
		for i = 1, #self.cardDatas do
			local subdatas = self.cardDatas[i]
			for j = 1, #subdatas do
				if subdatas[j] % 16 == c and not used[sm + j] then return sm + j end
			end

			sm = sm + #subdatas
		end
	end

	local ts = self:suitsAll(lv, {})
	local tc = {}

	for v = 2, 14 do
		local nlost = 0
		local used = {}
		local tt = {}

		for sv = v, v - 1, -1 do
			if sv == 14 then sv = 1 end

			for t = 1, 3 do
				local ret = search(sv, used)
				if ret then
					used[ret] = true
					if self:isSuit(self:getByidx(ret), lv) then nlost = nlost + 1 end
					table.insert(tt, ret)
				else
					nlost = nlost + 1
					if nlost <= #ts then
						used[ts[nlost]] = true
						table.insert(tt, ts[nlost])
					end
				end
			end
		end

		if nlost == 0 or nlost <= #ts then
			table.insert(tc, tt)
		end
	end
	return tc
end

--[[
pre32 - 获取所有的三带二
参数：
1.牌级
]]
function CardViewExLogic:pre32(lv)
	local function search(c, used)
		local sm = 0
		for i = 1, #self.cardDatas do
			local subdatas = self.cardDatas[i]
			for j = 1, #subdatas do
				if subdatas[j] % 16 == c and not used[sm + j] then return sm + j end
			end

			sm = sm + #subdatas
		end
	end

	local ts = self:suitsAll(lv, {})
	local tc = {}

	for v = 2, 14 do
		local sv = v
		if sv == 14 then sv = 1 end

		local nlost = 0
		local used = {}
		local tt = {}

		for t = 1, 3 do
			local ret = search(sv, used)
			if ret then
				used[ret] = true
				if self:isSuit(self:getByidx(ret), lv) then nlost = nlost + 1 end
				table.insert(tt, ret)
			else
				nlost = nlost + 1
				if nlost <= #ts then
					used[ts[nlost]] = true
					table.insert(tt, ts[nlost])
				end
			end
		end

		for _v = 1, 15 do
			local _sv = _v
			-- if _sv == 14 then _sv = 1 end

			if _sv ~= sv then
				local tlost = nlost
				local tused = clone(used)
				local ttt = clone(tt)

				for _t = 1, 2 do
					local ret = search(_sv, tused)
					if ret then
						tused[ret] = true
						if self:isSuit(self:getByidx(ret), lv) then tlost = tlost + 1 end
						table.insert(ttt, ret)
					else
						tlost = tlost + 1
						if tlost <= #ts then
							used[ts[tlost]] = true
							table.insert(ttt, ts[tlost])
						end
					end
				end

				if tlost == 0 or tlost <= #ts then
					table.insert(tc, ttt)
				end
			end
		end
	end

	return tc
end

--[[
pre3 - 获取所有的三张
参数：
1.牌级
]]
function CardViewExLogic:pre3(lv)
	local function search(c, used)
		local sm = 0
		for i = 1, #self.cardDatas do
			local subdatas = self.cardDatas[i]
			for j = 1, #subdatas do
				if subdatas[j] % 16 == c and not used[sm + j] then return sm + j end
			end

			sm = sm + #subdatas
		end
	end

	local ts = self:suitsAll(lv, {})
	local tc = {}

	for v = 2, 14 do
		local sv = v
		if sv == 14 then sv = 1 end

		local nlost = 0
		local used = {}
		local tt = {}

		for t = 1, 3 do
			local ret = search(sv, used)
			if ret then
				used[ret] = true
				if self:isSuit(self:getByidx(ret), lv) then nlost = nlost + 1 end
				table.insert(tt, ret)
			else
				nlost = nlost + 1
				if nlost <= #ts then
					used[ts[nlost]] = true
					table.insert(tt, ts[nlost])
				end
			end
		end

		if nlost == 0 or nlost <= #ts then table.insert(tc, tt) end
	end
	return tc
end

--[[
pre222 - 获取所有的三连对
参数：
1.牌级
]]
function CardViewExLogic:pre222(lv)
	local function search(c, used)
		local sm = 0
		for i = 1, #self.cardDatas do
			local subdatas = self.cardDatas[i]
			for j = 1, #subdatas do
				if subdatas[j] % 16 == c and not used[sm + j] then return sm + j end
			end

			sm = sm + #subdatas
		end
	end

	local ts = self:suitsAll(lv, {})
	local tc = {}

	for v = 3, 14 do
		local nlost = 0
		local used = {}
		local tt = {}

		for sv = v, v - 2, -1 do
			if sv == 14 then sv = 1 end
			for t = 1, 2 do
				local ret = search(sv, used)
				if ret then
					used[ret] = true
					if self:isSuit(self:getByidx(ret), lv) then nlost = nlost + 1 end
					table.insert(tt, ret)
				else
					nlost = nlost + 1
					if nlost <= #ts then
						used[ts[nlost]] = true
						table.insert(tt, ts[nlost])
					end
				end
			end
		end

		if nlost == 0 or nlost <= #ts then table.insert(tc, tt) end
	end
	return tc
end

--[[
pre2 - 获取所有的对牌
参数：
1.牌级
]]
function CardViewExLogic:pre2(lv)
	local function search(c, used)
		local sm = 0
		for i = 1, #self.cardDatas do
			local subdatas = self.cardDatas[i]
			for j = 1, #subdatas do
				if subdatas[j] % 16 == c and not used[sm + j] then return sm + j end
			end

			sm = sm + #subdatas
		end
	end

	local ts = self:suitsAll(lv, {})
	local tc = {}

	for v = 1, 13 do
		local sv = v

		local nlost = 0
		local used = {}
		local tt = {}

		for t = 1, 2 do
			local ret = search(sv, used)
			if ret then
				used[ret] = true
				if self:isSuit(self:getByidx(ret), lv) then nlost = nlost + 1 end
				table.insert(tt, ret)
			else
				nlost = nlost + 1
				if nlost <= #ts then
					used[ts[nlost]] = true
					table.insert(tt, ts[nlost])
				end
			end
		end

		if nlost == 0 or nlost <= #ts then table.insert(tc, tt) end
	end

	for v = 14, 15 do
		local nlost = 0
		local used = {}
		local tt = {}

		for t = 1, 2 do
			local ret = search(v, used)
			if ret then
				used[ret] = true
				table.insert(tt, ret)
			else nlost = nlost + 1
			end
		end

		if nlost == 0 then table.insert(tc, tt) end
	end

	return tc
end

--[[
pre1 - 获取所有的单牌
参数：
1.牌级
]]
function CardViewExLogic:pre1(lv)
	local function search(c, cmpt)
		local sm = 0
		for i = 1, #self.cardDatas do
			local subDatas = self.cardDatas[i]

			for j = 1, #subDatas do
				sm = sm + 1
				if not cmpt then
					if c == subDatas[j]%16 then return sm end
				else
					if c == subDatas[j] then return sm end
				end
			end
		end
	end

	local tc = {}
	for v = 2, 14 do
		if v == 14 then v = 1 end

		if lv ~= v then
			local ret = search(v)
			if ret then table.insert(tc, { ret }) end
		end
	end

	local ret = search(3 * 16 + lv, true)
	if ret then table.insert(tc, { ret })
	else
		ret = search(lv)
		if ret then table.insert(tc, { ret }) end
	end
	local ret = search(0x5e, true)
	if ret then table.insert(tc, { ret }) end
	local ret = search(0x5f, true)
	if ret then table.insert(tc, { ret }) end

	return tc;
end

--[[
cmpCards - 比较牌大小
参数：
1.待比较的牌序列1
2.待比较的牌序列2
3.牌型
4.牌级
5.参数1是否为手牌
]]
function CardViewExLogic:cmpCards(cardsIndices, cards, cardType, lv, isCards)
	local function cmpc(a, b, notCmplv)
		local va = a%16
		local vb = b%16
		if va == 1 or va == 14 or va == 15 then va = va + 16 end
		if vb == 1 or vb == 14 or vb == 15 then vb = vb + 16 end

		if va == lv and not notCmplv then
			if b == 0x5e or b == 0x5f then return -1
			elseif vb == lv then return 0
			else return 1
			end
		elseif vb == lv and not notCmplv then
			if a == 0x5e or a == 0x5f then return 1
			elseif va == lv then return 0
			else return -1
			end
		else
			return va - vb
		end
	end

	if cardType == Card_1 then
		local c = self:getByidx(cardsIndices[1])
		if isCards then c = cardsIndices[1] end -- TODO
		return cmpc(c, cards[1])
	elseif cardType == Card_Bomb then
		if #cardsIndices > #cards then return 1
		elseif #cardsIndices < #cards then return 0
		end

		local c = nil
		for i = 1, #cardsIndices do
			local cc = self:getByidx(cardsIndices[i])
			if isCards then cc = cardsIndices[i] end -- TODO
			if not self:isSuit(cc, lv) then c = cc end
		end
		local c1 = nil
		for i = 1, #cards do
			if not self:isSuit(cards[i], lv) then c1 = cards[i] end
		end

		return cmpc(c, c1)
	elseif cardType == Card_Ths then
		local c = 0
		for i = 1, #cardsIndices do
			local cc = self:getByidx(cardsIndices[i])
			if isCards then cc = cardsIndices[i] end -- TODO
			if not self:isSuit(cc, lv) then
				c = cc%16 + c
				if c == 14 then c = 1 end
				break
			else c = c + 1
			end
		end
		c = c + 16

		local c1 = 0
		self:isThs(cards, lv)
		for i = 1, #cards do
			if not self:isSuit(cards[i], lv) then
				c1 = c1 + cards[i]%16
				if c1 == 14 then c1 = 1 end
				break
			else c1 = c1 + 1
			end
		end
		c1 = c1 + 16

		return cmpc(c, c1, true)
	elseif cardType == Card_Sz then
		local c = 0
		for i = 1, #cardsIndices do
			local cc = self:getByidx(cardsIndices[i])
			if isCards then cc = cardsIndices[i] end -- TODO
			if not self:isSuit(cc, lv) then
				c = cc%16 + c
				if c == 14 then c = 1 end
				break
			else c = c + 1
			end
		end
		c = c + 16

		local c1 = 0
		self:isSz(cards, lv)
		for i = 1, #cards do
			if not self:isSuit(cards[i], lv) then
				c1 = c1 + cards[i]%16
				if c1 == 14 then c1 = 1 end
				break
			else c1 = c1 + 1
			end
		end
		c1 = c1 + 16

		return cmpc(c, c1, true)
	elseif cardType == Card_33 then
		local c = 0
		for i = 1, #cardsIndices do
			local cc = self:getByidx(cardsIndices[i])
			if isCards then cc = cardsIndices[i] end
			if not self:isSuit(cc, lv) then
				c = cc
				break
			end
		end

		local c1 = 0
		self:is33(cards, lv)
		for i = 1, #cards do
			if not self:isSuit(cards[i], lv) then
				c1 = c1 + cards[i]%16
				if c1 == 14 then c1 = 1 end
				break
			else c1 = c1 + 1
			end
		end
		c1 = c1 + 16

		return cmpc(c, c1, true)
	elseif cardType == Card_32 then
		local c = nil
		for i = 1, #cardsIndices do
			local cc = self:getByidx(cardsIndices[i])
			if isCards then cc = cardsIndices[i] end
			if not self:isSuit(cc, lv) then
				c = cc
				break
			end
		end

		local c1 = 0
		self:is32(cards, lv)
		for i = 1, #cards do
			if not self:isSuit(cards[i], lv) then
				c1 = c1 + cards[i]%16
				if c1 == 14 then c1 = 1 end
				break
			else c1 = c1 + 1
			end
		end
		c1 = c1 + 16

		return cmpc(c, c1)
	elseif cardType == Card_3 then
		local c = nil
		for i = 1, #cardsIndices do
			local cc = self:getByidx(cardsIndices[i])
			if isCards then cc = cardsIndices[i] end
			if not self:isSuit(cc, lv) then
				c = cc
				break
			end
		end

		local c1 = nil
		for i = 1, #cards do
			if not self:isSuit(cards[i], lv) then
				c1 = cards[i]
				break
			end
		end

		return cmpc(c, c1)
	elseif cardType == Card_2 then
		local c = self:getByidx(cardsIndices[1])
		if isCards then c = cardsIndices[1] end

		local ts = {}
		local tc = {}
		for i = 1, #cards do
			if self:isSuit(cards[i], lv) then table.insert(ts, cards[i])
			else table.insert(tc, cards[i])
			end
		end

		local c1 = nil
		if #tc > 0 then c1 = tc[1]
		else c1 = ts[1]
		end

		return cmpc(c, c1)
	elseif cardType == Card_222 then
		local c = 0
		for i = 1, #cardsIndices do
			local cc = self:getByidx(cardsIndices[i])
			if isCards then cc = cardsIndices[i] end
			if not self:isSuit(cc, lv) then
				if c == 1 or c == 0 then
					c = cc
				else
					local t = cc
					if t%16 == 13 then c = math.floor(t/16) * 16 + 1
					else c = t + 1
					end
				end
				break
			else c = c + 1
			end
		end

		local c1 = 0
		self:is222(cards, lv)
		for i = 1, #cards do
			if not self:isSuit(cards[i], lv) then
				c1 = c1 + cards[i]%16
				if c1 == 14 then c1 = 1 end
				break
			else c1 = c1 + 1
			end
		end
		c1 = c1 + 16

		return cmpc(c, c1, true)
	end
end

--[[
cardsType - 获取牌型
参数：
1.手牌数据
2.牌级
]]
function CardViewExLogic:cardsType(cards, lv)
	if not cards then return Card_nil end

	if #cards == 0 then return Card_0
	elseif #cards == 1 then return Card_1
	elseif self:isFourKing(cards) then return Card_4King
	elseif self:isThs(cards, lv) then return Card_Ths
	elseif self:isBomb(cards, lv) then return Card_Bomb
	elseif self:isSz(cards, lv) then return Card_Sz
	elseif self:is33(cards, lv) then return Card_33
	elseif self:is32(cards, lv) then return Card_32
	elseif self:is3(cards, lv) then return Card_3
	elseif self:is222(cards, lv) then return Card_222
	elseif self:is2(cards, lv) then return Card_2
	end
	return Card_nil
end

--[[
preHint - 预处理合法的提示牌
参数：
1.待比对的手牌
2.牌级
]]
function CardViewExLogic:preHint(cards, lv, ctyp)
	if not cards then return end

	local str = 'compare cards = {'
	for i = 1, #cards do
		str = string.format('%s %d', str, cards[i])
	end
	print(str .. '}')

	self.hintDatas = {}
	self.hintIdx = 1

	if self:isFourKing(cards) then
		print('Cards is 4 king')
		-- Do nothing
	else
		self:preths(lv)
		local bombs = self:prebombs(lv)
		local fk = self:pre4king()
		bombs = bombs or {}
		fk = fk or {}

		if #cards == 0 then
			print('Cards is 0')
			local tc = self:pre1(lv)
			for i = 1, #tc do table.insert(self.hintDatas, tc[i]) end -- card_1
			tc = self:pre2(lv)
			for i = 1, #tc do table.insert(self.hintDatas, tc[i]) end -- card_2
			tc = self:pre222(lv)
			for i = 1, #tc do table.insert(self.hintDatas, tc[i]) end -- card_222
			tc = self:pre3(lv)
			for i = 1, #tc do table.insert(self.hintDatas, tc[i]) end -- card_3
			tc = self:pre32(lv)
			for i = 1, #tc do table.insert(self.hintDatas, tc[i]) end -- card_32
			tc = self:pre33(lv)
			for i = 1, #tc do table.insert(self.hintDatas, tc[i]) end -- card_33
			tc = self:preSz(lv)
			for i = 1, #tc do table.insert(self.hintDatas, tc[i]) end -- card_sz

			local b = 0
			for i = #bombs, 1, -1 do
				if #bombs[i] <= 5 then
					table.insert(self.hintDatas, bombs[i])	-- bomb <= 5
				else
					b = i
					break
				end
			end
			for i = #self.thsDatas, 1, -1 do
				table.insert(self.hintDatas, self.thsDatas[i])	-- ths
			end
			for i = b, 1, -1 do
				table.insert(self.hintDatas, bombs[i])	-- bomb >= 6
			end
			if #fk == 4 then table.insert(self.hintDatas, fk) end	-- 4 king

		elseif #cards == 1 then
			print('Cards is 1')
			local tc = self:pre1(lv)

			for i = 1, #tc do
				if self:cmpCards(tc[i], cards, Card_1, lv) > 0 then table.insert(self.hintDatas, tc[i]) end
			end
			local b = 0
			for i = #bombs, 1, -1 do
				if #bombs[i] <= 5 then
					table.insert(self.hintDatas, bombs[i])
				else
					b = i
					break
				end
			end
			for i = #self.thsDatas, 1, -1 do
				table.insert(self.hintDatas, self.thsDatas[i])
			end
			for i = b, 1, -1 do
				table.insert(self.hintDatas, bombs[i])
			end
			if #fk == 4 then table.insert(self.hintDatas, fk) end
		elseif self:isThs(cards, lv) then
			print('Cards is Ths')

			for i = #self.thsDatas, 1, -1 do
				if self:cmpCards(self.thsDatas[i], cards, Card_Ths, lv) > 0 then table.insert(self.hintDatas, self.thsDatas[i]) end
			end
			for i = #bombs, 1, -1 do
				if #bombs[i] >= 6 then table.insert(self.hintDatas, bombs[i]) end
			end
			if #fk == 4 then table.insert(self.hintDatas, fk) end
		elseif self:isBomb(cards, lv) then
			print('Cards is Bomb')

			for i = #bombs, 1, -1 do
				if self:cmpCards(bombs[i], cards, Card_Bomb, lv) > 0 then table.insert(self.hintDatas, bombs[i]) end
			end

			if #cards <= 5 then
				for i = #self.thsDatas, 1, -1 do
					table.insert(self.hintDatas, self.thsDatas[i])
				end
			end

			if #fk == 4 then table.insert(self.hintDatas, fk) end
		elseif self:isSz(cards, lv) then
			print('Cards is Sz')
			local tc = self:preSz(lv)

			print('pre hints = {')
			for i = 1, #tc do
				local str = string.format('%d : {', i)
				local subt = tc[i]
				for j = 1, #subt do
					local c = self:getByidx(subt[j])
					str = string.format('%s [%d](%d %d)', str, subt[j], c%16, math.floor(c/16))
				end
				print(str .. '}')
			end
			print('}')

			for i = 1, #tc do
				if self:cmpCards(tc[i], cards, Card_Sz, lv) > 0 then table.insert(self.hintDatas, tc[i]) end
			end

			local b = 0
			for i = #bombs, 1, -1 do
				if #bombs[i] <= 5 then
					table.insert(self.hintDatas, bombs[i])
				else
					b = i
					break
				end
			end
			for i = #self.thsDatas, 1, -1 do
				table.insert(self.hintDatas, self.thsDatas[i])
			end
			for i = b, 1, -1 do
				table.insert(self.hintDatas, bombs[i])
			end
			if #fk == 4 then table.insert(self.hintDatas, fk) end
		elseif self:is33(cards, lv) then
			if ctyp == Card_222 then
				print('Cards is 222')
				local tc = self:pre222(lv)

				for i = 1, #tc do
					if self:cmpCards(tc[i], cards, Card_222, lv) > 0 then table.insert(self.hintDatas, tc[i]) end
				end

				local b = 0
				for i = #bombs, 1, -1 do
					if #bombs[i] <= 5 then
						table.insert(self.hintDatas, bombs[i])
					else
						b = i
						break
					end
				end
				for i = #self.thsDatas, 1, -1 do
					table.insert(self.hintDatas, self.thsDatas[i])
				end
				for i = b, 1, -1 do
					table.insert(self.hintDatas, bombs[i])
				end
				if #fk == 4 then table.insert(self.hintDatas, fk) end
			else
				print('Cards is 33')
				local tc = self:pre33(lv)

				for i = 1, #tc do
					if self:cmpCards(tc[i], cards, Card_33, lv) > 0 then table.insert(self.hintDatas, tc[i]) end
				end

				local b = 0
				for i = #bombs, 1, -1 do
					if #bombs[i] <= 5 then
						table.insert(self.hintDatas, bombs[i])
					else
						b = i
						break
					end
				end
				for i = #self.thsDatas, 1, -1 do
					table.insert(self.hintDatas, self.thsDatas[i])
				end
				for i = b, 1, -1 do
					table.insert(self.hintDatas, bombs[i])
				end
				if #fk == 4 then table.insert(self.hintDatas, fk) end
			end
		elseif self:is32(cards, lv) then
			print('Cards is 32')
			local tc = self:pre32(lv)

			for i = 1, #tc do
				if self:cmpCards(tc[i], cards, Card_32, lv) > 0 then table.insert(self.hintDatas, tc[i]) end
			end

			local b = 0
			for i = #bombs, 1, -1 do
				if #bombs[i] <= 5 then
					table.insert(self.hintDatas, bombs[i])
				else
					b = i
					break
				end
			end
			for i = #self.thsDatas, 1, -1 do
				table.insert(self.hintDatas, self.thsDatas[i])
			end
			for i = b, 1, -1 do
				table.insert(self.hintDatas, bombs[i])
			end
			if #fk == 4 then table.insert(self.hintDatas, fk) end
		elseif self:is3(cards, lv) then
			print('Cards is 3')
			local tc = self:pre3(lv)

			for i = 1, #tc do
				if self:cmpCards(tc[i], cards, Card_3, lv) > 0 then table.insert(self.hintDatas, tc[i]) end
			end

			local b = 0
			for i = #bombs, 1, -1 do
				if #bombs[i] <= 5 then
					table.insert(self.hintDatas, bombs[i])
				else
					b = i
					break
				end
			end
			for i = #self.thsDatas, 1, -1 do
				table.insert(self.hintDatas, self.thsDatas[i])
			end
			for i = b, 1, -1 do
				table.insert(self.hintDatas, bombs[i])
			end
			if #fk == 4 then table.insert(self.hintDatas, fk) end
		elseif self:is222(cards, lv) then
			print('Cards is 222')
			local tc = self:pre222(lv)

			for i = 1, #tc do
				if self:cmpCards(tc[i], cards, Card_222, lv) > 0 then table.insert(self.hintDatas, tc[i]) end
			end

			local b = 0
			for i = #bombs, 1, -1 do
				if #bombs[i] <= 5 then
					table.insert(self.hintDatas, bombs[i])
				else
					b = i
					break
				end
			end
			for i = #self.thsDatas, 1, -1 do
				table.insert(self.hintDatas, self.thsDatas[i])
			end
			for i = b, 1, -1 do
				table.insert(self.hintDatas, bombs[i])
			end
			if #fk == 4 then table.insert(self.hintDatas, fk) end
		elseif self:is2(cards, lv) then
			print('Cards is 2')
			local tc = self:pre2(lv)

			for i = 1, #tc do
				if self:cmpCards(tc[i], cards, Card_2, lv) > 0 then table.insert(self.hintDatas, tc[i]) end
			end

			local b = 0
			for i = #bombs, 1, -1 do
				if #bombs[i] <= 5 then
					table.insert(self.hintDatas, bombs[i])
				else
					b = i
					break
				end
			end
			for i = #self.thsDatas, 1, -1 do
				table.insert(self.hintDatas, self.thsDatas[i])
			end
			for i = b, 1, -1 do
				table.insert(self.hintDatas, bombs[i])
			end
			if #fk == 4 then table.insert(self.hintDatas, fk) end
		end
	end

	print('hints = {')
	for i = 1, #self.hintDatas do
		local str = string.format('%d : {', i)
		local subt = self.hintDatas[i]
		for j = 1, #subt do
			local c = self:getByidx(subt[j])
			str = string.format('%s [%d](%d %d)', str, subt[j], c%16, math.floor(c/16))
		end
		print(str .. '}')
	end
	print('}')
end

--[[
nextHint - 获取下一组合法的牌
参数：
1.待比对的手牌
返回：
1.下一组合法可出的牌table，如不存在则返回空表
2.牌级
]]
function CardViewExLogic:nextHint(cards, lv, ctyp)
	if not self.hintDatas then self:preHint(cards, lv, ctyp) end

	if #self.hintDatas == 0 then return {}
	else
		local hints = self.hintDatas[self.hintIdx]

		self.hintIdx = self.hintIdx + 1
		if self.hintIdx > #self.hintDatas then self.hintIdx = 1 end
		return hints
	end
end

--[[
resetHint - 重置提示手牌序列
]]
function CardViewExLogic:resetHint()
	self.hintIdx = nil
	self.hintDatas = nil
end

--------------------------------------------------------------------------------------------------------------------------------------

--[[
isFourKing - 判断是否为四王
参数：
1.手牌
]]
function CardViewExLogic:isFourKing(cards)
	if not cards or type(cards) ~= 'table' or #cards ~= 4 then return false end

	local cnt = 0
	for i = 1, #cards do
		if cards[i]%16 == 15 or cards[i]%16 == 14 then cnt = cnt + 1 end
	end

	if cnt == 4 then return true end
	return false
end

--[[
isThs - 是否为同花顺
参数：
1.手牌
2.牌级
]]
function CardViewExLogic:isThs(cards, lv)
	if not cards or type(cards) ~= 'table' or #cards ~= 5 then return false end

	local ts = {}
	local tc = {}
	for i = 1, #cards do
		if self:isSuit(cards[i], lv) then table.insert(ts, cards[i])
		else table.insert(tc, cards[i])
		end
	end

	table.sort(tc, function (a, b) return a%16 > b%16 end)

	local function hintsC(c, cs)
		for i = 1, #cs do
			if c == cs[i] then return true end
		end
		return false
	end

	local cl = math.floor(tc[1]/16)
	local cv = tc[1]%16
	for v = 14, 5, -1 do
		local nlost = 0
		local tt = {}

		for _v = v, v - 4, -1 do
			local sv = _v
			if sv == 14 then sv = 1 end

			local c = sv + cl * 16
			if not hintsC(c, tc) then
				nlost = nlost + 1
				if nlost <= #ts then table.insert(tt, ts[nlost]) end
			else
				table.insert(tt, c)
			end
		end

		if nlost == #ts then
			for i = #cards, 1, -1 do table.remove(cards, i) end
			for i = 1, #tt do table.insert(cards, tt[i]) end
			return true
		end
	end

	return false;
end

--[[
isSz - 是否为顺子
参数：
1.手牌
2.牌级
]]
function CardViewExLogic:isSz(cards, lv)
	if not cards or type(cards) ~= 'table' or #cards ~= 5 then return false end

	local ts = {}
	local tc = {}
	for i = 1, #cards do
		if self:isSuit(cards[i], lv) then table.insert(ts, i)
		else table.insert(tc, i)
		end
	end

	local function isHitCard(c, cs, used)
		for i = 1, #cs do
			if c == cards[cs[i]]%16 and not used[cs[i]] then return cs[i] end
		end
	end

	for v = 14, 5, -1 do
		local nlost = 0
		local used = {}
		local tt = {}

		for sv = v, v - 4, -1 do
			if sv == 14 then sv = 1 end

			local ret = isHitCard(sv, tc, used)
			if ret then
				used[ret] = true
				table.insert(tt, cards[ret])
			else
				nlost = nlost + 1
				if nlost <= #ts then table.insert(tt, cards[ts[nlost]]) end
			end
		end

		if nlost == #ts then
			for i = #cards, 1, -1 do table.remove(cards, i) end
			for i = 1, #tt do table.insert(cards, tt[i]) end
			return true
		end
	end
	return false
end

--[[
is33 - 是否为钢板
参数：
1.手牌
2.牌级
]]
function CardViewExLogic:is33(cards, lv)
	if not cards or type(cards) ~= 'table' or #cards ~= 6 then return false end

	local ts = {}
	local tc = {}
	for i = 1, #cards do
		if self:isSuit(cards[i], lv) then table.insert(ts, i)
		else table.insert(tc, i)
		end
	end

	local function isHitCard(c, cs, used)
		for i = 1, #cs do
			if c == cards[cs[i]]%16 and not used[cs[i]] then return cs[i] end
		end
	end

	for v = 14, 2, -1 do
		local nlost = 0
		local used = {}
		local tt = {}

		for sv = v, v - 1, -1 do
			if sv == 14 then sv = 1 end

			for i = 1, 3 do
				local ret = isHitCard(sv, tc, used)
				if ret then
					used[ret] = true
					table.insert(tt, cards[ret])
				else
					nlost = nlost + 1
					if nlost <= #ts then table.insert(tt, cards[ts[nlost]]) end
				end
			end
		end

		if nlost == 0 or nlost == #ts then
			for i = #cards, 1, -1 do table.remove(cards, i) end
			for i = 1, #tt do table.insert(cards, tt[i]) end
			return true
		end
	end

	return false
end

--[[
is3 - 是否为三张
参数：
1.手牌
2.牌级
]]
function CardViewExLogic:is3(cards, lv)
	if not cards or type(cards) ~= 'table' or #cards ~= 3 then return false end

	local ts = {}
	local tc = {}
	for i = 1, #cards do
		if self:isSuit(cards[i], lv) then table.insert(ts, cards[i])
		else table.insert(tc, cards[i])
		end
	end

	local cv = tc[1]%16
	if cv == 14 or cv == 15 then return false end
	for i = 2, #tc do
		if tc[i]%16 ~= cv then return false end
	end
	return true
end

--[[
is32 - 是否三带二
参数：
1.手牌
2.牌级
]]
function CardViewExLogic:is32(cards, lv)
	if not cards or type(cards) ~= 'table' or #cards ~= 5 then return false end

	local ts = {}
	local tc = {}
	for i = 1, #cards do
		if self:isSuit(cards[i], lv) then table.insert(ts, i)
		else table.insert(tc, i)
		end
	end

	local function search(c, cs, used)
		for i = 1, #cs do
			if c == cards[cs[i]]%16 and not used[cs[i]] then return cs[i] end
		end
	end

	local function match_type(v)
		local used = {}
		local nlost = 0
		local sv = v
		local tt = {}

		if sv == 14 then sv = 1 end

		for t = 1, 3 do
			local ret = search(sv, tc, used)
			if ret then
				used[ret] = true
				table.insert(tt, cards[ret])
			else
				nlost = nlost + 1
				if nlost <= #ts then table.insert(tt, cards[ts[nlost]]) end
			end
		end
		for cv = 15, 1, - 1 do
			local scv = cv

			-- if scv == 14 then scv = 1 end

			if scv ~= sv then
				local tlost = nlost
				local ttt = clone(tt)
				local tused = clone(used)

				for t = 1, 2 do
					local ret = search(scv, tc, tused)
					if ret then
						tused[ret] = true
						table.insert(ttt, cards[ret])
					else
						tlost = tlost + 1
						if tlost <= #ts then table.insert(ttt, cards[ts[tlost]]) end
					end
				end

				if tlost == #ts then
					for i = #cards, 1, -1 do table.remove(cards, i) end
					for i = 1, #ttt do table.insert(cards, ttt[i]) end
					return true
				end
			end
		end
	end
	if match_type(lv) then return true end

	for v = 14, 2, -1 do
		if lv ~= v then
			if match_type(v) then return true end
		end
	end
end

--[[
isBomb - 判断是否为炸弹
参数：
1.手牌
2.牌级
]]
function CardViewExLogic:isBomb(cards, lv)
	if not cards or type(cards) ~= 'table' or #cards < 4 then return false end

	local ts = {}
	local tc = {}
	for i = 1, #cards do
		if self:isSuit(cards[i], lv) then table.insert(ts, cards[i])
		else table.insert(tc, cards[i])
		end
	end

	table.sort(tc, function (a, b) return a%16 > b%16 end)

	local cv = tc[1]%16
	if cv == 14 or cv == 15 then return false end

	for i = 2, #tc do
		if tc[i]%16 ~= cv then return false end
	end
	return true
end

--[[
is2 - 是否为对子
参数：
1.手牌
2.牌级
]]
function CardViewExLogic:is2(cards, lv)
	if not cards or type(cards) ~= 'table' or #cards ~= 2 then return false end

	if cards[1]%16 >= 1 and cards[1]%16 <= 13 and cards[2]%16 >= 1 and cards[2]%16 <= 13 then
		if self:isSuit(cards[1], lv) or self:isSuit(cards[2], lv) then return true end
	end
	if cards[1]%16 == cards[2]%16 then return true end
	return false
end

--[[
is222 - 是否为三连对
参数：
1.手牌
2.牌级
]]
function CardViewExLogic:is222(cards, lv)
	if not cards or type(cards) ~= 'table' or #cards ~= 6 then return false end

	local ts = {}
	local tc = {}
	for i = 1, #cards do
		if self:isSuit(cards[i], lv) then table.insert(ts, i)
		else table.insert(tc, i)
		end
	end

	local function isHitCard(c, cs, used)
		for i = 1, #cs do
			if c == cards[cs[i]]%16 and not used[cs[i]] then return cs[i] end
		end
	end

	for v = 14, 3, -1 do
		local nlost = 0
		local used = {}
		local tt = {}

		for sv = v, v - 2, -1 do
			if sv == 14 then sv = 1 end

			for i = 1, 2 do
				local ret = isHitCard(sv, tc, used)
				if ret then
					used[ret] = true
					table.insert(tt, cards[ret])
				else
					nlost = nlost + 1
					if nlost <= #ts then table.insert(tt, cards[ts[nlost]]) end
				end
			end
		end

		if nlost == #ts then
			for i = #cards, 1, -1 do table.remove(cards, i) end
			for i = 1, #tt do table.insert(cards, tt[i]) end
			return true
		end
	end

	return false
end

--[[
isSuit - 是否为百搭牌
参数：
1.单张手牌
2.牌级
]]
function CardViewExLogic:isSuit(c, lv)
	if c%16 == lv and math.floor(c/16) == 3 then return true end
	return false
end

--[[
isMaxThs - 判断是否为最大同花顺
参数：
1.手牌序列
2.级牌
返回：
true表示是的，false表示不是
]]
function CardViewExLogic:isMaxThs(cards, lv)
	if not CardViewExLogic:isThs(cards, lv) then return false end

	local ts = {}
	local tc = {}
	for i = 1, #cards do
		if self:isSuit(cards[i], lv) then table.insert(ts, cards[i])
		else table.insert(tc, cards[i])
		end
	end
	local function hintsC(c, cs)
		for i = 1, #cs do
			if c == cs[i]%16 then return true end
		end
		return false
	end

	local nlost = 0
	for v = 14, 14 - 4, -1 do
		local sv = v
		if sv == 14 then sv = 1 end
		if not hintsC(sv, tc) then nlost = nlost + 1 end
	end
	if nlost == #ts then return true end
	return false
end

--[[
compareCards - 判断两组手牌大小
参数：
1.手牌序列1
2.手牌序列2
3.级牌
返回：
< 0 表示手牌1小于手牌2
= 0 表示手牌1等于手牌2
> 0 表示手牌1大于手牌2
nil 表示参数错误
]]
function CardViewExLogic:compareCards(cards1, cards2, lv)
	if not cards1 then return nil end
	if not cards2 then return nil end

	local ctype1 = self:cardsType(cards1, lv)
	local ctype2 = self:cardsType(cards2, lv)
	if ctype1 == Card_nil or ctype2 == Card_nil then return nil end

	local a = 1
	local e = 0
	local b = -1

	local strtype = {[0] = 'Card_4King', [1] = 'Card_Ths', [2] = 'Card_Sz', [3] = 'Card_Bomb', [4] = 'Card_33', [5] = 'Card_32', [6] = 'Card_222', [7] = 'Card_2', [8] = 'Card_1', [9] = 'Card_3', [10] = 'Card_0' }
	print('card1 type = ' .. strtype[ctype1] .. '  card2 type = ' .. strtype[ctype2])

	print(Card_0 .. ' : ' .. ctype1 .. ' : ' .. ctype2)

	if ctype1 == Card_0 and ctype2 == Card_0 then return e end
	if ctype1 == Card_4King or ctype2 == Card_0 then return a end
	if ctype2 == Card_4King or ctype1 == Card_0 then return b end

	if ctype1 == Card_Ths then
		if ctype2 == Card_Bomb then
			if #cards2 > 5 then return b
			else return a
			end
		elseif ctype2 == Card_Ths then
			return self:cmpCards(cards1, cards2, Card_Ths, lv, true)
		else return a
		end
	elseif ctype1 == Card_Bomb then
		if ctype2 == Card_Bomb then
			return self:cmpCards(cards1, cards2, Card_Bomb, lv, true)
		elseif ctype2 == Card_Ths then
			if #cards1 > 5 then return a
			else return b
			end
		else return a
		end
	elseif ctype1 == Card_Sz then
		if ctype2 == Card_Bomb or ctype2 == Card_Ths then return b
		elseif ctype2 == Card_Sz then
			return self:cmpCards(cards1, cards2, Card_Sz, lv, true)
		else return nil
		end
	elseif ctype1 == Card_33 then
		if ctype2 == Card_Bomb or ctype2 == Card_Ths then return b
		elseif ctype2 == Card_33 then
			return self:cmpCards(cards1, cards2, Card_33, lv, true)
		elseif ctype2 == Card_222 and self:is222(cards1, lv) then
			return self:cmpCards(cards1, cards2, Card_222, lv, true)
		else return nil
		end
	elseif ctype1 == Card_32 then
		if ctype2 == Card_Bomb or ctype2 == Card_Ths then return b
		elseif ctype2 == Card_32 then
			return self:cmpCards(cards1, cards2, Card_32, lv, true)
		else return nil
		end
	elseif ctype1 == Card_3 then
		if ctype2 == Card_Bomb or ctype2 == Card_Ths then return b
		elseif ctype2 == Card_3 then
			return self:cmpCards(cards1, cards2, Card_3, lv, true)
		else return nil
		end
	elseif ctype1 == Card_222 then
		if ctype2 == Card_Bomb or ctype2 == Card_Ths then return b
		elseif ctype2 == Card_222 then
			return self:cmpCards(cards1, cards2, Card_222, lv, true)
		elseif ctype2 == Card_33 and self:is222(cards2, lv) then
			return self:cmpCards(cards1, cards2, Card_222, lv, true)
		else return nil
		end
	elseif ctype1 == Card_2 then
		if ctype2 == Card_Bomb or ctype2 == Card_Ths then return b
		elseif ctype2 == Card_2 then
			return self:cmpCards(cards1, cards2, Card_2, lv, true)
		else return nil
		end
	elseif ctype1 == Card_1 then
		if ctype2 == Card_Bomb or ctype2 == Card_Ths then return b
		elseif ctype2 == Card_1 then
			return self:cmpCards(cards1, cards2, Card_1, lv, true)
		else return nil
		end
	end
	return nil
end

--[[
isCardType - 判断指定手牌是否为指定牌型
参数：
1.手牌序列
2.指定牌型
3.牌级
返回：
true表示正确，否则错误
]]
function CardViewExLogic:isCardType(cards, typ, lv)
	if typ == Card_1 then return #cards == 1
	elseif typ == Card_2 then return self:is2(cards, lv)
	elseif typ == Card_222 then return self:is222(cards, lv)
	elseif typ == Card_3 then return self:is3(cards, lv)
	elseif typ == Card_32 then return self:is32(cards, lv)
	elseif typ == Card_33 then return self:is33(cards, lv)
	elseif typ == Card_Sz then return self:isSz(cards, lv)
	elseif typ == Card_Ths then return self:isThs(cards, lv)
	elseif typ == Card_Bomb then return self:isBomb(cards, lv)
	end
	return false
end

--------------------------------------------------------------------------------------------------------------------------------------

return CardViewExLogic

-- local cards = {0x32, 0x2c, 0x1C, 0x4D, 0x32, 0x2D}
-- local ret = CardViewExLogic:is222(cards, 2)
--[[
if ret then print('is 32')
else print('not 32')
end
local str = 'cards = { '
for i = 1, #cards do
	str = str .. cards[i]%16 .. ', '
end
print(str .. ' }')
]]
-- local ret = CardViewExLogic:compareCards({0x38, 0x38, 0x31, 0x32, 0x31}, {0x2D, 0x1D, 0x1D, 0x21, 0x21}, 8)
-- local ret = CardViewExLogic:compareCards({0x25, 0x27, 0x26, 0x24, 0x23}, {0x33, 0x32, 0x35, 0x34, 0x36}, 5)
-- local ret = CardViewExLogic:compareCards({0x32, 0x32, 0x31, 0x3C, 0x3B}, {0x22, 0x21, 0x25, 0x24, 0x23}, 2)
--[[
local card0 = {0x12, 0x12, 0x13, 0x32, 0x43}
local card1 =  {0x21, 0x31, 0x37, 0x47, 0x11}
local ret = CardViewExLogic:compareCards(card0, card1, 2)
if not ret then print('invalide parameters that passed to function')
else
	local str = 'new card0 = {'
	for i = 1, #card0 do
		str = str .. '0x' .. math.floor(card0[i]/16) .. card0[i]%16 .. ' '
	end
	print(str .. '}')
	local str = 'new card1 = {'
	for i = 1, #card1 do
		str = str .. '0x' .. math.floor(card1[i]/16) .. card1[i]%16 .. ' '
	end
	print(str .. '}')
	if ret > 0 then print(ret .. ' above')
	elseif ret == 0 then print(ret .. ' equal')
	else print(ret .. ' below')
	end
end
]]
--[[
local ret = CardViewExLogic:is222({0x35, 0x35, 0x29, 0x29, 0x4A, 0x4A}, 5)
if ret then print('is 222')
else print('not 222')
end
]]
--[[
local ret = CardViewExLogic:is2({0x47, 0x32}, 2)
if ret then print('is 2')
else print('not 2')
end
]]
--[[
local ret = CardViewExLogic:isBomb({0x5F, 0x5F, 0x32, 0x32}, 2)
if ret then print('is bomb')
else print('not bomb')
end
]]
--[[
local ret = CardViewExLogic:is3({0x5e, 0x5e, 0x32}, 2)
if ret then print('is 3')
else print('not 3')
end
]]
--[[
local ret = CardViewExLogic:is32({0x47, 0x37, 0x27, 0x33, 0x32}, 2)
if ret then print('is 32')
else print('not 32')
end
]]
--[[
local ret = CardViewExLogic:is33({0x4D, 0x3D, 0x21, 0x41, 0x32, 0x32}, 2)
if ret then print('is 33')
else print('not 33')
end
]]
--[[
local ret = CardViewExLogic:isSz({0x32, 0x32, 0x12, 0x25, 0x14}, 2)
if ret then print('is sz')
else print('not sz')
end
]]
--[[
local ret = CardViewExLogic:isThs({0x32, 0x36, 0x37, 0x38, 0x39}, 2)
if ret then print('is ths')
else print('not ths')
end
]]
--[[
local ret = CardViewExLogic:isMaxThs({0x32, 0x3d, 0x3a, 0x3b, 0x39}, 2)
if ret then print('is Max ths')
else print('not Max ths')
end
--]]
--[[
test
]]
--[[
local card0 = {
	0x33, 0x13, 0x14, 0x24, 0x34, 0x25, 0x45, 0x17, 0x37, 0x18, 0x28, 0x28, 0x38, 0x48,
	0x29, 0x1A, 0x3A, 0x1B, 0x2B, 0x1C, 0x2C, 0x4C, 0x2D, 0x11, 0x22, 0x32, 0x5E, 0x5F
}
CardViewExLogic:normalise(card0, 5)
CardViewExLogic:dumpInfo()

print('===========> after remove')
local rmcards = { 0x33, 0x13, 0x25, 0x17, 0x18, 0x28, 0x38, 0x2D, 0x11, 0x22, 0x32, 0x5E }
CardViewExLogic:rmByCards(rmcards)
CardViewExLogic:dumpInfo()]]
-- CardViewExLogic:prebombs(2)
--[[
local selecs = {}
for i = 1, #card0 do table.insert(selecs, i) end
CardViewExLogic:bombAll(selecs, {}, 2)]]
-- CardViewExLogic:preHint({0x45, 0x45, 0x35}, 2)
-- CardViewExLogic:preHint({0x5e, 0x5f, 0x5e, 0x5f}, 2) -- 4 king
-- CardViewExLogic:preHint({0x10}, 2) -- card 1
-- CardViewExLogic:preHint({0x30, 0x20}, 2) -- card 2
--[[local ret = CardViewExLogic:is222({0x3C, 0x2C, 0x3D, 0x3D, 0x21, 0x41}, 2)
if (ret == Card_222) then print('is222')
else print('not 222')
end
CardViewExLogic:preHint({0x3C, 0x2C, 0x3D, 0x3D, 0x21, 0x41}, 2) -- card 222]]
-- CardViewExLogic:preHint({0x37, 0x27, 0x32}, 2) -- card 3
-- CardViewExLogic:preHint({0x44, 0x24, 0x14, 0x43, 0x23}, 2) -- card 32
-- CardViewExLogic:preHint({0x37, 0x27, 0x32, 0x16, 0x32, 0x47}, 2) -- card 33
-- CardViewExLogic:preHint({0x36, 0x37, 0x38, 0x39, 0x3A}, 5) -- card sz
-- CardViewExLogic:preHint({0x31, 0x32, 0x33, 0x34, 0x35}, 2) -- card Ths
-- CardViewExLogic:preHint({0x33, 0x13, 0x23, 0x32, 0x43, 0x32}, 2) -- card bomb
-- CardViewExLogic:preHint({}, 2)
-- CardViewExLogic:preHint({0x34, 0x35, 0x36, 0x37, 0x38}, 2)
-- CardViewExLogic:preHint({0x2D, 0x2D, 0x2D, 0x11, 0x11}, 5)
-- CardViewExLogic:preHint({0x11, 0x21, 0x31, 0x33, 0x33}, 2)
--[[
CardViewExLogic:preHint({0x45, 0x15, 0x32, 0x12, 0x22}, 2)
print('all hints [' .. #CardViewExLogic.hintDatas .. '] = {')
for i = 1, #CardViewExLogic.hintDatas do
	local str = string.format('%d : { ', i)

	local subhints = CardViewExLogic.hintDatas[i]
	for j = 1, #subhints do
		local c = CardViewExLogic:getByidx(subhints[j])
		str = string.format('%s [%d]0x%d%d', str, subhints[j], math.floor(c/16), c%16)
	end
	print(str)
end
print('}')
]]
-- print(CardViewExLogic:overlappedCard({1, 2, 7, 3, 8, 5, 6}))
--[[
local selIdx = { 1, 2, 3, 4, 7, 11, 15, 16, 25, 26, 28, 30, 31, 32, 33 }
local hits = CardViewExLogic:getHits(selIdx)
print('Hits list : {')
for i = 1, #hits do
	local tstr = string.format('    %d : ', i)

	for j = 1, #hits[i] do
		tstr = string.format('%s %d', tstr, hits[i][j])
	end
	print(tstr)
end
print('}')
]]
--[[
local rmIdx = { 1, 3, 5, 7, 11, 13, 14, 15, 19 }
local n = CardViewExLogic:nums(rmIdx)
for i = 1, n do
	CardViewExLogic:rmByIdx(rmIdx[i])
	print('==================> after delete ' .. rmIdx[i])
	CardViewExLogic:dumpInfo()
end
]]

--[[
local rmIdx = { 1, 3, 5, 7, 11, 13, 14, 15, 19 }
CardViewExLogic:rmByIndices(rmIdx)
print('==================> after delete ')
CardViewExLogic:dumpInfo()
]]

-- local selIdx = { 1, 2, 3, 4, 7, 11, 15, 16, 25, 26, 28, 30, 31, 32, 33 }
-- local selIdx = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27 }
-- CardViewExLogic:arrange(selIdx, 6)
-- CardViewExLogic:thsAll(selIdx, {}, 2, 2)

--[[
CardViewExLogic:preths(2)
for i = 1, #CardViewExLogic.thsDatas do
	local selecs = CardViewExLogic.thsDatas[i]
	local str = 'next ths : { '
	for i = 1, #selecs do
		local c = CardViewExLogic:getByidx(selecs[i])
		str = string.format('%s (%d, %d)', str, c%16, math.floor(c/16))
	end
	print(str .. ' }')
end
]]
