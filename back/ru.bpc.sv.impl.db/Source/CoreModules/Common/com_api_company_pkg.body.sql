create or replace package body com_api_company_pkg as
/*********************************************************
*  API for entity Company <br />
*  Created by Kryukov E.(krukov@bpcbt.com)  at 09.09.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: com_api_company_pkg <br />
*  @headcom
**********************************************************/ 

procedure register_customer_event(
    i_company_id  in     com_api_type_pkg.t_long_id
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    for rec in (
        select c.id
             , c.inst_id
             , c.split_hash
          from prd_customer c
         where c.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
           and c.object_id   = i_company_id
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
    end loop;
end;

procedure add_company(
    o_id                     out  com_api_type_pkg.t_short_id
  , o_seqnum                 out  com_api_type_pkg.t_tiny_id
  , i_company_short_name  in      com_api_type_pkg.t_multilang_value_tab
  , i_company_full_name   in      com_api_type_pkg.t_multilang_desc_tab
  , i_embossed_name       in      com_api_type_pkg.t_name
  , i_incorp_form         in      com_api_type_pkg.t_dict_value
  , i_inst_id             in      com_api_type_pkg.t_inst_id
) is
    l_param_tab       com_api_type_pkg.t_param_tab;
begin
    o_id     := com_company_seq.nextval;
    o_seqnum := 1;

    l_param_tab('COMPANY_ID') := o_id;

    insert into com_company_vw(
        id
      , seqnum
      , embossed_name
      , incorp_form
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , i_embossed_name
      , i_incorp_form
      , ost_api_institution_pkg.get_sandbox(i_inst_id)
    );

    -- add multilanguage name
    for i in 1..i_company_short_name.count loop

        trc_log_pkg.debug(
            i_text => 'Company short name added, value='||
                      i_company_short_name(i).value||
                      ', lang ='||i_company_short_name(i).lang
        );

        com_api_i18n_pkg.add_text(
            i_table_name        => 'com_company'
          , i_column_name       => 'label'
          , i_object_id         => o_id
          , i_text              => i_company_short_name(i).value
          , i_lang              => i_company_short_name(i).lang
        );
    end loop;

    for i in 1..i_company_full_name.count loop
        
        com_api_i18n_pkg.add_text(
            i_table_name        => 'com_company'
          , i_column_name       => 'description'
          , i_object_id         => o_id
          , i_text              => i_company_full_name(i).value
          , i_lang              => i_company_full_name(i).lang
        );
    end loop;

end add_company;

procedure modify_company(
    i_id                  in      com_api_type_pkg.t_short_id
  , io_seqnum             in out  com_api_type_pkg.t_seqnum
  , i_company_short_name  in      com_api_type_pkg.t_multilang_value_tab
  , i_company_full_name   in      com_api_type_pkg.t_multilang_desc_tab
  , i_embossed_name       in      com_api_type_pkg.t_name
  , i_incorp_form         in      com_api_type_pkg.t_dict_value
) is
begin
    trc_log_pkg.debug('com_api_company_pkg.modify_company, id=' || 
                      i_id || ', i_company_name=' || i_embossed_name 
    );

    for rec in (select id from com_company a where id = i_id) loop
        select nvl(io_seqnum, seqnum)
          into io_seqnum
          from com_company_vw
         where id = i_id;

        update com_company_vw b
           set b.embossed_name = nvl(i_embossed_name, b.embossed_name)
             , b.incorp_form   = nvl(i_incorp_form, b.incorp_form)
             , seqnum          = io_seqnum
         where id              = i_id;

        io_seqnum := io_seqnum + 1;

        for i in 1..i_company_short_name.count loop
            com_api_i18n_pkg.add_text(
                i_table_name    => 'com_company'
              , i_column_name   => 'label'
              , i_object_id     => i_id
              , i_text          => i_company_short_name(i).value
              , i_lang          => i_company_short_name(i).lang
            );
        end loop;

        for i in 1..i_company_full_name.count loop
            com_api_i18n_pkg.add_text(
                i_table_name    => 'com_company'
              , i_column_name   => 'description'
              , i_object_id     => i_id
              , i_text          => i_company_full_name(i).value
              , i_lang          => i_company_full_name(i).lang
            );
        end loop;
        register_customer_event( i_company_id  => i_id );
    end loop;

end modify_company;

procedure remove_company(
    i_id      in      com_api_type_pkg.t_short_id
  , i_seqnum  in      com_api_type_pkg.t_seqnum
) is
begin
    for rec in (select a.id from com_company_vw a where a.id = i_id) loop
        update com_company_vw
           set seqnum  = i_seqnum
         where id      = rec.id;

        delete from com_company_vw
         where id      = rec.id;
        
        com_api_i18n_pkg.remove_text(
            i_table_name  => 'com_company'
          , i_object_id   => rec.id
        );
        register_customer_event( i_company_id  => i_id );
    end loop;

end remove_company;

function get_company_incorp_form(
    i_id                  in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value is
begin
    for rec in (
        select a.incorp_form
          from com_company_vw a
         where a.id = i_id
    ) loop
        return rec.incorp_form;
    end loop;
    return null;
end;

end com_api_company_pkg;
/
