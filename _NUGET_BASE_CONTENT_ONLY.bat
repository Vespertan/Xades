@rem Oczekiwane jest ze przed wykonanie tego pliku 
@rem zostana ustawione wczesniej zmienne: projekt, katalog, build
@rem projekt to nazwa projektu. Np. ProjektA
@rem katalog to miejsce polozenia projektu wzgledem tego pliku. Np. ..\projekt\
@rem Najlepszym sposobem jest w innym pliku bat zdefioniowac te zmienne,
@rem a nastepnie wywoˆac ten plik.

@rem Zawarto˜c takiego pliku moze wygladac nastepujaco:
@rem @set projekt=Vespertan.DataBase
@rem @set katalog=..\Vespertan.DataBase\
@rem @set build=-Build
@rem @_NUGET_BASE.bat

@echo off
set wersja=
set push=T
set del=T

@REM GENROWANIE TIME STAMP

for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\International" /v sShortDate') do set formatDaty=%%a
for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\International" /v sDate') do set separatorDaty=%%a
for /f "tokens=1-3 delims=%separatorDaty%" %%a in ("%formatDaty%") do (
set part1=%%a
set part2=%%b
set part3=%%c)

set part1=%part1:~0,1%
set part2=%part2:~0,1%
set part3=%part3:~0,1%

for /f "tokens=1,2,3 delims=%separatorDaty%" %%a in ("%date%") do (
	if /I %part1% == d (set endDay=%%a) else if /I %part2% == d (set endDay=%%b) else if /I %part3% == d (set endDay=%%c)
	if /I %part1% == m (set endMonth=%%a) else if /I %part2% == m (set endMonth=%%b) else if /I %part3% == m (set endMonth=%%c)
	if /I %part1% == y (set endYear=%%a) else if /I %part2% == y (set endYear=%%b) else if /I %part3% == y (set endYear=%%c)
)
	
set /a endDay=1%endDay%-(11%endDay%-1%endDay%)/10
set /a endMonth=1%endMonth%-(11%endMonth%-1%endMonth%)/10
set /a endYear=1%endYear%-(11%endYear%-1%endYear%)/10
	
set timeStampDays=0
set /a year=2000

:loopYear
set /a rest4=year %% 4
set /a rest100=year %% 100
set /a rest400=year %% 400
set leapYear=0
if %rest400% EQU 0 (set leapYear=1) else if %rest4% EQU 0 if %rest100% NEQ 0 (set leapYear=1)

if %year% LSS %endYear% (
	if %leapYear% EQU 1 (set /a timeStampDays+=366) else (set /a timeStampDays+=365)
	set /a year+=1
	goto loopYear
)

set /a month=1
:loopMonth
if %month% LSS %endMonth% (
if %month% EQU 1 set /a timeStampDays+=31
if %month% EQU 2 if %leapYear% EQU 1 (set /a timeStampDays+=29) else (set /a timeStampDays+=28)
if %month% EQU 3 set /a timeStampDays+=31
if %month% EQU 4 set /a timeStampDays+=30
if %month% EQU 5 set /a timeStampDays+=31
if %month% EQU 6 set /a timeStampDays+=30
if %month% EQU 7 set /a timeStampDays+=31
if %month% EQU 8 set /a timeStampDays+=31
if %month% EQU 9 set /a timeStampDays+=30
if %month% EQU 10 set /a timeStampDays+=31
if %month% EQU 11 set /a timeStampDays+=30
set /a month+=1
goto loopMonth
)

set /a timeStampDays+=%endDay%-1

@REM GENROWANIE CZASU	

for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\International" /v sDecimal') do set separatorDziesietny=%%a
for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\International" /v sTime') do set separatorCzasu=%%a

for /f "tokens=1,2,3 delims=%separatorCzasu%%separatorDziesietny%" %%a in ("%time%") do (
	set hours=%%a
	set minutes=%%b
	set sec=%%c)

for /f "tokens=* delims= " %%a in ("%hours%") do (set hours=%%a)
	
set /a hours= 1%hours% - (11%hours% - 1%hours%)/10
set /a minutes= 1%minutes% - (11%minutes% -1%minutes%)/10
set /a sec=1%sec% - (11%sec% - 1%sec%)/10

set /a timeSpanTime = %hours%*3600 + %minutes%*60 + %sec%
@REM KONIEC GENEROWANIA CZASU
set /a timeSpanTime/=2

set filePath=%projekt%.nuspec
for /f "tokens=3,4 delims=.<>" %%a in ('findstr /R "<version>" %filePath%') do (
	set vMajor=%%a
	set vMinor=%%b
)

set genVersion=%vMajor%.%vMinor%.%timeStampDays%.%timeSpanTime%

set /P wersja=Wersja paczki (puste - pobierz ze specyfikacji projektu)[]
if /I [%wersja%] EQU [] (set wersja=-Version %genVersion%) else (set wersja=-Version %wersja%)
if exist %projekt%.nupkg del %projekt%.nupkg
nuget pack %katalog%%projekt%.nuspec %build% -Prop Configuration=Release %wersja%
if %errorlevel% NEQ 0 goto  err 
rename %projekt%*.nupkg %projekt%.nupkg

echo.
set /P push=Czy wypchnac na serwer? (T/N)[%push%]
if /I [%push%] == [t] (nuget push %projekt%.nupkg -Source http://pv70.internet.piotrkow.pl/nugetserver/)

echo.
set /P del=Usun plik paczki %projekt%.nupkg? (T/N)[%del%]
if /I [%del%] == [t] del %projekt%.nupkg
:err
pause