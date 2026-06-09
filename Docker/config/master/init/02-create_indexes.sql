USE medical_center_warehouse;

-- Индекс для получения списка айдишников которые будут удалены вместе с накладной для процедур: delete_purchase, restore_purcase
ALTER TABLE purchases ADD KEY idx_purchases_invoice_deleted (purchase_invoice_id, deleted_at);

-- Индекс для получения списка айдишников которые будут удалены вместе с накладной для процедур: delete_expense, restore_expense
ALTER TABLE expenses ADD KEY idx_expenses_invoice_deleted (expense_invoice_id, deleted_at);

-- Индекс для отчета по просроченной номенклатуре 
ALTER TABLE purchases ADD KEY idx_purchases_deleted_at_expires_at (deleted_at, expires_at);

-- Индекс для отчета по номенклатуре у которой скоро стечет срок годности
ALTER TABLE purchases ADD KEY idx_purchases_expires_at (expires_at);

-- Индексы для отчета по движениям номенклатуры
ALTER TABLE purchases ADD KEY idx_purchases_item_created(item_id, created_at);
ALTER TABLE expenses ADD KEY idx_expenses_item_created(item_id, created_at);

-- Индексы для процедуры get_items
ALTER TABLE items ADD KEY idx_items_deleted(deleted_at);
ALTER TABLE items ADD KEY idx_items_type_id_deleted_at(type_id, deleted_at);

ALTER TABLE items ADD FULLTEXT ft_items_name(name);
ALTER TABLE items ADD FULLTEXT ft_items_comment(comment);

-- Индексы для отчета по остаткам
ALTER TABLE purchases ADD KEY idx_purchases_item_deleted(item_id, deleted_at);
ALTER TABLE expenses ADD KEY idx_expenses_item_deleted (item_id, deleted_at);

'-> Filter: (items.`name` like \'%шприц%\')  (cost=2054 rows=2202) (actual time=0.0243..15.3 rows=333 loops=1)\n
    -> Table scan on items  (cost=2054 rows=19818) (actual time=0.0179..9.05 rows=20005 loops=1)\n'

'-> Filter: (match items.`name` against (\'шприц\'))  (cost=0.35 rows=1) (actual time=0.0183..0.0186 rows=1 loops=1)\n
    -> Full-text index search on items using ft_items_name (name=\'шприц\')  (cost=0.35 rows=1) (actual time=0.0176..0.0178 rows=1 loops=1)\n'


'-> Filter: (items.`comment` like \'%истек срок годности%\')  (cost=2054 rows=2202) (actual time=17.6..17.6 rows=0 loops=1)\n
    -> Table scan on items  (cost=2054 rows=19818) (actual time=0.0277..11.2 rows=20005 loops=1)\n'


'-> Filter: (match items.`comment` against (\'истек срок годности\'))  (cost=0.35 rows=1) (actual time=0.00522..0.00522 rows=0 loops=1)\n
    -> Full-text index search on items using ft_items_comment (comment=\'истек срок годности\')  (cost=0.35 rows=1) (actual time=0.00477..0.00477 rows=0 loops=1)\n'


'-> Filter: ((items.type_id = 5) and (items.deleted_at is null))  (cost=2054 rows=330) (actual time=0.0158..8.97 rows=3332 loops=1)\n
    -> Table scan on items  (cost=2054 rows=19818) (actual time=0.00804..8.17 rows=20005 loops=1)\n'


'-> Index lookup on items using idx_items_type_id_deleted_at (type_id=5, deleted_at=NULL), with index condition: (items.deleted_at is null)  (cost=550 rows=3332) (actual time=0.017..3.54 rows=3332 loops=1)\n'
