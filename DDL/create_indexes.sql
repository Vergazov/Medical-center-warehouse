USE medical_center_warehouse;

-- Индекс для получения списка айдишников которые будут удалены вместе с накладной для процедур: delete_purchase_invoice, restore_purcase_invoice
ALTER TABLE purchases ADD KEY idx_purchases_invoice_deleted (purchase_invoice_id, deleted_at);

-- Индекс для получения списка айдишников которые будут удалены вместе с накладной для процедур: delete_expense_invoice, restore_expense_invoice
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