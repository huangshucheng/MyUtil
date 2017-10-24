--[[
掼蛋手牌视图
]]

--local CardViewExLogic = require('GuanDan.views.CardViewExLogic')
local CardViewExLogic = import("..views/CardViewExLogic")
local CardViewEx = class("CardViewEx", cc.Layer)

--[[
常量定义
]]
local INNER_OFFSETX = 6
local INNER_OFFSETY = 6
local OFFSETX  =0
local OFFSETY = 40
local INNER_SPACE = 6
local CHOSE_SPACE = 9
local CHOSE_SPAWN = 0.2
local CARD_SCALE = 1.4

local CARD_SPX_VAL	= 1
local CARD_SPX_BC	= 2
local CARD_SPX_MC	= 3

function CardViewEx:ctor()
	local function onNodeEvent(event)
		if event == 'enter' then
			self:onEnter()
		elseif event == 'exit' then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	
	self._render_style	= 0		-- 0 表示竖	1 表示横
    self._numCount = 0
    self:setupVar()
    --self:onEnterEx()
end

function CardViewEx:onEnter()
    printInfo("CardViewEx:onEnter()")
    
    local function onTouchBegan(touch, event) 
        if(self:onTouchBegan(touch,event))then
            return true 
        else
            self:restatus()
            return false
        end
    end
    
    --local function onTouchBegan(touch, event)self:onTouchBegan(touch,event) return true end
    local function onTouchMoved(touch, event)self:onTouchMoved(touch,event) end
    local function onTouchEnded(touch, event)self:onTouchEnded(touch,evnet) end
    local function onTouchCancelled(touch, event)self:onTouchCancelled(touch,evnet) end
    local listener = cc.EventListenerTouchOneByOne:create()    
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
	self:setTouchEnabled(true)
end

--[[
onEnter 事件
]]
function CardViewEx:onEnterEx()
	self:registerScriptTouchHandler(function (state, ...)
										local args = { ... }

										if state == 'began' then
											if self:touchBeganEvent(args[1], args[2]) then return true
											else
												self:restatus()
												return false
											end
										elseif state == 'moved' then
											self:touchMovedEvent(args[1], args[2])
										elseif state == 'ended' then
											self:touchEndedEvent(args[1], args[2])
										end

										return false
									end, -- End of anonymous touch handler function
									false,
									0,
									true
									)
                                    

end
--[[
onExit 事件
]]
function CardViewEx:onExit()
    printInfo("CardViewEx:onExit()")
	self:unregisterScriptTouchHandler()
	self:setTouchEnabled(false)
end
--TODO
function CardViewEx:onTouchBegan(touch,event)
    printInfo("new touch begin")
    self.touchSprites = {}
    local cpos = self:convertToNodeSpace(touch:getLocation())
	for i = #self.cardSprites, 1, -1 do
		local card = self.cardSprites[i].sprite
		if self:containsPt(card, cpos.x, cpos.y) then
			self.touchSprites[i] = true
			self:setCardColor(card, cc.c3b(128, 128, 128))
			return true
		end
	end
	return false
end

function CardViewEx:onTouchMoved(touch,event)
    --local delta = touch:getDelta()
    --local startPos = touch:getStartLocation()   --start not change
    local curPos = touch:getLocation()
    local prePos = touch:getPreviousLocation()

    --printInfo('startPosX: ' .. startPos.x .. '  ,startPosY: ' .. startPos.y)
    --printInfo('curPosX: ' .. curPos.x .. '  ,curPosY: ' .. curPos.y)
    --printInfo('prePosX: ' .. prePos.x .. '  ,prePosY: ' .. prePos.y)
    --printInfo('deltaX: ' .. delta.x .. '  ,deltaY: ' .. delta.y)

    local cpos = self:convertToNodeSpace(touch:getLocation())
    --printInfo('x: ' .. cpos.x .. '  ,y: ' .. cpos.y)
    local index = self:getTouchCardIndex(cpos)
    --local index = self:getTouchCardIDX(touch)S
    if index then
        printInfo('index: ' .. index)
        self:setCardSelected(index)
    end
end

function CardViewEx:getTouchCardIDX(touch)
    local startPos = self:convertToNodeSpace(touch:getStartLocation())
    local curPos = self:convertToNodeSpace(touch:getLocation())
    --local prePos = touch:getPreviousLocation()
    --local delta = touch:getDelta()

    for index = table.nums(self.cardSprites), 1, -1 do
        local card = self.cardSprites[index].sprite
        local rect = self:getCardRect(card)
        local p1,p2,p3,p4 = self:getPointFromRect(rect)
        if  cc.pIsSegmentIntersect(startPos,curPos,p1,p2) or 
            cc.pIsSegmentIntersect(startPos,curPos,p2,p3) or 
            cc.pIsSegmentIntersect(startPos,curPos,p3,p4) or 
            cc.pIsSegmentIntersect(startPos,curPos,p1,p4) or 
            cc.rectContainsPoint(rect,startPos) or
            cc.rectContainsPoint(rect,curPos)   then
            return index
        end
    end
end

function CardViewEx:getPointFromRect(rect)
    if not rect then return end
    local p1 = cc.p(rect.x , rect.y)
    local p2 = cc.p(rect.x , rect.y + rect.height)
    local p3 = cc.p(rect.x + rect.width , rect.y + rect.height)
    local p4 = cc.p(rect.x + rect.width , rect.y)
    return p1,p2,p3,p4
end

function CardViewEx:getCardRect(obj)
    if not obj then return end
    local bdbox = obj:getBoundingBox()
	local px = bdbox.x
	local py = bdbox.y
	local sw = bdbox.width * CARD_SCALE
	local sh = bdbox.height * CARD_SCALE
    return cc.rect(px,py,sw,sh)
end

function CardViewEx:getTouchCardIndex(cpos)
    for index = table.nums(self.cardSprites), 1, -1 do
        local card = self.cardSprites[index].sprite
        if self:containsPt(card, cpos.x, cpos.y) then
            return index
        end
    end
end

function CardViewEx:onTouchEnded(touch,event)
    printInfo("new touch end")
	local cpos = self:convertToNodeSpace(touch:getLocation())
	for i = #self.cardSprites, 1, -1 do
		local card = self.cardSprites[i].sprite
		if self:containsPt(card, cpos.x, cpos.y) then
			self.touchSprites[i] = true
			self:setCardColor(card, cc.c3b(128, 128, 128))
			break
		end
	end
	self:fresh()
	self:selectSND()
end

function CardViewEx:onTouchCancelled(touch,event)

end

--[[
touchBeganEvent -touch began 事件
]]
function CardViewEx:touchBeganEvent(x, y)
	self.touchSprites = {}

	local cpos = self:convertToNodeSpace(cc.vertex2F(x, y))

	for i = #self.cardSprites, 1, -1 do
		local card = self.cardSprites[i].sprite

		if self:containsPt(card, cpos.x, cpos.y) then
			self.touchSprites[i] = true
			-- card:setColor(cc.c3b(128, 128, 128))
			self:setCardColor(card, cc.c3b(128, 128, 128))
			return true
		end
	end
	return false
end

--[[
touchMovedEvent - touch moved 事件
]]
function CardViewEx:touchMovedEvent(x, y)
	local cpos = self:convertToNodeSpace(cc.p(x, y))
    printInfo('x: ' .. cpos.x .. '  ,y: ' .. cpos.y)
    --[[
	for i = #self.cardSprites, 1, -1 do
		local card = self.cardSprites[i].sprite

		if self:containsPt(card, cpos.x, cpos.y) then
			self.touchSprites[i] = true
			self:setCardColor(card, cc.c3b(128, 128, 128))
			break
		end
	end
    ]]
    
    --printInfo('x: ' .. cpos.x .. '  ,y: ' .. cpos.y)
    self._numCount = self._numCount+1
    --printInfo('count------>'.. self._numCount)
    local index = self:getTouchCardIndex(cpos)
    if index then
        --printInfo('touch index: '..index)
        self:setCardSelected(index)
    end
end

function CardViewEx:setCardSelected(index)
    if not index then return end
    local card = self.cardSprites[index].sprite
    if card then
        self.touchSprites[index] = true
       -- printInfo('index->' .. index .. "is true")
        self:setCardColor(card, cc.c3b(128, 128, 128))
    end
end

--[[
touchEndedEvent - touch ended 事件
]]
function CardViewEx:touchEndedEvent(x, y)
    self._numCount = 0
	local cpos = self:convertToNodeSpace(cc.vertex2F(x, y))

	for i = #self.cardSprites, 1, -1 do
		local card = self.cardSprites[i].sprite

		if self:containsPt(card, cpos.x, cpos.y) then
			self.touchSprites[i] = true
			-- card:setColor(cc.c3b(128, 128, 128))
			self:setCardColor(card, cc.c3b(128, 128, 128))
			break
		end
	end
	self:fresh()
	
	self:selectSND()
end

------------------------------------------------------------------------------
-- 华丽分割线

--[[
setRenderStyle - 设置渲染方式（1 - 横| 0 - 竖）

]]
function CardViewEx:setRenderStyle(style)
	if self._render_style == style then
		return
	end
	
	self._render_style = style
	self:render()
end

--[[
selectSND - 选牌声音
]]
function CardViewEx:selectSND()
	local play = false
	for i = 1, #self.cardSprites do
		if self.touchSprites[i] then
			play = true
		end
	end
	if play then
		AudioEngine.playEffect('sound/selectcard.mp3')
	end
end

--[[
setupVar - 自定义变量
]]
function CardViewEx:setupVar()
	self.resPrefix = nil	-- 资源前缀

	self.maxWidth = self.maxWidth or 0		-- 视图最大宽度
	self.width_space = 70	-- 手牌序列两头预留
	self.offsetX = 0		-- 手牌x方向间距
	self.offsetY = 40 * CARD_SCALE		-- 手牌y方向间距
	self.cardSprites = {}	-- 手牌精灵序列
	self.touchSprites = {}	-- 被触摸的手牌精灵
	self.inner_offsetx = 6	-- 内部花色x偏移
	self.inner_offsety = 6	-- 内部花色y偏移
	self.inner_space = 6	-- 内部对象间距
	self.chose_space = 9	-- 选中后跳起高度
	self.chose_spawn = 0.2	-- 选中跳起动画时间间隔
end

--[[
initVal - 初始化变量
]]
function CardViewEx:initVal()
	self.width_space = 70	-- 手牌序列两头预留
	self.offsetX = 0		-- 手牌x方向间距
	self.offsetY = 40 * CARD_SCALE		-- 手牌y方向间距
	self.inner_offsetx = 6	-- 内部花色x偏移
	self.inner_offsety = 6	-- 内部花色y偏移
	self.inner_space = 6	-- 内部对象间距
	self.chose_space = 9	-- 选中后跳起高度
	self.chose_spawn = 0.2	-- 选中跳起动画时间间隔
end

--[[
setCards - 根据手牌数据整理并渲染手牌序列
参数：
1.手牌数据
2.plist资源描述文件
3.级牌牌值
]]
function CardViewEx:setCards(cards, plist, cardlv)
	if not cards then return end

	-- self:clearCards()

	-- self:initVal()
	local lv = cardlv or 2
	CardViewExLogic:normalise(cards, lv)
	CardViewExLogic:dumpInfo()

	self:prefix(plist)
	self:render()
end

--[[
clearCards - 清空手牌精灵视图
]]
function CardViewEx:clearCards()
	if not self.cardSprites then return end

	print('CardViewEx:clearCards ========================>')
	for i = 1, #self.cardSprites do
		local c = self.cardSprites[i].sprite

		self:removeChild(c)
	end
	self.cardSprites = {}
end

--[[
render - 渲染手牌精灵对象
]]
function CardViewEx:render()
	if self._render_style == 0 then
		self:renderAsVertical()
	else
		self:renderAsHorizontal()
	end
end

--[[
renderAsVertical - 按列方式渲染手牌精灵
]]
function CardViewEx:renderAsVertical()
	self:adjust()
	self:clearCards()

	local zorder = 0
	local cw = 0
	local px = 0
	for i = 1, #CardViewExLogic.cardDatas do
		local subcards = CardViewExLogic.cardDatas[i]

		local py = 0
		for j = 1, #subcards do
			-- local res = self:getCardRes(subcards[j])
			-- local c = cc.Sprite:createWithSpriteFrameName(res)
			local c = self:createComponentCard(subcards[j])

			c:setAnchorPoint(0.0, 0.0)
			c:setPosition(px, py)
			self:addChild(c, zorder + #subcards - j + 1)

			self.cardSprites[zorder + #subcards - j + 1] = { sprite = c, status = false, card = subcards[j], idx = zorder + j, hit = false, ignorehit = false }

			cw = c:getContentSize().width * CARD_SCALE
			py = py + self.offsetY
		end
		px = px + cw - self.offsetX

		zorder = zorder + #subcards
	end
end

--[[
renderAsHorizontal - 按行方式渲染手牌精灵
]]
function CardViewEx:renderAsHorizontal()
	self:adjust()
	self:clearCards()
	
	local zorder = 0
	local cw = 0
	local px = 0
	for i = 1, #CardViewExLogic.cardDatas do
		local subcards = CardViewExLogic.cardDatas[i]
		
		local py = 0
		for j = 1, #subcards do
			local c = self:createComponentCard(subcards[j])

			c:setAnchorPoint(0.0, 0.0)
			c:setPosition(px, py)
			-- self:addChild(c, zorder + #subcards - j + 1)
			self:addChild(c, zorder + j)

			-- self.cardSprites[zorder + #subcards - j + 1] = { sprite = c, status = false, card = subcards[j], idx = zorder + j, hit = false, ignorehit = false }
			self.cardSprites[zorder + j] = { sprite = c, status = false, card = subcards[j], idx = zorder + j, hit = false, ignorehit = false }

			cw = c:getContentSize().width * CARD_SCALE
			
			px = px + cw - self.offsetX
		end

		zorder = zorder + #subcards
	end
end

--[[
setMaxWidth - 设置视图最大宽度
参数：
1.width - 最大宽度
]]
function CardViewEx:setMaxWidth(width)
	self.maxWidth = width
end

--[[
prefix - 设置资源文件前缀
参数：
1.plist资源描述文件
]]
function CardViewEx:prefix(plist)
	local s = string.find(plist, '%.')
	self.resPrefix = string.sub(plist, 1, s - 1) .. '/'
end

--[[
getCardRes - 根据手牌获取资源路径
参数：
1.手牌数据
返回：
1.资源路径
]]
function CardViewEx:getCardRes(c)
	local hexval = { [0] = 'a', [1] = 'b', [2] = 'c', [3] = 'd', [4] = 'e', [5] = 'f' }
	local cv = c % 16
	local cc = math.floor(c/16)

	if cv >= 10 and cv <= 15 then
		return string.format('%scard_%d%s.png', self.resPrefix, cc, hexval[cv - 10])
	else
		return string.format('%scard_%d%s.png', self.resPrefix, cc, cv)
	end
end

--[[
设置手牌颜色
参数：
1.手牌精灵
2.颜色
]]
function CardViewEx:setCardColor(cardspx, c)
	cardspx:setColor(c)
	
	local spritevl = cardspx:getChildByTag(CARD_SPX_VAL)
	if spritevl then spritevl:setColor(c) end
	local spriteml = cardspx:getChildByTag(CARD_SPX_BC)
	if spriteml then spriteml:setColor(c) end
	local spritecl = cardspx:getChildByTag(CARD_SPX_MC)
	if spritecl then spritecl:setColor(c) end
end

--[[
createComponentCard - 根据牌面创建手牌精灵
参数：
1.手牌数据
返回：
1.如果成功返回Sprite，失败返回nil
]]
function CardViewEx:createComponentCard(c)
    if self._render_style == 0 then
		return self:createCardAsVertical(c)
	else
		return self:createCardAsHorizontal(c)
	end
end

--[[
createCardAsVertical - 根据牌面创建手牌精灵（竖排展示）
]]
function CardViewEx:createCardAsVertical(c)
	self.inner_offsetx = self.inner_offsetx or INNER_OFFSETX
    self.inner_offsety = self.inner_offsety or INNER_OFFSETY
	local spritebg = cc.Sprite:createWithSpriteFrameName('diban.png')

	local spritevl = cc.Sprite:createWithSpriteFrameName(string.format('%d_%d.png', math.floor(c/16)%2, c%16))
	spritevl:setAnchorPoint(0.0, 1.0)
	spritevl:setPosition(0 + self.inner_offsetx, spritebg:getContentSize().height - self.inner_offsety)
	spritebg:addChild(spritevl)
	spritevl:setTag(CARD_SPX_VAL)

	if c%16 == 14 or c%16 == 15 then
		local spriteml = cc.Sprite:createWithSpriteFrameName(string.format('b_%d.png', c%16))
		spriteml:setAnchorPoint(1.0, 1.0)
		spriteml:setPosition(spritebg:getContentSize().width - self.inner_offsetx, spritebg:getContentSize().height - self.inner_offsety - 40)

		spritebg:addChild(spriteml)
		spriteml:setTag(CARD_SPX_BC)
	else
		local spritecl = cc.Sprite:createWithSpriteFrameName(string.format('s_%d.png', math.floor(c/16)))
		spritecl:setAnchorPoint(0.0, 1.0)
		spritecl:setPosition(spritevl:getContentSize().width + self.inner_space, spritebg:getContentSize().height - self.inner_offsety)

		spritebg:addChild(spritecl)
		spritecl:setTag(CARD_SPX_MC)

		local spriteml = cc.Sprite:createWithSpriteFrameName(string.format('b_%d.png', math.floor(c/16)))
		spriteml:setAnchorPoint(1.0, 0.0)
		spriteml:setPosition(spritebg:getContentSize().width - self.inner_offsetx, 0 + self.inner_offsety)

		spritebg:addChild(spriteml)
		spriteml:setTag(CARD_SPX_BC)
	end

	spritebg:setScale(CARD_SCALE)
	return spritebg
end

--[[
createCardAsHorizontal	- 根据牌面创建手牌精灵（横排展示）
]]
function CardViewEx:createCardAsHorizontal(c)
	self.inner_offsetx = self.inner_offsetx or INNER_OFFSETX
    self.inner_offsety = self.inner_offsety or INNER_OFFSETY
	local spritebg = cc.Sprite:createWithSpriteFrameName('diban.png')

	local spritevl = cc.Sprite:createWithSpriteFrameName(string.format('%d_%d.png', math.floor(c/16)%2, c%16))
	spritevl:setAnchorPoint(0.0, 1.0)
	spritevl:setPosition(0 + self.inner_offsetx, spritebg:getContentSize().height - self.inner_offsety)
	spritebg:addChild(spritevl)
	spritevl:setTag(CARD_SPX_VAL)

	if c%16 == 14 or c%16 == 15 then
		local spriteml = cc.Sprite:createWithSpriteFrameName(string.format('b_%d.png', c%16))
		spriteml:setAnchorPoint(1.0, 1.0)
		spriteml:setPosition(spritebg:getContentSize().width - self.inner_offsetx, spritebg:getContentSize().height - self.inner_offsety - 40)

		spritebg:addChild(spriteml)
		spriteml:setTag(CARD_SPX_BC)
	else
		local spritecl = cc.Sprite:createWithSpriteFrameName(string.format('s_%d.png', math.floor(c/16)))
		spritecl:setAnchorPoint(0.5, 0.0)
		-- spritecl:setPosition(spritevl:getContentSize().width + self.inner_space, spritebg:getContentSize().height - self.inner_offsety)
		spritecl:setPosition(spritevl:getPositionX() + spritevl:getContentSize().width/2, spritevl:getPositionY() - spritevl:getContentSize().height * CARD_SCALE - self.inner_offsety)

		spritebg:addChild(spritecl)
		spritecl:setTag(CARD_SPX_MC)

		local spriteml = cc.Sprite:createWithSpriteFrameName(string.format('b_%d.png', math.floor(c/16)))
		spriteml:setAnchorPoint(1.0, 0.0)
		spriteml:setPosition(spritebg:getContentSize().width - self.inner_offsetx, 0 + self.inner_offsety)

		spritebg:addChild(spriteml)
		spriteml:setTag(CARD_SPX_BC)
	end

	spritebg:setScale(CARD_SCALE)
	return spritebg
end

--[[
getSingleSize - 计算单张手牌宽高
返回：
1.w - 手牌宽度
2.h - 手牌高度
]]
function CardViewEx:getSingleSize()
	local c = cc.Sprite:createWithSpriteFrameName('diban.png')
	return c:getContentSize().width, c:getContentSize().height
end

--[[
adjust - 重新计算手牌视图变量为渲染准备
]]
function CardViewEx:adjust()
	if self._render_style == 0 then
		self:adjustAsVertical()
	else
		self:adjustAsHorizontal()
	end
end

--[[
adjustAsVertical - 按列方式预计算
]]
function CardViewEx:adjustAsVertical()
	local cw = self:getSingleSize() * CARD_SCALE
	local vw = self.maxWidth - self.width_space
	local ncard = table.nums(CardViewExLogic.cardDatas)
	if vw >= ncard * cw then
		vw = ncard * cw
		self.offsetX = 0
	else
		self.offsetX = (ncard * cw - vw) / (ncard - 1)
	end

	self:setContentSize(vw, self:getContentSize().height)
end

--[[
adjustAsHorizontal - 按行方式预计算
]]
function CardViewEx:adjustAsHorizontal()
	local cw = self:getSingleSize() * CARD_SCALE
	local vw = self.maxWidth - self.width_space
	local ncard = 0
	for _, subcard in pairs(CardViewExLogic.cardDatas) do
		local nsubcard = 0
		for _, c in pairs(subcard) do
			nsubcard = nsubcard + 1
		end
		
		ncard = ncard + nsubcard
	end
	
	if vw >= ncard * cw then
		vw = ncard * cw
		self.offsetX = 0
	else
		self.offsetX = (ncard * cw - vw) / (ncard - 1)
	end

	self:setContentSize(vw, self:getContentSize().height)
end

--[[
containsPt - obj对象是否包含某个点
参数：
1.obj - 对象
2.x - 坐标
3.y - 坐标
]]
function CardViewEx:containsPt(obj, x, y)
	local px = obj:getPositionX()
	local py = obj:getPositionY()
	local sw = obj:getContentSize().width
	local sh = obj:getContentSize().height

	if x >= px and x <= px + sw * CARD_SCALE and y >= py and y <= py + sh * CARD_SCALE then
		return true
	end
	return false
end

--[[
fresh - 刷新视图内容
]]
function CardViewEx:fresh()
	if self._render_style == 0 then
		self:freshAsVertical()
	else
		self:freshAsHorizontal()
	end
end

--[[
freshAsVertical - 刷新视图内容（竖排方式）
]]
function CardViewEx:freshAsVertical()
	local selecs = {}

	-- fresh views color
	for k, _ in pairs(self.touchSprites) do
		if not self.cardSprites[k].ignorehit then
			self.cardSprites[k].status = not self.cardSprites[k].status

			local card = self.cardSprites[k].sprite
			if self.cardSprites[k].status == true then
				-- card:setPositionY(card:getPositionY() + 30)
				-- card:setColor(cc.c3b(128, 128, 128))
				self:setCardColor(card, cc.c3b(128, 128, 128))
				table.insert(selecs, self.cardSprites[k].idx)
			else
				-- card:setPositionY(card:getPositionY() - 30)
				-- card:setColor(cc.c3b(255, 255, 255))
				self:setCardColor(card, cc.c3b(255, 255, 255))
			end
		end
	end

	-- fresh views position
	local hits = CardViewExLogic:getVerticalHits(selecs)
	for i = 1, #hits do
		local hit = hits[i]

		local py = 0
		for j = 1, #hit do
			if not self.cardSprites[hit[1] + #hit - j].hit then
				self.cardSprites[hit[1] + #hit - j].hit = true

				local sprite = self.cardSprites[hit[1] + #hit - j].sprite
				sprite:setPositionY(py)
				sprite:stopAllActions()
				local mvBy = cc.MoveBy:create(self.chose_spawn, cc.vertex2F(0, self.chose_space * (j - 1)))
				sprite:runAction(mvBy)
				-- sprite:setPositionY(sprite:getPositionY() + self.chose_space * (j - 1))
			end
			
			py = py + self.offsetY
		end
	end
end

--[[
freshAsHorizontal - 刷新视图内容（横排方式）
]]
function CardViewEx:freshAsHorizontal()
	local selecs = {}

	-- fresh views color
	for k, _ in pairs(self.touchSprites) do
		if not self.cardSprites[k].ignorehit then
			self.cardSprites[k].status = not self.cardSprites[k].status

			local card = self.cardSprites[k].sprite
			if self.cardSprites[k].status == true then
				-- card:setPositionY(card:getPositionY() + 30)
				-- card:setColor(cc.c3b(128, 128, 128))
				self:setCardColor(card, cc.c3b(128, 128, 128))
				table.insert(selecs, self.cardSprites[k].idx)
			else
				-- card:setPositionY(card:getPositionY() - 30)
				-- card:setColor(cc.c3b(255, 255, 255))
				self:setCardColor(card, cc.c3b(255, 255, 255))
			end
		end
	end
	
	-- fresh view position
	if #selecs == 1 then
		-- horizontal fresh view while the selected card count is 1
		local hits_left, hits_right = CardViewExLogic:getHorizontalHits(selecs)
		
		-- TODO:
	end
	
	for i = 1, #selecs do
		for j = 1, #self.cardSprites do
			if selecs[i] == self.cardSprites[j].idx and not self.cardSprites[j].hit then
				self.cardSprites[j].hit = true
				
				local sprite = self.cardSprites[j].sprite
				sprite:setPositionY(sprite:getPositionY() + 30)
			end
		end
	end
end

--[[
restatus - 设置视图手牌为未选中状态
]]
function CardViewEx:restatus()
	if self._render_style == 0 then
		self:restatusAsVertical()
	else
		self:restatusAsHorizontal()
	end
end

--[[
restatusAsVertical - 设置视图手牌为未选中状态（竖排展示）
]]
function CardViewEx:restatusAsVertical()
	for i = 1, #self.cardSprites do
		local c = self.cardSprites[i].sprite
		-- c:setColor(cc.c3b(255, 255, 255))
		self:setCardColor(c, cc.c3b(255, 255, 255))

		if self.cardSprites[i].status == true then
			-- c:setPositionY(c:getPositionY() - 30)
			self.cardSprites[i].status = false
		end
	end

	local zorder = 0
	for i = 1, #CardViewExLogic.cardDatas do
		local datas = CardViewExLogic.cardDatas[i]

		local py = 0
		for j = 1, #datas do
			local idx = zorder + #datas - j + 1

			if idx <= #self.cardSprites and self.cardSprites[idx].hit == true then -- todo crash--  [string "GuanDan\views\CardViewEx.lua"](389): attempt to index field '?' (a nil value)
				self.cardSprites[idx].hit = false

				local sprite = self.cardSprites[idx].sprite
				sprite:setPositionY(py + self.chose_space * (j - 1))
				sprite:stopAllActions()
				local mvBy = cc.MoveBy:create(self.chose_spawn, cc.vertex2F(0, -self.chose_space * (j - 1)))
				sprite:runAction(mvBy)
			end
			
			py = py + self.offsetY
		end

		zorder = zorder + #datas
	end
end

--[[
restatusAsHorizontal - 设置视图手牌为未选中状态（横排展示）
]]
function CardViewEx:restatusAsHorizontal()
	for i = 1, #self.cardSprites do
		local c = self.cardSprites[i].sprite
		-- c:setColor(cc.c3b(255, 255, 255))
		self:setCardColor(c, cc.c3b(255, 255, 255))

		if self.cardSprites[i].status == true then
			-- c:setPositionY(c:getPositionY() - 30)
			self.cardSprites[i].status = false
		end
	end
	
	for i = 1, #self.cardSprites do
		if self.cardSprites[i].hit == true then
			self.cardSprites[i].hit = false
			
			local sprite = self.cardSprites[i].sprite
			sprite:setPositionY(sprite:getPositionY() - 30)
		end
	end
end

--[[
getSelectCard - 获取选中的手牌数据
返回：
1.选中的手牌
]]
function CardViewEx:getSelectCard()
	local selecIndices = {}
	local selecs = {}
	for i = 1, #self.cardSprites do
		if self.cardSprites[i].status == true then
			table.insert(selecs, self.cardSprites[i].card)
			table.insert(selecIndices, self.cardSprites[i].idx)
		end
	end
	return selecs, selecIndices
end

--[[
shootSelectCard - 发出选中的手牌（出牌完成后调用，用于清除获取时选中的手牌数据）
]]
function CardViewEx:shootSelectCard()
	local selecs, selecIndices = self:getSelectCard()
	if not selecIndices or #selecIndices == 0 then return end

    local str = 'shoot select cards = {'
    for i = 1, #selecIndices do
        str = string.format('%s %d', str, selecIndices[i])
    end
    print(str .. ' }')

	CardViewExLogic:rmByIndices(selecIndices)
	CardViewExLogic:resetThs()

	self:render()
	CardViewExLogic:dumpInfo()
end

--[[
setSelectCard - 设置选中的手牌
参数：
1.手牌对象序列
]]
function CardViewEx:setSelectCard(cards)
	if not cards or #cards == 0 then return end

	self:restatus()

	for i = 1, #cards do
		for j = 1, #self.cardSprites do
			if cards[i] == self.cardSprites[j].card and not self.cardSprites[j].status then
				self.cardSprites[j].status = true
				-- self.cardSprites[j].sprite:setColor(cc.c3b(128, 128, 128))
				self:setCardColor(self.cardSprites[j].sprite, cc.c3b(128, 128, 128))
				break
			end
		end
	end
end

--[[
nextThs - 下一组同花顺
返回：
1.同花顺table
]]
function CardViewEx:nextThs(lv)
	local ths = CardViewExLogic:nextThs(lv)
	if not ths or #ths == 0 then return end

	self:restatus()
	for i = 1, #ths do
		for j = 1, #self.cardSprites do
			if self.cardSprites[j].idx == ths[i] then
				self.cardSprites[j].status = true
				-- self.cardSprites[j].sprite:setPositionY(self.cardSprites[j].sprite:getPositionY() + 30)
				-- self.cardSprites[j].sprite:setColor(cc.c3b(128, 128, 128))
				self:setCardColor(self.cardSprites[j].sprite, cc.c3b(128, 128, 128))
			end
		end
	end
end

--[[
hints - 提示可出的牌
参数：
1.待比较的手牌
返回：
2.可出的手牌table，如不存在返回空表
]]
function CardViewEx:hints(cmpCards, lv, ctyp)
	if not cmpCards then return {} end

	local hints = CardViewExLogic:nextHint(cmpCards, lv, ctyp)
	if not hints or #hints == 0 then return {} end

	self:restatus()
	for i = 1, #hints do
		for j = 1, #self.cardSprites do
			if self.cardSprites[j].idx == hints[i] then
				self.cardSprites[j].status = true
				-- self.cardSprites[j].sprite:setPositionY(self.cardSprites[j].sprite:getPositionY() + 30)
				-- self.cardSprites[j].sprite:setColor(cc.c3b(128, 128, 128))
				self:setCardColor(self.cardSprites[j].sprite, cc.c3b(128, 128, 128))
			end
		end
	end
	
	return hints
end

--[[
resethints - 重置提示
]]
function CardViewEx:resethints()
	CardViewExLogic:resetHint()
end

--[[
arrange - 理牌
参数：
1.当前牌级
返回：
1.true表示成功，false表示失败
]]
function CardViewEx:arrange(lv)
	local selecs, selecIndices = self:getSelectCard()

	if not selecIndices and #selecIndices == 0 then return false end

	local str = 'seleced cards = { '
	for i = 1, #selecIndices do
		str = string.format('%s %d', str, selecIndices[i])
	end
	print(str .. ' }')

	CardViewExLogic:arrange(selecIndices, lv)
	CardViewExLogic:resetThs()

	self:render()

	return true
end

--[[
setSelectCard1 - 设置手牌状态为不可点状态并置灰
参数：
1.cards - 待设置手牌
2.ignorehit - 是否忽略点击true表示忽略，false表示不忽略
]]
function CardViewEx:setSelectCard1(cards, ignorehit)
	if not cards or #cards == 0 then return end
	
	local indices = CardViewExLogic:getCardsIndices(cards)
	for i = 1, #indices do
		for j = 1, #self.cardSprites do
			if self.cardSprites[j].idx == indices[i] then
				self.cardSprites[j].status = true
				self.cardSprites[j].ignorehit = ignorehit 
				-- self.cardSprites[j].sprite:setColor(cc.c3b(128, 128, 128))
				self:setCardColor(self.cardSprites[j].sprite, cc.c3b(128, 128, 128))
			end
		end
	end
end

--[[
removeByCards - 删除指定手牌
参数：
1.手牌
]]
function CardViewEx:removeByCards(cards)
	CardViewExLogic:rmByCards(cards)
	CardViewExLogic:resetThs()

	self:render()
	CardViewExLogic:dumpInfo()
end

--[[
removeByIndices - 删除指定位置手牌
参数：
1.手牌
]]
function CardViewEx:removeByIndices(indices)
	CardViewExLogic:rmByIndices(indices)
	CardViewExLogic:resetThs()

	self:render()
	CardViewExLogic:dumpInfo()
end

return CardViewEx
