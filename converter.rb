require 'optparse'

input = STDIN
output = STDOUT

options = OptionParser.new do |opts|
  opts.on("-i FILE","Input file") do |filename|
    input = File.new(filename)
  end
  opts.on("-o FILE","Output file") do |filename|
    output = File.open(filename, 'w')
  end
end

begin
  options.parse!(ARGV)
rescue OptionParser::ParseError
  $stderr.print "Error: " + $! + "\n"
  exit
end

output.puts "SET sql_mode='NO_BACKSLASH_ESCAPES';"

input.readlines.each do |line|
  next if line.start_with?('pragma', 'begin transaction',
    'commit', 'delete from sqlite_sequence;',
    'insert into \"sqlite_sequence\"', '/*', '?/*')
  line.gsub! 'AUTOINCREMENT', 'AUTO_INCREMENT'
  line.gsub! 'DEFAULT \'t\'', 'DEFAULT \'1\''
  line.gsub! 'DEFAULT \'f\'', 'DEFAULT \'0\''
  line.gsub! ',\'t\'', ',\'1\''
  line.gsub! ',\'f\'', ',\'1\''
  line.gsub! '[', ''
  line.gsub! ']', ''

  inside_string = false
  newLine = ''
  line.split("").each do |c|
    if not inside_string
      if c == '\''
        inside_string = true
      elsif c == '"'
        newLine = newLine + '`'
        next
      end
    elsif c == '\''
      inside_string = false
    end
    newLine = newLine + c
  end
  output.puts newLine
end

output.close