create or replace PACKAGE BODY XXBCM_DATA_MIGRATION_PKG
IS
	--Global Valiables
	gd_sysdate      DATE   := SYSDATE;
	--Global Valiables


	PROCEDURE XXBCM_ADD_SUPPLIER_ADDRESS
	IS
	begin
		for supp_add in (select distinct
		regexp_substr(adds,'[^,]+',1,1) as add1,
		regexp_substr(adds,'[^,]+',1,2) as add2,
		regexp_substr(adds,'[^,]+',1,3) as add3,
		regexp_substr(adds,'[^,]+',1,4) as add4,
		regexp_substr(adds,'[^,]+',1,5) as add5
		from
		(
		select regexp_substr(SUPP_ADDRESS,'[^,]+,[^,]+,[^,]+,[^,]+,[^,]+',1, level) adds from XXBCM_ORDER_MGT
		connect by regexp_substr(SUPP_ADDRESS,'[^,]+,[^,]+,[^,]+,[^,]+,[^,]+',1, level) is not null
		))
		LOOP
			INSERT into XXBCM_SUPPLIER_ADDRESS_TBL (Address_line1,
													Address_line2,
													Address_line3,
													Address_line4,
													Address_line5) 
			VALUES (supp_add.add1,
					supp_add.add2,
					supp_add.add3,
					supp_add.add4,
					supp_add.add5);
		END LOOP;
		COMMIT;
	end XXBCM_ADD_SUPPLIER_ADDRESS;

	PROCEDURE XXBCM_ADD_SUPPLIER
	IS
	begin
		for supp in (
		select distinct SUPPLIER_NAME,
		SUPP_CONTACT_NAME,
		SUPP_EMAIL,
		(select address_id 
		from XXBCM_SUPPLIER_ADDRESS_TBL a
		where replace(x.SUPP_ADDRESS,', ',' ') = a.ADDRESS_LINE1||a.ADDRESS_LINE2||a.ADDRESS_LINE3||a.ADDRESS_LINE4||a.ADDRESS_LINE5) address_id
		from XXBCM_ORDER_MGT x
		)
		LOOP
			INSERT into XXBCM_SUPPLIERS_TBL(supplier_name,
			supplier_contact_name,
			supplier_email,
			supplier_address_id) 
			VALUES (supp.SUPPLIER_NAME,
			supp.SUPP_CONTACT_NAME,
			supp.SUPP_EMAIL,
			supp.address_id);
		END LOOP;
		COMMIT;
	end XXBCM_ADD_SUPPLIER;

	PROCEDURE XXBCM_ADD_SUPPLIER_CONTACT
	IS
	begin
		for supp_con in (select distinct 
		replace(replace(replace(replace(trim(regexp_substr(SUPP_CONTACT_NUMBER,'[^,]+',1,level)),'S','5'),'o','0'),'I','1'),'.','') CONTACT_NUMBER
		,(select supplier_id from XXBCM_SUPPLIERS_TBL 
		where SUPPLIER_NAME = x.SUPPLIER_NAME
		and supplier_contact_name =x.SUPP_CONTACT_NAME) supplier_id
		from XXBCM_ORDER_MGT x
		connect by regexp_substr(SUPP_CONTACT_NUMBER,'[^,]+',1,level) is not null)
		LOOP
			INSERT into XXBCM_SUPPLIER_CONTACTS_TBL (supplier_id,
												 contact_number) 
			VALUES (supp_con.supplier_id,
					supp_con.CONTACT_NUMBER);
		END LOOP;
		COMMIT;
	end XXBCM_ADD_SUPPLIER_CONTACT;

	PROCEDURE XXBCM_ADD_ORDER_HEADERS
	IS
	begin
		for odr in (select distinct 
		ORDER_REF
		--,ORDER_DATE
		,to_date(ORDER_DATE,'DD-MM-YYYY') ORDER_DATE
		,ORDER_DESCRIPTION
		,to_number(replace(ORDER_TOTAL_AMOUNT,',','')) ORDER_TOTAL_AMOUNT
		,ORDER_STATUS
		,(select supplier_id from XXBCM_SUPPLIERS_TBL s
		where s.supplier_name = x.SUPPLIER_NAME) supplier_id 
		from XXBCM_ORDER_MGT x
		where ORDER_REF  not like '%-%'
		order by ORDER_REF)
		LOOP
			INSERT into XXBCM_ORDER_HEADERS_TBL (order_ref_number,
										  order_date,
										  order_desc,
										  order_total_amount,
										  order_status,
										  supplier_id) 
			VALUES (odr.ORDER_REF,
			        odr.ORDER_DATE,
					odr.ORDER_DESCRIPTION,
					odr.ORDER_TOTAL_AMOUNT,
					odr.ORDER_STATUS,
					odr.supplier_id);
		END LOOP;
		COMMIT;
	end XXBCM_ADD_ORDER_HEADERS;

	PROCEDURE XXBCM_ADD_ORDER_LINES
	IS
	begin
		for odrl in (select distinct ORDER_REF,
		(select order_header_id from XXBCM_ORDER_HEADERS_TBL where order_ref_number = substr(x.ORDER_REF,1,instr(x.ORDER_REF,'-',1)-1)) order_header_id,
		 row_number() over (partition by substr(ORDER_REF,1,instr(ORDER_REF,'-',1)-1) order by order_ref) ln_num,
		 ORDER_DESCRIPTION,
		 replace(replace(replace(replace(ORDER_LINE_AMOUNT,',',''),'I','1'),'S','5'),'o','0') ORDER_LINE_AMOUNT,
		 ORDER_STATUS
		from XXBCM_ORDER_MGT x
		where ORDER_REF like '%-%'
		order by ORDER_REF)
		LOOP
			INSERT into XXBCM_ORDER_LINES_TBL (order_ref,
											  order_header_id,
											  order_line_num,
											  order_line_desc,
											  order_line_amount,
											  order_line_status) 
			VALUES (odrl.ORDER_REF,
					odrl.order_header_id,
					odrl.ln_num,
					odrl.ORDER_DESCRIPTION,
					odrl.ORDER_LINE_AMOUNT,
					odrl.ORDER_STATUS);
		END LOOP;
		COMMIT;
	end XXBCM_ADD_ORDER_LINES;

	PROCEDURE XXBCM_ADD_INVOICE_HOLDS
	IS
	begin
		for inv_hold in (SELECT distinct INVOICE_HOLD_REASON 
						 from XXBCM_ORDER_MGT 
		                 where INVOICE_HOLD_REASON is not null)
		LOOP
			INSERT into XXBCM_INVOICE_HOLDS_TBL (invoice_hold_reason) 
			VALUES (inv_hold.invoice_hold_reason);
		END LOOP;
		COMMIT;
	end XXBCM_ADD_INVOICE_HOLDS;

	PROCEDURE XXBCM_ADD_INVOICE_HEADERS
	IS
	begin
		for invh in (select distinct a.inv from (
		select INVOICE_REFERENCE,
		substr(x.INVOICE_REFERENCE,1,instr(x.INVOICE_REFERENCE,'.',1)-1) INV
		from XXBCM_ORDER_MGT x) a
		where a.inv is not null
		order by a.inv)
		LOOP
			INSERT into XXBCM_INVOICE_HEADERS_TBL (invoice_number) 
			VALUES (invh.inv);
		END LOOP;
		COMMIT;
	end XXBCM_ADD_INVOICE_HEADERS;

	PROCEDURE XXBCM_ADD_INVOICE_LINES
	IS
	begin
		for invl in (select distinct 
		INVOICE_REFERENCE
		,(select invoice_header_id from XXBCM_INVOICE_HEADERS_TBL
		where invoice_number = substr(x.INVOICE_REFERENCE,1,instr(x.INVOICE_REFERENCE,'.',1)-1)) invoice_header_id
		,row_number() over (partition by substr(INVOICE_REFERENCE,1,instr(INVOICE_REFERENCE,'.',1)-1) order by INVOICE_REFERENCE) inv_num
		,odr.order_line_id
		,to_date(INVOICE_DATE,'DD-MM-YYYY') INVOICE_DATE
		,INVOICE_DESCRIPTION
		,replace(replace(replace(replace(INVOICE_AMOUNT,',',''),'I','1'),'S','5'),'o','0') INVOICE_AMOUNT
		,INVOICE_STATUS
		,(select invoice_hold_id from XXBCM_INVOICE_HOLDS_TBL where INVOICE_HOLD_REASON = x.INVOICE_HOLD_REASON) invoice_hold_id
		from XXBCM_ORDER_MGT x
		,XXBCM_ORDER_LINES_TBL odr
		where INVOICE_REFERENCE like '%.%'
		and odr.order_ref = x.order_ref
		and odr.order_line_desc = x.ORDER_DESCRIPTION
		order by INVOICE_REFERENCE)
		LOOP
			INSERT into XXBCM_INVOICE_LINES_TBL (invoice_reference,
												 invoice_header_id,
												 invoice_number,
												 order_line_id,
												 invoice_date,
												 invoice_desc,
												 invoice_amount,
												 invoice_status,
												 invoice_hold_id) 
			VALUES (invl.INVOICE_REFERENCE,
					invl.invoice_header_id,
					invl.inv_num,
					invl.order_line_id,
					invl.INVOICE_DATE,
					invl.INVOICE_DESCRIPTION,
					invl.INVOICE_AMOUNT,
					invl.INVOICE_STATUS,
					invl.invoice_hold_id);
		END LOOP;
		COMMIT;
	end XXBCM_ADD_INVOICE_LINES;

END XXBCM_DATA_MIGRATION_PKG;
