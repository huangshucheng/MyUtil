local CardView = class("CardView",cc.Layer)

local CardSprite = import(".CardSprite")

CardView.EventType = 
{
    EVENT_HIT_CARD = 0,     --点击牌
    EVENT_NOT_HIT = 1       --没点击牌
}

function CardView:ctor()
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    self:Init()
end

function CardView:Init()
    self.m_rootNode         = nil               --根节点，放所有牌
    self.m_imgFile          = nil               --文件路径（.png前加/）
    self.m_cardCallback     = nil               --点击回调

    self.m_cardSize         = cc.size(120,159)  --牌大小
    self.m_minHoriSpace     = 0                 --最小水平距离
    self.m_maxHoriSpace     = 0                 --最大水平距离
    self.m_minVertSpace     = 0                 --最小垂直距离
    self.m_maxVertSpace     = 0                 --最大垂直距离
    self.m_expandSpace      = 0                 --水平拓展距离
    self.m_curHoriSpace     = 0                 --当前水平距离
    self.m_curVertSpace     = 0                 --当前垂直距离

    self.m_maxHeight        = 0                 --最大高度
    self.m_maxWidth         = display.width-140 --最大宽度

    self.m_aniEnabled       = true              --是否有动画
    self.m_autoShootDown    = true              --点桌面牌下来
    self.m_singleTopMode    = false             --是否单点触摸模式
    self.m_touchEnabled     = false             --是否可触摸
    self.m_isExpand         = false             --是否可拓展
    self.m_isTouching       = false             --是否正在点击

    self.m_lastOrder        = 1                 --最后选中牌zOrder
    self.m_startIndex       = -1                --开始点击下标
    self.m_endIndex         = -1                --结束点击下标
    self.m_expandCount      = 5                 --默认拓展数量
    self.m_shootHeight      = 30                --弹起高度

end
--[[
创建
fileStr:文件名（xxxx.png）
需要预加载.plist .png
]]
function CardView:createWithFile(fileStr)
    if not cc.FileUtils:getInstance():isFileExist(fileStr) then 
        printInfo("CardView->initWithFile<" .. fileStr .. "> is nil") 
        return nil
    end
    local cv = CardView.new()
    cv:initWithFile(fileStr) 
    return cv
end

--[[
初始化
fileStr:文件名（xxxx.png）
]]
function CardView:initWithFile(fileStr)
    if type(fileStr) ~= "string" then return end
    self.m_imgFile = string.sub(fileStr,1,string.find(fileStr,'.png')-1) .. '/'
    local cardSp = self:createCardSprite(0x00)
    if cardSp then self:setCardSize(cardSp:getContentSize()) end
    self.m_rootNode = cc.Node:create():addTo(self):move(display.left_bottom)
    --self.m_rootNode = cc.SpriteBatchNode:create(fileStr):addTo(self):move(display.left_bottom)
end
--[[
创建单张牌
card:牌值
]]
function CardView:createCardSprite(card)
    if type(card) ~= 'number' then return end
    local CardSprite =  CardSprite:create(self.m_imgFile , card)
    if CardSprite then
        CardSprite:setCardView(self)
        return CardSprite
    end
end
--[[
设牌
cards:table值
]]
function CardView:setCards(cards)
    if type(cards) ~= 'table' then printInfo("CardView:setCards -> parm must be table") return end
    if not self.m_rootNode then return end
    local child_tb = self:getAllCardSprites()
    for i = 1 ,table.nums(cards) do
        if i <= table.nums(child_tb) then
            child_tb[i]:setCard(cards[i])
            child_tb[i]:setLocalZOrder(i)
        else
            local card_sp = self:createCardSprite(cards[i])
            if card_sp then card_sp:addTo(self.m_rootNode,i) end
        end
    end
    
    if table.nums(child_tb) > table.nums(cards) then
        for j = table.nums(child_tb) , table.nums(cards) + 1 , -1 do
            child_tb[j]:removeSelf()
        end
    end
    self:updateOrderAndSpace()
end
--[[
设置单张牌参数
]]
function CardView:setCardSize(size)
    if type(size) ~= 'table' then return end
    self.m_cardSize     = size
    self.m_minHoriSpace = self.m_cardSize.width  / 5
    self.m_maxHoriSpace = self.m_cardSize.width  * 4 / 6
    self.m_minVertSpace = self.m_cardSize.height / 3
    self.m_maxVertSpace = self.m_cardSize.height / 2 
    self.m_expandSpace  = self.m_maxHoriSpace
    self:updateCardMetrics()
    
    printInfo("CardView->m_minHoriSpace: " .. self.m_minHoriSpace)
    printInfo("CardView->m_maxHoriSpace: " .. self.m_maxHoriSpace)
    printInfo("CardView->m_minVertSpace: " .. self.m_minVertSpace)
    printInfo("CardView->m_maxVertSpace: " .. self.m_maxVertSpace)
    printInfo("CardView->m_expandSpace:  " .. self.m_expandSpace) 
end
--[[
调整所有牌的位置
]]
function CardView:updateCardMetrics()
    local child_tb = self:getAllCardSprites()
    if table.nums(child_tb) == 0 then return end

	local horiFixedSpace  = self:calcHoriFixedSpace()
	local horiSpaceFactor = self:calcHoriSpaceFactor()
    local maxRow = 1

    if self.m_maxHeight ~= 0 and self.m_minVertSpace ~= 0 then 
         maxRow = math.ceil(self.m_maxHeight / self.m_minVertSpace) 
    end

    self.m_curHoriSpace = self.m_maxWidth * maxRow - horiFixedSpace
    if horiSpaceFactor ~= 0 then
        self.m_curHoriSpace = self.m_curHoriSpace / horiSpaceFactor
    end

    self.m_curVertSpace = self.m_maxHeight / maxRow
    self.m_curHoriSpace = math.min(self.m_curHoriSpace,self.m_maxHoriSpace)
    self.m_curHoriSpace = math.max(self.m_curHoriSpace,self.m_minHoriSpace)
    self.m_curVertSpace = math.min(self.m_curVertSpace,self.m_maxVertSpace)
    self.m_curVertSpace = math.max(self.m_curVertSpace,self.m_minVertSpace)

    local row_width_tb          = {}
    local width , height        = 0 , 0
    local horiIndex , vertIndex = 0 , 0

    for _ ,child_sp in pairs(child_tb) do
        if (width + child_sp:getHoriRealSpace()) > self.m_maxWidth then
            vertIndex = vertIndex + 1
            horiIndex = 0
            table.insert(row_width_tb,width)
            width   = 0
            height  = height + child_sp:getVertRealSpace()
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
function CardView:reorderCardDirty()
    local child_tb = self:getAllCardSprites()
    if table.nums(child_tb) == 0 then return end
    for idx = 1 , table.nums(child_tb) do
        child_tb[idx]:setLocalZOrder(idx)
    end
end
--[[更新order,空间]]
function CardView:updateOrderAndSpace()
    self:reorderCardDirty()
    self:updateCardMetrics()
end
--[[
更新选中牌的 localZorder
]]
function CardView:sortShootedCards()
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
    self.m_lastOrder = table.nums(shooted_tb) + 1
end
--[[
水平距离
]]
function CardView:calcHoriFixedSpace()
    local space = 0
    local child_tb = self:getAllCardSprites()
    if table.nums(child_tb) == 0 then return space end
    for _, cardSprite in pairs(child_tb) do
        if cardSprite:getHoriFixedSpace() ~= 0 and cardSprite:getLocalZOrder() ~= 0 then
            space = space + cardSprite:getHoriFixedSpace()
        end
    end
    return space
end
--[[
水平距离因子
]]
function CardView:calcHoriSpaceFactor()
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
开始触摸
]]
function CardView:onTouchBegan(touch, event)
    if not self.m_rootNode then return end
    if not self.m_touchEnabled or self.m_isTouching then return false end
    self.m_isTouching     = true
    local touchBeginPoint = self.m_rootNode:convertToNodeSpace(touch:getLocation())
    self.m_startIndex     = self:getHitCardIndexForPos(touchBeginPoint)
    return true
end
--[[
触摸移动
]]
function CardView:onTouchMoved(touch, event)
    if not self.m_rootNode then return end
    if not self.m_touchEnabled then return end
    if self.m_startIndex ~= -1 then
        local touchPoint = self.m_rootNode:convertToNodeSpace(touch:getLocation())
        local cardIndex  = self:getHitCardIndexForPos(touchPoint)
        if cardIndex ~= -1 then
            self:setCardsSelect(self.m_startIndex,self.m_endIndex,false)
            self.m_endIndex = cardIndex
            self:setCardsSelect(self.m_startIndex,self.m_endIndex,true)
        end
    end
end
--[[
触摸结束
]]
function CardView:onTouchEnded(touch, event)
    if not self.m_rootNode then return end
    if not self.m_touchEnabled then return end
    self.m_isTouching = false
    local touchPoint = self.m_rootNode:convertToNodeSpace(touch:getLocation())
    self:setCardsSelect(1,self:getCardCount() ,false)
    self.m_endIndex = self:getHitCardIndexForPos(touchPoint)
    if self.m_startIndex ~= -1 and self.m_endIndex ~= -1 then
        if self.m_startIndex == self.m_endIndex and self.m_isExpand then
            local pSprite = self:getCardSprite(self.m_startIndex)
            if not pSprite:isExpanded() then
                self:expandCards(self.m_startIndex,self.m_expandCount)
            end
        end
        self:flipCardsShoot(self.m_startIndex,self.m_endIndex)
        self:doSingleTopMode()
        self:dispatchCardShootChangedEvent(CardView.EventType.EVENT_HIT_CARD)
    else
        if self.m_autoShootDown then self:setAllCardsShoot(false) end
        self:dispatchCardShootChangedEvent(CardView.EventType.EVENT_NOT_HIT)
    end
    self.m_startIndex , self.m_endIndex = -1 , -1
end
--[[触摸取消]]
function CardView:onTouchCancelled(touch, event)
    self.m_isTouching = false
    self.m_startIndex , self.m_endIndex = -1 , -1
end
--[[
获取点击的牌的下标（也就是zorder）
]]
function CardView:getHitCardIndexForPos(point)
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
function CardView:setCardsSelect(beginIndex , endIndex , isSel)
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
牌还原位置
]]
function CardView:adjustAllCardSpriteSpace()
    for _ , card in pairs(self:getAllCardSprites()) do
        card:setHoriFixedSpace(0)
        card:setHoriSpaceFactor(1)
        card:setExpanded(false)
    end
    self:updateCardMetrics()
end
--[[
拓展牌
index:当前选中牌
count:拓展数量
]]
function CardView:expandCards(index , count)
    if type(index)~= 'number' or type(count) ~= 'number' then return end
    local beginIndex = math.ceil(index - count / 2)
    local endIndex   = math.ceil(index + count / 2)
    self:adjustAllCardSpriteSpace()
    self:setCardsExpand(beginIndex,endIndex,true)
end
--[[
拓展牌
beginIndex:开始下标
endIndex:结束下标
expand:是否拓展
]]
function CardView:setCardsExpand(beginIndex , endIndex , expand)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if expand == nil then expand = true end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end

    local child_tb = self:getAllCardSprites()
    beginIndex = math.max(0 , beginIndex)
    endIndex   = math.min(table.nums(child_tb) , endIndex)

    for idx = beginIndex , endIndex do
        if child_tb[idx] then
            if (not child_tb[idx]:isExpanded()) and expand then
                child_tb[idx]:setHoriFixedSpace(self.m_expandSpace)
            elseif (not expand) and child_tb[idx]:isExpanded() then
                child_tb[idx]:setHoriFixedSpace(0)
            end
            child_tb[idx]:setExpanded(expand)
        end
    end
    self:updateCardMetrics()
end
--[[
拓展牌
cards:牌table
]]
function CardView:setCardsExpandByCardsTable(cards,expand)
    if type(cards) ~= 'table' then return end
    if expand == nil then expand = true end
    local cards_tb = self:findCardSprites(cards)
    for _ , cd_sp in pairs(cards_tb) do
        if (not cd_sp:isExpanded()) and expand then
            cd_sp:setHoriFixedSpace(self.m_expandSpace)
        elseif (not expand) and cd_sp:isExpanded() then
            cd_sp:setHoriFixedSpace(0)
        end
        cd_sp:setExpanded(expand)
    end
    self:updateCardMetrics()
end

--[[
是否所有牌都拓展
]]
function CardView:setAllCardsExPand(expand)
    self:setCardsExpand(1,self:getCardCount(),expand)
end

--[[
设置牌为选中或非选中
beginIndex:开始下标
endIndex:结束下标
]]
function CardView:flipCardsShoot(beginIndex , endIndex)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end
    local child_tb = self:getAllCardSprites()
    beginIndex     = math.max(0 , beginIndex)
    endIndex       = math.min(table.nums(child_tb) , endIndex)

    for idx = beginIndex , endIndex do
        if child_tb[idx] then
            if not child_tb[idx]:isDisabled() then
                child_tb[idx]:setShooted(not child_tb[idx]:isShooted())
            end
        end
    end
    self:updateCardMetrics()
end
--[[拓展]]
function CardView:flipCardsExpand()
   local card_tb = self:getAllCardSprites()
   for _,cd_sp in pairs(card_tb) do
     if not cd_sp:isDisabled() then
        cd_sp:setExpanded(cd_sp:isShooted())
        if cd_sp:isExpanded() then
            cd_sp:setHoriFixedSpace(self.m_expandSpace)
        else
            cd_sp:setHoriFixedSpace(0)
        end
     end
   end
   self:updateCardMetrics()
end
--[[
调整选中牌顺序
cardSprite:牌节点
]]
function CardView:reorderCardShootedOrder(cardSprite)
    if type(cardSprite) ~= 'userdata' then return  end
    self:sortShootedCards()
    if not cardSprite:isShooted() then
        cardSprite:setShootedOrder(-1)
    else
        cardSprite:setShootedOrder(self.m_lastOrder + 1)
    end
end
-----------------------------------------------get or set->start
--获取选中高度
function CardView:getShootAltitude()
    return self.m_shootHeight
end
--设置选中高度
function CardView:setShootAltitude(altitude)
    if type(altitude) ~= 'number' then return end
    if self.m_shootHeight == altitude then return end
    self.m_shootHeight = altitude
end
--获取最小水平距离
function CardView:getMinHoriSpace()
    return self.m_minHoriSpace
end
--设置最小水平距离
function CardView:setMinHoriSpace(val)
    if type(val) ~= 'number' then return end
    if self.m_minHoriSpace == val then return end
    self.m_minHoriSpace = val
    self.m_maxHoriSpace = math.max(val , self.m_maxHoriSpace)
    self:updateCardMetrics()
end
--获取最大水平距离
function CardView:getMaxHoriSpace()
    return self.m_maxHoriSpace
end
--设置最大水平距离
function CardView:setMaxHoriSpace(val)
    if type(val) ~= 'number' then return end
    if self.m_maxHoriSpace == val then return end
    self.m_maxHoriSpace = val
    self.m_minHoriSpace = math.min(val , self.m_minHoriSpace)
    self:updateCardMetrics()
end
--获取最大水平距离
function CardView:getMinVertSpace()
    return self.m_minVertSpace
end
--设置最大水平距离
function CardView:setMinVertSpace(val)
    if type(val) ~= 'number' then return end
    if self.m_minVertSpace == val then return end
    self.m_minVertSpace = val
    self:updateCardMetrics()
end
--取最大垂直距离
function CardView:getMaxVertSpace()
    return self.m_maxVertSpace
end
--设置最大垂直距离
function CardView:setMaxVertSpace(val)
    if type(val) ~= 'number' then return end
    if self.m_maxVertSpace == val then return end
    self.m_maxVertSpace = val
    self:updateCardMetrics()
end
--获取最大宽
function CardView:getMaxWidth()
    return self.m_maxWidth
end
--设置最大宽
function CardView:setMaxWidth(width)
    if type(width) ~= 'number' then return end
    if self.m_maxWidth == width then return end
    self.m_maxWidth = width
    self:updateCardMetrics()
end
--获取最大高
function CardView:getMaxHeight()
    return self.m_maxHeight
end
--设置最大高
function CardView:setMaxHeight(height)
    if type(height) ~= 'number' then return end
    if self.m_maxHeight == height then return end
    self.m_maxHeight = height
    self:updateCardMetrics()
end
--获取单张牌宽
function CardView:getCardWidth()
    return self.m_cardSize.width
end
--获取单张牌高
function CardView:getCardHeight()
    return self.m_cardSize.height
end
--获取单张牌大小
function CardView:getCardSize()
    return self.m_cardSize
end
--设置点击拓展牌数量
function CardView:setTouchExpandCount(count)
    if type(count) ~= 'number' then return end
    self.m_expandCount = count
end
--设置拓展水平距离
function CardView:setExpandHoriSpace(val)
    if type(val) ~= 'number' then return end
    self.m_expandSpace = val
end
--获取当前水平距离
function CardView:getCurrentHoriSpace()
    return self.m_curHoriSpace
end
--设置当前水平距离
function CardView:setCurrentHoriSpace(val)
    if type(val) ~= 'number' then return end
    self.m_curHoriSpace = val
end
--获取当前垂直距离
function CardView:getCurrentVertSpace()
    return self.m_curVertSpace
end
--设置当前垂直距离
function CardView:setCurrentVerSpace(val)
    if type(val) ~= 'number' then return end
    self.m_curVertSpace = val
end
--是否显示动画
function CardView:isMoveAnimationEnabled()
    return self.m_aniEnabled
end
--设置是否显示动画
function CardView:setMoveAnimationEnable(enable)
    if type(enable) ~= 'boolean' then return end
    self.m_aniEnabled = enable
end
--[[是否单点触摸]]
function CardView:isSingleTopMode()
    return self.m_singleTopMode
end
--[[设置是否单点触摸]]
function CardView:setSingleTopMode(enable)
    if type(enable) ~= 'boolean' then return end
    self.m_singleTopMode = enable
end
--[[设置可触摸]]
function CardView:setCardViewEnabled(enable)
    if type(enable) ~= 'boolean' then return end
    self.m_touchEnabled = enable
end
--[[是否可拓展]]
function CardView:setExpanded(enable)
    if type(enable) ~= 'boolean' then return end
    self.m_isExpand = enable
end

function CardView:isExpanded()
    return self.m_isExpand
end

--[[执行单点触摸]]
function CardView:doSingleTopMode()
    if not self.m_singleTopMode then return end
    local last_sp = self:getLastShootedCardSprite()
    if last_sp then
        local all_cards = self:getAllShootedCaredSprite()
        local not_last  = {}
        for _ ,card_sp in pairs(all_cards)do
            if card_sp ~= last_sp then table.insert(not_last,card_sp) end
        end
        self:setCardsShootByCardSpriteTable(not_last,false)
    end
end
--[[是否自动下滑]]
function CardView:setAutoShootDown(enable)
    if type(enable)~= 'boolean' then return end
    self.m_autoShootDown = enable
end
-----------------------------------------------get or set->end

-----------------------------------------------操做牌->start
--[[获取牌数量]]
function CardView:getCardCount()
    return table.nums(self:getAllCardSprites())
end
--[[返回所有牌节点]]
function CardView:getAllCardSprites()
    if not self.m_rootNode then return {} end
    return self.m_rootNode:getChildren()
end
--[[
获取牌下标
cards:牌值table
]]
function CardView:getCardsIndex(cards)
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
function CardView:getCard(index)
    if type(index) ~= 'number' then return 0x00 end
    if index > self:getCardCount() or index <= 0 then return 0x00 end
    return self:getAllCardSprites()[index]:getCard()
end
--[[
获取所有牌值
返回值：所有牌值
]]
function CardView:getCards()
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
function CardView:getCardSprite(index)
    if type(index) ~= 'number' then return end
    if index <= 0 or index > self:getCardCount() then return end
    return self:getAllCardSprites()[index]
end
--[[
查找牌值==card的节点（不重复）
card:牌值
]]
function CardView:findCardSprite(card)
    if type(card) ~= 'number' then return end
    local child_tb = self:getAllCardSprites()
    for _ ,cardSprite in pairs(child_tb) do
        if cardSprite:getCard() == card then
            return cardSprite
        end
    end
    return nil
end
--[[
查找牌值==cards的节点（不重复）
cards:牌值table
]]
function CardView:findCardSprites(cards)
    if type(cards) ~= 'table' then return {} end
    local index_tb = {}
    local cardsIndex = 1
    local allCards = self:getCards()
    for idx = 1 , table.nums(allCards) do
        if cardsIndex > table.nums(cards) then break end
        if allCards[idx] == cards[cardsIndex] then
             table.insert(index_tb,idx)
             cardsIndex = cardsIndex +1 
        end
    end

    local cardSprites = {}
    for i = 1 , table.nums(index_tb) do
        local sp = self:getCardSprite(index_tb[i])
        table.insert(cardSprites,sp)
    end
    return cardSprites
end
--[[
插入一张牌
index:下标
card:牌值
]]
function CardView:insertCard(index,card)
    if type(index) ~= 'number' or type(card) ~= 'number' then return end
    if not self.m_rootNode then return end
    index = math.max(index , 1)
    index = math.min(index , self:getCardCount())

    local cardSprite = self:createCardSprite(card)
    if cardSprite then
        cardSprite:addTo(self.m_rootNode,index)
        cardSprite:setLocalZOrder(index)
        self:updateOrderAndSpace()
        return cardSprite
    end
end
--[[
插入牌一坨牌
index:下标
cards:牌值table
]]
function CardView:insertCards(index,cards)
    if type(index) ~= 'number' or type(cards) ~= 'table' then return end
    if not self.m_rootNode then return end
    index = math.max(index , 1)
    index = math.min(index , self:getCardCount())
    for i = 1 , table.nums(cards) do
        local cd_sp = self:createCardSprite(cards[i])
        if cd_sp then cd_sp:addTo(self.m_rootNode,index+i) end
    end
    self:updateOrderAndSpace()
end
--[[
添加一张牌
card:牌值
]]
function CardView:addCard(card)
    return self:insertCard(self:getCardCount(),card)
end
--[[
添加牌一坨牌
cards:牌值table
]]
function CardView:addCards(cards)
    self:insertCards(self:getCardCount() , cards)
end
--[[
删除一张牌  若有相同的牌，只删除一张
card:牌值
]]
function CardView:removeCard(card)
    local cardSprite = self:findCardSprite(card)
    if not cardSprite then return false end
    cardSprite:removeSelf()
    self:updateOrderAndSpace()
    return true
end
--[[
删除一张牌
index:下标
]]
function CardView:removeCardByIndex(index)
    local cardSprite = self:getCardSprite(index)
    if not cardSprite then return false end
    cardSprite:removeSelf()
    self:updateOrderAndSpace()
    return true
end
--[[
删除一坨牌
cards:牌值table
]]
function CardView:removeCards(cards)
    if type(cards) ~= 'table' then return end
    for _ , cd in pairs(cards) do self:removeCard(cd) end
    self:updateOrderAndSpace()
end
--[[
删除一坨牌
indexs:牌下标table
]]
function CardView:removeCardsByIndex(indexs)
    if type(indexs) ~= 'table' then return end
    if not self.m_rootNode then return end
    local cardSprite_tb = {}
    for _ , idx in pairs(indexs)do
        local card_sp = self:getCardSprite(idx)
        if card_sp then
            table.insert(cardSprite_tb , card_sp)
        end
    end
    for _ , child in pairs(cardSprite_tb)do
        child:removeSelf()
    end
    self:updateOrderAndSpace()
end
--[[
删除所有选中牌
]]
function CardView:removeShootedCards()
    local shoot_tb = self:getAllShootedCaredSprite()
    if table.nums(shoot_tb)> 0  then
        for _ , cardSp in pairs(shoot_tb)do
           cardSp:removeSelf()
        end
    end
    self:updateOrderAndSpace()
end
--[[
删除所有牌
]]
function CardView:clearCards()
    if self.m_rootNode then
        self.m_rootNode:removeAllChildren()
    end
end
-----------------------------------------------操做牌->end

-----------------------------------------------牌选中管理->start
--[[
设置所有牌是否选中
]]
function CardView:setAllCardsShoot(shoot)
    self:setCardsShoot(1,self:getCardCount(),shoot)
end
--[[
设置牌是否选中
beginIndex:开始下标
endIndex:结束下标
shoot:是否选中
]]
function CardView:setCardsShoot(beginIndex,endIndex,shoot)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if shoot == nil then shoot = true end
    if type(shoot) ~= 'boolean' then return end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end
    local child_tb = self:getAllCardSprites()
    beginIndex  = math.max(0 , beginIndex)
    endIndex    = math.min(table.nums(child_tb) , endIndex)
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
function CardView:setCardShoot(card,shoot)
    if type(card)~= 'number' or type(shoot) ~= 'boolean' then return end
    local cardSprite = self:findCardSprite(card)
    if cardSprite then
        cardSprite:setShooted(shoot)
        self:updateCardMetrics()
    end
end
--[[
设置牌是否选中
cards:牌值table
shoot:是否选中
]]
function CardView:setCardsShootByCardTable(cards,shoot)
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
根据牌节点，设置是否选中
cardsSprite:牌节点table
shoot:是否选中
]]
function CardView:setCardsShootByCardSpriteTable(cardSprites,shoot)
    if type(cardSprites) ~= 'table' or type(shoot) ~= 'boolean' then return end
    if table.nums(cardSprites) == 0 then return end
    for _ , sp in pairs(cardSprites) do 
        sp:setShooted(shoot)
    end
    self:updateCardMetrics()
end

--[[
是否选中
index:下标
]]
function CardView:isCardShooted(index)
    local cardSprite = self:getCardSprite(index)
    if cardSprite then return cardSprite:isShooted() end
    return false
end
--[[获取选中牌数量]]
function CardView:getShootedCardCount()
    return table.nums(self:getShootedCards())
end
--[[
获取所有选中牌节点
返回值：所有选中牌的节点
]]
function CardView:getAllShootedCaredSprite()
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
根据选中顺序获取选中牌(最后选中的牌排在最后)
返回值：选中牌节点
]]
function CardView:getShootedCardsSpriteByOrder()
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
获取第一张选中牌节点
]]
function CardView:getFirstShootedCardSprite()
    return self:getCardSprite(self.m_startIndex)
end
--[[
获取最后一张选中牌节点
]]
function CardView:getLastShootedCardSprite()
    return self:getCardSprite(self.m_endIndex)
end
--[[
获取所有非选中牌节点
返回值：所有非选中牌的节点
]]
function CardView:getAllUnShootedCardSprite()
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
function CardView:getShootedCards()
    local shoot_tb = {}
    local shoot_sp_tb = self:getAllShootedCaredSprite()
    for _ , card_sp in pairs(shoot_sp_tb)do
         table.insert(shoot_tb,card_sp:getCard())
    end
    return shoot_tb
end

--[[获取选中牌下标
返回值：所有选中牌的下标
]]
function CardView:getShootedCardsIndex()
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
function CardView:getShootedCardsByOrder()
    local cards_sp_tb = self:getShootedCardsSpriteByOrder()
    local cards_tb = {}
    for _ , card in pairs(cards_sp_tb) do
        table.insert(cards_tb,card)
    end
    return cards_tb
end
--[[
获取非选中牌
返回值：所有非选中牌值
]]
function CardView:getUnshootedCards()
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
function CardView:setCardViewScale(scaleX,scaleY)
    if type(scaleX) ~= 'number' then return end
    scaleY = scaleY or scaleX
    if self.m_rootNode then
        self.m_rootNode:setScale(scaleX , scaleY)
    end
end
--[[发送事件]]
function CardView:dispatchCardShootChangedEvent(eventType)
    if self.m_cardCallback then
        self.m_cardCallback(self,eventType)
    end
end
--[[添加事件]]
function CardView:addEventListener(cardViewCallback)
    if type(cardViewCallback) ~= 'function' then return end
    self.m_cardCallback = cardViewCallback
end
-----------------------------------------------牌选中管理->end
--注册事件
function CardView:onEnter()
    local function onTouchBegan(touch, event) 
        if(self:onTouchBegan(touch,event))then
            return true 
        else
            return false
        end
    end
    local function onTouchMoved(touch, event)self:onTouchMoved(touch,event) end
    local function onTouchEnded(touch, event)self:onTouchEnded(touch,evnet) end
    local function onTouchCancelled(touch, event)self:onTouchCancelled(touch,evnet) end
    local listener = cc.EventListenerTouchOneByOne:create()    
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function CardView:onExit()
    self:removeTouch()
    display.removeUnusedSpriteFrames()
end
-------for test----------
--[[删除选中牌，动画]]
function CardView:removeShootedCardsByActions()
    local shoot_tb = self:getAllShootedCaredSprite()
    if table.nums(shoot_tb)> 0  then
        self:setCardViewEnabled(false)
        for _ , cardSp in pairs(shoot_tb)do
           local removeSelf = cc.RemoveSelf:create()
           local moveTo     = cc.MoveTo:create(0.2,cc.p(cardSp:getPositionX(),cardSp:getPositionY() + 120))
           local fadeout    = cc.FadeOut:create(0.2)
           local spawn      = cc.Spawn:create(moveTo,fadeout)
           cardSp:runAction(cc.Sequence:create(spawn,removeSelf))
        end
    end
    local delay = cc.DelayTime:create(0.2)
    local cfk = cc.CallFunc:create(function()
        self:updateOrderAndSpace()
        self:setCardViewEnabled(true)
    end)
    self:runAction(cc.Sequence:create(delay,cfk))
end
--[[删除指定牌，动画]]
function CardView:removeCardsByActions(cards)
    if type(cards) ~= 'table' then return end
    if table.nums(cards) == 0 then return end
    local card_tb = self:findCardSprites(cards)
    if table.nums(card_tb) > 0 then
        self:setCardViewEnabled(false)
        for _ , cardSp in pairs(card_tb)do
           local removeSelf = cc.RemoveSelf:create()
           local moveTo     = cc.MoveTo:create(0.2,cc.p(cardSp:getPositionX(),cardSp:getPositionY() + 120))
           local fadeout    = cc.FadeOut:create(0.2)
           local spawn      = cc.Spawn:create(moveTo,fadeout)
           cardSp:runAction(cc.Sequence:create(spawn,removeSelf))
        end
    end
    local delay = cc.DelayTime:create(0.2)
    local cfk = cc.CallFunc:create(function()
        self:updateOrderAndSpace()
        self:setCardViewEnabled(true)
    end)
    self:runAction(cc.Sequence:create(delay,cfk))
end

return CardView