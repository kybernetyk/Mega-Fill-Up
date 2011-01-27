-- penis.lua
local self = null;
local sprite = null;

-- Lua Hello World (test.lua)
function helloWorld ()
     print("hello world");
end

function OnInit (_self)
   self = _self;

	sprite = Object("CCSprite"):initWithFile("ball.png");
	sprite:setUserData(sprite);
	self:addChild(sprite,10);

	sprite:MoveTo(100.0,100.0,4.0);
end

function OnUpdate (delta)
     -- print("on update self: " .. self:description() .. " delta: " .. delta);
end

-- event handler
function OnMoveToFinished ()
	print ("LOL MOVE FINISHED");
end

-- main
print("main ()");