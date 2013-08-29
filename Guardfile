spec_location = "spec/%s_spec"

guard 'jasmine-headless-webkit' do
  watch(%r{^lib/assets/javascripts/(.*)\.coffee$}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{^spec/(.*)_spec\..*}) { |m| newest_js_file(spec_location % m[1]) }
  watch(%r{spec/fixtures/.+$})
end
