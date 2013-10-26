require 'factory_girl'

factories_dir = File.join(File.dirname(__FILE__), 'factories')
FactoryGirl.definition_file_paths = [factories_dir]
FactoryGirl.find_definitions

MLS_GEM_CACHE={}
