SET SED=C:\msys64\usr\bin\sed.exe

PUSHD .
FOR %%I IN (C:\WinDDK\7600.16385.1) DO CALL %%I\bin\setenv.bat %%I fre %Platform% WIN7 no_oacr
POPD

IF %_BUILDARCH%==x86 SET Lib=%Lib%\Crt\i386;%DDK_LIB_DEST%\i386;%Lib%
IF %_BUILDARCH%==AMD64 SET Lib=%Lib%\Crt\amd64;%DDK_LIB_DEST%\amd64;%Lib%

git clone --branch 1.26 https://github.com/tronkko/dirent.git

CD dirent
git apply ../dirent-1.24.diff
CD ..

FOR %%I IN (*.c) DO FOR %%J IN (
"include .sys/stat.h.	&\n#include <config.h>"
) DO FOR /F "TOKENS=1,* DELIMS=	" %%K IN (%%J) DO %SED% "s@%%K@%%L@" -i %%I

FOR /F %%I IN ('DIR /B *.c') DO CALL :cl %%I
CALL :link fds.exe

GOTO :EOF

:cl
cl.exe -nologo -O1 /GL /GS- /I%CRT_INC_PATH% /Idirent/include /I. -c /MD /DNDEBUG %*
GOTO :EOF

:link
link.exe -nologo						^
	/LTCG							^
	/OUT:%1							^
	*.obj							^
	/NODEFAULTLIB /SUBSYSTEM:CONSOLE			^
	/MERGE:.rdata=.text /MERGE:.data=.text			^
	kernel32.lib msvcrt.lib					^
	/ALIGN:16						^
