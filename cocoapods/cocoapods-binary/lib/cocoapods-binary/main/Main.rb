# encoding: UTF-8
require_relative '../tools/tools'


module Pod
    class Podfile
        module DSL

            # Enable prebuilding for all pods, it has a lower priority to other binary settings
            def all_binary!
                DSL.prebuild_all = true
            end

            # Enable bitcode for prebuilt frameworks
            def enable_bitcode_for_prebuilt_frameworks!
                DSL.bitcode_enabled = true
            end

            # Don't remove source code of prebuilt pods
            # It may speed up the pod install if git didn't include the 'Pods' folder
            def keep_source_code_for_prebuilt_frameworks!
                DSL.dont_remove_source_code = true
            end


            private
            class_attr_accessor :prebuild_all
            prebuild_all = false

            class_attr_accessor :bitcode_enabled
            bitcode_enabled = false

            class_attr_accessor :dont_remove_source_code
            dont_remove_source_code = false
        end
    end
end


Pod::HooksManager.register('cocoapods-binary', :pre_install) do |installer_context|

    require_relative '../helper/feature_switches'
    if Pod.is_prebuild_stage
        next
    end

    # [Check Environment] ==> check use_framework is on
    podfile = installer_context.podfile
    podfile.target_definition_list.each do |target_definition|
        next if target_definition.prebuild_framework_names.empty?
        if not target_definition.use_frameworks?
            STDERR.puts "[!] Cocoapods-binary requires `use_frameworks!`".red
            exit
        end
    end


    # ------------- Step 1: prebuild framework -------------
    # Execute a sperated pod install, to generate targets for building framework,
    # then compile them to framework files.
    require_relative '../helper/prebuild_sandbox'
end