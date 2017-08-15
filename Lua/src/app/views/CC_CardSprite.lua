local CC_CardSprite = class("CC_CardSprite",cc.Sprite)

function CC_CardSprite:ctor()
    self.m_card = 0x00              --默认牌值
    self.m_imageFilePrefix  = ''    --资源
    self.m_shooted  = false         --弹起
    self.m_selected = false         --选中
    self.m_expanded = false         --拓展
    self.m_disabled = false         --禁用

	self.m_horiSpaceFactor = 1.0		--水平空间距离因子
	self.m_vertSpaceFactor = 1.0		--垂直空间距离因子
	self.m_horiFixedSpace  = 0          --水平拓展空间

	self.m_horiIndex        = 0                --水平下标
	self.m_vertIndex        = 0                --垂直下标
    self.m_shootedZOrder    = -1               --弹起zorder

	self.m_selectColor  = cc.c3b(170,170,170)       --选中颜色
	self.m_disableColor = cc.c3b(100,100,100)       --禁用颜色
    self.m_normalColor  = cc.c3b(255,255,255)       --正常颜色

	self.m_normalPos = cc.p(-1,-1)			        --目标位置
	self.m_destPos   = cc.p(-1,-1)		            --终点位置

    self.m_cc_cardView = nil                        --手牌层
end

function CC_CardSprite:create(img,card)
    if type(img) ~= "string" or type(card) ~= "number" then return end
    if not self:checkSpriteFrameLoadead(img,card) then return end
    local cp = CC_CardSprite.new()
    cp:setImageFilePrefix(img)
    cp:setCard(card)
    return cp
end

function CC_CardSprite:isShooted()
    return self.m_shooted
end

function CC_CardSprite:setShooted(shoot)
    if type(shoot) ~= "boolean" then return end
    if self.m_shooted == shoot then return end
    self.m_shooted = shoot
    if self.m_cc_cardView then self.m_cc_cardView:reorderCardShootedOrder(self) end
    self:calcDestPos(self.m_normalPos)
    self:setDestPos(self.m_normalPos)
end

function CC_CardSprite:isSelected()
    return self.m_selected
end

function CC_CardSprite:setSelected(sel)
    if type(sel) ~= "boolean" then return end
    if self.m_selected == sel then return end
    self.m_selected = sel
    if self.m_selected then
        self:setColor(self.m_selectColor)
    else
        self:setColor(self.m_normalColor)
    end
end

function CC_CardSprite:isExpanded()
    return self.m_expanded
end

function CC_CardSprite:setExpanded(expand)
    if type(expand) ~= "boolean" then return end
    self.m_expanded = expand
end

function CC_CardSprite:isDisabled()
    return self.m_disabled
end

function CC_CardSprite:setDisabled(disable)
    if type(disable) ~= "boolean" then return end
    if disable == self.m_disabled then return end
    self.m_disabled = disable
    if self.m_disabled then
        self:setColor(self.m_disableColor)    
    else
        self:setColor(self.m_normalColor)
    end
end

function CC_CardSprite:getShootedOrder()
    return self.m_shootedZOrder
end

function CC_CardSprite:setShootedOrder(order)
    if type(order) ~= "number" then return end
    self.m_shootedZOrder = order
end

function CC_CardSprite:getCard()
    return self.m_card
end

function CC_CardSprite:getHoriSpaceFactor()
    return self.m_horiSpaceFactor
end

function CC_CardSprite:setHoriSpaceFactor(val)
    if type(val) ~= "number" then return end
    self.m_horiSpaceFactor = val
end

function CC_CardSprite:getVertSpaceFactor()
    return self.m_vertSpaceFactor
end

function CC_CardSprite:setVertSpaceFactor(val)
    if type(val) ~= "number" then return end
    self.m_vertSpaceFactor = val
end

function CC_CardSprite:getHoriFixedSpace()
    return self.m_horiFixedSpace
end

function CC_CardSprite:setHoriFixedSpace(val)
    if type(val) ~= "number" then return end
    self.m_horiFixedSpace = val
end

function CC_CardSprite:getHoriRealSpace()
    if self.m_horiFixedSpace ~= 0 then
        return self.m_horiFixedSpace
    else
        if self.m_cc_cardView then return self.m_horiSpaceFactor * self.m_cc_cardView:getCurrentHoriSpace() end
    end
    return 0
end

function CC_CardSprite:getVertRealSpace()
    if self.m_cc_cardView then
        return self.m_vertSpaceFactor * self.m_cc_cardView:getCurrentVertSpace()
    end
    return 0
end

function CC_CardSprite:getHoriIndex()
    return self.m_horiIndex
end

function CC_CardSprite:setHoriIndex(val)
    if type(val) ~= "number" then return end
    self.m_horiIndex = val
end

function CC_CardSprite:getVertIndex()
    return self.m_vertIndex
end

function CC_CardSprite:setVertIndex(val)
    if type(val) ~= "number" then return end
    self.m_vertIndex = val
end

function CC_CardSprite:setDimensionIndex(horiIndex,vertIndex)
    if type(horiIndex) ~= "number" or type(vertIndex) ~= "number" then return end
    self.m_horiIndex = horiIndex
	self.m_vertIndex = vertIndex
end

function CC_CardSprite:getNormalPos()
    return self.m_normalPos
end

function CC_CardSprite:setNormalPos(pos)
    if type(pos) ~= "table" then return end
    self.m_normalPos = pos
    self:calcDestPos(pos)
    self:setDestPos(pos)
end

function CC_CardSprite:getDestPos()
    return self.m_destPos
end

function CC_CardSprite:setDestPos(pos)
    if type(pos) ~= "table" then return end
    self.m_destPos = pos
    self:stopAllActions()
    if self.m_cc_cardView and self.m_cc_cardView:isMoveAnimationEnabled() then
        local ease_move = cc.EaseExponentialOut:create(cc.MoveTo:create(0.2,pos))
        --local ease_move = cc.EaseQuarticActionOut:create(cc.MoveTo:create(0.2,pos))
        self:runAction(ease_move)
    else
        self:setPosition(pos)
    end
end

function CC_CardSprite:getDestPosX()
    return self.m_destPos.x
end

function CC_CardSprite:getDestPosY()
    return self.m_destPos.y
end

function CC_CardSprite:calcDestPos(pos)
    if type(pos) ~= "table" then return end
    if self.m_cc_cardView and self.m_shooted then
        pos.y = pos.y + self.m_cc_cardView:getShootAltitude()
    end
end

function CC_CardSprite:updateSpriteFrame()
    local imgFileName = self.m_imageFilePrefix .. "card_%02x.png"
    local fileStr = string.format(imgFileName , self.m_card)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(fileStr)
    if not frame then
        fileStr = self.m_imageFilePrefix .. "card_00.png"
        frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(fileStr)
    end
    if frame then
        frame:getTexture():setAntiAliasTexParameters()
	    self:setSpriteFrame(frame)
    end
end

function CC_CardSprite:checkSpriteFrameLoadead(fileName,card)
    if type(fileName)~= "string" or type(card) ~= "number" then return false end
    local imgFileName = fileName .. "card_%02x.png"
    local fileStr = string.format(imgFileName , card)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(fileStr)
    if frame then return true end
    printInfo("CC_CardSprite:frame<" .. fileStr .. "> not loadead")
    return false
end

function CC_CardSprite:setCardView(cardView)
    if not cardView then return end
    self.m_cc_cardView = cardView
end

function CC_CardSprite:setImageFilePrefix(img)
    if type(img) ~= "string" then return end
    if self.m_imageFilePrefix == img then return end
    self.m_imageFilePrefix = img
    self:updateSpriteFrame()
end

function CC_CardSprite:setCard(card)
    if type(card) ~= "number" then return end
    if self.m_card == card then return end
    self.m_card = card
    self:updateSpriteFrame()
end

return CC_CardSprite