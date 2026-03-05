# Extensions to BTAPMeasureHelper for NRC measures. Essentially inherits all methods and
# only adds functionality where required.

require_relative 'BTAPMeasureHelper'
require 'etc'

module NRCMeasureHelper
  include BTAPMeasureHelper

  # Find the version of NECB used to define the model. Default to 2017.
  def find_standard(model)
    if model.getBuilding.standardsTemplate.is_initialized
      standardsTemplate = (model.getBuilding.standardsTemplate).to_s
      standard = Standard.build(standardsTemplate)
    else
      puts "The measure wasn't able to determine the standards template from the model, a default value of 'NECB2017' will be used.".red
      standard = Standard.build('NECB2017')
    end
    return standard
  end
end

module NRCMeasureTestHelper
  include BTAPMeasureTestHelper

  # Save the paths that we're using at the module level. Required for running tests in parallel.
  @@method_testing_paths = {}

  # Method to recover existing path being used by a method (or create one if it has not been instantiated).
  def self.get_output_path(path)
    path = nil
    if @@method_testing_paths.any? {|std| std.template == template}
      standard = @@method_testing_paths.select{|std| std.template == template}.first
      puts standard.class
    else
      standard = Standard.build(template)
      puts standard.class
      @@method_testing_paths << standard
    end
    return standard
  end

  # Define the output path. Set defaults and remove any existing outputs.
  # If the output root has been defined in the env variable then use that otherwise default to the
  # measures test folder.
  def self.setOutputFolder(measure_test_name)
    output_folder = ENV['OS_MEASURES_TEST_DIR']
    puts "Output folder: #{output_folder}".pink
    puts "Measure test name: #{measure_test_name}".pink
    operating_sys = Etc.uname[:sysname]
    puts "Operating system:".green + " #{operating_sys}".light_blue
    if operating_sys == "Windows_NT"
      output_folder = File.expand_path("#{File.expand_path(__dir__)}/../tests/output")
      FileUtils.mkdir_p output_folder unless Dir.exist?(output_folder)
      @output_root_path = output_folder
      puts "Output folder in Windows: ".green + " #{output_folder}".light_blue
      puts "@output_root_path: ".green + " #{@output_root_path}".light_blue
    else
      if Dir.exist?("/#{output_folder}")
        @output_root_path = File.expand_path("/#{output_folder}/output/#{measure_test_name}")
      end
    end

    # Make the folder. Try again if there is a failure (likely from an operating system collision).
    begin
      FileUtils.mkdir_p @output_root_path unless Dir.exist?(@output_root_path)
    rescue
      sleep(10)
      FileUtils.mkdir_p @output_root_path unless Dir.exist?(@output_root_path)
    ensure
      sleep(10)
      FileUtils.mkdir_p @output_root_path unless Dir.exist?(@output_root_path)
    end
    puts "Test output folder: #{@output_root_path}".green
  end

  # Remove the existing test results. Need to control when this is done as multiple test scripts could be
  #  accessing the same path.
  # Must call this in the test script.
  def self.removeOldOutputs(before: Time.now)
    existing_folders = Dir.entries(@output_root_path) - ['.', '..'] # Remove current folder above from list before deleting!
    existing_folders.each do |entry|
      folder_to_remove = File.expand_path("#{@output_root_path}/#{entry}")
      if (Dir.exist?(folder_to_remove)) # Double check it exists (incase another process has removed it as is the case with multiple test files).
        puts "Checking existing output folder: #{before}; #{File.mtime(folder_to_remove)}; #{folder_to_remove}".green
        if File.mtime(folder_to_remove) < before
          puts "Removing folder: #{folder_to_remove}".yellow
          FileUtils.rm_rf(folder_to_remove)
        else
          puts "Skipping existing output folder: #{folder_to_remove}".light_blue
        end
      end
    end
  end

  def self.appendOutputFolder(method_name, arguments)
    puts "Appending path to test output folder: #{method_name}".red

    local_args = arguments

    # No arguments in measure. Use calling method name.
    if local_args == nil
      local_args = caller_locations(1, 2)[1].label.split.last
      puts "Created dummy argument: #{local_args}".yellow
    end

    # Append name and validate if specified by the user.
    path = @output_root_path + "/" + method_name
    path = validateOutputFolder(path)
    @@method_testing_paths[local_args] = path
    return path
  end

  def self.validateOutputFolder(path)
    puts "Validating path: #{path}".blue

    # Check if paths exists - if it does add a number and re-check.
    path = File.expand_path(path)
    if File.exist?(path)
      # Create a numbered subfolder. First check if there is a numbered folder.
      path = path.split(/--/).first
      count = Dir.glob("#{path}*").count
      path = path + "--#{count}"
      sleep(10)
      validateOutputFolder(path)
    end
    path.to_s
  end

  def self.outputFolder(arguments)
    local_args = arguments

    # No arguments in measure. Use calling method name.
    if local_args == nil
      local_args = caller_locations(1, 2)[1].label.split.last
      puts "Using dummy argument: #{local_args}".yellow
    end

    #puts "Recovering outputFolder from: #{@@method_testing_paths}".pink
    #puts "  for: #{local_args}".blue
    folder = @@method_testing_paths[local_args]
    #puts "Recovering outputFolder: #{folder}".green

    # No folder found. Just set to Dir.pwd.
    if folder == nil
      folder = Dir.pwd
      puts "Missing outputFolder. Setting to: #{folder}".yellow
    end
    return folder
  end

  # Define the folder containing the test file for the test case summary output file.
  @measure_path = File.expand_path("#{File.expand_path(__dir__)}/../tests")
  @csv_path = @measure_path + "/" + "test_csv_file.csv"
  FileUtils.rm_rf(@csv_path)

  def self.create_csv_path
    @csv_path.to_s
  end  

  # Custom way to run a measure in the test. Overwrites run_measure definition in BTAPMeasureHelper.
  def run_measure(input_arguments, model)

    # Provide feedback as to what is being done to the terminal.
    puts "Running measure".green
    puts "  with input arguments".green + " #{input_arguments}".light_blue
    puts "     argument class".green + " #{input_arguments.class}".light_blue
    puts "  on model with".green + " #{model.modelObjects.count}".light_blue + " objects".green
    puts "  from method".green + " #{caller_locations(1, 1)[0].label.split.last}".light_blue

    # Set the output folder. Create if does not exist.
    output_folder = NRCMeasureTestHelper.outputFolder(input_arguments)
    FileUtils.mkdir_p(output_folder) unless Dir.exist?(output_folder)

    # This will create a instance of the measure you wish to test. It does this based on the test class name.
    measure = get_measure_object()
    measure.use_json_package = @use_json_package
    measure.use_string_double = @use_string_double

    # Return false if can't.
    return false if false == measure

    # Now get the arguments and create a runner.
    arguments = measure.arguments()
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)
    runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    # Set the arguements in the argument map use json or real arguments.
    if @use_json_package
      argument = arguments[0].clone
      assert(argument.setValue(input_arguments['json_input']), "Could not set value for 'json_input' to #{input_arguments['json_input']}")
      argument_map['json_input'] = argument
    else
      input_arguments.each_with_index do |(key, value), index|
        argument = arguments[index].clone
        if argument_type(argument) == "Double"
          # Forces it to a double if it is a double.
          assert(argument.setValue(value.to_f), "Could not set value for #{key} to #{value}")
        else
          assert(argument.setValue(value.to_s), "Could not set value for #{key} to #{value}")
        end
        argument_map[key] = argument
      end
    end

    # Run the measure.
    measure.run(model, runner, argument_map)

    # Save the model to test output directory. Do this now before asserts (so we have this in case of errors).
    output_path = "#{output_folder}/test_output.osm"
    model.save(output_path, true)

    # Get the result of the measure. Cannot check for success here as some tests designed to fail!
    resultValue = runner.result.value.valueName
    #puts "resultValue : #{resultValue} for #{output_folder}".pink

    # Add summary of test to README file.
    measure_name = measure.name.gsub("_", " ").upcase
    write_csv(measure_name, output_folder.split('/').last, input_arguments, resultValue)
    return runner
  end

  # write_csv(same input arguments as reportCase, the former method for the readme)
  # This method is meant to parse through the input arguments and add all the test 
  # results to a csv file, because data_point_id, expected_result and result are not
  # input_arguments, they need to be set seperately and added at the start of each line
  # in the csv file. This method was created to display the readme file in a sorted table
  # and for all measures but specifically for the parallel tests. See issue #64 for more 
  # information. Expected result variable needs to be changed, see note below.
  def write_csv(measure_name, test_name, input_arguments, result)
    out_file = File.new("#{NRCMeasureTestHelper.create_csv_path}", "a")

    test_parameter = false
    
    test_name = test_name.gsub("_", " ")
    test_name = test_name.gsub("-", " ")
    test_name = test_name.gsub("oscli", "Test Parameter")
    
    if (test_name == "Test Parameter")
      test_parameter = true
    end

    # Expected result should not be here, BTAP test parameters should have expected result to fail where all 
    # other tests are meant to pass, eventually change to have variable as a measure argument.
    if (result == 'Success')
      expected_result = "Pass"
      pass_fail = "Pass"
    else
      expected_result = "Fail"
      pass_fail = "Fail"
    end
    
    data_keys = []
    data_vals = []

    max_val = 0
    min_val = 0

    # max_param is a bool variable that represents whether the upper limit is being tested.
    # min_param is a bool variable that represents whether the lower limit is being tested.
    # test_val is a bool variable that is checking to see whether the key in @measure_interface_
    # detailed, match the key that is currently being evaluated.
    # Max and min need variables because the name needs to be adjusted if its a test parameter
    # but the name isn't adjusted for the tests that are expected to pass.
    max_param = false
    min_param = false
    test_val = false

    dp_name_string = ""

    input_arguments.each do |key, value|
      if key.include? "json_input" 
        # Value is a string, has to be parsed and converted into hash.
        value1 = JSON.parse(value)
        value1.each do |key, value|
          data_keys << "#{key},#{value},"
          dp_name_string += "#{key}: #{value} "
          
          #puts "key:#{key}"
          if (test_parameter && key != "necb_template") # necb_template has numerical value that shoudn't be evaluated.
            holder = value.to_s
            #puts "test: #{holder.to_f}"
            if (holder =~ /\d/)
              @measure_interface_detailed.each do |arr|
                arr.each do |keys, vals|
                  if (vals == key)
                    test_val = true
                  end
                  if (keys == "max_double_value" && test_val)
                    max_val = vals
                  elsif (keys == "min_double_value" && test_val)
                    min_val = vals
                    test_val = false
                  end  
                end
              end
              int_holder = holder.to_f
              #puts "int holder: #{int_holder}"
              #puts "max_val: #{max_val}"
              #puts "min_val: #{min_val}"

              if (int_holder > max_val)
                max_param = true
                #puts "MAX"
              elsif (int_holder < min_val)
                min_param = true
                #puts "MIN"
              end
            end
          end
        end
      else
        data_keys << "#{key},#{value},"
        dp_name_string += "#{key}: #{value} "
    
        #puts "key:#{key}"
        if (test_parameter && key != "necb_template")
          holder = value.to_s
          #puts "test: #{holder.to_f}"
          if (holder =~ /\d/)
            @measure_interface_detailed.each do |arr|
              arr.each do |keys, vals|
                if (vals == key)
                  test_val = true
                end
                if (keys == "max_double_value" && test_val)
                  max_val = vals
                elsif (keys == "min_double_value" && test_val)
                  min_val = vals
                  test_val = false
                end
              end  
            end
            int_holder = holder.to_f
            #puts "int holder: #{int_holder}"
            #puts "max_val: #{max_val}"
            #puts "min_val: #{min_val}"
            if (int_holder > max_val)
              max_param = true
              #puts "MAX"
            elsif (int_holder < min_val)
              min_param = true
              #puts "MIN"
            end
          end
        end
      end 
    end  
 
    # Opening the file to write the variables that aren't input arguments first
    # then looping through the array of input arguments and adding them to the csv.
    File.open("#{NRCMeasureTestHelper.create_csv_path}", "a") do |csv|
      if (max_param == true)
        test_name = test_name.gsub("Test Parameter", "#{dp_name_string} upper range")
      elsif (min_param == true)
        test_name = test_name.gsub("Test Parameter", "#{dp_name_string} lower range")
      end
      csv << "data_point_id,#{test_name},expected_result,#{expected_result},result,#{pass_fail},"      
      data_keys.each do |arr|
        csv << arr
      end
      csv << "\n"
    end
  end

  # Fancy way of getting the measure object automatically. Added check for NRC in measure name.
  def get_measure_object()
    measure_class_name = self.class.name.to_s.match((/(NRC.*)(\_Test)/i) || ((/(BTAP.*)(\_Test)/i))).captures[0]
    btap_measure = nil
    nrc_measure = nil
    eval "btap_measure = #{measure_class_name}.new" if measure_class_name.to_s.include? "BTAP"
    eval "nrc_measure = #{measure_class_name}.new" if measure_class_name.to_s.include? "Nrc"
    if btap_measure.nil? and nrc_measure.nil?
      if btap_measure.nil?
        puts "Measure class #{measure_class_name} is invalid. Please ensure the test class name is of the form 'BTAPMeasureName_Test' (Note: BTAP is case sensitive.) ".red
      elsif nrc_measure.nil?
        puts "Measure class #{measure_class_name} is invalid. Please ensure the test class name is of the form 'NrcMeasureName_Test' (Note: Nrc is case sensitive.) ".red
      end
      return false
    end
    if btap_measure
      return btap_measure
    else
      return nrc_measure
    end
  end

  # Load a test model (code that is common in a lot of test scripts). Returns the model object.
  def load_test_osm(full_osm_model_path)

    # Load the supplied osm.
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = OpenStudio::Path.new(full_osm_model_path)
    model = translator.loadModel(path)
    assert((not model.empty?), "Reading model file: #{path}")
    model = model.get
  end
end

# Add significant digits capability to float and integer class.
class Float
  def signif(digits=3)
    return 0 if self.zero?
    return self if self < 0.0
    self.round(-(Math.log10(self).ceil - digits))
  end
end
class Integer
  def signif(digits=3)
    return 0 if self.zero?
    return self if self < 0
    self.round(-(Math.log10(self).ceil - digits)).to_i
  end
end
