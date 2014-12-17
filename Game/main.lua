-----------------------------------------------------------------------------
--main.lua
--Authors: Nicholas Lee, Regan McCooey
--Date:    April 20, 2014
--Class:   CSCI 399, Professor King
--Purpose: The main Love file for Gravity Runner game. This file handles all
--         the computation, gameplay and high score recording. Gravity Runner
--         is a simple game. Use the arrow keys and the space bar the avoid 
--         obstacles and the edges of the screen as long as you can. As time 
--         continues, the obstacles start to move faster. Additionally, the 
--         gravity will invert at random times. Gravity Runner also has a 
--         simpler high scores screen that displays the name score and times 
--         played of the top 10 players.
--Input:   (from keyboard and mouse)Other than recording key presses to move 
--		   the ball, the user may input his/her name for the high scores list.
--Output:  (to screen and output file) Displays a game with which the user can
--         interact and writes the high scores to a text file called scores.txt
-------------------------------------------------------------------------------


--------------------------------------------------------------------------
-----------------------CALL BACK FUNCTIONS--------------------------------
--------------------------------------------------------------------------


--love.load()
--Purpose: the first function called in the love.run main loop. Creates all the necessary
--         variables and initialize objects like the floor ball and ceiling.
--Preconditions:  None.
--Postconditions: All initial variables are declared.
function love.load()

	--Set window dimensions 
	WINDOW_H = 512 --window height
	WINDOW_W = 1024 --window width

	--create the background image for the game
	backImage = love.graphics.newImage( "background.png", image )
	ballImage = love.graphics.newImage( "ballPic.png", image)
	
	--Represents when the game should record the keyboard presses for imputing a name. 
	typeTime = false
	
	--Variable for title animation.
	titleAnimationX = WINDOW_W

	--A string variable that defines which state the game is in: titleScreen, gameTime, gameOver and highScores
	state = "titleScreen"
	
	--Load and create highScores
	scoreEntry = Struct{"score", "name", "times_played"}--initialize the struct with three values
	list_high_scores = {}--table of scoreEntries to store the highScores
	tempTimes = 0--represents the number of times played for the current user
	userName = ""--empty string to represent the user name input
	newScore = 0--represents the score for the current user
	
	--if there is a previously defined scores file then read in the scores
	if love.filesystem.exists("scores.txt") == true then
		ReadScores("scores.txt", list_high_scores)
	else--else: this is the first time playing 
		first_time_played = true
	end

	--loads the custom font and creates 4 different font sizes for various uses.
	fontBig = love.graphics.newFont("data-latin.ttf", 90)
	fontMed = love.graphics.newFont("data-latin.ttf", 55)
	fontSm = love.graphics.newFont("data-latin.ttf", 30)
	fontScores = love.graphics.newFont("data-latin.ttf", 20) 

	--loads the music
	--title.mp3 and game.mp3 by Ben Prunty Music: http://benprunty.bandcamp.com/
	--button.mp3 by Kastenfrosch: http://www.freesound.org/people/Kastenfrosch/
	--jump.mp3 by Fins: http://www.freesound.org/people/fins/
	soundTitle = love.audio.newSource( "title.mp3", "static" )
	soundGame = love.audio.newSource( "game.mp3", "static" )
	soundButton = love.audio.newSource( "button.mp3", "static" )
	soundJump = love.audio.newSource( "jump.mp3", "static" )

	
	--GAMPLAY VARIABLES--
	METER = 64--a meter
	Grav = 9.81*METER--gravity inside the game
	GravNeg = 9.81*METER*-1--negative gravity inside the game
	GravPos = 0--the gravity position(1 or 0)
	count = 1
	blockMade = false--check for if block made
	pitMade = false--check for if pit made
	bCount = 0--the number of blocks
	pitCount = 1--the number of pits
	speedInc = 0--the continual increase of speed
	timeGame = 0--the time since the game starts
	tstart = 0--the current time
	
	objects = {} -- table to hold all our physical objects
	blocks = {} --table where we are going to store all of our blocks
	pits = {} --table where we are going to store all of our pits
	widths = {} --table of widths for checking intersection with the ball

	love.physics.setMeter(METER) --the height of a meter our worlds will be 64px
	world = love.physics.newWorld(0, Grav, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
	
	--create the ground
	objects.ground = {}
	objects.ground.body = love.physics.newBody(world, WINDOW_W/2, WINDOW_H-50/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	objects.ground.shape = love.physics.newRectangleShape(WINDOW_W, 50) --make a rectangle with a width of 650 and a height of 50
	objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) --attach shape to body
	--objects.ground.fixture:setFriction(1.0)

	--create the celing
	objects.celing = {}
	objects.celing.body = love.physics.newBody(world, WINDOW_W/2, 50/2)
	objects.celing.shape = love.physics.newRectangleShape(WINDOW_W, 50)
	objects.celing.fixture = love.physics.newFixture(objects.celing.body, objects.celing.shape)

	--create the ball
	objects.ball = {}
	objects.ball.image = love.graphics.newImage("ballPic.png")
	objects.ball.body = love.physics.newBody(world, WINDOW_W/2-30, WINDOW_H - 60, "dynamic")
	objects.ball.shape = love.physics.newRectangleShape(objects.ball.image:getWidth(), objects.ball.image:getHeight())
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, .08)
	objects.ball.body:setLinearVelocity(10, 0)


end--end of love.load()


--love.draw()
--Purpose: call back function that handles all the drawing for the game. Anything that appears on 
--         screen will be drawn in this function.
--Preconditions: the following variables must be initialized: fontBig, fontMed, fontScores, fontSm, 
--               typeTime, userName, tempTimes, state, pits and blocks.
--Postconditions: The correct objects and text will be drawn to screen given the correct state.
function love.draw()

	--draws the background image
	love.graphics.draw( backImage, 0, 0)
	
	--creates local variables for the x and y mouse coordinates 
	local mouseX = love.mouse.getX( )
	local mouseY = love.mouse.getY( )

	--drawing for the titleScreen state
	if state == "titleScreen" then		
		--draw title "GRAVITY RUNNER
		love.graphics.setFont(fontBig)
		love.graphics.print("GRAVITY RUNNER", titleAnimationX, 100)
		love.graphics.setFont(fontMed)
		
		--draw start and scores buttons that invert the colors and fill the polygons when moused over
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

	--drawing for the gameOver state
	elseif state == "gameOver" then
		--draw game over in the middle of the screen
		love.graphics.setFont(fontMed)
		love.graphics.setColor(255, 255, 255) 
		love.graphics.print("GAME OVER", 370, 100)
		--draw "score" and the user's score this round to the left of the screen
		love.graphics.print("SCORE:", 150, 210)
		love.graphics.print(newScore, 320, 210)
		
		--draw start and scores buttons that invert the colors and fill the polygons when moused over
		if mouseX > 707 and mouseX < 917 and mouseY > 180 and mouseY < 240 then--if mouse if over the start button
			love.graphics.polygon('fill', 707, 211, 737, 180, 887, 180, 917, 211, 887, 240, 737, 240)
			love.graphics.polygon('line', 707, 311, 737, 280, 887, 280, 917, 311, 887, 340, 737, 340)
			love.graphics.print("SCORES", 732, 280)	
			love.graphics.setColor(0, 0, 0) 
			love.graphics.print("START", 746, 180)
		elseif mouseX > 707 and mouseX < 917 and mouseY > 280 and mouseY < 340 then--if the mouse is over the scores button
			love.graphics.polygon('line', 707, 211, 737, 180, 887, 180, 917, 211, 887, 240, 737, 240)
			love.graphics.polygon('fill', 707, 311, 737, 280, 887, 280, 917, 311, 887, 340, 737, 340)
			love.graphics.print("START", 746, 180)
			love.graphics.setColor(0, 0, 0) 
			love.graphics.print("SCORES", 732, 280)
		else--mouse is not over any buttons		
			love.graphics.polygon('line', 707, 211, 737, 180, 887, 180, 917, 211, 887, 240, 737, 240)
			love.graphics.polygon('line', 707, 311, 737, 280, 887, 280, 917, 311, 887, 340, 737, 340)
			love.graphics.print("START", 746, 180)
			love.graphics.print("SCORES", 732, 280)
		end--end if
		
		--draw "NAME:" to the screen
		love.graphics.setColor(255, 255, 255) 
		love.graphics.print("NAME:" , 150, 265)

		--fills the rectangle if type time is true or if the mouse is over the text box
		if (typeTime == true) or (mouseX > 275 and mouseX < 475 and mouseY > 272 and mouseY < 322) then
			love.graphics.rectangle("fill", 275, 272, 200, 50)
			love.graphics.setColor(0, 0, 0) 
			--prints the user input from keyboard if typetime == true
			if typeTime == true then
				love.graphics.print("" .. userName, 275, 265)
			end
		else--else print the unfilled text box.
			love.graphics.setColor(255, 255, 255) 
			love.graphics.rectangle("line", 275, 272, 200, 50)
		end--end if
		
		--Draw quit button
		if mouseX > 875 and mouseX < 965 and mouseY > 430 and mouseY < 470 then--if moused over then fill box with red.
			love.graphics.setColor(255, 0, 0) 
			love.graphics.rectangle("fill", 875, 430, 90, 40)
		end
		love.graphics.setColor(255, 255, 255) 
		love.graphics.rectangle("line", 875, 430, 90, 40)
		love.graphics.setFont(fontSm)		
		love.graphics.print("EXIT", 888, 432)
	
	--drawing for highScores state
	elseif state == "highScores" then
		--draw highScores at the top of the screen
		love.graphics.setColor(255, 255, 255) 
		love.graphics.setFont(fontMed)
		love.graphics.print("HighScores", 360, 75)
		love.graphics.line(360, 135, 632, 135)
		
		--draw the title button and fill if moused over
		if mouseX > 107 and mouseX < 317 and mouseY > 230 and mouseY < 290 then
			love.graphics.setColor(255, 255, 255) 
			love.graphics.polygon('fill', 107, 261, 137, 230, 287, 230, 317, 261, 287, 290, 137, 290)
			love.graphics.setColor(0, 0, 0) 
			love.graphics.print("TITLE", 144, 230) 
		else	
			love.graphics.setColor(255, 255, 255) 
			love.graphics.polygon('line', 107, 261, 137, 230, 287, 230, 317, 261, 287, 290, 137, 290)
			love.graphics.print("TITLE", 144, 230) 
		end--end of if for title mouse button
		
		--draw the header for the highScores
		love.graphics.setColor(255, 255, 255) 
		love.graphics.setFont(fontScores)		
		love.graphics.print("SCORE     NAME        TIMES PLAYED", 360, 140)
		
		local scoreHeight = 0--local variable increment the Y values of the each score entry
		local entryPrint = ""--local variable to represent the formated string	
		--if it is the first time played then print the newest score and name
		if first_time_played == true then
			entryPrint = string.format("%-8s %-11s %7s", newScore, userName, tempTimes)--format the string with three columns
			love.graphics.print("1  "..entryPrint, 341, 170) 
			first_time_played = false
		else
			if #list_high_scores > 10 then
				upperBound = 10
			else
				upperBound = #list_high_scores
			end
			
			for i = 1, upperBound do
				tempScore, tempName, tempTimes = GetScore(i, list_high_scores)--retrieve the scoreEntry from the table
				entryPrint = string.format("%-8s %-11s %7s", tempScore, tempName, tempTimes)--format the string with three columns
				if i == 10 then--special case formatting for 10th score entry
					love.graphics.print(i.." "..entryPrint, 341, 170+scoreHeight) 
				else
					love.graphics.print(i.."  "..entryPrint, 341, 170+scoreHeight)
				end
				scoreHeight = scoreHeight + 25--increment the score height
			end
		end--end of if first time played
		
	--drawing for game time state
	else	
		love.graphics.setColor(125, 125, 125) -- set the drawing color to grey for the ground
		love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
		love.graphics.polygon("fill", objects.celing.body:getWorldPoints(objects.celing.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
		love.graphics.setColor(0, 255, 0) --set the drawing color to red for the ball
		--love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())		  
		--love.graphics.draw(objects.ball.image, objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.body:getAngle())
		 
		 
		love.graphics.draw(objects.ball.image, objects.ball.body:getX(), objects.ball.body:getY(), 
		objects.ball.body:getAngle(), 1, 1, objects.ball.image:getWidth()/2, objects.ball.image:getHeight()/2) 
		 
		 
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
	love.graphics.setColor(255,255,255)
  
end--end of love.draw()


--love.update(dt)
--Purpose: callback function that updates every frame of the program. Included are 
--         actions such as checking for mouse clicks, applying force to the obstacles,
--         and changing states. 
--Preconditions:  The following variables must be declared properly: state, userName, timeGame
--                t-start, typeTime, titleAnimationX, ball object, blockMade, pitMade and speedInc
--Postconditions: Changes the state given the correct actions, either mouse clicks or losing the game.
--                Correctly spawns blocks and pits. 
function love.update(dt)
	world:update(dt) --this puts the world into motion
	if state ~= "gameTime" then
		love.audio.play(soundTitle)
	end

	--creates local variables for the x and y mouse coordinates 
	local mouseX = love.mouse.getX( )
	local mouseY = love.mouse.getY( )
	
	--game over state
	if state == "gameOver" then
		love.audio.stop( soundGame )
		newScore = math.floor(timeGame-tstart)--records the time/score of the user
		--if the user clicks on the text box typeTime = true
		if love.mouse.isDown("l") and mouseX > 275 and mouseX < 475 and mouseY > 272 and mouseY < 322  then
			typeTime = true
		--if the user clicks on the start button
		elseif love.mouse.isDown("l") and mouseX > 707 and mouseX < 917 and mouseY > 180 and mouseY < 240 then
			userName = ""--reset the name string
			typeTime = false
			tstart = love.timer.getTime()--restart the timer
			resetGame()--resets the gamplay variables
			state = "gameTime"--change the state to the game
		--if the user clicks on the scores button
		elseif love.mouse.isDown("l") and mouseX > 707 and mouseX < 917 and mouseY > 280 and mouseY < 340 then
			typeTime = false
			love.audio.play(soundButton)
			updateTimesPlayed()--increments the times played
			--inserts the most recent score and name into the high scores list.
			if userName ~= "" then
				InsertScore(newScore, userName, list_high_scores ) 
			end
			SortScores(list_high_scores)--sorts the scores
			state = "highScores"--changes the state to highScores
		--if the user clicks on the exit button
		elseif love.mouse.isDown("l") and mouseX > 875 and mouseX < 965 and mouseY > 430 and mouseY < 470 then
			WriteScores("scores.txt", list_high_scores)--writes the scores to an ouput file
			love.event.push('quit') -- Quit the game
		end--end of if checks for mouse clicks in gameOver state
		
	--titleScreen state
	elseif state == "titleScreen" then
		--animation for the title
		if titleAnimationX > 200 then
			titleAnimationX = titleAnimationX - 10
		else
			--if the user clicks on start button
			if love.mouse.isDown("l") and mouseX > 407 and mouseX < 617 and mouseY > 230 and mouseY < 290 then
				tstart = love.timer.getTime()--starts the timer
				state = "gameTime"--changes the state to gameTime
			--if the user clicks on the scores button
			elseif love.mouse.isDown("l") and mouseX > 407 and mouseX < 617 and mouseY > 330 and mouseY < 390 then
				love.audio.stop(soundButton)
				love.audio.play(soundButton)
				state = "highScores"--change the state to highScores
			--if the user clicks on the quit button
			elseif love.mouse.isDown("l") and mouseX > 875 and mouseX < 965 and mouseY > 430 and mouseY < 470 then
				WriteScores("scores.txt", list_high_scores)--writes the scores to an output file
				love.event.push('quit') -- Quit the game
			end--end of if checks for mouse clicks in titleScreen state
		end
		
	--highScores state
	elseif state == "highScores" then	
		--if the user clicks on title button
		if love.mouse.isDown("l") and mouseX > 107 and mouseX < 317 and mouseY > 230 and mouseY < 290 then
			love.audio.stop(soundButton)
			love.audio.play(soundButton)
			userName = ""--reset the name string
			resetGame()--reset game play variables
			state = "titleScreen"--change state to titleScreen
		end
		
	--gameTime state
	else
		love.audio.stop(soundTitle)
		love.audio.play(soundGame)
		ChangeGravity()
		if objects.ball.body:getX() < 0 then -- if the ball touches the left screen = game over
			state = "gameOver"
		elseif objects.ball.body:getX() > WINDOW_W-10 then --prevent the ball from going out of scope on the right side
			objects.ball.body:setX(WINDOW_W-10)
		end


		local x, y = objects.ball.body:getLinearVelocity( ) -- get the linear velocity of the ball

		if love.keyboard.isDown("right") and x < 50 then --right control with bound
			objects.ball.body:applyForce(5, 0) 
		elseif love.keyboard.isDown("left") and x > -50 then --left control with bound 
			objects.ball.body:applyForce(-5, 0) --bound prevents the ball from going to fast left or right
		end

		speedInc = speedInc - 0.05 --change speed increment
		for j = 1, #blocks do --for all the blocks 
			local x, y = blocks[j].body:getLinearVelocity() --get the velocity
			blocks[j].body:setLinearVelocity(-100+speedInc, 0) --set the velocity
		end
		--get position of the ball
		local xB = objects.ball.body:getX()
		local yB = objects.ball.body:getY()

-- for all of the pits
		for pi = 1, #pits do
		
			local xV, yV = pits[pi].body:getLinearVelocity() --get linear velocity of the pit
			local xP = pits[pi].body:getX() --get X of pit
			local yP = pits[pi].body:getY() --get Y of pit
		   
		--check if the ball hit one of the pits 
    --if the ball is at the same x value +/- the width of the pit 
    -- and the same height as +/- the height of the pit because of the forces 
    -- acting on the pit
    -- and the ball is at the same height depending on the gravity 
    -- then the ball hit the pit
		 if (xB < (xP + math.floor(widths[pi]/2))) and (xB > (xP - math.floor(widths[pi]/2))) and 
			((((yP >= pBot - 50/2) and (yP <= pBot + 50/2)) and (yB >= WINDOW_H - 70)) or 
			(((yP >= pTop - 50/2) and (yP <= pTop + 50/2)) and (yB <= 70))) then 
			state = "gameOver"
			break
		else
			pits[pi].body:setLinearVelocity(-100+speedInc, -yV) --increment the speed of the pit and prevent it from falling because of gravity
		end
		end -- end for


		random = love.math.random(1000) -- calculate random number up to 1000
		if random % 100 == 0 and blockMade ~= true and bCount > 25 then --if its divisible by 100 and a block wasnt made and the counter is greater than 25
		  makeBlock() --make a block
		  blockMade = true
		  pitMade = false
		  bCount = 0
		  --if the number is divisible by 50, a pit hasnt been made and frame count is greater than 35
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
	
end--end of love.update()


--love.keypressed(key)
--Purpose: Call back function that records which keys are pressed from the keyboard.
--         Used to control the ball by applying force to its linear velocity. Also 
--         Used to record names for the high scores.
--Preconditions:  ball object and userName must be previously defined
--Postconditions: Applies force to the ball given the specified gravity and records
--                the name given typeTime == true.
function love.keypressed(key) 

	local x, y = objects.ball.body:getLinearVelocity( )--gets the x and y velocities for the ball object
	--if the user presses the spacebar and the y velocity is less then .5 and greater than -.5
	if ((key == " ") and (y < 0.5) and (y > -0.5)) then
		--if the gravity is normal apply force down
		if GravPos == 0 then 
			love.audio.stop(soundJump)
			love.audio.play(soundJump)
			objects.ball.body:applyForce(0, -180, objects.ball.body:getX()-2, objects.ball.body:getY()+1)
		--else apply force up
		else 
			love.audio.stop(soundJump)
			love.audio.play(soundJump)
			objects.ball.body:applyForce(0, 180, objects.ball.body:getX()-2, objects.ball.body:getY()+1)
		end
	end
	--if the user has clicked on the text box
	if typeTime == true then
		if key == "return" then
			typeTime = false
			love.audio.play(soundButton)
			updateTimesPlayed()--increments the times played
			--inserts the most recent score and name into the high scores list.
			if userName ~= "" then
				InsertScore(newScore, userName, list_high_scores ) 
			end
			SortScores(list_high_scores)--sorts the scores
			state = "highScores"--changes the state to highScores
		end
		--if the backspace has been pressed
		if key == "backspace" then
			--if the string is empty return
			if userName == "" then
				return
			else
				userName = string.sub(userName, 1, string.len(userName) - 1)--update userName to one less than before. 
			end
		end
		--if the key is not space, backspace, shift or tab then add the recorded key to userName
		if key ~= ' ' and key ~= "backspace" and key ~= "lshift" and key ~= "rshift" and key ~= "tab" and string.len(userName) < 7 then
			userName = userName .. key
		end
	end
  
end--end of love.keypressed(key)


--------------------------------------------------------------------------
--------------------------HELPER FUNCTIONS--------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--makeBlock()
--Pre: there is a blocks table created
--Post: a block will be created and added to the block table 
--Purpose: to make a block in the game
---------------------------------------------------------------------------
function makeBlock() 
  
  local gravBlock = bottom 
  local height = love.math.random(20, WINDOW_H/2-150) --randomize height
  local width = love.math.random(40, 60) --randomize width
  local bottom = WINDOW_H-50-height/2 - 2 --location of the bottom position
  local top = 50 + height/2 --location of the top position
  if GravPos == 0 then --set the position of the block based on the gravity 
    gravBlock = bottom
  elseif GravPos == 1 then
    gravBlock = top
  end 
  
  --create the block object
  blocks[count] = {} 
  blocks[count].body = love.physics.newBody(world, WINDOW_W, gravBlock, "dynamic")
  blocks[count].shape = love.physics.newRectangleShape(width, height)
  blocks[count].fixture = love.physics.newFixture(blocks[count].body, blocks[count].shape, 5)
  count = count + 1 --increment block count
  -- if the counter is 15 make it back to one to prevent infinitely growing tables
  if count == 15 then pitCount = 1 end
 
end

--------------------------------------------------------------------------
--makePit()
--Pre: there is a pits table created
--Post: a pit will be created and added to the pit table 
--Purpose: to make a pit in the game
---------------------------------------------------------------------------
function makePit() 
  pBot = WINDOW_H-50/2 --position of bottom 
  pTop = 50/2 --position of top 
  gravPit = bottom
  local widthP = love.math.random(40, 65) -- calculate a random width between 40 and 65
  widths[pitCount] = widthP --add the width to the width table
  if GravPos == 0 then --set the position based on the gravity position
    gravPit = pBot
  elseif GravPos == 1 then
    gravPit = pTop
  end
  --create pit object
  --kinematic objects do not interact with static objects, just dynamic 
  pits[pitCount] = {}
  pits[pitCount].body = love.physics.newBody(world, WINDOW_W, gravPit, "kinematic")
  pits[pitCount].shape = love.physics.newRectangleShape(widthP, 50)
  pits[pitCount].fixture = love.physics.newFixture(pits[pitCount].body, pits[pitCount].shape, 5)
  pitCount = pitCount + 1
  -- if the counter is 15 make it back to one to prevent infinitely growing tables
  if pitCount == 15 then pitCount = 1 end
  

end--end of makeBlock

--------------------------------------------------------------------------
--ChangeGravity()
--Post: the gravity of the environment will change and the blocks and pits
--will be spawn on the correct side accroding to the gravity
--Purpose: to change the gravity of the environment at a random time
---------------------------------------------------------------------------
function ChangeGravity()
  local gravNum = math.random(5000) -- generate a random number
  if gravNum % 1000 == 0 then --if that number is divisible by 1000
  --change the gravity to the opposite value
    if GravPos == 1 then
       GravPos = 0
       world:setGravity(0,Grav)
    else 
        world:setGravity(0,GravNeg)
        GravPos = 1
    end
   else 
  end


end--end of ChangeGravity()

--------------------------------------------------------------------------
--Reset()
--Purpose: to reset all values in order to start a new game
---------------------------------------------------------------------------
function resetGame()
	
	--destroy all pit and block objects
	for i = 1, #pits do	
		pits[i].body:destroy()
	end
	for i = 1, #blocks do
		blocks[i].body:destroy()
	end
	blocks = {} --table where we are going to store all of our blocks
	pits = {} --table where we are going to store all of our pits
	widths = {} --table of widths for checking intersection with the ball
	
	--set the gravity back to bottom
	gravPit = bottom
	world:setGravity(0, Grav)
	GravPos = 0
	pitCount = 0
	count = 0
	speedInc = 0
	--set the ball back to the original position
	objects.ball.body:setPosition(WINDOW_W/2, WINDOW_H-55)
end--end of resetGame()


--updateTimesPlayed()
--Purpose: increments the number of times played.
function updateTimesPlayed()
	tempTimes = tempTimes + 1
end--end of updateTimesPlayed()



--------------------------------------------------------------------------
---------------------------STRUCT CREATION--------------------------------
-----Code from http://lua-users.org/lists/lua-l/2012-11/msg00394.html-----
--------------------------------------------------------------------------


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


--------------------------------------------------------------------------
-----------------------HIGHSCORES FUNCTIONS-------------------------------
--------------------------------------------------------------------------


--ReadScores(filename, list)
--Purpose:  takes in a file name and a table. Opens and reads the file putting each string
--  		(separated by a space) into a new scoreEntry struct. 
--Preconditions:  The table must be initialized before hand. 
--Postconditions: The table contains a list of structs with informations read from the file
function ReadScores(filename, list)

	scorefile = love.filesystem.newFile(filename)
	scorefile:open("r")
	local data = scorefile:read()
	local count = 1
	for i in string.gmatch(data, "%S+") do -- separate each individual part of the string to check    
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


--WriteScores(fileName, list)
--Purpose: writes the scores from a specified list to a specified output file
--Preconditions:  the file name and list a correctly initialized.
--Postconditions: the scores will be written to the output file each value 
--                separated by a space.
function WriteScores(filename, list)
	local outString = ""--string to be written to output file
	--if list is empty return
	if #list == 0 then
		return
	else
		for i = 1, #list_high_scores do
			tempScore, tempName, tempTimes = GetScore(i, list)--get the score entries and assign to temp variables
			outString = outString.." "..tempScore.." "..tempName.." "..tempTimes.."\n" --concat to string
		end
		love.filesystem.write( filename, outString )--write to outfile
	end

end--end of WriteScores()


--InsertScore(score, name, list)
--Purpose: creates a new score entry and inserts the score and name into the specified list.
--         Accounts for duplicates, incrementing times played. 
--Preconditions:  score, name and list are properly initialized. 
--Postconditions: The score entry is added to the list or the entry matching the name is updated.
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

	
--SortScores(list)
--Purpose: sorts the specified list using the built in table sorting function.
--Preconditions:  the table is properly initialized. 
--Postconditions: the table is sorted in descending order. 
function SortScores(list)

	table.sort(list, function (score1, score2) return score1.score > score2.score end)

end--end of SortScores()


--GetScore(index, list)
--Purpose: returns the score, name and times played, given the index and the table.
--Preconditions: index and list are previously initialized.
--Postconditions: returns the correct name, score and times played. 
function GetScore(index, list)
	if #list ~= 0 then
		return list[index].score, list[index].name, list[index].times_played
	end
end-- end of PrintHighScores()


