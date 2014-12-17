--------------------------------------------------------------------------------------
--Spell Checker
--Authors: Regan McCooey and Nick Lee
--Date: 4/21/14
--Class: CSCI 324 Professor King
--Assignment: PL Final Project - LUA Common Program
--Purpose: to spell check a file and output the misspelled words  
--Input: the file name of the file to be spell checked
--Output: the misspelled words
--------------------------------------------------------------------------------------


--love.load()
--Purpose: the first function called in the love.run main loop. Creates all the necessary
--         variables like fonts and input variables.
--Preconditions:  None.
--Postconditions: All initial variables are declared.
function love.load()
	--Font initialization
	--Font by Kevin Ma: http://www.dafont.com/kelvin-ma.d3691?text=SPELL+CHECKER
	fontBig = love.graphics.newFont("SugarcubesRegular.ttf", 45)
	fontSm = love.graphics.newFont("SugarcubesRegular.ttf", 20)
	fontEr = love.graphics.newFont("SugarcubesRegular.ttf", 12)
	
	Write()--a basic initial write in order to create the spell checker folder to put dictionary 
	       --and test files in.
	
	userInputAdd = ""--user recorded input for the add text box
	userInputCheck = ""--user recorded input for the check text box
	typeTimeCheck = false--turns on keyboard recording for the check text box
	typeTimeAdd = false--turns on keyboard recording for the add text box
	capsOn = false--turns the next letter recorded to uppercase
	fileError = false--file is unable to be opened
	printIncorrect = false--flag to print incorrect words
	word_add = ""--final word to be added to dictionary
	if love.filesystem.exists("space.txt") == true then
		CreateDictionary() --reads in the dictionary and puts it into the 2D table array
	end
end--end of love.load()


---------------------------------------------------------------------------------------------------
--love.draw()
--Purpose: call back function that handles all the drawing for the game. Anything that appears on 
--         screen will be drawn in this function.
--Preconditions: the following variables must be initialized: fontBig, fontSm, fontEr, printIncorrect
--               fileError, userInputAdd and userInputCheck
--Postconditions: The correct objects and text will be drawn to screen.
---------------------------------------------------------------------------------------------------
function love.draw()

	--x and y mouse coordinates
	local mouseX = love.mouse.getX( )
	local mouseY = love.mouse.getY( )

	--print header
	love.graphics.setFont(fontBig)
	love.graphics.print("Spell Checker", 360, 45)
	
	--print prompt for check
	love.graphics.setFont(fontSm)
	love.graphics.print("Please input a file to be spellchecked: ", 325, 100)
	love.graphics.print("Done with input? Press enter.", 325, 165)
	
	--print text box
	if (typeTimeCheck == true) or (mouseX > 325 and mouseX < 710 and mouseY > 125 and mouseY < 165) then
		love.graphics.polygon("fill", 325, 125, 710, 125, 710, 165, 325, 165)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(userInputCheck, 330, 130)	
	else
		love.graphics.polygon("line", 325, 125, 710, 125, 710, 165, 325, 165)
		love.graphics.print(userInputCheck, 330, 130)
	end
	
	--print check button 
	if mouseX > 470 and mouseX < 570 and mouseY > 200 and mouseY < 240 then
		love.graphics.setColor(255, 255, 255)
		love.graphics.polygon("fill", 470, 200, 470, 240, 570, 240, 570, 200)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("Check", 488, 205)
	else
		love.graphics.setColor(255, 255, 255)
		love.graphics.polygon("line", 470, 200, 470, 240, 570, 240, 570, 200)
		love.graphics.print("Check", 488, 205)
	end
	
	--print error message
	if fileError == true then
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(fontEr)
		love.graphics.print("Error: file does not exist or has been misspelled.", 715, 125)
		love.graphics.print("Please input another file name." , 715, 140)
	end
	
	local lineInc = 0--moves line down for each word
	local columnInc = 0--moves column over when at the bottom
	
	--print incorrect words
	if printIncorrect == true then
		love.graphics.setFont(fontSm)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print("Incorrect Words:" , 50, 300)
		for i = 1, #incorrect do
			if lineInc + 230 > 775 then
				columnInc = columnInc + 50
				lineInc = 0
			end
			love.graphics.print(incorrect[i], 70+columnInc, 330+lineInc)
			lineInc = lineInc + 30
		end
	end
	
	
	--print prompt for add
	love.graphics.setFont(fontSm)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Please input a word to add to the dictionary: ", 285, 300)
	love.graphics.print("Done with input? Press enter.", 325, 365)
	
	--print text box
	if (typeTimeAdd == true) or (mouseX > 325 and mouseX < 710 and mouseY > 325 and mouseY < 365) then
		love.graphics.polygon("fill", 325, 325, 710, 325, 710, 365, 325, 365)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(userInputAdd, 330, 330)	
	else
		love.graphics.polygon("line", 325, 325, 710, 325, 710, 365, 325, 365)
		love.graphics.print(userInputAdd, 330, 330)
	end
	
	--print add button 
	if mouseX > 470 and mouseX < 570 and mouseY > 400 and mouseY < 440 then
		love.graphics.setColor(255, 255, 255)
		love.graphics.polygon("fill", 470, 400, 470, 440, 570, 440, 570, 400)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("Add", 500, 405)
	else
		love.graphics.setColor(255, 255, 255)
		love.graphics.polygon("line", 470, 400, 470, 440, 570, 440, 570, 400)
		love.graphics.print("Add", 500, 405)
	end
	
	
	
	love.graphics.setColor(255, 255, 255)
end--end of love.draw()


------------------------------------------------------------------------------------------------
--love.update(dt)
--Purpose: callback function that updates every frame of the program. Included are 
--         actions such as checking for mouse clicks. 
--Preconditions:  The following variables must be declared properly: typeTimeCheck, typeTimeAdd,
--                fileError.
--Postconditions: Takes the proper actions when mouse buttons are clicked.
------------------------------------------------------------------------------------------------
function love.update()
	--local x and y mouse coordinates
	local mouseX = love.mouse.getX( )
	local mouseY = love.mouse.getY( )
	--if the check text box is clicked
	if love.mouse.isDown("l") and mouseX > 325 and mouseX < 710 and mouseY > 125 and mouseY < 165 then
		typeTimeCheck = true
		fileError = false
	end
	
	--if the check button is clicked
	if love.mouse.isDown("l") and mouseX > 470 and mouseX < 570 and mouseY > 200 and mouseY < 240 then
		if love.filesystem.exists(test_file) == true then
			spellCheck(test_file)
		else
			fileError = true
		end
	end
	
	--if the add text box is clicked
	if love.mouse.isDown("l") and mouseX > 325 and mouseX < 710 and mouseY > 325 and mouseY < 365 then
		typeTimeAdd = true
	end
	
	--if the add word button is clicked
	if love.mouse.isDown("l") and mouseX > 470 and mouseX < 570 and mouseY > 400 and mouseY < 440 then		
		addWord(word_add)
		writeNewDictionary()
	end
end--end of love.update()


-------------------------------------------------------------------------------------
--love.keypressed(key)
--Purpose: Call back function that records which keys are pressed from the keyboard.
--Preconditions:  The following variables must be defined: typeTimeCheck, typeTimeAdd,
--                test_file, word_add, capsOn
--Postconditions: Records the keyboard keys for the add word and check.
-------------------------------------------------------------------------------------
function love.keypressed(key)
	if typeTimeCheck == true or typeTimeAdd == true then
		--if return key is pressed
		if key == "return" then
			if typeTimeCheck == true then
				test_file = userInputCheck
				typeTimeCheck = false
			else
				word_add = userInputAdd
				typeTimeAdd = false
			end
		end
		
		--turns on capsOn
		if (key == "lshift" or key == "rshift") and capsOn == false then
			capsOn = true
		end
		
		--Makes the next key uppercase
		if capsOn == true and key ~= "lshift" and key ~= "rshift" and key ~= ' ' and key ~= "backspace" and key ~= "tab" and key ~= "return" then
			key = string.upper(key)
			capsOn = false
		end
		
		--if the backspace has been pressed
		if key == "backspace" then
			--if the string is empty return
			if typeTimeCheck == true and userInputCheck == "" then
				return
			elseif typeTimeAdd == true and userInputAdd == "" then
				return
			end
			
			if typeTimeAdd == true then
				userInputAdd = string.sub(userInputAdd, 1, string.len(userInputAdd) - 1)--update userInputAdd to one less than before. 
			else
				userInputCheck = string.sub(userInputCheck, 1, string.len(userInputCheck) - 1)--update userInputCheck to one less than before. 
			end
		end
		--if the key is not space, backspace, shift or tab then add the recorded key to userInputCheck and userInputAdd
		if key ~= ' ' and key ~= "backspace" and key ~= "lshift" and key ~= "rshift" and key ~= "tab" and key ~= "return" and string.len(userInputCheck) < 30 then
			if typeTimeCheck then
				userInputCheck = userInputCheck .. key
			else
				userInputAdd = userInputAdd .. key
			end
		end
	end

end--end of love.update()


-------------------------------------------------------------------------------------------
--Write()
--Purpose: to create a new directory if the spell checker is running for the first time.
--         after the directory is created the user can move dictionaries and test documents
--         to the proper foler.
-------------------------------------------------------------------------------------------
function Write()
	local outString = "test"
	love.filesystem.write( "space.txt", outString )--write to outfile
end--end of Write()



--------------------------------------------------------------------------------------
------------------------------------SPELL CHECK FUNTIONS------------------------------
--------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------
--function addWord(newWord)
--Pre: 
--Post: a new word will be added to our dictionary table
--Purpose: to add a new word to our dictionary table in order for it to be outputted
--to a file
--------------------------------------------------------------------------------------
function addWord(newWord)

	capLetters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
				"W", "X", "Y", "Z"} 
	lowLetters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
				"w", "x", "y", "z"}

	newWord = tostring(newWord)
	local newL = string.sub(newWord,1,-1*string.len(newWord)) --get the first letter of the new word
	if newL == string.upper(newL) then --if its uppercase 
		index,_ = BinarySearch(newL, capLetters) --find the index of the letter 
		table.insert(dictionary[index],1,newWord) --insert the new word to that letter's table
		RecursiveQuickSort(1, #dictionary[index], dictionary[index]) --sort that table
	else  --if its lowercase 
		index, _ = BinarySearch(newL, lowLetters) --find the index of the lowercase letter
		table.insert(dictionary[index+26],1,newWord) --insert it into the table at that index
		RecursiveQuickSort(1, #dictionary[index+26], dictionary[index+26]) --sort that table    
	end
end--end of addWord(newWord)


--------------------------------------------------------------------------------------
--function writeNewDictionary()
--Pre: a dictionary.txt file exists
--Post: a new dictionary will overwrite the old one
--Purpose: to output the new dictionary from the data structure into the file 
--------------------------------------------------------------------------------------
function writeNewDictionary()
	local output = ""
  
	for i = 1, 52 do --for all of the letters 
		for j = 1, #dictionary[i] do --in each letter table
			output = output.." "..dictionary[i][j] 
		end
	end
	love.filesystem.write( "dictionary.txt", output )--write to outfile

	
end -- write Dictionary


--------------------------------------------------------------------------------------
--function Swap(a, b, list)
--Pre: a and b positions within list 
--Post: the values at position a and b will be interchanged within list
--Purpose: to "swap" the values of two indexes of a list - used in Recursive Quick Sort
--------------------------------------------------------------------------------------
function Swap (a, b, list) --swap the values at positions a and b

  local temp = list[a] -- set the value at position a to a temp
  list[a] = list[b] --set the value at postition a to b 
  list[b] = temp --set the value at position b to a
  return list

end--end of Swap()


--------------------------------------------------------------------------------------
--function Partition(low, high, L)
--Pre: low and high are indecies in a list and L is a list
--Post: when called by QuickSort, values in the list will be swaped based on order 
--Purpose: Partition is a helper function for RecursiveQuickSort
--------------------------------------------------------------------------------------
function Partition(low, high, L)

  pivot = L[low] --pivot is equal to the value at the low index
  lastSmall = low --the last small is equal to low 
  for i = low + 1, high do --from one more than low to high 
    if L[i] < pivot then --if the value is less than the pivot 
      lastSmall = lastSmall + 1 --last small is now equal to that value
      Swap(lastSmall, i, L)  --swap that value with the pivot
    end
   end
   Swap(low, lastSmall, L) --swqp the low value with lastSmall
  return lastSmall

end--end of Partition()


--------------------------------------------------------------------------------------
--function RecursiveQuickSort(low, high, L)
--Pre: low and high are indecies in a list and L is a list
--Post: L will be sorted in the correct order
--Purpose: to sort a list, table, etc in ascending order
--------------------------------------------------------------------------------------
function RecursiveQuickSort(low, high, L)

  if low < high then --if the low index is < the high index
    pivotPosition = Partition(low, high, L) --partition the list 
    RecursiveQuickSort(low, pivotPosition-1, L) --sort from the low to one less than pivot
    RecursiveQuickSort(pivotPosition+1, high, L) --sort from one more than pivot to high 
   end
 
end--end of RecursiveQuickSort()  
  
  
--------------------------------------------------------------------------------------
--function BinarySearch(key,list)
--Pre: the list is in ascending order
--Post: true or false will be returned based on whether or not the key is found
--the index where the key was found will also be returned
--Purpose: to search through a list, table, etc, and find out whether or not the key 
--is located in the list and if it is in the list, where it was found
--------------------------------------------------------------------------------------
function BinarySearch (key, list)
first = 1 --first part of the list
last = table.maxn(list) --the max index
found = false --boolean 

  while last >= first and not found do 
  
    middle = math.floor((first + last) / 2) --calculate the middle and truncate
    if key == list[middle] then --if the middle is the key then found
      found = true
    elseif key < list[middle] then -- if its less than the middle 
      last = middle - 1 --search through the first half 
    elseif key > list[middle] then --if its greater than the middle
      first = middle + 1 --search through the second half
    
    else 
      found = true 
    end -- end if elseif elseif
  
  end -- end while

  if found then --return true and the middle
    return middle, true
  else
    return middle, false --return false and nothing 
  end
 
end--end of BinarySearch()

--------------------------------------------------------------------------------------
--function Check(word)
--Pre: word is a string parsed from a file 
--Post: true or false will be returned 
--Purpose: to check whether or not the word is in our dictionary table data structure
--------------------------------------------------------------------------------------
function Check (word)
  --table for low and capital letters 
  capLetters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
                "W", "X", "Y", "Z"} 
  lowLetters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
                "w", "x", "y", "z"}
  letter = string.sub(word,1,-1*string.len(word)) --gets the first letter
  if letter == string.upper(letter) then --checks if its uppercase
    index, checker = BinarySearch(letter, capLetters) --finds the index of the uppercase letter
    if checker == nil then return false end --if its not a letter return false
    if string.len(word) == 1 then return true end --if the length of the word is 1 return true
       _, checker = BinarySearch(word, dictionary[index]) --search for the word in the dictionary
   else 
    index, checker = BinarySearch(letter, lowLetters) --search for the index of the lowercase letter
    if string.len(word) == 1 then return true end --return true if the length of the letter is one word
    _, checker = BinarySearch(word, dictionary[index+26]) --searches for word in the dictionary
   end 
  return checker
end--end of Check()


--------------------------------------------------------------------------------------
--function CreateDictionary()
--Pre: dictionary.txt exists
--Post: a 2D table will be created storing all of the dictionary information
--Purpose: To store all of the words present in a dictionary file 
--------------------------------------------------------------------------------------
function CreateDictionary()

	local dictionaryFile = love.filesystem.newFile("dictionary.txt")
	dictionaryFile:open("r")
	local whole = dictionaryFile:read()
  
  
	--Table initialization to make a table of tables
	dictionary = { }
	for i = 1, 52 do 
		dictionary[i] = { }
	end

	local letters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
					"W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s",
					"t", "u", "v", "w", "x", "y", "z"}
	

	local isDone = false --boolean variable to state whether or not the dictionary is read in completely
	local letterCount = 1  --count for what letter we're up to
	local count = 1 --counter for what word in each letter were up to
	
	-- source: http://lua-users.org/wiki/SplitJoin 
	for i in string.gmatch(whole, "%S+") do -- seperate each individual part of the string to check    
		-- sets i to the individual word then puts it through our check function
		-- if the word is incorrect it puts it in our incorrect table
		
		local word = i

		local wordL = string.sub(word,1,-1*string.len(word))
		if wordL ~= letters[letterCount] then
			letterCount = letterCount + 1
			count = 1
		end
		dictionary[letterCount][count] = word
		count = count + 1
		
	end --end for
	
	dictionaryFile:close( ) 
 
end--end of CreateDictionary()


------------------------------------------------------------------------------------
--spellCheck(filename)
--Purpose: checks the spelling of the specified file and updates the incorrect table.
--Preconditions: none.
--Postconditions: the incorrect table will be updated with incorrectly spelled words
--                in sorted order.
------------------------------------------------------------------------------------
function spellCheck(filename)
	
	local testfile = love.filesystem.newFile(filename)
	testfile:open("r")
	local whole = testfile:read()

	--table for incorrect words 
	incorrect = { }

	-- finding incorrect words within the file.
	-- source: http://lua-users.org/wiki/SplitJoin 
	for i in string.gmatch(whole, "%S+") do -- seperate each individual part of the string to check    
		-- sets i to the individual word then puts it through our check function
		-- if the word is incorrect it puts it in our incorrect table
		i = string.gsub(i,"%A", "")--removes punctuation		
		if not Check(i) then
		  table.insert(incorrect, i)
		end -- end if
	end --end for

	--sort the incorrect table
	RecursiveQuickSort(1, #incorrect, incorrect)

	--print results
	printIncorrect = true


end -- spellCheck()

