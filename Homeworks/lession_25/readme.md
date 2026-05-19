# DML: вставка, обновление, удаление, выборка данных в MySQL

## Задание в сфере администрирования и разработки

### Напишите запрос по своей базе с inner join

```sql
-- Вывести все оприходования конкретного товара
SELECT
    nomenclatures.name,
    parishes.price,
    parishes.amount,
    purchase_invoices.document_number,
    purchase_invoices.date
FROM parishes
INNER JOIN nomenclatures nom ON nom.id = nomenclature.id
INNER JOIN purchase_invoices ON purchase_invoices.id = parishes.purchase_invoice_id
WHERE nomenclatures.id = 4
ORDER BY DATE DESC;
```

### Напишите запрос по своей базе с left  join
```sql
-- Вывод всей информации о товарах
SELECT
    nomenclatures.name,
    types.name,
    specialities.name,
    main_unit,
    exp_unit,
    min_balance,
    max_balance
FROM nomenclatures
LEFT JOIN types ON types.id = nomenclatures.type_id
LEFT JOIN specialities ON specialities.id = nomenclatures.speciality_id
LEFT JOIN units main_unit ON unitts.id = nomenclatures.main_unit_id
LEFT JOIN units exp_unit ON unitts.id = nomenclatures.expiration_unit_id;
```

### Напишите 5 запросов с WHERE с использованием разных операторов, опишите для чего вам в проекте нужна такая выборка данных

```sql
-- Отфильтровать приходные накладные по складу и ответственному сотрудникуу
SELECT * FROM purchase_invoices 
WHERE 1=1
AND storage_id = 3
AND emplyee_id = 2;
```

```sql
-- Поиск накладной по коментарию
SELECT * FROM purchase_invoices 
WHERE 1=1
AND comment LIKE = '%оформлена по заказу%';
```

```sql
-- Поиск номенклатуры по имени
SELECT * FROM nomenclatures 
WHERE 1=1
AND name LIKE 'Бинт стериль%';
```

```sql
-- Поиск номенклатуры по диапазону цены
SELECT * FROM parishes
WHERE 1=1
AND price BETWEEN 1000 AND 1500
AND nomenclature_id = 140;
```

```sql
-- Поиск расходов конкретной номенклатуры в которой за раз списано больше 100 позиций
SELECT * FROM cancelations
WHERE 1=1
AND amount > 100
AND nomenclature_id = 23;
```