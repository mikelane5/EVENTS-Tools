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
local CrowdFistsOn = require "CrowdFistsOn"
local CrowdFistsOff = require "CrowdFistsOff"
local CrowdHornsOn = require "CrowdHornsOn"
local CrowdHornsOff = require "CrowdHornsOff"
local CrowdLightersOn = require "CrowdLightersOn"
local CrowdLightersOff = require "CrowdLightersOff"

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

-- Crowd state pairs to track
local CROWD_PAIRS = {
    { on = "crowd_fists_on",    off = "crowd_fists_off" },
    { on = "crowd_horns_on",    off = "crowd_horns_off" },
    { on = "crowd_lighters_on", off = "crowd_lighters_off" },
}

-- Load practice section list from file
local PRACTICE_SECTIONS = {}  -- ALL practice sections for validation
local PRACTICE_SECTIONS_DISPLAY = {}  -- Filtered for dropdown display
local PRACTICE_SECTIONS_DISPLAY_NAMES = {}  -- Display names for dropdown
local function LoadPracticeSections()
    local file_path = reaper.GetResourcePath() .. "/Scripts/EventsTools/practice_section_list.txt"
    local file = io.open(file_path, "r")
    
    if not file then
        reaper.ShowConsoleMsg("Warning: practice_section_list.txt not found\n")
        return
    end
    
    -- Build set of existing button markers to filter from dropdown only
    local existing_buttons = {
        intro=true, intro_a=true, intro_b=true, intro_c=true, intro_d=true,
        preverse_1=true, preverse_1a=true, preverse_1b=true, preverse_1c=true, preverse_1d=true,
        preverse_2=true, preverse_2a=true, preverse_2b=true, preverse_2c=true, preverse_2d=true,
        preverse_3=true, preverse_3a=true, preverse_3b=true, preverse_3c=true, preverse_3d=true,
        preverse_4=true, preverse_4a=true, preverse_4b=true, preverse_4c=true, preverse_4d=true,
        verse_1=true, verse_1a=true, verse_1b=true, verse_1c=true, verse_1d=true,
        verse_2=true, verse_2a=true, verse_2b=true, verse_2c=true, verse_2d=true,
        verse_3=true, verse_3a=true, verse_3b=true, verse_3c=true, verse_3d=true,
        verse_4=true, verse_4a=true, verse_4b=true, verse_4c=true, verse_4d=true,
        postverse_1=true, postverse_1a=true, postverse_1b=true, postverse_1c=true, postverse_1d=true,
        postverse_2=true, postverse_2a=true, postverse_2b=true, postverse_2c=true, postverse_2d=true,
        postverse_3=true, postverse_3a=true, postverse_3b=true, postverse_3c=true, postverse_3d=true,
        postverse_4=true, postverse_4a=true, postverse_4b=true, postverse_4c=true, postverse_4d=true,
        prechorus_1=true, prechorus_1a=true, prechorus_1b=true, prechorus_1c=true, prechorus_1d=true,
        prechorus_2=true, prechorus_2a=true, prechorus_2b=true, prechorus_2c=true, prechorus_2d=true,
        prechorus_3=true, prechorus_3a=true, prechorus_3b=true, prechorus_3c=true, prechorus_3d=true,
        prechorus_4=true, prechorus_4a=true, prechorus_4b=true, prechorus_4c=true, prechorus_4d=true,
        chorus_1=true, chorus_1a=true, chorus_1b=true, chorus_1c=true, chorus_1d=true,
        chorus_2=true, chorus_2a=true, chorus_2b=true, chorus_2c=true, chorus_2d=true,
        chorus_3=true, chorus_3a=true, chorus_3b=true, chorus_3c=true, chorus_3d=true,
        chorus_4=true, chorus_4a=true, chorus_4b=true, chorus_4c=true, chorus_4d=true,
        postchorus_1=true, postchorus_1a=true, postchorus_1b=true, postchorus_1c=true, postchorus_1d=true,
        postchorus_2=true, postchorus_2a=true, postchorus_2b=true, postchorus_2c=true, postchorus_2d=true,
        postchorus_3=true, postchorus_3a=true, postchorus_3b=true, postchorus_3c=true, postchorus_3d=true,
        postchorus_4=true, postchorus_4a=true, postchorus_4b=true, postchorus_4c=true, postchorus_4d=true,
        main_1=true, main_1a=true, main_1b=true, main_1c=true, main_1d=true,
        main_2=true, main_2a=true, main_2b=true, main_2c=true, main_2d=true,
        main_3=true, main_3a=true, main_3b=true, main_3c=true, main_3d=true,
        main_4=true, main_4a=true, main_4b=true, main_4c=true, main_4d=true,
        bridge_1=true, bridge_1a=true, bridge_1b=true, bridge_1c=true, bridge_1d=true,
        bridge_2=true, bridge_2a=true, bridge_2b=true, bridge_2c=true, bridge_2d=true,
        bridge_3=true, bridge_3a=true, bridge_3b=true, bridge_3c=true, bridge_3d=true,
        bridge_4=true, bridge_4a=true, bridge_4b=true, bridge_4c=true, bridge_4d=true,
        gtr_solo_1=true, gtr_solo_1a=true, gtr_solo_1b=true, gtr_solo_1c=true, gtr_solo_1d=true,
        gtr_solo_2=true, gtr_solo_2a=true, gtr_solo_2b=true, gtr_solo_2c=true, gtr_solo_2d=true,
        gtr_solo_3=true, gtr_solo_3a=true, gtr_solo_3b=true, gtr_solo_3c=true, gtr_solo_3d=true,
        gtr_solo_4=true, gtr_solo_4a=true, gtr_solo_4b=true, gtr_solo_4c=true, gtr_solo_4d=true,
        bass_solo_1=true, bass_solo_1a=true, bass_solo_1b=true, bass_solo_1c=true, bass_solo_1d=true,
        drum_solo_1=true, drum_solo_1a=true, drum_solo_1b=true, drum_solo_1c=true, drum_solo_1d=true,
        keyboard_solo_1=true, keyboard_solo_1a=true, keyboard_solo_1b=true, keyboard_solo_1c=true, keyboard_solo_1d=true,
        outro=true, outro_a=true, outro_b=true, outro_c=true, outro_d=true,
        outro_chorus=true, outro_chorus_a=true, outro_chorus_b=true, outro_chorus_c=true, outro_chorus_d=true,
    }
    
    for line in file:lines() do
        -- Parse: [prc_marker_name] "Display Name"
        local marker_name, display_name = line:match('%[prc_(.-)%]%s*"(.-)"')
        if marker_name and display_name then
            -- Add ALL to validation list
            table.insert(PRACTICE_SECTIONS, marker_name)
            
            -- Only add to dropdown if not an existing button
            if not existing_buttons[marker_name] then
                table.insert(PRACTICE_SECTIONS_DISPLAY, marker_name)
                table.insert(PRACTICE_SECTIONS_DISPLAY_NAMES, display_name)
            end
        end
    end
    
    file:close()
end

-- Load the practice sections on startup
LoadPracticeSections()

-- Clipboard for copied markers
local copied_markers = {}  -- Stores {name, relative_time} for each copied marker
local clipboard_display = "No markers copied"

-- Helper function: Get the base name and number from a marker
-- e.g., "verse_1a" -> base="verse", num=1, suffix="a"
local function ParseMarkerName(name)
    local base, num, suffix = name:match("^(.-)_(%d+)(.*)$")
    if base and num then
        return base, tonumber(num), suffix
    end
    -- Handle markers without numbers (e.g., "intro")
    local base_only = name:match("^([^_]+)$")
    if base_only then
        return base_only, nil, ""
    end
    return nil, nil, ""
end

-- Helper function: Find highest existing number for a base marker type in timeline
local function GetMaxMarkerNumber(base_name)
    local max_num = 0
    local num_markers = reaper.CountProjectMarkers(0)
    
    for i = 0, num_markers - 1 do
        local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
        if not isrgn then
            local marker_base, marker_num, marker_suffix = ParseMarkerName(name)
            if marker_base == base_name and marker_num and marker_num > max_num then
                max_num = marker_num
            end
        end
    end
    
    return max_num
end

-- Helper function: Check if a marker name exists in the master practice sections list
local function IsValidPracticeSection(name)
    for i = 1, #PRACTICE_SECTIONS do
        if PRACTICE_SECTIONS[i] == name then
            return true
        end
    end
    return false
end

-- Copy markers from timeline selection
local function CopyMarkers()
    local start_time, end_time = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    
    if start_time == end_time then
        reaper.ShowMessageBox("No timeline selection found.", "Error", 0)
        return
    end
    
    -- Collect all markers within the time selection
    local markers_in_selection = {}
    local num_markers = reaper.CountProjectMarkers(0)
    
    for i = 0, num_markers - 1 do
        local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
        if not isrgn and pos >= start_time and pos <= end_time then
            table.insert(markers_in_selection, {name = name, time = pos})
        end
    end
    
    if #markers_in_selection == 0 then
        reaper.ShowMessageBox("No practice section markers found in timeline selection.", "Error", 0)
        copied_markers = {}
        clipboard_display = "No markers copied"
        return
    end
    
    -- Sort by time
    table.sort(markers_in_selection, function(a, b) return a.time < b.time end)
    
    -- Calculate relative times (relative to first marker)
    local first_time = markers_in_selection[1].time
    copied_markers = {}
    
    for i, marker in ipairs(markers_in_selection) do
        table.insert(copied_markers, {
            name = marker.name,
            relative_time = marker.time - first_time
        })
    end
    
    -- Update display text
    local first_name = markers_in_selection[1].name
    local last_name = markers_in_selection[#markers_in_selection].name
    clipboard_display = string.format("Practice section markers selected: %d markers from %s to %s", 
                                      #markers_in_selection, first_name, last_name)
end

-- Paste markers at cursor with smart incrementing
local function PasteMarkers()
    if #copied_markers == 0 then
        reaper.ShowMessageBox("No markers in clipboard. Use 'Copy Markers' first.", "Error", 0)
        return
    end
    
    local cursor_pos = reaper.GetCursorPosition()
    
    -- Build increment map: for each base marker type, find the next available number
    local increment_map = {}
    
    for _, marker in ipairs(copied_markers) do
        local base, num, suffix = ParseMarkerName(marker.name)
        
        if base and num then
            -- Only calculate once per base type
            if not increment_map[base] then
                local max_existing = GetMaxMarkerNumber(base)
                increment_map[base] = max_existing + 1
            end
        end
    end
    
    -- Paste markers with incremented names
    local markers_to_create = {}
    
    for _, marker in ipairs(copied_markers) do
        local base, num, suffix = ParseMarkerName(marker.name)
        
        if base and num then
            -- Increment the number
            local new_num = num + (increment_map[base] - num)
            local new_name = base .. "_" .. new_num .. suffix
            
            -- Check if new name exists in master list
            if not IsValidPracticeSection(new_name) then
                reaper.ShowMessageBox(
                    string.format("Cannot paste: '%s' exceeds master practice section list.\n\nPaste aborted.", new_name),
                    "Error", 0)
                return
            end
            
            table.insert(markers_to_create, {
                name = new_name,
                time = cursor_pos + marker.relative_time
            })
        else
            -- Marker without number pattern, paste as-is
            table.insert(markers_to_create, {
                name = marker.name,
                time = cursor_pos + marker.relative_time
            })
        end
    end
    
    -- Create all markers
    for _, m in ipairs(markers_to_create) do
        reaper.SetEditCurPos(m.time, false, false)
        AddMarker(m.name)
    end
    
    -- Restore cursor to original position
    reaper.SetEditCurPos(cursor_pos, false, false)
    reaper.UpdateArrange()
end

-- Scan the EVENTS track MIDI for crowd state text events
-- Returns a table keyed by event name, e.g. { crowd_fists_on = 3, crowd_fists_off = 2 }
local function ScanCrowdEvents()
    local counts = {}
    local track_name = "EVENTS"
    local track = nil

    for i = 0, reaper.CountTracks(0) - 1 do
        local current_track = reaper.GetTrack(0, i)
        local _, name = reaper.GetTrackName(current_track)
        if name == track_name then
            track = current_track
            break
        end
    end

    if not track then 
        return counts 
    end

    -- Find the MIDI item
    local midi_item = nil
    for i = 0, reaper.CountTrackMediaItems(track) - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        local take = reaper.GetActiveTake(item)
        if take and reaper.TakeIsMIDI(take) then
            midi_item = item
            break
        end
    end

    if not midi_item then 
        return counts 
    end

    local take = reaper.GetActiveTake(midi_item)
    
    -- Sort MIDI to ensure all events are visible
    reaper.MIDI_Sort(take)

    -- Try getting the entire MIDI data as a string and searching for our events
    local _, midi_string = reaper.MIDI_GetAllEvts(take, "")
    
    -- Search for our crowd state text in the raw MIDI data
    for _, pair in ipairs(CROWD_PAIRS) do
        local on_pattern = "%[" .. pair.on .. "%]"
        local off_pattern = "%[" .. pair.off .. "%]"
        
        -- Count occurrences
        local on_count = 0
        for match in midi_string:gmatch(on_pattern) do
            on_count = on_count + 1
        end
        
        local off_count = 0
        for match in midi_string:gmatch(off_pattern) do
            off_count = off_count + 1
        end
        
        if on_count > 0 then
            counts[pair.on] = on_count
        end
        if off_count > 0 then
            counts[pair.off] = off_count
        end
    end

    return counts
end

-- Determine button state for each pair based on event counts
-- Returns: "green", "orange", or nil (default)
local function GetPairButtonStates(counts, pair)
    local on_count  = counts[pair.on]  or 0
    local off_count = counts[pair.off] or 0

    if on_count == 0 and off_count == 0 then
        -- No events at all — both default
        return nil, nil
    elseif on_count == off_count then
        -- Properly paired — both green
        return "green", "green"
    elseif on_count > off_count then
        -- Unclosed _on — on is green, off is orange
        return "green", "orange"
    else
        -- Orphan _off — off is green, on is orange
        return "orange", "green"
    end
end

-- Colors
local COLOR_GREEN  = 0x00CC00FF
local COLOR_ORANGE = 0xFF8C00FF
local COLOR_BADGE  = 0xFF3333FF  -- red badge background
local COLOR_BADGE_TEXT = 0xFFFFFFFF

-- Draw a crowd state button with color state and a badge counter in the top-right corner
local function CrowdStateButton(label, id, count, state)
    local width, height = 143, 30

    -- Push button color based on state
    local color_pushed = false
    if state == "green" then
        ImGui.PushStyleColor(ctx, ImGui.Col_Button, COLOR_GREEN)
        ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0x000000FF)
        color_pushed = true
    elseif state == "orange" then
        ImGui.PushStyleColor(ctx, ImGui.Col_Button, COLOR_ORANGE)
        ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0x000000FF)
        color_pushed = true
    end

    -- Record cursor position before drawing the button (for badge overlay)
    local btn_x, btn_y = ImGui.GetCursorPos(ctx)

    local clicked = ImGui.Button(ctx, label .. id, width, height)

    -- Pop colors
    if color_pushed then
        ImGui.PopStyleColor(ctx)  -- text
        ImGui.PopStyleColor(ctx)  -- button
    end

    -- Draw badge if count > 0
    if count and count > 0 then
        local badge_text = tostring(count)
        local badge_w, badge_h = ImGui.CalcTextSize(ctx, badge_text)
        local padding = 4
        badge_w = badge_w + padding * 2
        badge_h = badge_h + padding * 2

        -- Position badge in top-right corner of the button
        local badge_x = btn_x + width - badge_w - 2
        local badge_y = btn_y - 2

        -- Draw badge background (filled rect)
        local draw = ImGui.GetWindowDrawList(ctx)
        local wx, wy = ImGui.GetWindowPos(ctx)
        ImGui.DrawList_AddRectFilled(draw,
            wx + badge_x, wy + badge_y,
            wx + badge_x + badge_w, wy + badge_y + badge_h,
            COLOR_BADGE, 8)

        -- Draw badge text centered in the badge rect
        ImGui.DrawList_AddText(draw,
            wx + badge_x + padding,
            wy + badge_y + padding,
            COLOR_BADGE_TEXT, badge_text)
    end

    return clicked
end

-- Reposition Window if it goes offscreen in virtual machine after sleep
-- reaper.ImGui_SetNextWindowPos(ctx, 100, 100, reaper.ImGui_Cond_Always())

-- Main GUI loop
local practice_filter = ""  -- Search filter text
local filtered_indices = {} -- Indices of filtered practice sections
local selected_practice = -1 -- Currently selected item (-1 = none)

local function loop()
    ImGui.SetNextWindowSize(ctx, 1220, 875, ImGui.Cond_FirstUseEver)
    local visible, open = ImGui.Begin(ctx, 'EVENTS Tools', true)
    if visible then

        -- Scan MIDI track each frame for crowd state tracking
        local crowd_counts = ScanCrowdEvents()
        local crowd_states = {}
        for _, pair in ipairs(CROWD_PAIRS) do
            local on_state, off_state = GetPairButtonStates(crowd_counts, pair)
            crowd_states[pair.on]  = { state = on_state,  count = crowd_counts[pair.on]  or 0 }
            crowd_states[pair.off] = { state = off_state, count = crowd_counts[pair.off] or 0 }
        end

        ImGui.SeparatorText(ctx, 'Common Practice Section Markers')
	
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

       		 	-- Spacer
	     		ImGui.SameLine(ctx)

-- Practice Section Dropdown

        -- Update filtered list based on search
        if practice_filter == "" then
            -- No filter - show all dropdown items
            filtered_indices = {}
            for i = 1, #PRACTICE_SECTIONS_DISPLAY do
                filtered_indices[i] = i
            end
        else
            -- Filter based on search text (case-insensitive)
            filtered_indices = {}
            local filter_lower = practice_filter:lower()
            for i = 1, #PRACTICE_SECTIONS_DISPLAY_NAMES do
                if PRACTICE_SECTIONS_DISPLAY_NAMES[i]:lower():find(filter_lower, 1, true) then
                    table.insert(filtered_indices, i)
                end
            end
        end

        -- Search input box (30px tall with placeholder)
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 4, 9)
        ImGui.SetNextItemWidth(ctx, 295)
        local changed, new_filter = ImGui.InputTextWithHint(ctx, '##prc_search', 'Search', practice_filter, ImGui.InputTextFlags_AutoSelectAll)
        ImGui.PopStyleVar(ctx)
        if changed then
            practice_filter = new_filter
            selected_practice = -1
        end

        -- Create invisible spacer row to match outro button pattern
        -- This ensures dropdown aligns with search box above
        -- First set: matches "Outro Chorus" main button + 4 sub-buttons
        ImGui.Dummy(ctx, 143, 0)  -- Main button width
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 30, 0)   -- Sub-button width
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 30, 0)
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 30, 0)
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 30, 0)
        ImGui.SameLine(ctx)
        
        -- Second set: matches "Outro" main button + 4 sub-buttons
        ImGui.Dummy(ctx, 143, 0)  -- Main button width
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 30, 0)   -- Sub-button width
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 30, 0)
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 30, 0)
        ImGui.SameLine(ctx)
        ImGui.Dummy(ctx, 30, 0)
        ImGui.SameLine(ctx)
        
        -- Combo box with filtered results (30px tall) - now aligned
        ImGui.PushStyleVar(ctx, ImGui.StyleVar_FramePadding, 4, 9)
        ImGui.SetNextItemWidth(ctx, 295)
        local preview = selected_practice >= 0 and PRACTICE_SECTIONS_DISPLAY_NAMES[selected_practice] or "Select Practice Section..."
        
        if ImGui.BeginCombo(ctx, '##prc_combo', preview, ImGui.ComboFlags_HeightLarge) then
            ImGui.PopStyleVar(ctx)
            -- Show filtered items
            for _, idx in ipairs(filtered_indices) do
                local is_selected = (selected_practice == idx)
                if ImGui.Selectable(ctx, PRACTICE_SECTIONS_DISPLAY_NAMES[idx], is_selected) then
                    selected_practice = idx
                    -- Auto-create marker when selected (use marker name, not display name)
                    AddMarker(PRACTICE_SECTIONS_DISPLAY[idx])
                end
                if is_selected then
                    ImGui.SetItemDefaultFocus(ctx)
                end
            end
            ImGui.EndCombo(ctx)
        else
            ImGui.PopStyleVar(ctx)
        end

-- Copy/Paste Practice Section Markers

        ImGui.SeparatorText(ctx, 'Copy / Paste Practice Section Markers in Timeline Selection')

        -- Copy Markers button
        if ImGui.Button(ctx, 'Copy Markers', 143, 30) then
            CopyMarkers()
        end

        ImGui.SameLine(ctx)

        -- Paste Markers button
        if ImGui.Button(ctx, 'Paste Markers', 143, 30) then
            PasteMarkers()
        end

        -- Display copied markers info
        ImGui.TextWrapped(ctx, clipboard_display)

-- Marker tools section

        ImGui.SeparatorText(ctx, 'EVENTS Track Tools')

        -- Button for "Markers to Sections"
        if ImGui.Button(ctx, 'Copy Markers to EVENTS Track', 294, 30) then
            MarkersToSections(IsValidPracticeSection)
        end

		-- Music events section
        ImGui.Text(ctx, 'Music Events')

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
        ImGui.Text(ctx, 'Crowd Clap')

        if ImGui.Button(ctx, 'Add Crowd Clap', 143, 30) then
            CrowdClap()
        end

		ImGui.SameLine(ctx)

		if ImGui.Button(ctx, 'Add Crowd NoClap', 143, 30) then
            CrowdNoClap()
        end

		-- Crowd clap section
        ImGui.Text(ctx, 'Crowd intensity')

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

        ImGui.Text(ctx, 'Undocumented Crowd States')

        if CrowdStateButton('Crowd Fists On', '##cfo', crowd_states["crowd_fists_on"].count, crowd_states["crowd_fists_on"].state) then
            CrowdFistsOn()
        end

		ImGui.SameLine(ctx)

        if CrowdStateButton('Crowd Fists Off', '##cfoff', crowd_states["crowd_fists_off"].count, crowd_states["crowd_fists_off"].state) then
            CrowdFistsOff()
        end

		ImGui.SameLine(ctx)

        if CrowdStateButton('Crowd Horns On', '##cho', crowd_states["crowd_horns_on"].count, crowd_states["crowd_horns_on"].state) then
            CrowdHornsOn()
        end

		ImGui.SameLine(ctx)

        if CrowdStateButton('Crowd Horns Off', '##choff', crowd_states["crowd_horns_off"].count, crowd_states["crowd_horns_off"].state) then
            CrowdHornsOff()
        end

		ImGui.SameLine(ctx)

        if CrowdStateButton('Crowd Lighters On', '##clo', crowd_states["crowd_lighters_on"].count, crowd_states["crowd_lighters_on"].state) then
            CrowdLightersOn()
        end

		ImGui.SameLine(ctx)

        if CrowdStateButton('Crowd Lighters Off', '##cloff', crowd_states["crowd_lighters_off"].count, crowd_states["crowd_lighters_off"].state) then
            CrowdLightersOff()
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