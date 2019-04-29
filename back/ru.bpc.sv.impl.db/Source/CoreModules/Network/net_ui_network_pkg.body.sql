create or replace package body net_ui_network_pkg is
/**********************************************************
*  UI for networks <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 01.06.2010 <br />
*  Last changed by $Author: khougaev $ <br />
*  $LastChangedDate:: 2011-03-18 10:19:32 +0300#$ <br />
*  Revision: $LastChangedRevision: 8498 $ <br />
*  Module: NET_UI_NETWORK_PKG <br />
*  @headcom
***********************************************************/
procedure add (
    o_id                         out com_api_type_pkg.t_tiny_id
  , o_seqnum                     out com_api_type_pkg.t_seqnum
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_bin_table_scan_priority in     com_api_type_pkg.t_tiny_id
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_name                    in     com_api_type_pkg.t_name
  , i_full_desc               in     com_api_type_pkg.t_full_desc
) is
    l_id                      com_api_type_pkg.t_tiny_id;
    l_seqnum                  com_api_type_pkg.t_seqnum;
begin
    o_id     := net_network_seq.nextval;
    o_seqnum := 1;

    insert into net_network_vw (
        id
      , seqnum
      , inst_id
      , bin_table_scan_priority
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
      , i_bin_table_scan_priority
    );

    com_api_i18n_pkg.add_text(
        i_table_name           => 'net_network'
      , i_column_name          => 'name'
      , i_object_id            => o_id
      , i_lang                 => i_lang
      , i_text                 => i_name
    );
    com_api_i18n_pkg.add_text(
        i_table_name           => 'net_network'
      , i_column_name          => 'description'
      , i_object_id            => o_id
      , i_lang                 => i_lang
      , i_text                 => i_full_desc
    );

    -- add default members
    net_ui_member_pkg.add(
        o_id                   => l_id
      , o_seqnum               => l_seqnum
      , i_inst_id              => i_inst_id
      , i_network_id           => o_id
    );
end add;

procedure modify (
    i_id                      in     com_api_type_pkg.t_tiny_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_bin_table_scan_priority in     com_api_type_pkg.t_tiny_id
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_name                    in     com_api_type_pkg.t_name
  , i_full_desc               in     com_api_type_pkg.t_full_desc
) is
begin
    update net_network_vw
       set seqnum                  = io_seqnum
         , bin_table_scan_priority = i_bin_table_scan_priority
     where id                      = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text(
        i_table_name    => 'net_network'
      , i_column_name   => 'name'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_name
    );
    com_api_i18n_pkg.add_text(
        i_table_name    => 'net_network'
      , i_column_name   => 'description'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_full_desc
    );
end modify;

procedure remove (
    i_id                   in     com_api_type_pkg.t_tiny_id
  , i_seqnum               in     com_api_type_pkg.t_seqnum
) is
    l_count                pls_integer;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_default_member_id    com_api_type_pkg.t_tiny_id;
    l_seqnum               com_api_type_pkg.t_seqnum;
begin
    select inst_id
      into l_inst_id
      from net_network_vw
     where id = i_id;

    select count(1)
      into l_count
      from net_member_vw
     where network_id  = i_id
       and inst_id    != l_inst_id;

    if l_count>0 then
        com_api_error_pkg.raise_error(
            i_error      => 'UNABLE_TO_DELETE_NETWORK'
          , i_env_param1 => i_id
        );
    end if;
    
    select id
         , seqnum
      into l_default_member_id
         , l_seqnum
      from net_member_vw
     where network_id = i_id
       and inst_id    = l_inst_id;

    -- remove default member
    net_ui_member_pkg.remove(
        i_id      =>  l_default_member_id
      , i_seqnum  =>  l_seqnum + 1
    );
       
    com_api_i18n_pkg.remove_text(
        i_table_name => 'net_network'
      , i_object_id  => i_id
    );
 
    -- update default network for institution 
    update ost_institution_vw
       set network_id = null
    where network_id = i_id;    
    
    update net_network_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from net_network_vw
    where  id     = i_id;

end remove;

end; 
/
