-- public."Customer" definition

-- Drop table

-- DROP TABLE public."Customer";

CREATE TABLE public."Customer" (
	"CID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"CustomerType_ID" int4 NULL,
	"Occupation_ID" int4 NULL,
	"Sub_Occ_ID" int4 NULL,
	"Occupation_Remark" varchar(255) NULL,
	"CS_CardID" varchar(255) NULL,
	"CS_PASSPORT_NO" varchar(255) NULL,
	"Passport_Country_ID" varchar(10) NULL,
	"Flag_Juristic" bool NULL,
	"Branch_Code" varchar(50) NULL,
	"Branch_Name" varchar(255) NULL,
	"CS_Authorized_Person_TH" varchar(255) NULL,
	"CS_Authorized_Person_EN" varchar(255) NULL,
	"MarriageStatus" varchar(2) NULL,
	"CS_Prefix" varchar(50) NULL,
	"CS_FName" varchar(255) NULL,
	"CS_LName" varchar(255) NULL,
	"CS_Prefix_EN" varchar(50) NULL,
	"CS_FName_EN" varchar(255) NULL,
	"CS_LName_EN" varchar(255) NULL,
	"CS_BirthDate" date NULL,
	"CS_Sex" varchar(10) NULL,
	"CS_Nationality" varchar(50) NULL,
	"CS_Race" varchar(4) NULL,
	"Customer_Note" text NULL,
	"Language" varchar(50) NULL,
	"Income" numeric(15) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	"Migration_Time" int4 NULL,
	"Spam_Type" varchar(255) NULL,
	"Segment" varchar(255) NULL,
	"Sub_Segment" varchar(255) NULL,
	bank_customer_id varchar(255) NULL,
	"Segment_OLM" varchar(255) NULL,
	card_brand varchar(50) NULL,
	card_number varchar(50) NULL,
	card_expired varchar(50) NULL,
	card_id varchar(100) NULL,
	card_name varchar(255) NULL,
	lux_bank_customer_id varchar(255) NULL,
	CONSTRAINT "Customer_CID_key" UNIQUE ("CID"),
	CONSTRAINT "Customer_pkey" PRIMARY KEY ("CID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer" before delete on
public."Customer" for each row execute function "Archived_Customer"();
create trigger set_nb_customer_id before insert on
public."Customer" for each row execute function generate_nb_customer_id();
create trigger trigger_format_timestamp before insert
or update on
public."Customer" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Address" definition

-- Drop table

-- DROP TABLE public."Customer_Address";

CREATE TABLE public."Customer_Address" (
	"CAID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"AddrType" varchar(255) NULL,
	"AddrName" varchar(255) NULL,
	"AddrBuilding" varchar(255) NULL,
	"AddrNumber" varchar(255) NULL,
	"AddrMoo" varchar(255) NULL,
	"AddrSoi" varchar(255) NULL,
	"AddrRoad" varchar(255) NULL,
	"AddrTumbonID" int4 NULL,
	"AddrAmperID" int4 NULL,
	"AddrProvinceID" int4 NULL,
	"AddrZipID" varchar(255) NULL,
	"AddrCountryID" int4 NULL,
	"AddrName_EN" varchar(255) NULL,
	"AddrBuilding_EN" varchar(255) NULL,
	"AddrNumber_EN" varchar(255) NULL,
	"AddrMoo_EN" varchar(255) NULL,
	"AddrSoi_EN" varchar(255) NULL,
	"AddrRoad_EN" varchar(255) NULL,
	"AddrTumbon_TH" varchar(255) NULL,
	"AddrAmper_TH" varchar(255) NULL,
	"AddrProvince_TH" varchar(255) NULL,
	"AddrCountry_TH" varchar(255) NULL,
	"AddrTumbon_EN" varchar(255) NULL,
	"AddrAmper_EN" varchar(255) NULL,
	"AddrProvince_EN" varchar(255) NULL,
	"AddrCountry_EN" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Address_CAID_key" UNIQUE ("CAID"),
	CONSTRAINT "Customer_Address_pkey" PRIMARY KEY ("CAID")
);
CREATE INDEX customer_address_nb_customer_id_idx ON public."Customer_Address" USING btree ("NB_Customer_ID");

-- Table Triggers

create trigger "Trigger_Archived_Customer_Address" before delete on
public."Customer_Address" for each row execute function "Archived_Customer_Address"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Address" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Company" definition

-- Drop table

-- DROP TABLE public."Customer_Company";

CREATE TABLE public."Customer_Company" (
	"Customer_Company_ID" serial4 NOT NULL,
	"Company_ID" int4 NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"Role" varchar(255) NULL,
	"Authorize_Flag" bool NULL,
	"Authorize_Priority" int4 NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Company_Customer_Company_ID_key" UNIQUE ("Customer_Company_ID"),
	CONSTRAINT "Customer_Company_pkey" PRIMARY KEY ("Customer_Company_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Company" before delete on
public."Customer_Company" for each row execute function "Archived_Customer_Company"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Company" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_CustomerDB" definition

-- Drop table

-- DROP TABLE public."Customer_CustomerDB";

CREATE TABLE public."Customer_CustomerDB" (
	"CDBID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"Segment" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_CustomerDB_CDBID_key" UNIQUE ("CDBID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_CustomerDB" before delete on
public."Customer_CustomerDB" for each row execute function "Archived_Customer_CustomerDB"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_CustomerDB" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Detail" definition

-- Drop table

-- DROP TABLE public."Customer_Detail";

CREATE TABLE public."Customer_Detail" (
	"Customer_Detail_ID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"PD_CODE" varchar(255) NULL,
	"PD_RUNNO" int4 NULL,
	"Segment" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Detail_Customer_Detail_ID_key" UNIQUE ("Customer_Detail_ID"),
	CONSTRAINT "Customer_Detail_pkey" PRIMARY KEY ("Customer_Detail_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Detail" before delete on
public."Customer_Detail" for each row execute function "Archived_Customer_Detail"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Detail" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Email" definition

-- Drop table

-- DROP TABLE public."Customer_Email";

CREATE TABLE public."Customer_Email" (
	"CEID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"Email" varchar(255) NULL,
	"Priority" int4 NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Email_CEID_key" UNIQUE ("CEID"),
	CONSTRAINT "Customer_Email_pkey" PRIMARY KEY ("CEID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Email" before delete on
public."Customer_Email" for each row execute function "Archived_Customer_Email"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Email" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Key" definition

-- Drop table

-- DROP TABLE public."Customer_Key";

CREATE TABLE public."Customer_Key" (
	"CL_Key_ID" int4 NOT NULL,
	"CL_Key" varchar(255) NULL,
	"CL_Desc" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Key_pkey" PRIMARY KEY ("CL_Key_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Key" before delete on
public."Customer_Key" for each row execute function "Archived_Customer_Key"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Key" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Lifestyle" definition

-- Drop table

-- DROP TABLE public."Customer_Lifestyle";

CREATE TABLE public."Customer_Lifestyle" (
	"Customer_Lifestyle_ID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"CL_Key" varchar(255) NULL,
	"CL_Value" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Lifestyle_Customer_Lifestyle_ID_key" UNIQUE ("Customer_Lifestyle_ID"),
	CONSTRAINT "Customer_Lifestyle_pkey" PRIMARY KEY ("Customer_Lifestyle_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Lifestyle" before delete on
public."Customer_Lifestyle" for each row execute function "Archived_Customer_Lifestyle"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Lifestyle" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Phone" definition

-- Drop table

-- DROP TABLE public."Customer_Phone";

CREATE TABLE public."Customer_Phone" (
	"CPID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"Phone" varchar(50) NULL,
	"CountryCode" varchar(10) NULL,
	"DialCode" varchar(10) NULL,
	"PhoneExt" varchar(10) NULL,
	"Mobile_SMS_Allow" bool NULL,
	"Priority" int4 NULL,
	"Flag_Verify" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Phone_CPID_key" UNIQUE ("CPID"),
	CONSTRAINT "Customer_Phone_pkey" PRIMARY KEY ("CPID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Phone" before delete on
public."Customer_Phone" for each row execute function "Archived_Customer_Phone"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Phone" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Project" definition

-- Drop table

-- DROP TABLE public."Customer_Project";

CREATE TABLE public."Customer_Project" (
	"CPJID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"PJ_CODE" varchar(255) NULL,
	"Segment" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Project_CPJID_key" UNIQUE ("CPJID"),
	CONSTRAINT "Customer_Project_pkey" PRIMARY KEY ("CPJID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Project" before delete on
public."Customer_Project" for each row execute function "Archived_Customer_Project"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Project" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Project_20240912" definition

-- Drop table

-- DROP TABLE public."Customer_Project_20240912";

CREATE TABLE public."Customer_Project_20240912" (
	"CPJID" int4 NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"PJ_CODE" varchar(255) NULL,
	"Segment" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL
);


-- public."Customer_Project_NEW" definition

-- Drop table

-- DROP TABLE public."Customer_Project_NEW";

CREATE TABLE public."Customer_Project_NEW" (
	"CPJID" int4 NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"PJ_CODE" varchar(255) NULL,
	"Segment" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	customerdb varchar(8) NULL,
	updatge_date timestamp NOT NULL
);


-- public."Customer_Relation" definition

-- Drop table

-- DROP TABLE public."Customer_Relation";

CREATE TABLE public."Customer_Relation" (
	"CRID" serial4 NOT NULL,
	"Rel_Customer_ID" varchar(20) NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"Relation_Type" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Relation_CRID_key" UNIQUE ("CRID"),
	CONSTRAINT "Customer_Relation_pkey" PRIMARY KEY ("CRID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Relation" before delete on
public."Customer_Relation" for each row execute function "Archived_Customer_Relation"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Relation" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Social" definition

-- Drop table

-- DROP TABLE public."Customer_Social";

CREATE TABLE public."Customer_Social" (
	"CSCID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"Name" varchar(255) NULL,
	"Provider" varchar(255) NULL,
	"Social_ID" varchar(255) NULL,
	"Social_Display_Name" varchar(255) NULL,
	"Social_Display_Image" text NULL,
	"Social_URL" varchar(255) NULL,
	"Priority" int4 NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	"Flag_PP_Customer" bool NULL,
	"Flag_Migrate" int4 NULL,
	CONSTRAINT "Customer_Social_CSCID_key" UNIQUE ("CSCID"),
	CONSTRAINT "Customer_Social_pkey" PRIMARY KEY ("CSCID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Social" before delete on
public."Customer_Social" for each row execute function "Archived_Customer_Social"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Social" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_System" definition

-- Drop table

-- DROP TABLE public."Customer_System";

CREATE TABLE public."Customer_System" (
	"CSID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"System_ID" int4 NULL,
	"Sys_Customer_ID" int4 NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_System_CSID_key" UNIQUE ("CSID"),
	CONSTRAINT "Customer_System_pkey" PRIMARY KEY ("CSID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_System" before delete on
public."Customer_System" for each row execute function "Archived_Customer_System"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_System" for each row execute function format_update_date_to_wh_update_date();


-- public."Customer_Unit" definition

-- Drop table

-- DROP TABLE public."Customer_Unit";

CREATE TABLE public."Customer_Unit" (
	"Customer_Unit_ID" serial4 NOT NULL,
	"NB_Customer_ID" varchar(20) NULL,
	"PD_CODE" varchar(255) NULL,
	"PD_RUNNO" int4 NULL,
	"CT" varchar(255) NULL,
	"Segment" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Customer_Unit_Customer_Unit_ID_key" UNIQUE ("Customer_Unit_ID"),
	CONSTRAINT "Customer_Unit_pkey" PRIMARY KEY ("Customer_Unit_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_Customer_Unit" before delete on
public."Customer_Unit" for each row execute function "Archived_Customer_Unit"();
create trigger trigger_format_timestamp before insert
or update on
public."Customer_Unit" for each row execute function format_update_date_to_wh_update_date();


-- public."Event_Generate_QR_Checkin_Task" definition

-- Drop table

-- DROP TABLE public."Event_Generate_QR_Checkin_Task";

CREATE TABLE public."Event_Generate_QR_Checkin_Task" (
	"Event_ID" serial4 NOT NULL,
	"Customer_ID" int4 NOT NULL,
	"Promotion_ID" int4 NOT NULL,
	"PJ_CODE" int4 NOT NULL,
	"Create_Date" timestamp NOT NULL,
	"Create_By" varchar(255) NOT NULL,
	"Update_Date" timestamp NOT NULL,
	"Update_By" varchar(255) NOT NULL,
	CONSTRAINT "Event_Generate_QR_Checkin_Task_Event_ID_key" UNIQUE ("Event_ID")
);


-- public."PP_Company" definition

-- Drop table

-- DROP TABLE public."PP_Company";

CREATE TABLE public."PP_Company" (
	"Company_ID" serial4 NOT NULL,
	"Address_ID" int4 NULL,
	"Industry_ID" int4 NULL,
	"Name" varchar(255) NULL,
	"Type" varchar(255) NULL,
	"Tax_ID" varchar(255) NULL,
	"Tax_Address" varchar(255) NULL,
	"Contact_Address" varchar(255) NULL,
	"Commercial_ID" varchar(255) NULL,
	"Commercial_Type" varchar(255) NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "PP_Company_Company_ID_key" UNIQUE ("Company_ID"),
	CONSTRAINT "PP_Company_pkey" PRIMARY KEY ("Company_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_PP_Company" before delete on
public."PP_Company" for each row execute function "Archived_PP_Company"();
create trigger trigger_format_timestamp before insert
or update on
public."PP_Company" for each row execute function format_update_date_to_wh_update_date();


-- public."PP_Company_Industry" definition

-- Drop table

-- DROP TABLE public."PP_Company_Industry";

CREATE TABLE public."PP_Company_Industry" (
	"Industry_ID" serial4 NOT NULL,
	"Name" varchar(255) NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "PP_Company_Industry_Industry_ID_key" UNIQUE ("Industry_ID"),
	CONSTRAINT "PP_Company_Industry_pkey" PRIMARY KEY ("Industry_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_PP_Company_Industry" before delete on
public."PP_Company_Industry" for each row execute function "Archived_PP_Company_Industry"();
create trigger trigger_format_timestamp before insert
or update on
public."PP_Company_Industry" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Country" definition

-- Drop table

-- DROP TABLE public."SY_Country";

CREATE TABLE public."SY_Country" (
	"Country_ID" serial4 NOT NULL,
	"CY_CODE" varchar(10) NULL,
	"CY_NAME" varchar(255) NULL,
	"CY_ENAME" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Country_Country_ID_key" UNIQUE ("Country_ID"),
	CONSTRAINT "SY_Country_pkey" PRIMARY KEY ("Country_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Country" before delete on
public."SY_Country" for each row execute function "Archived_SY_Country"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Country" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Customer_Type" definition

-- Drop table

-- DROP TABLE public."SY_Customer_Type";

CREATE TABLE public."SY_Customer_Type" (
	"CustomerType_ID" serial4 NOT NULL,
	"CustomerType_Name" varchar(255) NULL,
	"CustomerType_Color" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Customer_Type_CustomerType_ID_key" UNIQUE ("CustomerType_ID"),
	CONSTRAINT "SY_Customer_Type_pkey" PRIMARY KEY ("CustomerType_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Customer_Type" before delete on
public."SY_Customer_Type" for each row execute function "Archived_SY_Customer_Type"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Customer_Type" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_District" definition

-- Drop table

-- DROP TABLE public."SY_District";

CREATE TABLE public."SY_District" (
	"District_ID" serial4 NOT NULL,
	"PV_CODE" varchar(255) NULL,
	"DT_CODE" varchar(255) NULL,
	"DT_TNAME" varchar(255) NULL,
	"DT_ENAME" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_District_District_ID_key" UNIQUE ("District_ID"),
	CONSTRAINT "SY_District_pkey" PRIMARY KEY ("District_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_District" before delete on
public."SY_District" for each row execute function "Archived_SY_District"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_District" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Income" definition

-- Drop table

-- DROP TABLE public."SY_Income";

CREATE TABLE public."SY_Income" (
	"Income_ID" serial4 NOT NULL,
	"Income" varchar(255) NULL,
	"Income_EN" varchar(255) NULL,
	"Flag_Active" bool NULL,
	"Sort_No" int4 NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Income_Income_ID_key" UNIQUE ("Income_ID"),
	CONSTRAINT "SY_Income_pkey" PRIMARY KEY ("Income_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Income" before delete on
public."SY_Income" for each row execute function "Archived_SY_Income"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Income" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Language" definition

-- Drop table

-- DROP TABLE public."SY_Language";

CREATE TABLE public."SY_Language" (
	"LG_ID" serial4 NOT NULL,
	"LG_CODE" varchar(5) NULL,
	"LG_TNAME" varchar(60) NULL,
	"LG_ENAME" varchar(60) NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Language_LG_ID_key" UNIQUE ("LG_ID"),
	CONSTRAINT "SY_Language_pkey" PRIMARY KEY ("LG_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Language" before delete on
public."SY_Language" for each row execute function "Archived_SY_Language"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Language" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Marriage_Status" definition

-- Drop table

-- DROP TABLE public."SY_Marriage_Status";

CREATE TABLE public."SY_Marriage_Status" (
	"MS_ID" serial4 NOT NULL,
	"MS_CODE" varchar(5) NULL,
	"MS_TNAME" varchar(60) NULL,
	"MS_ENAME" varchar(60) NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Marriage_Status_MS_ID_key" UNIQUE ("MS_ID"),
	CONSTRAINT "SY_Marriage_Status_pkey" PRIMARY KEY ("MS_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Marriage_Status" before delete on
public."SY_Marriage_Status" for each row execute function "Archived_SY_Marriage_Status"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Marriage_Status" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Nationality" definition

-- Drop table

-- DROP TABLE public."SY_Nationality";

CREATE TABLE public."SY_Nationality" (
	"Nation_ID" serial4 NOT NULL,
	"NT_CODE" varchar(255) NULL,
	"NT_NAME" varchar(255) NULL,
	"NT_ENAME" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Nationality_Nation_ID_key" UNIQUE ("Nation_ID"),
	CONSTRAINT "SY_Nationality_pkey" PRIMARY KEY ("Nation_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Nationality" before delete on
public."SY_Nationality" for each row execute function "Archived_SY_Nationality"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Nationality" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Occupation" definition

-- Drop table

-- DROP TABLE public."SY_Occupation";

CREATE TABLE public."SY_Occupation" (
	"Occupation_ID" serial4 NOT NULL,
	"Occupation_Name_TH" varchar(255) NULL,
	"Occupation_Name_EN" varchar(255) NULL,
	"Specify_Detail" bool NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Occupation_Occupation_ID_key" UNIQUE ("Occupation_ID"),
	CONSTRAINT "SY_Occupation_pkey" PRIMARY KEY ("Occupation_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Occupation" before delete on
public."SY_Occupation" for each row execute function "Archived_SY_Occupation"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Occupation" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Occupation_Relate" definition

-- Drop table

-- DROP TABLE public."SY_Occupation_Relate";

CREATE TABLE public."SY_Occupation_Relate" (
	"OCRID" serial4 NOT NULL,
	"Occupation_ID" int4 NULL,
	"Sub_Occ_ID" int4 NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Occupation_Relate_OCRID_key" UNIQUE ("OCRID"),
	CONSTRAINT "SY_Occupation_Relate_pkey" PRIMARY KEY ("OCRID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Occupation_Relate" before delete on
public."SY_Occupation_Relate" for each row execute function "Archived_SY_Occupation_Relate"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Occupation_Relate" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Prefix" definition

-- Drop table

-- DROP TABLE public."SY_Prefix";

CREATE TABLE public."SY_Prefix" (
	"Prefix_ID" serial4 NOT NULL,
	"PN_CODE" varchar(255) NULL,
	"PN_NAME" varchar(255) NULL,
	"PN_ENAME" varchar(255) NULL,
	"PN_TYPE" varchar(255) NULL,
	"PN_LANG" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Prefix_Prefix_ID_key" UNIQUE ("Prefix_ID"),
	CONSTRAINT "SY_Prefix_pkey" PRIMARY KEY ("Prefix_ID")
);

-- Table Triggers

create trigger trigger_format_timestamp before insert
or update on
public."SY_Prefix" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Project" definition

-- Drop table

-- DROP TABLE public."SY_Project";

CREATE TABLE public."SY_Project" (
	"PJ_ID" serial4 NOT NULL,
	"PJ_CODE" varchar(5) NULL,
	"PJ_TNAME" varchar(60) NULL,
	"PJ_ENAME" varchar(60) NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Project_PJ_ID_key" UNIQUE ("PJ_ID"),
	CONSTRAINT "SY_Project_pkey" PRIMARY KEY ("PJ_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Project" before delete on
public."SY_Project" for each row execute function "Archived_SY_Project"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Project" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Province" definition

-- Drop table

-- DROP TABLE public."SY_Province";

CREATE TABLE public."SY_Province" (
	"Province_ID" serial4 NOT NULL,
	"CY_CODE" varchar(255) NULL,
	"PV_CODE" varchar(255) NULL,
	"PV_TNAME" varchar(255) NULL,
	"PV_ENAME" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Province_Province_ID_key" UNIQUE ("Province_ID"),
	CONSTRAINT "SY_Province_pkey" PRIMARY KEY ("Province_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Province" before delete on
public."SY_Province" for each row execute function "Archived_SY_Province"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Province" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Race" definition

-- Drop table

-- DROP TABLE public."SY_Race";

CREATE TABLE public."SY_Race" (
	"RA_ID" serial4 NOT NULL,
	"RA_CODE" varchar(255) NULL,
	"RA_NAME" varchar(255) NULL,
	"RA_ENAME" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Race_RA_ID_key" UNIQUE ("RA_ID"),
	CONSTRAINT "SY_Race_pkey" PRIMARY KEY ("RA_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Race" before delete on
public."SY_Race" for each row execute function "Archived_SY_Race"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Race" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Sub_District" definition

-- Drop table

-- DROP TABLE public."SY_Sub_District";

CREATE TABLE public."SY_Sub_District" (
	"Sub_District_ID" serial4 NOT NULL,
	"PV_CODE" varchar(255) NULL,
	"DT_CODE" varchar(255) NULL,
	"SDT_CODE" varchar(255) NULL,
	"SDT_TNAME" varchar(255) NULL,
	"SDT_ENAME" varchar(255) NULL,
	"ZIP_CODE" varchar(255) NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Sub_District_Sub_District_ID_key" UNIQUE ("Sub_District_ID"),
	CONSTRAINT "SY_Sub_District_pkey" PRIMARY KEY ("Sub_District_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Sub_District" before delete on
public."SY_Sub_District" for each row execute function "Archived_SY_Sub_District"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Sub_District" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_Sub_Occupation" definition

-- Drop table

-- DROP TABLE public."SY_Sub_Occupation";

CREATE TABLE public."SY_Sub_Occupation" (
	"Sub_Occ_ID" serial4 NOT NULL,
	"Sub_Occ_Name_TH" varchar(255) NULL,
	"Sub_Occ_Name_EN" varchar(255) NULL,
	"Specify_Detail" bool NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_Sub_Occupation_Sub_Occ_ID_key" UNIQUE ("Sub_Occ_ID"),
	CONSTRAINT "SY_Sub_Occupation_pkey" PRIMARY KEY ("Sub_Occ_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_Sub_Occupation" before delete on
public."SY_Sub_Occupation" for each row execute function "Archived_SY_Sub_Occupation"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_Sub_Occupation" for each row execute function format_update_date_to_wh_update_date();


-- public."SY_System" definition

-- Drop table

-- DROP TABLE public."SY_System";

CREATE TABLE public."SY_System" (
	"System_ID" serial4 NOT NULL,
	"System" varchar(50) NULL,
	"Status" bool NULL,
	"Create_Date" timestamp(6) NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp(6) NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "SY_System_System_ID_key" UNIQUE ("System_ID"),
	CONSTRAINT "SY_System_pkey" PRIMARY KEY ("System_ID")
);

-- Table Triggers

create trigger "Trigger_Archived_SY_System" before delete on
public."SY_System" for each row execute function "Archived_SY_System"();
create trigger trigger_format_timestamp before insert
or update on
public."SY_System" for each row execute function format_update_date_to_wh_update_date();


-- public."Yeastar_Token" definition

-- Drop table

-- DROP TABLE public."Yeastar_Token";

CREATE TABLE public."Yeastar_Token" (
	"Yeastar_ID" serial4 NOT NULL,
	"Access_Token" varchar(255) NULL,
	"Access_Token_Expire_Time" int4 NULL,
	"Refresh_Token" varchar(255) NULL,
	"Refresh_Token_Expire_Time" int4 NULL,
	"Create_Date" timestamp NULL,
	"Create_By" varchar(255) NULL,
	"Update_Date" timestamp NULL,
	"Update_By" varchar(255) NULL,
	"WH_Update_Date" int4 NULL,
	CONSTRAINT "Yeastar_Token_pkey" PRIMARY KEY ("Yeastar_ID")
);