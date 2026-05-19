USE medical_center_warehouse;


DROP TABLE IF EXISTS cancellations;
DROP TABLE IF EXISTS expense_invoices;
DROP TABLE IF EXISTS parishes;
DROP TABLE IF EXISTS purchase_invoices;
DROP TABLE IF EXISTS types;
DROP TABLE IF EXISTS specialties;
DROP TABLE IF EXISTS units;
DROP TABLE IF EXISTS accounting_objects;
DROP TABLE IF EXISTS providers;
DROP TABLE IF EXISTS storage_structures;
DROP TABLE IF EXISTS storages;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS nomenclatures;

CREATE TABLE types (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);
INSERT INTO types (name) VALUES 
('Медикамент'),
('Материал'),
('Техника'),
('Мебель'),
('Инструмент'),
('Расходный материал');

CREATE TABLE specialties (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);
INSERT INTO specialties (name) VALUES 
('Клиническая лабораторная диагностика'),
('Клиническая фармакология'),
('Стоматология терапевтическая'),
('Стоматология хирургическая');

CREATE TABLE units (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);
INSERT INTO units (name) VALUES 
('Штуки'),
('Коробка'),
('Ампула'),
('День'),
('Неделя'),
('Месяц'),
('Год');

CREATE TABLE accounting_objects (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);
INSERT INTO accounting_objects (name) VALUES
    ('Терапевтическое отделение'),
    ('Хирургическое отделение'),
    ('Стоматологический кабинет №3'),
    ('Лаборатория');

CREATE TABLE providers (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    inn VARCHAR(12) NOT NULL
);
INSERT INTO providers (name,inn) VALUES 
('Медицинские технологии и решения (МедТехРешение)','7816501234'),
('Фармацевтическая компания «Вита-Мед»','7824506789'),
('Поставка медоборудования «Диагност-Сервис»','7832504321');

CREATE TABLE companies (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    inn VARCHAR(12) NOT NULL
);
INSERT INTO companies (name,inn) VALUES 
('Медси','7756789012'),
('Евромед','7745678901');

CREATE TABLE employees (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    birthDate DATE,
    address VARCHAR(255),
    email VARCHAR(50),
    phone VARCHAR(20)
);
INSERT INTO employees (name,birthDate,address,email,phone) VALUES
('Анна Владимировна Соколова','1985-03-15','г. Москва, ул. Тверская, д. 10, кв. 45','a.sokolova@medclinic.ru','+7(905)123-45-67'),
('Игорь Петрович Морозов','1978-11-22','г. Москва, Ленинградский пр-т, д. 56, кв. 123','i.morozov@medclinic.ru','+7(916)789-12-34'),
('Елена Андреевна Лебедева','1992-08-07','г. г. Москва, ул. Арбат, д. 25, кв. 8','e.lebedeva@medclinic.ru','+7(909)567-89-01');

CREATE TABLE storages (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    company_id int,

    FOREIGN KEY (company_id) REFERENCES companies(id)
); 
INSERT INTO storages (name,company_id) VALUES 
('Общий',null),
('Медси',1),
('Склад апмулы',1),
('Евромед',2);

CREATE TABLE storage_structures (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    parent_id INT NOT NULL,
    child_id INT  NOT NULL,

    FOREIGN KEY (parent_id) REFERENCES storages(id),
    FOREIGN KEY (child_id) REFERENCES storages(id)
); 
INSERT INTO storage_structures (parent_id,child_id) VALUES
(2,3),
(1,2),
(1,4);

CREATE TABLE nomenclatures (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    type_id INTEGER NOT NULL,
    speciality_id INTEGER NOT NULL,
    main_unit_id INTEGER NOT NULL,
    inv_number VARCHAR(50),
    expiration_date INTEGER,
    expiration_unit_id INTEGER,
    min_balance SMALLINT,
    max_balance SMALLINT,
    comment TEXT
);
INSERT INTO nomenclatures (name,type_id,speciality_id,main_unit_id) VALUES 
('Активированный уголь (таблетки 250 мг, №20)', 1,2,2),
('Салфетки гемостатические с коллагеном (5x5 см)', 5,1,1),
('Стетоскоп (фонендоскоп) двухсторонний', 4,3,1),
('Антисептический лейкопластырь на катушке (5 м × 2.5 см)', 5,4,2),
('Аппарат для измерения артериального давления (тонометр) механический', 3,1,1),
('Кресло гинекологическое с электроприводом', 3,4,1);

CREATE TABLE purchase_invoices (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    document_number VARCHAR(50) NOT NULL,
    date DATETIME NOT NULL,
    provider_id INT NOT NULL,
    employee_id INT NOT NULL,
    company_id INT NOT NULL,
    storage_id INT NOT NULL,
    comment TEXT,

    FOREIGN KEY (provider_id) REFERENCES providers(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (storage_id) REFERENCES storages(id)
);
INSERT INTO purchase_invoices (document_number, date, provider_id, employee_id, company_id, storage_id, comment) VALUES
('ПН-001', '2025-04-01 10:00:00', 1, 1, 1, 2, 'Срочная поставка медикаментов'),
('ПН-002', '2025-04-10 14:30:00', 2, 2, 2, 4, 'Поставка оборудования'),
('ПН-003', '2025-04-15 09:15:00', 3, 3, 1, 2, 'Расходные материалы');

CREATE TABLE parishes (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    amount INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    vat INT,
    manufacture_date DATETIME,
    good_until DATETIME,
    nomenclature_id INT NOT NULL,
    purchase_invoice_id INT NOT NULL,
    comment TEXT,

    FOREIGN KEY (nomenclature_id) REFERENCES nomenclatures(id),
    FOREIGN KEY (purchase_invoice_id) REFERENCES purchase_invoices(id)
);
INSERT INTO parishes (amount, price, vat, manufacture_date, good_until, nomenclature_id, purchase_invoice_id, comment) VALUES
-- Для накладной ПН-001
(100, 50.00, 10, '2025-03-01', '2026-03-01', 1, 1, 'Уголь активированный'),
(50, 150.00, 20, '2025-04-01', '2027-04-01', 4, 1, 'Лейкопластырь'),
-- Для накладной ПН-002
(5, 5000.00, 20, '2025-01-15', '2030-01-15', 3, 2, 'Стетоскопы'),
(2, 150000.00, 20, '2024-10-10', '2035-10-10', 6, 2, 'Кресло гинекологическое'),
-- Для накладной ПН-003
(200, 25.00, 10, '2025-04-01', '2026-04-01', 2, 3, 'Салфетки гемостатические'),
(10, 1200.00, 20, '2024-12-01', '2030-12-01', 5, 3, 'Тонометры');

CREATE TABLE expense_invoices (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    document_number VARCHAR(50),
    date DATETIME NOT NULL,
    accounting_object_id INT,
    storage_id INT NOT NULL,
    comment TEXT,

    FOREIGN KEY (storage_id) REFERENCES storages(id),
    FOREIGN KEY (accounting_object_id) REFERENCES accounting_objects(id)
);
INSERT INTO expense_invoices (document_number, date, accounting_object_id, storage_id, comment) VALUES
('РН-001', '2025-04-05 11:00:00', 1, 2, 'Выдача в отделение терапии'),
('РН-002', '2025-04-12 16:00:00', 2, 2, 'Передача в операционную'),
('РН-003', '2025-04-18 10:30:00', 3, 4, 'Выдача в лабораторию');

CREATE TABLE cancellations (
    id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    amount INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    manufacture_date DATETIME,
    good_until DATETIME,
    nomenclature_id INT NOT NULL,
    expense_invoice_id INT NOT NULL,
    comment TEXT,

    FOREIGN KEY (nomenclature_id) REFERENCES nomenclatures(id),
    FOREIGN KEY (expense_invoice_id) REFERENCES expense_invoices(id)
);
INSERT INTO cancellations (amount, price, manufacture_date, good_until, nomenclature_id, expense_invoice_id, comment) VALUES
-- Для накладной РН-001
(10, 50.00, '2025-03-01', '2026-03-01', 1, 1, 'Списано угля в терапию'),
(5, 150.00, '2025-04-01', '2027-04-01', 4, 1, 'Лейкопластырь в процедурную'),
-- Для накладной РН-002
(2, 5000.00, '2025-01-15', '2030-01-15', 3, 2, 'Стетоскопы в ординаторскую'),
-- Для накладной РН-003
(50, 25.00, '2025-04-01', '2026-04-01', 2, 3, 'Салфетки для лаборатории'),
(1, 1200.00, '2024-12-01', '2030-12-01', 5, 3, 'Тонометр для лаборатории');