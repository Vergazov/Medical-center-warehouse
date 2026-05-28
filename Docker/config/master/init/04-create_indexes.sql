USE medical_center_warehouse;

-- Индекс для получения списка айдишников которые будут удалены вместе с накладной для процедур: delete_purchase, restore_purcase
ALTER TABLE purchases ADD KEY idx_purchase_invoice_deleted (purchase_invoice_id, deleted_at);

-- Индекс для получения списка айдишников которые будут удалены вместе с накладной для процедур: delete_expense, restore_expense
ALTER TABLE expenses ADD KEY idx_expense_invoice_deleted (expense_invoice_id, deleted_at);

-- Индекс для отчета по просроченной номенклатуре 
ALTER TABLE purchases ADD KEY idx_deleted_at_expires_at (deleted_at, expires_at);


-- Индексы для процедуры get_items
ALTER TABLE items ADD KEY idx_items_deleted(deleted_at);
ALTER TABLE items ADD KEY idx_items_type_id_deleted_at(type_id, deleted_at);
-- ALTER TABLE items ADD KEY idx_items_spec_id_deleted_at(spec_id, deleted_at); -- разобраться как тут сделать

ALTER TABLE items ADD FULLTEXT ft_items_name(name);
ALTER TABLE items ADD FULLTEXT ft_items_comment(comment);






