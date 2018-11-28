@echo off

set    zip=digdug.zip
set ifiles=dd1a.1+dd1a.2+dd1a.3+dd1a.4.bin+dd1a.5+dd1a.6+dd1.7+dd1.9+dd1.15+dd1.14+dd1.13+dd1.13+dd1.11+dd1.10b
set  ofile=a.digdug.rom

rem =====================================
setlocal ENABLEDELAYEDEXPANSION

set pwd=%~dp0
echo.
echo.

if EXIST %zip% (

	!pwd!7za x -otmp %zip%
	if !ERRORLEVEL! EQU 0 ( 
		cd tmp

		copy /b/y %ifiles% !pwd!%ofile%
		if !ERRORLEVEL! EQU 0 ( 
			echo.
			echo ** done **
			echo.
			echo Copy "%ofile%" into root of SD card
		)
		cd !pwd!
		rmdir /s /q tmp
	)

) else (

	echo Error: Cannot find "%zip%" file
	echo.
	echo Put "%zip%", "7za.exe" and "%~nx0" into the same directory
)

echo.
echo.
pause
