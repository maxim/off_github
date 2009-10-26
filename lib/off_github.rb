#!/usr/bin/env ruby

require 'rubygems'
require 'hirb'
require 'strscan'
 
module VersionSorter
  extend self
 
  def sort(list)
    ss = StringScanner.new ''
    pad_to = 0
    list.each { |li| pad_to = li.size if li.size > pad_to }
 
    list.sort_by do |li|
      ss.string = li
      parts = ''
 
      if match = ss.scan_until(/\d+|[a-z]+/i)
        parts << match.rjust(pad_to)
      end until ss.eos?
 
      parts
    end
  end
 
  def rsort(list)
    sort(list).reverse!
  end
end


module OffGithub
  GITHUB_URL = "http://gems.github.com"
  GEMCUTTER_URL = "http://gemcutter.org"

  class GemList
    attr_reader :list, :source, :gems
  
    def initialize(source = nil)
      if source.class == Array
        @source = nil
        @list = source
      else
        @source = source
        fetch_gem_list
      end
    end
  
    def versions(gem_name)
      @gems[gem_name]
    end
  
    private
    def fetch_gem_list
      out = @source ? `gem list -rs #{@source}` : `gem list --local`
      gems = out.split("\n").select{|l| l =~ /\(/}.inject({}) do |hash, l| 
        elems = l.squeeze(' ').split(' ', 2)
        hash.merge! elems.first.strip => VersionSorter.rsort(elems[1].strip.gsub(/[\(\)]/, '').split(', '))
        hash
      end
      @list = gems.keys
      @gems = gems
    end
  end

  class GemInvestigator
    def initialize( local = GemList.new, 
                    other = GemList.new(GEMCUTTER_URL),
                    github = GemList.new(GITHUB_URL))
      @github = github.list
      @github_gems = github.gems
      @github_url = github.source
      @other = other.list
      @other_gems = other.gems
      @other_url = other.source
      @local = local.list
      @local_gems = local.gems
    end
  
    def github_suspects
      @github_suspects ||= @local.select{|name| looks_like_github_gem?(name)}
    end
    
    def found_matches
      @found_matches ||= github_suspects.map{|name| find_match(name)}
    end
    
    def relations
      @relations ||= Hash[*github_suspects.map.zip(found_matches).flatten]
    end
    
    def will_be_migrated
      return @will_be_migrated if @will_be_migrated
      
      targets = relations.select{|k, v| v}
      @will_be_migrated = targets.map do |names|
        gh_name, gc_name = names
        local_gh_versions = @local_gems[gh_name]
        local_gc_versions = @local_gems[gc_name]
        gh_versions = @github_gems[gh_name]
        gc_versions = @other_gems[gc_name]
        
        action = if @local.include?(gc_name) && !newer_version?(local_gh_versions.first, gc_versions.first)
          "uninstall"
        elsif !newer_version?(gc_versions.first, local_gh_versions.first)
          "skip"
        else
          "reinstall"
        end
        
        [gh_name, gc_name, action]
      end.sort{|a,b| a[2] <=> b[2]}
    end
    
    def will_be_migrated_with_versions
      @will_be_migrated_with_versions ||= will_be_migrated.map do |rows|
        gh_name, gc_name, action = rows
        [gh_name + " (#{@local_gems[gh_name].join(', ')})", 
         gc_name + " (#{@other_gems[gc_name].join(', ')})",
         action]
      end
    end
    
    def will_not_be_migrated
      @will_not_be_migrated ||= Hash[*relations.select{|k, v| !v}.flatten].keys
    end
    
    def stats
      <<-STATS

GitHub gems found on #{GEMCUTTER_URL} (will be reinstalled):
#{Hirb::Helpers::AutoTable.render will_be_migrated_with_versions, :headers => [GITHUB_URL, GEMCUTTER_URL, "action"]}

reinstall = Everything ok. Gemcutter has same/newer version, which will replace installed github version.
skip = Gemcutter doesn't yet have a version that you need, only older. Not touching anything. Run this again later.
uninstall = The non-github version is already installed. Only removing github version.

GitHub gems not found on #{GEMCUTTER_URL} (won't be touched):

#{will_not_be_migrated.join("\n")}

      STATS
    end
    alias to_s stats
    
    private
    def newer_version?(a, b)
      VersionSorter.rsort([a, b]).first == a
    end
    
    def looks_like_github_gem?(name)
      name =~ /-/ && 
        @github.include?(name) && 
        !@other.include?(name)
    end
  
    def find_match(name)
      return nil if !name || name.strip == ""
      return name if @other.include?(name)
      find_match name.split('-', 2)[1]
    end
  end

  class Runner
    def self.run(wet = false)
      unless Gem.sources.find{|g| g =~ /gemcutter/}
        puts "Looks like you don't have gemcutter installed as a source. Follow instructions at #{GEMCUTTER_URL} before running this tool.\n\n"
        return
      end
      
      investigator = GemInvestigator.new
      puts investigator
      print "Everything looks good? Want to migrate gems? (It'll take a bit to perform all the actions.) (Y/n) "
      reply = STDIN.gets.strip
      if reply == "Y"
        puts "Okeydoke.\n\n"
        
        dont_ask = nil
        investigator.will_be_migrated.each do |args|
          github_gem, gemcutter_gem, action = args
          next if action == "skip"
          
          if action == "reinstall"
            print "Reinstall#{dont_ask && 'ing'} #{github_gem} to #{gemcutter_gem}#{dont_ask ? '...' : '? (y/n/a) '}"
            proceed = dont_ask ? "y" : STDIN.gets.strip
          
            if proceed =~ /^[ya]$/
              cmd "sudo gem uninstall -axq --user-install #{github_gem}", wet
              cmd "sudo gem install #{gemcutter_gem} -s #{GEMCUTTER_URL}", wet
              puts "\n"
            end
          else
            print "Uninstall#{dont_ask && 'ing'} #{github_gem}#{dont_ask ? '...' : '? (y/n/a) '}"
            proceed = dont_ask ? "y" : STDIN.gets.strip
            
            if proceed =~ /^[ya]$/
              cmd "sudo gem uninstall -axq --user-install #{github_gem}", wet
              puts "\n"
            end
          end
          
          dont_ask = true if proceed == "a"
        end
        
        puts "Migration finished."
      else
        puts "Oh well."
      end
    end
    
    private
    def self.cmd(cmd, wet = false)
      puts "running: #{cmd}"
      system(cmd) if wet
    end
  end
end