function    t = audio_sensor_offset(tag)
%
%    t = audio_sensor_offset(tag)
%     A positive number means that the sensor recording
%     started t seconds after the audio recording.
%     To align audio and sensor data, add t seconds to
%     the sensor time axis.

loadcal(tag,'CUETAB') ;
t = diff(CUETAB(1,[2 7])) ;
