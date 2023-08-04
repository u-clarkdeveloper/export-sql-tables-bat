@echo off
setlocal EnableDelayedExpansion
@REM $_$E[1;30;40m[$E[0;36;40m%computername% | %userdomain%\%username%$E[1;30;40m] $E[0;33;40m$M$_$E[35;40m$d$s$t$h$h$h$h$h$h$_$E[1;33;40m$p$_$E[1;30;40m$g $E[0;37;40m

SET tab=	
SET space= 
if [%*]==[] (
	echo.
	CALL :echo-e "\x1b[1;31mError: You must provide flags to this batch script\x1b[0m"
	echo.
	echo.
	CALL :help
	exit /b 0
)
CALL :parse_args %*

CALL :help
@REM Exit early if help flag -h was set
if defined flag-h exit /b 0

CALL :enable_verbose
CALL :set_tablefile
CALL :enable_test
CALL :set_username
CALL :set_password
CALL :main

GOTO e

@REM Main logic
:main

exit /b 1

:set_username
if defined flag-U (
	if not defined flag-P goto user_error
	SET "username=-U!flag-U!"
) else (
	SET username=
)
exit /b 1

:set_password
if defined flag-P (
	if not defined flag-U goto user_error
	SET "password=-P!flag-U!"
) else (
	SET password=
)
exit /b 1

:user_error
echo Error: You must set -P and -U to user either
exit /b 1

:set_tablefile
@REM if not test set table file to -f flag or the default tables.txt
if defined flag-f (
    SET "infile=!flag-v!"
) else (
    SET "infile=tables.txt"
)
exit /b 1

:enable_test
@REM if -t is set use test.txt as the table file
if defined flag-t SET "infile=test.txt"
exit /b 1

@REM remove temp files function
:remove_tmp
rm *.tmp
rm *.temp

@REM create export function
:create_export
@REM get passed in table
SET t=%1

@REM no table passed in exit function
if [%t%]==[] exit /b 1

@REM export table data
CALL :export_table %t%

@REM export header row for table
CALL :export_headers %t%

@REM Main stuff goes here



@REM Formatter for printing flag descriptions example call -> CALL :flags -h "Help me"
:flags
SET f=
SET f=%1
SET s=
SET s=%2
echo !tab!!f!!tab!!s:~1,-1!
exit /b 1

@REM  Formatter for printing command examples -> CALL :commands "MyScript.bat -h -v -q"
:commands
SET c=
SET c=%1
echo !space!C:\Users\Me^>!c:~1,-1!
exit /b 1

:help
@REM Display help if -h flag is set

CALL :echo-e "\x1b[1m\x1b[4mExport MS SQL Database Tables\x1b[22;0m"
echo Note: Make sure to have bcp installed on the server running this script
echo.
CALL :echo-e "\x1b[1mUsage:\x1b[22;0m"
echo !tab!ExportSqlTables.bat [flags]
echo.
CALL :echo-e "\x1b[1mFlags:\x1b[22;0m"
CALL :flags -h "Help for ExortSqlTables.bat"
CALL :flags -S "SQL Server hostname, otherwise localhost"
CALL :flags -U "Username for SQL Server"
CALL :flags -P "Password for SQL Server"
CALL :flags -d "Database name, otherwise left off of export"
CALL :flags -s "Schema for database table, otherwise left off export"
CALL :flags -f "Path to file where a list of tables to export is located"
CALL :flags -format "Use Format file to format exported data in, file will be xml format"
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

exit /b 1

:parse_args
@REM parse arguments to batch file
echo %1
echo %*
set "flag="
set "last="
for %%a in (%*) do (
	
	if not defined flag (
		set arg=%%a
		echo !arg!
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
exit /b 1

:enable_verbose
@REM if -v is set enable verbose and print arguments to batch script
if defined flag-v (
	echo --Set flags--
	SET flag
)
exit /b 1

:echo-e
setlocal
set "arg1=%~1"
set "arg1=%arg1:\x=0x%"
forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo(%arg1%"
exit /b

:e
exit /b 0