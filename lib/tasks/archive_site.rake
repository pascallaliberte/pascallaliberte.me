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
      page.viewport = Puppeteer::Viewport.new(width: 1280, height: 800)
      page.goto(url, wait_until: 'networkidle0')
      
      # Get full page height
      full_height = page.evaluate('() => {
        return Math.max(
          document.body.scrollHeight,
          document.documentElement.scrollHeight,
          document.body.offsetHeight,
          document.documentElement.offsetHeight,
          document.body.clientHeight,
          document.documentElement.clientHeight
        );
      }')
      
      # Set viewport to full height
      page.viewport = Puppeteer::Viewport.new(width: 1280, height: full_height)
      page.screenshot(path: desktop_path, full_page: true)

      # Mobile screenshot
      page = browser.new_page
      page.viewport = Puppeteer::Viewport.new(width: 375, height: 667)
      page.goto(url, wait_until: 'networkidle0')
      
      # Get full page height for mobile
      full_height = page.evaluate('() => {
        return Math.max(
          document.body.scrollHeight,
          document.documentElement.scrollHeight,
          document.body.offsetHeight,
          document.documentElement.offsetHeight,
          document.body.clientHeight,
          document.documentElement.clientHeight
        );
      }')
      
      # Set viewport to full height
      page.viewport = Puppeteer::Viewport.new(width: 375, height: full_height)
      page.screenshot(path: mobile_path, full_page: true)
    end

    # Create the markdown file
    content = <<~MARKDOWN
---
layout: archived
title: "#{title}"
description: "#{description}"
original_url: "#{url}"
desktop_screenshot: "/images/archived-sites/#{desktop_filename}"
mobile_screenshot: "/images/archived-sites/#{mobile_filename}"
---

#{description}
MARKDOWN

    # Generate filename for the markdown file
    markdown_filename = "#{domain}-#{timestamp}.md"
    markdown_path = File.join(Dir.pwd, '_archived-sites', markdown_filename)

    # Create _archived-sites directory if it doesn't exist
    FileUtils.mkdir_p(File.join(Dir.pwd, '_archived-sites'))

    # Write the markdown file
    File.write(markdown_path, content)

    puts "Archived site created at #{markdown_path}"
    puts "Screenshots saved in #{screenshots_dir}"
  end
end 