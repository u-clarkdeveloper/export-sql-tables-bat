@echo off 
cls
setlocal EnableDelayedExpansion
SET tab=	
SET space= 
if "%1"=="" (
	CALL :echo-e "\x1b[1;31mError: You must provide flags to this batch script\x1b[0m"
	echo.
	CALL :help
	exit /b 0
)

CALL :parse_args %*
CALL :help
CALL :clean_path
CALL :set_tablefile
CALL :enable_test
CALL :test_tablefile
CALL :set_server
CALL :set_username
CALL :set_password
CALL :clean_files
CALL :set_date
CALL :set_database
CALL :set_schema
CALL :set_dryrun
CALL :parse_tablelist
CALL :enable_verbose

goto e

:set_dryrun
@REM print out commands instead of running them
if defined flag-dryrun echo ------- Dry Run -------
exit /b 1

:clean_path
@REM Clean up flag-format and check that path and files exists
CALL :set_pre
if !pre!==^" SET flag-format=!flag-format:~1!

CALL :set_post
if !post!==^" SET flag-format=!flag-format:~,-1!

CALL :set_post
if not "!post!" equ "\" SET flag-format=!flag-format!\

if not exist "%flag-format%" (
	CALL :echo-e "\x1b[1;31mError: Format folder must exist\x1b[0m"
	CALL :format_error
) 

if not exist "%flag-format%*.xml" (
	CALL :echo-e "\x1b[1;31mError: Format xml files must exist in folder path\x1b[0m"
	CALL :format_error
)

exit /b 1

:set_pre
SET pre=!flag-format:~,1!
exit /b 1

:set_post
SET post=!flag-format:~-1!
exit /b 1

:set_server
@REM set server if flag-S
if defined flag-S (
    SET "pARserver=-S!flag-S!"
) else (
    SET pARserver=
)
exit /b 1

:set_format
@REM set format if flag-format set
if defined flag-format SET pARformat=-f"%~1.xml"
exit /b 1

:parse_tablelist
@REM loop over table file and create exports
for /F "usebackq tokens=*" %%A in ("%pARinfile%") do (
    echo %%A
    CALL :create_export %%A
    @REM remove any temporary files created by export process
    CALL :remove_tmp
)
exit /b 1

:create_headerfile
@REM 

SET HEADER=
for /F %%B in (HEADERS.!pARdatabase!.%t%.temp) do (
    SET "HEADER=!HEADER!	%%B"
)
echo %HEADER:~1% >> HEADER.!pARdatabase!.%t%.tmp

COPY *.tmp !pARdatabase!.%pARexport_date%.%t%.file >NULL
tr -d '\032' < !pARdatabase!.%pARexport_date%.%t%.file > !pARdatabase!.%pARexport_date%.%t%.csv
rm -f !pARdatabase!.%pARexport_date%.%t%.file
rm -f NULL
exit /b 1

:set_date
@REM set date if flag-date 
if defined flag-date SET pARexport_date=%date:~10,4%%date:~7,2%%date:~4,2%.
exit /b 1

:set_database
@REM set database name variable -d if set
if defined flag-d SET pARdatabase=!flag-d!.
exit /b 1

:set_schema
@REM set schema name if -s is set
if defined flag-schema SET pARschema=!flag-schema!.
exit /b 1

:set_username
@REM set username, otherwise blank
if defined flag-U (
	if not defined flag-P goto user_error
	SET "pARusername=-U!flag-U!"
) else (
	SET pARusername=
)
exit /b 1

:set_password
if defined flag-P (
	if not defined flag-U goto user_error
	SET "pARpassword=-P!flag-P!"
) else (
	SET pARpassword=
)
exit /b 1

:format_error
goto e

:user_error
CALL :echo-e "\x1b[1;31mError: You must set -P and -U together to use either\x1b[0m"
goto e


:set_tablefile
@REM if not test set table file to -f flag or the default tables.txt
if defined flag-f (
    SET "pARinfile=!flag-f!"
) else (
    SET "pARinfile=tables.txt"
)
exit /b 1

:enable_test
@REM if -t is set use test.txt as the table file
if defined flag-t (
	SET "pARinfile=test.txt"
)
exit /b 1

:test_tablefile
CALL :test_file !pARinfile!
exit /b 1


:test_file
@REM test if file exists
if not exist "%~1" (
	CALL :echo-e "\x1b[1;31mError: file %~1 does not exist\x1b[0m"
	CALL :format_error
) 
exit /b 1

:clean_files
@rem remove existing csv files
if defined flag-clean (
	rm -vf *.csv
)
exit /b 1

:remove_tmp
@REM remove temp files function
rm -f *.tmp
rm -f *.temp
exit /b 1

:create_export
@REM create export function
@REM get passed in table
SET t=%1

@REM no table passed in exit function
if [%t%]==[] exit /b 1

@REM export table data
CALL :export_table %t%

@REM export header row for table
@REM CALL :export_headers %t%
exit /b 1

:flags
@REM Formatter for printing flag descriptions example call -> CALL :flags -h "Help me"
SET f=
SET f=%1
SET s=
SET s=%2
echo !tab!!f!!tab!!s:~1,-1!
exit /b 1

:commands
@REM  Formatter for printing command examples -> CALL :commands "MyScript.bat -h -v -q"
SET c=
SET c=%1
echo !space!C:\Users\Me^>!c:~1,-1!
exit /b 1

:help
@REM Display help if -h flag is set
if not defined flag-h exit /b 1
CALL :echo-e "\x1b[1m\x1b[4mExport MS SQL Database Tables\x1b[22;0m"
echo Note: Make sure to have bcp installed on the server running this script
echo.
CALL :echo-e "\x1b[1mUsage:\x1b[22;0m"
echo !tab!ExportSqlTables.bat [flags]
echo.
CALL :echo-e "\x1b[1mFlags:\x1b[22;0m"
CALL :flags -h "Help for ExortSqlTables.bat"
CALL :flags -s "SQL Server hostname, otherwise localhost"
CALL :flags -u "Username for SQL Server"
CALL :flags -p "Password for SQL Server"
CALL :flags -d "Database name, otherwise left off of export"
CALL :flags -schema "Schema for database table, otherwise left off export"
CALL :flags -f "Path to file where a list of tables to export is located"
CALL :flags -format "Use Format file to format exported data. Path to folder with xml format files"
CALL :flags -clean "Clean up existing csv files, will delete any csv file in directory rm *.csv"
CALL :flags ... "!tab!See url for details:"
CALL :flags ... "!tab!https://learn.microsoft.com/en-us/sql/relational-databases/import-export/create-a-format-file-sql-server?view=sql-server-ver16&WT.mc_id=email"
CALL :flags -date "Add Data in format YYYYMMDD to exported file"
CALL :flags -v "View set flags to batch file"
CALL :flags --dryrun "Echo out commands that would have ran"
echo.
CALL :echo-e "\x1b[1mExample:\x1b[22;0m"
CALL :commands "ExportSqlTables.bat -S MYMSSQLSERVER.domain.local -U MyUsername -p MyPassword -d DbName -s dbo -f ListOfTables.txt -date"
CALL :echo-e "\x09\x1b[2;32mConnected to MYMSSQLSERVER.domain.local as MyUsername...\x1b[22;0m"
CALL :echo-e "\x09\x1b[2;32mReading ListOfTables.txt and Exporting Tables...\x1b[22;0m"
CALL :echo-e "\x09\x1b[2;32mDbName.20230801.TableName.csv created\x1b[22;0m"
CALL :echo-e "\x09\x1b[2;32mDbName.20230801.AnotherTableName.csv created\x1b[22;0m"
echo.
CALL :echo-e "\x1b[1;32mDone\x1b[0m"

goto e

:parse_args
@REM parse arguments to batch file
set "flag="
set "last="
for %%a in (%*) do (
	
	if not defined flag (
		set arg=%%a
		if "!arg:~0,1!" equ "-" set "flag=!arg!"
	) else (
		set arg=%%a
		if "!arg:~0,1!" equ "-" (
			set "flag!flag!=true"
			set "flag=!arg!"
		) else (
			set "flag!flag!=%%a"
			set "flag="
		)
	)
	set "last=%%a"
)
@REM Set flag if it is last and is a bool
if "!last:~0,1!" equ "-" set "flag!last!=true"
SET flag=
exit /b 1

:enable_verbose
@REM if -v is set enable verbose and print arguments to batch script
if defined flag-v (
	echo --Set flags--
	SET flag
	echo --Set Parameters--
	SET pAR
	echo.
)
exit /b 1

:export_table
set table=%1
CALL :set_format %~1
SET fulltable=!pARdatabase!!pARschema!%table%
SET filetable=!fulltable!.%pARexport_date%
SET bcpcmd=bcp !fulltable! out !filetable!tmp !pARserver! !pARusername! !pARpassword!
SET filter1=sed -i -E "s+(\w*)(\s*)\t+\1\t+g" !filetable!tmp
SET filter2=sed -i -E "s+\x0++g" !filetable!tmp 
SET convert=unix2dos !filetable!tmp 
if defined flag-dryrun (
    echo !bcpcmd!
	 echo !filter1!
	 echo !filter2!
	 echo !convert!
) else (
    !bcpcmd!>NUL
    !filter1!
	 !filter2!
	 !convert!
)
exit /b 1

:export_headers
SET table=%1
SET sql="select ac.name from sys.all_columns ac inner join sys.tables t on t.object_id = ac.object_id where t.name = '%t%' ORDER BY column_id"
bcp %sql% queryout !pARdatabase!!pARschema!%table%.temp !pARserver! -c -t\t !pARusername! !pARpassword! >NUL
exit /b 1

:echo-e
setlocal
set "arg1=%~1"
set "arg1=%arg1:\x=0x%"
forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo(%arg1%"
exit /b

:e
exit /b 0