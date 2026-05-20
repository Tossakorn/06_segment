-- customer manangement system

select * 
from openquery([CUST_MANAGEMENT],'select * from public."Customer_System" limit 100')

select * 
from openquery([CUST_MANAGEMENT],'select * from public."SY_System"')

select * 
from openquery([CUST_MANAGEMENT],'select * from public."Customer" limit 100')

-- online_member 

select top 10 * 
from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_ID_ASSET')

select top 10 * 
from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember_Authen_Line')


select top 10 * 
from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember')


-- pos system
select top 10 * 
from nbfo2.pos.pp_customer with(nolock);

----------------
--TASK 
---------------
1. ใน pp_customer มีการซ้ำของข้อมูล pattern อย่างไรบ้าง
    1.1  ชื่อ / นามสกุล / เบอร์โทรศัพท์ / อีเมลล์
        -- 2545 records 
        -- issue
        -- 1. อาจจะมาจาก web register ที่ส่งมาแล้ว api ค้าง พอ restart  API ระบบเลยยิงรัว  (สันนิฐาน)
        -- 2. 4  field เข้ามาครั้งแรก ไม่ซ้ำ จึงเกิด มากกว่า 1 customer  แต่เมื่อมีการ update customer แล้วระบบเจอว่า 4 field ซ้ำ ระบบถามว่า จะ merge มั๊ย  user ไม่ merge แล้ว Save จึงเกิด 4 field ซ้ำ
    1.2  ชื่อ / นามสกุล / เบอร์โทรศัพท์
        -- 3844 Rrecords
    1.3  ชื่อ / นามสกุล / อีเมลล์
        -- 4272 records
    1.4  ชื่อ / อีเมลล์
        -- 18185 records
2. onlinemember 
    1.1 duplicate poscustid

/*1.4 ชื่อ / อีเมลล์ */
select 
    pp_cust.cs_fname 
    ,pp_cust.email
    ,count(*) as duplicate_count
from nbfo2.pos.pp_customer pp_cust with(nolock)
group by 
    pp_cust.cs_fname 
    ,pp_cust.email
having COUNT(*) > 1;




/* 1.3 ชื่อ / นามสกุล / อีเมลล์ */
select 
    pp_cust.cs_fname 
    ,pp_cust.cs_lname
    ,pp_cust.email
    ,count(*) as duplicate_count
from nbfo2.pos.pp_customer pp_cust with(nolock)
group by 
    pp_cust.cs_fname 
    ,pp_cust.cs_lname
    ,pp_cust.email
having COUNT(*) > 1;




/*1.2 ชื่อ / นามสกุล / เบอร์โทรศัพท์ */
select 
    pp_cust.cs_fname 
    ,pp_cust.cs_lname
    ,pp_cust.ccontactphone
    ,count(*) as duplicate_count
   
from nbfo2.pos.pp_customer pp_cust with(nolock)
group by 
    pp_cust.cs_fname 
    ,pp_cust.cs_lname
    ,pp_cust.ccontactphone
having COUNT(*) > 1;


--pos-issue1
/* 1.1 ชื่อ / นามสกุล / เบอร์โทรศัพท์ / อีเมลล์ */
select 
    pp_cust.cs_fname 
    ,pp_cust.cs_lname
    ,pp_cust.email
    ,pp_cust.ccontactphone
    ,count(*) as duplicate_count
    ,DATEDIFF(day,min(Create_Date),max(Create_Date)) diff_day
    ,min(Create_Date) as first_rec
    ,max(Create_Date) as lastest_rec
    --  ,max(olm_id)
    -- ,min(olm_id)
    ,case 
        when   max(olm_id) = min(olm_id) then '01 มี olm_id แล้ว ตรงกัน'
        when   max(olm_id) <> min(olm_id) then '02 มี olm_id แล้ว ไม่ตรงกัน'
        when  max(olm_id) is null then '03 ยังไม่มี olm_id'
        else 
            '99 etc'
        end casex
from nbfo2.pos.pp_customer pp_cust with(nolock)
    -- left join openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember') olm

group by 
    pp_cust.cs_fname 
    ,pp_cust.cs_lname
    ,pp_cust.email
    ,pp_cust.ccontactphone
having COUNT(*) > 1
order by 8 desc;


select  olm_id,count(*) no_of_dup
    ,max(Customer_ID) as customer_id_max_order
    ,min(Customer_ID) as customer_id_min_order
from nbfo2.pos.pp_customer pp_cust with(nolock)
where olm_id is not null
group by olm_id
having count(*)>1
order by 2 desc;

--olm issue1
select 
    olm.POSCustID
    ,olm.Serve
    ,count(*) as no_of_dup
    --,pp_cust.Customer_ID
-- select top 10 * 
-- from openquery([DBPOBK.NBDS.COM],'select * from noble_id_member.dbo.NB_OnlineMember') olm 
from [DBPOBK.NBDS.COM].[noble_id_member].[dbo].[NB_OnlineMember] olm
    left join nbfo2.pos.PP_Customer pp_cust with(nolock)
     on olm.poscustid = pp_cust.Customer_ID
where olm.poscustid is not null
group by olm.POSCustID,Serve,pp_cust.Customer_ID
having count(*)>1;





select olm_auth.olm_id,app_id ,count(*)
-- select top 10 *
from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember_Authen_Line') olm_auth
group by olm_auth.olm_id,app_id
having count(*)>1;


-- [OK]
-- olm ทุกตัวที่มี poscustId มีใน  customer_id จริง 
-- [ISSUE]
-- duplicate poscustid 1974

------
select olm_id,cs_fname, CS_LName,pp_cust.email,CContactPhone
    ,pp_cust.customer_id
    ,Create_Date
    ,create_by
    ,update_by
    ,staff.ThFirstName
    ,pp_cust.Update_Date
    ,CContactPhone_StaffUpdate
    ,'<--->'
    ,* 
from nbfo2.pos.pp_customer pp_cust with(nolock)
    left join nbct.nbct.nb_staff staff with(nolock)
    on pp_cust.update_by = staff.Staff_ID 
-- case 1 : สันนิฐานว่า เกิดจาก api ยิ่งรัว เมื่อ restart ขึ้นมาใหม่
-- where pp_cust.cs_fname = 'ภูวชัย'
--     and cs_lname = 'อินสองคราม'
-- case 2 : มีการเปลี่ยน 4 field  แล้วไม่ merge
-- where pp_cust.cs_fname = 'ปลิดา'
--     and cs_lname = 'ผาติผดุงกุล'
where pp_cust.cs_fname = 'กุลยา'
    and cs_lname = 'ขจีเจตน์'
order by pp_cust.customer_id desc;





select  pp_act.Activity,* 
from nbfo2.pos.PP_Activity pp_act with(nolock)
where customer_id in  (551995,533827)
order by a_id 

select Activity,* 
from [192.168.83.37].nbfo2.pos.PP_Activity pp_act with(nolock)
where Activity like '%merge%'
    and at_id = 3


select * 
from nbfo2.pos.SY_Activity_Type
where at_name like '%แก้%'

7  Visit Event วันที่ 26/06/2019 เวลา 19:10:32 merge
41 ติดต่อทาง E-mail: MERGE
42 ติดต่อทางช่องทางอื่นๆ : merge
43  ติดต่อ ทาง Mobile Call In : MERGEII
44  ติดต่อ ทาง Mobile Call Out : รับสาย เข้าชมโครงการแล้ว ลงทะเบียนอีกชื่อนึงซึ่งไม่สามารถ merge ได้
83  ติดต่อทาง Live Chat merge

219 Edit Opportunity Note : MERGEII Opportunity Note


select top 10  wbreg.email,wbreg.CContactPhone,wbreg.CS_FName,wbreg.CS_LName,*
from nbfo2.pos.pp_web_register wbreg
where customer_id in (553000,549846)


select top 10 * from nbct.nbct.nb_staff

SELECT top 10 create_date,* 
from nbfo2.stg.stg_nbk_booking_customer with(nolock)
where book_no = 'R105900043'
where customer_id in (213088,313312)




select top 10 contract_date,*
from openquery([rem],'select * from [noble_prd].[dbo].[vw_noble_contractdata] where customer_id in (213088,313312)')



-------------------------------------
-- 2026.08.18 
-------------------------------------
select top 100 PP_CUST.create_date
    ,pp_cust.customer_id
    ,pp_cust.olm_id 
        ,pp_cust.cs_fname 
    ,pp_cust.cs_lname
    ,pp_cust.email
    ,pp_cust.ccontactphone
    ,pp_cust.REM_Customer_ID
    ,case when visit.customer_id is not null then 'visit' else NULL end is_visit
    ,case when living.olm_id is not null then 'living' else NULL end is_living
from nbfo2.pos.pp_customer pp_cust witH(nolock) 
    left join 
            (
                select distinct customer_id 
                from nbfo2.pos.pp_visit with(nolock)
            ) visit 
    on pp_cust.customer_id = visit.customer_id
    left join 
            (
            select distinct olm_id
            from openquery([LIVING_V2],'select * from "NBL".living_v2."NBL_Order_Items"')
            ) living
    on pp_cust.olm_id = living.olm_id
where pp_cust.olm_id in 
        (
            select olm_id 
            from nbfo2.pos.pp_customer pp_cust with(nolock)
            where olm_id is not null
            group by olm_id
            having count(*)>1
        )
order by 
    pp_cust.olm_id
    ,pp_cust.customer_id;


select distinct olm_id
from openquery([LIVING_V2],'select * from "NBL".living_v2."NBL_Order_Items" limit 10 ');


select create_date,Update_Date,ccontactphone_dateupdate,CContactPhone2_DateUpdate,REM_Customer_ID
,pp_cust.customer_id
,pp_cust.olm_id
,pp_cust.cs_fname 
    ,pp_cust.cs_lname
    ,pp_cust.email
    ,pp_cust.ccontactphone
from nbfo2.pos.pp_customer pp_cust with(nolock)
where olm_id in ( 88113,79700);

select top 10 ContactPhone1,idcardno,createdatetime,updatedatetime,email,POSCustID,olm_id
from [192.168.83.37].[noble_id_member].[dbo].[NB_OnlineMember] olm with(nolock)
where olm_id = 74633     
    or poscustid = 531303;

select lineid,count(*)
-- select top 10 * 
from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember_Authen_Line')
group by lineid
having count(*)>1
;


select authen.olm_id
    ,olm.olm_id
 from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember_Authen_Line') authen
 left  join openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember')  olm 
    on authen.olm_id = olm.olm_id
where olm.olm_id is null;

---------------------------------------------------------------------------------------------------------------------------------------------
--                         d q                         
---------------------------------------------------------------------------------------------------------------------------------------------
--dg  authen_line 01 :  [STG].[vw_segment_dq_nb_onlinemember_authen_line]   : fail
select -- authen.olm_id
     authen.*
    -- ,olm.olm_id
 from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember_Authen_Line') authen
 where not exists 
    (   select * 
        from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember') olm
        where authen.olm_id = olm.olm_id
    )

-- dq authen_line 02 [vw_segment_dq_nb_onlinemember_authen_line_unique]  status=pass
select olm_id,app_id,count(*) as no_of_dup
-- select top 10 * 
from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember_Authen_Line')
group by olm_id,app_id
having count(*)>1


-- dq onlinemember  [STG].[vw_segment_dq_nb_onlinemember_poscustid_duplicate]  status=fail
select 
    olm.olm_id
    ,olm.poscustid
    ,case when pp_cust.customer_id is null then 'Invalid-customer_id' else 'Valid-customer_id' end poscust_verify
   -- ,case when olm.olm_id = pp_cust.olm_id then 'valid-olm_id' else 'invalid-olm_id' end olm_id_verify 
    ,olm.firstname
    ,olm.lastname
    ,olm.birthday
    ,olm.idcardno
    ,olm.passportno
      ,olm.ContactPhone1
    ,olm.email
    -- ,olm.*
    ,createdatetime
    ,updatedatetime
from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember with(nolock)') olm
    left join nbfo2.pos.pp_customer pp_cust with(nolock)
    on olm.poscustid = pp_cust.customer_id
where poscustid 
    in     
    (
        SELECT DISTINCT     olm.poscustid 
        from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember with(nolock)') olm
        group by olm.poscustid
        having count(*)>1
    )
    -- and olm.poscustid = '476578'
order by olm.poscustid

--
-- dq  case  [STG].[vw_segment_dq_nb_id_asset_validate]
select distinct asset.olm_id
    ,asset.app_id
    ,case when olm.olm_id is null then 'Invalid-olm' else 'Valid-olm' end olm_verify_with_onlinemember
    ,pp_cust.olm_id as pp_customer_olm_id
    ,pp_cust.customer_id as pp_customer_customer_id
from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_ID_ASSET with(nolock)') asset
    left join openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember with(nolock)') olm
    on asset.olm_id = olm.olm_id
    -- left join openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember_Authen_Line') authen
    -- on asset.olm_id = authen.olm_id
    left join nbfo2.pos.pp_customer pp_cust with(nolock)
    on asset.olm_id = pp_cust.olm_id
where asset.app_id =1 
    and asset.olm_id is not null
    and olm.olm_id is  null






SELECT DISTINCT     olm.poscustid 
from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember') olm
group by olm.poscustid
having count(*)>1



select top 10 * from openquery([192.168.83.37],'select * from noble_id_member.dbo.NB_OnlineMember_Verify')
;
select *
from nbfo2.pos.pp_visit visit  with(nolock)
where customer_id in (384288,486989)
;



select   olm.olm_id   
    ,olm.poscustid
    ,olm.idcardno
    ,olm.contactphone1
    ,olm.email
    ,olm.serve
    -- ,*
from [192.168.83.37].[noble_id_member].[dbo].[NB_OnlineMember] olm with(nolock)  -- 81713
    
;


select poscustid ,count(*) ,max(createdatetime) , min(createdatetime)
-- select top 10 *
from [192.168.83.37].[noble_id_member].[dbo].[NB_OnlineMember] olm with(nolock)  -- 81713
WHERE POSCUSTID IS NOT NULL
and statuscode = 'Active'
group by poscustid 
having count(*)>1

----------------------------------------------------------------------------------------------------------------

with raw_data as 
(
select poscustId,olm_id,statuscode,firstname,lastname,idcardno,contactphone1,email,serve
from  [192.168.83.37].[noble_id_member].[dbo].[NB_OnlineMember] olm with(nolock)  -- 81713
--  where poscustid = '229860'
)
-- case2 poscustid >1 --> and statuscode = active  750 rec
select poscustId,count(*)
from raw_data
where poscustid is not null
    and statuscode = 'active'
group by poscustid
having count(*)>1

-- case2 poscustid >1 --> 1886 rec
select poscustId,count(*)
from raw_data
where poscustid is not null
group by poscustid
having count(*)>1
;



    -- and authen.olm_id is null;