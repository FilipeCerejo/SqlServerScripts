
-------------------------------------------------------
---------- TEMPORARY TABLE FOR TEST PURPOSES ----------
-------------------------------------------------------

drop table if exists test_table;

create table test_table (
	id int identity(1,1),
	c1 varchar(20) null,
	c2 varchar(20) not null,
	c3 varchar(30) null
)
go

insert into test_table values('2452335','45634563456','45634563456')
insert into test_table values(null,'56436456', '')
insert into test_table values('3456356345','345634564356563', null)
insert into test_table values(null,'4563547', '1223124')
insert into test_table values('0','6785678567', '12304918341')
insert into test_table values('0','', '1231')

-------------------------------------------------------
-------------------------------------------------------

declare @execute_stmts bit = 1; -- 0: Just print the commands; 1: Executes the commands

-------------------------------------------------------
-------------------------------------------------------
-- On this example we are changing the 'c1' column from 
-- 'test_table' table from varchar(20) to numeric(17)
-------------------------------------------------------
-------------------------------------------------------

declare @table_name varchar(100) = 'test_table',
		@column_name varchar(100) = 'c1';

-------------------------------------------------------
-------------------------------------------------------

declare @temporary_name varchar(100) = concat('##temporary_', @table_name);
declare @column_id int = (
	select column_id
	from sys.tables tb
	inner join sys.columns c
	on(tb.object_id = c.object_id)
	where tb.[name] = @table_name
	and c.[name] = @column_name
);
declare	@before_table_columns varchar(max) = (
	select stuff(
		(select ', ' + c.[name]
		from sys.tables tb
		inner join sys.columns c
		on(tb.object_id = c.object_id)
		where tb.[name] = @table_name
		and c.[column_id] < @column_id
		for xml path('')), 1, 2, '') 
)
declare	@after_table_columns varchar(max) = (
	select stuff(
		(select ', ' + c.[name]
		from sys.tables tb
		inner join sys.columns c
		on(tb.object_id = c.object_id)
		where tb.[name] = @table_name
		and c.[column_id] > @column_id
		for xml path('')), 1, 2, '') 
)

declare @stmt_identity_on nvarchar(max) = concat('set identity_insert ', @table_name, ' on;');
declare @stmt_identity_off nvarchar(max) = concat('set identity_insert ', @table_name, ' off;');
declare @has_identity int = objectproperty(object_id(@table_name), 'tablehasidentity');

declare @stmt_select_table nvarchar(max) = concat('select top 1000 * from ', @table_name)
declare @stmt_delete_temporary nvarchar(max) = concat('drop table if exists ', @temporary_name);
declare @stmt_temporary_name nvarchar(max) = concat('select * into ', @temporary_name, ' from ', @table_name);
declare @stmt_truncate_table nvarchar(max) = concat('truncate table ', @table_name);
declare @stmt_alter_table nvarchar(max) = concat('alter table ', @table_name, ' alter column ' + @column_name + ' numeric(17,0) not null;');
declare @stmt_insert_table nvarchar(max) = concat(
	iif(@has_identity = 1, @stmt_identity_on + ' ', ''),
	'insert into ',
	@table_name,
	'(',
	iif(@before_table_columns is not null, @before_table_columns + ', ', ' '),
	@column_name,
	iif(@after_table_columns is not null, ', ' + @after_table_columns, ' '),
	') select ',
	iif(@before_table_columns is not null, @before_table_columns + ', ', ' '),
	'cast(iif(', @column_name, ' is null or ', @column_name,' = '''', ','''0'', ', @column_name, ') as numeric(17,0)) as ', @column_name,
	iif(@after_table_columns is not null, ', ' + @after_table_columns , ''),
	' from ',
	@temporary_name,
	';',
	iif(@has_identity = 1, ' ' + @stmt_identity_off, ''))

if exists (
	select 1
	from sys.tables tb
	inner join sys.columns c
	on(tb.object_id = c.object_id)
	inner join sys.types tp
	on(c.user_type_id = tp.user_type_id)
	where tb.type = 'U'
	and tb.[name] = @table_name
	and c.[name] = @column_name
	and tp.[name] = 'varchar'
)
begin

	
	if @execute_stmts = 1
	begin

		begin tran
		begin try

			exec sp_executesql @stmt_select_table;
			exec sp_executesql @stmt_delete_temporary;
			exec sp_executesql @stmt_temporary_name;
			exec sp_executesql @stmt_truncate_table;
			exec sp_executesql @stmt_alter_table;
			exec sp_executesql @stmt_insert_table;
			exec sp_executesql @stmt_delete_temporary;
			exec sp_executesql @stmt_select_table;

			commit;

		end try
		begin catch

			select
				  error_number()	as [Error Number]
				, error_state()		as [Error State]
				, error_severity()	as [Error Severity]
				, error_message()	as [Error Message];

			rollback;

		end catch

	 end
	 else
	 begin
		print @stmt_delete_temporary;
		print @stmt_temporary_name;
		print @stmt_truncate_table;
		print @stmt_alter_table;
		print @stmt_insert_table;
		print @stmt_delete_temporary;
	 end

end

drop table if exists test_table;