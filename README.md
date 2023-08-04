# export-sql-tables-bat

Export MS SQL Database Tables
Note: Make sure to have bcp installed on the server running this script


Usage:
        ExportSqlTables.bat [flags]


Flags:
        -h      Help for ExortSqlTables.bat
        -S      SQL Server hostname, otherwise localhost
        -U      Username for SQL Server
        -P      Password for SQL Server
        -d      Database name, otherwise left off of export
        -s      Schema for database table, otherwise left off export
        -f      Path to file where a list of tables to export is located
        -format Use Format file to format exported data in, file will be xml format
        ...             See url for details:
        ...             https://learn.microsoft.com/en-us/sql/relational-databases/import-export/create-a-format-file-sql-server?view=sql-server-ver16&WT.mc_id=email
        -date   Add Data in format YYYYMMDD to exported file
        -v      View set flags to batch file
        --dryrun        Echo out commands that would have ran


Example:
 C:\Users\Me>ExportSqlTables.bat -S MYMSSQLSERVER.domain.local -U MyUsername -p MyPassword -d DbName -s dbo -f ListOfTables.txt -date

        Connected to MYMSSQLSERVER.domain.local as MyUsername...

        Reading ListOfTables.txt and Exporting Tables...

        DbName.20230801.TableName.csv created

        DbName.20230801.AnotherTableName.csv created


Done