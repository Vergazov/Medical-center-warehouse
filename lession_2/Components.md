Индексы:

Таблица номенклатуры nomenclatures

Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность| Ограничения                         |
|--------------------|---------------------|-----------------------------|-----------------------|
| id                 | CRUD операции, поиск связанных приходных и расходных накладных | высокая     | primary key (unique, not null)       |
| name               | Поиск по имени      | высокая     | 255 символов, not null, unique        |
| type_id            | фильтрация по типу, join для отображения всей информации о товаре         | средняя   | foreign key, not null |
| speciality_id      | фильтрация по специльности, join для отображения всей информации о товаре | средняя   |   foreign key, not null |
| main_unit_id       | join для отображения всей информации о товаре  | высокая  | foreign key, not null     |
| inv_number         | -                   | высокая                 | 100 символов |
| expiration_date    | отчет по номенклатуре у которой близится окончание срока годности  | средняя       | ограничения формата |
| expiration_unit_id | join для отображения всей информации о товаре  | высокая | ограничения формата |
| min_balance        | отчет по номенклатуре у которой близится срок дозаказа  | средняя                  |ограничения формата |
| max_balance        | отчет по номенклатуре, которой слишком много на складе  | средняя                  |ограничения формата |
| comment            | -       | высокая     | ограничения формата |

Индексы:

* CREATE INDEX idx_name ON nomenclatures(name);
* CREATE INDEX idx_type_id ON nomenclatures(type_id);
* CREATE INDEX idx_speciality_idON nomenclatures(speciality_id);
* CREATE INDEX idx_main_unit_id ON nomenclatures(main_unit_id );
* CREATE INDEX idx_expiration_unit_id ON nomenclatures(expiration_unit_id);
* CREATE INDEX idx_min_balance ON nomenclatures(min_balance);
* CREATE INDEX idx_max_balance ON nomenclatures(max_balance);

Таблица приходных накладных - purchase_invoices

Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции, поиск связанных приходов | Высокая          | primary key (unique, not null)|
| document_number    | -    | Высокая      | ограничения формата, not null, unique |
| date               | поиск по дате         | высокая       | ограничения формата, not null |
| provider_id        | фильтрация по поставщику, join для отображения всей информации о накладной | средняя |foreign key, not null | 
| employee_id        | фильтрация по тветственному, join для отображения всей информации о накладной | низкая |foreign key, not null |  
| company_id         | фильтрация по юр лицу, join для отображения всей информации о накладной | средняя |foreign key, not null |  
| storage_id         | фильтрация по складу, join для отображения всей информации о накладной | средняя |foreign key, not null |  
| comment            | -  | высокая | ограничения формата |

Индексы:

* CREATE INDEX idx_date ON purchase_invoices(date);
* CREATE INDEX idx_provider_id  ON purchase_invoices(provider_id );
* CREATE INDEX idx_employee_id ON purchase_invoices(employee_id);
* CREATE INDEX idx_company_id ON purchase_invoices(company_id);
* CREATE INDEX idx_storage_id  ON purchase_invoices(storage_id);

Таблица приходов - parishes

Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                   | CRUD операции            | высокая | primary key (unique, not null)|
| amount               | поиск по количеству  | высокая   | ограничения формата, not null |
| price                | поиск по цене             | высокая | ограничения формата, not null
| vat                  | поиск по ставке НДС             | низкая              | ограничения формата
| manufacture_date     | поиск по дате производства      | высокая         | ограничения формата
| good_until           | поиск по сроку годности      | высокая                  | ограничения формата
| namenclature_id      | join для отображения всей информации о приходе, поиск по номенклатуре  |  высокая |foreign key, not null |  
| purchase_invoice_id  | -             | высокая       | foreign key, not null| 
| comment              | -                | высокая                | ограничения формата |

Индексы:

* CREATE INDEX idx_amount ON parishes(amount);
* CREATE INDEX idx_price ON parishes(price);
* CREATE INDEX idx_vat ON parishes(vat);
* CREATE INDEX idx_good_until ON parishes(good_until);
* CREATE INDEX idx_namenclature_id ON parishes(namenclature_id);
* CREATE INDEX idx_purchase_invoice_id ON parishes(purchase_invoice_id);

## Таблица расходных накладных - expense_invoices

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции, поиск связанных приходов | Высокая          | primary key (unique, not null)|
| document_number    | -    | Высокая      | ограничения формата, not null, unique |
| date               | поиск по дате         | высокая       | ограничения формата, not null |
| accounting_object_id | поиск по объекту учета       | средняя | foreign key, not null
| storage_id         | фильтрация по складу, join для отображения всей информации о накладной | средняя |foreign key, not null |  
| comment            | -  | высокая | ограничения формата |

Индексы:

* CREATE INDEX idx_date ON expense_invoices(idx_date);
* CREATE INDEX idx_accounting_object_id ON expense_invoices(accounting_object_id);
* CREATE INDEX idx_storage_id ON expense_invoices(storage_id);


## Таблица списаний - cancellations

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции, поиск связанных расходов | высокая | primary |key (unique, not null)|
| amount               | поиск по количеству  | высокая   | ограничения формата, not null |
| price                | поиск по цене             | высокая | ограничения формата, not null
| vat                  | поиск по ставке НДС             | низкая              | ограничения формата
| manufacture_date     | поиск по дате производства      | высокая         | ограничения формата
| good_until           | поиск по сроку годности      | высокая                  | ограничения формата
| namenclature_id      | join для отображения всей информации о расходе, поиск по номенклатуре  |  высокая |foreign key, not null |  
| expense_invoice_id   | -             | высокая       | foreign key, not null| 
| comment              | -                | высокая                | ограничения формата |

Индексы:

* CREATE INDEX idx_amount ON cancellations(amount);
* CREATE INDEX idx_price ON cancellations(price);
* CREATE INDEX idx_vat ON cancellations(vat);
* CREATE INDEX idx_good_until ON cancellations(good_until);
* CREATE INDEX idx_namenclature_id ON cancellations(namenclature_id);
* CREATE INDEX idx_expense_invoice_id ON cancellations(expense_invoice_id);

## Таблица типов - types

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции | Высокая | primary key (unique, not null)|
| name               | поиск по имени       | высокая  | unique, not null |

Индексы:

* CREATE INDEX idx_name ON types(name);

## Таблица специальностей - specialities

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции | высокая | primary key (unique, not null)|
| name               | поиск по имени       | высокая  | unique, not null |

Индексы:

* CREATE INDEX idx_name ON specialities(name);

## Таблица единиц измерения - units

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции | высокая | primary key (unique, not null)|
| name               | поиск по имени       | высокая  | unique, not null |

Индексы:

* CREATE INDEX idx_name ON units(name);

## Таблица поставщиков - providers

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции | высокая | primary key (unique, not null)|
| name               | поиск по имени       | высокая  | unique, not null |
| INN                | поиск по инн      | высокая  | unique, not null |

Индексы:

* CREATE INDEX idx_name ON providers(name);
* CREATE INDEX idx_INN ON providers(INN);


## Таблица сотрудников - employees

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции | высокая | primary key (unique, not null)|
| name               | поиск по имени       | высокая  | unique, not null |
| address             | -      | высокая  | not null |
| email              | -     | высокая  | not null , unique|

Индексы:

* CREATE INDEX idx_name ON employees(name);

## Таблица компаний - companies

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции | высокая | primary key (unique, not null)|
| name               | поиск по имени       | высокая  | unique, not null |
| INN                | поиск по инн      | высокая  | unique, not null |

Индексы:

* CREATE INDEX idx_name ON companies(name);
* CREATE INDEX idx_INN ON companies(INN);

## Таблица складов - storages

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции, отображение структуры склада | Высокая | primary key (unique, not null)|
| name               | поиск по имени       | высокая  | unique, not null |
| company_id         |  join для отображения всей информации о складе, поиск по компании     | высокая  | not null |

Индексы:

* CREATE INDEX idx_name ON storages(name);
* CREATE INDEX idx_INN ON storages(INN);

## Таблица структуры складов - strorage_structures

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | - | Высокая | primary key (unique, not null)|
| parent_id          |  -     | высокая  | foreign key, not null |
| child_id           |  -     | высокая  | foreign key, not null |

Индексы:

* CREATE INDEX idx_parent_id ON strorage_structures(parent_id);
* CREATE INDEX idx_child_id  ON strorage_structures(child_id);

## Таблица объектов учета - accounting_object

### Возможные запросы/отчеты/ограничения:

| Поле               | Описание запроса    | Кардинальность | Ограничения |
|--------------------|---------------|-----------------------------------|--------------|
| id                 | CRUD операции | Высокая | primary key (unique, not null)|
| name               | поиск по имени       | высокая  | unique, not null |

Индексы:

* CREATE INDEX idx_name ON accounting_object(name);