import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/crank"
import "Corelibs/ui"

import 'text'
import 'linkedList'
import 'indicator'

local pd<const> = playdate
local gfx<const> = pd.graphics

local counter = -1

local totalChange = 0

confirmingReset = false

local clickSound,res = pd.sound.sampleplayer.new("./sounds/click.wav")
print(res)
local scrollSound = pd.sound.sampleplayer.new("./sounds/scroll.wav") 

offset = 100
rem = 40.737

local maxNumOfSprites = 7

bannerImage = gfx.image.new("images/banner.png")
bannerSprite = gfx.sprite.new(bannerImage:scaledImage(0.35))
bannerSprite:moveTo(200,240)
bannerSprite:add()

-- Creating linked list of text sprite objects
local topSpriteNode = ListNode(nil,nil,Text(200, 300 + (offset + rem) + 0*offset,"*0*"))
local curr = topSpriteNode
for i=1,maxNumOfSprites-2 do
    curr.next = ListNode(nil,curr,Text(200,300 + (offset + rem) + i*offset,"*"..i.."*"))
    curr = curr.next
end
local bottomSpriteNode = ListNode(nil,curr,Text(200,300 + (offset + rem) + (maxNumOfSprites-1)*offset,"*"..(maxNumOfSprites-1).."*"))
curr.next = bottomSpriteNode
curr = topSpriteNode

local resetButtonIndicator = Indicator(65,220)
local resetButtonIndicatorImage = gfx.image.new("images/resetButton.png")
resetButtonIndicator:setImage(resetButtonIndicatorImage:scaledImage(0.35))
resetButtonIndicator:setVisible(false)

local confirmResetIndicator = Indicator(200,120)
local confirmResetIndicatorImage = gfx.image.new("images/confirm.png")
confirmResetIndicator:setImage(confirmResetIndicatorImage:scaledImage(0.25))
confirmResetIndicator:setVisible(false)

function showAllText()
    curr = topSpriteNode
    while curr ~= nil do
        curr.val:setVisible(true)
        curr = curr.next
    end
end

function hideAllText()
    curr = topSpriteNode
    while curr ~= nil do
        curr.val:setVisible(false)
        curr = curr.next
    end
end

function resetCounter() 
    print("reset")
    counter = 0
    i = 0
    curr = topSpriteNode
    while curr ~= nil do
        curr.val:moveTo(200,(offset + rem) + i*offset)
        curr.val:setText("*"..i.."*")
        i += 1
        curr = curr.next
    end
end

function confirmResetCounter()
    print("are you sure")
    if pd.buttonJustPressed(pd.kButtonB) then
        resetCounter()
        confirmingReset = false
    elseif pd.buttonJustPressed(pd.kButtonA) then
        -- Don't reset counter
        print("cancel reset")
        confirmingReset = false
    end
end

function pd.update()
    -- print("update() called")
    gfx.sprite.update()

    confirmResetIndicator:setVisible(confirmingReset)
    
    if confirmingReset == false then
        if pd.buttonJustPressed(pd.kButtonB) and counter ~= -1 then
            confirmingReset = true
            totalChange = 0
            pd.timer.performAfterDelay(50, confirmResetCounter)
        end
        handleScrolling()
    else
        print("confirming reset")
        confirmResetCounter()
    end
end

function handleScrolling()
    local allSprites = gfx.sprite.getAllSprites()
    local change,a = pd.getCrankChange()
    totalChange += change

    --print("bannerSprite pos: "..bannerSprite.x.." "..bannerSprite.y)
    if counter == -1 then
        pd.ui.crankIndicator:draw(0,0)
        if bannerSprite.y < -35 then
            counter = 0
            totalChange = 0
            --clickSound:play(1,1)
        end
    end

    if counter >= 1 then
        resetButtonIndicator:setVisible(true)
    end

    if bannerSprite.y < -60 then
        bannerSprite:setVisible(false)
        bannerSprite:remove()
    end

    if change ~= 0 then
        for _,sprite in ipairs(allSprites) do
            if counter <= 0 and change < 0 then
                totalChange = 0
                change = 0
            else
                -- Added a variable, but basically, the changeFactor here was 0.3 before
                local changeFactor = 0.25
                if sprite:isa(Indicator) == false then
                    sprite:moveBy(0, -change * changeFactor)
                end
                if scrollSound:isPlaying() == false then
                    if totalChange > 20 then
                        scrollSound:setRate(audioPitchFactorFunction(math.abs(totalChange - 180)))
                        scrollSound:play()
                    end
                end
            end
        end
        if math.abs(totalChange) >= 180 then
            print("acceleratedChange in update: "..a)
            moveSpritesToClosestYSpot()
            clickSound:play(1,1)
            print("counter: "..counter)
            if counter ~= -1 then
                print("totalChange before: "..totalChange)
                if totalChange > 0 then
                    counter += 1
                    print("counter increment, it is now "..counter)
                else
                    -- Note: Gets out of sync sometimes if the crank moves fast
                    counter -= 1
                    print("counter decrement, it is now "..counter)
                end
            end
            totalChange = 0
            -- print("counter: "..counter)
            -- textSpritesInfo()
        end 
    end
end

function moveSpritesToClosestYSpot()
    print("moveSpritesToClosestYSpot() called")
    -- print("Before move; top sprite y-pos: "..topSpriteNode.val.y.." bottom sprite y-pos: "..bottomSpriteNode.val.y)
    local _,acceleratedChange = pd.getCrankChange()
    print("acceleratedChange in method: "..acceleratedChange)
    local allSprites = gfx.sprite.getAllSprites()
    y = allSprites[1].y 
    if acceleratedChange >= 0 then
        moveAllSpritesOneSpotHigher()
    else
        moveAllSpritesOneSpotLower()
    end
    -- print("After move; top sprite y-pos: "..topSpriteNode.val.y.." bottom sprite y-pos: "..bottomSpriteNode.val.y)
end

function moveAllSpritesOneSpotHigher()
    print("moveAllSpritesOneSpotLower() called") 
    local allSprites = gfx.sprite.getAllSprites()
    for _,sprite in ipairs(allSprites) do
        if sprite:isa(Indicator) == false then
            y = sprite.y
            lowerBound = offset * math.floor(y / offset) + rem
            print("lowerBound: "..lowerBound)
            sprite:moveTo(200, lowerBound)
        end
    end
    if counter >= 3 then
        moveTopSpriteToBottom()
    end
end

function moveAllSpritesOneSpotLower()
    print("moveAllSpritesOneSpotHigher() called") 
    local allSprites = gfx.sprite.getAllSprites()
    for _,sprite in ipairs(allSprites) do
        if sprite:isa(Indicator) == false then
            y = sprite.y
            upperBound = offset * (math.floor(y / offset)+1) + rem - 5
            print("upperBound: "..upperBound)
            sprite:moveTo(200, upperBound)
        end
    end
    if counter >= 3 then
        moveBottomSpriteToTop()
    end
end

function moveTopSpriteToBottom()
    print("moveTopSpriteToBottom() called")
    -- print("moveTopSpriteToBottomDeluxe called")
    local topSprite = topSpriteNode.val
    local lowestBound = bottomSpriteNode.val.y + offset
    print("lowestBound: "..lowestBound)
    local highestBound = topSpriteNode.val.y - offset
    print("highestBound: "..highestBound)

    topSprite:moveTo(200, lowestBound)
    topSprite:setText("*"..tostring(counter + 4).."*")

    bottomSpriteNode.next = topSpriteNode
    topSpriteNode.prev = bottomSpriteNode
    topSpriteNode = topSpriteNode.next
    bottomSpriteNode = bottomSpriteNode.next
    topSpriteNode.prev = nil
    bottomSpriteNode.next = nil

    --printLinkedList()
end

function moveBottomSpriteToTop()
    print("moveBottomSpriteToTop() called")
    -- print("moveBottomSpriteToTopDeluxe called")
    local bottomSprite = bottomSpriteNode.val
    local highestBound = topSpriteNode.val.y - offset
    print("highestBound: "..highestBound)
        
    bottomSprite:moveTo(200, highestBound)
    bottomSprite:setText("*"..tostring(counter - 4).."*")

    topSpriteNode.prev = bottomSpriteNode
    bottomSpriteNode.next = topSpriteNode
    bottomSpriteNode = bottomSpriteNode.prev
    topSpriteNode = topSpriteNode.prev
    topSpriteNode.prev = nil
    bottomSpriteNode.next = nil

    --printLinkedList()
end

function printLinkedList()
    curr = topSpriteNode
    res = ""
    while curr ~= nil do
        res = res..curr.val.text.." "
        curr = curr.next
    end
    print(res)
end

function audioPitchFactorFunction(x)
    if x == 0 then return 2 end
    if x > 160 then return 0.4 end
    return ((-x/math.abs(x))*0.01*x) + 2
end