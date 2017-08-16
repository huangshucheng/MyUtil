
local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local CardView = require("app.views.CC_CardView")
function GameScene:onCreate()
    self:addUI()
    self:addButton()
end

function GameScene:addUI()

   self.Card = {
        0x11,0X12,0x13,0X14,0X15,0X16,0X17,0X18,0X19,0X1A,0X1B,0X1C,0X1D,  --·½¿é 
        0x21,0X22,0X23,0X24,0X25,0X26,0X27,0X28,0X29,0X2A,0X2B,0X2C,0X2D,  --Ã·»¨
        0x31,0X32,0x33,0X34,0X35,0X36,0X37,0X38,0X39,0X3A,0X3B,0X3C,0X3D,  --ºìÌÒ
	    0x41,0X42,0x43,0X44,0X45,0X46,0X47,0X48,0X49,0X4A,0X4B,0X4C,0X4D,  --ºÚÌÒ
        0X5E,0X5F                                                          --ÍõÅÆ
    }
    
    --[[
   self.Card = {
        0x11,0X12,0x13,0X14,0X15,0X16,0X17,0X18,0X19,0X1A,0X1B,0X1C,0X1D,  --·½¿é 
        0x21,0X22,0X23,0X24,0X25,0X26,0X27,0X28,0X29,0X2A,0X2B,0X2C 
    }
    ]]
    local cd = {0x00,0x11,0X12,0x01}
    cc.SpriteFrameCache:getInstance():addSpriteFrames("images/card/card-tddz.plist","images/card/card-tddz.png")
    self.cardView = CardView:createWithFile("images/card/card-tddz.png")
    if self.cardView then
       self:addChild(self.cardView)
        self.cardView:setCards(cd)
        self.cardView:move(display.center)
        self.cardView:setMoveAnimationEnable(true)
        self.cardView:setSingleTopMode(true)
    end

    self.cardView:addCardViewEventListener(function(sender,eventType)
    if eventType == self.cardView.EventType.EVENT_HIT_CARD then
        --printInfo("hit card")
    else
        --printInfo("not hit card")
    end
    end)
end

function GameScene:addButton()
    local Card_1 = {0x00,0X36,0X37,0X38,0X39}
    local Card_2 = {0X37,0X38,0X39,0X36,0X36,0X36,0X36,0X37,0X38,0X39,0X11}
    local Card_3 = {0X42,0x43,0X44,0X45,0X46,0X47,0X48,0X49,0X4A,0X4B,0X4C,0X4D,0x11,0X12,0x13,0X14,0X15,0X16,0X17,0X18,0X19,0X1A,0X1B,0X1C,0X1D}
    local btn_0 = ccui.Button:create("BT_YAOGAN.png")
    btn_0:setPosition(50,50)
    btn_0:addTo(self)
    btn_0:addClickEventListener(function(sender)
        printInfo("hcc fuck---->0----->click \n\n")
        ---self.cardView:setCards(Card_1)
        --self.cardView:ignoreAnchorPointForPosition(false)
        --local anchp = self.cardView:getAnchorPoint()
        self.cardView:setCardViewScale(0.5)
        --printInfo("x:   " .. anchp.x .. "   y:  " .. anchp.y)
    end)

    local btn_1 = ccui.Button:create("BT_YAOGAN.png")
    btn_1:setPosition(150,50)
    btn_1:addTo(self)
    btn_1:addClickEventListener(function(sender)
        printInfo("hcc fuck---->1----->click \n\n")
        --self.cardView:setCards(Card_2)
        self.cardView:setCardViewScale(1.0)
    end)

    local btn_2 = ccui.Button:create("BT_YAOGAN.png")
    btn_2:setPosition(250,50)
    btn_2:addTo(self)
    btn_2:addClickEventListener(function(sender)
        printInfo("hcc fuck---->2----->click \n\n")
        self.cardView:setCards(Card_3)
    end)

    local btn_3 = ccui.Button:create("BT_YAOGAN.png")
    btn_3:setPosition(350,50)
    btn_3:addTo(self)
    btn_3:addClickEventListener(function(sender)
        printInfo("hcc fuck---->3----->click \n\n")
        self.cardView:setCards(self.Card)
    end)

    local btn_4 = ccui.Button:create("BT_YAOGAN.png")
    btn_4:setPosition(450,50)
    btn_4:addTo(self)
    btn_4:addClickEventListener(function(sender)
        printInfo("hcc fuck---->4----->click \n\n")
        --self.cardView:insertCard(2 , 0X5F)
        self.cardView:removeCardByIndex(math.ceil(self.cardView:getCardCount() / 2))
    end)

    local btn_5 = ccui.Button:create("BT_YAOGAN.png")
    btn_5:setPosition(550,50)
    btn_5:addTo(self)
    btn_5:addClickEventListener(function(sender)
        printInfo("hcc fuck---->5----->click \n\n")
        --local tb = self.cardView:findCardSprite(0X11)
        --local tb1 = self.cardView:findCardSprite(0X36)
        --printInfo("findNumber--->0x11: " .. #tb .. '  ,0x36: ' .. #tb1)
        local insertCard = self.cardView:insertCard(self.cardView:getCardCount() , 0X11)
        --printInfo("insertCard: " .. insertCard:getCard())
        --self.cardView:removeCard(0X11)
        --self.cardView:removeCardByIndex(0)
        --local cd_tb = {0X36,0X36 ,0X11}
        --self.cardView:removeCards(cd_tb)
        --self.cardView:removeCardsByIndex({0,1,2,3,4})
        local shoottb = {0X36,0X37,0X38,0X36}
        for _ ,v in pairs(shoottb)do
            --self.cardView:setCardShoot(v , true)
        end
        printInfo("card index 1== " .. self.cardView:getCard(1))
        --self.cardView:setCardsShootByCardTable(shoottb , true)
        --self.cardView:removeShootedCards()
    end)

    local btn_6 = ccui.Button:create("BT_YAOGAN.png")
    btn_6:setPosition(650,50)
    btn_6:addTo(self)
    btn_6:addClickEventListener(function(sender)
        printInfo("hcc fuck---->6----->click \n\n")
        for i = 1 ,self.cardView:getCardCount() do
            --printInfo("card value:" .. self.cardView:getCard(i))
        end
        --[[
        local card = self.cardView:getCardSprite(0)
        local card = self.cardView:getCardSprite(1)
        local card = self.cardView:getCardSprite(self.cardView:getCardCount())
        ]]
        --local insertCard = self.cardView:insertCard(0 , 0X5F)
        --self.cardView:insertCards(5 , Card_1)
       -- printInfo("insertCard: " .. insertCard:getCard())
       --self.cardView:removeCard(0X36)
       --self.cardView:removeCardByIndex(1)
       local cd_tb = {0X36,0X37,0X11,0X00}
        --self.cardView:removeCards(cd_tb)
        self.cardView:removeCardsByIndex({1,2,3})
        --self.cardView:removeShootedCards()
        --self.cardView:clearCards()
        local indexTb =  self.cardView:getCardsIndex(cd_tb)
        for _, var in pairs(indexTb) do
            printInfo("index: " .. var)
        end
        --printInfo("type: "  .. type(print))
        local shoottb = {0X36,0X36,0X37,0X38,0X36}
        for _ ,v in pairs(shoottb)do
            --self.cardView:setCardShoot(v , true)
            --self.cardView:removeCard(v)
        end
        --self.cardView:setCardsShootByCardTable(shoottb , true)
        --self.cardView:removeCard(0X36)
        --local shoot_tb = self.cardView:getShootedCards()
        --local shoot_tb = self.cardView:getShootedCardsIndex()
        --local shoot_tb = self.cardView:getShootedCardsByOrder()
        local shoot_tb = self.cardView:getUnshootedCards()
        for _ , v in pairs(shoot_tb)do
            --printInfo("unshooted card: " .. v)
        end
        printInfo("shooted card count:" .. self.cardView:getShootedCardCount())
        --self.cardView:setCardViewScale(0.5)
    end)
end

return GameScene
