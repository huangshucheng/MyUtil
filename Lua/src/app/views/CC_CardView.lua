local CC_CardView = class("CC_CardView",cc.Layer)

local CC_CardSprite = require("app.views.CC_CardSprite")

CC_CardView.EventType = 
{
    EVENT_HIT_CARD = 0, --点击牌
    EVENT_NOT_HIT = 1   --没点击牌
}

function CC_CardView:ctor()
    printInfo("CC_CardView:ctor")

    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    self:onMemberAssigned()
    self:setCardSize(cc.size(120,159))
end

function CC_CardView:onMemberAssigned()
    self.m_cardRootNode = nil               --根节点，放所有牌

    self.m_cardImageFileName = nil          --文件名
    self.m_cardImageFilePrefix = nil        --文件路径（.png前加/）

    self.m_cardSize = cc.size(0,0)          --牌大小
    self.m_minHoriSpace = 0                 --最小水平距离
    self.m_maxHoriSpace = 0                 --最大水平距离
    self.m_minVertSpace = 0                 --最小垂直距离
    self.m_maxVertSpace = 0                 --最大垂直距离
    self.m_expandHoriSpace = 0              --水平拓展距离

    self.m_maxHeight = 0                    --最大高度
    self.m_maxWidth = display.width-140     --最大宽度

    self.m_currentHoriSpace = 0             --当前水平距离
    self.m_currentVertSpace = 0             --当前垂直距离

    self.m_lastShootedCardOrder = 1         --最后选中牌的zOrder(也是下标)

    self.m_moveAnimationEnabled = true      --是否有移动动画
    self.m_autoShootDown = true             --点其他地方牌自动非选中
    self.m_singleTopMode = false            --是否每次只能选中一张

    self.m_touchBeganPoint = cc.p(-1,-1)    --开始点击点
    self.m_beginTouchCardIndex = -1         --开始点击下标
    self.m_endTouchCardIndex = -1           --结束点击下标

    self.m_touchExpandCount = 5             --默认拓展数量
    self.m_shootAltitude = 30               --弹起高度

    self.m_cardViewCallback = nil           --点击回调
    
end
--[[
创建
cardImageFileName:文件名（xxxx.png）
]]
function CC_CardView:createWithFile(cardImageFileName)
    if not cc.FileUtils:getInstance():isFileExist(cardImageFileName) then 
        printInfo("CC_CardView->initWithFile<" .. cardImageFileName .. "> is nil") 
        return nil
    end
    local cv = CC_CardView.new()
    cv:initWithFile(cardImageFileName) 
    return cv
end

--[[
初始化
cardImageFileName:文件名（xxxx.png）
]]
function CC_CardView:initWithFile(cardImageFileName)
    if type(cardImageFileName) ~= "string" then return end
    self:setCardImageFile(cardImageFileName)
    self.m_cardRootNode = cc.SpriteBatchNode:create(cardImageFileName)
    if self.m_cardRootNode then
        self.m_cardRootNode:getTexture():setAliasTexParameters()--抗锯齿
	    self.m_cardRootNode:addTo(self)
    end
end
--[[
设置资源文件名
cardImageFileName:文件名（xxxx.png）
]]
function CC_CardView:setCardImageFile(cardImageFileName)
    if type(cardImageFileName) ~= "string" then return end
    if self.m_cardImageFileName == cardImageFileName then return end
    self.m_cardImageFileName = cardImageFileName
    local str = string.sub(self.m_cardImageFileName,1,string.find(self.m_cardImageFileName,'.png')-1)
    self.m_cardImageFilePrefix = str .. '/'

    local cardSp = self:createCardSprite(0x00)
    if cardSp then
        self:setCardSize(cardSp:getContentSize())
        printInfo("cardSpSize-> w:" .. cardSp:getContentSize().width .. ' ,h:' .. cardSp:getContentSize().height)
    end
    cardSp = nil
    --printInfo("CC_CardView->setCardImageFile-> m_cardImgFile: " .. self.m_cardImageFilePrefix)
end
--[[
创建单张牌
card:牌值
]]
function CC_CardView:createCardSprite(card)
    if type(card) ~= 'number' then return end
    local CardSprite =  CC_CardSprite:create(self.m_cardImageFilePrefix , card)
    if CardSprite then
        CardSprite:setCardView(self)
        return CardSprite
    end
end
--[[
设牌
cards:table值
]]
function CC_CardView:setCards(cards)
    if type(cards) ~= 'table' then printInfo("CC_CardView:setCards -> parm must be table") return end
    if not self.m_cardRootNode then return end
    local child_tb = self:getAllCardSprites()
    for i = 1 ,table.nums(cards) do
        if i <= table.nums(child_tb) then
            child_tb[i]:setCard(cards[i])
            child_tb[i]:setLocalZOrder(i)
        else
            local card_sp = self:createCardSprite(cards[i])
            if card_sp then
                card_sp:addTo(self.m_cardRootNode,i)
                card_sp:setLocalZOrder(i)
                printInfo("CC_CardView->addCard index: " .. i)
            end
        end
    end
    
    if table.nums(child_tb) > table.nums(cards) then
        for j = table.nums(child_tb) , table.nums(cards) + 1 , -1 do
            self.m_cardRootNode:removeChild(child_tb[j],true)
            printInfo("CC_CardView->remove index: " .. j)
        end
    end
    
    self:reorderCardDirty()
    self:updateCardMetrics()
end
--[[
设置单张牌size
]]
function CC_CardView:setCardSize(size)
    if type(size) ~= 'table' then return end
    self.m_cardSize = size
    self.m_minHoriSpace = self.m_cardSize.width / 5
    self.m_maxHoriSpace = self.m_cardSize.width * 3 / 5
    self.m_minVertSpace = self.m_cardSize.height / 3
    self.m_maxVertSpace = self.m_cardSize.height  / 2 
    self.m_expandHoriSpace = self.m_cardSize.width * 0.15
    self:updateCardMetrics()

    printInfo("m_minHoriSpace: " .. self.m_minHoriSpace)
    printInfo("m_maxHoriSpace: " .. self.m_maxHoriSpace)
    printInfo("m_minVertSpace: " .. self.m_minVertSpace)
    printInfo("m_maxVertSpace: " .. self.m_maxVertSpace)
    printInfo("m_expandHoriSpace: " .. self.m_expandHoriSpace) 
end
--[[
调整所有牌的位置
]]
function CC_CardView:updateCardMetrics()
    local child_tb = self:getAllCardSprites()
    if table.nums(child_tb) == 0 then return end

	local horiFixedSpace = self:calcAllCardSpriteHoriFixedSpace()
	local horiSpaceFactor = self:calcAllCardSpriteHoriSpaceFactor()
    local maxRow = 1

    if self.m_maxHeight ~= 0 and self.m_minVertSpace ~= 0 then 
         maxRow = math.ceil(self.m_maxHeight / self.m_minVertSpace) 
    end

    self.m_currentHoriSpace = self.m_maxWidth * maxRow - horiFixedSpace
    if horiSpaceFactor ~= 0 then
        self.m_currentHoriSpace = self.m_currentHoriSpace / horiSpaceFactor
    end

    self.m_currentVertSpace = self.m_maxHeight / maxRow
    self.m_currentHoriSpace = math.min(self.m_currentHoriSpace,self.m_maxHoriSpace)
    self.m_currentHoriSpace = math.max(self.m_currentHoriSpace,self.m_minHoriSpace)
    self.m_currentVertSpace = math.min(self.m_currentVertSpace,self.m_maxVertSpace)
    self.m_currentVertSpace = math.max(self.m_currentVertSpace,self.m_minVertSpace)

    local row_width_tb = {}
    local width , height = 0 , 0
    local horiIndex , vertIndex = 0 , 0

    for _ ,child_sp in pairs(child_tb) do
        if (width + child_sp:getHoriRealSpace()) > self.m_maxWidth then
            vertIndex = vertIndex + 1
            horiIndex = 0
            table.insert(row_width_tb,width)
            width = 0
            height = height + child_sp:getVertRealSpace()
        end
        child_sp:setDimensionIndex(horiIndex,vertIndex)
        if horiIndex ~= 0 then 
            width = width + child_sp:getHoriRealSpace() 
        end
        horiIndex = horiIndex + 1
    end

    table.insert(row_width_tb,width)
    local anchorPoint = self:getAnchorPoint()
    local x = 0
    local y = height * anchorPoint.y
    vertIndex = -1
    for _ ,child_sp in pairs(child_tb) do
        if child_sp:getVertIndex() ~= vertIndex then
            local vd = child_sp:getVertIndex()
            if row_width_tb[vd + 1] then
                x = - row_width_tb[vd + 1] * anchorPoint.x 
            end
            vertIndex = child_sp:getVertIndex()
            if vertIndex > 0 then
                y = y - child_sp:getVertRealSpace() 
            end
        end
        if child_sp:getHoriIndex() ~= 0 then 
            x = x + child_sp:getHoriRealSpace() 
        end
        child_sp:setNormalPos(cc.p(x,y))
    end
end
--[[
更新所有牌的LocalZorder
]]
function CC_CardView:reorderCardDirty()
    local child_tb = self:getAllCardSprites()
    if table.nums(child_tb) == 0 then return end
    for idx = 1 , table.nums(child_tb) do
        child_tb[idx]:setLocalZOrder(idx)
    end
end
--[[
更新选中牌的 localZorder
]]
function CC_CardView:sortShootedCards()
    local child_tb = self:getAllCardSprites()
    if table.nums(child_tb) == 0 then return end
    local shooted_tb = {}
    for _ , v in pairs(child_tb) do
        if v:isShooted() then table.insert(shooted_tb,v) end
    end

    local function compare(cdSp_A,cdSp_B)
        return cdSp_A:getShootedOrder() < cdSp_B:getShootedOrder()
    end
    table.sort(shooted_tb,compare)

    for idx = 1 , table.nums(shooted_tb) do
        shooted_tb[idx]:setShootedOrder(idx+1)
    end
    self.m_lastShootedCardOrder = table.nums(shooted_tb) + 1
end
--[[
计算水平距离
]]
function CC_CardView:calcAllCardSpriteHoriFixedSpace()
    local space = 0
    local child_tb = self:getAllCardSprites()
    if table.nums(child_tb) == 0 then return space end
    for _, cardSprite in pairs(child_tb) do
        if cardSprite:getHoriFixedSpace() == 0 and cardSprite:getLocalZOrder() ~= 0 then
            space = space + cardSprite:getHoriFixedSpace()
        end
    end
    return space
end
--[[
计算水平距离因子
]]
function CC_CardView:calcAllCardSpriteHoriSpaceFactor()
    local factor = 0
    local child_tb = self:getAllCardSprites()
    if table.nums(child_tb) == 0 then return factor end
    for _, cardSprite in pairs(child_tb) do
        if cardSprite:getHoriFixedSpace()== 0 and cardSprite:getLocalZOrder() ~= 0 then
            factor = factor + cardSprite:getHoriSpaceFactor()
        end
    end
    return factor
end
--[[
开始触摸屏幕事件
]]
function CC_CardView:onTouchesBegan(touches, event)
    local touches_size = table.nums(touches)
    if touches_size <= 0 then return end
    local touch = touches[touches_size]
    self.m_touchBeganPoint = self:convertToNodeSpace(touch:getLocation())
    self.m_beginTouchCardIndex = self:getHitCardIndexForPos(self.m_touchBeganPoint)
    printInfo("m_beginTouchCardIndex---------------> " .. self.m_beginTouchCardIndex)
end
--[[
触摸移动事件
]]
function CC_CardView:onTouchesMoved(touches, event)
    local touches_size = table.nums(touches)
    if touches_size <= 0 then return end
    local touch = touches[touches_size]
    if self.m_beginTouchCardIndex ~= -1 then
        local touchPoint = self:convertToNodeSpace(touch:getLocation())
        local cardIndex = self:getHitCardIndexForPos(touchPoint)
        if cardIndex ~= -1 then
            self:setCardsSelect(self.m_beginTouchCardIndex,self.m_endTouchCardIndex,false)
            self.m_endTouchCardIndex = cardIndex
            self:setCardsSelect(self.m_beginTouchCardIndex,self.m_endTouchCardIndex,true)
        end
    end
end
--[[
触摸结束事件
]]
function CC_CardView:onTouchesEnded(touches, event)
    local touches_size = table.nums(touches)
    if touches_size <= 0 then return end
    local touch = touches[touches_size]
    local touchPoint = self:convertToNodeSpace(touch:getLocation())
    self.m_endTouchCardIndex = self:getHitCardIndexForPos(touchPoint)
    self:setCardsSelect(1,self:getCardCount() ,false)
    if self.m_beginTouchCardIndex ~= -1 and self.m_endTouchCardIndex ~= -1 then
    --[[  TODO  只选中一张
        if self.m_singleTopMode then
            if self.m_beginTouchCardIndex == self.m_endTouchCardIndex then
                self:flipCardsShoot(self.m_beginTouchCardIndex,self.m_endTouchCardIndex)
            end
            local shoot_sp = self:getShootedCardsSpriteByOrder()
            local count = table.nums(shoot_sp)
            printInfo("shoot count:" .. count)
            if count == 2 then
                shoot_sp[count]:setShooted(false)
            end
        else
            self:flipCardsShoot(self.m_beginTouchCardIndex,self.m_endTouchCardIndex)
        end
        ]]
        self:flipCardsShoot(self.m_beginTouchCardIndex,self.m_endTouchCardIndex)
        self:dispatchCardShootChangedEvent(CC_CardView.EventType.EVENT_HIT_CARD)
    else
        if self.m_autoShootDown then self:setAllCardsShoot(false) end
        self:dispatchCardShootChangedEvent(CC_CardView.EventType.EVENT_NOT_HIT)
    end

    printInfo("m_endTouchCardIndex-----------------> " .. self.m_endTouchCardIndex .. "\n\n")
    self.m_beginTouchCardIndex = -1
    self.m_endTouchCardIndex = -1
    self.m_touchBeganPoint = cc.p(0,0)
end
--[[
获取点击的牌的下标（也就是zorder）
]]
function CC_CardView:getHitCardIndexForPos(point)
    if type(point) ~= 'table' then return end
    local child_tb = self:getAllCardSprites()
    for idx = table.nums(child_tb) , 1 , -1 do
        if child_tb[idx]:isVisible() then
            if cc.rectContainsPoint(child_tb[idx]:getBoundingBox(),point) then
                if not child_tb[idx]:isDisabled() then
                    return child_tb[idx]:getLocalZOrder()
                end 
            end
        end
    end
    return -1
end
--[[
设置牌是否选中
beginIndex:开始下标
endIndex:结束下标
isSel:是否选中（默认选中）
]]
function CC_CardView:setCardsSelect(beginIndex , endIndex , isSel)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if isSel == nil then isSel = true end
    local child_tb = self:getAllCardSprites()
    if table.nums(child_tb) == 0 then return end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end
    beginIndex = math.max(0 , beginIndex)
    endIndex = math.min(table.nums(child_tb) , endIndex)
    for idx = beginIndex , endIndex do
        if child_tb[idx] then
            if not child_tb[idx]:isDisabled() then
                child_tb[idx]:setSelected(isSel) 
            end
        end
    end
end
--[[
拓展牌
index:当前选中牌
count:拓展数量
]]
function CC_CardView:expandCards(index , count)
    if type(index)~= 'number' or type(count) ~= 'number' then return end
    local beginIndex = math.ceil(index - count / 2) 
    local endIndex = math.ceil(index + count / 2)
    self:adjustAllCardSpriteSpace()
    self:setCardsExpand(beginIndex,endIndex,true)
end
--[[
调整所有牌位置
]]
function CC_CardView:adjustAllCardSpriteSpace()
    for _ ,cardSprite in pairs(self:getAllCardSprites()) do
        self:adjustCardSpriteSpace(cardSprite)
    end
    self:updateCardMetrics()
end
--[[
拓展牌
beginIndex:开始下标
endIndex:结束下标
expand:是否拓展
]]
function CC_CardView:setCardsExpand(beginIndex , endIndex , expand)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if expand == nil then expand = true end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end

    local child_tb = self:getAllCardSprites()
    beginIndex = math.max(0 , beginIndex)
    endIndex = math.min(table.nums(child_tb) , endIndex)

    for idx = beginIndex , endIndex do
        if child_tb[idx] then
            if not child_tb[idx]:isExpanded() and expand then
                child_tb[idx]:setHoriFixedSpace(self.m_maxHoriSpace)
            elseif not expand and child_tb[idx]:isExpanded() then
                child_tb[idx]:setHoriFixedSpace(0)
            end
            child_tb[idx]:setExpanded(expand)
        end
    end
    self:updateCardMetrics()
end
--[[
设置牌为选中或非选中
beginIndex:开始下标
endIndex:结束下标
]]
function CC_CardView:flipCardsShoot(beginIndex , endIndex)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end
    local child_tb = self:getAllCardSprites()
    beginIndex = math.max(0 , beginIndex)
    endIndex = math.min(table.nums(child_tb) , endIndex)

    for idx = beginIndex , endIndex do
        if child_tb[idx] then
            if not child_tb[idx]:isDisabled() then
                child_tb[idx]:setShooted(not child_tb[idx]:isShooted())
            end
        end
    end
    self:updateCardMetrics()
end
--[[
调整牌空间
cardSprite:牌节点
]]
function CC_CardView:adjustCardSpriteSpace(cardSprite)
    if type(cardSprite) ~= 'userdata' then return end
    cardSprite:setHoriFixedSpace(0)
    cardSprite:setHoriSpaceFactor(1)
    cardSprite:setExpanded(false)
end
--[[
调整选中牌顺序
cardSprite:牌节点
]]
function CC_CardView:reorderCardShootedOrder(cardSprite)
    if type(cardSprite) ~= 'userdata' then return  end
    self:sortShootedCards()
    if not cardSprite:isShooted() then
        cardSprite:setShootedOrder(-1)
    else
        cardSprite:setShootedOrder(self.m_lastShootedCardOrder + 1)
    end
end
-----------------------------------------------get or set->start
--获取选中高度
function CC_CardView:getShootAltitude()
    return self.m_shootAltitude
end
--设置选中高度
function CC_CardView:setShootAltitude(altitude)
    if type(altitude) ~= 'number' then return end
    if self.m_shootAltitude == altitude then return end
    self.m_shootAltitude = altitude
end
--获取最小水平距离
function CC_CardView:getMinHoriSpace()
    return self.m_minHoriSpace
end
--设置最小水平距离
function CC_CardView:setMinHoriSpace(val)
    if type(val) ~= 'number' then return end
    if self.m_minHoriSpace == val then return end
    self.m_minHoriSpace = val
    self.m_maxHoriSpace = math.max(val , self.m_maxHoriSpace)
    self:updateCardMetrics()
end
--获取最大水平距离
function CC_CardView:getMaxHoriSpace()
    return self.m_maxHoriSpace
end
--设置最大水平距离
function CC_CardView:setMaxHoriSpace(val)
    if type(val) ~= 'number' then return end
    if self.m_maxHoriSpace == val then return end
    self.m_maxHoriSpace = val
    self.m_minHoriSpace = math.min(val , self.m_minHoriSpace)
    self:updateCardMetrics()
end
--获取最大水平距离
function CC_CardView:getMinVertSpace()
    return self.m_minVertSpace
end
--设置最大水平距离
function CC_CardView:setMinVertSpace(val)
    if type(val) ~= 'number' then return end
    if self.m_minVertSpace == val then return end
    self.m_minVertSpace = val
    self:updateCardMetrics()
end
--取最大垂直距离
function CC_CardView:getMaxVertSpace()
    return self.m_maxVertSpace
end
--设置最大垂直距离
function CC_CardView:setMaxVertSpace(val)
    if type(val) ~= 'number' then return end
    if self.m_maxVertSpace == val then return end
    self.m_maxVertSpace = val
    self:updateCardMetrics()
end
--获取最大宽
function CC_CardView:getMaxWidth()
    return self.m_maxWidth
end
--设置最大宽
function CC_CardView:setMaxWidth(width)
    if type(width) ~= 'number' then return end
    if self.m_maxWidth == width then return end
    self.m_maxWidth = width
    self:updateCardMetrics()
end
--获取最大高
function CC_CardView:getMaxHeight()
    return self.m_maxHeight
end
--设置最大高
function CC_CardView:setMaxHeight(height)
    if type(height) ~= 'number' then return end
    if self.m_maxHeight == height then return end
    self.m_maxHeight = height
    self:updateCardMetrics()
end
--获取单张牌宽
function CC_CardView:getCardWidth()
    return self.m_cardSize.width
end
--获取单张牌高
function CC_CardView:getCardHeight()
    return self.m_cardSize.height
end
--获取单张牌大小
function CC_CardView:getCardSize()
    return self.m_cardSize
end
--设置点击拓展牌数量
function CC_CardView:setTouchExpandCount(count)
    if type(count) ~= 'number' then return end
    self.m_touchExpandCount = count
end
--设置拓展水平距离
function CC_CardView:setExpandHoriSpace(val)
    if type(val) ~= 'number' then return end
    self.m_expandHoriSpace = val
end
--获取当前水平距离
function CC_CardView:getCurrentHoriSpace()
    return self.m_currentHoriSpace
end
--设置当前水平距离
function CC_CardView:setCurrentHoriSpace(val)
    if type(val) ~= 'number' then return end
    self.m_currentHoriSpace = val
end
--获取当前垂直距离
function CC_CardView:getCurrentVertSpace()
    return self.m_currentVertSpace
end
--设置当前垂直距离
function CC_CardView:setCurrentVerSpace(val)
    if type(val) ~= 'number' then return end
    self.m_currentVertSpace = val
end
--是否显示动画
function CC_CardView:isMoveAnimationEnabled()
    return self.m_moveAnimationEnabled
end
--设置是否显示动画
function CC_CardView:setMoveAnimationEnable(enable)
    if type(enable) ~= 'boolean' then return end
    self.m_moveAnimationEnabled = enable
end

function CC_CardView:isSingleTopMode()
    return self.m_singleTopMode
end

function CC_CardView:setSingleTopMode(enable)
    if type(enable) ~= 'boolean' then return end
    self.m_singleTopMode = enable
end
-----------------------------------------------get or set->end

-----------------------------------------------操做牌->start
--[[获取牌数量]]
function CC_CardView:getCardCount()
    return table.nums(self:getAllCardSprites())
end
--[[返回所有牌节点]]
function CC_CardView:getAllCardSprites()
    if not self.m_cardRootNode then return {} end
    return self.m_cardRootNode:getChildren()
end
--[[
获取牌下标
cards:牌值table
]]
function CC_CardView:getCardsIndex(cards)
    if type(cards) ~= 'table' then return end
    local index_tb = {}
    local child_tb = self:getAllCardSprites()
    for _ , child in pairs(child_tb) do
        for _ , value in pairs(cards) do
            if child:getCard() == value then
               table.insert(index_tb,child:getLocalZOrder()) 
            end
        end
    end
    return index_tb
end
--[[
获取牌值
index:下标
]]
function CC_CardView:getCard(index)
    if type(index) ~= 'number' then return 0x00 end
    if index > self:getCardCount() or index <= 0 then return 0x00 end
    return self:getAllCardSprites()[index]:getCard()
end
--[[
获取所有牌值
返回值：所有牌值
]]
function CC_CardView:getCards()
    local card_value_tb = {}
    for _ ,card in pairs(self:getAllCardSprites()) do 
        table.insert(card_value_tb , card:getCard()) 
    end
    return card_value_tb
end
--[[
获取牌节点
index:下标
]]
function CC_CardView:getCardSprite(index)
    if type(index) ~= 'number' then return end
    if index <= 0 or index > self:getCardCount() then return end
    return self:getAllCardSprites()[index]
end
--[[
查找牌值==card的所有节点
card:牌值
]]
function CC_CardView:findCardSprite(card)
    if type(card) ~= 'number' then return {} end
    local child_tb = self:getAllCardSprites()
    local find_tb = {}
    for _ ,cardSprite in pairs(child_tb) do
        if cardSprite:getCard() == card then
            table.insert(find_tb,cardSprite)
        end
    end
    return find_tb
end
--[[
插入一张牌
index:下标
card:牌值
]]
function CC_CardView:insertCard(index,card)
    if type(index) ~= 'number' or type(card) ~= 'number' then return end
    if not self.m_cardRootNode then return end
    index = math.max(index , 1)
    index = math.min(index , self:getCardCount())

    local cardSprite = self:createCardSprite(card)
    if cardSprite then
        cardSprite:addTo(self.m_cardRootNode,index)
        cardSprite:setLocalZOrder(index)
        self:reorderCardDirty()
        self:updateCardMetrics()
        return cardSprite
    end
end
--[[
插入牌一坨牌
index:下标
cards:牌值table
]]
function CC_CardView:insertCards(index,cards)
    if type(index) ~= 'number' or type(cards) ~= 'table' then return end
    if not self.m_cardRootNode then return end
    index = math.max(index , 1)
    index = math.min(index , self:getCardCount())
    for i = 1 , table.nums(cards) do
        local cd_sp = self:createCardSprite(cards[i])
        if cd_sp then
            self.m_cardRootNode:addChild(cd_sp , index + i)
        end
    end
    self:reorderCardDirty()
    self:updateCardMetrics()
end
--[[
添加一张牌
card:牌值
]]
function CC_CardView:addCard(card)
    return self:insertCard(self:getCardCount(),card)
end
--[[
添加牌一坨牌
cards:牌值table
]]
function CC_CardView:addCards(cards)
    self:insertCards(self:getCardCount() , cards)
end
--[[
删除一张牌  若有相同的牌，只删除一张
card:牌值
]]
function CC_CardView:removeCard(card)
    if not self.m_cardRootNode then return false end
    local cardSprite_tb = self:findCardSprite(card)
    if table.nums(cardSprite_tb) == 0 then return false end
    if cardSprite_tb[1] then
        self.m_cardRootNode:removeChild(cardSprite_tb[1] , true)
    end
    self:reorderCardDirty()
    self:updateCardMetrics()
    return true
end
--[[
删除一张牌
index:下标
]]
function CC_CardView:removeCardByIndex(index)
    if not self.m_cardRootNode then return false end
    local cardSprite = self:getCardSprite(index)
    if not cardSprite then return false end
    self.m_cardRootNode:removeChild(cardSprite , true)
    self:reorderCardDirty()
    self:updateCardMetrics()
    return true
end
--[[
删除一坨牌
cards:牌值table
]]
function CC_CardView:removeCards(cards)
    if type(cards) ~= 'table' then return end
    for _ , cd in pairs(cards) do self:removeCard(cd) end
    self:reorderCardDirty()
    self:updateCardMetrics()
end
--[[
删除一坨牌
indexs:牌下标table
]]
function CC_CardView:removeCardsByIndex(indexs)
    if type(indexs) ~= 'table' then return end
    if not self.m_cardRootNode then return end
    local cardSprite_tb = {}
    for _ , idx in pairs(indexs)do
        local card_sp = self:getCardSprite(idx)
        if card_sp then
            table.insert(cardSprite_tb , card_sp)
        end
    end
    for _ , child in pairs(cardSprite_tb)do
        self.m_cardRootNode:removeChild(child , true)
    end
    self:reorderCardDirty()
    self:updateCardMetrics()
end
--[[
删除所有选中牌
]]
function CC_CardView:removeShootedCards()
    if not self.m_cardRootNode then return end
    local shoot_tb = self:getAllShootedCaredSprite()
    if table.nums(shoot_tb)> 0  then
        for _ , cardSp in pairs(shoot_tb)do
            self.m_cardRootNode:removeChild(cardSp,true)
        end
    end
    self:reorderCardDirty()
    self:updateCardMetrics()
end
--[[
删除所有牌
]]
function CC_CardView:clearCards()
    if self.m_cardRootNode then
        self.m_cardRootNode:removeAllChildren()
    end
end
-----------------------------------------------操做牌->end

-----------------------------------------------牌选中管理->start
--[[
设置所有牌是否选中
]]
function CC_CardView:setAllCardsShoot(shoot)
    self:setCardsShoot(1,self:getCardCount(),shoot)
end
--[[
设置牌是否选中
beginIndex:开始下标
endIndex:结束下标
shoot:是否选中
]]
function CC_CardView:setCardsShoot(beginIndex,endIndex,shoot)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if shoot == nil then shoot = true end
    if type(shoot) ~= 'boolean' then return end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end
    local child_tb = self:getAllCardSprites()
    beginIndex = math.max(0 , beginIndex)
    endIndex = math.min(table.nums(child_tb) , endIndex)
    for idx = beginIndex , endIndex do
        if child_tb[idx] then
            child_tb[idx]:setShooted(shoot)
        end
    end
    self:updateCardMetrics()
end
--[[
设置单张牌是否选中
card:牌值
shoot:是否选中
]]
function CC_CardView:setCardShoot(card,shoot)
    local card_tb = self:findCardSprite(card)
    if not card_tb then return end
    if table.nums(card_tb) > 0 then
        for _ ,card_sp in pairs(card_tb) do
            if card_sp:isShooted() ~= shoot then
                card_sp:setShooted(shoot)
                break
            end
        end
    end
    self:updateCardMetrics()
end
--[[
设置牌是否选中
cards:牌值table
shoot:是否选中
]]
function CC_CardView:setCardsShootByCardTable(cards,shoot)
    if type(cards) ~= 'table' or type(shoot) ~= 'boolean' then return end
    if table.nums(cards) == 0 then return end
    local child_tb = self:getAllCardSprites()
    for _ , card in pairs(cards) do 
        for _ , card_sp in pairs(child_tb) do
            if card_sp:getCard() == card and card_sp:isShooted() ~= shoot then
                card_sp:setShooted(shoot)
                break
            end
        end
    end
    self:updateCardMetrics()
end
--[[
是否选中
index:下标
]]
function CC_CardView:isCardShooted(index)
    local cardSprite = self:getCardSprite(index)
    if cardSprite then return cardSprite:isShooted() end
    return false
end
--[[获取选中牌数量]]
function CC_CardView:getShootedCardCount()
    return table.nums(self:getShootedCards())
end
--[[
获取所有选中牌节点
返回值：所有选中牌的节点
]]
function CC_CardView:getAllShootedCaredSprite()
    local shoot_sp_tb = {}
    local child_tb = self:getAllCardSprites()
    for _ ,card_sp in pairs(child_tb)do
        if card_sp:isShooted() then
            table.insert(shoot_sp_tb , card_sp)
        end
    end
    return shoot_sp_tb
end
--[[
获取所有非选中牌节点
返回值：所有非选中牌的节点
]]
function CC_CardView:getAllUnShootedCardSprite()
    local unshoot_sp_tb = {}
    local child_tb = self:getAllCardSprites()
    for _ ,card_sp in pairs(child_tb)do
        if not card_sp:isShooted() then
            table.insert(unshoot_sp_tb , card_sp)
        end
    end
    return unshoot_sp_tb
end
--[[
获取选中牌
返回值：所有选中牌的值
]]
function CC_CardView:getShootedCards()
    local shoot_tb = {}
    local shoot_sp_tb = self:getAllShootedCaredSprite()
    for _ , card_sp in pairs(shoot_sp_tb)do
        if card_sp:isShooted() then table.insert(shoot_tb,card_sp:getCard()) end
    end
    return shoot_tb
end
--[[获取选中牌下标
返回值：所有选中牌的下标
]]
function CC_CardView:getShootedCardsIndex()
    local shoot_idx_tb = {}
    local shoot_sp_tb = self:getAllShootedCaredSprite()
    for _ , card_sp in pairs(shoot_sp_tb)do
        if card_sp:isShooted() then table.insert(shoot_idx_tb,card_sp:getLocalZOrder()) end
    end
    return shoot_idx_tb
end
--[[
根据选中顺序获取选中牌(最后选中的牌排在最后)
返回值：所有选中牌的值
]]
function CC_CardView:getShootedCardsByOrder()
    local cards_sp_tb = self:getShootedCardsSpriteByOrder()
    local cards_tb = {}
    for _ , card in pairs(cards_sp_tb) do
        table.insert(cards_tb,card)
    end
    return cards_tb
end
--[[
根据选中顺序获取选中牌(最后选中的牌排在最后)
返回值：选中牌节点
]]
function CC_CardView:getShootedCardsSpriteByOrder()
   local shoot_sp_tb = self:getAllShootedCaredSprite()
    local card_tb = {}
    local function compare(cdSp_A,cdSp_B)
        return cdSp_A:getShootedOrder() < cdSp_B:getShootedOrder()
    end
    table.sort(shoot_sp_tb,compare)
    for _ , card_sp in pairs(shoot_sp_tb) do
        table.insert(card_tb,card_sp)
    end
    return card_tb
end
--[[
获取非选中牌
返回值：所有非选中牌值
]]
function CC_CardView:getUnshootedCards()
    local unshoot_tb = {}
    local unshoot_sp_tb = self:getAllUnShootedCardSprite()
    for _ , card_sp in pairs(unshoot_sp_tb)do
        if not card_sp:isShooted() then 
            table.insert(unshoot_tb,card_sp:getCard()) 
        end
    end
    return unshoot_tb
end
--[[手牌整体缩放]]
function CC_CardView:setCardViewScale(scale)
    if type(scale) ~= 'number' then return end
    --self:setCardSize(cc.size(self.m_cardSize.width * scale,self.m_cardSize.height * scale))
end
--[[发送事件]]
function CC_CardView:dispatchCardShootChangedEvent(eventType)
    if self.m_cardViewCallback then
        self.m_cardViewCallback(self,eventType)
    end
end
--[[添加事件]]
function CC_CardView:addCardViewEventListener(cardViewCallback)
    if type(cardViewCallback) ~= 'function' then return end
    self.m_cardViewCallback = cardViewCallback
end
-----------------------------------------------牌选中管理->end
--注册事件
function CC_CardView:onEnter()
    printInfo("CC_CardView:onEnter")
    local function onTouchesBegan(touches, event)self:onTouchesBegan(touches,event) end
    local function onTouchesMoved(touches, event)self:onTouchesMoved(touches,event) end
    local function onTouchesEnded(touches, event)self:onTouchesEnded(touches,evnet) end
    local listener = cc.EventListenerTouchAllAtOnce:create()    
    listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
    self._listener = listener
end

function CC_CardView:onExit()
    printInfo("CC_CardView:onExit")
    if self._listener then
        self:getEventDispatcher():removeEventListener(self._listener)
    end
end

return CC_CardView