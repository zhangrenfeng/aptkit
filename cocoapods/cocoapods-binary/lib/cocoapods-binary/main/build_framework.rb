require 'fourflusher'

CONFIGURATION = "Release"
PLATFORMS = { 'iphonesimulator' => 'iOS',
              'appletvsimulator' => 'tvOS',
              'watchsimulator' => 'watchOS' }


def build_for_ios_for_specific_platform(sandbox,
                                        build_dir,
                                        output_path,
                                        target,
                                        device,
                                        simulator,
                                        bitcode_enabled)

    deployment_target = target.platform.deployment_target.to_s

    target_label = target.label
    Pod::UI.puts "Prebuilding #{target_label}"

    other_options = []


end