create or replace package body prs_ui_blank_type_pkg is
/************************************************************
 * User interface for blank for card embossing <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.12.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_blank_type_pkg <br />
 * @headcom
 ************************************************************/
    
procedure check_duplicate(
    i_id             in     com_api_type_pkg.t_tiny_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_card_type_id   in     com_api_type_pkg.t_tiny_id
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_name           in     com_api_type_pkg.t_name
) is
    l_check_cnt                 number;
begin
    select count(1)
      into l_check_cnt
      from (select id
                 , card_type_id
                 , inst_id
                 , get_text(
                       i_table_name  => 'prs_blank_type'
                     , i_column_name => 'name'
                     , i_object_id   => id
                     , i_lang        => i_lang
                   ) name
              from prs_blank_type_vw) t
     where t.card_type_id = i_card_type_id
       and t.inst_id      = i_inst_id
       and t.name         = i_name
       and (t.id != i_id or i_id is null);
        
    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_BLANK_TYPE'
          , i_env_param1  => i_inst_id
          , i_env_param2  => i_card_type_id
          , i_env_param3  => i_name
        );
    end if;
end;

function check_name_change(
    i_id             in     com_api_type_pkg.t_tiny_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_card_type_id   in     com_api_type_pkg.t_tiny_id
  , i_lang           in     com_api_type_pkg.t_dict_value
  , i_name           in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_tiny_id is
    l_check_cnt         com_api_type_pkg.t_tiny_id;
begin
    select count(1)
      into l_check_cnt
      from (select id
                 , card_type_id
                 , inst_id
                 , get_text(
                       i_table_name  => 'prs_blank_type'
                     , i_column_name => 'name'
                     , i_object_id   => id
                     , i_lang        => 'LANGENG'
                   ) name
              from prs_blank_type_vw) t
     where t.id              = i_id
       and t.card_type_id    = i_card_type_id
       and t.inst_id         = i_inst_id
       and t.name           != i_name;
        
    return l_check_cnt;
end check_name_change;

procedure add_blank_type(
    o_id            out      com_api_type_pkg.t_tiny_id
  , o_seqnum        out      com_api_type_pkg.t_seqnum
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_card_type_id   in      com_api_type_pkg.t_tiny_id
  , i_lang           in      com_api_type_pkg.t_dict_value
  , i_name           in      com_api_type_pkg.t_name
) is
begin
    check_duplicate(
        i_id            => o_id
      , i_inst_id       => i_inst_id
      , i_card_type_id  => i_card_type_id
      , i_lang          => i_lang
      , i_name          => i_name
    );
        
    o_id     := prs_blank_type_seq.nextval;
    o_seqnum := 1;

    insert into prs_blank_type_vw (
        id
      , card_type_id
      , inst_id
      , seqnum
    ) values (
        o_id
      , i_card_type_id
      , i_inst_id
      , o_seqnum
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'prs_blank_type'
      , i_column_name   => 'name'
      , i_object_id     => o_id
      , i_lang          => i_lang
      , i_text          => i_name
    );
end;

procedure modify_blank_type(
    i_id            in      com_api_type_pkg.t_tiny_id
  , io_seqnum       in out  com_api_type_pkg.t_seqnum
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_card_type_id  in      com_api_type_pkg.t_tiny_id
  , i_lang          in      com_api_type_pkg.t_dict_value
  , i_name          in      com_api_type_pkg.t_name
) is
    l_check_cnt     pls_integer;
    l_check_name    com_api_type_pkg.t_tiny_id;
begin
    l_check_name := check_name_change(
                        i_id            => i_id
                      , i_inst_id       => i_inst_id
                      , i_card_type_id  => i_card_type_id
                      , i_lang          => i_lang
                      , i_name          => i_name
                    );

    if l_check_name = 0 then
        select count(1)
          into l_check_cnt
          from (select blank_type_id
                  from iss_product_card_type_vw
                 where blank_type_id = i_id
                 union all 
                select blank_type_id
                  from prs_batch_vw
                 where blank_type_id = i_id
                 union all 
                select id
                  from prs_blank_type_vw
                 where id = i_id
                   and is_active = com_api_type_pkg.TRUE);

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'BLANK_TYPE_ALREADY_USED'
              , i_env_param1 => i_id
            );
        end if;
    end if;
    
    check_duplicate(
        i_id            => i_id
      , i_inst_id       => i_inst_id
      , i_card_type_id  => i_card_type_id
      , i_lang          => i_lang
      , i_name          => i_name
    );
        
    update prs_blank_type_vw
       set seqnum       = io_seqnum
         , card_type_id = i_card_type_id
     where id           = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name    => 'prs_blank_type'
      , i_column_name   => 'name'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_name
    );
end;

procedure remove_blank_type(
    i_id           in      com_api_type_pkg.t_tiny_id
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) is
    l_check_cnt    pls_integer;
begin
    select count(1)
      into l_check_cnt
      from (select blank_type_id
              from iss_product_card_type_vw
             where blank_type_id = i_id
             union all 
            select blank_type_id
              from prs_batch_vw
             where blank_type_id = i_id
             union all 
            select id
              from prs_blank_type_vw
             where id = i_id
               and is_active = com_api_type_pkg.TRUE);

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'BLANK_TYPE_ALREADY_USED'
          , i_env_param1 => i_id
        );
    end if;
        
    com_api_i18n_pkg.remove_text(
        i_table_name            => 'prs_blank_type'
      , i_object_id             => i_id
    );

    update prs_blank_type_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from prs_blank_type_vw
     where id     = i_id;
end;

end;
/
