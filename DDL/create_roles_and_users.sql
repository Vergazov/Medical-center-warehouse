USE medical_center_warehouse;

CREATE ROLE IF NOT EXISTS 'analyst'; -- разрешаю только запуск аналитики
CREATE ROLE IF NOT EXISTS 'warehouse_manager'; -- разрешаю все, кроме выдачи прав

GRANT EXECUTE ON PROCEDURE medical_center_warehouse.get_storage_balance TO 'analyst';
GRANT EXECUTE ON PROCEDURE medical_center_warehouse.get_expired_items TO 'analyst';
GRANT EXECUTE ON PROCEDURE medical_center_warehouse.get_soon_expired_items TO 'analyst';
GRANT EXECUTE ON PROCEDURE medical_center_warehouse.get_items_movement TO 'analyst';

GRANT ALL PRIVILEGES ON medical_center_warehouse.* TO 'warehouse_manager';

CREATE USER IF NOT EXISTS 'warehouse_manager'@'localhost' IDENTIFIED BY '123';
CREATE USER IF NOT EXISTS 'analyst'@'localhost' IDENTIFIED BY '123';

CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED WITH mysql_native_password BY '123';

GRANT 'warehouse_manager' TO 'warehouse_manager'@'localhost';
GRANT 'analyst' TO 'analyst'@'localhost';

SET DEFAULT ROLE 'warehouse_manager' TO 'warehouse_manager'@'localhost';
SET DEFAULT ROLE 'analyst' TO 'analyst'@'localhost';

GRANT REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO 'repl'@'%';