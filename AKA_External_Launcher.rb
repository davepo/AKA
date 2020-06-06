#Project: AKA Triage Suite
#Sub-Project: AKA External Processor
#Component: External processor launcher
#Purpose: 	This script launches the external processor 
#Supporting tool: Ruby
#Supporting URL: ruby-lang.org
#Developer: Dave Posocco

if ARGV.length != 4
	puts "I need three arguments!"
	exit
end

puts ARGV[0]
puts ARGV[1]
puts ARGV[2]
puts ARGV[3]

cmd="start cmd.exe /K ruby "+ARGV[0]+ARGV[1]+ARGV[2]+ARGV[3]

system(cmd)

exit