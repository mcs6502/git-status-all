require 'git'
require 'colorize'

require "git/status_all/version"
require "git/status_all/extensions"
require "git/status_all/git"

module Git
  module StatusAll
	class App
		def main
			dev_dir = '/Users/reednj/Documents/dev/'
			repo_paths = Dir.entries(dev_dir).
				map {|p| { :name => p, :path => File.expand_path(p, dev_dir) } }.
				select { |p| Git.repo? p[:path] }
			
			repo_paths.each do |p|
				g = Git.open p[:path]
				s = file_status(g)
				r = remote_status(g)

				s = " #{s} ".black.on_yellow unless s.empty?
				n = s.empty? ? p[:name] : p[:name].yellow 
				puts "#{n}".pad_to_col(24).append(s).right_align("#{r} [#{g.branch.to_s.blue}]")
			end
		
		end

		def file_status(g)
			result = ""
			result += "A#{g.status.added.length}" if g.status.added.length > 0
			result += "D#{g.status.deleted.length}" if g.status.deleted.length > 0
			result += "M#{g.status.changed.length}" if g.status.changed.length > 0
			result += "U#{g.status.untracked.length}" if g.status.untracked.length > 0
			return result
		end

		def remote_status(g)
			if g.remotes.empty?
				return "no remotes".black.on_red
			end

			if g.remotes.select{|r| r.name.downcase == 'origin' }.empty?
				return "no origin".black.on_yellow
			end

			if !g.branches[:master].up_to_date?
				b = g.branches[:master]
				
				s = ''
				s += "#{b.behind_count}↓" if b.behind_count > 0
				s += ' / '  if b.ahead_count > 0 && b.behind_count > 0
				s += "#{b.ahead_count}↑" if b.ahead_count > 0

				return s.green
			end

			return ''
		end

		def term_width
			@term_width ||= `tput cols`.to_i
		end

	end
  end
end