create or replace package body cst_sat_prc_acs_enrollment_pkg
is

BULK_LIMIT              constant integer := 400;

procedure export_card_info(
    i_inst_id   in  com_api_type_pkg.t_inst_id      default ost_api_const_pkg.DEFAULT_INST
  , i_lang      in  com_api_type_pkg.t_dict_value   default null
) is
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_line                  com_api_type_pkg.t_raw_data;
    l_sysdate               date;
    l_event_tab             com_api_type_pkg.t_number_tab;

    l_session_file_id       com_api_type_pkg.t_long_id;
    l_raw_data_tab          com_api_type_pkg.t_raw_tab;
    l_rec_num_tab           com_api_type_pkg.t_integer_tab;
    l_rec_num               com_api_type_pkg.t_long_id := 0;
    l_subscriber            com_api_type_pkg.t_name;
    
    l_i                     pls_integer := 0;

    procedure flush_file is
    begin
        trc_log_pkg.debug('cst_sat_prc_acs_enrollment_pkg.export_card_info, raw_tab.count='||l_raw_data_tab.count);
        prc_api_file_pkg.put_bulk(
            i_sess_file_id  => l_session_file_id
          , i_raw_tab       => l_raw_data_tab
          , i_num_tab       => l_rec_num_tab
        );
        l_raw_data_tab.delete;
        l_rec_num_tab.delete;
    end flush_file;

    procedure put_line(
        i_line                  in com_api_type_pkg.t_raw_data
    ) is
    begin
        l_rec_num                  := l_rec_num + 1;
        l_raw_data_tab(l_rec_num)  := i_line;
        l_rec_num_tab(l_rec_num)   := l_rec_num;
        trc_log_pkg.info('cst_sat_prc_acs_enrollment_pkg.export_card_info: line ' || l_rec_num || '=' || i_line);

        if mod(l_rec_num, BULK_LIMIT) = 0 then
            flush_file;
        end if;
    end put_line;

begin
    trc_log_pkg.debug('start unloading acs enrollment');

    prc_api_stat_pkg.log_start;

    l_sysdate    := com_api_sttl_day_pkg.get_sysdate;  
    l_subscriber := 'CST_SAT_PRC_ACS_ENROLLMENT_PKG.EXPORT_CARD_INFO';

    for r in (select card_number
                   , expir_date
                   , first_name
                   , surname
                   , email
                   , address_line1
                   , address_line2
                   , address_line3
                   , otp_address
                   , contract_number
                   , account_number
                   , card_istate
                   , auth_method
                   , service_status
                   , event_log_id
                   , imaj
                   , card_status
                   , row_number
                   , count(*) over() cnt
                from (with b
                      as (select c.card_number
                               , i.expir_date
                               , p.first_name
                               , p.surname
                               , t.contract_number
                               , t.product_id
                               , c.customer_id
                               , c.cardholder_id
                               , c.id     as card_id
                               , i.split_hash
                               , i.state  as card_istate
                               , row_number() over (partition by o.object_id order by o.event_timestamp desc) as rn
                               , o.event_id
                               , o.id     as event_log_id
                               , decode(o.event_id, 7001, 'A', 1046, 'S', 'M') as imaj
                               , decode(i.status, 'CSTS0000', 'E', 'U') as card_status
                            from evt_event_object   o
                               , evt_event          e
                               , iss_card_vw        c
                               , iss_card_instance  i
                               , prd_contract       t
                               , iss_cardholder     h
                               , com_person         p
                           where decode(o.status, 'EVST0001', o.procedure_name, null) = l_subscriber
                             and ((o.inst_id = i_inst_id) or (nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST) = ost_api_const_pkg.DEFAULT_INST))
                             and ((o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD and o.object_id = i.card_id)
                                  or
                                  (o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE and o.object_id = i.id)
                                 )
                             and o.split_hash          = i.split_hash
                             and o.eff_date           <= l_sysdate
                             and o.event_id            = e.id
                             and i.split_hash         in (select split_hash from com_api_split_map_vw)
                             and (c.id, c.split_hash) in ((i.card_id, i.split_hash))
                             and c.contract_id         = t.id
                             and t.split_hash          = i.split_hash
                             and c.cardholder_id       = h.id
                             and h.person_id           = p.id)
                       , a
                      as (select e.object_id as cardholder_id
                               , s.street    as address_line1
                               , s.city      as address_line2
                               , s.region    as address_line3
                            from com_address_object e
                               , com_address        s
                               , b
                           where b.rn            = 1
                             and e.object_id     = b.cardholder_id
                             and e.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                             and e.address_type  = com_api_const_pkg.ADDRESS_TYPE_HOME
                             and s.id            = e.address_id)
                       , n
                      as (select card_id
                               , auth_method
                               , otp_address
                            from (select w.card_id, w.attr_name, w.attr_value
                                    from (select b.card_id as card_id
                                               , v.attr_name
                                               , u.attr_value, u.start_date, u.end_date
                                               , row_number() over (partition by b.card_id, v.attr_name order by u.start_date desc, u.id desc) as rn
                                            from prd_attribute_value u
                                               , prd_attribute       v
                                               , b
                                           where b.rn           = 1
                                             and (u.entity_type, u.object_id) in ((iss_api_const_pkg.ENTITY_TYPE_CARD, b.card_id), (prd_api_const_pkg.ENTITY_TYPE_PRODUCT, b.product_id))
                                             and  u.attr_id     = v.id
                                             and  v.attr_name  in ('3D_SECURE_AUTHENTICATION_METHOD', '3D_SECURE_OTP_ADDRESS')
                                             and (u.start_date is null or u.start_date <= l_sysdate)
                                             and (u.end_date   is null or u.end_date   >  l_sysdate)) w
                                   where w.rn = 1)
                           pivot (max(attr_value) for attr_name in ('3D_SECURE_AUTHENTICATION_METHOD' as auth_method, '3D_SECURE_OTP_ADDRESS' as otp_address)))
                       , q
                      as (select customer_id
                               , email
                            from (select j.object_id      as customer_id
                                       , d.commun_address as email
                                       , row_number() over (partition by j.object_id order by j.contact_type, d.start_date desc, d.id desc) as rn
                                    from com_contact_object j
                                       , com_contact_data   d
                                       , b
                                   where b.rn             = 1
                                     and j.object_id      = b.customer_id
                                     and j.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                     and j.contact_type  in (com_api_const_pkg.CONTACT_TYPE_NOTIFICATION, com_api_const_pkg.CONTACT_TYPE_PRIMARY)
                                     and j.contact_id     = d.contact_id
                                     and d.commun_method  = com_api_const_pkg.COMMUNICATION_METHOD_EMAIL
                                     and (d.start_date   is null or d.start_date <= l_sysdate)
                                     and (d.end_date     is null or d.end_date    > l_sysdate))
                           where rn = 1)
                  select b.card_number                                                          as card_number
                       , b.expir_date                                                           as expir_date
                       , b.first_name                                                           as first_name
                       , b.surname                                                              as surname
                       , q.email                                                                as email
                       , a.address_line1                                                        as address_line1
                       , a.address_line2                                                        as address_line2
                       , a.address_line3                                                        as address_line3
                       , n.otp_address                                                          as otp_address
                       , b.contract_number                                                      as contract_number
                       , case b.rn
                           when 1 then (select k.account_number
                                          from acc_account_object l
                                             , acc_account        k
                                         where (l.object_id, l.split_hash) in ((b.card_id, b.split_hash))
                                           and l.entity_type                = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and l.split_hash                 = b.split_hash
                                           and l.account_id                 = k.id
                                           and rownum                       = 1)
                                  else null
                          end                                                                   as account_number
                       , b.card_istate                                                          as card_istate
                       , n.auth_method                                                          as auth_method
                       , case b.rn
                           when 1 then (select g.status
                                          from prd_service_type   y
                                             , prd_service        r
                                             , prd_service_object g
                                             , b
                                         where y.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and y.id              = ntf_api_const_pkg.THREE_D_SECURE_CARD_SERVICE --3DS service type
                                           and r.service_type_id = y.id
                                           and g.service_id      = r.id
                                           and g.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           and (g.object_id, g.split_hash) in ((b.card_id, b.split_hash))
                                           and rownum = 1)
                                  else null
                          end                                                                   as service_status
                       , b.rn                                                                   as row_number
                       , b.event_log_id                                                         as event_log_id
                       , b.imaj
                       , b.card_status
                    from b
                       , a
                       , n
                       , q
                   where b.cardholder_id = a.cardholder_id(+)
                     and b.card_id       = n.card_id
                     and b.customer_id   = q.customer_id  (+)))
    loop

        if l_session_file_id is null then
            prc_api_stat_pkg.log_estimation(i_estimated_count  => r.cnt);
                  
            prc_api_file_pkg.open_file(o_sess_file_id  => l_session_file_id);
            trc_log_pkg.debug('l_session_file_id=' || l_session_file_id);
        end if;

        l_i := l_i + 1;
        l_event_tab(l_i) := r.event_log_id;

        if r.row_number = 1 then
            l_line := r.imaj;
            l_line := l_line || rpad(r.card_number,     16, ' ');
            l_line := l_line || to_char(trunc(r.expir_date), 'yyyymmdd');
            l_line := l_line || rpad(nvl(r.first_name,     ' '),  30, ' ');
            l_line := l_line || rpad(nvl(r.surname,        ' '),  30, ' ');
            l_line := l_line || rpad(nvl(r.email,          ' '), 100, ' ');
            l_line := l_line || rpad(nvl(r.address_line1,  ' '),  40, ' ');
            l_line := l_line || rpad(nvl(r.address_line2,  ' '),  40, ' ');
            l_line := l_line || rpad(nvl(r.address_line3,  ' '),  40, ' ');
            l_line := l_line || rpad(nvl(r.otp_address,    ' '),  15, ' ');
            l_line := l_line || rpad(substr(r.contract_number, -15), 15, ' ');
            l_line := l_line || rpad(nvl(r.account_number, ' '),  20, ' ');
            l_line := l_line || r.card_status;
            l_line := l_line || r.card_istate;
            l_line := l_line || r.auth_method;
            l_line := l_line || r.service_status;

            put_line(l_line);

            l_processed_count := l_processed_count + 1;
        end if;

    end loop;

    prc_api_stat_pkg.log_current(
        i_current_count  => l_processed_count
      , i_excepted_count => 0
    );

    if l_session_file_id is not null then
        flush_file;
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
        l_session_file_id  := null;
    end if;

    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab    => l_event_tab
    );

    trc_log_pkg.debug('cst_sat_prc_acs_enrollment_pkg.export_card_info: FINISH' );

    prc_api_stat_pkg.log_end(
        i_excepted_total  => 0
      , i_processed_total => l_processed_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS 
    );

    commit;

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_excepted_total  => 0
          , i_processed_total => l_processed_count
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED 
        );
        
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end export_card_info;

end cst_sat_prc_acs_enrollment_pkg;
/
