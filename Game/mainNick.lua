--global game variables
METER = 64
Grav = 9.81*METER
GravNeg = 9.81*METER*-1
count = 1
blockMade = false
pitMade = false
bCount = 0
timeGame = 0
tstart = 0
newScore = 0
GravPos = 0
gameOver = false
pitCount = 1 
state = "titleScreen"
typeTime = false
userName = ""
tempTimes = 0

function ConvertY(coord)
return (WINDOW_H-coord)
end

function love.keypressed(key) 
 local x, y = objects.ball.body:getLinearVelocity( )
  if ((key == " ") and (y < 0.5) and (y > -0.5)) then
    if GravPos == 0 then 
      objects.ball.body:applyForce(0, -180)
    else 
      objects.ball.body:applyForce(0, 180)
    end
  end
  
  if typeTime == true then
		if key == "backspace" then
			if userName == "" then
				return
			end
			userName = string.sub(1, string.len(userName)-1)
		end
		if key ~= ' ' and key ~= "backspace" and string.len(userName) < 7 then
				userName = userName .. key
		end
	end
  
end



function love.load()


	backImage = love.graphics.newImage( "background.png", image )
	--create score stuff
	scoreEntry = Struct{"score", "name", "times_played"}
	list_high_scores = {}
	first_time_played = love.filesystem.exists( "scores.txt" )
	if love.filesystem.exists("scores.txt") == true then
		ReadScores("scores.txt", list_high_scores)
	else
		first_time_played = true
	end

	
	WINDOW_H = 512 --window height
	WINDOW_W = 1024 --window width 

	MEEP_SIZE = 50

	love.physics.setMeter(METER) --the height of a meter our worlds will be 64px
	world = love.physics.newWorld(0, Grav, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

	objects = {} -- table to hold all our physical objects
	blocks = {} --table where we are going to store all of our blocks
	pits = {} --table where we are going to store all of our pits
	widths = {} --table of widths for checking intersection with the ball
	speedInc = 0

	--create the ground
	objects.ground = {}
	objects.ground.body = love.physics.newBody(world, WINDOW_W/2, WINDOW_H-50/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	objects.ground.shape = love.physics.newRectangleShape(WINDOW_W, 50) --make a rectangle with a width of 650 and a height of 50
	objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) --attach shape to body
	--objects.ground.fixture:setFriction(1.0)

	--[[
	--create the ground
	objects.pitGround = {}
	objects.pitGround.body = love.physics.newBody(world, WINDOW_W/2, WINDOW_H) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	objects.pitGround.shape = love.physics.newRectangleShape(-WINDOW_W, -50) --make a rectangle with a width of 650 and a height of 50
	objects.pitGround.fixture = love.physics.newFixture(objects.pitGround.body, objects.pitGround.shape) --attach shape to body
	--]]
	--create the celing
	objects.celing = {}
	objects.celing.body = love.physics.newBody(world, WINDOW_W/2, 50/2)
	objects.celing.shape = love.physics.newRectangleShape(WINDOW_W, 50)
	objects.celing.fixture = love.physics.newFixture(objects.celing.body, objects.celing.shape)

	--let's create a ball
	objects.ball = {}
	objects.ball.body = love.physics.newBody(world, WINDOW_W/2-30, WINDOW_H - 60, "dynamic") --place the body in the center of the world and make it dynamic, so it 
	objects.ball.shape = love.physics.newCircleShape( 10) --the ball's shape has a radius of 10
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 0.1) -- Attach fixture to body and give it a density of 1.
	objects.ball.body:setLinearVelocity(10, 0)
	

end



function love.draw()

	love.graphics.draw( backImage, 0, 0)
	mouseX = love.mouse.getX( )
	mouseY = love.mouse.getY( )
	fontBig = love.graphics.newFont("data-latin.ttf", 90)
	fontMed = love.graphics.newFont("data-latin.ttf", 55)
	fontSm = love.graphics.newFont("data-latin.ttf", 30)
	fontScores = love.graphics.newFont("data-latin.ttf", 20)

	if state == "titleScreen" then		
		--draw title "GRAVITY RUNNER
		love.graphics.setFont(fontBig)
		love.graphics.print("GRAVITY RUNNER", 230, 100)
		love.graphics.setFont(fontMed)
		
		--draw start and scores buttons
		if mouseX > 407 and mouseX < 617 and mouseY > 230 and mouseY < 290 then
			love.graphics.polygon('fill', 407, 261, 437, 230, 587, 230, 617, 261, 587, 290, 437, 290)
			love.graphics.polygon('line', 407, 361, 437, 330, 587, 330, 617, 361, 587, 390, 437, 390)
			love.graphics.print("SCORES", 432, 330)
			love.graphics.setColor(0, 0, 0) 
			love.graphics.print("START", 446, 230)
		elseif mouseX > 407 and mouseX < 617 and mouseY > 330 and mouseY < 390 then
			love.graphics.polygon('line', 407, 261, 437, 230, 587, 230, 617, 261, 587, 290, 437, 290)
			love.graphics.polygon('fill', 407, 361, 437, 330, 587, 330, 617, 361, 587, 390, 437, 390)
			love.graphics.print("START", 446, 230)
			love.graphics.setColor(0, 0, 0) 
			love.graphics.print("SCORES", 432, 330)
		else		
			love.graphics.polygon('line', 407, 261, 437, 230, 587, 230, 617, 261, 587, 290, 437, 290)
			love.graphics.polygon('line', 407, 361, 437, 330, 587, 330, 617, 361, 587, 390, 437, 390)
			love.graphics.print("START", 446, 230)
			love.graphics.print("SCORES", 432, 330)
		end
		
		--Draw quit button
		if mouseX > 875 and mouseX < 965 and mouseY > 430 and mouseY < 470 then
			love.graphics.setColor(255, 0, 0) 
			love.graphics.rectangle("fill", 875, 430, 90, 40)
		end
		love.graphics.setColor(255, 255, 255) 
		love.graphics.rectangle("line", 875, 430, 90, 40)
		love.graphics.setFont(fontSm)		
		love.graphics.print("EXIT", 888, 432)

	elseif state == "gameOver" then
		love.graphics.setFont(fontMed)
		love.graphics.setColor(255, 255, 255) 
		love.graphics.print("GAME OVER", 370, 100)
		love.graphics.print("SCORE:", 150, 210)
		love.graphics.print(newScore, 320, 210)
		
		mouseX = love.mouse.getX( )
		mouseY = love.mouse.getY( )
			
		if mouseX > 707 and mouseX < 917 and mouseY > 180 and mouseY < 240 then
			love.graphics.polygon('fill', 707, 211, 737, 180, 887, 180, 917, 211, 887, 240, 737, 240)
			love.graphics.polygon('line', 707, 311, 737, 280, 887, 280, 917, 311, 887, 340, 737, 340)
			love.graphics.print("SCORES", 732, 280)	
			love.graphics.setColor(0, 0, 0) 
			love.graphics.print("START", 746, 180)

		elseif mouseX > 707 and mouseX < 917 and mouseY > 280 and mouseY < 340 then
			love.graphics.polygon('line', 707, 211, 737, 180, 887, 180, 917, 211, 887, 240, 737, 240)
			love.graphics.polygon('fill', 707, 311, 737, 280, 887, 280, 917, 311, 887, 340, 737, 340)
			love.graphics.print("START", 746, 180)
			love.graphics.setColor(0, 0, 0) 
			love.graphics.print("SCORES", 732, 280)
			
		else		
			love.graphics.polygon('line', 707, 211, 737, 180, 887, 180, 917, 211, 887, 240, 737, 240)
			love.graphics.polygon('line', 707, 311, 737, 280, 887, 280, 917, 311, 887, 340, 737, 340)
			love.graphics.print("START", 746, 180)
			love.graphics.print("SCORES", 732, 280)
		end
		
		love.graphics.setColor(255, 255, 255) 
		love.graphics.print("NAME:" , 150, 265)

		if typeTime == true or(mouseX > 275 and mouseX < 475 and mouseY > 272 and mouseY < 322) then
			love.graphics.rectangle("fill", 275, 272, 200, 50)
			love.graphics.setColor(0, 0, 0) 
			if typeTime == true then
				love.graphics.print("" .. userName, 275, 265)
			end
		else
			love.graphics.setColor(255, 255, 255) 
			love.graphics.rectangle("line", 275, 272, 200, 50)
		
		end
		
		--Draw quit button
		if mouseX > 875 and mouseX < 965 and mouseY > 430 and mouseY < 470 then
			love.graphics.setColor(255, 0, 0) 
			love.graphics.rectangle("fill", 875, 430, 90, 40)
		end
		love.graphics.setColor(255, 255, 255) 
		love.graphics.rectangle("line", 875, 430, 90, 40)
		love.graphics.setFont(fontSm)		
		love.graphics.print("EXIT", 888, 432)
		
	elseif state == "highScores" then
		love.graphics.setColor(255, 255, 255) 
		love.graphics.setFont(fontMed)
		love.graphics.print("HighScores", 360, 75)
		love.graphics.line(360, 135, 632, 135)
		love.graphics.setFont(fontScores)		
		
		local scoreHeight = 0

		
		if first_time_played == true then
			love.graphics.print("1-   SCORE: "..newScore.." NAME: "..userName.." TIMES PLAYED: "..tempTimes, 360, 140) 
			first_time_played = false
		else
			for i = 1, #list_high_scores do
				tempScore, tempName, tempTimes = GetScore(i, list_high_scores)
				love.graphics.print(i.." -   SCORE: "..tempScore.." NAME: "..tempName.." TIMES PLAYED: "..tempTimes, 360, 140+scoreHeight) 
				scoreHeight = scoreHeight + 20
			end
		end
		--InsertScore(newScore, userName, list_high_scores)
		--SortScores(list_high_scores)
		--tempScore, tempName, tempTimes = GetScore(1, list_high_scores)
		
		love.graphics.setFont(fontScores)
		--love.graphics.print("1-   SCORE: "..tempScore.." NAME: "..tempName.." TIMES PLAYED: "..tempTimes, 360, 170) 


	
	else	
		if state == "gameTime" then
			love.graphics.setColor(125, 125, 125) -- set the drawing color to green for the ground
			love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
			love.graphics.polygon("fill", objects.celing.body:getWorldPoints(objects.celing.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
			love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
			love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())		  
			  
			love.graphics.setColor(0, 204, 204) --set color for block
			for i = 1, #blocks do
				love.graphics.polygon("fill", blocks[i].body:getWorldPoints(blocks[i].shape:getPoints()))
			end
			 
			love.graphics.setColor(0, 0, 0) --set color for pits
			for p = 1, #pits do
				love.graphics.polygon("fill", pits[p].body:getWorldPoints(pits[p].shape:getPoints()))
			end
			 
			love.graphics.setFont(fontMed)
			love.graphics.setColor(255,255,255)
			love.graphics.print(math.floor(timeGame-tstart), 510, 200);
		end
	end
	love.graphics.setColor(255,255,255)

  
end--end of love.draw()


function resetGame()
	
	for i = 1, #pits do	
		pits[i].body:destroy()
	end
	for i = 1, #blocks do
		blocks[i].body:destroy()
	end
	blocks = {} --table where we are going to store all of our blocks
	pits = {} --table where we are going to store all of our pits
	widths = {} --table of widths for checking intersection with the ball
	
	gravPit = bottom
	world:setGravity(0, Grav)
	gravCount = 0
	GravPos = 0
	pitCount = 0
	count = 0
	speedInc = 0
	objects.ball.body:setPosition(WINDOW_W/2, WINDOW_H-55)
	
	

end


function updateTimesPlayed()
	tempTimes = tempTimes + 1
end

function love.update(dt)
	world:update(dt) --this puts the world into motion
	
	mouseX = love.mouse.getX( )
	mouseY = love.mouse.getY( )
	if state == "gameOver" then
		newScore = math.floor(timeGame-tstart)
		if love.mouse.isDown("l") and mouseX > 275 and mouseX < 475 and mouseY > 272 and mouseY < 322  then
			typeTime = true
		elseif love.mouse.isDown("l") and mouseX > 707 and mouseX < 917 and mouseY > 180 and mouseY < 240 then
			userName = ""
			typeTime = false
			tstart = love.timer.getTime()	
			resetGame()
			state = "gameTime"
		elseif love.mouse.isDown("l") and mouseX > 707 and mouseX < 917 and mouseY > 280 and mouseY < 340 then
			typeTime = false
			updateTimesPlayed()
			InsertScore(newScore, userName, list_high_scores )
			SortScores(list_high_scores)
			state = "highScores"
		elseif love.mouse.isDown("l") and mouseX > 875 and mouseX < 965 and mouseY > 430 and mouseY < 470 then
			WriteScores("scores.txt", list_high_scores)
			love.event.push('quit') -- Quit the game.
		end
		
	elseif state == "titleScreen" then
		
		if love.mouse.isDown("l") and mouseX > 407 and mouseX < 617 and mouseY > 230 and mouseY < 290 then
			tstart = love.timer.getTime()
			state = "gameTime"
		elseif love.mouse.isDown("l") and mouseX > 407 and mouseX < 617 and mouseY > 330 and mouseY < 390 then
			state = "highScores"
		elseif love.mouse.isDown("l") and mouseX > 875 and mouseX < 965 and mouseY > 430 and mouseY < 470 then
			WriteScores("scores.txt", list_high_scores)
			love.event.push('quit') -- Quit the game.
		end
	
	elseif state == "highScores" then		
		if love.keyboard.isDown('t') then
			userName = ""
			resetGame()
			state = "titleScreen"
		end	
	else
		ChangeGravity()
		if objects.ball.body:getX() < 0 then
			state = "gameOver"
		elseif objects.ball.body:getX() > WINDOW_W-10 then
			objects.ball.body:setX(WINDOW_W-10)
		end


		local x, y = objects.ball.body:getLinearVelocity( )

		if love.keyboard.isDown("right") and x < 50 then
			objects.ball.body:applyForce(5, 0) 
		elseif love.keyboard.isDown("left") and x > -50 then
			objects.ball.body:applyForce(-5, 0)
		end

		--speedInc = speedInc - 0.05
		for j = 1, #blocks do
			local x, y = blocks[j].body:getLinearVelocity()
			blocks[j].body:setLinearVelocity(-100+speedInc, 0)
		end
		local xB = objects.ball.body:getX()
		local yB = objects.ball.body:getY()


		for pi = 1, #pits do
			--local tempPit = pits[1].body:getX()
			--love.graphics.print(tempPit, 300, 100);
			local xV, yV = pits[pi].body:getLinearVelocity()
			local xP = pits[pi].body:getX()
			local yP = pits[pi].body:getY()
			local yP2 = pits[pi].body:getY() 
		   
		--check if the ball hit one of the pits 
		 if (xB < (xP + math.floor(widths[pi]/2))) and (xB > (xP - math.floor(widths[pi]/2))) and 
			((((yP >= pBot - 50/2) and (yP <= pBot + 50/2)) and (yB >= WINDOW_H - 70)) or 
			(((yP >= pTop - 50/2) and (yP <= pTop + 50/2)) and (yB <= 70))) then 
			state = "gameOver"
			break
		else
			pits[pi].body:setLinearVelocity(-100+speedInc, -yV)
		end
		end -- end for


		random = love.math.random(1000)
		if random % 100 == 0 and blockMade ~= true and bCount > 25 then
		  makeBlock()
		  blockMade = true
		  pitMade = false
		  bCount = 0
		elseif random % 50 == 0 and pitMade ~= true and bCount > 35 then 
		  makePit()
		  blockMade = false
		  pitMade = true
		  bCount = 0
		else
		  blockMade = false
		  bCount = bCount + 1
		end

		timeGame = love.timer.getTime( )

    end
	
end



function makeBlock() 
  
  local gravBlock = bottom
  local height = love.math.random(20, WINDOW_H/2-150)
  local width = love.math.random(40, 60)
  local bottom = WINDOW_H-50-height/2 - 2
  local top = 50 + height/2
  if GravPos == 0 then 
    gravBlock = bottom
  elseif GravPos == 1 then
    gravBlock = top
  end 
  
  blocks[count] = {}
  blocks[count].body = love.physics.newBody(world, WINDOW_W, gravBlock, "dynamic")
  blocks[count].shape = love.physics.newRectangleShape(width, height)
  blocks[count].fixture = love.physics.newFixture(blocks[count].body, blocks[count].shape, 5)
  count = count + 1
  if count == 15 then pitCount = 1 end
 
end

function makePit() 
  pBot = WINDOW_H-50/2
  pTop = 50/2
  gravPit = bottom
  local widthP = love.math.random(40, 65)
  widths[pitCount] = widthP
  if GravPos == 0 then
    gravPit = pBot
  elseif GravPos == 1 then
    gravPit = pTop
  end
  pits[pitCount] = {}
  pits[pitCount].body = love.physics.newBody(world, WINDOW_W, gravPit, "kinematic")
  pits[pitCount].shape = love.physics.newRectangleShape(widthP, 50)
  pits[pitCount].fixture = love.physics.newFixture(pits[pitCount].body, pits[pitCount].shape, 5)
  pitCount = pitCount + 1
  if pitCount == 15 then pitCount = 1 end
  

end

function ChangeGravity()
  local gravNum = math.random(5000)
  gravCount = 0
  if gravNum % 1000 == 0 then
    gravCount = 0
    if GravPos == 1 then
       GravPos = 0
       world:setGravity(0,Grav)
    else 
        world:setGravity(0,GravNeg)
        GravPos = 1
    end
   else 
    gravCount = gravCount + 1
  end


end


-----------------------------------------------------------
-----------------------------------------------------------


-- Struct "type"

local putit = table.insert    -- put it (item) in array ;-)

Struct = {
   mt = {} ,
}

Struct.new_kind = function (Struct, kind)
   -- reverse map field-name --> index
   kind.field_indexes = {}
   for i,field_name in ipairs(kind) do
      kind.field_indexes[field_name] = i
   end
   -- metafields
   kind.__tostring   = Struct.tostring
   kind.__index      = Struct.get
   kind.__newindex   = Struct.set
   setmetatable(kind, Struct)
   return kind
end

Struct.new = function (kind, rec)
   setmetatable(rec, kind)
   return rec
end

Struct.get = function(rec, field_name)
   local kind = getmetatable(rec)
   local i = kind.field_indexes[field_name]
   return rec[i]
end

Struct.set = function(rec, field_name, val)
   local kind = getmetatable(rec)
   local i = kind.field_indexes[field_name]
   rec[i] = val
end

Struct.tostring = function (rec)
   local field_names = getmetatable(rec)
   local strings = {}
   for i,item in ipairs(rec) do
      putit(strings, field_names[i] .. ":" .. tostring(item))
   end
   local string = table.concat(strings, ' ')
   return '(' .. string .. ')'
end

Struct.__call     = Struct.new
Struct.mt.__call  = Struct.new_kind
setmetatable(Struct, Struct.mt)


-----------------------------------------------------------
-----------------------------------------------------------


function ReadScores(filename, list)

	scorefile = love.filesystem.newFile(filename)
	scorefile:open("r")
	local data = scorefile:read()
	--io.input(filename)
	--local whole = io.read("*all")
	local count = 1
	for i in string.gmatch(data, "%S+") do -- seperate each individual part of the string to check    
		if count == 1 then
			readScore = tonumber(i)
		end
		if count == 2 then
			readName = i
		end
		if count == 3 then
			sEntry = scoreEntry{readScore, readName, tonumber(i)}     
			table.insert(list, 1, sEntry)
			count = 0
		end
		count = count + 1
	 
	end --end for
	
	scorefile:close( )

	SortScores(list)
	
end--end of ReadScores()



function WriteScores(filename, list)
	local outString = ""
	if #list == 0 then
		return
	else
		for i = 1, #list_high_scores do
			local 
			tempScore, tempName, tempTimes = GetScore(i, list)
			outString = outString.." "..tempScore.." "..tempName.." "..tempTimes.."\n" 
		end
		love.filesystem.write( filename, outString )
	end

end--end of WriteScores()


function InsertScore(score, name, list)

	local duplicate = false--boolean to check if the name is already in the system
	local indexD = 0 --index of the duplicate to be replaced

	--if the list is not empty
	if #list > 0 then
		for i = 1, #list do
			if string.upper(name) == list[i].name then
				duplicate = true
				indexD = i
			end--if there is a duplicate
		end--for length of list
	end--if not empty

	--the name already exists
	if duplicate == true then
		list[indexD].times_played = list[indexD].times_played + 1
		list[indexD].score = score
	--new entry
	else
		local newScore = scoreEntry{score, string.upper(name), 1}
		table.insert(list, 1, newScore)
	end

	end--end of InsertScores()


function SortScores(list)

	table.sort(list, function (score1, score2) return score1.score > score2.score end)

end--end of SortScores()



function GetScore(index, list)
	if #list ~= 0 then
		return list[index].score, list[index].name, list[index].times_played
	end
end-- end of PrintHighScores()


