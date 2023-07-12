CREATE TABLE XXBCM_SUPPLIER_ADDRESS_TBL(
    address_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	Address_line1 VARCHAR(200),
    Address_line2 VARCHAR(200),
    Address_line3 VARCHAR(200),
    Address_line4 VARCHAR(200),
    Address_line5 VARCHAR(200)
);

CREATE TABLE XXBCM_SUPPLIERS_TBL(
    supplier_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	supplier_name VARCHAR(200),
    supplier_contact_name VARCHAR(200),
    supplier_address_id NUMBER,
    supplier_email VARCHAR(200)
);
CREATE TABLE XXBCM_SUPPLIER_CONTACTS_TBL(
    contact_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	supplier_id NUMBER,
    contact_number VARCHAR(200)
);

CREATE TABLE XXBCM_ORDER_HEADERS_TBL(
    order_header_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
    order_ref_number VARCHAR(100),
    order_date DATE,
    order_desc VARCHAR(500),
    order_total_amount NUMBER,
    order_status VARCHAR(100),
    supplier_id NUMBER
);

CREATE TABLE XXBCM_ORDER_LINES_TBL(
	order_ref VARCHAR(100),
	order_header_id NUMBER,
    order_line_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
    order_line_num VARCHAR(100),
    order_line_desc VARCHAR(500),
    order_line_amount NUMBER,
    order_line_status VARCHAR(100)
);
CREATE TABLE XXBCM_INVOICE_HEADERS_TBL(
    invoice_header_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
    invoice_number VARCHAR(100)
);

CREATE TABLE XXBCM_INVOICE_LINES_TBL(
	invoice_header_id NUMBER,
    invoice_line_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	invoice_number NUMBER,
	invoice_reference VARCHAR2(100),
    order_line_id NUMBER,
    invoice_date DATE,
    invoice_desc VARCHAR(500),
    invoice_amount NUMBER,
    invoice_status VARCHAR(100), 
    invoice_hold_id NUMBER
);
CREATE TABLE XXBCM_INVOICE_HOLDS_TBL(
	invoice_hold_id number generated always as identity(start with 1 INCREMENT BY 1)  PRIMARY KEY,
	invoice_hold_reason VARCHAR(200)
    );
ALTER table XXBCM_SUPPLIER_CONTACTS_TBL add CONSTRAINT XXBCM_fk_con_supplier_id FOREIGN KEY(supplier_id) REFERENCES XXBCM_SUPPLIERS_TBL(supplier_id);
ALTER table XXBCM_ORDER_HEADERS_TBL add CONSTRAINT XXBCM_fk_supplier_id FOREIGN KEY(supplier_id) REFERENCES XXBCM_SUPPLIERS_TBL(supplier_id);
ALTER table XXBCM_ORDER_LINES_TBL add CONSTRAINT XXBCM_fk_order_header_id FOREIGN KEY (order_header_id) REFERENCES XXBCM_ORDER_HEADERS_TBL(order_header_id);
ALTER table XXBCM_SUPPLIERS_TBL add CONSTRAINT XXBCM_fk_address_id FOREIGN KEY(supplier_address_id) REFERENCES XXBCM_SUPPLIER_ADDRESS_TBL(address_id);
ALTER table XXBCM_INVOICE_LINES_TBL add CONSTRAINT XXBCM_fk_invoice_header_id FOREIGN KEY (invoice_header_id) REFERENCES XXBCM_INVOICE_HEADERS_TBL(invoice_header_id);
ALTER table XXBCM_INVOICE_LINES_TBL add CONSTRAINT XXBCM_fk_order_line_id FOREIGN KEY (Order_line_id) REFERENCES XXBCM_ORDER_LINES_TBL(Order_line_id);
ALTER table XXBCM_INVOICE_LINES_TBL add CONSTRAINT XXBCM_fk_invoice_hold_id FOREIGN KEY (invoice_hold_id) REFERENCES XXBCM_INVOICE_HOLDS_TBL(invoice_hold_id); 