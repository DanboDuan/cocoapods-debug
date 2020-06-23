require 'cocoapods-debug/xcodeproj/build_configuration'
require 'cocoapods-debug/xcodeproj/project'

require 'cocoapods-core'
require 'xcodeproj'
require 'cocoapods'

module CocoapodsDebug

  class << self

    def convert_keys_to_string(value, recursive: true)
      return {} unless value.is_a?(Hash)
      result = {}
      value.each do |key, subvalue|
        subvalue = convert_keys_to_string(subvalue) if recursive && subvalue.is_a?(Hash)
        result[key.to_s] = subvalue
      end
      result
    end

    def lock_file_result
      path = 'Podfile.lock'
      return unless File.file?(path)
      lock_file = Pod::Lockfile.from_file(Pathname.new(path))
      source_manager = Pod::Source::Manager.new('~/.cocoapods/repos')

      lock_file.pod_names.map { |pod_name|
        pod_name.split("/")[0]
      }.uniq.reject { |pod_name|
        spec_repo = lock_file.spec_repo(pod_name)
        spec_repo.nil? || spec_repo.empty? || !spec_repo.include?("git")
      }.map { |pod_name|
        spec_repo = lock_file.spec_repo(pod_name)
        version = lock_file.version(pod_name)
        source = source_manager.source_with_name_or_url(spec_repo)
        {pod_name => source.specification(pod_name, version.to_s)}
      }.reduce({}) { |h, v|  h.merge v }
    end

    def modify_build_settings(target, subspecs = [], specification = nil)
      return if subspecs.nil? || subspecs.empty? || specification.nil?

      files = subspecs.map { |subspec|
        pod_name = "#{specification.name.to_s}/#{subspec}"
        spec = specification.subspec_by_name(pod_name)
        source_files = Pod::Specification::Consumer.new(spec, :ios).source_files
        source_files
      }.flatten.uniq

      target.build_configurations.each { |config|
        next if config.type == :debug
        config.debug_exclude_source_files = files
      }
    end

    def vendored_libraries(user_options, specs)
      user_options.map { |pod_name, subspecs|
        libraries = subspecs.map { |subspec|
          specification = specs.fetch(pod_name)
          name = "#{specification.name.to_s}/#{subspec}"
          spec = specification.subspec_by_name(name)
          libraries = Pod::Specification::Consumer.new(spec, :ios).vendored_libraries
          libraries
        }.flatten.uniq

        libraries.map { |library|
          glob = File.join('Pods', pod_name, library)
          Pathname.glob(glob).reduce([]) do |libs, entry|
            next unless entry.file?
            lib = File.basename(entry, '.a')
            libs << lib.reverse.chomp("bil").reverse
            libs
          end
        }
      }.flatten.uniq
    end

    def modify_xconfig(target, libraries)
      target.build_configurations.each { |config|
        next if config.type == :debug
        real_path = config.base_configuration_reference.real_path
        next unless real_path.exist?

        xconfig = Xcodeproj::Config.new(real_path)
        xconfig.libraries.reject! { |e|  libraries.include?(e)}
        xconfig.save_as(real_path)
      }
    end

    def install!(user_options)
      user_options = convert_keys_to_string(user_options)
      specs = lock_file_result.select { |pod_name, specification|
        user_options.key?(pod_name)
      }
      libraries = vendored_libraries(user_options, specs)
      Dir["Pods/*.xcodeproj"].each do |path|
        xcproj = Xcodeproj::Project.open(path)
        xcproj.targets.each do |target|
          next if target.platform_name != :ios
          pod_name = target.name.to_s
          CocoapodsDebug.modify_build_settings(target, user_options.fetch(pod_name, nil), specs.fetch(pod_name, nil))
          CocoapodsDebug.modify_xconfig(target, libraries)
        end
        xcproj.save
      end
    end
  end

  Pod::HooksManager.register('cocoapods-debug', :post_install) do |context, user_options|
    # p context
    CocoapodsDebug.install!(user_options)
  end

end



