# Overview
Useful SQL Server Scripts


### Column datatype from varchar to numeric
This script is useful when you have a column that was created with the purpose of having only numeric values, but it has the varchar datatype.
Basically the script will copy all your data to a temporary table, truncate yours and then copy the data back to the table.
As you can see, there is a test_table example with which you can try to run the script.
