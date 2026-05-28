-- Создание расхода

CREATE DEFINER=`root`@`%` PROCEDURE `create_cancellation`(
IN p_amount INT,
IN p_price DECIMAL(10,2),
IN p_manufactured_at DATETIME,
IN p_expires_at DATETIME,
IN p_nomenclature_id INT,
IN p_expense_invoice_id INT,
IN p_user_id INT,
OUT created_cancellation_id INT
)
BEGIN

	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
        
    IF p_amount IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указано кол-во товара';
	END IF;
    
	IF p_price IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана цена товара';
	END IF;

	IF p_nomenclature_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана номенклатура';
	END IF;
    
	IF p_expense_invoice_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан номер накладной';
	END IF;
    
    IF p_user_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;

    IF v_user_name IS NULL OR v_user_name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
    INSERT INTO cancellations(
        amount,
        price,
        manufactured_at,
        expires_at,
        nomenclature_id,
        expense_invoice_id
    )
    VALUES (
        p_amount,
        p_price,
        p_manufactured_at,
        p_expires_at,
        p_nomenclature_id,
        p_expense_invoice_id
    );
    
    SET created_cancellation_id = LAST_INSERT_ID();
    
	INSERT INTO action_logs(atype,log) VALUES(41, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' создал расход с id -  ','(',created_cancellation_id,')' ));

END

-- Редактирование расхода

CREATE DEFINER=`root`@`%` PROCEDURE `update_cancellation`(
IN p_cancellation_id INT,
IN p_amount INT,
IN p_price DECIMAL(10,2),
IN p_manufactured_at DATETIME,
IN p_expires_at DATETIME,
IN p_nomenclature_id INT,
IN p_expense_invoice_id INT,
IN p_user_id INT
)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_cancellation_count INT;
    DECLARE v_nomenclature_name VARCHAR(255);
    
    IF p_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Не указан пользователь';
    END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
    IF v_user_name IS NULL OR v_user_name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
    SELECT COUNT(*) INTO v_cancellation_count 
    FROM cancellations
    WHERE id = p_cancellation_id AND deleted_at IS NULL;

    IF v_cancellation_count = 0 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Такой записи расхода не существует';
    END IF;
    
    START TRANSACTION;
    
    UPDATE cancellations 
    SET
        amount = COALESCE(p_amount, amount),
        price = COALESCE(p_price, price),
        manufactured_at = COALESCE(p_manufactured_at, manufactured_at),
        expires_at = COALESCE(p_expires_at, expires_at),
        nomenclature_id = COALESCE(p_nomenclature_id, nomenclature_id),
        expense_invoice_id = COALESCE(p_expense_invoice_id, expense_invoice_id),
        updated_at = NOW()
    WHERE id = p_cancellation_id;
    
	INSERT INTO action_logs(atype,log) VALUES(42, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' отредактировал расход c id - ','(',p_cancellation_id,')' ));

END


-- Архивирование расхода

CREATE DEFINER=`root`@`%` PROCEDURE `delete_cancellation`(IN p_cancellation_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_cancellation_count INT;
    
    IF p_user_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
	IF p_cancellation_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан расход';
	END IF;

	SELECT COUNT(*) INTO v_cancellation_count FROM cancellations
    WHERE 1=1
    AND id = p_cancellation_id
    AND deleted_at IS NULL;
    
    IF v_cancellation_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такого расхода не существует или он уже архивирован';
	END IF;
    
    START TRANSACTION;
    
    UPDATE cancellations
		SET deleted_at =  now()
        WHERE 1=1
        AND cancellations.deleted_at IS NULL
        AND cancellations.id = p_cancellation_id;
	
	INSERT INTO action_logs(atype,log) VALUES(43, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал расход с id - ', p_cancellation_id ));
	
    COMMIT;
END

-- Разархивирование расхода

CREATE DEFINER=`root`@`%` PROCEDURE `restore_cancellation`(IN p_cancellation_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_cancellation_count INT;
    
    IF p_user_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
	IF p_cancellation_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан расход';
	END IF;

	SELECT COUNT(*) INTO v_cancellation_count FROM cancellations
    WHERE 1=1
    AND id = p_cancellation_id
    AND deleted_at IS NOT NULL;
    
    IF v_cancellation_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такого расхода не существует или он уже разархивирован';
	END IF;
    
    START TRANSACTION;
    
    UPDATE cancellations
		SET deleted_at = NULL
        WHERE 1=1
        AND cancellations.deleted_at IS NOT NULL
        AND cancellations.id = p_cancellation_id;
	
	INSERT INTO action_logs(atype,log) VALUES(44, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' разархивировал расход с id - ', p_cancellation_id ));
	
    COMMIT;
END