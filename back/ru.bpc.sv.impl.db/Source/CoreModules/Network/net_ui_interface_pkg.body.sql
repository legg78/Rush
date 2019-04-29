create or replace package body net_ui_interface_pkg is
/********************************************************* 
 *  UI for network interface <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 19.07.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: net_ui_interface_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add (
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_host_member_id        in      com_api_type_pkg.t_tiny_id
  , i_consumer_member_id    in      com_api_type_pkg.t_tiny_id
  , i_msp_member_id         in      com_api_type_pkg.t_tiny_id
) is
begin

    select net_interface_seq.nextval into o_id from dual;
    
    o_seqnum := 1;
     
    insert into net_interface_vw (
        id
      , seqnum
      , host_member_id
      , consumer_member_id
      , msp_member_id
    ) values (
        o_id
      , o_seqnum
      , i_host_member_id
      , i_consumer_member_id
      , i_msp_member_id
    );
end;

procedure modify (
    i_id                    in      com_api_type_pkg.t_tiny_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_host_member_id        in      com_api_type_pkg.t_tiny_id
  , i_consumer_member_id    in      com_api_type_pkg.t_tiny_id
  , i_msp_member_id         in      com_api_type_pkg.t_tiny_id
) is
begin
    update net_interface_vw
       set seqnum             = io_seqnum
         , host_member_id     = i_host_member_id
         , consumer_member_id = i_consumer_member_id
         , msp_member_id      = i_msp_member_id
     where id                 = i_id;
            
    io_seqnum := io_seqnum + 1;
end;

procedure remove (
    i_id                    in      com_api_type_pkg.t_tiny_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
) is
    l_count                 pls_integer;
begin
    select count(1)
      into l_count
      from net_interface_vw a
         , net_device_vw b
     where a.id             = i_id
       and a.host_member_id = b.host_member_id;
            
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NET_HOST_ASSOCIATED_WITH_DEVICE_CANNOT_DELETE'
        );
    end if;

    select count(1) 
      into l_count       
      from net_interface_vw a
         , net_interface_vw b
     where a.msp_member_id = b.consumer_member_id 
       and b.id            = i_id;
    
    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'NET_HOST_USED_AS_MSP_CANNOT_DELETE'
          , i_env_param1 => i_id
        );
    
    end if;

    update net_interface_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete net_interface_vw
     where id     = i_id;
end;

end; 
/
