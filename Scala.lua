require "StringUtils"

--------------------------------------------------------------------------------
-- Function to extract a value from a string based on the given pattern.
local function get_value(str, pattern)
  local first, last, value = string.find(str, pattern)
  return value
end

--------------------------------------------------------------------------------
-- return true if this line is not a scala commented line, otherwise this function return false.
local function is_not_commented_line(line)
  return (string.sub(line, 1, 1) ~= '!') and (string.len(string.gsub(line, ' ', '')) > 0)
end

--------------------------------------------------------------------------------
-- Extract tuning value from cent (e.g 123.456)
local function extract_tuning_from_cent(line, tunings)
  local cents = tonumber(get_value(line, '(\-*%d+\.%d*)'))
          
  return math.pow(2, cents / 1200)  
end

--------------------------------------------------------------------------------
-- Extract tuning value from a ratio (e.g 123/456)
local function extract_tuning_from_ratio(line)
  local ratio_parts = string.split(line, '/')
            
  return tonumber(ratio_parts[1]) / tonumber(ratio_parts[2])
end

--------------------------------------------------------------------------------
-- Extract tuning value from an integer (e.g 123456)
local function extract_tuning_from_whole_integer(line)
  return tonumber(get_value(line, '(\-*%d+)'))
end

--------------------------------------------------------------------------------
-- Function to load a Scala .scl file and generate a table of note frequencies.
-- Based on the snippet from  Kieran Foster (aka dblue). January 26th, 2011.
-- Scala .scl file format: http://www.huygens-fokker.org/scala/scl_format.html
function load_scala_file(filepath)
  local tunings = {}
  local description = ""
  local note_per_octave = 0
  local error = false
 
  -- Line counter for error reporting
  local line_counter = 0
  local uncommented_line_counter = 0
  local file = io.open(filepath, 'r')
  
  -- If we managed to open the file.
  if file then
    -- Iterate through each line.
    for line in file:lines() do
      line_counter = line_counter + 1
      line = line:trim()
      -- If the current line is *not* a comment and is not a blank line...
      if is_not_commented_line(line) then    
        uncommented_line_counter = uncommented_line_counter + 1  
        -- According to the .scl file format, the first uncommented line we 
        -- encounter should be the description.
        if uncommented_line_counter == 1 then
          description = line
        -- The second uncommented line we encounter should be the note count.
        elseif uncommented_line_counter == 2 then
          note_per_octave = tonumber(line)
          if note_per_octave ~= nil then
            error = "Could not parse scala file '" .. filepath .. "' at line " .. tostring(line_counter) .. ": invalid note count: " .. line
            break
          end
        else
          local tuning = nil
           
          if string.find(line, '.', 1, true) then
            tuning = extract_tuning_from_cent(line) 
          elseif string.find(line, '/', 1, true) then
            tuning = extract_tuning_from_ratio(line)          
          else
            tuning = extract_tuning_from_whole_integer(line)
          end
          if tuning ~= nil then
            table.insert(tunings, tuning)
          else
            error = "Could not parse scala file '" .. filepath .. "' at line " .. tostring(line_counter)
            break
          end
        end
      end
    end
    -- Close the .scl file when we're finished with it.
    file:close()
  else
    -- If the file can't be opened, we notify the error
    error = "Could not open scala file '" .. filepath .. "'"
  end
  local results = {}
  
  results["tunings"] = tunings
  results["filepath"] = filepath
  results["filename"] = filepath:match("([^/]+)$")
  results["notes_per_octave"] = note_per_octave
  results["description"] = description
  results["error"] = error
  return results
end

function generate_frequency_table(base_note, base_frequency, octave_offset, scale_infos)
  if scale_infos.error == false then
    assert( scale_infos.notes_per_octave ~= nil and scale_infos.notes_per_octave ~= 0, "invalid scale_infos.notes_per_octave" )
    assert( scale_infos.tunings ~= nil and #scale_infos.tunings ~= scale_infos.notes_per_octave, "invalid scale_infos.tunings" )
     
    local notes_per_octave = scale_infos.notes_per_octave
    local tunings = scale_infos.tunings
    local note = 0
    local octave = 0
    local degree = 0
    local frequency = 0
    local frequencies = {}
   
    for midi_note = 0, 127, 1 do
      -- Calculate the shifted note index.
      note = midi_note - base_note + (octave_offset * notes_per_octave)
      -- Calculate the current degree.
      degree = note % notes_per_octave
      -- Calculate the current octave.
      octave = math.floor(note / notes_per_octave)
      -- Calculate the current octave's base frequency.
      frequency = base_frequency * math.pow(tunings[notes_per_octave], (octave * notes_per_octave) / notes_per_octave)
      -- Factor in the degree multiplier if necessary.
      if degree > 0 then
        frequency = frequency * tunings[degree]
      end
      
      -- Restrict frequency to some sensible limits.
      -- frequency = math.max(0.0, math.min(22050.0, frequency))  
      
      -- MIDI notes range from 0 to 127, so I prefer to index them in the same way. 
      -- If you prefer to index things LUA style, ie. from 1 to 128, then use:
      -- frequencies[midi_note + 1] = frequency
      frequencies[midi_note] = frequency
    end
    scale_infos["frequencies"] = frequencies
  end
  return scale_infos
end
--------------------------------------------------------------------------------
