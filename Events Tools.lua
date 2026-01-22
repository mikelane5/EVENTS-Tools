-- Setting directories for ImGui and scripts
package.path = reaper.ImGui_GetBuiltinPath() .. '/?.lua'
package.path = reaper.GetResourcePath() .. "/Scripts/EventsTools/?.lua;" .. package.path
local ImGui = require 'imgui' '0.9.3'

-- Create ImGui context
local ctx = ImGui.CreateContext('EVENT Tools')

-- Load .Lua file functions
local AddMarker = require('MarkerUtils')
local MarkersToSections = require "MarkersToSections"
local MusicStart = require "MusicStart"
local MusicEnd = require "MusicEnd"
local AddEnd = require "AddEnd"
local CrowdClap = require "CrowdClap"
local CrowdNoClap = require "CrowdNoClap"
local CrowdMellow = require "CrowdMellow"
local CrowdNormal = require "CrowdNormal"
local CrowdIntense = require "CrowdIntense"
local CrowdRealtime = require "CrowdRealtime"

-- Load marker colors from MarkerUtils
local MARKER_COLORS = {
    intro = 0x00FF00FF,      -- Green
    preverse = 0xFF8C00FF,   -- Orange
    verse = 0xFF0000FF,      -- Red
    postverse = 0x8B0032FF,  -- Dark Red
    prechorus = 0x00BFFFFF,  -- Light Blue/Cyan
    chorus = 0x0000FFFF,     -- Blue
    postchorus = 0x00008BFF, -- Navy/Dark Blue
    main = 0xFFFF00FF,       -- Yellow
    bridge = 0xB700AEFF,     -- Purple
    gtr = 0xFFA500FF,        -- Orange
    bass = 0xFFA500FF,       -- Orange
    drum = 0xFFA500FF,       -- Orange
    keyboard = 0xFFA500FF,   -- Orange
    outro = 0xFFFFFFFF,      -- White
}

-- Function to check if a marker exists
local function MarkerExists(markerName)
    local numMarkers = reaper.CountProjectMarkers(0)
    for i = 0, numMarkers - 1 do
        local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
        if not isrgn and name == markerName then
            return true
        end
    end
    return false
end

-- Colored button helper - uses marker type color
local function ColoredButton(label, id, markerName, width, height)
    local exists = MarkerExists(markerName)
    
    if exists then
        -- Extract marker type from marker name
        local markerType = markerName:match("^([^_]+)")
        local color = MARKER_COLORS[markerType] or 0x808080FF
        
        -- Light colored buttons that need dark text
        local needsDarkText = {
            intro = true,
            preverse = true,
            prechorus = true,
            main = true,
            gtr = true,
            bass = true,
            drum = true,
            keyboard = true,
            outro = true
        }
        
        -- Change button color
        ImGui.PushStyleColor(ctx, ImGui.Col_Button, color)
        
        -- Change text color to black for light buttons
        if needsDarkText[markerType] then
            ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0x000000FF)  -- Black text
        end
    end
    
    local buttonLabel = label .. id
    local clicked = ImGui.Button(ctx, buttonLabel, width, height)
    
    if exists then
        local markerType = markerName:match("^([^_]+)")
        local needsDarkText = {
            intro = true, preverse = true, prechorus = true, main = true,
            gtr = true, bass = true, drum = true, keyboard = true, outro = true
        }
        
        -- Pop text color if it was changed
        if needsDarkText[markerType] then
            ImGui.PopStyleColor(ctx)  -- Pop text color
        end
        ImGui.PopStyleColor(ctx)  -- Pop button color
    end
    
    return clicked
end

-- Reposition Window if it goes offscreen in virtual machine after sleep
-- reaper.ImGui_SetNextWindowPos(ctx, 100, 100, reaper.ImGui_Cond_Always())

-- Main GUI loop
local function loop()
    ImGui.SetNextWindowSize(ctx, 1220, 680, ImGui.Cond_Always)
    local visible, open = ImGui.Begin(ctx, 'EVENTS Tools', true)
    if visible then


        ImGui.Text(ctx, 'Common Practice Section Markers')
	
--Intro Practice Section Markers
	
		if ColoredButton('Intro', '', 'intro', 143, 30) then
		    AddMarker('intro')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##intro_a', 'intro_a', 30, 30) then
		    AddMarker('intro_a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##intro_b', 'intro_b', 30, 30) then
		    AddMarker('intro_b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##intro_c', 'intro_c', 30, 30) then
		    AddMarker('intro_c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##intro_d', 'intro_d', 30, 30) then
		    AddMarker('intro_d')
		end

--PreVerse_1 Practice Section Markers
	
		if ColoredButton('PreVerse_1', '', 'preverse_1', 143, 30) then
		    AddMarker('preverse_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pv1a', 'preverse_1a', 30, 30) then
		    AddMarker('preverse_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pv1b', 'preverse_1b', 30, 30) then
		    AddMarker('preverse_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pv1c', 'preverse_1c', 30, 30) then
		    AddMarker('preverse_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pv1d', 'preverse_1d', 30, 30) then
		    AddMarker('preverse_1d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PreVerse_2 Practice Section Markers

		if ColoredButton('PreVerse_2', '', 'preverse_2', 143, 30) then
		    AddMarker('preverse_2')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pv2a', 'preverse_2a', 30, 30) then
		    AddMarker('preverse_2a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pv2b', 'preverse_2b', 30, 30) then
		    AddMarker('preverse_2b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pv2c', 'preverse_2c', 30, 30) then
		    AddMarker('preverse_2c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pv2d', 'preverse_2d', 30, 30) then
		    AddMarker('preverse_2d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PreVerse_3 Practice Section Markers
	
		if ColoredButton('PreVerse_3', '', 'preverse_3', 143, 30) then
		    AddMarker('preverse_3')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pv3a', 'preverse_3a', 30, 30) then
		    AddMarker('preverse_3a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pv3b', 'preverse_3b', 30, 30) then
		    AddMarker('preverse_3b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pv3c', 'preverse_3c', 30, 30) then
		    AddMarker('preverse_3c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pv3d', 'preverse_3d', 30, 30) then
		    AddMarker('preverse_3d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PreVerse_4 Practice Section Markers

		if ColoredButton('PreVerse_4', '', 'preverse_4', 143, 30) then
		    AddMarker('preverse_4')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pv4a', 'preverse_4a', 30, 30) then
		    AddMarker('preverse_4a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pv4b', 'preverse_4b', 30, 30) then
		    AddMarker('preverse_4b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pv4c', 'preverse_4c', 30, 30) then
		    AddMarker('preverse_4c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pv4d', 'preverse_4d', 30, 30) then
		    AddMarker('preverse_4d')
		end

--Verse_1 Practice Section Markers
	
		if ColoredButton('Verse_1', '', 'verse_1', 143, 30) then
		    AddMarker('verse_1')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

		if ColoredButton('a', '##v1a', 'verse_1a', 30, 30) then
		    AddMarker('verse_1a')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

		if ColoredButton('b', '##v1b', 'verse_1b', 30, 30) then
		    AddMarker('verse_1b')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

		if ColoredButton('c', '##v1c', 'verse_1c', 30, 30) then
		    AddMarker('verse_1c')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

		if ColoredButton('d', '##v1d', 'verse_1d', 30, 30) then
		    AddMarker('verse_1d')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

--Verse_2 Practise Section Markers


		if ColoredButton('Verse_2', '', 'verse_2', 143, 30) then
		    AddMarker('verse_2')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##v2a', 'verse_2a', 30, 30) then
		    AddMarker('verse_2a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##v2b', 'verse_2b', 30, 30) then
		    AddMarker('verse_2b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##v2c', 'verse_2c', 30, 30) then
		    AddMarker('verse_2c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##v2d', 'verse_2d', 30, 30) then
		    AddMarker('verse_2d')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

--Verse_3 Practice Section Markers
	
		if ColoredButton('Verse_3', '', 'verse_3', 143, 30) then
		    AddMarker('verse_3')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##v3a', 'verse_3a', 30, 30) then
		    AddMarker('verse_3a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##v3b', 'verse_3b', 30, 30) then
		    AddMarker('verse_3b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##v3c', 'verse_3c', 30, 30) then
		    AddMarker('verse_3c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##v3d', 'verse_3d', 30, 30) then
		    AddMarker('verse_3d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--Verse_4 Practice Section Markers

		if ColoredButton('Verse_4', '', 'verse_4', 143, 30) then
		    AddMarker('verse_4')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##v4a', 'verse_4a', 30, 30) then
		    AddMarker('verse_4a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##v4b', 'verse_4b', 30, 30) then
		    AddMarker('verse_4b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##v4c', 'verse_4c', 30, 30) then
		    AddMarker('verse_4c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##v4d', 'verse_4d', 30, 30) then
		    AddMarker('verse_4d')
		end

--PostVerse_1 Practice Section Markers
	
		if ColoredButton('PostVerse_1', '', 'postverse_1', 143, 30) then
		    AddMarker('postverse_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pov1a', 'postverse_1a', 30, 30) then
		    AddMarker('postverse_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pov1b', 'postverse_1b', 30, 30) then
		    AddMarker('postverse_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pov1c', 'postverse_1c', 30, 30) then
		    AddMarker('postverse_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pov1d', 'postverse_1d', 30, 30) then
		    AddMarker('postverse_1d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PostVerse_2 Practice Section Markers

		if ColoredButton('PostVerse_2', '', 'postverse_2', 143, 30) then
		    AddMarker('postverse_2')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pov2a', 'postverse_2a', 30, 30) then
		    AddMarker('postverse_2a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pov2b', 'postverse_2b', 30, 30) then
		    AddMarker('postverse_2b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pov2c', 'postverse_2c', 30, 30) then
		    AddMarker('postverse_2c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pov2d', 'postverse_2d', 30, 30) then
		    AddMarker('postverse_2d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PostVerse_3 Practice Section Markers
	
		if ColoredButton('PostVerse_3', '', 'postverse_3', 143, 30) then
		    AddMarker('postverse_3')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pov3a', 'postverse_3a', 30, 30) then
		    AddMarker('postverse_3a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pov3b', 'postverse_3b', 30, 30) then
		    AddMarker('postverse_3b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pov3c', 'postverse_3c', 30, 30) then
		    AddMarker('postverse_3c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pov3d', 'postverse_3d', 30, 30) then
		    AddMarker('postverse_3d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PostVerse_4 Practice Section Markers

		if ColoredButton('PostVerse_4', '', 'postverse_4', 143, 30) then
		    AddMarker('postverse_4')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pov4a', 'postverse_4a', 30, 30) then
		    AddMarker('postverse_4a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pov4b', 'postverse_4b', 30, 30) then
		    AddMarker('postverse_4b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pov4c', 'postverse_4c', 30, 30) then
		    AddMarker('postverse_4c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pov4d', 'postverse_4d', 30, 30) then
		    AddMarker('postverse_4d')
		end


--PreChorus_1 Practice Section Markers
	
		if ColoredButton('PreChorus_1', '', 'prechorus_1', 143, 30) then
		    AddMarker('prechorus_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pc1a', 'prechorus_1a', 30, 30) then
		    AddMarker('prechorus_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pc1b', 'prechorus_1b', 30, 30) then
		    AddMarker('prechorus_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pc1c', 'prechorus_1c', 30, 30) then
		    AddMarker('prechorus_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pc1d', 'prechorus_1d', 30, 30) then
		    AddMarker('prechorus_1d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PreChorus_2 Practice Section Markers

		if ColoredButton('PreChorus_2', '', 'prechorus_2', 143, 30) then
		    AddMarker('prechorus_2')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pc2a', 'prechorus_2a', 30, 30) then
		    AddMarker('prechorus_2a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pc2b', 'prechorus_2b', 30, 30) then
		    AddMarker('prechorus_2b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pc2c', 'prechorus_2c', 30, 30) then
		    AddMarker('prechorus_2c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pc2d', 'prechorus_2d', 30, 30) then
		    AddMarker('prechorus_2d')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

--PreChorus_3 Practice Section Markers
	
		if ColoredButton('PreChorus_3', '', 'prechorus_3', 143, 30) then
		    AddMarker('prechorus_3')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pc3a', 'prechorus_3a', 30, 30) then
		    AddMarker('prechorus_3a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pc3b', 'prechorus_3b', 30, 30) then
		    AddMarker('prechorus_3b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pc3c', 'prechorus_3c', 30, 30) then
		    AddMarker('prechorus_3c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pc3d', 'prechorus_3d', 30, 30) then
		    AddMarker('prechorus_3d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PreChorus_4 Practice Section Markers

		if ColoredButton('PreChorus_4', '', 'prechorus_4', 143, 30) then
		    AddMarker('prechorus_4')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##pc4a', 'prechorus_4a', 30, 30) then
		    AddMarker('prechorus_4a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##pc4b', 'prechorus_4b', 30, 30) then
		    AddMarker('prechorus_4b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##pc4c', 'prechorus_4c', 30, 30) then
		    AddMarker('prechorus_4c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##pc4d', 'prechorus_4d', 30, 30) then
		    AddMarker('prechorus_4d')
		end

--Chorus_1 Practice Section Markers
	
		if ColoredButton('Chorus_1', '', 'chorus_1', 143, 30) then
		    AddMarker('chorus_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##c1a', 'chorus_1a', 30, 30) then
		    AddMarker('chorus_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##c1b', 'chorus_1b', 30, 30) then
		    AddMarker('chorus_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##c1c', 'chorus_1c', 30, 30) then
		    AddMarker('chorus_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##c1d', 'chorus_1d', 30, 30) then
		    AddMarker('chorus_1d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--Chorus_2 Practice Section Markers

		if ColoredButton('Chorus_2', '', 'chorus_2', 143, 30) then
		    AddMarker('chorus_2')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##c2a', 'chorus_2a', 30, 30) then
		    AddMarker('chorus_2a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##c2b', 'chorus_2b', 30, 30) then
		    AddMarker('chorus_2b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##c2c', 'chorus_2c', 30, 30) then
		    AddMarker('chorus_2c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##c2d', 'chorus_2d', 30, 30) then
		    AddMarker('chorus_2d')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

--Chorus_3 Practice Section Markers
	
		if ColoredButton('Chorus_3', '', 'chorus_3', 143, 30) then
		    AddMarker('chorus_3')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##c3a', 'chorus_3a', 30, 30) then
		    AddMarker('chorus_3a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##c3b', 'chorus_3b', 30, 30) then
		    AddMarker('chorus_3b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##c3c', 'chorus_3c', 30, 30) then
		    AddMarker('chorus_3c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##c3d', 'chorus_3d', 30, 30) then
		    AddMarker('chorus_3d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--Chorus_4 Practice Section Markers

		if ColoredButton('Chorus_4', '', 'chorus_4', 143, 30) then
		    AddMarker('chorus_4')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##c4a', 'chorus_4a', 30, 30) then
		    AddMarker('chorus_4a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##c4b', 'chorus_4b', 30, 30) then
		    AddMarker('chorus_4b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##c4c', 'chorus_4c', 30, 30) then
		    AddMarker('chorus_4c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##c4d', 'chorus_4d', 30, 30) then
		    AddMarker('chorus_4d')
		end

--PostChorus_1 Practice Section Markers
	
		if ColoredButton('PostChorus_1', '', 'postchorus_1', 143, 30) then
		    AddMarker('postchorus_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##poch1a', 'postchorus_1a', 30, 30) then
		    AddMarker('postchorus_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##poch1b', 'postchorus_1b', 30, 30) then
		    AddMarker('postchorus_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##poch1c', 'postchorus_1c', 30, 30) then
		    AddMarker('postchorus_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##poch1d', 'postchorus_1d', 30, 30) then
		    AddMarker('postchorus_1d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PostChorus_2 Practice Section Markers
		if ColoredButton('PostChorus_2', '', 'postchorus_2', 143, 30) then
		    AddMarker('postchorus_2')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##poch2a', 'postchorus_2a', 30, 30) then
		    AddMarker('postchorus_2a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##poch2b', 'postchorus_2b', 30, 30) then
		    AddMarker('postchorus_2b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##poch2c', 'postchorus_2c', 30, 30) then
		    AddMarker('postchorus_2c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##poch2d', 'postchorus_2d', 30, 30) then
		    AddMarker('postchorus_2d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PostChorus_3 Practice Section Markers
	
		if ColoredButton('PostChorus_3', '', 'postchorus_3', 143, 30) then
		    AddMarker('postchorus_3')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##poch3a', 'postchorus_3a', 30, 30) then
		    AddMarker('postchorus_3a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##poch3b', 'postchorus_3b', 30, 30) then
		    AddMarker('postchorus_3b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##poch3c', 'postchorus_3c', 30, 30) then
		    AddMarker('postchorus_3c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##poch3d', 'postchorus_3d', 30, 30) then
		    AddMarker('postchorus_3d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--PostChorus_4 Practice Section Markers

		if ColoredButton('PostChorus_4', '', 'postchorus_4', 143, 30) then
		    AddMarker('postchorus_4')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##poch4a', 'postchorus_4a', 30, 30) then
		    AddMarker('postchorus_4a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##poch4b', 'postchorus_4b', 30, 30) then
		    AddMarker('postchorus_4b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##poch4c', 'postchorus_4c', 30, 30) then
		    AddMarker('postchorus_4c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##poch4d', 'postchorus_4d', 30, 30) then
		    AddMarker('postchorus_4d')
		end

--Main_Riff_1 Practice Section Markers
	
		if ColoredButton('Main_Riff_1', '', 'main_riff_1', 143, 30) then
		    AddMarker('main_riff_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##mr1a', 'main_riff_1a', 30, 30) then
		    AddMarker('main_riff_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##mr1b', 'main_riff_1b', 30, 30) then
		    AddMarker('main_riff_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##mr1c', 'main_riff_1c', 30, 30) then
		    AddMarker('main_riff_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##mr1d', 'main_riff_1d', 30, 30) then
		    AddMarker('main_riff_1d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--Main_Riff_2 Practice Section Markers

		if ColoredButton('Main_Riff_2', '', 'main_riff_2', 143, 30) then
		    AddMarker('main_riff_2')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##mr2a', 'main_riff_2a', 30, 30) then
		    AddMarker('main_riff_2a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##mr2b', 'main_riff_2b', 30, 30) then
		    AddMarker('main_riff_2b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##mr2c', 'main_riff_2c', 30, 30) then
		    AddMarker('main_riff_2c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##mr2d', 'main_riff_2d', 30, 30) then
		    AddMarker('main_riff_2d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)

--Main_Riff_3 Practice Section Markers
	
		if ColoredButton('Main_Riff_3', '', 'main_riff_3', 143, 30) then
		    AddMarker('main_riff_3')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##mr3a', 'main_riff_3a', 30, 30) then
		    AddMarker('main_riff_3a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##mr3b', 'main_riff_3b', 30, 30) then
		    AddMarker('main_riff_3b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##mr3c', 'main_riff_3c', 30, 30) then
		    AddMarker('main_riff_3c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##mr3d', 'main_riff_3d', 30, 30) then
		    AddMarker('main_riff_3d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--Main_Riff_4 Practice Section Markers

		if ColoredButton('Main_Riff_4', '', 'main_riff_4', 143, 30) then
		    AddMarker('main_riff_4')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##mr4a', 'main_riff_4a', 30, 30) then
		    AddMarker('main_riff_4a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##mr4b', 'main_riff_4b', 30, 30) then
		    AddMarker('main_riff_4b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##mr4c', 'main_riff_4c', 30, 30) then
		    AddMarker('main_riff_4c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##mr4d', 'main_riff_4d', 30, 30) then
		    AddMarker('main_riff_4d')
		end

--Bridge_1 Practice Section Markers
	
		if ColoredButton('Bridge_1', '', 'bridge_1', 143, 30) then
		    AddMarker('bridge_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##b1a', 'bridge_1a', 30, 30) then
		    AddMarker('bridge_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##b1b', 'bridge_1b', 30, 30) then
		    AddMarker('bridge_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##b1c', 'bridge_1c', 30, 30) then
		    AddMarker('bridge_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##b1d', 'bridge_1d', 30, 30) then
		    AddMarker('bridge_1d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--Bridge_2 Practice Section Markers

		if ColoredButton('Bridge_2', '', 'bridge_2', 143, 30) then
		    AddMarker('bridge_2')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##b2a', 'bridge_2a', 30, 30) then
		    AddMarker('bridge_2a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##b2b', 'bridge_2b', 30, 30) then
		    AddMarker('bridge_2b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##b2c', 'bridge_2c', 30, 30) then
		    AddMarker('bridge_2c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##b2d', 'bridge_2d', 30, 30) then
		    AddMarker('bridge_2d')
		end


--Gtr_Solo_1 Practice Section Markers
	
		if ColoredButton('Gtr_Solo_1', '', 'gtr_solo_1', 143, 30) then
		    AddMarker('gtr_solo_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##gs1a', 'gtr_solo_1a', 30, 30) then
		    AddMarker('gtr_solo_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##gs1b', 'gtr_solo_1b', 30, 30) then
		    AddMarker('gtr_solo_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##gs1c', 'gtr_solo_1c', 30, 30) then
		    AddMarker('gtr_solo_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##gs1d', 'gtr_solo_1d', 30, 30) then
		    AddMarker('gtr_solo_1d')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--Gtr_Solo_2 Practice Section Markers
		if ColoredButton('Gtr_Solo_2', '', 'gtr_solo_2', 143, 30) then
		    AddMarker('gtr_solo_2')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##gs2a', 'gtr_solo_2a', 30, 30) then
		    AddMarker('gtr_solo_2a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##gs2b', 'gtr_solo_2b', 30, 30) then
		    AddMarker('gtr_solo_2b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##gs2c', 'gtr_solo_2c', 30, 30) then
		    AddMarker('gtr_solo_2c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##gs2d', 'gtr_solo_2d', 30, 30) then
		    AddMarker('gtr_solo_2d')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

--Gtr_Solo_3 Practice Section Markers
	
		if ColoredButton('Gtr_Solo_3', '', 'gtr_solo_3', 143, 30) then
		    AddMarker('gtr_solo_3')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##gs3a', 'gtr_solo_3a', 30, 30) then
		    AddMarker('gtr_solo_3a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##gs3b', 'gtr_solo_3b', 30, 30) then
		    AddMarker('gtr_solo_3b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##gs3c', 'gtr_solo_3c', 30, 30) then
		    AddMarker('gtr_solo_3c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##gs3d', 'gtr_solo_3d', 30, 30) then
		    AddMarker('gtr_solo_3d')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)


--Gtr_Solo_4 Practice Section Markers

		if ColoredButton('Gtr_Solo_4', '', 'gtr_solo_4', 143, 30) then
		    AddMarker('gtr_solo_4')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##gs4a', 'gtr_solo_4a', 30, 30) then
		    AddMarker('gtr_solo_4a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##gs4b', 'gtr_solo_4b', 30, 30) then
		    AddMarker('gtr_solo_4b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##gs4c', 'gtr_solo_4c', 30, 30) then
		    AddMarker('gtr_solo_4c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##gs4d', 'gtr_solo_4d', 30, 30) then
		    AddMarker('gtr_solo_4d')
		end


--Bass_Solo_1 Practice Section Markers
	
		if ColoredButton('Bass_Solo_1', '', 'bass_solo_1', 143, 30) then
		    AddMarker('bass_solo_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##bass1a', 'bass_solo_1a', 30, 30) then
		    AddMarker('bass_solo_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##bass1b', 'bass_solo_1b', 30, 30) then
		    AddMarker('bass_solo_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##bass1c', 'bass_solo_1c', 30, 30) then
		    AddMarker('bass_solo_1c')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##bass1d', 'bass_solo_1d', 30, 30) then
		    AddMarker('bass_solo_1d')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

--Drum_Solo_1 Practice Section Markers

		if ColoredButton('Drum_Solo_1', '', 'drum_solo_1', 143, 30) then
		    AddMarker('drum_solo_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##drum1a', 'drum_solo_1a', 30, 30) then
		    AddMarker('drum_solo_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##drum1b', 'drum_solo_1b', 30, 30) then
		    AddMarker('drum_solo_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##drum1c', 'drum_solo_1c', 30, 30) then
		    AddMarker('drum_solo_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##drum1d', 'drum_solo_1d', 30, 30) then
		    AddMarker('drum_solo_1d')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx) 

--Keyboard_Solo_1 Practice Section Markers
	
		if ColoredButton('Keyboard_Solo_1', '', 'keyboard_solo_1', 143, 30) then
		    AddMarker('keyboard_solo_1')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##key1a', 'keyboard_solo_1a', 30, 30) then
		    AddMarker('keyboard_solo_1a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##key1b', 'keyboard_solo_1b', 30, 30) then
		    AddMarker('keyboard_solo_1b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##key1c', 'keyboard_solo_1c', 30, 30) then
		    AddMarker('keyboard_solo_1c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##key1d', 'keyboard_solo_1d', 30, 30) then
		    AddMarker('keyboard_solo_1d')
		end

--Outro Practice Section Markers
	
		if ColoredButton('Outro', '', 'outro', 143, 30) then
		    AddMarker('outro')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##outa', 'outro_a', 30, 30) then
		    AddMarker('outro_a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##outb', 'outro_b', 30, 30) then
		    AddMarker('outro_b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##outc', 'outro_c', 30, 30) then
		    AddMarker('outro_c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##outd', 'outro_d', 30, 30) then
		    AddMarker('outro_d')
		end

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

--Outro_Chorus Practice Section Markers
	
		if ColoredButton('Outro_Chorus', '', 'outro_chorus', 143, 30) then
		    AddMarker('outro_chorus')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('a', '##oc1a', 'outro_chorus_a', 30, 30) then
		    AddMarker('outro_chorus_a')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('b', '##oc1b', 'outro_chorus_b', 30, 30) then
		    AddMarker('outro_chorus_b')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('c', '##oc1c', 'outro_chorus_c', 30, 30) then
		    AddMarker('outro_chorus_c')
		end
       		 	-- Spacer
	     		ImGui.SameLine(ctx)
		if ColoredButton('d', '##oc1d', 'outro_chorus_d', 30, 30) then
		    AddMarker('outro_chorus_d')
		end

-- Marker tools section

        ImGui.Text(ctx, 'EVENTS Track Tools')

        -- Button for "Markers to Sections"
        if ImGui.Button(ctx, 'Copy Markers to EVENTS Track', 294, 30) then
            MarkersToSections()
        end

		-- Music events section
        ImGui.SeparatorText(ctx,'Music Events')

        if ImGui.Button(ctx, 'Add Music Start', 143, 30) then
            MusicStart()
        end

        -- Spacer
        ImGui.SameLine(ctx)

        if ImGui.Button(ctx, 'Add Music End', 143, 30) then
            MusicEnd()
        end

		ImGui.SameLine(ctx)

        if ImGui.Button(ctx, 'Add End', 143, 30) then
            AddEnd()
        end

		-- Crowd clap section
        ImGui.SeparatorText(ctx,'Crowd Clap')

        if ImGui.Button(ctx, 'Add Crowd Clap', 143, 30) then
            CrowdClap()
        end

		ImGui.SameLine(ctx)

		if ImGui.Button(ctx, 'Add Crowd NoClap', 143, 30) then
            CrowdNoClap()
        end

		-- Crowd clap section
        ImGui.SeparatorText(ctx,'Crowd intensity')

        if ImGui.Button(ctx, 'Crowd Mellow', 143, 30) then
            CrowdMellow()
        end

		ImGui.SameLine(ctx)

		if ImGui.Button(ctx, 'Crowd Normal', 143, 30) then
            CrowdNormal()
        end

		ImGui.SameLine(ctx)

		if ImGui.Button(ctx, 'Crowd Intense', 143, 30) then
            CrowdIntense()
        end

		ImGui.SameLine(ctx)

		if ImGui.Button(ctx, 'Crowd Realtime', 143, 30) then
            CrowdRealtime()
        end

        -- Finalizing the window
        ImGui.End(ctx)			
    end

    -- Keep loop active while the window is open
    if open then
        reaper.defer(loop)
    end
end

-- Starting the loop
reaper.defer(loop)