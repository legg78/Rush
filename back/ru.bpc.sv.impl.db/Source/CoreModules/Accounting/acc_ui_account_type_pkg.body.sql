create or replace package body acc_ui_account_type_pkg as
/*********************************************************
*  Account type UI  <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 06.11.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: acc_ui_account_type_pkg <br />
*  @headcom
**********************************************************/
procedure add (
    o_id                   out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_number_format_id  in      com_api_type_pkg.t_tiny_id
  , i_number_prefix     in      com_api_type_pkg.t_name
  , i_product_type      in      com_api_type_pkg.t_dict_value
) is
begin
    o_id := acc_account_type_seq.nextval;
    o_seqnum := 1;

    begin
        insert into acc_account_type_vw (
            id
          , seqnum
          , account_type
          , inst_id
          , number_format_id
          , number_prefix
          , product_type
        ) values (
            o_id
          , o_seqnum
          , i_account_type
          , i_inst_id
          , i_number_format_id
          , i_number_prefix
          , i_product_type
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error       => 'ACCOUNT_TYPE_ALREADY_REGISTERED'
              , i_env_param1  => i_inst_id
              , i_env_param2  => i_account_type
            );
    end;
end;

procedure modify (
    i_id                in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_number_format_id  in      com_api_type_pkg.t_tiny_id
  , i_number_prefix     in      com_api_type_pkg.t_name
  , i_product_type      in      com_api_type_pkg.t_dict_value
) is
begin
    update acc_account_type_vw
       set seqnum           = io_seqnum
         , number_format_id = i_number_format_id
         , number_prefix    = i_number_prefix
         , product_type     = i_product_type
     where id               = i_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove (
    i_id                in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_check_count       number;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_account_type      com_api_type_pkg.t_dict_value;
begin
    select count(a.id)
         , min(t.inst_id)
         , min(t.account_type)
      into l_check_count
         , l_inst_id
         , l_account_type
      from acc_account_type t
         , acc_account a
     where t.id             = i_id
       and t.inst_id        = a.inst_id(+)
       and t.account_type   = a.account_type(+);

    if l_check_count = 0 then
        delete from acc_account_type_entity_vw
         where inst_id      = l_inst_id
           and account_type = l_account_type;

        delete from acc_balance_type_vw
         where inst_id      = l_inst_id
           and account_type = l_account_type;

        delete from acc_account_type_vw
         where id           = i_id
           and seqnum       = i_seqnum;
           
        delete from acc_product_account_type_vw
         where product_id   in (select id from prd_product where inst_id = l_inst_id)
           and account_type = l_account_type;

    else
        com_api_error_pkg.raise_error (
            i_error       => 'ACCOUNT_TYPE_ALREADY_USED'
          , i_env_param1  => l_inst_id
          , i_env_param2  => l_account_type
        );
    end if;
end;

procedure add_entity_type (
    o_id                   out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
) is
    l_check_cnt         pls_integer;
    l_product_type      com_api_type_pkg.t_dict_value;
begin
    select count(*)
      into l_check_cnt
      from (
          select 1
            from acc_account_type_entity_vw t
           where t.account_type = i_account_type
             and t.inst_id      = i_inst_id
             and t.entity_type in (ost_api_const_pkg.ENTITY_TYPE_AGENT
                                 , ost_api_const_pkg.ENTITY_TYPE_INSTITUTION)
             and i_entity_type not in (ost_api_const_pkg.ENTITY_TYPE_AGENT
                                     , ost_api_const_pkg.ENTITY_TYPE_INSTITUTION)
             and rownum         = 1
           union all
          select 1
            from acc_account_type_entity_vw t
           where t.account_type = i_account_type
             and t.inst_id      = i_inst_id
             and t.entity_type not in (ost_api_const_pkg.ENTITY_TYPE_AGENT
                                     , ost_api_const_pkg.ENTITY_TYPE_INSTITUTION)
             and i_entity_type in (ost_api_const_pkg.ENTITY_TYPE_AGENT
                                 , ost_api_const_pkg.ENTITY_TYPE_INSTITUTION)
             and rownum         = 1
      );

    select product_type
      into l_product_type
      from acc_account_type_vw
     where account_type = i_account_type
       and inst_id      = i_inst_id;

    if l_product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS then
        if i_entity_type not in (iss_api_const_pkg.ENTITY_TYPE_CARD
                               , com_api_const_pkg.ENTITY_TYPE_CONTACT 
                               , com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                               , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT) then
            l_check_cnt := 1;
        end if;
    elsif l_product_type = prd_api_const_pkg.PRODUCT_TYPE_ACQ then
        if i_entity_type not in (acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                               , acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                               , iss_api_const_pkg.ENTITY_TYPE_CARD) then
            l_check_cnt := 1;
        end if;
    elsif l_product_type = prd_api_const_pkg.PRODUCT_TYPE_INST then
        if i_entity_type not in (ost_api_const_pkg.ENTITY_TYPE_AGENT, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION) then
            l_check_cnt := 1;
        end if;
    end if;

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error  => 'GL_ACCOUNT_TYPE_CAN_NOT_USED_ENTITY'
        );
    end if;

    o_id     := acc_account_type_entity_seq.nextval;
    o_seqnum := 1;

    begin
        insert into acc_account_type_entity_vw (
            id
          , seqnum
          , account_type
          , inst_id
          , entity_type
        ) values (
            o_id
          , o_seqnum
          , i_account_type
          , i_inst_id
          , i_entity_type
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error      => 'ILLEGAL_ACCOUNT_ENTITY_TYPE_COMBINATION'
              , i_env_param1 => case
                                    -- Special processing is due to UK:
                                    -- {account_type, inst_id, decode(entity_type, 'ENTTAGNT', 'ENTTINST', entity_type)}
                                    when i_entity_type in (ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                         , ost_api_const_pkg.ENTITY_TYPE_AGENT)
                                    then com_api_dictionary_pkg.get_article_text(
                                             i_article => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                         )
                                         || ' or ' ||
                                         com_api_dictionary_pkg.get_article_text(
                                             i_article => ost_api_const_pkg.ENTITY_TYPE_AGENT
                                         )
                                    else i_entity_type
                                end
              , i_env_param2 => i_account_type
            );
    end;
end;

procedure remove_entity_type (
    i_id                in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             com_api_type_pkg.t_long_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_account_type      com_api_type_pkg.t_dict_value;
    l_inst_id           com_api_type_pkg.t_inst_id;
begin
    select entity_type
         , account_type
         , inst_id
      into l_entity_type
         , l_account_type
         , l_inst_id
      from acc_account_type_entity_vw
     where id = i_id;

    if l_entity_type in (ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                       , ost_api_const_pkg.ENTITY_TYPE_AGENT)
    then
        select count(*)
          into l_count
          from acc_account_vw a
         where a.account_type = l_account_type
           and a.inst_id      = l_inst_id;
    else
        select count(*)
          into l_count
          from (select 1
                  from acc_account_vw a
                     , acc_account_object_vw o
                 where a.account_type = l_account_type
                   and o.entity_type  = l_entity_type
                   and a.id           = o.account_id
                   and a.inst_id      = l_inst_id
          );
    end if;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'ACCOUNT_ENTITY_TYPE_LINK_EXISTS'
          , i_env_param1 => l_account_type
          , i_env_param2 => l_entity_type
          , i_env_param3 => ost_ui_institution_pkg.get_inst_name(l_inst_id)

        );
    end if;

    update acc_account_type_entity_vw
    set    seqnum = i_seqnum
    where  id     = i_id;

    delete from acc_account_type_entity_vw
    where  id     = i_id;
end;

procedure add_iso_type (
    o_id                   out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_iso_type          in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
) is
begin
    o_id     := acc_iso_account_type_seq.nextval;
    o_seqnum := 1;
    
    begin
        insert into acc_iso_account_type_vw (
            id
          , seqnum
          , account_type
          , inst_id
          , iso_type
          , priority
        ) values (
            o_id
          , o_seqnum
          , i_account_type
          , i_inst_id
          , i_iso_type
          , i_priority
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error      => 'ACCOUNT_ISO_TYPE_LINK_EXISTS'
              , i_env_param1 => i_account_type
              , i_env_param2 => i_iso_type            
            );    
    end;
end;

procedure modify_iso_type (
    i_id                in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_priority          in      com_api_type_pkg.t_tiny_id
) is
begin
    update acc_iso_account_type_vw
       set seqnum   = io_seqnum
         , priority = i_priority
     where id = i_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove_iso_type (
    i_id                in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update acc_iso_account_type_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from acc_iso_account_type_vw
     where id     = i_id;
end;

end;
/
