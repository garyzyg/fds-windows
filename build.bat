PUSHD .
FOR %%I IN (C:\WinDDK\7600.16385.1) DO CALL %%I\bin\setenv.bat %%I fre %Platform% WIN7 no_oacr
POPD

IF %_BUILDARCH%==x86 SET Lib=%Lib%\Crt\i386;%DDK_LIB_DEST%\i386;%Lib%
IF %_BUILDARCH%==AMD64 SET Lib=%Lib%\Crt\amd64;%DDK_LIB_DEST%\amd64;%Lib%

git clone --branch 1.23.2 https://github.com/tronkko/dirent.git

FOR %%I IN (
"struct stat"
"\Wstat("
) DO FOR %%J IN (*.c) DO C:\msys64\usr\bin\sed.exe "/%%~I/s@\w*stat@_&@" -i %%J

FOR %%I IN (*.c scandir.h) DO FOR %%J IN (
"ifndef S_IFLNK		if !S_IFLNK"
"ifdef S_IFLNK		if S_IFLNK"
"define SCANDIR_H	&\n#include <dirent.h>"
"#define IS_PATH_DELIM	#include <scandir.h>\n&"
"include .scandir.h.	&\n#ifdef CopyFile\n#undef CopyFile\n#endif"
) DO FOR /F "TOKENS=1,* DELIMS=	" %%K IN (%%J) DO C:\msys64\usr\bin\sed.exe "s@%%K@%%L@" -i %%I

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
	user32.lib advapi32.lib					^
	kernel32.lib						^
