-- @title MovieClipX
-- @tagline A better way to animate.
-- @author Garet McKinley (@iGaret)


module(..., package.seeall)

	

--- Creates a new MovieClipX container
-- mxc containers are the core of the MovieClipX library.
-- In order to do anything with the library, you first need
-- a mcx container.
function new()
	
	local mcx = display.newGroup()
	local clips = {}
	local active = nil
	animName = nil
	timeWarp = 1
	debug = false
	
	function mcx:newAnim (name,imageTable,width,height, speed)

		-- Set up graphics
		local g = display.newGroup()
		local animFrames = {}
		local animLabels = {}
		local limitX, limitY, transpose
		local startX, startY
		g.speed = speed * timeWarp
		g.progress = speed

		local i = 1
		while imageTable[i] do
			animFrames[i] = display.newImageRect(imageTable[i],width,height);
			g:insert(animFrames[i], true)
			animLabels[i] = i -- default frame label is frame number
			animFrames[i].isVisible = false
			i = i + 1
		end
		
		-- show first frame by default
		animFrames[1].isVisible = false

		-------------------------
		-- Define private methods
	
		local currentFrame = 1
		local totalFrames = #animFrames
		local startFrame = 1
		local endFrame = #animFrames
		local loop = 0
		local loopCount = 0
		local remove = false
		local dragBounds = nil
		local dragLeft, dragTop, dragWidth, dragHeight
	
		-- flag to distinguish initial default case (where no sequence parameters are submitted)
		local inSequence = false
	
		local function resetDefaults()
			currentFrame = 1
			startFrame = 1
			endFrame = #animFrames
			loop = 0
			loopCount = 0
			remove = false
		end
	
		local function resetReverseDefaults()
			currentFrame = #animFrames
			startFrame = #animFrames
			endFrame = 1
			loop = 0
			loopCount = 0
			remove = false
		end
	
		local function nextFrame( self, event )
			animFrames[currentFrame].isVisible = false
			currentFrame = currentFrame + 1
			if (currentFrame == endFrame + 1) then
				if (loop > 0) then
					loopCount = loopCount + 1

					if (loopCount == loop) then
						-- stop looping
						currentFrame = currentFrame - 1
						animFrames[currentFrame].isVisible = true
						Runtime:removeEventListener( "enterFrame", self )

						if (remove) then
							-- delete self (only gets garbage collected if there are no other references)
							self.parent:remove(self)
						end

					else
						currentFrame = startFrame
						animFrames[currentFrame].isVisible = true
					end

				else
					currentFrame = startFrame
					animFrames[currentFrame].isVisible = true
				end
			
			elseif (currentFrame > #animFrames) then
				currentFrame = 1
				animFrames[currentFrame].isVisible = true
			
			else
				animFrames[currentFrame].isVisible = true
			
			end
		end

	
		local function prevFrame( self, event )
			animFrames[currentFrame].isVisible = false
			currentFrame = currentFrame - 1
		
			if (currentFrame == endFrame - 1) then
				if (loop > 0) then
					loopCount = loopCount + 1

					if (loopCount == loop) then 
						-- stop looping
						currentFrame = currentFrame + 1
						animFrames[currentFrame].isVisible = true
						Runtime:removeEventListener( "enterFrame", self )

						if (remove) then
							-- delete self
							self.parent:remove(self)
						end

					else
						currentFrame = startFrame
						animFrames[currentFrame].isVisible = true
					end

				else
					currentFrame = startFrame
					animFrames[currentFrame].isVisible = true
				end
			
			elseif (currentFrame < 1) then
				currentFrame = #animFrames
				animFrames[currentFrame].isVisible = true
			
			else
				animFrames[currentFrame].isVisible = true
			
			end
		end
	
	
		local function dragMe(self, event)
			local onPress = self._onPress
			local onDrag = self._onDrag
			local onRelease = self._onRelease
	
			if event.phase == "began" then
				display.getCurrentStage():setFocus( self )
				startX = g.x
				startY = g.y
			
				if onPress then
					result = onPress( event )
				end
			
			elseif event.phase == "moved" then
	
				if transpose == true then
					-- Note: "transpose" is deprecated now that Corona supports native landscape mode
					-- dragBounds is omitted in transposed mode, but feel free to implement it
					if limitX ~= true then
						g.x = startX - (event.yStart - event.y)
					end
					if limitY ~= true then
						g.y = startY + (event.xStart - event.x)
					end
				else
					if limitX ~= true then
						g.x = startX - (event.xStart - event.x)
						if (dragBounds) then
							if (g.x < dragLeft) then g.x = dragLeft end
							if (g.x > dragLeft + dragWidth) then g.x = dragLeft + dragWidth end
						end
					end
					if limitY ~= true then
						g.y = startY - (event.yStart - event.y)
						if (dragBounds) then
							if (g.y < dragTop) then g.y = dragTop end
							if (g.y > dragTop + dragHeight) then g.y = dragTop + dragHeight end
						end
					end
				end

				if onDrag then
					result = onDrag( event )
				end
				
			elseif event.phase == "ended" then
				display.getCurrentStage():setFocus( nil )

				if onRelease then
					result = onRelease( event )
				end
			
			end
		
			-- stop touch from falling through to objects underneath
			return true
		end


		------------------------
		-- Define public methods

		function g:enterFrame( event )
			--mcx:log(g.progress)
			if (g.progress == 0) then
				self:repeatFunction( event )
				g.progress = g.speed
			else
				g.progress = g.progress - 1
			end
		end

		function g:play(params )
			Runtime:removeEventListener( "enterFrame", self )

			if ( params ) then
				-- if any parameters are submitted, assume this is a new sequence and reset all default values
				animFrames[currentFrame].isVisible = false
				resetDefaults()				
				inSequence = true
				-- apply optional parameters (with some boundary and type checking)
				if ( params.startFrame and type(params.startFrame) == "number" ) then startFrame=params.startFrame end
				if ( startFrame > #animFrames or startFrame < 1 ) then startFrame = 1 end
		
				if ( params.endFrame and type(params.endFrame) == "number" ) then endFrame=params.endFrame end
				if ( endFrame > #animFrames or endFrame < 1 ) then endFrame = #animFrames end
		
				if ( params.loop and type(params.loop) == "number" ) then loop=params.loop end
				if ( loop < 0 ) then loop = 0 end
			
				if ( params.remove and type(params.remove) == "boolean" ) then remove=params.remove end
				loopCount = 0
			else
				if (not inSequence) then
					-- use default values
					startFrame = 1
					endFrame = #animFrames
					loop = 0
					loopCount = 0
					remove = false
				end			
			end
					
			currentFrame = startFrame
			animFrames[startFrame].isVisible = true 
		
			self.repeatFunction = nextFrame
			Runtime:addEventListener( "enterFrame", self )
		end
	
	
		function g:reverse( params )
			Runtime:removeEventListener( "enterFrame", self )
		
			if ( params ) then
				-- if any parameters are submitted, assume this is a new sequence and reset all default values
				animFrames[currentFrame].isVisible = false
				resetReverseDefaults()
				inSequence = true
				-- apply optional parameters (with some boundary and type checking)
				if ( params.startFrame and type(params.startFrame) == "number" ) then startFrame=params.startFrame end
				if ( startFrame > #animFrames or startFrame < 1 ) then startFrame = #animFrames end
		
				if ( params.endFrame and type(params.endFrame) == "number" ) then endFrame=params.endFrame end
				if ( endFrame > #animFrames or endFrame < 1 ) then endFrame = 1 end
		
				if ( params.loop and type(params.loop) == "number" ) then loop=params.loop end
				if ( loop < 0 ) then loop = 0 end
		
				if ( params.remove and type(params.remove) == "boolean" ) then remove=params.remove end
			else
				if (not inSequence) then
					-- use default values
					startFrame = #animFrames
					endFrame = 1
					loop = 0
					loopCount = 0
					remove = false
				end
			end
		
			currentFrame = startFrame
			animFrames[startFrame].isVisible = true 
		
			self.repeatFunction = prevFrame
			Runtime:addEventListener( "enterFrame", self )
		end

	
		function g:nextFrame()
			-- stop current sequence, if any, and reset to defaults
			Runtime:removeEventListener( "enterFrame", self )
			inSequence = false
		
			animFrames[currentFrame].isVisible = false
			currentFrame = currentFrame + 1
			if ( currentFrame > #animFrames ) then
				currentFrame = 1
			end
			animFrames[currentFrame].isVisible = true
		end
	
	
		function g:previousFrame()
			-- stop current sequence, if any, and reset to defaults
			Runtime:removeEventListener( "enterFrame", self )
			inSequence = false
		
			animFrames[currentFrame].isVisible = false
			currentFrame = currentFrame - 1
			if ( currentFrame < 1 ) then
				currentFrame = #animFrames
			end
			animFrames[currentFrame].isVisible = true
		end

		function g:currentFrame()
			return currentFrame
		end
	
		function g:totalFrames()
			return totalFrames
		end
	
		function g:stop()
			Runtime:removeEventListener( "enterFrame", self )
		end

		function g:stopAtFrame(label)
			-- This works for either numerical indices or optional text labels
			if (type(label) == "number") then
				Runtime:removeEventListener( "enterFrame", self )
				animFrames[currentFrame].isVisible = false
				currentFrame = label
				animFrames[currentFrame].isVisible = true
			
			elseif (type(label) == "string") then
				for k, v in next, animLabels do
					if (v == label) then
						Runtime:removeEventListener( "enterFrame", self )
						animFrames[currentFrame].isVisible = false
						currentFrame = k
						animFrames[currentFrame].isVisible = true
					end
				end
			end
		end

	
		function g:playAtFrame(label)
			-- This works for either numerical indices or optional text labels
			if (type(label) == "number") then
				Runtime:removeEventListener( "enterFrame", self )
				animFrames[currentFrame].isVisible = false
				currentFrame = label
				animFrames[currentFrame].isVisible = true
			
			elseif (type(label) == "string") then
				for k, v in next, animLabels do
					if (v == label) then
						Runtime:removeEventListener( "enterFrame", self )
						animFrames[currentFrame].isVisible = false
						currentFrame = k
						animFrames[currentFrame].isVisible = true
					end
				end
			end
			self.repeatFunction = nextFrame
			Runtime:addEventListener( "enterFrame", self )
		end


		function g:setDrag( params )
			if ( params ) then
				if params.drag == true then
					limitX = (params.limitX == true)
					limitY = (params.limitY == true)
					transpose = (params.transpose == true)
					dragBounds = nil
				
					if ( params.onPress and ( type(params.onPress) == "function" ) ) then
						g._onPress = params.onPress
					end
					if ( params.onDrag and ( type(params.onDrag) == "function" ) ) then
						g._onDrag = params.onDrag
					end
					if ( params.onRelease and ( type(params.onRelease) == "function" ) ) then
						g._onRelease = params.onRelease
					end
					if ( params.bounds and ( type(params.bounds) == "table" ) ) then
						dragBounds = params.bounds
						dragLeft = dragBounds[1]
						dragTop = dragBounds[2]
						dragWidth = dragBounds[3]
						dragHeight = dragBounds[4]
					end
				
					g.touch = dragMe
					g:addEventListener( "touch", g )
				
				else
					g:removeEventListener( "touch", g )
					dragBounds = nil
				
				end
			end
		end


		-- Optional function to assign text labels to frames
		function g:setLabels(labelTable)
			for k, v in next, labelTable do
				if (type(k) == "string") then
					animLabels[v] = k
				end
			end		
		end
	
		-- Return instance of anim
		--return g
		clips[name] = g
		mcx:insert(g)
		active = g
		animName = name
		paused = false
	end
	
	function mcx:log(msg)
		if debug == true then
			print("MCX_MSG: " .. msg)
		end
	end
	
	function mcx:play(name)
		if name == nil and animName == nil then
			print("Error, no animation name given and no animations to be resumed.")
		else
			if name == nil then
				name = animName
			end
			mcx:log("Playing " .. name)
			mcx:stop()
			active = clips[name]
			active.isVisible = true
			clips[name]:playAtFrame(1)
			animName = name
			paused = false
		end
	end
	
	function mcx:stop()
		clips[animName]:stop()
		active.isVisible = false
		active = nil
		animName = nil
	end
	
	function mcx:pause()
		clips[animName]:stop()
		paused = true
	end
	
	function mcx:isPaused()
		return paused
	end
	
	function mcx:isPlaying()
		if paused == true then
			return false
		end
		return true
	end
	
	function mcx:currentFrame()
		return clips[animName]:currentFrame()
	end
	
	function mcx:togglePause()
		if paused then
			paused = false
			mcx:play()
		else
			paused = true
			mcx:pause()
		end
	end
	
	
	function mcx:currentAnimation()
		return animName
	end
	
	
	function mcx:enableDebugging()
		debug = true
	end
	
	function mcx:disableDebugging()
		debug = false
	end
		
	return mcx
end
