/*
    audit : nbfo2.stg.stg_segment_ep4
*/

-- audit01 --> request result as null
select * 
from nbfo2.stg.stg_segment_ep4 sg
left join nbfo2.pos.pp_customer pp_cust with(nolock)
    on sg.customer_id = pp_cust.customer_id 
where pp_cust.Customer_ID is null
    and version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
;
-- audit02 --> ทุก customer_id ต้องมี segment อยู่
 select top 10 pp_cust.Customer_ID
    ,pp_cust.Create_Date
    ,pp_cust.CName
    ,sg.*
 from nbfo2.pos.pp_customer pp_cust with(nolock)
 left  join  nbfo2.stg.stg_segment_ep4 sg 
    on pp_cust.Customer_ID = sg.customer_id
where sg.customer_id is null
    and SG.version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
;

-- audit03 -->  ถ้ามี เลขห้อง แสดงว่าห้องมีจริง
SELECT  *
FROM nbfo2.stg.stg_segment_ep4 sg 
where 1=1 
    and SG.version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
    and (pd_code is not null  and pd_runno is null )
    and is_prove_data = 1
    
;


SELECT  source,customer_id ,segment_olm,pj_code, ct,pd_code,count(*)
FROM nbfo2.stg.stg_segment_ep4 sg 
where 1=1 
    and SG.version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
    and is_prove_data = 1
group by source, customer_id,segment_olm,pj_code, pd_code,ct
having count(*)>1
;
SELECT  *
FROM nbfo2.stg.stg_segment_ep4 sg 
where 1=1 
    and SG.version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
    and is_prove_data = 1
     and  source = '#temp_last_ex_customer_pos_702'
     and customer_id = '99895';

----------------------------------------------------------------------------------------------------------------------
-- truncate table nbfo2.stg.stg_segment_ep4
------------------------------------------------------------

/* ---------------------------------------  nbfo2.stg.vw_poc_base_segment_data  ---------------------------------------
with mst_unit as 
(
    sELECT distinct sg.pj_code 
        ,sg.pd_code
        ,sg.pd_runno
    
    FROM nbfo2.stg.stg_segment_ep4 sg
    where 1=1 
        and SG.version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
        and is_prove_data = 1
        and pd_code is not null
)
, process_data as 
(
    SELECT  *
    FROM nbfo2.stg.stg_segment_ep4 sg 
    where 1=1 
        and SG.version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
        and is_prove_data = 1
        and my_rank = 1
) 
, clear_data as 
(  
select
        mst.pj_code
        ,mst.pd_code 
        ,mst.pd_runno
        ,pdata.customer_id
        ,pdata.ct
        ,pdata.segment_olm
        ,pdata.pos_segment_id
from mst_unit mst
    left join process_data pdata
    on mst.pj_code = pdata.pj_code 
    and mst.pd_code = pdata.pd_code 
    and mst.pd_runno = pdata.pd_runno
--where mst.pj_code = '1075'                                        
)
select * 
from clear_data; 
*/ ---------------------------------------  nbfo2.stg.vw_poc_segment_base_segment_data  ---------------------------------------


-- audit : [STG].[vw_poc_base_segment_data]
-- 1 : owner(1) ต้องมีได้แค่ 1 คน  --> pass 
select 
        pj_code
        ,pd_code 
        ,count(*)
from nbfo2.stg.vw_poc_segment_base_segment_data
where segment_olm = 1
group by 
    pj_code 
    ,pd_code 
having count(*)>1
-- 2 : co-owner(2) ต้องมีได้แค่ 0 -4 คน pass
select 
        pj_code
        ,pd_code 
        ,count(*)
from nbfo2.stg.vw_poc_segment_base_segment_data
where segment_olm = 2
group by 
    pj_code 
    ,pd_code 
having count(*)>4
-- 3 : ห้ามเป็น Owner + Ex Owner พร้อมกัน --pass
select 
        pj_code
        ,pd_code 
        ,customer_id
        ,count(*)
from nbfo2.stg.vw_poc_segment_base_segment_data
where segment_olm in  (1,3)
group by 
    pj_code 
    ,pd_code
    ,customer_id  
having count(*)>1;

-- 4  customer ต้องไม่ duplicate segment เดียวกัน --pass
select 
        pj_code
        ,pd_code
        ,pd_runno
        ,ct
        ,customer_id
        ,segment_olm
        ,pos_segment_id 
        
--        ,count(*)
from nbfo2.stg.vw_poc_segment_base_segment_data  --36776
-- where segment_olm in  (1,3)
group by 
                pj_code
        ,pd_code
        ,pd_runno
        ,ct
        ,segment_olm 
        ,customer_id
        ,pos_segment_id
having count(*)>1


-- select count(*) from nbfo2.stg.vw_poc_segment_base_segment_data  -- 36790
--------------------------------------------------------
-- customer_unit 
---------------------------
    sELECT --distinct 
        -- cmm.nb_customer_id
        sg.pj_code 
        ,sg.pd_code
        ,sg.pd_runno
        ,sg.ct
        ,sg.customer_id
    
        ,min(sg.segment_olm) as segment_olm
        ,min(sg.pos_segment_id) as pos_segment_id
        ,sg.nb_customer_id
        ,sg.create_date
        ,sg.create_by
    -- FROM nbfo2.stg.stg_segment_ep4 sg
    from nbfo2.stg.vw_poc_segment_base_segment_data sg
    where 1=1 
        --and SG.version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
        --and is_prove_data = 1
      --  and pj_code is null 
    group by  
            --  cmm.nb_customer_id
            sg.pj_code
            ,sg.pd_code
            ,sg.pd_runno
            ,sg.ct  
            ,sg.customer_id
            ,sg.nb_customer_id
            ,sg.create_date
            ,sg.create_by
--------------------------------------
-- customer_project
---------------------------
    sELECT --distinct 
        -- cmm.nb_customer_id
        sg.pj_code 
       ,sg.customer_id
    
        ,min(sg.segment_olm) as segment_olm
        ,min(sg.pos_segment_id) as pos_segment_id
        ,sg.nb_customer_id
        ,sg.create_date
        ,sg.create_by
    -- FROM nbfo2.stg.stg_segment_ep4 sg
    from nbfo2.stg.vw_poc_segment_base_segment_data sg
    where 1=1 
        --and SG.version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
        --and is_prove_data = 1
         and pj_code is not null 
    group by  
            --  cmm.nb_customer_id
            sg.pj_code
            ,sg.customer_id
            ,sg.create_date
            ,sg.create_by
            ,sg.nb_customer_id
--------------------------------------
-- by customer
-------------------------------
sELECT --distinct 
         sg.customer_id
         ,sg.nb_customer_id
        ,min(sg.segment_olm) as segment_olm
        ,min(sg.pos_segment_id) as pos_segment_id
        ,sg.version_date as create_date
        ,'99999999' as create_by
        -- select top 10 *
    FROM nbfo2.stg.stg_segment_ep4 sg   --461604
    --from nbfo2.stg.vw_poc_segment_base_segment_data sg
    where 1=1 
        and SG.version = (select max(version) from nbfo2.stg.stg_segment_ep4 )
        and is_prove_data = 1
      -- and pj_code is not null
    group by  
        sg.customer_id
        ,sg.nb_customer_id
        ,sg.version_date



select count(*) 
from nbfo2.pos.pp_customer with(nolock)



select top 10 status,completed_date,* from [rem].[noble_prd].[dbo].[vw_noble_contractdata] where pj_code = '1024' and pd_code = '243' 
                    



select
    pj_code,
    pd_code,
    count(*) as owner_count
from final_segment
where segment_olm = 1
group by
    pj_code,
    pd_code
having count(*) > 1



select pj_code
    ,pd_code
    ,pd_runno
    ,sum(case when segment_olm = 1 then 1 else 0 end) as  olm_1
    ,sum(case when segment_olm = 2 then 1 else 0 end) as  olm_2
    ,sum(case when segment_olm = 3 then 1 else 0 end) as  olm_3
    ,sum(case when segment_olm = 4 then 1 else 0 end) as  olm_4
    ,sum(case when segment_olm = 5 then 1 else 0 end) as  olm_5
    ,sum(case when segment_olm = 6 then 1 else 0 end) as  olm_6
    ,sum(case when segment_olm = 7 then 1 else 0 end) as  olm_7
    ,sum(case when segment_olm = 8 then 1 else 0 end) as  olm_8
    ,sum(case when segment_olm = 9 then 1 else 0 end) as  olm_9
    ,sum(case when segment_olm = 10 then 1 else 0 end) as  olm_10
    ,sum(case when segment_olm = 11 then 1 else 0 end) as  olm_11
    ,sum(case when segment_olm = 12 then 1 else 0 end) as  olm_12
    ,sum(case when segment_olm = 13 then 1 else 0 end) as  olm_13    
from clear_data

group by 
pj_code
    ,pd_code
    ,pd_runno
order by pj_code, pd_code
;

select status,customer_id,pj_code, pd_code,* 
from  NBFO2.REM.V_ContractData
where pj_code = '1053'
    and pd_code = '11A1'

select distinct status
from NBFO2.REM.V_ContractData 
where pj_code = '1053'
    and pd_code = '11A1'


select status,* 
from NBFO2.REM.V_ContractData  with(nolock)
    UNPIVOT
        (
            customer for customer_id_rank in (customer_id, customer_id2, customer_id3, customer_id4, customer_id1)            
        ) as ctdata
    left  join nbfo2.pos.pp_customer pp_cust with(nolock)
        on ctdata.customer = pp_cust.customer_id

 where ctdata.status in ('Transfered')
    and pp_cust.Customer_ID is not null   --ตรวจสอบ ว่า custome_id ต้องมีใน pp_customer เท่านั้น  ถ้ามีแจ้งบอส
    and pj_code = '1053'
    and pd_code = '11A1'




SELECT  *
FROM nbfo2.stg.stg_segment_ep4
where pj_code = '1053'
    and pd_code = '11A1'



select top 10 * 
from nbfo2.[REM].[V_Noble_InventoryData]
where pj_code = 'j005'
and pd_code like  'D15B86%'

-- select status,customer_id,pp_runno,* 
-- from [rem].[noble_prd].[dbo].[vw_noble_contractdata]
-- where contract_no = 'CJ00500650'



-- select * from nbfo2.pos.pp_customer where customer_id = '94295'
pj_code	pd_code	pd_runno	customer_id	ct	segment_olm	pos_segment_id
1033	011	2005000015	420894	2005090003	1	1