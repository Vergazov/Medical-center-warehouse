>хранимая процедура которая будет создавать тестовые данные
use medical_center_warehouse;

INSERT INTO types (name) VALUES 
('Медикаменты'),
('Реактивы'),
('Оборудование'),
('Мебель'),
('Хозтовары'),
('Расходники');

INSERT INTO specialties (name) VALUES 
('хирургия'),
('клиническая лабораторная диагностика'),
('акушерство и гинекология'),
('кардиология'),
('стоматология терапевтическая');
('прочие');

INSERT INTO units (name) VALUES 
('Штуки'),
('Коробка'),
('Упоковка'),
('Кг'),
('Г'),
('Мл'),
('Л');

INSERT INTO accounting_objects (name) VALUES
('Регистратура'),
('Операционная ЛДЦ 1 этаж'),
('Операционная ЛДЦ 2 этаж'),
('Лаборатория'),
('Стоматология'),
('Педиатрия'),
('Гинекология');

INSERT INTO providers (name,inn,email,phone) VALUES 
('Медицинские технологии и решения (МедТехРешение)','7816501234','medteh@mail.ru','84952305748'),
('Фармацевтическая компания «Вита-Мед»','7824506789','vitaMed@mail.ru','8881458569'),
('Поставка медоборудования «Диагност-Сервис»','7832504321','d-servis@mail.ru','223085436974');

INSERT INTO companies (name,inn,address) VALUES 
('Медси','7756789012', 'г. Москва, ул Больничная д 3'),
('Евромед','7745678901', 'г. Москва, ул Больничная д 3 к. 1');

INSERT INTO employees (name,birthDate,email,phone,address,speciality_id) VALUES
('Анна Владимировна Соколова','1985-03-15','г. Москва, ул. Тверская, д. 10, кв. 45','a.sokolova@medclinic.ru','+7(905)123-45-67', 6),
('Игорь Петрович Морозов','1978-11-22','г. Москва, Ленинградский пр-т, д. 56, кв. 123','i.morozov@medclinic.ru','+7(916)789-12-34', 6),
('Елена Андреевна Лебедева','1992-08-07','г. г. Москва, ул. Арбат, д. 25, кв. 8','e.lebedeva@medclinic.ru','+7(909)567-89-01', 6);

INSERT INTO employees_companies (company_id,employee_id) VALUES 
(1,1),
(1,2),
(2,1),
(3,2);

INSERT INTO storages (name,company_id) VALUES 
('Склад Медси',1),
('Склад Евромед',2);


INSERT INTO nomenclatures (name,unit_id,type_id,spec_id,inv_number,serial_number,comment) VALUES 
('Перчатки нитриловые нестерильные размер M, 100 шт/уп', 3, 6, 6, NULL, NULL,'Расходный материал для процедурных кабинетов и осмотров'),
('Маска медицинская одноразовая трехслойная, 50 шт/уп', 3, 6, 6, NULL, NULL,NULL),
('Шприц одноразовый стерильный 5 мл с иглой', 1, 6, 6, NULL, NULL,'Для инъекций и забора лекарственных средств'),
('Тонометр автоматический медицинский', 1, 3, 4,'INV-EQ-0001','SN-TON-240315-001','Оборудование для измерения артериального давления'),
('Кушетка медицинская смотровая', 1, 4, 6, NULL, NULL,NULL);

-- создать после создания nomenclatures
-- 2 -  коробка, 1 - перчатки, 10 сколько в коробке упаковок перчаток у перчаток должно быть несколько упаковок() 
INSERT INTO nomenclature_units (unit_id,nomenclature_id,multiplier) VALUES 
(2,1,10);

-- Создаем приходные накладные
INSERT INTO purchase_invoices (doc_number, provider_id, employee_id, company_id, storage_id, comment) VALUES
('ПН-2025-0001', 1, 1, 1, 1, 'Первичная закупка расходных материалов'),
('ПН-2025-0002', 2, 2, 1, 1, NULL),
('ПН-2025-0003', 3, 1, 2, 2, NULL),
('ПН-2025-0004', 1, 3, 2, 2, 'Поставка оборудования для кабинетов'),
('ПН-2025-0005', 2, 2, 1, 1, NULL);

INSERT INTO parishes (amount, price, unit_id, manufactured_at, expires_at, nomenclature_id, purchase_invoice_id, comment) VALUES
-- ПН-2025-0001
(20, 850.00, 3, '2025-01-10', '2028-01-10', 1, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0001'), NULL),
(15, 420.00, 3, '2025-01-12', '2028-01-12', 2, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0001'), 'Для процедурных и смотровых кабинетов'),

-- ПН-2025-0002
(300, 18.50, 1, '2025-02-01', '2030-02-01', 3, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0002'), NULL),

-- ПН-2025-0003
(2, 4850.00, 1, NULL, NULL, 4, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0003'), NULL),
(1, 14500.00, 1, NULL, NULL, 5, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0003'), 'Для оснащения смотрового кабинета'),

-- ПН-2025-0004
(10, 790.00, 3, '2025-03-05', '2028-03-05', 1, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0004'), NULL),
(8, 390.00, 3, '2025-03-08', '2028-03-08', 2, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0004'), NULL),
(150, 17.90, 1, '2025-03-12', '2030-03-12', 3, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0004'), NULL),

-- ПН-2025-0005
(1, 5100.00, 1, NULL, NULL, 4, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0005'), 'Резервный тонометр'),
(5, 870.00, 3, '2025-04-01', '2028-04-01', 1, (SELECT id FROM purchase_invoices WHERE doc_number = 'ПН-2025-0005'), NULL);

-- Создаем расходные накладные
INSERT INTO expense_invoices
(doc_number, storage_id, accounting_object_id, comment)
VALUES
('РН-2025-0001', 1, 2, NULL),
('РН-2025-0002', 1, 1, 'Передача расходных материалов в регистратуру'),
('РН-2025-0003', 2, 4, NULL);

INSERT INTO cancellations (amount, price, manufactured_at, expires_at, nomenclature_id, expense_invoice_id) VALUES

-- РН-2025-0001
(4, 850.00, '2025-01-10', '2028-01-10', 1, (SELECT id FROM expense_invoices WHERE doc_number = 'РН-2025-0001')),

-- РН-2025-0002
(3, 420.00, '2025-01-12', '2028-01-12', 2, (SELECT id FROM expense_invoices WHERE doc_number = 'РН-2025-0002')),(50, 18.50, '2025-02-01', '2030-02-01', 3,
 (SELECT id FROM expense_invoices WHERE doc_number = 'РН-2025-0002')),

-- РН-2025-0003
(1, 4850.00, NULL, NULL, 4, (SELECT id FROM expense_invoices WHERE doc_number = 'РН-2025-0003')),
(2, 870.00, '2025-04-01', '2028-04-01', 1, (SELECT id FROM expense_invoices WHERE doc_number = 'РН-2025-0003')),
(1, 14500.00, NULL, NULL, 5, (SELECT id FROM expense_invoices WHERE doc_number = 'РН-2025-0003'));