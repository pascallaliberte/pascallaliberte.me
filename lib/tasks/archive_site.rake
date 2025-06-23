require 'puppeteer-ruby'
require 'fileutils'
require 'uri'

namespace :site do
  desc "Archive a website by taking screenshots and creating a markdown page"
  task :archive, [:url] do |t, args|
    url = args[:url]
    title = url
    description = "DESCRIPTION GOES HERE"

    unless url && title
      puts "Usage: rake site:archive[url]"
      exit
    end

    # Create screenshots directory if it doesn't exist
    screenshots_dir = File.join(Dir.pwd, 'images', 'archived-sites')
    FileUtils.mkdir_p(screenshots_dir)

    # Generate filenames based on the domain
    domain = URI.parse(url).host.gsub(/[^0-9A-Za-z]/, '-')
    timestamp = Time.now.strftime('%Y%m%d')
    desktop_filename = "#{domain}-desktop-#{timestamp}.png"
    mobile_filename = "#{domain}-mobile-#{timestamp}.png"
    
    desktop_path = File.join(screenshots_dir, desktop_filename)
    mobile_path = File.join(screenshots_dir, mobile_filename)

    # Take screenshots using Puppeteer
    Puppeteer.launch(headless: true) do |browser|
      # Desktop screenshot
      page = browser.new_page
      page.viewport = Puppeteer::Viewport.new(
        width: 1280,
        height: 800,
        device_scale_factor: 1
      )
      page.goto(url, wait_until: 'networkidle0')
      
      # Get actual content height
      content_height = page.evaluate('() => {
        return Math.max(
          document.documentElement.scrollHeight,
          document.body.scrollHeight
        );
      }')
      
      puts "Desktop content height: #{content_height}"
      
      # Set viewport to content height
      page.viewport = Puppeteer::Viewport.new(
        width: 1280,
        height: content_height,
        device_scale_factor: 1
      )
      
      # Take screenshot
      page.screenshot(
        path: desktop_path,
        full_page: false
      )

      # Mobile screenshot
      page = browser.new_page
      page.viewport = Puppeteer::Viewport.new(
        width: 375,
        height: 667,
        device_scale_factor: 1
      )
      page.goto(url, wait_until: 'networkidle0')
      
      # Get actual content height
      content_height = page.evaluate('() => {
        return Math.max(
          document.documentElement.scrollHeight,
          document.body.scrollHeight
        );
      }')
      
      puts "Mobile content height: #{content_height}"
      
      # Set viewport to content height
      page.viewport = Puppeteer::Viewport.new(
        width: 375,
        height: content_height,
        device_scale_factor: 1
      )
      
      # Take screenshot
      page.screenshot(
        path: mobile_path,
        full_page: false
      )
    end

    # Create the markdown file
    content = <<~MARKDOWN
---
layout: archived
title: "#{title}"
original_url: "#{url}"
desktop_screenshot: "/images/archived-sites/#{desktop_filename}"
mobile_screenshot: "/images/archived-sites/#{mobile_filename}"
---

#{description}
MARKDOWN

    # Generate filename for the markdown file
    markdown_filename = "#{domain}.md"
    markdown_path = File.join(Dir.pwd, '_archived', markdown_filename)

    # Create archived directory if it doesn't exist
    FileUtils.mkdir_p(File.join(Dir.pwd, '_archived'))

    # Write the markdown file
    File.write(markdown_path, content)

    puts "Archived site created at #{markdown_path}"
    puts "Screenshots saved in #{screenshots_dir}"
  end
end 