class 'Microtonal'
  function Microtonal:__init()
    self.view_builder = renoise.ViewBuilder()
    self.DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
    self.CONTENT_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING
    self.NOTE_NAMES = { 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B' }
    
    self.pitchToString = function(value)
      local noteName = tostring(self.NOTE_NAMES[math.floor(value % #self.NOTE_NAMES) + 1])
      local octave = math.floor(value / #self.NOTE_NAMES)
      
      return noteName .. "-" .. tostring(octave)
    end
    
    self.stringToPitch = function(value)
      local noteName, octave = str:split("-")
      local noteValue = 0
      
      for _,v in pairs(self.NOTE_NAMES) do
        if v == noteName then
          break
        end
        noteValue = noteValue + 1
      end
      return noteValue + octave * #self.NOTE_NAMES
    end
    
    self.param_base_note = 0
    self.param_base_frequency = 261.625565300598623000
    self.param_octave_offset = 0
    self.param_preserve_loop_point = false
    self.param_scala_filepath = ""
    
    self.base_note_box = self.view_builder:valuebox {
      width = 120,
      min = 0,
      max = 128,
      value = self.param_base_note,
      tostring = self.pitchToString,
      tonumber = self.stringToPitch,
      notifier = function(v) self.param_base_note = v end
    }
    
    self.base_frequency_box = self.view_builder:valuefield {
      width = 120,
      min = 0,
      max = 22000,
      value = self.param_base_frequency,
      tostring = tostring,
      tonumber = tonumber,
      notifier = function(v) self.param_base_frequency = v end
    }
    
    self.octave_offset_box = self.view_builder:valuebox {
      width = 120,
      min = -4,
      max = 4,
      value = self.param_octave_offset,
      notifier = function(v) self.param_octave_offset = v end
    }
    
    self.preserve_loop_point_box = self.view_builder:checkbox {
      notifier = function(v) self.param_preserve_loop_point = v end,
      value = self.param_preserve_loop_point
    }
    
    self.scala_filepath_display = self.view_builder:textfield
    {
      edit_mode = false,
      value = self.param_scala_filepath
    }
    
    self.scala_select_button = self.view_builder:button {
      text = "...",
      pressed = function ()
        local filepath = renoise.app():prompt_for_filename_to_read({"*.scl"}, "Select Scala File")
        
        self.param_scala_filepath = filepath
        self.scala_filepath_display.value = filepath
      end
    }
    
    self.main_layout = self.view_builder:column {
      margin = self.DIALOG_MARGIN,
      spacing = self.CONTENT_SPACING,
      self.view_builder:row{ self.view_builder:text { text = "Scala file:", width = 80 }, self.scala_filepath_display, self.scala_select_button },
      self.view_builder:row{ self.view_builder:text { text = "Base note:", width = 80 }, self.base_note_box },
      self.view_builder:row{ self.view_builder:text { text = "Base frequency:", width = 80 }, self.base_frequency_box },
      self.view_builder:row{ self.view_builder:text { text = "Octave offset:", width = 80 }, self.octave_offset_box },
      self.view_builder:row{ self.view_builder:text { text = "Preserve loop point:", width = 80 }, self.preserve_loop_point_box }
    }
  end
  
  function Microtonal:show_dialog() 
    local prompt = renoise.app():show_custom_prompt(
      "Microtonal",
      self.main_layout,
      { "Process", "Cancel" }
    )
    if prompt == "Process" then
      print(self.param_base_note)
      print(self.param_base_frequency)
      print(self.param_octave_offset)
      print(self.param_preserve_loop_point)
      print(self.param_scala_filepath)
    end
  end
