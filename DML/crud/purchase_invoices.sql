-- Одновременное создание приходной накладной и прихода

CREATE DEFINER=`root`@`%` PROCEDURE `create_purchase_invoice_with_items`(IN p_user_id INT)
BEGIN
    DECLARE v_purchase_invoice_id INT;
    DECLARE v_parish_id INT;
	DECLARE v_parish_ids TEXT DEFAULT NULL;
    
	START TRANSACTION;
    
        call medical_center_warehouse.create_purchase_invoice('ПН-2025-0008', 1, 1, 1, 1, '', 1, v_purchase_invoice_id);
		
        call medical_center_warehouse.create_parish(10, 5, null, 1, null, null, 1, v_purchase_invoice_id,null, 1, v_parish_id);
		call medical_center_warehouse.create_parish(100, 3, null, 1, null, null, 1, v_purchase_invoice_id,null, 1, v_parish_id);  

    COMMIT;
END  

-- Создание приходной накладной

CREATE DEFINER=`root`@`%` PROCEDURE `create_purchase_invoice`(
IN p_doc_number VARCHAR(20),
IN p_provider_id INT,
IN p_employee_id INT ,
IN p_company_id INT,
IN p_storage_id INT,
IN p_comment TEXT,
IN p_user_id INT,
OUT created_invoice_id INT
)
BEGIN

    DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    
    IF p_doc_number IS NULL OR p_doc_number = ''  THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан номер документа';
	END IF;
    
	IF p_provider_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан поставщик';
	END IF;
    
	IF p_employee_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан ответственный сотрудник';
	END IF;

	IF p_company_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана организация';
	END IF;
    
	IF p_storage_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указан склад';
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
    
    INSERT INTO purchase_invoices(
        doc_number,
        provider_id,
        employee_id,
        company_id,
        storage_id,
        comment
    )
    VALUES (
        p_doc_number,
        p_provider_id,
        p_employee_id,
        p_company_id,
        p_storage_id,
        p_comment
    );
    
    SET created_invoice_id = LAST_INSERT_ID();
    
	INSERT INTO action_logs(atype,log) VALUES(11, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' создал приходную накладную с id -  ', '(',created_invoice_id,')' ));

END

-- Редактирование приходной накладной

CREATE DEFINER=`root`@`%` PROCEDURE `update_purchase_invoice`(
IN p_purchase_invoice_id INT,
IN p_doc_number VARCHAR(20),
IN p_provider_id INT,
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
    
    SELECT COUNT(*) INTO v_purcahse_invoice_count FROM purchase_invoices
    WHERE 1=1
    AND id = p_purchase_invoice_id;
    
    IF v_purcahse_invoice_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой приходной накладной не существует';
	END IF;
    
     START TRANSACTION;
    
    UPDATE purchase_invoices 
    SET
		doc_number = COALESCE(p_doc_number, doc_number),
        provider_id = COALESCE(p_provider_id, provider_id),
        employee_id = COALESCE(p_employee_id, employee_id),
        company_id = COALESCE(p_company_id, company_id),
        storage_id = COALESCE(p_storage_id, storage_id),
        comment = COALESCE(p_comment, comment),
        updated_at = NOW()
	WHERE purchase_invoices.id = p_purchase_invoice_id;
            
	INSERT INTO action_logs(atype,log) VALUES(2, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' отредактировал приходную накладную ',' id:(',p_purchase_invoice_id,')' ));
	
    COMMIT;
    
END

-- Архивирование приходной накладной

CREATE DEFINER=`root`@`%` PROCEDURE `delete_purchase_invoice`(IN p_purchase_invoice_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_purchase_invoice_count INT;
    DECLARE v_parish_ids TEXT;
    DECLARE v_now DATETIME;
    
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
    
	IF p_purchase_invoice_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана приходная накладная';
	END IF;

	SELECT COUNT(*) INTO v_purchase_invoice_count FROM purchase_invoices
    WHERE 1=1
    AND id = p_purchase_invoice_id
    AND deleted_at IS NULL;
    
    IF v_purchase_invoice_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует или она уже архивирована';
	END IF;
    
    START TRANSACTION;
    
    SELECT GROUP_CONCAT(id)
	INTO v_parish_ids
	FROM parishes
	WHERE 1=1
    AND purchase_invoice_id = p_purchase_invoice_id
	AND deleted_at IS NULL;
    
    SET v_now = now();
    
	UPDATE purchase_invoices
		SET deleted_at = v_now
		WHERE purchase_invoices.id = p_purchase_invoice_id;
	
    UPDATE parishes
		SET deleted_at = v_now
        WHERE 1=1
        AND parishes.deleted_at IS NULL
        AND parishes.purchase_invoice_id = p_purchase_invoice_id;
	
	INSERT INTO action_logs(atype,log) VALUES(13, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал приходную наккладную с id - ',p_purchase_invoice_id,'. Архивированы приходы с id: ', IFNULL(v_parish_ids, 'нет приходов') ));
	
    COMMIT;
    
END

-- Разархивирование приходной накладной

CREATE DEFINER=`root`@`%` PROCEDURE `restore_purchase_invoice`(IN p_purchase_invoice_id INT, IN p_user_id INT)
BEGIN
	DECLARE v_user_name VARCHAR(100);
    DECLARE v_user_birth_date VARCHAR(100);
    DECLARE v_purchase_invoice_count INT;
    DECLARE v_parish_ids TEXT;
    DECLARE v_now DATETIME;
    DECLARE v_deleted_at_filter DATETIME;
    
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
    
	IF p_purchase_invoice_id IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Не указана приходная накладная';
	END IF;

	SELECT COUNT(*) INTO v_purchase_invoice_count FROM purchase_invoices
    WHERE 1=1
    AND id = p_purchase_invoice_id
    AND deleted_at IS NOT NULL;
    
    IF v_purchase_invoice_count = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Такой номенклатуры не существует или она уже разархивирована';
	END IF;
    
    START TRANSACTION;
    
    SELECT deleted_at INTO v_deleted_at_filter 
    FROM purchase_invoices 
    WHERE 1=1
    AND purchase_invoices.id = p_purchase_invoice_id;
    
    SELECT GROUP_CONCAT(id)
	INTO v_parish_ids
	FROM parishes
	WHERE 1=1
    AND purchase_invoice_id = p_purchase_invoice_id
    AND parishes.deleted_at = v_deleted_at_filter
	AND deleted_at IS NULL;
        
	UPDATE purchase_invoices
		SET deleted_at = NULL
		WHERE purchase_invoices.id = p_purchase_invoice_id;
	
    UPDATE parishes
		SET deleted_at = NULL
        WHERE 1=1
		AND parishes.deleted_at = v_deleted_at_filter
        AND parishes.purchase_invoice_id = p_purchase_invoice_id;
	
	INSERT INTO action_logs(atype,log) VALUES(13, CONCAT('Пользователь ', v_user_name,'(',v_user_birth_date, ')', ' архивировал приходную накладную с id - ',p_purchase_invoice_id,'. архивированы приходы с id: ', IFNULL(v_parish_ids, 'нет приходов') ));
	
    COMMIT;
END