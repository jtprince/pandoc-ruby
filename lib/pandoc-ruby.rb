require 'open4'

class PandocRuby
  @@bin_path = nil
  EXECUTABLES = %W[
    pandoc
    markdown2pdf
    html2markdown
    hsmarkdown
  ]
  
  def self.bin_path=(path)
    @@bin_path = path
  end

  def self.convert(*args)
    new(*args).convert
  end

  def initialize(*args)
    target = args.shift
    @target  = File.exists?(target) ? File.read(target) : target rescue target
    if args[0] && !args[0].respond_to?(:each_pair) && EXECUTABLES.include?(args[0])
      @executable = args.shift
    else
      @executable = 'pandoc'
    end
    @options = args
  end

  def convert
    executable = @@bin_path ? File.join(@@bin_path, @executable) : @executable
    execute executable + convert_options
  end
  alias_method :to_s, :convert

private

  def execute(command)
    output = ''
    Open4::popen4(command) do |pid, stdin, stdout, stderr| 
      stdin.puts @target 
      stdin.close
      output = stdout.read.strip 
    end
    output
  end


  def convert_options
    @options.inject('') do |string, opt|
      string + if opt.respond_to?(:each_pair)
        opt.inject('') do |s, (flag, val)|
          s + (flag.to_s.length == 1 ? " -#{flag} #{val}" : " --#{flag}=#{val}")
        end
      else
        opt.to_s.length == 1 ? " -#{opt}" : " --#{opt}"
      end
    end
  end
end
