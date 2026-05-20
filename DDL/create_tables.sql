>добавить внешние ключи

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
    multiplier SMALLINT UNSIGNED NOT NULL
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
    speciality_id INT UNSIGNED NOT NULL
);

CREATE TABLE employees_companies (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    employee_id INT UNSIGNED NOT NULL
);

CREATE TABLE storages (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    company_id INT UNSIGNED NOT NULL
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
    deleted_at DATETIME

    CONSTRAINT fk_nomenclatures_unit
        FOREIGN KEY (unit_id)
        REFERENCES units(id),

    CONSTRAINT fk_nomenclatures_type
        FOREIGN KEY (type_id)
        REFERENCES types(id),

    CONSTRAINT fk_nomenclatures_specialty
        FOREIGN KEY (spec_id)
        REFERENCES specialties(id)
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
    deleted_at DATETIME
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
    deleted_at DATETIME
);

CREATE TABLE expense_invoices (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    doc_number VARCHAR(100) NOT NULL,
    storage_id INT UNSIGNED NOT NULL,
    accounting_object_id INT UNSIGNED NOT NULL,
    comment TEXT,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    updated_at DATETIME,
    deleted_at DATETIME
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
    deleted_at DATETIME
);

-- Таблица для логов
-- Типы логов atype:
-- 1 - Создание номенклатуры
-- 2 - Редактирование номенклатуры
-- 3 - Удаление номенклатуры
-- 11 - Создание приходной накладной
-- 12 - Редактирование приходной накладной
-- 13 - Удаление приходной накладной
-- 21 - Создание номенклатуры
-- 22 - Редактирование номенклатуры
-- 23 - Удаление номенклатуры
CREATE TABLE action_logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    atype TINYINT UNSIGNED NOT NULL,
    log TEXT,
    created_at DATETIME NOT NULL DEFAULT NOW()
);

-- ALTER TABLE nomenclature_units ADD CONSTRAINT fk_nomenclature_units
-- FOREIGN KEY (unit_id)
-- REFERENCES units(id)
-- ON DELETE CASCADE ????
-- ON UPDATE CASCADE; ????