require 'media_converter'

describe MediaConverter do
  before :all do
    @converter = MediaConverter.new
  end

  it "should convert wav to mp3" do
    @converter.convert_wav_to_mp3("test")
  end

  it "should convert wmv to mp3" do
    pending
    @converter.genertate_mp3 "stream.wmv", "stream.mp3"
  end

  it "should convert mms to mp3" do
    pending
    @converter.dump_mms_stream "mms://208.100.43.199/MTVL_S0016/stream.wmv?t=PHJvb3QgYT0iaXRiXzQ4ZmIwNzZkNzY2OTVkNmE2MjI1OWQwMTZhMGFhZjFmIiBiPSIyNzczNyIgYz0iNzEuMjI1LjQ3LjQ2IiBkPSIxMzcwMjQiIGU9IjYwMCIgZj0iRzpcMDAwXDEzN1wwMjRcNjAwLndtdiIgZz0iNjAwIiBoPSItMSIgaT0iMSIgaj0iMCIgaz0iaHR0cDovLzE3NC4xNDIuMTg1LjgwL3N0YXQvd21zX3N0YXRpc3RpY3MuYXNteCIgbD0ibWF0dmlsXzUyNTMxYjRhMDEwYTM0ZDI3YzBjOWUzMjgxM2JjNzI0IiBtPSItMSIgLz4%3d", "test"
  end

  it "should convert remote mms to avi" do
    @converter.save_mms_stream "mms://208.53.168.71/MTVL_S0110/stream.wmv?t=PHJvb3QgbD0ibV9pX2MyOGFjY2U4NGVmMzY0MTBhZTQ0MzliMjJjOTBkMjkwIiBnPSJJMTEwIiBjPSI3MS4yMjUuNDEuODAiIHg9IjEiIGY9IkM6XDAwMFw0NDVcMzQzXDYwMC53bXYiIGs9Imh0dHA6Ly83NC44Ni43Mi4xNjMvc3RhdC93bXNfc3RhdGlzdGljcy5hc214IiBqPSIwIiBoPSIzOCIgeT0iMTI5MzMxNzQ5MCIgej0iMTI5MzMxOTc3MCIgYT0iIiBiPSIiIGQ9IjAiIGU9IiIgaT0iMCIgbT0iMCIgLz4=",
                               "test2.avi"
  end

#   it "should convert wav tp mp3" do
#     @converter.extract_wav("test")
#  end

  it "should convert local wmv to mp3" do
    pending
    command_mencoder = "mencoder stream.wmv -o output.avi -oac lavc -ovc lavc -lavcopts vcodec=xvid:acodec=mp3"

    begin
      @converter.execute_mencoder(command_mencoder)
    rescue Exception => e
      p e
      print "ERROR\n"
      exit 1
    end
  end

  it "should convert local wmv to avi" do
    command_ffmpeg = "ffmpeg -y -i stream.wmv output.avi 2>&1"

    begin
      @converter.execute_ffmpeg2(command_ffmpeg)
    rescue Exception => e
      p e
      print "ERROR\n"
      exit 1
    end
  end

#  it "should convert local wmv to avi" do
#    command_ffmpeg = "ffmpeg -y -i stream.wmv output.avi 2>&1"
#
#    begin
#      @converter.execute_ffmpeg(command_ffmpeg)
#    rescue Exception => e
#      p e
#      print "ERROR\n"
#      exit 1
#    end
#  end
end



