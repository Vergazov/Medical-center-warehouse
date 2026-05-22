-- Создание прихода

CREATE DEFINER=`root`@`%` PROCEDURE `create_parish`(
IN p_amount INT,
IN p_price DECIMAL(10,2),
IN p_vat INT,
IN p_unit_id INT,
IN p_manufactured_at DATETIME,
IN p_expires_at DATETIME,
IN p_nomenclature_id INT,
IN p_purchase_invoice_id INT,
IN p_comment TEXT,
IN p_user_id INT,
OUT created_parish_id INT
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
    
	IF p_unit_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана единица измерения';
	END IF;

	IF p_nomenclature_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана номенклатура';
	END IF;
    
	IF p_purchase_invoice_id IS NULL THEN
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
    
    INSERT INTO parishes(
        amount,
        price,
        vat,
        unit_id,
        manufactured_at,
        expires_at,
        nomenclature_id,
        purchase_invoice_id,
        comment
    )
    VALUES (
        p_amount,
        p_price,
        p_vat,
        p_unit_id,
        p_manufactured_at,
        p_expires_at,
        p_nomenclature_id,
        p_purchase_invoice_id,
        p_comment
    );

    SET created_parish_id = LAST_INSERT_ID();
    
	INSERT INTO action_logs(atype,log) VALUES(21, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' создал приход с id -  ','(',created_parish_id,')' ));

END

-- редактирование прихода

CREATE DEFINER=`root`@`%` PROCEDURE `update_parish`(
IN p_parish_id INT,
IN p_amount SMALLINT,
IN p_price DECIMAL(10,2),
IN p_vat INT,
IN p_unit_id INT,
IN p_manufactured_at DATETIME,
IN p_expires_at DATETIME,
IN p_nomenclature_id INT,
IN p_purchase_invoice_id INT,
IN p_comment TEXT,
IN p_user_id INT
)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_parish_count INT;
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
    
    SELECT COUNT(*) INTO v_parish_count 
    FROM parishes
    WHERE id = p_parish_id AND deleted_at IS NULL;
    
    IF v_parish_count = 0 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Такой записи прихода не существует';
    END IF;
    
    START TRANSACTION;
    
    UPDATE parishes 
    SET
        amount = COALESCE(p_amount, amount),
        price = COALESCE(p_price, price),
        vat = COALESCE(p_vat, vat),
        unit_id = COALESCE(p_unit_id, unit_id),
        manufactured_at = COALESCE(p_manufactured_at, manufactured_at),
        expires_at = COALESCE(p_expires_at, expires_at),
        nomenclature_id = COALESCE(p_nomenclature_id, nomenclature_id),
        purchase_invoice_id = COALESCE(p_purchase_invoice_id, purchase_invoice_id),
        comment = COALESCE(p_comment, comment),
        updated_at = NOW()
    WHERE id = p_parish_id;
    
	INSERT INTO action_logs(atype,log) VALUES(2, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' отредактировал приход c id - ','(',p_parish_id,')' ));

END

-- архивирование прихода

CREATE DEFINER=`root`@`%` PROCEDURE `delete_parish`(IN p_parish_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_parish_count INT;
    
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
    
	IF p_parish_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана приходная накладная';
	END IF;

	SELECT COUNT(*) INTO v_parish_count FROM parishes
    WHERE 1=1
    AND id = p_parish_id
    AND deleted_at IS NULL;
    
    IF v_parish_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такого прихода не существует или он уже архивирован';
	END IF;
    
    START TRANSACTION;
    
    UPDATE parishes
		SET deleted_at =  now()
        WHERE 1=1
        AND parishes.deleted_at IS NULL
        AND parishes.id = p_parish_id;
	
	INSERT INTO action_logs(atype,log) VALUES(23, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал приход с id - ', p_parish_id ));
	
    COMMIT;
END

-- разархивирование прихода

CREATE DEFINER=`root`@`%` PROCEDURE `restore_parish`(IN p_parish_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_parish_count INT;
    
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
    
	IF p_parish_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана приходная накладная';
	END IF;

	SELECT COUNT(*) INTO v_parish_count FROM parishes
    WHERE 1=1
    AND id = p_parish_id
    AND deleted_at IS NOT NULL;
    
    IF v_parish_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такого прихода не существует или он уже разархивирован';
	END IF;
    
    START TRANSACTION;
    
    UPDATE parishes
		SET deleted_at = NULL
        WHERE 1=1
        AND parishes.deleted_at IS NOT NULL
        AND parishes.id = p_parish_id;
	
	INSERT INTO action_logs(atype,log) VALUES(23, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' разархивировал приход с id - ', p_parish_id ));
	
    COMMIT;
END