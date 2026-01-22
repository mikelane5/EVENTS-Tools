-- MarkerUtils.lua: Shared marker creation with color coding
local COLORS = {
        intro = reaper.ColorToNative(0, 255, 0) | 0x1000000,   -- Green
	preverse = reaper.ColorToNative(255, 140, 0) | 0x1000000,  -- Orange
	verse = reaper.ColorToNative(255, 0, 0) | 0x1000000,      -- Red
	postverse = reaper.ColorToNative(139, 0, 50) | 0x1000000,    -- Dark Red
	prechorus = reaper.ColorToNative(0, 191, 255) | 0x1000000,  -- Light Blue/Cyan
	chorus = reaper.ColorToNative(0, 0, 255) | 0x1000000,       -- Blue
	postchorus = reaper.ColorToNative(0, 0, 139) | 0x1000000,   -- Navy/Dark Blue
	main = reaper.ColorToNative(255, 255, 0) | 0x1000000,     -- Yellow
	bridge = reaper.ColorToNative(183, 0, 174) | 0x1000000,    -- Purple
	gtr = reaper.ColorToNative(255, 165, 0) | 0x1000000,    -- Orange
	bass = reaper.ColorToNative(255, 165, 0) | 0x1000000,     -- Orange
	drum = reaper.ColorToNative(255, 165, 0) | 0x1000000,     -- Orange
	keyboard = reaper.ColorToNative(255, 165, 0) | 0x1000000, -- Orange
	outro = reaper.ColorToNative(255, 255, 255) | 0x1000000, -- White

}

local function AddMarker(name)
    local markerType = name:match("^([^_]+)")
    local color = COLORS[markerType] or COLORS.verse
    
    reaper.AddProjectMarker2(0, false, reaper.GetCursorPosition(), 0, name, -1, color)
end

return AddMarker