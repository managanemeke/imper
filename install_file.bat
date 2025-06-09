@ECHO OFF
CHCP 65001

SET "path=%~dp0"
SET "name=Ночная статика"
SET "position=Bottom"
SET command=%path%file.bat ""%%1""

CALL :add_context_menu_item_for_extension ".png"
CALL :add_context_menu_item_for_extension ".jpg"
CALL :add_context_menu_item_for_extension ".jpeg"

EXIT /B %ERRORLEVEL%

:add_context_menu_item_for_extension
SET "type=%~1"
reg add "HKCR\SystemFileAssociations\%type%\shell\%name%" /f
reg add "HKCR\SystemFileAssociations\%type%\shell\%name%" /f /v MUIVerb /t REG_SZ /d %name%
reg add "HKCR\SystemFileAssociations\%type%\shell\%name%" /f /v Position /t REG_SZ /d %position%
reg add "HKCR\SystemFileAssociations\%type%\shell\%name%\command" /f
reg add "HKCR\SystemFileAssociations\%type%\shell\%name%\command" /f /ve /d "%command%"
EXIT /B 0
