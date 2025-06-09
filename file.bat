@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET path=%~dp0

CALL :generate_mp4_video_in_same_directory %1

EXIT /B %ERRORLEVEL%

:generate_mp4_video_in_same_directory
SET input=%~1
SET without_extension=%~dpn1
CALL :get_extension_without_dot "%input%" extension
SET output=%without_extension%.mp4
CALL :generate_mp4_video_from_image "%input%", "%output%"
EXIT /B 0

:generate_mp4_video_from_image
SET input=%~1
SET output=%~2
CALL :get_extension_without_dot "%input%" extension
IF "%extension%"=="png" CALL :generate_mp4_video "%input%", "%output%"
IF "%extension%"=="jpg" CALL :generate_mp4_video "%input%", "%output%"
IF "%extension%"=="jpeg" CALL :generate_mp4_video "%input%", "%output%"
EXIT /B 0

:generate_mp4_video
SET input=%~1
SET output=%~2
"%path%ffmpeg" ^
  -loop 1 -i "%input%" ^
  -vf "fade=in:st=0:d=5, fade=out:st=55:d=5" ^
  -c:v h264 -t 60 ^
  -pix_fmt yuv420p ^
  "%output%" ^
  -y
EXIT /B 0

:get_extension_without_dot
SET extension=%~x1
SET without_dot=%extension:~1%
SET %~2=%without_dot%
EXIT /B 0
