USE [NBFO2]
GO

/****** Object:  StoredProcedure [STG].[SP_poc_segement_prepare_data_for_segment]    Script Date: 13/05/2026 16:41:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











-- ============================================================================ ===============================================================================
-- Author:  Tossakorn
-- Create date: 2026.05.11
-- Description: รวบรวมข้อมูลต่าง ๆ เพื่อเตรียมสำหรับการจัด segment 
-- ===========================================================================================================================================================================================

ALTER PROCEDURE [STG].[SP_poc_segement_prepare_data_for_segment]
as
begin
 --================  =================
 /*
    playground
    2026.05.06 ep4  v01
    2026.05.11 ep4  v02 เพิ่มส่วนของการดึง nbcustomer_id มาแสดงใน segment data เลย
	                               เพิ่มส่วนของการลบ ไม่ให้เกิน  3 version ป้องกันข้อมูลบวม
    2026.05.13 ep4  v03 เปลี่ยน segment 13 เป็น 19 เพื่อให้เหลือ segment สำหรับการเพิ่มในอนาคตได้อีก และเปลี่ยน segment ของ authorized, family, tenant เป็น 9,10,11 ตามลำดับ

*/


/* -- เหมือนยังไม่มีการใช้งาน
IF (OBJECT_ID (N'tempdb..#rem_v_contractdata') IS NOT NULL) DROP TABLE #rem_v_contractdata;

 select distinct  pj_code,pd_code, customer_id
    into #rem_v_contractdata
                from  NBFO2.REM.V_ContractData ctdata with(nolock)
                where status in ('Completed','Transfered');
create index rem_v_contractdata_key on #rem_v_contractdata(pj_code, pd_code,customer_id);
*/

-- temp_owner_a = เก็บค่า owner /co-owner ตามเอกสาร contractata 


IF (OBJECT_ID (N'tempdb..#temp_owner_pos') IS NOT NULL) DROP TABLE #temp_owner_pos;
-----------
 select 
     ctdata.pj_code 
    ,ctdata.PD_CODE
    ,ctdata.[Status]
    ,ctdata.contract_no
    ,ctdata.Completed_Date
    ,ctdata.Ownership_Transfer_Date
    ,ctdata.Completed_Date as action_date  -- วันทีจะใช้อ้างอิง  ณ ปัจจบุัน ใช้ complete_date 
    ,ctdata.customer as customer_id
    ,case 
        when ctdata.customer_id_rank = 'Customer_ID' then 1
        else 2   
    end olm_segment
    --,1 as segment  -- pos_segment
   -- ,1 as priority
 -------------------------------------------
     into #temp_owner_pos
 -------------------------------------------
 from NBFO2.REM.V_ContractData  with(nolock)
    UNPIVOT
        (
            customer for customer_id_rank in (customer_id, customer_id2, customer_id3, customer_id4, customer_id1)            
        ) as ctdata
    left  join nbfo2.pos.pp_customer pp_cust with(nolock)
        on ctdata.customer = pp_cust.customer_id

 where ctdata.status in ('Transfered')
    and pp_cust.Customer_ID is not null   --ตรวจสอบ ว่า custome_id ต้องมีใน pp_customer เท่านั้น  ถ้ามีแจ้งบอส
 order by 9 desc
;
--select * from #temp_owner_pos where contract_no= 'C107500210';  -- จะได้ olm_segment (1,2) / pos segment จะเป็น customer segment = 0 

-----------------------------------------------------------------------------------------------------
-- 2026.05.06  เพิ่มส่วนของ การหา master pos_segment_id
-----------------------------------------------------------------------------------------------------
-- จะเป็นส่วนของ segment 1-8




------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_owner_nbid') IS NOT NULL) DROP TABLE #temp_owner_nbid;

 select
        pp_cust.Customer_ID as pos_customer_id
        ,pp_cust.OLM_ID  as pos_olm_id  
        ,asset.olm_id
       -- ,asset.customer_id
        ,asset.pj_code
        ,asset.pd_code
        ,asset.Permission
        ,asset.status
        ,asset.email
        ,asset.source
        ,case when asset.source = 'CMS' then 1  --เป็นการบันทึกจาก julistic
            when asset.source = 'POS' then 2    --เป็นการบันทึกจากการตรวจสอบจาก pos 
            else   3
        end source_priority
        ,createdate
        ,row_number() over (partition by asset.pj_code, asset.pd_code, asset.permission order by 
            case when asset.source = 'CMS' then 1 
                when asset.source = 'POS' then 2
                else   3
            end ,pp_cust.customer_id )
        as rec_rank
        ,inv.pd_code as inv_pd_code
        ,inv.pd_runno
        -- ,0  as  priority 
 -------------------------------------------
        into #temp_owner_nbid
 -------------------------------------------
    -- select distinct asset.permission
    from [DBPOBK.NBDS.COM].[noble_id_member].[dbo].[nb_id_asset] asset with(nolock)
        left join nbfo2.pos.PP_Customer pp_cust with(nolock)
            on asset.olm_id = pp_cust.OLM_ID
        -- left join nbfo2.app_bi.dwh_inventory_v03 inv with(nolock)
        left join  [rem].[noble_prd].[dbo].[vw_noble_inventorydata] inv 
            on asset.pj_code = inv.pj_code
                and asset.pd_code = inv.pd_code 

    where asset.pd_code is not null
        and asset.permission = 'O'  --owner
        and asset.pd_code not like 'Test%'
        and asset.source = 'CMS'
        and pp_cust.Customer_ID is not null
        and inv.pd_code IS NOT NULL
        and pp_cust.OLM_ID  = asset.olm_id
        --join ต้อง where rec_rank = 1 ด้วย
        and asset.status = 'Active'
    ;

--  select *   from #temp_owner_nbid;    -- ok 
  
-----------------------------------------------------------------------------------------------------------------
-- step 3 list ข้อมูลที่จะนำ ไปupdate  สถานะ ของ owner คนเก่าใน pos ให้เป็น  ex-customer
-----------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_owner_update') IS NOT NULL) DROP TABLE #temp_owner_update;
--         select pj_code, pd_code, customer_id from #temp_owner_nbid where rec_rank = 1

-- select pj_code, pd_code, customer_id  from #temp_owner_pos where olm_segment =1 
select 
    owner_nbid.pj_code 
    ,owner_nbid.pd_code 
    ,owner_nbid.pos_customer_id as owner_nbid_customer_id 
    ,owner_pos.customer_id as owner_pos_customer_id
    ,case 
        when owner_nbid.pos_customer_id = owner_pos.customer_id then owner_pos.customer_id --'Match'
        else owner_nbid.pos_customer_id  --'Not Match'
    end as customer_id
    ,case 
        when owner_nbid.pos_customer_id = owner_pos.customer_id then 'pos' --'Match'
        else 'nbid'  --'Not Match'
    end as customer_source_final
 -------------------------------------------
    into #temp_owner_update
 -------------------------------------------
 -- select * 
from #temp_owner_nbid owner_nbid
    left join #temp_owner_pos owner_pos    
        on owner_nbid.pj_code = owner_pos.pj_code
            and owner_nbid.pd_code = owner_pos.pd_code
where 
    owner_nbid.rec_rank = 1          -- ต้องมีเพราะมีการ Add owner ซ้ำใน nb_id_asset
    and owner_pos.olm_segment = 1    -- ต้องมีเพราะจะเอา owner มาเที่ยบเท่านั้้น    
    and case 
        when owner_nbid.pos_customer_id = owner_pos.customer_id then 'pos' --'Match'
        else 'nbid'  --'Not Match'
    end  = 'nbid'  --เอาเฉพาะที่ไม่ตรงกัน

order by 1,2
;

-- select  * from #temp_owner_update;

-----------------------------------------------------------------------------------------------------------------
-- step 4 --> จะได้เฉพาะส่วนของ segement 1 ,2   ใหม่   แต่ ยังไม่รู้ว่า customer ที่เป็น owner ใหม่ มี pos segment ว่าเป็นอะไร
-----------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_owner_final') IS NOT NULL) DROP TABLE #temp_owner_final;

select *
 -------------------------------------------
    into #temp_owner_final
 -------------------------------------------
from
(
    --คนที่เป็น  owner จริง ๆ ไม่มีข้อมูลใน nb_id_asset
    select  owner_pos.*
        ,1 as pos_segment_id
    from #temp_owner_pos owner_pos   -- 25199       
        left join #temp_owner_update owner_update --560 rows
            on owner_update.pj_code = owner_pos.pj_code
                and owner_update.pd_code = owner_pos.pd_code
    where owner_update.pd_code is   null 
    -- -------------------------------------------------------------
    union
    -------------------------------------------------------------
    -- ถ้าใน  pos เป็นคนเดียวกับ asset ให้ยึด pos>> step ก่อนหน้านี้เลือกที่เฉพาะ ต้อง updateมาแล้ว
    select
        owner_pos.PJ_CODE
        ,owner_pos.PD_CODE
        ,owner_pos.[Status]
        ,owner_pos.Contract_No
        ,owner_pos.Completed_Date
        ,owner_pos.Ownership_Transfer_Date
        ,owner_pos.action_date
        ,owner_update.customer_id
        ,owner_pos.olm_segment
        -- 2026.05.06 เพิ่มส่วนในการตรวจเช็คpos segment
        -- ,case 
        --         when owner.customer_id is not null then 1        -- customer
        --         when prospect.customer_id is not null then 2     -- prospect
        --         when lead.customer_id  is not null then 3      -- lead
        --     else 4                                               -- n/a
        -- end pos_segment_id
        -- ,4 as pos_segment_id   -- เพราะถ้าเป็นคนใหม่ ที่มาเป็นเจ้าของ  unit นี้ และไม่อยู่ในเอกสาร 
        ,case 
            when chk_owner.customer_id is null then 4         -- เพราะถ้าเป็นคนใหม่ ที่มาเป็นเจ้าของ  unit นี้ และไม่อยู่ในเอกสาร
            else 1                                            -- เพราะมีชื่อเอกสารของห้องนี้แล้ว
        end as pos_segment_id
    from #temp_owner_update owner_update --560 rows
        inner join #temp_owner_pos owner_pos 
            on owner_update.pj_code = owner_pos.pj_code
                and owner_update.pd_code = owner_pos.pd_code
                and owner_update.owner_pos_customer_id = owner_pos.customer_id
        left join 
                (
                        select distinct pj_code ,pd_code , customer_id 
                        from #temp_owner_pos where olm_segment <> 1
                ) chk_owner
             on owner_update.pj_code = chk_owner.pj_code 
             and owner_update.customer_id = chk_owner.customer_id
        
        left join   
                (
                    select distinct pj_code, customer_id 
                    from  #temp_owner_pos with(nolock)   -- owner
                 ) owner 
            on owner_update.pj_code = owner.pj_code 
            and owner_update.customer_id = owner.customer_id


    where owner_pos.olm_segment = 1   
) union_data 
;

-- select * from #temp_owner_final where contract_no = 'C107500210'
--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------     segment 1,2  ถูกต้องแล้ว

-- step 5 : #temp_ex_owner_final  
-----------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_ex_owner_final') IS NOT NULL) DROP TABLE #temp_ex_owner_final;

select
        owner_pos.PJ_CODE
        ,owner_pos.PD_CODE
        ,owner_pos.[Status]
        ,owner_pos.Contract_No
        ,owner_pos.Completed_Date
        ,owner_pos.Ownership_Transfer_Date
        ,owner_pos.action_date
        -- 2026.05.08 ต้องเป็น customer ที่เคยเป็นowner แล้ว ใน  asset เป็น owner คนใหม่  คนเก่าจึงกลายเป็น ex
        --,owner_update.customer_id
         ,owner_pos.customer_id
        ,case when owner_pos.olm_segment = 1 then 3 
            when owner_pos.olm_segment = 2 then 4
            else 99999
        end as olm_segment
        ,1 as pos_segment_id
       
 -------------------------------------------
        into #temp_ex_owner_final
 -------------------------------------------
 /* org
    from #temp_owner_update owner_update --560 rows
        inner join #temp_owner_pos owner_pos 
            on owner_update.pj_code = owner_pos.pj_code
                and owner_update.pd_code = owner_pos.pd_code
                -- cutomer_id ต้องไม่ใช่คนเดียวกัน
                and owner_update.customer_id <> owner_pos.customer_id
    -- where owner_update.pj_code = '1046'
    --     and owner_update.pd_code = '17A7'
*/
   -- select *
    from #temp_owner_pos owner_pos
        inner join  #temp_owner_update owner_update --560 rows
        on owner_pos.PJ_CODE = owner_update.pj_code 
        and owner_pos.pd_code = owner_update.pd_code 
    where 1=1 
        and owner_update.customer_id <> owner_pos.customer_id
        -- and owner_update.pj_code = '1046'
        -- and owner_update.pd_code = '17A7'    
        
;
-- select * from #temp_ex_owner_final
--   where pj_code = '1046'
--         and pd_code = '17A7'

-- select *
-- from #temp_owner_pos
--   where pj_code = '1046'
--         and pd_code = '17A7'

-- -----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------     segment 3,4   ถูกต้องแล้ว
-- step 6 : #temp_last_customer_pos                                                                                   segment 5,6  part 1 จาก contract
-----------------------------------------------------------------------------------------------------------------

IF (OBJECT_ID (N'tempdb..#temp_last_customer_pos') IS NOT NULL) DROP TABLE #temp_last_customer_pos;
-----------
 select distinct
     ctdata.pj_code 
    ,ctdata.PD_CODE
    ,ctdata.[Status]
    ,ctdata.contract_no
    ,ctdata.Completed_Date
    ,ctdata.Ownership_Transfer_Date
    ,ctdata.Completed_Date as action_date  -- วันทีจะใช้อ้างอิง  ณ ปัจจบุัน ใช้ complete_date 
    ,ctdata.customer as customer_id
    ,case 
        when ctdata.customer_id_rank = 'Customer_ID' then 5
        else 6   
    end olm_segment
 -------------------------------------------
     into #temp_last_customer_pos
 -------------------------------------------
 from NBFO2.REM.V_ContractData  with(nolock)
    UNPIVOT
        (
            customer for customer_id_rank in (customer_id, customer_id2, customer_id3, customer_id4, customer_id1)            
        ) as ctdata
    left  join nbfo2.pos.pp_customer pp_cust with(nolock)
        on ctdata.customer = pp_cust.customer_id

 where ctdata.status   in ('Completed')
    and ctdata.Ownership_Transfer_Date is null
    and pp_cust.Customer_ID is not null   --ตรวจสอบ ว่า custome_id ต้องมีใน pp_customer เท่านั้น  ถ้ามีแจ้งบอส
 order by 9 desc;

-----------------------------------------------------------------------------------------------------------------
-- step 7 : #temp_last_ex_customer_pos 
        -- 7.1 สัญญา active ที่มีการเปลี่ยน owner แล้ว customer id เดิมกลายเป็น ex-customer
        --       - key condition :สัญญาที่ active ได้มาแล้วจาก #temp_last_customer_pos
        --       - source        : ir_change_owner ที่มี docid_old ตรงกับ key condition
        -- 7.2 สัญญา cancel แต่เคยทำสำเร็จแล้ว (มี completed_date)
        --       - key condition : สัญญา cancel and complete_date is not null
        --       - source        : contractdata
        -- 7.3 สัญญา cancel แต่เคยทำสำเร็จแล้ว (มี completed_date) และมีการเปลี่ยน owner อีกด้วย  (เป็นส่วนที่ ก่อนที่จะ cancel แล้วมีการ change owner)
        --       - key condition : ข้อมูลตาม 7.2
        --       - source        : ir_change_owner ที่มี docid_old ตรงกับ 7.2 
        -- note : case  3.ลูกค้าหลักที่ยกเลิกสัญญาแต่มีวันที่โอนแล้ว >>>ส่วนนี้จะอยู่ใน ข้อ 6.2,6.3 แล้ว     
-----------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_last_ex_customer_pos_701') IS NOT NULL) DROP TABLE #temp_last_ex_customer_pos_701;


-- 7.1 สัญญา active ที่มีการเปลี่ยน owner แล้ว customer id เดิมกลายเป็น ex-customer
select *
       into #temp_last_ex_customer_pos_701
from 
(
select 
        chg_owner.PJ_CODE
        ,chg_owner.PD_CODE  
        ,chg_owner.DocID_Old
        ,chg_owner.[Status]           -- status = approved,completed
        ,chg_owner.Completed_Date    --ต้องมีค่า
        ,chg_owner.Approve_Date
        --,coalesce(chg_owner.Approve_Date,chg_owner.Completed_Date) as action_date
        ,(select max(v) as x from (values (chg_owner.Approve_Date), (chg_owner.Completed_Date)) as raw_data(v)) as action_date  -- แก้ไขโดยใช้วันที่มากกว่า
        ,chg_owner.Customer_ID_upv as customer_id
        --,chg_owner.customer_id_rank
        ,case when chg_owner.customer_id_rank = 'Customer_ID_Old' then 7 
            else 8
        end as olm_segment
        ,chg_owner.ChangeOwner_No
        ,ROW_NUMBER() over (partition by chg_owner.pj_code, chg_owner.pd_code, chg_owner.docid_old, chg_owner.Customer_ID_upv order by approve_date ) as my_rank
--------------------------------------------
      
--------------------------------------------
from nbfo2.pos.IR_ChangeOwnerDoc --chg_owner
    UNPIVOT
        (
            Customer_ID_upv for customer_id_rank in (Customer_ID_Old, Customer_ID1_Old, Customer_ID2_Old, Customer_ID3_Old, Customer_ID4_Old)            
        ) as chg_owner  
    inner join (select distinct contract_no,Completed_Date from #temp_last_customer_pos) last_cust
        on chg_owner.DocID_Old = last_cust.contract_no
           -- case นี้แจ้งเป็น issue : http://git.noblehome.com/data-cdp-and-report/cdp/-/issues/212
              -- ไม่ตรวจสอบนี้ เพื่อให้ได้ข้อมูลครบก่อน 
           --and coalesce(chg_owner.Approve_Date,chg_owner.Completed_Date)  < last_cust.Completed_Date
           and (select max(v) as x from (values (chg_owner.Approve_Date), (chg_owner.Completed_Date)) as raw_data(v)) >= last_cust.Completed_Date
where 1=1
    and chg_owner.[Status] in( 'Approved','Completed')
   -- and chg_owner.Completed_Date is not null   
    -- and chg_owner.Approve_Date is null 
    and DocID_Old in (select distinct contract_no from #temp_last_customer_pos)
-- order by olm_segment desc
) x
where my_rank = 1   -- 2026.05.08 แก้ไขปัญหา duplicate customer   pd_code = 'd11b12x' pj_code =1081
;

-- select * from #temp_last_ex_customer_pos_701

-----------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_last_ex_customer_pos_702') IS NOT NULL) DROP TABLE #temp_last_ex_customer_pos_702;
-----------------------------------------------------------------------------------------------------------------
-- 7.2 สัญญา cancel แต่เคยทำสำเร็จแล้ว (มี completed_date)
 select distinct 
     ctdata.pj_code 
    ,ctdata.PD_CODE
    ,ctdata.[Status]
    ,ctdata.contract_no
    ,ctdata.Completed_Date
    ,ctdata.Ownership_Transfer_Date
    ,ctdata.Completed_Date as action_date  -- วันทีจะใช้อ้างอิง  ณ ปัจจบุัน ใช้ complete_date 
    ,ctdata.customer as customer_id
    ,case 
        when ctdata.customer_id_rank = 'Customer_ID' then 7   -- ex-customer
        else 8   -- ex-co-customer
    end olm_segment
 -------------------------------------------
    into #temp_last_ex_customer_pos_702
 -------------------------------------------
 from NBFO2.REM.V_ContractData  with(nolock)
    UNPIVOT
        (
            customer for customer_id_rank in (customer_id, customer_id2, customer_id3, customer_id4, customer_id1)            
        ) as ctdata
    left  join nbfo2.pos.pp_customer pp_cust with(nolock)
        on ctdata.customer = pp_cust.customer_id

 where ctdata.status   in ('cancel')         --cont_01 เอกสารมีการ cancel 
    and ctdata.Completed_Date is not null    --cont_02 เอกสารต้องเคยทำสำเร็จมาแล้ว   
   -- and ctdata.Ownership_Transfer_Date is null
    and pp_cust.Customer_ID is not null   --ตรวจสอบ ว่า custome_id ต้องมีใน pp_customer เท่านั้น  ถ้ามีแจ้งบอส
 order by 9 desc;

-- select * from #temp_last_ex_customer_pos_702;

-- select distinct customer_id_rank
-- from #temp_last_ex_customer_pos_702

-----------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_last_ex_customer_pos_703') IS NOT NULL) DROP TABLE #temp_last_ex_customer_pos_703;
-----------------------------------------------------------------------------------------------------------------

select 
        chg_owner.PJ_CODE
        ,chg_owner.PD_CODE  
        ,chg_owner.DocID_Old
        ,chg_owner.[Status]           -- status = approved,completed
        ,chg_owner.Completed_Date    --ต้องมีค่า
        ,chg_owner.Approve_Date
        ,coalesce(chg_owner.Approve_Date,chg_owner.Completed_Date) as action_date
        ,chg_owner.Customer_ID_upv as customer_id
        --,chg_owner.customer_id_rank
        ,case when chg_owner.customer_id_rank = 'Customer_ID_Old' then 7 
            else 8
        end as olm_segment
        ,chg_owner.ChangeOwner_No
 -------------------------------------------
        into #temp_last_ex_customer_pos_703
 -------------------------------------------
from nbfo2.pos.IR_ChangeOwnerDoc --chg_owner
    UNPIVOT
        (
            Customer_ID_upv for customer_id_rank in (Customer_ID_Old, Customer_ID1_Old, Customer_ID2_Old, Customer_ID3_Old, Customer_ID4_Old)            
        ) as chg_owner  
    inner join (select distinct contract_no,Completed_Date from #temp_last_ex_customer_pos_702) last_cust
        on chg_owner.DocID_Old = last_cust.contract_no
           -- case นี้แจ้งเป็น issue : http://git.noblehome.com/data-cdp-and-report/cdp/-/issues/212
              -- ไม่ตรวจสอบนี้ เพื่อให้ได้ข้อมูลครบก่อน 
          -- and coalesce(chg_owner.Approve_Date,chg_owner.Completed_Date)  < last_cust.Completed_Date
           and (select max(v) as x from (values (chg_owner.Approve_Date), (chg_owner.Completed_Date)) as raw_data(v)) >= last_cust.Completed_Date
where 1=1
    and chg_owner.[Status] in( 'Approved','Completed')
   -- and chg_owner.Completed_Date is not null   
    -- and chg_owner.Approve_Date is null 
    and DocID_Old in (select distinct contract_no from #temp_last_ex_customer_pos_702)
order by olm_segment desc
;
-----------------------------------------------------------------------------------------------------------------
-- step 8 : #temp_last_ex_co_customer_pos ( รวม ทั้ง Active ทั้ง cancel เลย)
--          case สัญญา complete          
--               8.1 nbfo2.pos.IR_AddRemove_Owner.remove_customer_id1,2,3,4 
                --      stauts in ('Approved') 
                --      and completed_date is not null
                --      and ar_type= 'สละชื่อ'
                --      and remove.completed_date >= last_cust.Completed_Date
                --      source : #temp_last_customer_pos
                --  8.2 สัญญาที่ยกเลิก 
                --      source :   7.2 สัญญา cancel แต่เคยทำสำเร็จแล้ว (มี completed_date) #temp_last_ex_customer_pos_702       

-- select status,* from nbfo2.rem.V_ContractData where contract_no = 'C000003345';
-----------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_last_ex_customer_pos_8') IS NOT NULL) DROP TABLE #temp_last_ex_customer_pos_8;
-----------------------------------------------------------------------------------------------------------------

select  
        ar_owner.PJ_CODE
        ,ar_owner.PD_CODE
        ,coalesce(ar_owner.Contract_No,chg_owner.contract_no) as contract_no
        ,ar_owner.Completed_Date
        ,ar_owner.Replace_Status
        ,ar_owner.remove_customer_id as customer_id
        ,8 as olm_segment             -- add remove_owner จะเปลี่ยนเฉพาะ customer_1-4 เท่านั้น
 -------------------------------------------
        into #temp_last_ex_customer_pos_8
 -------------------------------------------
from nbfo2.pos.IR_AddRemove_Owner  with(nolock)
    UNPIVOT
        (
            remove_customer_id for remove_customer_id_rank in (Remove_Customer_ID1, Remove_Customer_ID2, Remove_Customer_ID3, Remove_Customer_ID4)            
        ) as ar_owner
    left join (select distinct DocID_Old as contract_no,changeowner_no from nbfo2.pos.IR_ChangeOwnerDoc with(nolock))  chg_owner
        on ar_owner.ChangeOwner_No = chg_owner.changeowner_no  
    left join (select customer_id from nbfo2.pos.pp_customer with(nolock)) pp_cust
        on ar_owner.remove_customer_id = pp_cust.customer_id
    inner JOIN
            (
                select contract_no,'completed' as status from #temp_last_customer_pos
                union
                select contract_no,'cancel' as status from #temp_last_ex_customer_pos_702
            ) all_contract 
    on coalesce(ar_owner.Contract_No,chg_owner.contract_no) = all_contract.contract_no
where ar_owner.iar_type = 'R'  -- สละชื่อ
    and ar_owner.Completed_Date is not null
    and pp_cust.Customer_ID is not null
    and ar_owner.NBS_ID = 111    -- 111 = completed    fk nbct.nbct.nbs_status
;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 2026.05.07  : ถึง step นี้ segment ที่เพิ่มขึ้นจะไม่เกี่ยวกับส่วนนี้ เพราะส่วนนี้จะเป็นของ POS เป็นหลัก
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------
-- step 9,10 noble id asset authorize(A -9), Family (F -10), tenant (T -10  ) 
-----------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_nbid_segment_09') IS NOT NULL) DROP TABLE #temp_nbid_segment_09;
-----------------------------------------------------------------------------------------------------------------
-- IF (OBJECT_ID (N'tempdb..#temp_owner_nbid') IS NOT NULL) DROP TABLE #temp_owner_nbid;

 select distinct
        pp_cust.Customer_ID as pos_customer_id
        ,pp_cust.OLM_ID  as pos_olm_id  
        ,asset.olm_id
       -- ,asset.customer_id
        ,asset.pj_code
        ,asset.pd_code
        ,upper(asset.Permission) as Permission
        ,asset.status
        ,asset.email
        ,asset.source
        ,case when asset.source = 'CMS' then 1  --เป็นการบันทึกจาก julistic
            when asset.source = 'POS' then 2    --เป็นการบันทึกจากการตรวจสอบจาก pos 
            else   3
        end source_priority
        ,createdate
        -- ,row_number() over (partition by asset.pj_code, asset.pd_code, asset.permission order by 
        --     case when asset.source = 'CMS' then 1 
        --         when asset.source = 'POS' then 2
        --         else   3
        --     end ,pp_cust.customer_id )
        -- as rec_rank
        ,inv.pd_code as inv_pd_code
        ,case when upper(asset.Permission) = 'A' then 9
               when upper(asset.Permission) in ( 'T') then 11          --2026.05.13 เปลี่ยนจาก (t,f) =10  tenant-main = 11
               when upper(asset.Permission) in ( 'F') then 10          --2026.05.13 เปลี่ยนจาก (t,f) =10  family      = 10 
               else 99999  
        end as olm_segment
 -------------------------------------------
         into  #temp_nbid_segment_09
 -------------------------------------------
    -- select distinct asset.permission
    from [DBPOBK.NBDS.COM].[noble_id_member].[dbo].[nb_id_asset] asset with(nolock)
        left join nbfo2.pos.PP_Customer pp_cust with(nolock)
            on asset.olm_id = pp_cust.OLM_ID
        left join nbfo2.app_bi.dwh_inventory_v03 inv with(nolock)
            on asset.pj_code = inv.pj_code
                and asset.pd_code = inv.pd_code 

    where asset.pd_code is not null
        and asset.permission <> 'O'  --owner
        and asset.pd_code not like 'Test%'
       -- and asset.source = 'CMS'
        and pp_cust.Customer_ID is not null
        and inv.pd_code IS NOT NULL
        and pp_cust.OLM_ID  = asset.olm_id
        and asset.status = 'Active'
        and upper(asset.permission) in ('T','A','F')  -- tenant, authorized person, family
      --0  and asset.status = 'Active'
;

-----------------------------------------------------------------------------------------------------------------
-- step 10   postspect(11) & lead(12) --> 
-- soruce 
--     postspect(11) = PP_Visit
--     lead(12)  =  PP_Opportunity 
-----------------------------------------------------------------------------------------------------------------
IF (OBJECT_ID (N'tempdb..#temp_prospect_lead_10') IS NOT NULL) DROP TABLE #temp_prospect_lead_10;
-----------------------------------------------------------------------------------------------------------------


select *
 -------------------------------------------
         into  #temp_prospect_lead_10
 -------------------------------------------
from 
(
    select distinct
            visit.pj_code
            ,visit.customer_id
            ,17 as olm_segment   -- postspect 2026.05.13 เปลี่ยนจาก 11->17
    from nbfo2.pos.PP_Visit visit with(nolock)
        left join nbfo2.pos.PP_Customer pp_cust with(nolock)
            on visit.customer_id = pp_cust.customer_id
    where pp_cust.Customer_ID is not null   -- เผื่อเช็คว่า ไม่มีใน pp_customer
    UNION
    select distinct
            opp.pj_code
            ,opp.customer_id
            ,18 as olm_segment   -- lead   2026.05.13 เปลี่ยนจาก 11->17 
    from nbfo2.pos.PP_Opportunity opp with(nolock)
        left join nbfo2.pos.PP_Customer pp_cust with(nolock)
            on opp.customer_id = pp_cust.customer_id       
    where pp_cust.Customer_ID is not null   -- เผื่อเช็คว่า ไม่มีใน pp_customer
) prospect_lead_data

;

create index idx_temp_prospect_lead_10_01 on #temp_prospect_lead_10(customer_id, pj_code , olm_segment);

-------------------------------------------------------------------------------------------------
-- รวม 
/*
-------------------------------------------------------------------------------------------------
 IF (OBJECT_ID (N'tempdb..#temp_mst_segment') IS NOT NULL) DROP TABLE #temp_mst_segment;



select *
    into #temp_mst_segment
from 
(
select 1  as sub_segment_id ,'Owner' as sub_segment_name                , 1 as segment_id ,'Customer' as segment_name , 1 as priority_order_sub_segment_id  ,1 as priority_order_segment_id
UNION
select 2  as sub_segment_id ,'Co-Owner' as sub_segment_name             , 1 as segment_id ,'Customer' as segment_name, 2 as priority_order_sub_segment_id   ,1 as priority_order_segment_id
UNION
select 3  as sub_segment_id ,'Ex Owner' as sub_segment_name             , 1 as segment_id ,'Customer' as segment_name, 3 as priority_order_sub_segment_id   ,1 as priority_order_segment_id
UNION
select 4  as sub_segment_id ,'Ex Co-Owner' as sub_segment_name          , 1 as segment_id ,'Customer' as segment_name, 4 as priority_order_sub_segment_id   ,1 as priority_order_segment_id
UNION
select 5  as sub_segment_id ,'Last Customer' as sub_segment_name        , 1 as segment_id ,'Customer' as segment_name, 5 as priority_order_sub_segment_id   ,1 as priority_order_segment_id
UNION
select 6  as sub_segment_id ,'Last Co-Customer' as sub_segment_name     , 1 as segment_id ,'Customer' as segment_name, 6 as priority_order_sub_segment_id   ,1 as priority_order_segment_id
UNION
select 7  as sub_segment_id ,'Ex Customer' as sub_segment_name          , 1 as segment_id ,'Customer' as segment_name, 7 as priority_order_sub_segment_id   ,1 as priority_order_segment_id
UNION
select 8  as sub_segment_id ,'Ex Co-Customer' as sub_segment_name       , 1 as segment_id ,'Customer' as segment_name, 8 as priority_order_sub_segment_id   ,1 as priority_order_segment_id
UNION
select 9  as sub_segment_id ,'Family / Tenant' as sub_segment_name      , 3 as segment_id ,'Lead' as segment_name, 9 as priority_order_sub_segment_id       ,3 as priority_order_segment_id   -- Lead/Prospect/UI/NULL
UNION
select 10  as sub_segment_id ,'Authorize Person' as sub_segment_name    , 3 as segment_id ,'Lead' as segment_name, 10 as priority_order_sub_segment_id      ,3 as priority_order_segment_id   
UNION
select 11  as sub_segment_id ,'Postpect' as sub_segment_name            , 2 as segment_id ,'Postpect' as segment_name, 11 as priority_order_sub_segment_id  ,2 as priority_order_segment_id
UNION
select 12  as sub_segment_id ,'Lead' as sub_segment_name                , 3 as segment_id ,'Lead' as segment_name, 12 as priority_order_sub_segment_id      ,3 as priority_order_segment_id
UNION
select 13  as sub_segment_id ,'Guest' as sub_segment_name               , 4 as segment_id ,'UI / NULL' as segment_name, 13 as priority_order_sub_segment_id ,4 as priority_order_segment_id
) segment
;
create index idx_segment_01 on #temp_mst_segment(sub_segment_id,priority_order_segment_id);
----------------------------------------------------------------
*/

 IF (OBJECT_ID (N'tempdb..#temp_segment_rawdata') IS NOT NULL) DROP TABLE #temp_segment_rawdata;

select rawdata.*
    ,row_number()over(partition by rawdata.pj_code, rawdata.pd_code, rawdata.customer_id order by rawdata.segment_olm ,rawdata.pos_segment_id, rawdata.ct asc) as my_rank
    into #temp_segment_rawdata
from 
(
select 
        owner.pj_code 
        ,owner.pd_code
        -- ,'xxx' as pd_runno
        ,owner.customer_id
        ,owner.Contract_No as ct
        -- ,1 as pos_segment_id
        -- ,'Customer' as pos_segment_name
        ,owner.olm_segment as segment_olm
        ,owner.pos_segment_id as pos_segment_id           --2026.05.07  เพิ่มขึ้นมาเนื่องจากต้องหา pos_segment_id จาก asset ฝั่ง noble id
        -- ,sg.sub_segment_name 
        -- ,owner.*
        ,'#temp_owner_final' as source
from #temp_owner_final owner
--   where pd_code = '024-D'
--   and pj_code = '1032'
UNION all

/*
select *
from  #temp_ex_owner_final ex_owner
-- from  #temp_owner_final
where pj_code = '1046'
and pd_code = '17A7'
*/
select 
    ex_owner.pj_code
    ,ex_owner.pd_code
    ,ex_owner.customer_id
    ,ex_owner.contract_no as ct
    ,ex_owner.olm_segment as segment_olm
   -- ,owner.olm_segment       
    ,1 as pos_segment_id                                  --2026.05.07  เพิ่มขึ้นมา default คนที่มีชื่อในเอกสาร จะเป็นสถานะ customer (1)
    ,'#temp_ex_owner_final' as source
from #temp_ex_owner_final ex_owner
--    left  join #temp_owner_final owner 
--     on ex_owner.pj_code = owner.PJ_CODE
--         and ex_owner.pd_code = owner.PD_CODE
--        --and ex_owner.customer_id = owner.customer_id       
where 1=1
   -- and ex_owner.pd_code is not null
--    and ex_owner.pd_code = '17A7' 
--   and ex_owner.pj_code = '1046'   
UNION all
select 
    distinct 
    last_cust.pj_code
    ,last_cust.PD_CODE
    ,last_cust.customer_id
    ,last_cust.Contract_No as ct
    ,last_cust.olm_segment as segment_olm
    ,1 as pos_segment_id
    ,'#temp_last_customer_pos' as source                                  --2026.05.07  เพิ่มขึ้นมา default คนที่มีชื่อในเอกสาร จะเป็นสถานะ customer (1)    
from #temp_last_customer_pos last_cust
UNION all
--- 
select 
    last_cust701.pj_code
    ,last_cust701.PD_CODE
    ,last_cust701.customer_id
    ,last_cust701.docid_old as ct
    ,last_cust701.olm_segment as segment_olm
    ,1 as pos_segment_id                                  --2026.05.07  เพิ่มขึ้นมา default คนที่มีชื่อในเอกสาร จะเป็นสถานะ customer (1)
    -- ,last_cust701.*
    ,'#temp_last_ex_customer_pos_701' as source
from #temp_last_ex_customer_pos_701 last_cust701
UNION all
select distinct
    last_cust702.pj_code
    ,last_cust702.PD_CODE
    ,last_cust702.customer_id
    ,last_cust702.contract_no as ct
    ,last_cust702.olm_segment as segment_olm
    ,1 as pos_segment_id                                  --2026.05.07  เพิ่มขึ้นมา default คนที่มีชื่อในเอกสาร จะเป็นสถานะ customer (1)
    -- ,last_cust702.*
    ,'#temp_last_ex_customer_pos_702' as source
from #temp_last_ex_customer_pos_702 last_cust702
UNION all
select 
    ex_cust703.pj_code
    ,ex_cust703.PD_CODE
    ,ex_cust703.customer_id
    ,ex_cust703.docId_old as ct
    ,ex_cust703.olm_segment as segment_olm
    ,1 as pos_segment_id                                  --2026.05.07  เพิ่มขึ้นมา default คนที่มีชื่อในเอกสาร จะเป็นสถานะ customer (1)
    ,'#temp_last_ex_customer_pos_703' as source
from #temp_last_ex_customer_pos_703 ex_cust703
UNION all
select 
    ex_cust8.pj_code
    ,ex_cust8.PD_CODE
    ,ex_cust8.customer_id
    ,ex_cust8.contract_no as ct
    ,ex_cust8.olm_segment as segment_olm 
    ,1 as pos_segment_id                                  --2026.05.07  เพิ่มขึ้นมา default คนที่มีชื่อในเอกสาร จะเป็นสถานะ customer (1)
    ,'#temp_last_ex_customer_pos_8' as source
from #temp_last_ex_customer_pos_8 ex_cust8
union all
select 
    nbid_09.pj_code
    ,nbid_09.PD_CODE
    ,nbid_09.pos_customer_id as customer_id
    ,null as ct
    ,nbid_09.olm_segment as segment_olm
    --,999 as pos_segment_id                                  --2026.05.07  ส่วนนี้ต้องตรวจสอบเพิ่ม 
    -- 2026.05.08  แก้ไข โดยตรวจกับ segment  1-8 ว่า จะเป็น customer(1) หรือไม่
    ,case when pos_seg_customer.customer_id is  not null then 1 
        else 4 
        end pos_segment_id
    -- select *
    ,'#temp_nbid_segment_09' as source
from #temp_nbid_segment_09 nbid_09
    left join 
                (
                    select distinct pj_code, pd_code , customer_id ,1 as pos_segment_id
                    from 
                    (
                    select '#temp_owner_pos' as source , pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id   from #temp_owner_pos
                    union
                    -- select '#temp_ex_owner_final' as source , pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id   from #temp_ex_owner_final
                    -- union
                    select top 10 '#temp_last_customer_pos' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_customer_pos
                    union
                    select '#temp_last_ex_customer_pos_701' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_ex_customer_pos_701
                    union
                    select '#temp_last_ex_customer_pos_702' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_ex_customer_pos_702
                    union
                    select '#temp_last_ex_customer_pos_703' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_ex_customer_pos_703
                    UNION
                    select '#temp_last_ex_customer_pos_8' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_ex_customer_pos_8
                    ) pos_seg
                    -- where pj_code = '1049' and pd_code = 'B26A06'
                ) pos_seg_customer
        on nbid_09.pj_code = pos_seg_customer.PJ_CODE
        and nbid_09.pd_code = pos_seg_customer.pd_code 
        and nbid_09.pos_customer_id = pos_seg_customer.customer_id
--------------------------------------------------------------------------------------------------
UNION all
select 
    lead.pj_code
    ,null as pd_code
    ,lead.customer_id as customer_id
    ,null as ct
    ,lead.olm_segment as segment_olm
    ,case when lead.olm_segment = 17 then 2              -- 2026.05.13 เปลี่ยนจาก 11->17
          when lead.olm_segment = 18 then 3              -- 2026.05.13 เปลี่ยนจาก 12->18
          else  999
    end pos_segment_id                                   --2026.05.07  เพิ่มขึ้นมา อ้างอิงจาก olm_segment
    ,'#temp_prospect_lead_10' as source
from #temp_prospect_lead_10 lead

) rawdata 

create index idx_temp_segment_rawdata_customer_id on #temp_segment_rawdata(customer_id);


-- select distinct version  from nbfo2.stg.stg_segment_ep2
-- truncate table nbfo2.stg.stg_segment_ep2;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- additional เพื่อหา master pos_segment
--      -- จะรวม  step 1-8  จาก raw  ยังไม่รวม  step  #temp_owner_nbid; เพราะส่วนนี้จะยังไม่รู้ว่า pos_segment อะไร
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
with pos_segment_customer as 
(
select distinct pj_code, pd_code , customer_id ,1 as pos_segment_id

from 
(
select '#temp_owner_pos' as source , pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id   from #temp_owner_pos
union
-- select '#temp_ex_owner_final' as source , pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id   from #temp_ex_owner_final
-- union
select top 10 '#temp_last_customer_pos' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_customer_pos
union
select '#temp_last_ex_customer_pos_701' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_ex_customer_pos_701
union
select '#temp_last_ex_customer_pos_702' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_ex_customer_pos_702
union
select '#temp_last_ex_customer_pos_703' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_ex_customer_pos_703
UNION
select '#temp_last_ex_customer_pos_8' as source ,  pj_code, pd_code, customer_id,olm_segment ,1 as pos_segment_id from #temp_last_ex_customer_pos_8
) pos_seg
)
select pj_code,pd_code,customer_id ,count(*)
from pos_segment_customer
group by pj_code,pd_code,customer_id
having count(*)>1
*/


-- select distinct pj_code , customer_id , 2 as pos_segment_id 
-- from nbfo2.pos.PP_Visit visit with(nolock)  -- prospect

--  select distinct pj_code, customer_id ,3 as pos_segment_id 
--                     from nbfo2.pos.PP_Opportunity opp with(nolock) --lead
---------------------------------------------------------------------------------------------------------------------------------

--888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
-- select * from #temp_segment_rawdata where source =  '#temp_ex_owner_final'

-- -- audit 1
-- select source,segment_olm, pos_segment_id ,count(*)
-- from #temp_segment_rawdata
-- group by source,segment_olm, pos_segment_id
-- order by 2,1,3

-- select * from #temp_owner_final where contract_no = 'C107500210'
-- select top 10 * from  #temp_segment_rawdata where ct = 'C107500210'

--2026.05.11
IF (OBJECT_ID (N'tempdb..#cmm_customer') IS NOT NULL) DROP TABLE #cmm_customer;
select  *
        into #cmm_customer
from openquery([CUST_MANAGEMENT],'select "NB_Customer_ID", "Sys_Customer_ID" from "customer_management_db"."public"."Customer_System" where "Status" = true and "System_ID" = 1 ') ;

create index idx_cmm_customer_Id on #cmm_customer(sys_customer_id) ;
--888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
declare @version INT;
select @version = coalesce(max(version),0)+1 from nbfo2.stg.stg_segment_ep4 with(nolock);
print @version 

if @version -3 > 0
    BEGIN
        delete from nbfo2.stg.stg_segment_ep4 where version < (@version -3) ;
    end

insert into nbfo2.stg.stg_segment_ep4
select 
        @version as version
        ,getdate() as version_date
        ,final.*
        -- into nbfo2.stg.stg_segment_ep4
FROm

 (
select 
        sg.pj_code 
        ,sg.pd_code 
        ,sg.customer_id
        ,inv.PD_RUNNO as pd_runno
        ,sg.ct
        ,sg.segment_olm
        ,sg.pos_segment_id
        ,sg.source
        ,sg.my_rank 
        ,case when (sg.pj_code is not null and sg.pd_code is not null and inv.PD_RUNNO  is null)  then 0  --case pj_code 1066, J005 , J013 มีการปรับ inventory
             else 
                 1 
           end is_prove_data 
        ,cmm.NB_Customer_ID
      --  ,my_rank
       -- ,row_number()over(partition by sg.pj_code, sg.pd_code, sg.customer_id order by segment_olm asc) as my_rankx
from #temp_segment_rawdata sg  --595844
    left join nbfo2.[REM].[V_Noble_InventoryData] inv 
        on sg.pj_code = inv.pj_code 
        and sg.pd_code = inv.pd_code 
    left join #cmm_customer cmm 
        on sg.customer_id = cmm.sys_customer_id
--where (sg.pj_code is not null and sg.pd_code is not null and inv.PD_RUNNO  is null)  
-- where my_rank = 1 
UNION 
select 
     '1000' as pj_code
     ,null as pd_code
     ,pp_cust.customer_id 
     ,null as pd_runno
     ,null as CT
     ,19 as segment                               -- 2026.05.13 เปลี่ยนจาก 13->19
     ,4 as pos_segment_id
     ,'pj_code = 1000' as source
     , 1 as my_rank
     ,1 as is_prove_data   -- 1= data สามารถใช้งานได้  
     ,cmm.NB_Customer_ID
    --  ,1 as my_rank
    -- select top 10 * 
from nbfo2.pos.PP_Customer pp_cust with(nolock)
    left join 
                (
                    select distinct customer_id 
                    from #temp_segment_rawdata
                ) sg_data
     on pp_cust.Customer_ID = sg_data.customer_id
        left join #cmm_customer cmm 
        on pp_cust.customer_id = cmm.sys_customer_id
where sg_data.customer_id is null 
 ) final      



IF (OBJECT_ID (N'tempdb..#cmm_customer') IS NOT NULL) DROP TABLE #cmm_customer;
IF (OBJECT_ID (N'tempdb..#temp_segment_rawdata') IS NOT NULL) DROP TABLE #temp_segment_rawdata;
IF (OBJECT_ID (N'tempdb..#temp_prospect_lead_10') IS NOT NULL) DROP TABLE #temp_prospect_lead_10;
IF (OBJECT_ID (N'tempdb..#temp_nbid_segment_09') IS NOT NULL) DROP TABLE #temp_nbid_segment_09;
IF (OBJECT_ID (N'tempdb..#temp_last_ex_customer_pos_8') IS NOT NULL) DROP TABLE #temp_last_ex_customer_pos_8;
IF (OBJECT_ID (N'tempdb..#temp_last_ex_customer_pos_703') IS NOT NULL) DROP TABLE #temp_last_ex_customer_pos_703;
IF (OBJECT_ID (N'tempdb..#temp_last_ex_customer_pos_702') IS NOT NULL) DROP TABLE #temp_last_ex_customer_pos_702;
IF (OBJECT_ID (N'tempdb..#temp_last_ex_customer_pos_701') IS NOT NULL) DROP TABLE #temp_last_ex_customer_pos_701;
IF (OBJECT_ID (N'tempdb..#temp_last_customer_pos') IS NOT NULL) DROP TABLE #temp_last_customer_pos;
IF (OBJECT_ID (N'tempdb..#temp_ex_owner_final') IS NOT NULL) DROP TABLE #temp_ex_owner_final;
IF (OBJECT_ID (N'tempdb..#temp_owner_final') IS NOT NULL) DROP TABLE #temp_owner_final;
IF (OBJECT_ID (N'tempdb..#temp_owner_update') IS NOT NULL) DROP TABLE #temp_owner_update;
IF (OBJECT_ID (N'tempdb..#temp_owner_nbid') IS NOT NULL) DROP TABLE #temp_owner_nbid;
IF (OBJECT_ID (N'tempdb..#temp_owner_pos') IS NOT NULL) DROP TABLE #temp_owner_pos;

	
  ----------------------------------
 END
GO


