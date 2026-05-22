## Файл create_db_and_users.sql

Создаем базу, роли и пользователей.
База - medical_center_warehouse

Роли: 

    - аналитик(analyst) - имеет доступ только к аналитическим отчетам
    - администратор склада(warehouse_manager) - имеет полные права на операции со складом

Создаем конкертных пользователей и назначаем им роли

    - пользователь analyst с ролью analyst
    - пользователь warehouse_manager с ролью warehouse_manager

## Файл create_tables.sql

Создает таблицы базы medical_center_warehouse

![alt text](image.png)

## Файл create_indexes.sql

Создает индексы для полей таблиц (в работе)