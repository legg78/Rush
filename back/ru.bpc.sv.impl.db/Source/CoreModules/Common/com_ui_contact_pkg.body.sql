create or replace package body com_ui_contact_pkg as
/************************************************************
 * UI for Contacts <br />
 * Created by Khougev A.(khougaev@bpc.ru)  at 19.03.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_CONTACT_PKG <br />
 * @headcom
 ************************************************************/
procedure register_event(
    i_contact_id        in      com_api_type_pkg.t_long_id
  , i_contact_data_id   in      com_api_type_pkg.t_long_id  default null
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    for rec in (
        select c.id
             , c.inst_id
             , c.split_hash
          from com_contact_object o
             , prd_customer c
         where o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and o.contact_id  = i_contact_id
           and c.id          = o.object_id
         union
        select c.id
             , c.inst_id
             , c.split_hash 
          from com_contact_object o
             , iss_cardholder h
             , prd_customer c
         where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
           and o.object_id   = h.id
           and h.person_id   = c.object_id
           and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
           and o.contact_id  = i_contact_id
    ) loop
        evt_api_event_pkg.register_event(
            i_event_type      => prd_api_const_pkg.EVENT_CUSTOMER_MODIFY
          , i_eff_date        => get_sysdate
          , i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id       => rec.id
          , i_inst_id         => rec.inst_id
          , i_split_hash      => rec.split_hash
          , i_param_tab       => l_param_tab
        );
        if i_contact_data_id is not null then
            for r_cdata in (
                select cntr.product_id
                     , prd.product_type
                  from prd_contract cntr
                     , prd_product prd
                 where cntr.customer_id = rec.id
                   and prd.id           = cntr.product_id
            ) loop
                rul_api_param_pkg.set_param(
                    i_name    => 'PRODUCT_ID'
                  , i_value   => r_cdata.product_id
                  , io_params => l_param_tab
                );
                rul_api_param_pkg.set_param(
                    i_name    => 'PRODUCT_TYPE'
                  , i_value   => r_cdata.product_type
                  , io_params => l_param_tab
                );
                rul_api_param_pkg.set_param(
                    i_name    => 'SRC_ENTITY_TYPE'
                  , i_value   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , io_params => l_param_tab
                );
                rul_api_param_pkg.set_param(
                    i_name    => 'SRC_OBJECT_ID'
                  , i_value   => rec.id
                  , io_params => l_param_tab
                );
                evt_api_event_pkg.register_event(
                    i_event_type      => com_api_const_pkg.EVENT_TYPE_CON_DATA_CHANGED
                  , i_eff_date        => get_sysdate
                  , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_CONTACT_DATA
                  , i_object_id       => i_contact_data_id
                  , i_inst_id         => rec.inst_id
                  , i_split_hash      => rec.split_hash
                  , i_param_tab       => l_param_tab
                );
                rul_api_param_pkg.clear_params(
                    io_params => l_param_tab
                );
            end loop;
        end if;
    end loop;
end register_event;

procedure add_contact (
    o_contact_id            out com_api_type_pkg.t_medium_id
  , i_job_title          in     com_api_type_pkg.t_dict_value
  , i_person_id          in     com_api_type_pkg.t_name
  , i_pref_lang          in     com_api_type_pkg.t_dict_value
  , o_seqnum                out com_api_type_pkg.t_seqnum
) is
begin
    o_contact_id := com_contact_seq.nextval;
    o_seqnum := 1;

    insert into com_contact_vw (
        id
        , job_title
        , person_id
        , seqnum
        , preferred_lang
        , inst_id
    ) values (
        o_contact_id
        , i_job_title
        , i_person_id
        , o_seqnum
        , i_pref_lang
        , ost_api_institution_pkg.get_sandbox
    );
        
    trc_log_pkg.debug (
        i_text          => 'Contact added'
        , i_env_param1  => o_contact_id
    );
    
    register_event(i_contact_id => o_contact_id);
    
end;

procedure modify_contact (
    i_contact_id         in     com_api_type_pkg.t_medium_id
  , i_job_title          in     com_api_type_pkg.t_dict_value
  , i_person_id          in     com_api_type_pkg.t_name
  , i_pref_lang          in     com_api_type_pkg.t_dict_value
  , io_seqnum            in out com_api_type_pkg.t_seqnum
) is
begin
    update
        com_contact_vw
    set
        job_title        = i_job_title
        , person_id      = i_person_id
        , preferred_lang = i_pref_lang
        , seqnum         = io_seqnum
    where
        id = i_contact_id;

    io_seqnum := io_seqnum + 1;
    
    register_event(i_contact_id => i_contact_id);
end;

procedure remove_contact (
    i_contact_id         in     com_api_type_pkg.t_medium_id
  , i_seqnum             in     com_api_type_pkg.t_seqnum
) is
    l_count     com_api_type_pkg.t_tiny_id;
begin
    select
        count(1)
    into
        l_count
    from
        com_contact_object_vw a
    where
        a.contact_id = i_contact_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error  => 'CONTACT_HAS_ATTACHED_OBJECTS'
        );
    end if;

    delete from com_contact_data_vw
     where contact_id = i_contact_id;

    update com_contact_vw
       set seqnum = i_seqnum
     where id     = i_contact_id;

    delete from com_contact_vw
     where id     = i_contact_id;

end;

procedure add_contact_object (
    i_contact_id         in     com_api_type_pkg.t_medium_id
  , i_entity_type        in     com_api_type_pkg.t_dict_value
  , i_contact_type       in     com_api_type_pkg.t_dict_value
  , i_object_id          in     com_api_type_pkg.t_long_id
  , o_contact_object_id     out com_api_type_pkg.t_long_id
) is
begin
    com_api_contact_pkg.add_contact_object (
        i_contact_id         => i_contact_id
      , i_entity_type        => i_entity_type
      , i_contact_type       => i_contact_type
      , i_object_id          => i_object_id
      , o_contact_object_id  => o_contact_object_id
    );
end;

procedure remove_contact_object (
    i_contact_object_id  in     com_api_type_pkg.t_long_id
) is
begin
    for rec in (
       select
           count(1) as cnt
         , b.entity_type
         , b.object_id
       from
           com_contact_object_vw b
       where (b.object_id, b.entity_type) in (
           select
               a.object_id
             , a.entity_type
           from
               com_contact_object_vw a
           where
               a.id = i_contact_object_id)
       group by
           b.entity_type
         , b.object_id
        )
    loop

        if rec.cnt > 1 then

            delete
                com_contact_object_vw
            where
                id = i_contact_object_id;

        else
            com_api_error_pkg.raise_error(
                i_error      => 'OBJECT_LAST_CONTACT'
              , i_env_param1 => rec.entity_type
              , i_env_param2 => rec.object_id
            );

        end if;
    end loop;
end;

procedure add_contact_data (
    o_id                    out com_api_type_pkg.t_medium_id
    , i_contact_id       in     com_api_type_pkg.t_medium_id
    , i_commun_method    in     com_api_type_pkg.t_dict_value
    , i_commun_address   in     com_api_type_pkg.t_full_desc
    , i_start_date       in     date
    , i_end_date         in     date
) is
begin
    o_id := com_contact_data_seq.nextval;

    insert into com_contact_data_vw (
        id
        , contact_id
        , commun_method
        , commun_address
        , start_date
        , end_date
    ) values (
        o_id
        , i_contact_id
        , i_commun_method
        , i_commun_address
        , nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)
        , i_end_date
    );
    
    register_event (
        i_contact_id       => i_contact_id
      , i_contact_data_id  => o_id
    );
    
end;

procedure modify_contact_data (
    i_id                 in     com_api_type_pkg.t_medium_id
    , i_contact_id       in     com_api_type_pkg.t_medium_id
    , i_commun_method    in     com_api_type_pkg.t_dict_value
    , i_commun_address   in     com_api_type_pkg.t_full_desc
    , i_start_date       in     date
    , i_end_date         in     date
) is
begin
    update
        com_contact_data_vw
    set
        commun_method = i_commun_method
        , commun_address = i_commun_address
        , start_date = nvl(i_start_date, start_date)
        , end_date = i_end_date
    where
        id = i_id;
        
    register_event (
        i_contact_id       => i_contact_id
      , i_contact_data_id  => i_id
    );
end;

procedure remove_contact_data (
    i_id                 in     com_api_type_pkg.t_medium_id
) is
begin
    delete from com_contact_data_vw
    where  id = i_id;
end;

procedure get_contacts (
    i_entity_type        in     com_api_type_pkg.t_dict_value
  , i_object_id          in     com_api_type_pkg.t_long_id
  , o_contacts              out sys_refcursor
) is
    l_sysdate  date;
begin
    if i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        l_sysdate := com_api_sttl_day_pkg.get_sysdate;

        open o_contacts for
        select c.id
             , c.seqnum
             , c.preferred_lang
             , c.job_title
             , c.person_id
             , o.contact_type
             , d.commun_method
             , d.commun_address
             , d.start_date
             , d.end_date
          from com_contact c
             , com_contact_object o
             , com_contact_data d
         where c.id          = o.contact_id
           and o.entity_type = i_entity_type
           and o.object_id   = i_object_id
           and d.contact_id  = c.id
           and (d.end_date is null or d.end_date > l_sysdate);
    end if;
end;

end;
/
