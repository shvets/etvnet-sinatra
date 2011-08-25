# http://kpumuk.info/ruby-on-rails/encoding-media-files-in-ruby-using-ffmpeg-mencoder-with-progress-tracking/

require 'progressbar'

class MediaFormatException < StandardError
end


class MediaConverter

  def genertate_mp3 input_file, output_file
    command = "ffmpeg -y -i #{input_file} -vn -ar 44100 -ac 2 -ab 192 -f mp3 #{output_file} 2>&1"

    execute("ffmpeg", command)
  end

  def generate_flv input_file, output_file
    command = "ffmpeg -i #{input_file} -ab 56 -ar 44100 -b 200 -r 15 -s 320x240 -f flv #{output_file} 2>&1"

    execute("ffmpeg", command)
  end

  def dump_mms_stream url, name
    command = "-dumpstream -dumpfile #{name}.wma #{url} 2>&1"

    execute("mplayer", command)
  end

  def save_mms_stream url, name
    command = "mencoder #{url} -ovc copy -oac copy -o #{name}"

    execute_mencoder(command)
    #execute("mencoder", command)
  end

  def extract_wav name
    command = "-vo null -vc dummy -ao pcm:file=#{name}.wav #{name}.wma"

    execute("mplayer", command)
  end

  def convert_wav_to_mp3 name
    command = "-ab 128 -i #{name}.wav #{name}.mp3"
p command

    execute("ffmpeg", command)
  end

  def execute_mencoder(command)
    progress = nil
    IO.popen(command) do |pipe|
      pipe.each("\r") do |line|
        if line =~ /Pos:[^(]*(\s*(\d+)%)/
          p = $1.to_i
          p = 100 if p > 100
          if progress != p
            progress = p
            print "PROGRESS: #{progress}\n"
            $defout.flush
          end
        end
      end
    end
    raise MediaFormatException if $?.exitstatus != 0
  end

  def execute_ffmpeg(command)
    progress = nil
    duration = 0
    IO.popen(command) do |pipe|
      pipe.each("\r") do |line|
        if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{1})/
          duration = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 10 + $4.to_i
        end

        if line =~ /time=(\d+).(\d+)/
          if not duration.nil? and duration != 0
            p = ($1.to_i * 10 + $2.to_i) * 100 / duration
          else
            p = 0
          end
          p = 100 if p > 100
          if progress != p
            progress = p
            print "PROGRESS: #{progress}\n"
            $defout.flush
          end
        end
      end
    end
    raise MediaFormatException if $?.exitstatus != 0
  end

#  def execute_ffmpeg2(command)
#    pbar = ProgressBar.new("test", 100)
#
#    duration = 0
#
#    IO.popen(command) do |pipe|
#      pipe.each("\r") do |line|
#        if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{1})/
#          duration = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 10 + $4.to_i
#        end
#
#        if line =~ /time=(\d+).(\d+)/
#          if not duration.nil? and duration != 0
#            pos = ($1.to_i * 10 + $2.to_i) * 100 / duration
#          else
#            pos = 0
#          end
#
#          pos = 100 if pos > 100
#
#          pbar.set(pos) if pbar.current != pos
#        end
#      end
#    end
#
#    pbar.finish
#  end
  
  protected

  def execute(tool, command)
    progress_bar = ProgressBar.new("media converter", 100)

    IO.popen("#{tool} #{command}") do |pipe|
      duration = 0

      pipe.each("\r") do |line|
        p line

        duration = next_position(duration, line) do |position|
          progress_bar.set(position) if progress_bar.current != position
        end
      end
    end

    progress_bar.finish
  end

  def next_position duration, line
    if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{1})/
      duration = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 10 + $4.to_i
    end

    if line =~ /time=(\d+).(\d+)/
      if duration != 0
        pos = ($1.to_i * 10 + $2.to_i) * 100 / duration
      else
        pos = 0
      end

      pos = 100 if pos > 100

      yield(pos)
    end

    duration
  end

  def get_video_file_duration(input_ilename)
    command = "ffmpeg -i " + input_ilename.to_s + "
                             2>&amp;1 | grep 'Duration'
                             | cut -d ' ' -f 4 | sed s/,//"
    output = `#{command}`

    if output =~ /([\d][\d]):([\d][\d]):([\d][\d]).([\d]+)/
      duration = (($1.to_i * 60 + $2.to_i) * 60 + $3.to_i) * 10 + $4.to_i
    end

    #return duration.to_s
    "#{$2}:#{$3}"
  end
end
