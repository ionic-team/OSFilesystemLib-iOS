Pod::Spec.new do |spec|
  spec.name                   = 'OSFilesystemLib'
  spec.version                = '0.0.1'

  spec.summary                = 'The `OSFilesystemLib` is a template library.'
  spec.description            = <<-DESC
  The `OSFilesystemLib` is a template library.
  
  The `OSFilesystemLib` structure provides the main feature of the Library:
  - ping: A simple echo function that returns the input string.
  DESC

  spec.homepage               = 'https://github.com/ionic-team/OSFilesystemLib-iOS'
  spec.license                = { :type => 'MIT', :file => 'LICENSE' }
  spec.author                 = { 'OutSystems Mobile Ecosystem' => 'rd.mobileecosystem.team@outsystems.com' }
  
  spec.source                 = { :http => "https://github.com/ionic-team/OSFilesystemLib-iOS/releases/download/#{spec.version}/OSFilesystemLib.zip", :type => "zip" }
  spec.vendored_frameworks    = "OSFilesystemLib.xcframework"

  spec.ios.deployment_target  = '14.0'
  spec.swift_versions         = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9']
end