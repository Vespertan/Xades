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

set /P wersja=Wersja paczki (puste - pobierz ze specyfikacji projektu)[]
if /I [%wersja%] NEQ [] set wersja=-Version %wersja%
if exist %projekt%.nupkg del %projekt%.nupkg
nuget pack %katalog%%projekt%.csproj %build% -IncludeReferencedProjects -Prop Configuration=Release %wersja%
if %errorlevel% NEQ 0 goto  err 

rename %projekt%*.nupkg %projekt%.nupkg

echo.
set /P push=Czy wypchnac na serwer? (T/N)[%push%]
@rem if /I [%push%] == [t] (nuget push %projekt%.nupkg -Source http://pv70.internet.piotrkow.pl:8080/nugetserver/)
if /I [%push%] == [t] (nuget push %projekt%.nupkg -Source http://pv70.internet.piotrkow.pl/nugetserver/)
@rem if /I [%push%] == [t] (nuget push %projekt%.nupkg -s http://omvs3/nugetserver/)

echo.
set /P del=Usun plik paczki %projekt%.nupkg? (T/N)[%del%]
if /I [%del%] == [t] del %projekt%.nupkg
:err
pause