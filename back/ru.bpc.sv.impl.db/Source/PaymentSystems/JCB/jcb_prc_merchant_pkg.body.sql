create or replace package body jcb_prc_merchant_pkg as
/*********************************************************
 *  Visa outgoing files API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vis_api_incoming_pkg <br />
 *  @headcom
 **********************************************************/
    BULK_LIMIT          constant com_api_type_pkg.t_tiny_id := 1000;

function check_field_length(
    i_merchant_rec           in jcb_api_type_pkg.t_merchant_rec
) return com_api_type_pkg.t_boolean is
    l_result        com_api_type_pkg.t_boolean;
begin
    l_result := com_api_type_pkg.TRUE;
    
    if length(i_merchant_rec.licensee_id) > 6 then
        trc_log_pkg.error (
            i_text          => 'Length of field Licensee ID is longer than specified Length [#1], [#2], [#3]' 
          , i_env_param1    => 6
          , i_env_param2    => i_merchant_rec.licensee_id
          , i_env_param3    => length(i_merchant_rec.licensee_id)
        );
        l_result := com_api_type_pkg.FALSE;
        
    end if;    

    return l_result;
end;

function process_merchant (
    i_merchant_rec           in  jcb_api_type_pkg.t_merchant_rec
  , i_session_file_id        in  com_api_type_pkg.t_long_id
  , i_full_export            in  com_api_type_pkg.t_boolean
  , i_inst_id                in  com_api_type_pkg.t_inst_id
  , i_fee_type               in  com_api_type_pkg.t_dict_value      default null
) return com_api_type_pkg.t_boolean is
    l_line                   com_api_type_pkg.t_text;
begin
    -- If merchant was created, but then removed
    if i_merchant_rec.data_id = '0' then
        trc_log_pkg.debug (
            i_text  => 'Merchant ' || i_merchant_rec.merchant_number || ' was skiped, because it was created, and then was removed.'
        );
        return com_api_type_pkg.FALSE;
    end if;    
        
    if check_field_length(i_merchant_rec  => i_merchant_rec) = com_api_type_pkg.FALSE then 

        trc_log_pkg.debug (
            i_text  => 'Merchant ' || i_merchant_rec.merchant_number || ' was skiped, because it has error in fields.'
        );

        return com_api_type_pkg.FALSE;
    end if;
    
    l_line :=
    -- 1. Record Type
    i_merchant_rec.record_type
    -- 2. Data ID
    || i_merchant_rec.data_id;
        
    if i_full_export = com_api_type_pkg.TRUE then
         
        l_line := l_line 
            -- 3. Reason for Revision
            || i_merchant_rec.reason_for_revision
            -- 4. Reason for Cancellation
            || i_merchant_rec.reason_for_cncl
            -- 5. Effective Date for Cancellation
            || i_merchant_rec.eff_date_for_cncl;

    else
        if i_merchant_rec.data_id = '2' then
        
            l_line := l_line 
                -- 3. Reason for Revision
                || '3';
        else
            l_line := l_line 
                -- 3. Reason for Revision
                || '0';
        end if;
        
        if i_merchant_rec.data_id = '3' then --removed

            l_line := l_line 
                -- 4. Reason for Cancellation
                || '1';

            l_line := l_line 
                -- 5. Effective Date for Cancellation
                || nvl(i_merchant_rec.eff_date_for_cncl, '00000000');
                
        else
            l_line := l_line 
                -- 4. Reason for Cancellation
                || '0';
                
            l_line := l_line 
                -- 5. Effective Date for Cancellation
                || '00000000';
        end if;
    end if;

    l_line := l_line 
    -- 6. Filler
    || itf_api_type_pkg.pad_char(' ', 5, 5)
    -- 7. Merchant Number 
    || itf_api_type_pkg.pad_char(i_merchant_rec.merchant_number, 16, 16)
    -- 8. Merchant Name
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.merchant_name), 25, 25)
    -- 9. Merchant Category Code
    || itf_api_type_pkg.pad_number(i_merchant_rec.mcc, 4, 4)
    -- 10. JCBI SIC Sub Code
    || itf_api_type_pkg.pad_char(i_merchant_rec.jcbi_sic_sub_code, 2, 2)
    -- 11. City Name
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.city_name), 13, 13)
    -- 12. State Code
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.state_code), 3, 3)
    -- 13. Type of Merchant Classification
    || itf_api_type_pkg.pad_number(i_merchant_rec.type_merchant_class, 1, 1)
    -- 14. Area Code (1)
    || itf_api_type_pkg.pad_number(i_merchant_rec.area_code_1, 2, 2)
    -- 15. Area Code (2)
    || itf_api_type_pkg.pad_number(i_merchant_rec.area_code_2, 2, 2)
    -- 16. Filler
    || itf_api_type_pkg.pad_char(' ', 15, 15)
    -- 17. Merchant Postal Code
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.merchant_postal_code), 10, 10)
    -- 18. Merchant Phone Number
    || itf_api_type_pkg.pad_char(i_merchant_rec.merchant_phone_number, 15, 15)
    -- 19. Merchant Address (1)
    || itf_api_type_pkg.pad_char(upper(replace(i_merchant_rec.merchant_address_1, ' ', '')), 30, 30)
    -- 20. Merchant Address (2)
    || itf_api_type_pkg.pad_char(upper(replace(i_merchant_rec.merchant_address_2, ' ', '')), 30, 30)
    -- 21. Merchant Address (3)
    || itf_api_type_pkg.pad_char(upper(replace(i_merchant_rec.merchant_address_3, ' ', '')), 30, 30)
    -- 22. Merchant Address (4)
    || itf_api_type_pkg.pad_char(upper(replace(i_merchant_rec.merchant_address_4, ' ', '')), 30, 30);
    -- 23. Commission Rate
    if i_fee_type is null then
        l_line := l_line || itf_api_type_pkg.pad_number(
                                jcb_cst_merchant_pkg.get_merchant_commission_rate (
                                    i_merchant_rec => i_merchant_rec
                                  , i_inst_id      => i_inst_id)
                              , 6
                              , 6);
    else
        l_line := l_line || itf_api_type_pkg.pad_number(
                                jcb_prc_merchant_pkg.get_merchant_commission_rate (
                                    i_merchant_rec => i_merchant_rec
                                  , i_inst_id      => i_inst_id
                                  , i_fee_type     => i_fee_type)
                              , 6
                              , 6);
    end if;

    l_line := l_line
    -- 24. Floor Limit
    || itf_api_type_pkg.pad_number(i_merchant_rec.floor_limit, 11, 11)
    -- 25. Company Name (1)
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.company_name_1), 25, 25)
    -- 26. Company Name (2)
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.company_name_2), 25, 25)
    -- 27. Company Postal Code
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.company_postal_code), 10, 10)
    -- 28. Company Phone Number
    || itf_api_type_pkg.pad_char(i_merchant_rec.company_phone_number, 15, 15)
    -- 29. Company Address (1)
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.company_address_1), 30, 30)
    -- 30. Company Address (2)
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.company_address_2), 30, 30)
    -- 31. Company Address (3)
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.company_address_3), 30, 30)
    -- 32. Company Address (4)
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.company_address_4), 30, 30)
    -- 33. Merchant Management
    || itf_api_type_pkg.pad_char(i_merchant_rec.merchant_management, 1, 1)
    -- 34. Licensee ID
    || itf_api_type_pkg.pad_number(i_merchant_rec.licensee_id, 6, 6)
    -- 35. Area Code (Country)
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.area_code_country), 3, 3)
    -- 36. Area Code (Continent)
    || itf_api_type_pkg.pad_number(i_merchant_rec.area_code_continent, 1, 1)
    -- 37. Filler
    || itf_api_type_pkg.pad_char('  ', 2, 2)
    -- 38. PT Class Flag
    || itf_api_type_pkg.pad_char(i_merchant_rec.pt_class_flag, 1, 1)
    -- 39. Mag/CRS Flag
    || itf_api_type_pkg.pad_char(i_merchant_rec.mag_crs_flag, 2, 2)
    -- 40. MO Information Flag
    || itf_api_type_pkg.pad_number(i_merchant_rec.mo_information_flag, 1, 1)
    -- 41. CAT/EDC Flag
    || itf_api_type_pkg.pad_number(i_merchant_rec.cat_edc_flag, 1, 1)
    -- 42. D/R Type
    || itf_api_type_pkg.pad_number(i_merchant_rec.d_r_type, 1, 1)
    -- 43. G/R Flag
    || itf_api_type_pkg.pad_number(i_merchant_rec.g_r_flag, 1, 1)
    -- 44. Express C/O Flag
    || itf_api_type_pkg.pad_number(i_merchant_rec.express_flag, 1, 1)
    -- 45. Adv Deposit Flag
    || itf_api_type_pkg.pad_number(i_merchant_rec.adv_deposit_flag, 1, 1)
    -- 46. JL Merchant Flag
    || itf_api_type_pkg.pad_number(i_merchant_rec.jl_merchant_flag, 1, 1)
    -- 47. SP Serv Flag
    || itf_api_type_pkg.pad_number(i_merchant_rec.sp_serv_flag, 1, 1)
    -- 48. MO/TO Flag
    || itf_api_type_pkg.pad_number(i_merchant_rec.mo_to_flag, 1, 1)
    -- 49. Filler
    || itf_api_type_pkg.pad_char(' ', 16, 16)
    -- 50. Filler
    || itf_api_type_pkg.pad_char('  ', 2, 2)
    -- 51. Merchant URL
    || itf_api_type_pkg.pad_char(upper(i_merchant_rec.merchant_url), 255, 255)
    -- 52. Merchant Phone Number
    || itf_api_type_pkg.pad_char(' ', 16, 16)
    -- 53. Customer Service Phone Number
    || itf_api_type_pkg.pad_char(i_merchant_rec.customer_phone_number, 16, 16)
    -- 54. Filler
    || itf_api_type_pkg.pad_char(' ', 63, 63);
        
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => l_line
            , i_sess_file_id  => i_session_file_id
        );
    end if;
    
    return com_api_type_pkg.TRUE;
end;

procedure generate_header(
      i_cmid                 in com_api_type_pkg.t_cmid 
    , i_session_file_id      in com_api_type_pkg.t_long_id
) is
    l_line                 com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text  => 'Generate header start'
    );

    -- 1. Record Type
    l_line := 
    '1'  
    -- 2. Sub System ID
    || 'KM'
    -- 3. OPS Control ID
    || '994'
    -- 4. Input/Output ID
    || 'I'
    -- 5. Serial Number
    || '01'
    -- 6. Filler
    || rpad(' ', 6)
    -- 7. Processing Date
    || to_char(get_sysdate, 'YYMMDD')
    -- 8. Filler
    || '  '
    -- 9. Licensee ID
    || lpad(i_cmid, 6, '0')
    -- 10. Filler
    || rpad(' ', 821);
    
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => l_line
            , i_sess_file_id  => i_session_file_id
        );
    end if;
    
    trc_log_pkg.debug (
        i_text  => 'Generate header end'
    );
    
end;

procedure generate_trailer(
    i_session_file_id      in com_api_type_pkg.t_long_id
  , i_processed_count      in com_api_type_pkg.t_long_id   
) is
    l_line                 com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (
        i_text  => 'Generate trailer start. i_processed_count = ' || i_processed_count
    );

    -- 1. Record Type
    l_line := 
    '8'  
    -- 2. Total Number of Data Records
    || lpad(i_processed_count, 9, '0')
    -- 3. Filler
    || rpad(' ', 840);
    
    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data        => l_line
            , i_sess_file_id  => i_session_file_id
        );
    end if;
    
    trc_log_pkg.debug (
        i_text  => 'Generate trailer end'
    );
    
end;

procedure process (
    i_inst_id               in com_api_type_pkg.t_inst_id
    , i_full_export         in com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
    , i_lang                in com_api_type_pkg.t_dict_value default null
) is
    l_lang                 com_api_type_pkg.t_dict_value;
    l_full_export          com_api_type_pkg.t_boolean;
    l_record_count         com_api_type_pkg.t_long_id   := 0; 
    l_processed_count      com_api_type_pkg.t_long_id   := 0; 
    l_excepted_count       com_api_type_pkg.t_long_id   := 0; 
    l_estimated_count      com_api_type_pkg.t_long_id   := 0; 
    l_total_proc_count     com_api_type_pkg.t_long_id   := 0; 
    l_total_except_count   com_api_type_pkg.t_long_id   := 0; 
    l_merchant_tab         jcb_api_type_pkg.t_merchant_tab; 
    l_cmid                 com_api_type_pkg.t_cmid; 
    l_param_tab            com_api_type_pkg.t_param_tab;
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_sysdate              date;
    l_fee_type             com_api_type_pkg.t_dict_value := null;

    l_inst_id              com_api_type_pkg.t_inst_id_tab;
    l_host_inst_id         com_api_type_pkg.t_inst_id_tab;
    l_network_id           com_api_type_pkg.t_network_tab;
    l_host_id              com_api_type_pkg.t_number_tab;
    l_standard_id          com_api_type_pkg.t_number_tab;
    l_event_tab            num_tab_tpt;      

    cursor evt_objects_merhcnat_cur(i_inst_id com_api_type_pkg.t_inst_id) is
        select o.id
          from evt_event_object o
             , acq_merchant m
             , evt_event e
         where o.split_hash in (select split_hash from com_api_split_map_vw)
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'JCB_PRC_MERCHANT_PKG.PROCESS' 
           and o.eff_date    <= l_sysdate 
           and o.object_id   = m.id 
           and o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and o.event_id    = e.id
           and e.event_type in (acq_api_const_pkg.EVENT_MERCHANT_CREATION, acq_api_const_pkg.EVENT_MERCHANT_CLOSE, acq_api_const_pkg.EVENT_MERCHANT_CHANGE) --('EVNT0200', 'EVNT0220', 'EVNT0230') 
           and o.inst_id     = i_inst_id
           and m.inst_id     = o.inst_id
         order by o.id;

    cursor evt_merchant_cur_count(i_inst_id com_api_type_pkg.t_inst_id) is
        select count(distinct m.id) 
          from evt_event_object o
             , acq_merchant m
             , evt_event e
         where o.split_hash in (select split_hash from com_api_split_map_vw)
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'JCB_PRC_MERCHANT_PKG.PROCESS' 
           and o.object_id   = m.id 
           and o.eff_date    <= l_sysdate 
           and o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and o.event_id    = e.id
           and e.event_type in (acq_api_const_pkg.EVENT_MERCHANT_CREATION, acq_api_const_pkg.EVENT_MERCHANT_CLOSE, acq_api_const_pkg.EVENT_MERCHANT_CHANGE) --('EVNT0200', 'EVNT0220', 'EVNT0230')
           and o.inst_id     = i_inst_id
           and m.inst_id     = o.inst_id;
  
    cursor evt_merchant_cur(i_inst_id com_api_type_pkg.t_inst_id) is
        with action as (
            select t.merchant_id
                 , max(t.is_created) is_created
                 , max(t.is_updated) is_updated
                 , max(t.is_deleted) is_deleted
                 , max(case when t.is_deleted = 1 then t.eff_date else null end) eff_date
              from (      
                select m.id merchant_id
                     , e.event_type
                     , case when e.event_type = acq_api_const_pkg.EVENT_MERCHANT_CREATION then 1 else 0 end is_created
                     , case when e.event_type = acq_api_const_pkg.EVENT_MERCHANT_CHANGE   then 1 else 0 end is_updated
                     , case when e.event_type = acq_api_const_pkg.EVENT_MERCHANT_CLOSE    then 1 else 0 end is_deleted
                     , trunc(o.eff_date) eff_date
                  from evt_event_object o
                     , acq_merchant m
                     , evt_event e
                     , (select column_value as id from table(cast(l_event_tab as num_tab_tpt))) t
                 where o.split_hash in (select split_hash from com_api_split_map_vw)
                   and decode(o.status, 'EVST0001', o.procedure_name, null) = 'JCB_PRC_MERCHANT_PKG.PROCESS' 
                   and o.eff_date    <= l_sysdate 
                   and o.inst_id     = i_inst_id
                   and o.object_id   = m.id 
                   and o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and o.event_id    = e.id
                   and e.event_type in (acq_api_const_pkg.EVENT_MERCHANT_CREATION, acq_api_const_pkg.EVENT_MERCHANT_CLOSE, acq_api_const_pkg.EVENT_MERCHANT_CHANGE) --('EVNT0200', 'EVNT0220', 'EVNT0230')
                   and t.id = o.id
                 order by o.id     
               ) t
            group by merchant_id       
        )    
        select '2' record_type
             , case when is_created = 1 and is_deleted = 1 then '0' --need skip this record
                    when is_deleted = 1 then '3'
                    when is_created = 1 then '1'
                    else '2'
               end data_id
             , '0' reason_for_revision
             , '0' reason_for_cncl
             , to_char(a.eff_date, 'YYYYMMDD') eff_date_cncl -- '00000000'  
             , m.merchant_number
             , m.merchant_name 
             , m.mcc
             , null jcbi_sic_sub_code
             , a.city city_name
             , com_api_country_pkg.get_country_name (i_code => a.country, i_raise_error  => get_false) state_code-- substr(a.region_code, -3) state_code             
             , case when m.mcc in ('6010', '6011') then 1 else 0 end type_merchant_class
             , '00' area_code_1
             , '00' area_code_2
             , a.postal_code merchant_postal_code
             , c.commun_address merchant_phone_number
             , a.street merchant_address_1
             , null merchant_address_2 
             , null merchant_address_3 
             , null merchant_address_4 
             , '0' commission_rate
             , '0' floor_limit
             , substr(com_api_i18n_pkg.get_text ('com_company', 'label', s.object_id, l_lang), 1, 25) company_name_1
             , null company_name_2
             , null company_postal_code
             , null company_phone_number
             , null company_address_1
             , null company_address_2
             , null company_address_3
             , null company_address_4
             , ' ' merchant_management
             , l_cmid licensee_id --cmid
             , com_api_country_pkg.get_country_name (i_code => a.country, i_raise_error  => get_false) area_code_country             
             , '3' area_code_continent
             , ' ' pt_class_flag
             , '  ' mag_crs_flag
             , '0' mo_information_flag
             , '0' cat_edc_flag
             , '0' d_r_type
             , '0' g_r_flag
             , '0' express_flag
             , '0' adv_deposit_flag
             , '0' jl_merchant_flag
             , '0' sp_serv_flag
             , '0' mo_to_flag
             , null merchant_url
             , null customer_phone_number
             , c.product_id
             , m.id merchant_id
          from acq_merchant m
             , prd_contract c 
             , prd_customer s
             , action a 
             , (select a.id
                     , o.address_type
                     , a.country
                     , a.region
                     , a.city
                     , a.street
                     , a.house
                     , a.apartment
                     , a.postal_code
                     , a.place_code
                     , a.region_code
                     , a.lang
                     , o.object_id
                     , row_number() over (partition by o.object_id, o.address_type order by decode(a.lang, l_lang, -1, 'LANGENG', 0, o.address_id)) rn                                                    
                  from com_address_object o
                     , com_address a
                 where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and a.id          = o.address_id
               ) a  
             , (select o.object_id
                     , d.commun_method
                     , d.commun_address
                     , row_number() over (partition by o.object_id, o.contact_type order by decode(c.preferred_lang, l_lang, -1, 'LANGENG', 0, o.contact_id)) rn                                                    
                  from com_contact_object o
                     , com_contact c
                     , com_contact_data d
                 where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and c.id = o.contact_id
                   and c.id = d.contact_id
                   and d.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                   and o.contact_type  = com_api_const_pkg.CONTACT_TYPE_PRIMARY   
             ) c 
         where m.id = a.merchant_id
           and a.object_id    = m.id
           and a.rn           = 1
           and c.object_id(+) = m.id
           and c.rn(+)        = 1
           and m.inst_id      = i_inst_id
           and c.id           = m.contract_id
           and c.customer_id  = s.id
         order by m.merchant_number  
           ;                   
    
    cursor all_merchant_cur(i_inst_id com_api_type_pkg.t_inst_id) is
        select '2' record_type
             , '1' data_id
             , '0' reason_for_revision --set to 0, because for Full export we set data_id = 1 
             , '0' reason_for_cncl
             , '00000000' eff_date_cncl 
             , m.merchant_number
             , m.merchant_name
             , m.mcc
             , null jcbi_sic_sub_code
             , a.city city_name
             , com_api_country_pkg.get_country_name (i_code => a.country, i_raise_error  => get_false) state_code --substr(a.region_code, -3) state_code             
             , case when m.mcc in ('6010', '6011') then 1 else 0 end type_merchant_class
             , '00' area_code_1
             , '00' area_code_2
             , a.postal_code merchant_postal_code
             , c.commun_address merchant_phone_number
             , a.street merchant_address_1
             , null merchant_address_2 
             , null merchant_address_3 
             , null merchant_address_4 
             , '0' commission_rate
             , '0' floor_limit
             , substr(com_api_i18n_pkg.get_text ('com_company', 'label', s.object_id, l_lang), 1, 25) company_name_1
             , null company_name_2
             , null company_postal_code
             , null company_phone_number
             , null company_address_1
             , null company_address_2
             , null company_address_3
             , null company_address_4
             , ' ' merchant_management
             , l_cmid licensee_id --cmid
             , com_api_country_pkg.get_country_name (i_code => a.country, i_raise_error  => get_false) area_code_country             
             , '3' area_code_continent
             , ' ' pt_class_flag
             , '  ' mag_crs_flag
             , '0' mo_information_flag
             , '0' cat_edc_flag
             , '0' d_r_type
             , '0' g_r_flag
             , '0' express_flag
             , '0' adv_deposit_flag
             , '0' jl_merchant_flag
             , '0' sp_serv_flag
             , '0' mo_to_flag
             , null merchant_url
             , null customer_phone_number
             , c.product_id
             , m.id merchant_id
          from acq_merchant m 
             , prd_contract c 
             , prd_customer s
             , (select a.id
                     , o.address_type
                     , a.country
                     , a.region
                     , a.city
                     , a.street
                     , a.house
                     , a.apartment
                     , a.postal_code
                     , a.place_code
                     , a.region_code
                     , a.lang
                     , o.object_id
                     , row_number() over (partition by o.object_id, o.address_type order by decode(a.lang, l_lang, -1, com_api_const_pkg.DEFAULT_LANGUAGE, 0, o.address_id)) rn                                                    
                  from com_address_object o
                     , com_address a
                 where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and a.id          = o.address_id
               ) a  
             , (select o.object_id
                     , d.commun_method
                     , d.commun_address
                     , row_number() over (partition by o.object_id, o.contact_type order by decode(c.preferred_lang, l_lang, -1, com_api_const_pkg.DEFAULT_LANGUAGE, 0, o.contact_id)) rn                                                    
                  from com_contact_object o
                     , com_contact c
                     , com_contact_data d
                 where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and c.id = o.contact_id
                   and c.id = d.contact_id
                   and d.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                   and o.contact_type  = com_api_const_pkg.CONTACT_TYPE_PRIMARY    
             ) c 
         where m.status in (acq_api_const_pkg.MERCHANT_STATUS_ACTIVE, acq_api_const_pkg.MERCHANT_STATUS_SUSPENDED)
           and a.object_id(+) = m.id
           and a.rn(+)        = 1
           and c.object_id(+) = m.id
           and c.rn(+)        = 1
           and m.inst_id      = i_inst_id
           and c.id           = m.contract_id
           and c.customer_id  = s.id
         order by m.merchant_number  
           ;

    cursor all_cur_count(i_inst_id com_api_type_pkg.t_inst_id) is
        select count(1)
          from acq_merchant m 
         where m.status in (acq_api_const_pkg.MERCHANT_STATUS_ACTIVE, acq_api_const_pkg.MERCHANT_STATUS_SUSPENDED) --('MRCS0001', 'MRCS0003')
           and m.inst_id      = i_inst_id;
           

    procedure register_session_file (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_acq_bin             in com_api_type_pkg.t_dict_value
    ) is
    begin
        l_param_tab.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => to_char(i_inst_id)
            , io_params  => l_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => 'NETWORK_ID'
            , i_value    => i_network_id
            , io_params  => l_param_tab
        );
        rul_api_param_pkg.set_param (
            i_name       => 'ACQ_BIN'
            , i_value    => i_acq_bin
            , io_params  => l_param_tab
        );

        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
            , i_file_type   => jcb_api_const_pkg.FILE_TYPE_CLEARING_JCB
            , io_params     => l_param_tab
        );
    end;
begin
    trc_log_pkg.debug (
        i_text  => 'JCB unload merchan start'
    );

    prc_api_stat_pkg.log_start;
    
    l_lang          := nvl(i_lang, com_api_const_pkg.DEFAULT_LANGUAGE);
    l_full_export   := nvl(i_full_export, com_api_type_pkg.FALSE);   
    l_sysdate       := get_sysdate; 
    
    -- get institutions list
    select
        m.id host_id
        , m.inst_id host_inst_id
        , n.id network_id
        , r.inst_id
        , s.standard_id
    bulk collect into
        l_host_id
        , l_host_inst_id
        , l_network_id
        , l_inst_id
        , l_standard_id
    from
        net_network n
        , net_member m
        , net_interface i
        , net_member r
        , cmn_standard_object s
    where
        n.id                 = jcb_api_const_pkg.JCB_NETWORK_ID
        and n.id             = m.network_id
        and n.inst_id        = m.inst_id
        and s.object_id      = m.id
        and s.entity_type    = net_api_const_pkg.ENTITY_TYPE_HOST
        and s.standard_type  = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
        and (r.inst_id = i_inst_id or i_inst_id is null)
        and r.id             = i.consumer_member_id
        and i.host_member_id = m.id;
           
    -- make estimated count
    for i in 1..l_host_id.count loop

        if l_full_export = com_api_type_pkg.TRUE then

            open all_cur_count(l_inst_id(i));
            fetch all_cur_count into l_record_count;
            close all_cur_count;

        else
            open evt_merchant_cur_count(l_inst_id(i));
            fetch evt_merchant_cur_count into l_record_count;
            close evt_merchant_cur_count;

        end if;

        l_estimated_count := l_estimated_count + l_record_count;
    end loop;        

    trc_log_pkg.debug (
        i_text  => 'Estimated count [#1]'
      , i_env_param1    => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_estimated_count
    );
    
    if l_estimated_count > 0 then

        for j in 1..l_host_id.count loop

            -- get cmid
            l_cmid := cmn_api_standard_pkg.get_varchar_value (
                          i_inst_id     => l_inst_id(j)
                        , i_standard_id => l_standard_id(j)
                        , i_object_id   => l_host_id(j)
                        , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
                        , i_param_name  => jcb_api_const_pkg.CMID
                        , i_param_tab   => l_param_tab
                      );
            
            trc_log_pkg.debug (
                i_text  => 'Found cmid [#1], host [#2], standard [#3]'
              , i_env_param1    => l_cmid
              , i_env_param2    => l_host_id(j)
              , i_env_param3    => l_standard_id(j)
            );
            
            l_fee_type := cmn_api_standard_pkg.get_varchar_value (
                              i_inst_id      => l_inst_id(j)
                            , i_standard_id  => l_standard_id(j)
                            , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                            , i_object_id    => l_host_id(j)
                            , i_param_name   => jcb_api_const_pkg.MERCHANT_COMMISS_RATE
                            , i_param_tab    => l_param_tab
                          );    

            if l_full_export = com_api_type_pkg.TRUE then
            
                open all_cur_count(l_inst_id(j));
                fetch all_cur_count into l_record_count;
                close all_cur_count;

                trc_log_pkg.debug (
                    i_text  => 'For inst_id ' || l_inst_id(j) || ' count of records = ' || l_record_count
                );
                
                if l_record_count > 0 then
                
                    l_processed_count := 0;
                    l_excepted_count  := 0;  
                    l_session_file_id := null;
                    
                    register_session_file (
                        i_inst_id         => l_inst_id(j)
                        , i_network_id    => jcb_api_const_pkg.JCB_NETWORK_ID
                        , i_acq_bin       => l_cmid
                    ); 
                        
                    generate_header(
                          i_cmid            => l_cmid 
                        , i_session_file_id => l_session_file_id
                    );

                    open all_merchant_cur(l_inst_id(j));
                         
                    loop
                        fetch all_merchant_cur
                         bulk collect into
                              l_merchant_tab
                        limit BULK_LIMIT;

                        for i in 1..l_merchant_tab.count loop
                            
                            if process_merchant(
                                    i_merchant_rec       => l_merchant_tab(i)
                                    , i_session_file_id  => l_session_file_id 
                                    , i_full_export      => l_full_export
                                    , i_inst_id          => i_inst_id
                                    , i_fee_type         => l_fee_type
                                ) = com_api_type_pkg.FALSE then
                            
                                l_excepted_count := l_excepted_count + 1;
                            
                            else
                                l_processed_count := l_processed_count + 1;        
                            end if;
                            
                        end loop;
                        
                        trc_log_pkg.debug (
                            i_text  => 'l_processed_count = ' || l_processed_count || ', l_merchant_tab.count = '|| l_merchant_tab.count || ', l_excepted_count = ' || l_excepted_count 
                        );

                        exit when all_merchant_cur%notfound;
                    end loop;

                    close all_merchant_cur;
                    
                    trc_log_pkg.debug (
                        i_text  => 'l_processed_count = ' || l_processed_count || ', l_excepted_count = ' || l_excepted_count
                    );

                    generate_trailer(
                        i_session_file_id   => l_session_file_id
                      , i_processed_count   => l_processed_count  
                    );
                              
                    l_total_proc_count   := l_total_proc_count + l_processed_count; 
                    l_total_except_count := l_total_except_count + l_excepted_count;
                        
                    prc_api_stat_pkg.log_current (
                        i_current_count     => l_total_proc_count
                        , i_excepted_count  => l_total_except_count
                    );
                    
                    trc_log_pkg.debug (
                        i_text  => 'l_total_proc_count = ' || l_total_proc_count || ', l_total_except_count = ' || l_total_except_count
                    );
                         
                    if l_processed_count = 0 then
                        prc_api_file_pkg.remove_file (
                            i_sess_file_id  => l_session_file_id
                          , i_file_type     => jcb_api_const_pkg.FILE_TYPE_CLEARING_JCB
                        );
                    else   
                        prc_api_file_pkg.close_file (
                            i_sess_file_id  => l_session_file_id
                          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                        );
                        
                    end if;    
                end if;            
                
            else
                -- incremental
                open evt_objects_merhcnat_cur(l_inst_id(j)); --incremental
                fetch evt_objects_merhcnat_cur bulk collect into l_event_tab;
                close evt_objects_merhcnat_cur;
                
                trc_log_pkg.debug (
                    i_text  => 'l_event_tab.count = ' || l_event_tab.count
                );
                
                open evt_merchant_cur_count(l_inst_id(j));
                fetch evt_merchant_cur_count into l_record_count;
                close evt_merchant_cur_count;

                trc_log_pkg.debug (
                    i_text  => 'For inst_id ' || l_inst_id(j) || ' count of records = ' || l_record_count
                );
                
                if l_record_count > 0 then
                
                    l_processed_count := 0;
                    l_excepted_count  := 0;
                    l_session_file_id := null;
                    
                    register_session_file (
                        i_inst_id         => l_inst_id(j)
                        , i_network_id    => jcb_api_const_pkg.JCB_NETWORK_ID
                        , i_acq_bin       => l_cmid
                    ); 
                        
                    generate_header(
                          i_cmid            => l_cmid 
                        , i_session_file_id => l_session_file_id
                    );
                    
                    open evt_merchant_cur(l_inst_id(j));
                    
                        fetch evt_merchant_cur
                         bulk collect into
                              l_merchant_tab;
                         
                    for i in 1..l_merchant_tab.count loop
                            
                        if process_merchant(
                                i_merchant_rec       => l_merchant_tab(i)
                                , i_session_file_id  => l_session_file_id 
                                , i_full_export      => l_full_export
                                , i_inst_id          => i_inst_id
                                , i_fee_type         => l_fee_type
                            ) = com_api_type_pkg.FALSE then
                            
                            l_excepted_count := l_excepted_count + 1;
                            
                        else
                            l_processed_count := l_processed_count + 1;        
                        end if;
                            
                    end loop;

                    close evt_merchant_cur;

                    generate_trailer(
                        i_session_file_id   => l_session_file_id
                      , i_processed_count   => l_processed_count  
                    );

                    l_total_proc_count   := l_total_proc_count + l_processed_count; 
                    l_total_except_count := l_total_except_count + l_excepted_count;
                        
                    prc_api_stat_pkg.log_current (
                        i_current_count     => l_total_proc_count
                        , i_excepted_count  => l_total_except_count
                    );
                              
                    trc_log_pkg.debug (
                        i_text  => 'l_total_proc_count = ' || l_total_proc_count || ', l_total_except_count = ' || l_total_except_count
                    );
                         
                    if l_processed_count = 0 then
                        prc_api_file_pkg.remove_file (
                            i_sess_file_id  => l_session_file_id
                          , i_file_type     => jcb_api_const_pkg.FILE_TYPE_CLEARING_JCB
                        );
                    else   
                        prc_api_file_pkg.close_file (
                            i_sess_file_id  => l_session_file_id
                          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                        );
                        
                    end if;    

                    evt_api_event_pkg.process_event_object(
                        i_event_object_id_tab => l_event_tab
                    );
                     
                end if;                
            end if;
            
        end loop;        
    end if;
    
    prc_api_stat_pkg.log_end(
        i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        , i_processed_total  => l_total_proc_count
    );

    trc_log_pkg.debug (
        i_text  => 'JCB unload merchan end'
    );

exception
    when others then
        if all_merchant_cur%isopen then
            close all_merchant_cur;
        end if;

        if evt_merchant_cur%isopen then
            close evt_merchant_cur;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end;

function get_merchant_commission_rate (
    i_merchant_rec         in  jcb_api_type_pkg.t_merchant_rec
  , i_inst_id              in  com_api_type_pkg.t_inst_id         default null
  , i_fee_type             in  com_api_type_pkg.t_dict_value      default null
) return com_api_type_pkg.t_tag is
    l_inst_id                  com_api_type_pkg.t_inst_id         := null;
    l_fee_type                 com_api_type_pkg.t_dict_value      := null;
    l_host_id                  com_api_type_pkg.t_tiny_id         := null;
    l_fee_id                   com_api_type_pkg.t_long_id         := null;
    l_rate                     com_api_type_pkg.t_auth_code       := null;
    l_rate_part_1              com_api_type_pkg.t_auth_code       := null;
    l_rate_part_2              com_api_type_pkg.t_auth_code       := null;
    l_params                   com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug (
        i_text  => 'get_merchant_commission_rate: ' 
                || 'i_inst_id [' || i_inst_id 
                || '], i_fee_type [' || i_fee_type || ']'
    );

    if i_inst_id is null then
        l_inst_id := jcb_api_const_pkg.NATIONAL_PROC_CENTER_INST;
    else
        l_inst_id := i_inst_id;
    end if;

    if i_fee_type is null then
        l_host_id := net_api_network_pkg.get_host_id (
            i_inst_id     => l_inst_id
          , i_network_id  => jcb_api_const_pkg.JCB_NETWORK_ID
        );

        l_fee_type := cmn_api_standard_pkg.get_varchar_value (
            i_inst_id      => l_inst_id
          , i_standard_id  => jcb_api_const_pkg.STANDARD_ID
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id    => l_host_id
          , i_param_name   => jcb_api_const_pkg.MERCHANT_COMMISS_RATE
          , i_param_tab    => l_params
        );    
        l_fee_type := nvl(l_fee_type, jcb_api_const_pkg.MERCHANT_DEFAULT_FEE_TYPE);

        trc_log_pkg.debug (
            i_text  => 'Found fee type [' || l_fee_type || '] for host [' || l_host_id || ']'
        );
    else
        l_fee_type := i_fee_type;
    end if;

    rul_api_param_pkg.set_param (
        io_params  => l_params
      , i_name     => 'MERCHANT_NUMBER'
      , i_value    => i_merchant_rec.merchant_number
    );

    rul_api_param_pkg.set_param (
        io_params  => l_params
      , i_name     => 'MCC'
      , i_value    => i_merchant_rec.mcc
    );

    l_fee_id := prd_api_product_pkg.get_fee_id (
        i_product_id   => i_merchant_rec.product_id
      , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id    => i_merchant_rec.merchant_id
      , i_fee_type     => l_fee_type
      , i_params       => l_params
      , i_inst_id      => l_inst_id
    );
           
    select min(percent_rate) 
      into l_rate 
      from fcl_fee_tier
     where fee_id = l_fee_id;

    if l_rate is null then
        trc_log_pkg.error (
            i_text         => 'FEE_RATE_NOT_FOUND'
          , i_env_param1   => l_fee_id
          , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id    => i_merchant_rec.merchant_id
          , i_inst_id      => l_inst_id
        );
        return '000000';
    end if;
    
    l_rate := replace(l_rate, ',', '.');
    l_rate_part_1 := lpad(substr(l_rate, 1, instr(l_rate, '.') - 1), 3, '0');
    l_rate_part_2 := rpad(substr(l_rate, instr(l_rate, '.') + 1), 3, '0');
    l_rate := l_rate_part_1 || l_rate_part_2;

    trc_log_pkg.debug (
        i_text  => 'Commission Rate [' || l_rate || '].'
    );

    return l_rate;

exception
    when no_data_found then
        trc_log_pkg.error (
            i_text         => 'FEE_RATE_NOT_FOUND'
          , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
        );
        return '000000';
    when com_api_error_pkg.e_application_error then
        trc_log_pkg.error (
            i_text         => sqlerrm 
        );
        return '000000';         
end;

end;
/
