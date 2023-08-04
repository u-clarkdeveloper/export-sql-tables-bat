@echo off
setlocal EnableDelayedExpansion

SET tab=	
SET space= 

CALL :parse_args %*
CALL :help
if defined flag-h exit /b 0
CALL :enable_verbose

@REM if -t is set go to test and use test.txt as the table file
if defined flag-t goto test

@REM if not test set table file to -f flag or the default tables.txt
if defined flag-f (
    SET "infile=!flag-v!"
) else (
    SET "infile=tables.txt"
)

@REM skip test if we reach here and -t was not set
goto main

@REM test section to set test file
:test
SET "infile=test.txt"
@REM continue on to main
goto main

:main

GOTO e

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
if defined flag-h (
    echo Export Database Batchfile
    echo Note: Make sure to have bcp installed on the server running this script
    echo.
    echo Usage:
	echo !tab!ExportSqlTables.bat [flags]
	echo.
	echo Flags:
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
    echo Example:
    CALL :commands "ExportSqlTables.bat -S MYMSSQLSERVER.domain.local -U MyUsername -p MyPassword -d DbName -s dbo -f ListOfTables.txt -date"
	echo.
	echo !space!-^>Connected to MYMSSQLSERVER.domain.local as MyUsername...
	echo.
	echo !space!-^>Reading ListOfTables.txt and Exporting Tables...
	echo.
	echo !space!-^>C:\Users\Me\DbName.20230801.TableName.csv created
	echo !space!-^>C:\Users\Me\DbName.20230801.AnotherTableName.csv created
	echo.
	echo Done
)
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

:e
exit /b 0