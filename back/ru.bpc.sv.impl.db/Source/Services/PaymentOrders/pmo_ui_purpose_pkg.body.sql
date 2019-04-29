create or replace package body pmo_ui_purpose_pkg as
/************************************************************
 * UI for Payment Order Purposes<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 14.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PMO_UI_PURPOSE_PKG <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                  out com_api_type_pkg.t_short_id
  , i_provider_id      in     com_api_type_pkg.t_short_id
  , i_service_id       in     com_api_type_pkg.t_short_id
  , i_host_algorithm   in     com_api_type_pkg.t_dict_value
  , i_oper_type        in     com_api_type_pkg.t_dict_value
  , i_terminal_id      in     com_api_type_pkg.t_short_id
  , i_mcc              in     com_api_type_pkg.t_mcc
  , i_purpose_number   in     com_api_type_pkg.t_name     default null
  , i_mod_id           in     com_api_type_pkg.t_tiny_id  default null
  , i_amount_algorithm in     com_api_type_pkg.t_name     default null
  , i_inst_id          in     com_api_type_pkg.t_inst_id  default null
) is
begin
    o_id := pmo_purpose_seq.nextval;

    insert into pmo_purpose_vw(
        id
      , provider_id
      , service_id
      , host_algorithm
      , oper_type
      , terminal_id
      , mcc
      , purpose_number
      , mod_id
      , amount_algorithm
      , inst_id
    ) values (
        o_id
      , i_provider_id
      , i_service_id
      , i_host_algorithm
      , i_oper_type
      , i_terminal_id
      , i_mcc
      , i_purpose_number
      , i_mod_id
      , i_amount_algorithm
      , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
    );
end;

procedure modify(
    i_id               in     com_api_type_pkg.t_short_id
  , i_provider_id      in     com_api_type_pkg.t_short_id
  , i_service_id       in     com_api_type_pkg.t_short_id
  , i_host_algorithm   in     com_api_type_pkg.t_dict_value
  , i_oper_type        in     com_api_type_pkg.t_dict_value
  , i_terminal_id      in     com_api_type_pkg.t_short_id
  , i_mcc              in     com_api_type_pkg.t_mcc
  , i_purpose_number   in     com_api_type_pkg.t_name     default null
  , i_mod_id           in     com_api_type_pkg.t_tiny_id  default null
  , i_amount_algorithm in     com_api_type_pkg.t_name     default null
  , i_inst_id          in     com_api_type_pkg.t_inst_id  default null
) is 
begin
    update pmo_purpose_vw a
       set a.provider_id    = i_provider_id
         , a.service_id     = i_service_id
         , a.host_algorithm = i_host_algorithm
         , a.oper_type      = i_oper_type
         , a.terminal_id    = i_terminal_id
         , a.mcc            = i_mcc
         , a.purpose_number = nvl(a.purpose_number, i_purpose_number)
         , a.mod_id         = i_mod_id
         , a.amount_algorithm = i_amount_algorithm
         , a.inst_id        = nvl(i_inst_id, inst_id)
     where a.id             = i_id;
end;

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
) is 
begin
    for rec in (select a.id
                     , a.seqnum
                  from pmo_purpose_parameter_vw a
                 where a.purpose_id = i_id
    ) loop
        pmo_ui_purpose_parameter_pkg.remove(
            i_id     => rec.id
          , i_seqnum => rec.seqnum + 1
        );
    end loop;

    delete pmo_purpose_vw a
     where a.id = i_id;
end;

procedure get_service_provider_list(
    i_lang          in     com_api_type_pkg.t_dict_value
    , o_ref_cursor  out    sys_refcursor 
)is
    l_lang          com_api_type_pkg.t_dict_value;

begin
    l_lang := nvl(i_lang, get_user_lang);

    open o_ref_cursor for
        select p.id 
             , nvl(get_text ('pmo_purpose', 'label', p.id, i_lang), 
                   get_text ('pmo_service', 'label', p.service_id, i_lang) || ' - ' || get_text ('pmo_provider', 'label', p.provider_id, i_lang)
                 ) purpose_name
         from pmo_purpose p
        order by p.id;    
end;

end pmo_ui_purpose_pkg;
/
