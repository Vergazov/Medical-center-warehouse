use medical_center_warehouse;

DELIMITER $$

-- Создать приходную накладную

CREATE DEFINER=`root`@`%` PROCEDURE `create_purchase_invoice`(
    IN p_doc_number VARCHAR(20),
    IN p_vendor_id INT,
    IN p_employee_id INT,
    IN p_company_id INT,
    IN p_storage_id INT,
    IN p_comment TEXT,
    IN p_user_id INT
)
BEGIN

    DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE error_message TEXT;
    DECLARE v_expected_error BOOLEAN DEFAULT FALSE;
    DECLARE employee_works_in_company INT;
    DECLARE v_created_invoice_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1 
			error_message = MESSAGE_TEXT;
        
        ROLLBACK;
        
		IF v_expected_error = TRUE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = error_message;
		ELSE
			INSERT INTO error_logs(log) VALUES(error_message);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Произошла ошибка при выполнении процедуры';
        END IF;
    END;
    
    IF p_doc_number IS NULL OR p_doc_number = ''  THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан номер документа';
	END IF;
    
	IF p_vendor_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан поставщик';
	END IF;
    
	IF p_employee_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан ответственный сотрудник';
	END IF;

	IF p_company_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана организация';
	END IF;
    
	IF p_storage_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан склад';
	END IF;
    
    IF p_user_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;

    IF v_user_name IS NULL OR v_user_name = '' THEN
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
    SELECT COUNT(*) INTO employee_works_in_company 
    FROM employees_companies
    WHERE 1=1
    AND employee_id = p_employee_id
    AND company_id = p_company_id;
    
    IF employee_works_in_company = 0 THEN
		SET v_expected_error = TRUE; 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Этот пользователь не может провести накладную, выберите другую организацию';
	END IF;
    
    START TRANSACTION;
    
    INSERT INTO purchase_invoices(
        doc_number,
        vendor_id,
        employee_id,
        company_id,
        storage_id,
        comment
    )
    VALUES (
        p_doc_number,
        p_vendor_id,
        p_employee_id,
        p_company_id,
        p_storage_id,
        p_comment
    );
    
    SET v_created_invoice_id = LAST_INSERT_ID();
	INSERT INTO action_logs(atype,log) VALUES(11, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' создал приходную накладную с id -  ', '(',v_created_invoice_id,')' ));
	
    COMMIT;

    SELECT 100 AS status;
    
END $$ 

-- Архивировать приходную накладную

CREATE DEFINER=`root`@`%` PROCEDURE `delete_purchase_invoice`(IN p_purchase_invoice_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_purchase_invoice_count INT;
    DECLARE v_purchase_ids TEXT;
    DECLARE v_now DATETIME;
    DECLARE error_message TEXT;
    DECLARE v_expected_error BOOLEAN DEFAULT FALSE;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1 
			error_message = MESSAGE_TEXT;
        
        ROLLBACK;
        
		IF v_expected_error = TRUE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = error_message;
		ELSE
			INSERT INTO error_logs(log) VALUES(error_message);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Произошла ошибка при выполнении процедуры';
        END IF;
    END;
    
	IF p_user_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
	IF p_purchase_invoice_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана приходная накладная';
	END IF;

	SELECT COUNT(*) INTO v_purchase_invoice_count FROM purchase_invoices
    WHERE 1=1
    AND id = p_purchase_invoice_id
    AND deleted_at IS NULL;
    
    IF v_purchase_invoice_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует или она уже архивирована';
	END IF;
    
    START TRANSACTION;
    
    SELECT GROUP_CONCAT(id)
	INTO v_purchase_ids
	FROM purchases
	WHERE 1=1
    AND purchase_invoice_id = p_purchase_invoice_id
	AND deleted_at IS NULL;
    
    SET v_now = now();
    
	UPDATE purchase_invoices
		SET deleted_at = v_now
		WHERE id = p_purchase_invoice_id;
	
    UPDATE purchases
		SET deleted_at = v_now
        WHERE 1=1
		AND purchase_invoice_id = p_purchase_invoice_id
        AND deleted_at IS NULL;
	
	INSERT INTO action_logs(atype,log) VALUES(13, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал приходную наккладную с id - ',p_purchase_invoice_id,'. Архивированы приходы с id: ', IFNULL(v_purchase_ids, 'нет приходов') ));
	
    COMMIT;

    SELECT 100 AS status;
    
END $$ 

-- Восстановить приходную накладную

CREATE DEFINER=`root`@`%` PROCEDURE `restore_purchase_invoice`(IN p_purchase_invoice_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_purchase_invoice_count INT;
    DECLARE v_purchase_ids TEXT;
    DECLARE v_now DATETIME;
    DECLARE v_deleted_at_filter DATETIME;
    DECLARE error_message TEXT;
    DECLARE v_expected_error BOOLEAN DEFAULT FALSE;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1 
			error_message = MESSAGE_TEXT;
        
        ROLLBACK;
        
		IF v_expected_error = TRUE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = error_message;
		ELSE
			INSERT INTO error_logs(log) VALUES(error_message);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Произошла ошибка при выполнении процедуры';
        END IF;
    END;
    
     IF p_user_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
	IF p_purchase_invoice_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана приходная накладная';
	END IF;

	SELECT COUNT(*) INTO v_purchase_invoice_count FROM purchase_invoices
    WHERE 1=1
    AND id = p_purchase_invoice_id
    AND deleted_at IS NOT NULL;
    
    IF v_purchase_invoice_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует или она уже разархивирована';
	END IF;
    
    START TRANSACTION;
    
    -- получить сперва deleted_at из накладной
    -- найти в purchases только те удаленные записи, у которых этот deleted_at совпадает
    -- только их я должен восстановить
    SELECT deleted_at INTO v_deleted_at_filter 
    FROM purchase_invoices 
    WHERE 1=1
    AND purchase_invoices.id = p_purchase_invoice_id;
    
    SELECT GROUP_CONCAT(id)
	INTO v_purchase_ids
	FROM purchases
	WHERE 1=1
    AND purchase_invoice_id = p_purchase_invoice_id
    AND deleted_at = v_deleted_at_filter;
        
	UPDATE purchase_invoices
		SET deleted_at = NULL
		WHERE id = p_purchase_invoice_id;
	
    UPDATE purchases
		SET deleted_at = NULL
        WHERE 1=1
		AND purchase_invoice_id = p_purchase_invoice_id
		AND deleted_at = v_deleted_at_filter;
	
	INSERT INTO action_logs(atype,log) VALUES(14, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал приходную накладную с id - ',p_purchase_invoice_id,'. архивированы приходы с id: ', IFNULL(v_purchase_ids, 'нет приходов') ));
    COMMIT;

    SELECT 100 AS status;
END  $$

-- Обновить приходную накладную

CREATE DEFINER=`root`@`%` PROCEDURE `update_purchase_invoice`(
    IN p_purchase_invoice_id INT,
    IN p_doc_number VARCHAR(20),
    IN p_vendor_id INT,
    IN p_employee_id INT,
    IN p_company_id INT,
    IN p_storage_id INT,
    IN p_comment TEXT,
    IN p_user_id INT
)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
	DECLARE v_purcahse_invoice_count INT;
    DECLARE error_message TEXT;
    DECLARE v_expected_error BOOLEAN DEFAULT FALSE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1 
			error_message = MESSAGE_TEXT;
        
        ROLLBACK;
        
		IF v_expected_error = TRUE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = error_message;
		ELSE
			INSERT INTO error_logs(log) VALUES(error_message);
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Произошла ошибка при выполнении процедуры';
        END IF;
    END;
    
    IF p_user_id IS NULL THEN
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан пользователь';
	END IF;
    
    SELECT name, birth_date
    INTO v_user_name, v_user_birth_date
    FROM employees
    WHERE id = p_user_id
    LIMIT 1;
    
	IF v_user_name IS NULL OR v_user_name = '' THEN
		SET v_expected_error = TRUE;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Пользователь не найден';
    END IF;
    
    SELECT COUNT(*) INTO v_purcahse_invoice_count FROM purchase_invoices
    WHERE 1=1
    AND id = p_purchase_invoice_id;
    
    IF v_purcahse_invoice_count = 0 THEN 
		SET v_expected_error = TRUE;
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой приходной накладной не существует';
	END IF;
    
     START TRANSACTION;
    
    UPDATE purchase_invoices 
    SET
		doc_number = COALESCE(p_doc_number, doc_number),
        vendor_id = COALESCE(p_vendor_id, vendor_id),
        employee_id = COALESCE(p_employee_id, employee_id),
        company_id = COALESCE(p_company_id, company_id),
        storage_id = COALESCE(p_storage_id, storage_id),
        comment = COALESCE(p_comment, comment),
        updated_at = NOW()
	WHERE purchase_invoices.id = p_purchase_invoice_id;
            
	INSERT INTO action_logs(atype,log) VALUES(12, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' отредактировал приходную накладную ',' id:(',p_purchase_invoice_id,')' ));
	
    COMMIT;

    SELECT 100 AS status;
    
END $$

DELIMITER ;