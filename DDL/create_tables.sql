CREATE TABLE types (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE specialties (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE units (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE nomenclature_units (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    unit_id INT UNSIGNED NOT NULL,
    nomenclature_id INT UNSIGNED NOT NULL,
    multiplier SMALLINT UNSIGNED NOT NULL,

     CONSTRAINT fk_nomenclature_units_unit
        FOREIGN KEY (unit_id)
        REFERENCES units(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_nomenclature_units_nomenclature
        FOREIGN KEY (nomenclature_id)
        REFERENCES nomenclatures(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE accounting_objects (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE providers (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    inn VARCHAR(12) NOT NULL,
    email VARCHAR(50),
    phone VARCHAR(20)
);

CREATE TABLE companies (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    inn VARCHAR(12) NOT NULL,
    address VARCHAR(255)
);

CREATE TABLE employees (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    birth_date DATE,
    email VARCHAR(50),
    phone VARCHAR(20),
    address VARCHAR(255),
    speciality_id INT UNSIGNED NOT NULL,

    CONSTRAINT fk_employees_speciality
        FOREIGN KEY (speciality_id)
        REFERENCES specialties(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE employees_companies (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    employee_id INT UNSIGNED NOT NULL,

    CONSTRAINT fk_employees_companies_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_employees_companies_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE storages (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    company_id INT UNSIGNED NOT NULL,

     CONSTRAINT fk_storages_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE nomenclatures (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    unit_id INT UNSIGNED NOT NULL,
    type_id INT UNSIGNED NOT NULL,
    spec_id INT UNSIGNED NOT NULL,
    inv_number VARCHAR(100),
    serial_number VARCHAR(100),
    comment TEXT,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    updated_at DATETIME,
    deleted_at DATETIME,

     CONSTRAINT fk_nomenclatures_unit
        FOREIGN KEY (unit_id)
        REFERENCES units(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_nomenclatures_type
        FOREIGN KEY (type_id)
        REFERENCES types(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_nomenclatures_specialty
        FOREIGN KEY (spec_id)
        REFERENCES specialties(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE purchase_invoices (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    doc_number VARCHAR(100) NOT NULL,
    provider_id INT UNSIGNED NOT NULL,
    employee_id INT UNSIGNED NOT NULL,
    company_id INT UNSIGNED NOT NULL,
    storage_id INT UNSIGNED NOT NULL,
    comment TEXT,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    updated_at DATETIME,
    deleted_at DATETIME,

    CONSTRAINT fk_purchase_invoices_provider
        FOREIGN KEY (provider_id)
        REFERENCES providers(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_purchase_invoices_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_purchase_invoices_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_purchase_invoices_storage
        FOREIGN KEY (storage_id)
        REFERENCES storages(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE parishes (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    amount SMALLINT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    vat INT UNSIGNED,
    unit_id INT UNSIGNED NOT NULL,
    manufactured_at DATETIME,
    expires_at DATETIME,
    nomenclature_id INT UNSIGNED NOT NULL,
    purchase_invoice_id INT UNSIGNED NOT NULL,
    comment TEXT,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    updated_at DATETIME,
    deleted_at DATETIME,

    CONSTRAINT fk_parishes_unit
        FOREIGN KEY (unit_id)
        REFERENCES units(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_parishes_nomenclature
        FOREIGN KEY (nomenclature_id)
        REFERENCES nomenclatures(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_parishes_purchase_invoice
        FOREIGN KEY (purchase_invoice_id)
        REFERENCES purchase_invoices(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE expense_invoices (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    doc_number VARCHAR(100) NOT NULL,
    storage_id INT UNSIGNED NOT NULL,
    accounting_object_id INT UNSIGNED NOT NULL,
    comment TEXT,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    updated_at DATETIME,
    deleted_at DATETIME,

    CONSTRAINT fk_expense_invoices_storage
        FOREIGN KEY (storage_id)
        REFERENCES storages(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_expense_invoices_accounting_object
        FOREIGN KEY (accounting_object_id)
        REFERENCES accounting_objects(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE cancellations (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    amount SMALLINT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    manufactured_at DATETIME,
    expires_at DATETIME,
    nomenclature_id INT UNSIGNED NOT NULL,
    expense_invoice_id INT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    updated_at DATETIME,
    deleted_at DATETIME,
    
    CONSTRAINT fk_cancellations_nomenclature
        FOREIGN KEY (nomenclature_id)
        REFERENCES nomenclatures(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_cancellations_expense_invoice
        FOREIGN KEY (expense_invoice_id)
        REFERENCES expense_invoices(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

/**
Таблица для логов

Опсание типов
1 - Создание номенклатуры
2 - Редактирование номенклатуры
3 - Удаление номенклатуры
4 - Восстановление номенклатуры

11 - Создание приходной накладной
12 - Редактирование приходной накладной
13 - Удаление приходной накладной
14 - Восстановление приходной накладной

21 - Создание прихода
22 - Редактирование прихода
23 - Удаление прихода
24 - Восстановление прихода

31 - Создание расходной накладной
32 - Редактирование расходной накладной
33 - Удаление расходной накладной
34 - Восстановление расходной накладной

41 - Создание расхода
42 - Редактирование расхода
43 - Удаление расхода
44 - Восстановление расхода
*/
CREATE TABLE action_logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    atype TINYINT UNSIGNED NOT NULL,
    log TEXT,
    created_at DATETIME NOT NULL DEFAULT NOW()
);