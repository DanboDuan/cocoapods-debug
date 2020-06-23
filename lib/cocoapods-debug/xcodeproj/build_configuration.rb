require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      # Encapsulates the information a specific build configuration referenced
      # by a {XCConfigurationList} which in turn might be referenced by a
      # {PBXProject} or a {PBXNativeTarget}.
      #
      class XCBuildConfiguration
        def debug_exclude_source_files=(value)
          # build_settings['EXCLUDED_SOURCE_FILE_NAMES[config=Release][sdk=*][arch=*]'] = value
          build_settings['EXCLUDED_SOURCE_FILE_NAMES'] = value
        end

      end
    end
  end
end

