@echo off

SET ASDOC_PATH=".\FlexSDK\bin\asdoc"
SET SOURCE_PATH=".\src"
SET OUTPUT_PATH=".\doc"
SET DOCSOURCES_PATH=".\src\ch"

%ASDOC_PATH% -source-path %SOURCE_PATH% -output %OUTPUT_PATH% -doc-sources %DOCSOURCES_PATH% -main-title "Masapi 2.0 - http://masapi.googlecode.com" -window-title "Masapi 2.0 API Reference" -footer "Cedric Tabin - http://www.astorm.ch"

cmd
