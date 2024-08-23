task :switch do
  sh "darwin-rebuild switch --flake '.#fusillade'"
end

task :build do
  sh "darwin-rebuild build --flake '.#fusillade'"
end

task :search do 
  sh "nix-search #{$ARGV}"
end

task :default => :build
task :install => :switch
task :s => :switch
task :i => :switch
