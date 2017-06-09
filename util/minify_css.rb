#!/usr/bin/env ruby

root_path = File.expand_path('..', File.dirname(__FILE__))
Dir.chdir(root_path)

Dir.glob('src/*.css').select { |fname| fname !~ /\.min\./ }.each do |fname|
  basename = File.basename(fname, '.css')
  system("wget --post-data=\"input=$(cat #{fname})\" --output-document=src/#{basename}.min.css https://cssminifier.com/raw")
end