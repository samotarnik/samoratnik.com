#!/usr/bin/env ruby

# 'stolen' from https://gist.github.com/garybernhardt/546022b191ed2b2636e020371b5918d6

require 'base64'
require 'nokogiri'
require 'uri'

class Inliner

  attr_reader :filename, :proj_root, :proj_src, :html, :output_file

  def initialize(input, output)
    raise "pass input and output files as arguments" if (input.nil? || output.nil?)
    @proj_root = File.expand_path('..', File.dirname(__FILE__))
    @proj_src = File.join(@proj_root, File.dirname(input))
    @filename = File.join(@proj_root, input)
    @output_file = File.join(@proj_root, output)
  end

  def process
    read_and_parse_input
    inline_favicon
    # inline_all_images(html)
    inline_all_css
    write_output
  end


  private

  def read_and_parse_input
    @html = Nokogiri::HTML(File.read(filename))
  end

  def inline_favicon
    html.css(%{head link[rel="icon"]}).each do |favicon|
      full_path = File.join(proj_src, favicon['href'])
      mime_type = {
        ".svg" => "image/svg+xml",
        ".jpg" => "image/jpeg",
        ".png" => "image/png"
      }.fetch(File.extname(full_path))
      base64ed_data = Base64.encode64(File.read(full_path))
      favicon['href'] = "data:#{mime_type};base64,#{base64ed_data}"
    end
  end


  def inline_all_images(html)
    html.css("img").each do |img|
      img['src'] = base64_image_src(img['src'])
    end
  end

  def inline_all_css
    html.css(%{link[rel="stylesheet"]}).each do |link|
      unless is_remote_path?(link['href'])
        inline_css_node(link)
      end
    end
  end

  def inline_css_node(link)
    style_node = Nokogiri::XML::Node.new('style', link.parent)
    full_path = File.join(proj_src, link['href'])
    style_node.content = File.read(full_path)
    link.add_next_sibling(style_node)
    link.remove
  end

  def base64_image_src(path)
    base64ed_data = Base64.encode64(File.read(path))
    "data:#{content_type};base64,#{base64ed_data}"
  end

  def is_remote_path?(path)
    uri = URI.parse(path)
    uri.scheme != nil || path.start_with?("//")
  end

  def path_to_local_path(path)
    # We treat the current working directory as the root of the "server", so any
    # absolute path in the markup becomes a path relative to the current
    # directory.
    path.sub(/^\//, "")
  end

  def write_output
    # puts output_file
    File.open(output_file, 'w') { |f| f.write html.to_s.gsub(/^\s*/, '').gsub(/>\n/, '>') }
  end

end

# ./inline.rb src/index.html build/index.html
input = ARGV.shift
output = ARGV.shift
Inliner.new(input, output).process