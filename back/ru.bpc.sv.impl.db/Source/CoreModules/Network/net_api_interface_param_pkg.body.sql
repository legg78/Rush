create or replace package body net_api_interface_param_pkg as

procedure get_param_value(
    i_device_id             in      com_api_type_pkg.t_short_id
  , i_consumer_member_id    in      com_api_type_pkg.t_tiny_id
  , i_param_name            in      com_api_type_pkg.t_name
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_standart_type         in      com_api_type_pkg.t_dict_value default null    
  , o_param_value              out  com_api_type_pkg.t_param_value
  , o_xml_param_value          out  clob
) is
    l_param_tab             com_api_type_pkg.t_param_tab;
begin

    for r in (
        with hst as (
            select m.id host_member_id
                 , s.standard_type
                 , v.standard_id
                 , max(ov.version_id) keep (dense_rank first order by ov.start_date desc) version_id
              from net_member m
                 , cmn_standard_version_obj ov
                 , cmn_standard_version v
                 , cmn_standard s
             where m.id = ov.object_id
               and ov.entity_type  = net_api_const_pkg.ENTITY_TYPE_HOST
               and ov.start_date  <= get_sysdate
               and ov.version_id   = v.id
               and v.standard_id   = s.id
               and s.standard_type = nvl(i_standart_type, s.standard_type)
               and s.standard_type in (cmn_api_const_pkg.STANDART_TYPE_NETW_COMM, cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING)
          group by m.id
                 , s.standard_type
                 , v.standard_id
        ),
        ifc_param as (
            select ifc.id                  interface_id
                 , ifc.host_member_id      host_member_id
                 , ifc.consumer_member_id  consumer_member_id
                 , hst.standard_id
                 , hst.version_id
                 , pr.param_id
                 , pr.param_name
                 , pr.data_type
                 , nvl(pr.param_value, pr.default_value)     default_value
                 , nvl(pr.xml_value,   pr.xml_default_value) xml_default_value
                 , pr.mod_id
              from hst
                 , cmn_api_version_parameter_vw pr
                 , net_interface ifc
             where hst.version_id       = pr.version_id
               and pr.param_entity_type = net_api_const_pkg.ENTITY_TYPE_INTERFACE
               and hst.host_member_id   = ifc.host_member_id
            )
        select i.data_type
             , nvl(v1.param_value, nvl(i.default_value, vd.param_value))     param_value
             , nvl(v1.xml_value,   nvl(i.xml_default_value, vd.xml_value)) xml_param_value
             , nvl(v1.mod_id, i.mod_id) mod_id
          from ifc_param i
              , net_device d
              , cmn_parameter_value v1
              , rul_mod m
              , (select * from cmn_parameter_value where version_id is null) vd
          where v1.param_id(+)       = i.param_id
            and v1.entity_type(+)    = net_api_const_pkg.ENTITY_TYPE_INTERFACE
            and v1.object_id(+)      = i.interface_id
            and v1.standard_id(+)    = i.standard_id
            and v1.version_id(+)     = i.version_id
            and i.host_member_id     = d.host_member_id(+)
            and i.param_name         = upper(i_param_name)
            and i.consumer_member_id = i_consumer_member_id
            and d.device_id          = i_device_id
            and v1.mod_id            = m.id(+) 
            and vd.param_id(+)       = i.param_id
            and vd.entity_type(+)    = net_api_const_pkg.ENTITY_TYPE_INTERFACE
            and vd.object_id(+)      = i.interface_id
            and vd.standard_id(+)    = i.standard_id
          order by nvl2(v1.version_id, 0, 1), nvl2(v1.mod_id, 0, 1), m.priority
    ) loop
        if l_param_tab.count = 0 and i_auth_id is not null then
            rul_api_shared_data_pkg.load_oper_params(
                i_oper_id       => i_auth_id
              , io_params       => l_param_tab
            );
        end if;
        
        if rul_api_mod_pkg.check_condition (
                i_mod_id        => r.mod_id
              , i_params        => l_param_tab
           ) = com_api_const_pkg.TRUE
        then
            o_param_value       := r.param_value;
            o_xml_param_value   := r.xml_param_value;
            return;
        end if;
        
    end loop;
end;

procedure get_param_value(
    i_device_id             in      com_api_type_pkg.t_short_id
  , i_consumer_member_id    in      com_api_type_pkg.t_tiny_id
  , i_param_name            in      com_api_type_pkg.t_name
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_standart_type         in      com_api_type_pkg.t_dict_value default null  
  , o_param_value              out  com_api_type_pkg.t_param_value
) is
    l_xml_param_value       clob;
begin
    get_param_value(
        i_device_id             => i_device_id
      , i_consumer_member_id    => i_consumer_member_id
      , i_param_name            => i_param_name
      , i_auth_id               => i_auth_id
      , i_standart_type         => i_standart_type
      , o_param_value           => o_param_value
      , o_xml_param_value       => l_xml_param_value
    );
end;

procedure get_xml_param_value(
    i_device_id             in      com_api_type_pkg.t_short_id
  , i_consumer_member_id    in      com_api_type_pkg.t_tiny_id
  , i_param_name            in      com_api_type_pkg.t_name
  , i_auth_id               in      com_api_type_pkg.t_long_id
  , i_standart_type         in      com_api_type_pkg.t_dict_value default null  
  , o_xml_param_value          out  clob
) is
    l_param_value           com_api_type_pkg.t_param_value;
begin
    get_param_value(
        i_device_id             => i_device_id
      , i_consumer_member_id    => i_consumer_member_id
      , i_param_name            => i_param_name
      , i_auth_id               => i_auth_id
      , i_standart_type         => i_standart_type
      , o_param_value           => l_param_value
      , o_xml_param_value       => o_xml_param_value
    );
end;

end;
/