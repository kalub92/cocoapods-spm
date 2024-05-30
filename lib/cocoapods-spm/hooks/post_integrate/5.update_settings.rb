require "cocoapods-spm/hooks/base"
require "cocoapods-spm/macro/metadata"

module Pod
  module SPM
    class Hook
      class UpdateSettings < Hook
        def run
          update_macro_plugin_flags
          update_modulemap_flags
          update_swift_include_paths
          update_linker_flags
        end

        private

        def macro_plugin_flag_by_config
          path_prefix = "${PODS_ROOT}/../#{spm_config.macro_prebuilt_root_dir}"
          @macro_plugin_flag_by_config ||= begin
            hash = user_build_configurations.keys.to_h do |config|
              flags = macro_pods.keys.map do |name|
                metadata = MacroMetadata.for_pod(name)
                impl_module_name = metadata.macro_impl_name
                plugin_executable_path =
                  "#{path_prefix}/#{name}/" \
                  "#{impl_module_name}-#{config.to_s.downcase}##{impl_module_name}"
                "-load-plugin-executable \"#{plugin_executable_path}\""
              end.join(" ")
              [config, flags]
            end
            user_build_configurations.each { |config, symbol| hash[symbol] = hash[config] }
            hash
          end
        end

        def update_macro_plugin_flags
          return if spm_config.all_macros.empty?

          perform_settings_update(
            update_targets: lambda do |_, _, config|
              { "OTHER_SWIFT_FLAGS" => macro_plugin_flag_by_config[config] }
            end
          )
        end

        def update_modulemap_flags
          perform_settings_update(
            update_targets: lambda do |target, _, _|
              {
                "OTHER_SWIFT_FLAGS" => modulemap_args_for_target(target, prefix: "-Xcc"),
                "OTHER_CFLAGS" => modulemap_args_for_target(target),
              }
            end
          )
        end

        def update_linker_flags
          return if @spm_resolver.result.spm_pkgs.empty?

          # For packages to work in the main target
          perform_settings_update(
            update_targets: lambda do |target, _, _|
              {
                "OTHER_LDFLAGS" => linker_flags_for(target),
                "FRAMEWORK_SEARCH_PATHS" => "\"${PODS_CONFIGURATION_BUILD_DIR}/PackageFrameworks\"",
                "LIBRARY_SEARCH_PATHS" => "\"${PODS_CONFIGURATION_BUILD_DIR}\"",
              }
            end
          )
        end

        def linker_flags_for(target)
          return [] if !target.is_a?(Pod::AggregateTarget) && target.build_as_static?

          @spm_resolver.result.linker_flags_for(target)
        end

        def update_swift_include_paths
          return if @spm_resolver.result.spm_pkgs.empty? && spm_config.all_macros.empty?

          perform_settings_update(
            update_targets: lambda do |_, _, _|
              { "SWIFT_INCLUDE_PATHS" => "$(PODS_CONFIGURATION_BUILD_DIR)" }
            end
          )
        end

        def modulemap_args_for_target(target, prefix: nil)
          @spm_resolver
            .result
            .spm_targets_for(target)
            .filter_map(&:clang_modulemap_arg)
            .map { |v| prefix.nil? ? v : "#{prefix} #{v}" }
            .join(" ")
        end
      end
    end
  end
end
