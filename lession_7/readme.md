## В рамках домашнего задания выполнены следующие действия:

### Создание базы clinic:
```
create database clinic encoding = 'UTF8';
```

### Создание схемы medical_center_warehouse
```
create schema medical_center_warehouse;
```

### Создание ролей:
* developer:
```
create role developer;
```
* analyst:
```
create role analyst;
```

### Создание пользователей:
* ava:
```
 create user ava with password '***'
```
* vasya_pupkin:
```
 create user vasya_pupkin with password '***'
```

### Права ролей:

#### developer:

1. использование схемы medical_center_warehouse:
```
grant usage on schema medical_center_warehouse to developer;
```

2. создание объектов в схеме medical_center_warehouse:
```
grant create on schema medical_center_warehouse to developer;
```

3. выполнение любых операций с уже существующими таблицами в схеме medical_center_warehouse
```
grant all on all tables in schema medical_center_warehouse to developer;
```

4. права на создание и использования табличного пространства:
```
grant create on tablespace references_ts  to developer;
```

5. роль developer наследует пользователь ava
```
grant developer to ava;
```

#### analyst

1. использование схемы medical_center_warehouse:
```
grant usage on schema medical_center_warehouse to analyst;
```

2. выполнение select операций с уже существующими таблицами в схеме medical_center_warehouse
```
grant SELECT on all tables in schema medical_center_warehouse to analyst;
```

3. роль analyst наследует пользователь vasua_pupkin
```
grant analyst to vasya_pupkin;
```

### Создание табличного пространства references_ts, в котором будут хранится все справочные таблицы
```
\! mkdir ~/references_ts;

create tablespace references_ts location '/var/lib/postgresql/references_ts';
```

### Пользователю ava выданы права на CRUD операции со всеми таблицами которые будут созданы в будущем
```
ALTER DEFAULT PRIVILEGES IN SCHEMA medical_center_warehouse GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ava;
```

### Пользователю analyst выдано право на SELECT операции со всеми таблицами которые будут созданы в будущем
```
ALTER DEFAULT PRIVILEGES IN SCHEMA medical_center_warehouse GRANT SELECT ON TABLES TO analyst;
```

### Созданы все таблицы согласно схеме
Таблицы справочников вынесены в табличное пространство references_ts. Это таблицы:
* accounting_object
* companies
* employees
* providers
* specialities
* storages
* storages_structures
* types
* units
