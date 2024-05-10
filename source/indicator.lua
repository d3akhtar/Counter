local pd<const> = playdate
local gfx<const> = pd.graphics

class('Indicator').extends(gfx.sprite)
function Indicator:init(x,y)
    Indicator.super.init(self)
    self:moveTo(x,y)
    self:add()
end