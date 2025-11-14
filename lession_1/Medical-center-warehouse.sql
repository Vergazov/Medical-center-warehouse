CREATE TABLE IF NOT EXISTS `nomenclatures` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(255) NOT NULL,
	`type_id` INTEGER NOT NULL,
	`speciality_id` INTEGER NOT NULL,
	`main_unit_id` INTEGER NOT NULL COMMENT 'основная единица измерения',
	`inv_number` VARCHAR(255),
	`expiration_date` SMALLINT,
	`expiration_unit_id` INTEGER NOT NULL COMMENT 'единица измерения срока годности',
	`min_balance` SMALLINT,
	`max_balance` SMALLINT,
	`comment` TEXT(65535),
	PRIMARY KEY(`id`)
);


CREATE INDEX `Nomenclatures_index_0`
ON `nomenclatures` ();
CREATE TABLE IF NOT EXISTS `types` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE TABLE IF NOT EXISTS `specialities` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE TABLE IF NOT EXISTS `units` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE TABLE IF NOT EXISTS `purchase_invoices` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`document_number` VARCHAR(255) NOT NULL,
	`date` DATE NOT NULL,
	`provider_id` INTEGER NOT NULL,
	`employee_id` INTEGER NOT NULL,
	`company_id` INTEGER NOT NULL,
	`storage_id` INTEGER NOT NULL,
	`comment` TEXT(65535),
	PRIMARY KEY(`id`)
);


CREATE INDEX `purchase_invoices_index_0`
ON `purchase_invoices` ();
CREATE TABLE IF NOT EXISTS `parishes` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`amount` INTEGER NOT NULL,
	`price` DOUBLE NOT NULL,
	`vat` INTEGER,
	`manufactire_date` DATE,
	`good_until` DATE,
	`namenclature_id` INTEGER NOT NULL,
	`purchase_invoice_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
) COMMENT='Таблица приходов';


CREATE TABLE IF NOT EXISTS `providers` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(255) NOT NULL,
	`inn` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE INDEX `providers_index_0`
ON `providers` ();
CREATE TABLE IF NOT EXISTS `employees` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(255) NOT NULL,
	`address` VARCHAR(255),
	`email` VARCHAR(255),
	PRIMARY KEY(`id`)
);


CREATE TABLE IF NOT EXISTS `companies` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(255) NOT NULL,
	`inn` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE TABLE IF NOT EXISTS `storages` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(255) NOT NULL,
	`company_id` INTEGER,
	PRIMARY KEY(`id`)
);


CREATE TABLE IF NOT EXISTS `expense_invoices` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`number` VARCHAR(255),
	`date` DATE,
	`storage_id` INTEGER,
	`accounting_object` INTEGER,
	`provider_id` INTEGER NOT NULL,
	`comment` TEXT(65535),
	PRIMARY KEY(`id`)
);


CREATE TABLE IF NOT EXISTS `accounting_object` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`name` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE TABLE IF NOT EXISTS `cancellations` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`amount` INTEGER NOT NULL,
	`price` DOUBLE NOT NULL,
	`manufacture_date` DATE,
	`good_until` DATE,
	`nomenclature_id` INTEGER NOT NULL,
	`expense_invoice_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);


CREATE TABLE IF NOT EXISTS `strorage_structures` (
	`id` INTEGER NOT NULL AUTO_INCREMENT UNIQUE,
	`parent_id` INTEGER NOT NULL,
	`child_id` INTEGER NOT NULL,
	PRIMARY KEY(`id`)
);


ALTER TABLE `nomenclatures`
ADD FOREIGN KEY(`type_id`) REFERENCES `types`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `nomenclatures`
ADD FOREIGN KEY(`speciality_id`) REFERENCES `specialities`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `nomenclatures`
ADD FOREIGN KEY(`main_unit_id`) REFERENCES `units`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `nomenclatures`
ADD FOREIGN KEY(`expiration_unit_id`) REFERENCES `units`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `purchase_invoices`
ADD FOREIGN KEY(`provider_id`) REFERENCES `providers`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `purchase_invoices`
ADD FOREIGN KEY(`employee_id`) REFERENCES `employees`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `purchase_invoices`
ADD FOREIGN KEY(`company_id`) REFERENCES `companies`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `purchase_invoices`
ADD FOREIGN KEY(`storage_id`) REFERENCES `storages`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `storages`
ADD FOREIGN KEY(`company_id`) REFERENCES `companies`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `expense_invoices`
ADD FOREIGN KEY(`accounting_object`) REFERENCES `accounting_object`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `expense_invoices`
ADD FOREIGN KEY(`storage_id`) REFERENCES `storages`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `parishes`
ADD FOREIGN KEY(`purchase_invoice_id`) REFERENCES `purchase_invoices`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `parishes`
ADD FOREIGN KEY(`namenclature_id`) REFERENCES `nomenclatures`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `cancellations`
ADD FOREIGN KEY(`nomenclature_id`) REFERENCES `nomenclatures`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `cancellations`
ADD FOREIGN KEY(`expense_invoice_id`) REFERENCES `expense_invoices`(`id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `storages`
ADD FOREIGN KEY(`id`) REFERENCES `strorage_structures`(`parent_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE `storages`
ADD FOREIGN KEY(`id`) REFERENCES `strorage_structures`(`child_id`)
ON UPDATE NO ACTION ON DELETE NO ACTION;