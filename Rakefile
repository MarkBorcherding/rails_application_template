task :clean do
  system 'rm -rf ./example'
end

task test: :clean do
  system 'rails new example --template default.rb --skip-bundle --skip-spring'
end
