# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'simple-app' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static

  # Pods for simple-app
  pod 'CocoaAsyncSocket'

end

$static_frameworks = ['CocoaAsyncSocket']

pre_install do |installer|
  installer.pod_targets.each do |pod|
    if $static_frameworks.include?(pod.name)
      def pod.build_type;
        Pod::BuildType.static_framework
      end
    end
  end
end
