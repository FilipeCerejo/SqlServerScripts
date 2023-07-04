# Overview
Useful SQL Server Scripts


### Column datatype from varchar to numeric
This script is useful when you have a column that was created with the purpose of having only numeric values, but it has the varchar datatype.
Basically the script will copy all data in **table A** to a **temporary table**, truncate **table A** and then copy the data from the **temporary table** into **table A**.
On this particular case, the _NULL_ values will be replaced by _zero (0)_.
As you can see, there is a test_table example with which you can try to run the script.
