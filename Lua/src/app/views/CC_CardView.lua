local CC_CardView = class("CC_CardView",cc.Layer)

local CC_CardSprite = require("app.views.CC_CardSprite")

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
--成员变量
function CC_CardView:onMemberAssigned()
    self.m_cardRootNode = nil           --根节点，放所有牌

    self.m_cardImageFileName = nil      --文件名
    self.m_cardImageFilePrefix = nil    --文件路径（.png前加/）

    self.m_cardSize = cc.size(0,0)  --牌大小
    self.m_minHoriSpace = 0         --最小水平距离
    self.m_maxHoriSpace = 0         --最大水平距离
    self.m_minVertSpace = 0         --最小垂直距离
    self.m_maxVertSpace = 0         --最大垂直距离
    self.m_expandHoriSpace = 0      --水平拓展距离

    self.m_maxHeight = 0            --最大高度
    self.m_maxWidth = display.width - 140             --最大宽度

    self.m_currentHoriSpace = 0     --当前水平距离
    self.m_currentVertSpace = 0     --当前垂直距离

    self.m_lastShootedCardOrder = 1 --最后选中牌的zOrder

    self.m_moveAnimationEnabled = true     --是否有移动动画
    self.m_autoShootDown = true             --点其他地方牌自动非选中

    self.m_touchBeganPoint = cc.p(0,0)      --开始点击点
    self.m_beginTouchCardIndex = -1          --开始点击下标
    self.m_endTouchCardIndex = -1            --结束点击下标

    self.m_touchExpandCount = 5             --默认拓展数量
    self.m_shootAltitude = 27
end
--创建
function CC_CardView:createWithFile(cardImageFileName)
    if not cc.FileUtils:getInstance():isFileExist(cardImageFileName) then 
        printInfo("CC_CardView->initWithFile<" .. cardImageFileName .. "> is nil") 
        return nil
    end
    local cv = CC_CardView.new()
    cv:initWithFile(cardImageFileName) 
    return cv
end
--初始化
function CC_CardView:initWithFile(cardImageFileName)
    if type(cardImageFileName) ~= "string" then return end
    self:setCardImageFile(cardImageFileName)
    self.m_cardRootNode = cc.SpriteBatchNode:create(cardImageFileName)
    if self.m_cardRootNode then
        self.m_cardRootNode:getTexture():setAliasTexParameters()
	    self.m_cardRootNode:addTo(self)
    end
end
--设置资源文件名
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
    printInfo("CC_CardView->setCardImageFile-> m_cardImgFile: " .. self.m_cardImageFilePrefix)
end
--创建单张牌
function CC_CardView:createCardSprite(card)
    if type(card) ~= 'number' then return end
    local CardSprite =  CC_CardSprite:create(self.m_cardImageFilePrefix , card)
    if CardSprite then
        CardSprite:setCardView(self)
        return CardSprite
    end
end
--设牌
function CC_CardView:setCards(cards)
    if type(cards) ~= 'table' then printInfo("CC_CardView:setCards -> parm must be table") return end
    if not self.m_cardRootNode then return end
    local child_tb = self.m_cardRootNode:getChildren()
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
--设置单张牌size
function CC_CardView:setCardSize(size)
    if type(size) ~= 'table' then return end
    self.m_cardSize = size
    self.m_minHoriSpace = self.m_cardSize.width / 5
    self.m_maxHoriSpace = self.m_cardSize.width * 3 / 5
    self.m_minVertSpace = self.m_cardSize.height / 5
    self.m_maxVertSpace = self.m_cardSize.height / 2 
    self.m_expandHoriSpace = self.m_cardSize.width * 0.15
    self:updateCardMetrics()
end
--调整所有牌的位置
function CC_CardView:updateCardMetrics()
    if not self.m_cardRootNode  then return end
    local child_tb = self.m_cardRootNode:getChildren()
    if table.nums(child_tb) == 0 then return end

	local horiFixedSpace = self:calcAllCardSpriteHoriFixedSpace()
	local horiSpaceFactor = self:calcAllCardSpriteHoriSpaceFactor()
    local anchorPoint = self:getAnchorPoint()
    local maxRow = 1

    if self.m_maxHeight ~= 0 and self.m_minVertSpace ~= 0 then 
         maxRow = math.ceil(self.m_maxHeight / self.m_minVertSpace)
    else 
        maxRow = 1 
    end

    if horiSpaceFactor ~= 0 then
        self.m_currentHoriSpace = (self.m_maxWidth * maxRow - horiFixedSpace) / horiSpaceFactor
    else
        self.m_currentHoriSpace = self.m_maxWidth * maxRow - horiFixedSpace 
    end

    self.m_currentVertSpace = self.m_maxHeight / maxRow
    self.m_currentHoriSpace = math.min(self.m_currentHoriSpace,self.m_maxHoriSpace)
    self.m_currentHoriSpace = math.max(self.m_currentHoriSpace,self.m_minHoriSpace)
    self.m_currentVertSpace = math.min(self.m_currentVertSpace,self.m_maxVertSpace)
    self.m_currentVertSpace = math.max(self.m_currentVertSpace,self.m_minVertSpace)

    local rowWidth_tb = {}
    local width = 0
    local height = 0
    local horiIndex = 0
    local vertIndex = 0

    for idx = 1 , table.nums(child_tb) do 
        if (width + child_tb[idx]:getHoriRealSpace()) > self.m_maxWidth + 0.1 then
            vertIndex = vertIndex + 1
            horiIndex = 0
            table.insert(rowWidth_tb ,width)
            width = 0
            height = height + child_tb[idx]:getVertRealSpace()
        end
        child_tb[idx]:setDimensionIndex(horiIndex,vertIndex)
        if horiIndex ~= 0 then width = width + child_tb[idx]:getHoriRealSpace() end
        horiIndex = horiIndex + 1
    end

    table.insert(rowWidth_tb,width)
    local x = 0
    local y = height * anchorPoint.y
    vertIndex = -1

    for idx = 1 , table.nums(child_tb) do 
        if child_tb[idx]:getVertIndex() ~= vertIndex then
            local vd = child_tb[idx]:getVertIndex()
            if rowWidth_tb[vd + 1] then x = - rowWidth_tb[vd + 1] * anchorPoint.x end
            vertIndex = child_tb[idx]:getVertIndex()
            if vertIndex > 0 then y = y - child_tb[idx]:getVertRealSpace() end
        end
        if child_tb[idx]:getHoriIndex() ~= 0 then x = x + child_tb[idx]:getHoriRealSpace() end
        child_tb[idx]:setNormalPos(cc.p(x,y))
    end
    print("CC_CardView->child_count->" .. table.nums(child_tb))
end
--更新所有牌的LocalZorder
function CC_CardView:reorderCardDirty()
    if not self.m_cardRootNode  then return end
    local child_tb = self.m_cardRootNode:getChildren()
    if table.nums(child_tb) == 0 then return end
    for idx = 1 , table.nums(child_tb) do
        child_tb[idx]:setLocalZOrder(idx)
    end
end
--更新选中牌的 localZorder
function CC_CardView:sortShootedCards()
    if not self.m_cardRootNode  then return end
    local child_tb = self.m_cardRootNode:getChildren()
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

function CC_CardView:calcAllCardSpriteHoriFixedSpace()
    if not self.m_cardRootNode  then return end
    local space = 0
    local child_tb = self.m_cardRootNode:getChildren()
    if table.nums(child_tb) == 0 then return space end
    for _, cardSprite in pairs(child_tb) do
        if cardSprite:getHoriFixedSpace() == 0 and cardSprite:getLocalZOrder() ~= 0 then
            space = space + cardSprite:getHoriFixedSpace()
        end
    end
    return space
end

function CC_CardView:calcAllCardSpriteHoriSpaceFactor()
    if not self.m_cardRootNode  then return end
    local factor = 0
    local child_tb = self.m_cardRootNode:getChildren()
    if table.nums(child_tb) == 0 then return factor end
    for _, cardSprite in pairs(child_tb) do
        if cardSprite:getHoriFixedSpace()== 0 and cardSprite:getLocalZOrder() ~= 0 then
            factor = factor + cardSprite:getHoriSpaceFactor()
        end
    end
    return factor
end

function CC_CardView:getCurrentHoriSpace()
    return self.m_currentHoriSpace
end

function CC_CardView:getCurrentVertSpace()
    return self.m_currentVertSpace
end

function CC_CardView:isMoveAnimationEnabled()
    return self.m_moveAnimationEnabled
end

function CC_CardView:setMoveAnimationEnable(enable)
    if type(enable) ~= 'boolean' then return end
    self.m_moveAnimationEnabled = enable
end

function CC_CardView:onTouchesBegan(touches, event)
    printInfo("onTouchesBegan")
    if table.nums(touches) == 1 and touches[1] then
        local touch = touches[1]
        self.m_touchBeganPoint = self:convertToNodeSpace(touch:getLocation())
        self.m_beginTouchCardIndex = self:hitCard(self.m_touchBeganPoint)
        printInfo("m_beginTouchCardIndex: " .. self.m_beginTouchCardIndex)
    end
end

function CC_CardView:onTouchesMoved(touches, event)
    if table.nums(touches) == 1 and touches[1] and self.m_beginTouchCardIndex ~= -1 then
        local touch = touches[1]
        local touchPoint = self:convertToNodeSpace(touch:getLocation())
        local cardIndex = self:hitCard(touchPoint)
        if cardIndex ~= -1 then
            self:setCardsSelect(self.m_beginTouchCardIndex,self.m_endTouchCardIndex,false)
            self.m_endTouchCardIndex = cardIndex
            self:setCardsSelect(self.m_beginTouchCardIndex,self.m_endTouchCardIndex,true)
            printInfo("m_endTouchCardIndex: " .. self.m_endTouchCardIndex)
        end
    end
end

function CC_CardView:onTouchesEnded(touches, event)
    printInfo("onTouchesEnded")
    if table.nums(touches) ~= 1 or not touches[1] or not self.m_cardRootNode then return end
    local touch = touches[1]
    local touchPoint = self:convertToNodeSpace(touch:getLocation())
    self.m_endTouchCardIndex = self:hitCard(touchPoint)
    self:setCardsSelect(1,self.m_cardRootNode:getChildrenCount() ,false)

    if self.m_beginTouchCardIndex ~= -1 and self.m_endTouchCardIndex ~= -1 then
        if self.m_beginTouchCardIndex == self.m_endTouchCardIndex then
            local cardSprite = self:getCardSprite(self.m_beginTouchCardIndex)
            if not cardSprite:isExpanded() then
                self:expandCards(self.m_beginTouchCardIndex,self.m_touchExpandCount)
            end
        end
        self:flipCardsShoot(self.m_beginTouchCardIndex,self.m_endTouchCardIndex)
    else
        if self.m_autoShootDown then
            self:setAllCardsShoot(false)
            if (self.m_touchBeganPoint.x -touchPoint.x) < -100 or (self.m_touchBeganPoint.x -touchPoint.x) > 100  then
                self:adjustAllCardSpriteSpace()
            end
        end
    end

    printInfo("m_endTouchCardIndex: " .. self.m_endTouchCardIndex)
    self.m_beginTouchCardIndex = -1
    self.m_endTouchCardIndex = -1
    self.m_touchBeganPoint = cc.p(0,0)
end

function CC_CardView:hitCard(point)
    if type(point) ~= 'table' then return end
    if not self.m_cardRootNode  then return end
    local child_tb = self.m_cardRootNode:getChildren()
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

function CC_CardView:setCardsSelect(beginIndex , endIndex , isSel)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if not self.m_cardRootNode then return end
    if isSel == nil then isSel = true end
    local child_tb = self.m_cardRootNode:getChildren()
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

function CC_CardView:getCardSprite(index)
    if type(index) ~= 'number' or not self.m_cardRootNode then return end
    if index < 0 or index > self.m_cardRootNode:getChildrenCount() then return end
    return self.m_cardRootNode:getChildren()[index]
end

function CC_CardView:expandCards(index , count)
    if type(index)~= 'number' or type(count) ~= 'number' then return end
    local beginIndex = math.ceil(index - count / 2) 
    local endIndex = math.ceil(index + count / 2)
    self:adjustAllCardSpriteSpace()
    self:setCardsExpand(beginIndex,endIndex,true)
end

function CC_CardView:adjustAllCardSpriteSpace()
    if not self.m_cardRootNode  then return end
    for _ ,cardSprite in pairs(self.m_cardRootNode:getChildren()) do
        self:adjustCardSpriteSpace(cardSprite)
    end
    self:updateCardMetrics()
end

function CC_CardView:setCardsExpand(beginIndex , endIndex , expand)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if not self.m_cardRootNode then return end
    if expand == nil then expand = true end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end

    local child_tb = self.m_cardRootNode:getChildren()
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

function CC_CardView:flipCardsShoot(beginIndex , endIndex)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if not self.m_cardRootNode then return end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end
    local child_tb = self.m_cardRootNode:getChildren()
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

function CC_CardView:setAllCardsShoot(shoot)
    if not self.m_cardRootNode then return end
    self:setCardsShoot(1 , self.m_cardRootNode:getChildrenCount() , shoot)
end

function CC_CardView:setCardsShoot(beginIndex,endIndex,shoot)
    if type(beginIndex) ~= 'number' or type(endIndex) ~= 'number' then return end
    if type(shoot) ~= 'boolean' then return end
    if not self.m_cardRootNode then return end
    if beginIndex > endIndex then
        beginIndex , endIndex = endIndex , beginIndex
    end
    local child_tb = self.m_cardRootNode:getChildren()
    beginIndex = math.max(0 , beginIndex)
    endIndex = math.min(table.nums(child_tb) , endIndex)
    for idx = beginIndex , endIndex do
        if child_tb[idx] then
            child_tb[idx]:setShooted(shoot)
        end
    end
    self:updateCardMetrics()
end

function CC_CardView:adjustCardSpriteSpace(cardSprite)
    if type(cardSprite) ~= 'userdata' then return end
    cardSprite:setHoriFixedSpace(0)
    cardSprite:setHoriSpaceFactor(1)
    cardSprite:setExpanded(false)
end

function CC_CardView:reorderCardShootedOrder(cardSprite)
    if type(cardSprite) ~= 'userdata' then return  end
    self:sortShootedCards()
    if not cardSprite:isShooted() then
        cardSprite:setShootedOrder(-1)
    else
        cardSprite:setShootedOrder(self.m_lastShootedCardOrder + 1)
    end
end

function CC_CardView:getShootAltitude()
    return self.m_shootAltitude
end

function CC_CardView:onEnter()
    printInfo("CC_CardView:onEnter")
    local function onTouchesBegan(touches, event)
        self:onTouchesBegan(touches,event)
    end
    local function onTouchesMoved(touches, event)
        self:onTouchesMoved(touches,event)
    end
    local function onTouchesEnded(touches, event)
        self:onTouchesEnded(touches,evnet)
    end
    local listener = cc.EventListenerTouchAllAtOnce:create()    
    listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function CC_CardView:onExit()
    printInfo("CC_CardView:onExit")
end

return CC_CardView