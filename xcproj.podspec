Pod::Spec.new do |s|
  s.name             = "xcproj"
  s.version          = "0.2.0"
  s.summary          = "Read/Modify/Write your Xcode projects"
  s.homepage         = "https://github.com/swift-xcode/xcproj"
  s.license          = 'MIT'
  s.author           = "Pedro Pinñera", "Yonas Kolb"
  s.source           = { :git => "https://github.com/swift-xcode/xcproj.git", :tag => s.version.to_s }
  s.requires_arc = true

  s.platform = :osx
  s.osx.deployment_target = "10.10"

  s.source_files = "Sources/**/*.{swift}"

  s.dependency "PathKit", "~> 0.8"
  s.dependency "Unbox", "~> 2.5"
  s.dependency "AEXML", "~> 4.1"
end