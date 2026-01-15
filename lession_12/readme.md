### Создать индекс к какой-либо из таблиц вашей БД

Создаю индексы на таблицу nomenclatures
* CREATE INDEX idx_type_id ON nomenclatures(type_id);
* CREATE INDEX idx_speciality_id ON nomenclatures(speciality_id);
* CREATE INDEX idx_main_unit_id ON nomenclatures(main_unit_id );
* CREATE INDEX idx_expiration_unit_id ON nomenclatures(expiration_unit_id);

### Прислать текстом результат команды explain, в которой используется данный индекс

>Команда:
```
EXPLAIN SELECT 
n.id, 
n.name AS nomenclature, 
t.name AS type, 
specs.name AS spec,
n.inv_number,
u_main.name AS main_unit_name,
n.expiration_date,
u_exp.name AS exp_unit_name, 
min_balance, max_balance,
n.comment 
FROM nomenclatures AS n
LEFT JOIN types AS t ON n.type_id = t.id
LEFT JOIN specialities AS specs ON n.speciality_id = specs.id
LEFT JOIN units AS u_main ON n.main_unit_id = u_main.id
LEFT JOIN units AS u_exp ON n.expiration_unit_id = u_exp.id
where type_id = 4
```

>Вывод:
```
"Nested Loop Left Join  (cost=0.61..184.90 rows=1 width=327)"
"  ->  Nested Loop Left Join  (cost=0.46..176.72 rows=1 width=299)"
"        ->  Nested Loop Left Join  (cost=0.30..168.54 rows=1 width=271)"
"              ->  Nested Loop Left Join  (cost=0.15..160.36 rows=1 width=243)"
"                    ->  Seq Scan on nomenclatures n  (cost=0.00..152.18 rows=1 width=215)"
"                          Filter: (type_id = 4)"
"                    ->  Index Scan using types_pkey on types t  (cost=0.15..8.17 rows=1 width=36)"
"                          Index Cond: (id = 4)"
"              ->  Index Scan using specialities_pkey on specialities specs  (cost=0.15..8.17 rows=1 width=36)"
"                    Index Cond: (id = n.speciality_id)"
"        ->  Index Scan using units_pkey on units u_main  (cost=0.15..8.17 rows=1 width=36)"
"              Index Cond: (id = n.main_unit_id)"
"  ->  Index Scan using units_pkey on units u_exp  (cost=0.15..8.17 rows=1 width=36)"
"        Index Cond: (id = n.expiration_unit_id)"
```

### Реализовать индекс для полнотекстового поиска
>Команда:
```
alter table nomenclatures add column name_lexeme tsvector;

update pg_index
set indisready = false
where indrelid = (
	select oid from pg_class
	where relname = 'nomenclatures'
);

update nomenclatures set name_lexeme = to_tsvector(name);

update pg_index
set indisready = true
where indrelid = (
	select oid from pg_class
	where relname = 'nomenclatures'
);

reindex table nomenclatures;

create index idx_name_fts on nomenclatures using gin(name_lexeme);

```
> Комментарий к индексу - индекс для полнотекстового поиска по наименованию номенклатуры

### Реализовать индекс на часть таблицы или индекс на поле с функцией
>Команда:
```
CREATE INDEX idx_name_lower ON emplayees (LOWER(name));
```
> Комментарий к индексу - индекс для регистронезависимого поиска сотрудника по имени 

### Создать индекс на несколько полей
```
CREATE INDEX idx_provider_id_employee_id on purchase_invoices(provider_id,employee_id)
```
> Комментарий к индексу - составной индекс для поиска приходных накладных у определенного постщика оприходованного определенным сотрудником

### Описать что и как делали и с какими проблемами столкнулись
Не сразу понял как реализовать полнотекстовый поиск. Пересмотрел лекцию, разобрался и все сделал. 