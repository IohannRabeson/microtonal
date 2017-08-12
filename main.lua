require "Scala"
require "Microtonal"

function run_test()
  -- Set the base note to C-4
  local base_note = 0
  
  -- Set the base frequency to Middle C
  local base_frequency = 261.625565300598623000
  
  local octave_offset = 0
  
  -- Set the Scala .scl filename
  local scl_filepath = '/Users/iota/Downloads/scl 2/05-19.scl'
  
  local scale_infos = load_scala_file(scl_filepath)
  
  rprint(scale_infos)
  
  scale_infos = generate_frequency_table(base_note, base_frequency, octave_offset, scale_infos)
  
  rprint(scale_infos)
end

function run_test_gui()
  local gui = Microtonal()
  
  gui:show_dialog()
end

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Microtonal:Test",
  invoke = run_test  
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Microtonal:Test GUI...",
  invoke = run_test_gui  
}
