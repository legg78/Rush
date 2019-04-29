create or replace package body net_ui_card_type_pkg is
/*********************************************************
*  UI for card types <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 31.05.2010 <br />
*  Last changed by $Author: kopachev $ <br />
*  $LastChangedDate:: 2011-02-11 14:17:58 +0300#$ <br />
*  Revision: $LastChangedRevision: 8057 $ <br />
*  Module: NET_UI_CARD_TYPE_PKG <br />
*  @headcom
**********************************************************/

procedure check_text(
    i_object_id             in com_api_type_pkg.t_inst_id
    , i_network_id          in com_api_type_pkg.t_inst_id
    , i_text                in com_api_type_pkg.t_name
)is
l_count                 com_api_type_pkg.t_tiny_id;
    
begin       
    if i_object_id is null then
        select count(1)    
          into l_count
          from com_i18n_vw i 
             , net_card_type_vw c  
         where i.table_name = 'NET_CARD_TYPE'
           and i.column_name = 'NAME'  
           and i.text = i_text
           and c.id = i.object_id
           and c.network_id = i_network_id;
    else
        select count(1)
          into l_count
          from com_i18n_vw i
             , net_card_type_vw c  
         where i.table_name = 'NET_CARD_TYPE'
           and i.column_name = 'NAME'  
           and i.text        = i_text
           and c.id = i.object_id
           and i.object_id   != i_object_id
           and c.network_id = i_network_id;     
    end if;
        
    trc_log_pkg.debug (
        i_text          => 'l_count ' || l_count
    );
        
    if l_count > 0 then
        com_api_error_pkg.raise_error(
              i_error           => 'CARD_TYPE_ALREADY_EXISTS'
            , i_env_param1      => i_text 
            , i_env_param2      => i_network_id 
        );            
    end if;         
end;

procedure add (
    o_id                     out com_api_type_pkg.t_tiny_id
  , o_seqnum                 out com_api_type_pkg.t_seqnum
  , i_parent_type_id      in     com_api_type_pkg.t_tiny_id
  , i_network_id          in     com_api_type_pkg.t_tiny_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_name                in     com_api_type_pkg.t_name
  , i_is_virtual          in     com_api_type_pkg.t_boolean     default null
) is
begin
    check_text(
        i_object_id             => o_id
        , i_network_id          => i_network_id
        , i_text                => i_name
    );
    
    o_id     := net_card_type_seq.nextval;
    o_seqnum := 1;

    insert into net_card_type_vw (
        id
      , seqnum
      , parent_type_id
      , network_id
      , is_virtual
    ) values (
        o_id
      , o_seqnum
      , i_parent_type_id
      , i_network_id
      , i_is_virtual
    );

    com_api_i18n_pkg.add_text(
        i_table_name       => 'net_card_type'
      , i_column_name      => 'name'
      , i_object_id        => o_id
      , i_lang             => i_lang
      , i_text             => i_name
      , i_check_unique     => com_api_type_pkg.FALSE
    );

end;

procedure modify (
    i_id              in     com_api_type_pkg.t_tiny_id
  , io_seqnum         in out com_api_type_pkg.t_seqnum
  , i_parent_type_id  in     com_api_type_pkg.t_tiny_id
  , i_network_id      in     com_api_type_pkg.t_tiny_id
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_is_virtual      in     com_api_type_pkg.t_boolean     default null
) is
    l_count           com_api_type_pkg.t_long_id;
begin
    check_text(
        i_object_id             => i_id
        , i_network_id          => i_network_id
        , i_text                => i_name
    );

    -- check for loop
    for rec in (select parent_type_id from net_card_type
                connect by prior parent_type_id = id
                start with id = i_parent_type_id)
    loop
        if rec.parent_type_id = i_id then
            com_api_error_pkg.raise_error(
                i_error      => 'LOOP_CHILD_TYPE'
              , i_env_param1 => i_id
              , i_env_param2 => i_parent_type_id
            );
        end if;
    end loop;

    select sum(cnt)
      into l_count
      from (select count(id) cnt from iss_product_card_type_vw where card_type_id = i_id union all
            select count(id) cnt from iss_card                 where card_type_id = i_id union all
            select count(id) cnt from iss_bin_vw               where card_type_id = i_id union all
            select count(id) cnt from prs_blank_type_vw        where card_type_id = i_id --union all
    );

    if l_count > 0 then
        begin
            select 1
              into l_count
              from net_card_type
             where id = i_id
               and parent_type_id = i_parent_type_id
               and network_id = i_network_id;
                 
            com_api_error_pkg.raise_error(
                i_error      => 'ISSUING_CARD_TYPE_ALREADY_USED'
              , i_env_param1 => i_id
            );
            
        exception
            when no_data_found then
                null;
                    
        end;
        
    else
        update net_card_type_vw
           set seqnum         = io_seqnum
             , parent_type_id = i_parent_type_id
             , network_id     = i_network_id
             , is_virtual     = i_is_virtual
         where id             = i_id;

    end if;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name      => 'net_card_type'
      , i_column_name     => 'name'
      , i_object_id       => i_id
      , i_lang            => i_lang
      , i_text            => i_name
      , i_check_unique    => com_api_type_pkg.FALSE
    );

end;

procedure remove (
    i_id        in       com_api_type_pkg.t_tiny_id
  , i_seqnum    in       com_api_type_pkg.t_seqnum
) is
    l_count  number;
begin
    select sum(cnt)
      into l_count
      from (select count(id) cnt from iss_product_card_type_vw where card_type_id = i_id union all
            select count(id) cnt from iss_card                 where card_type_id = i_id union all
            select count(id) cnt from iss_bin_vw               where card_type_id = i_id union all
            select count(id) cnt from prs_blank_type_vw        where card_type_id = i_id --union all
    );

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'ISSUING_CARD_TYPE_ALREADY_USED'
          , i_env_param1  => i_id
        );
    end if;
    
    select count(1)
      into l_count
      from net_card_type_vw
     where parent_type_id = i_id;
     
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error     => 'CARD_TYPE_HAS_CHILD'
          , i_env_param1 => i_id
        );
    end if; 
    
    -- we delete current row 
    com_api_i18n_pkg.remove_text(
        i_table_name  => 'net_card_type'
      , i_object_id   => i_id
    );

    update net_card_type_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from net_card_type_vw
     where id     = i_id;
end;

end;
/
