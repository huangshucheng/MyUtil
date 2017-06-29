
local GameScene = class("GameScene", cc.load("mvc").ViewBase)

function GameScene:onCreate()
    self:addUI()
end

function GameScene:addUI()
    self.touchlayer = require("app.views.TouchLayer"):create()
    self:addChild(self.touchlayer)
end


return GameScene
