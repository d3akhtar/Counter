local pd<const> = playdate
local gfx<const> = pd.graphics

class('Text').extends(gfx.sprite)
function Text:init(x,y,text)
    Text.super.init(self)
    textImage = gfx.image.new(gfx.getTextSize(text))
    gfx.pushContext(textImage)
        gfx.drawText(text,0,0,100,100)
    gfx.popContext()
    self:setImage(textImage:scaledImage(1))
    self.textImage = textImage
    self:moveTo(x,y)
    self:add()
    self.text = text
end

local function getScalingFactorBasedOffCenter(x)
   return -(math.abs(0.08*x)) + 8
end

function Text:update()
    centerY = 100 + 40.747
    distanceToCenter = self.y - centerY

    if math.abs(distanceToCenter) >= 80 then
        self:setImage(self.textImage:scaledImage(1.6))
    else
        self:setImage(self.textImage:scaledImage(getScalingFactorBasedOffCenter(distanceToCenter)))
    end

    if self.text:sub(2,2) == "-" then
        self:setVisible(false)
    else
        self:setVisible(true)
    end
end

function Text:setText(text)
    local textImage = gfx.image.new(gfx.getTextSize(text))
    gfx.pushContext(textImage)
        gfx.drawText(text,0,0,100,100)
    gfx.popContext()
    self:setImage(textImage:scaledImage(1))
    self.textImage = textImage
    self.text = text
end