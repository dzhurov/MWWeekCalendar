Pod::Spec.new do |s|
  s.name     = 'WeeklyCalendar'
  s.version  = '0.0.2'
  s.license  = 'MIT'
  s.summary  = 'WeeklyCalendar for iOS'
  s.description = <<-DESC
  					WeeklyCalendar, calendar control
  					DESC
  s.homepage = 'https://github.com/dzhurov/MWWeekCalendar'
  s.authors  =  {'Dmitry Zhurov' => 'zim01001@gmail.com',
                 'Sergiy Konovorotskiy' => 'skonovorotskiy@gmail.com',
                 'Andrey Durbalo' => 'andrey.durbalo@gmail.com' }
  s.source   = { :git => 'https://github.com/dzhurov/MWWeekCalendar.git', :tag => s.version, :submodules => true }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'  
  s.source_files = "WeeklyCalendar/WeeklyCalendarSource/**/*.{h,m}"
  s.resource = "WeeklyCalendar/WeeklyCalendarSource/**/*.{xib}"
  s.dependency 'PureLayout'
end