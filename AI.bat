@echo off
setlocal EnableDelayedExpansion
set "trained_ai=trained.ai"
if "%~1"=="--train_db" goto train_db
for /f "tokens=2 delims=:" %%A in ('chcp') do set "codepage=%%A"
chcp 65001 > nul 2>&1





if "%~1" neq "" set "trained_ai=%~f1"
net session > nul 2>&1 && set "admin=1" || set "admin=0"
set "working_dir=%~dp0"


if not exist "%trained_ai%" goto create_ai
for /f "usebackq tokens=1* delims==" %%A in ("%trained_ai%") do call :getname_ai
call :ai
exit /b



:ai


findstr /bc:"city" "%trained_ai%" > nul 2>&1 || (
	echo !name! is loading your city...
	for /f "delims=" %%A in ('curl ifconfig.co/city 2^>nul') do set "_city=%%A"
	echo.city="!_city!">>"%trained_ai%"
)
findstr /bc:"country" "%trained_ai%" > nul 2>&1 || (
	echo !name! is loading your country...
	for /f "delims=" %%A in ('curl ifconfig.co/country 2^>nul') do set "_country=%%A"
	echo.country="!_country!">>"%trained_ai%"

)
findstr /bc:"personal_name" "%trained_ai%" > nul 2>&1 || (
	echo !name! is loading your personal name...
	for /f "tokens=1 delims=." %%A in ("%username%") do set "_personal_name=%%A"
	echo.personal_name="!_personal_name!">>"%trained_ai%"
)
for /f "usebackq tokens=1* delims==" %%X in ("!trained_ai!") do set "%%~X=%%~Y"



title !name! AI
::echo.- Remember you're talking to a robot and not a person - It can be rude sometimes
echo.Hello, it's !name!, how can I help you? 

:ai_loop
echo.
set /p "input="
:linked_input
for /f "delims=" %%A in ('slang2english.bat "!input!"') do set "input=%%A"
set "_input=!input!"
set "input=!input:  = !"
for /l %%A in (1,1,15) do set "_input=!_input:  = !"





rem echo.LQ:!last_question!
if defined last_question (
	
	if "%last_question%"=="hau" for %%B in ("good" "great" "fine") do if "!_input:%%~B=_!" neq "!input!" (
		call :imgood
	)
)

for /f "tokens=1* delims==" %%A in ('findstr /bc:"*!input!" "!trained_ai!"') do (
	if !errorlevel! equ 0 (
		set "input=%%B"
		goto linked_input
	)
)

for /f "tokens=1* delims==" %%A in ('findstr /bc:"+!input!" "!trained_ai!"') do (
	if !errorlevel! equ 0 (
		set "input=%%B"
		goto run_command
	)
)

set "last_question="

if "%_input:what time is it=_%" neq "%input%" (
	call :current_time
	goto ai_loop
)

if "%_input:what's the current time=_%" neq "%input%" (
	call :current_time
	goto ai_loop
)
if "%_input:weather like=_%" neq "%input%" (
	for /f "tokens=4 delims=:" %%A in ('curl -L "https://www.metaweather.com/api/location/search/?query=!_city!" 2^>nul') do set "_woeid=%%A"
	for /f "tokens=4 delims=:" %%A in ('curl -L "https://www.metaweather.com/api/location/search/location/!_woeid!?weather_state_name" 2^>nul') do for /f "tokens=1 delims=," %%B in ("%%~A") do echo.%%~B
	goto ai_loop
)


if "%_input:your name=_%" neq "%input%" (
	call :whoareyou
	goto ai_loop
)
if "%_input:who are you=_%" neq "%input%" (
	call :whoareyou
	goto ai_loop
)
if "%_input:how are you=_%" neq "%input%" (
	call :howareyou
	goto ai_loop
	
)

if "%_input:a joke=_%" neq "%input%" (
	call :tellmeajoke
	goto ai_loop
)

if /i "%input%"=="exit" (
	echo Bye^^!
	exit /b
)

if "%_input:m fine=_%" neq "%input%" (
	echo Glad you're fine !username!^^!
	goto ai_loop
)

if "%_input:calculate=_%" neq "%input%" (
	call :calculate
	goto ai_loop
)

if "%_input:link =_%" neq "%input%" (
	call :link_action
	goto ai_loop
)


rem echo.!input! | findstr /ric:"open .*" > nul 2>&1 && goto open_prog

echo.!input! | findstr /ric:"do you know what is *" /ric:"do you know what are *" >  nul 2>&1 && goto learn_input

for %%A in (!hello_arr!) do (
	if "!_input:%%~A=_!" neq "!input!" (
		call :hello
		goto ai_loop
	)
)
rem HAVE TO FIX THIS
rem 
rem if "%_input:what is=_%" neq "%input%" (
rem 	call :wikipedia_search
rem 	goto ai_loop
rem )

echo.Sorry, but I don't understand what you mean by "!input!". What about adding it to my mind?
echo.Or linking it to another action?
set /p input_incorrect=
for %%A in (!ok_arr! !yes_arr!) do if /i "!input_incorrect!"=="%%~A" (
	echo.Adding to my mind...
	goto learn_input
)
for %%A in (!link_arr!) do if /i "!input_incorrect!"=="%%~A" (
	goto link_mind
)
set /a _ran_ans=%random% %% 2
for %%A in (!no_arr!) do if /i "!input_incorrect!"=="%%~A" (
	if "!_ran_ans!"=="0" echo Ok, no problem
	if "!_ran_ans!"=="1" echo.We'll just continue speaking for now then
	goto ai_loop
)
echo With that you mean yes, no or nothing?
set /p ynn_input=
if /i "%ynn_input:~0,1%"=="y" (
	findstr /bvc:"yes_arr=" "!trained_ai!" > "!trained_ai!.tmp"
	echo.yes_arr=!yes_arr!, !ynn_input! >> "!trained_ai!.tmp"
)

if /i "%ynn_input:~0,4%"=="noth" goto ai_loop
if /i "%ynn_input:~0,1%"=="n" (
	findstr /bvc:"no_arr=" "!trained_ai!" > "!trained_ai!.tmp"
	echo.no_arr=!no_arr!, !ynn_input! >> "!trained_ai!.tmp"
)

move /y "!trained_ai!.tmp" "!trained_ai!"
goto ai_loop
chcp %codepage% > nul 2>&1
exit /b

:create_ai
echo Training AI...
set "name=Ristmind"
set "age=10 day"
set "lang=Batch"
echo.name="%name%"> "%trained_ai%"
echo.age="%age%">> "%trained_ai%"
echo.lang="%lang%">> "%trained_ai%"

for /f "delims=" %%A in ('curl ifconfig.co/ 2^>nul') do set "_ip=%%A"
echo.ip="!_ip!">>"%trained_ai%"

for /f "delims=" %%A in ('curl ifconfig.co/city 2^>nul') do set "_city=%%A"
echo.city="!_city!">>"%trained_ai%"


for /f "delims=" %%A in ('curl ifconfig.co/country 2^>nul') do set "_country=%%A"
echo.country="!_country!">>"%trained_ai%"

for /f "tokens=3* delims= " %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v LastLoggedOnDisplayName') do set "_personal_full_name=%%A %%B"
echo.personal_full_name=!_personal_full_name!>>"%trained_ai%"

for /f "tokens=1 delims=." %%A in ("%username%") do set "_personal_name=%%A"

echo.personal_name="!username!">>"%trained_ai%"
echo.ok_arr=ok, alright, aight, okay, "why not">>"%trained_ai%"
echo.yes_arr=yes, ye, yea, yeah>>"%trained_ai%"
echo.good_arr=good, great, fine>>"%trained_ai%"
echo.no_arr=no, nah, no, need, "there's no need", "theres no need">>"%trained_ai%"
echo.preposition_list=a, an, with, to, about, at, for, from, in, inside >>"%trained_ai%"
echo.hello_arr=hello, hi, hey, yo>>"%trained_ai%"
echo.link_arr=link, linked, "link it">>"%trained_ai%"
	
goto :EOF
:getname_ai

for /f "tokens=2 delims==" %%A in ('findstr /bc:"name" "%trained_ai%"') do for /f "delims=" %%B in ("%%A") do set "name=%%~B"

exit /b
:whoareyou
set /a phrases=(%random% %% 5) + 1
set phrases=5
if "%phrases%"=="1" (
	echo.Hello, I'm !name!, an artificial intelligence^^!
)
if "%phrases%"=="2" (
	echo Hey, !name! here.
)
if "%phrases%"=="3" (
	echo Hello, it's !name!.
)
if "%phrases%"=="4" (
	echo I'm !name!. I'm an artificial intelligence.
)
if "%phrases%"=="5" (
	echo I'm !name!. How are you !username! ?
	set "last_question=hau"
)
set phrases=
goto :EOF
:howareyou
set /a phrases=%random% %% 2
if "%phrases%"=="0" (
	echo.Well, machines we can't feel it, but I think I'm fine. I don't find any missing file.
)
if "%phrases%"=="1" (
	echo.I'm fine^^! How about you?
)
set phrases=
goto :EOF

:tellmeajoke
echo.
set joke_count=0
set joke_count_2=0
set /a phrases=(%random% %% 5)
for %%A in (
	"What do you call a bagel that can fly"
	"Why do chicken coops have 2 doors"
	"How did Harry Potter get down the hill"	
	"What's the best thing about Switzerland"
	"Hear about the new restaurant called Karma"
	"How does a computer get drunk"
	"Why did the PowerPoint Presentation cross the road"
	"Why are colds bad criminals"
	"What does a clock do when it's hungry"
	
) do (
	if !phrases! equ !joke_count! echo.%%~A?
	set "joke_arr[!joke_count!]=%%~A?"
	set /a joke_count+=1
	
)
timeout /t 2 > nul
for %%A in (
	"A plain bagel."
	"Because if they had 4 then they would be called chicken sedans."
	"Walking. J.K. Rowling"
	"I don't know, but the flag is a big plus."
	"There's no menu: You get what you deserve^!"
	"It takes screenshots."
	"To get to the other slide."
	"Because they're easy to catch."
	"It goes back four seconds."
) do (
	if !phrases! equ !joke_count_2! echo.%%~A
	set /a joke_count_2+=1
)

goto :EOF

:hello
echo.Hello !username!^^!
goto :EOF

:link_mind
set /p "link_action=What you want to link me with? "
echo.*!input!=!link_action! >>"%trained_ai%"
echo.Alright, !link_action! was linked to !input!
goto ai_loop

:link_action

set link_action=
for /f "tokens=1,2,3*" %%A in ("!input!") do (
	set "link_create=%%B"
	for %%X in (!preposition_list!) do if "%%~C"=="%%X" (
		set link_action=%%D
	)
	if not defined link_action (
		set link_action=%%C %%D
	)
	findstr /c:"*%%B!=!link_action!" "%trained_ai%" > nul 2>&1 && (
	echo.It seems that %%B is already linked to %%D)|| (
		echo.*%%B!=!link_action! >>"%trained_ai%"
		echo.Linked %%B to %%D
	)
	
)
goto ai_loop

:run_command
for /f "tokens=1,2,3*" %%A in ("!input!") do (
	for %%X in (!preposition_list!) do if "%%~C"=="%%X" (
		set run_command=%%D
	)
	if not defined run_command (
		set run_command=%%C %%D
	)
	findstr /c:"*%%B!=!run_command!" "%trained_ai%" > nul 2>&1 && (
	echo.It seems that %%B is already defined)|| (
		echo.*%%B!=!run_command! >>"%trained_ai%"
		echo.Linked %%B to %%D
	)
	
)



:imgood
echo.Great^^!
echo.What do you want to do?
set "last_question=wdywtd"
goto :EOF

:calculate
for /f "tokens=1* delims= " %%A in ("%input%") do set "operation=%%B"
echo.WScript.Echo !operation! > "%TMP%\ai.ristando.operation.vbs"
cscript.exe //nologo "%TMP%\ai.ristando.operation.vbs" 2>nul || echo Error while calculating
goto :EOF

:current_time
for /f %%A in ('time /t') do echo.Current time is %%A
goto :EOF

:wikipedia_search
echo."!input!"
for /f "tokens=2* delims= " %%A in ("!input!") do (
	set "wikipedia_search_term=%%A"
	echo.%%B
)

for /f "tokens=3 delims=*" %%A in ('curl "https://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=content&rvsection=0&titles=%wikipedia_search_term%&format=json"') do echo.%%A
goto :EOF


:learn_input
	set _prep_know_thing=is
	set _plural_know=s
	for /f "tokens=6*" %%A in ("!input:?=!") do (
		set "know_thing=%%A %%B"
		for %%O in ("a" "an") do if "%%A"=="%%~O" set "know_thing=%%B"
		if "!know_thing:~-1!"==" " set know_thing=!know_thing:~0,-1!
		findstr /c:"!know_thing: =_!" "%~dp0%trained_ai%" > nul 2>&1 && (
			for /f "tokens=1* delims==" %%a in ('findstr /bic:"!know_thing!=" %trained_ai%') do (set "know_thing_def=%%b")
			set "know_thing=!know_thing:_= !"
			if "!know_thing:~-1!"=="s" set "_prep_know_thing=are"
			echo.A !know_thing! !_prep_know_thing! !know_thing_def!
			goto ai_loop
		) || (
			set /p "tell_know_thing=Tell me about !know_thing!!_plural_know!. "
			echo.!know_thing!=!tell_know_thing! >> "%~dp0%trained_ai%"
			echo.
			set /a ran_ans_know=%random% %% 4
			if "!ran_ans_know!"=="0" echo.Great^^! Now I know what is a !know_thing!
			if "!ran_ans_know!"=="1" echo.I learnt what is !know_thing!
			if "!ran_ans_know!"=="2" echo.Added to my mind. So I can know a !know_thing! is !tell_know_thing!
			if "!ran_ans_know!"=="3" echo.I just learned the definition of !know_thing!, which is !tell_know_thing!
		)
	)
	goto ai_loop


:open_prog
for /f "tokens=1*" %%I in ("!input!") do set "_program_open=%%J"
echo on
for /f "tokens=1,2*" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s ^| findstr /ric:"InstallLocation.* REG_SZ.*!_program_open!"') do (
	if errorlevel 0 (
		set "InstallLocation=%%C"
		
		for /f "delims=" %%X in ('dir /s /b "!InstallLocation!\*.exe" ^| findstr /ic:"!_program_open!"') do (
			start "" "%%~X"
			goto ai_input
		)
	) else (
	echo The program you just said doesn't exist^^! Make sure you spell it correctly
))
goto ai_input

:train_db
if not exist "!trained_ai!" (
	echo.WARNING: No '!trained_ai!' file, creating one
	call :create_ai
)
if "%~f2"=="" (echo.Missing arguments. Usage: %~n0 --train_db ^<database^> && exit /b)
if not exist "%~f2" (echo.Cannot find "%~f2": AI cannot be trained && exit /b)

set "db_read=%~f2"

for /f "tokens=1,2 delims==" %%A in ('findstr /rc:".*=.*" "!db_read!"') do (
	echo.%%A=%%B >> "!trained_ai!
)
if errorlevel 0 (
	echo.Success: !db_read! was successfully loaded into !trained_ai!
)
exit /b %errorlevel%