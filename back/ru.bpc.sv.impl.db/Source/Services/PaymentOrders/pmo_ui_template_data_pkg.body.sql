create or replace package body pmo_ui_template_data_pkg as
/************************************************************
 * UI for Payment Order template data<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.07.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_ui_template_data_pkg <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                   out com_api_type_pkg.t_long_id
  , i_template_id       in     com_api_type_pkg.t_long_id
  , i_param_id          in     com_api_type_pkg.t_short_id
  , i_param_value       in     com_api_type_pkg.t_name
) is
begin
    o_id := com_api_id_pkg.get_id(pmo_order_data_seq.nextval);
    insert into pmo_order_data_vw(
        id
      , order_id
      , param_id
      , param_value
    ) values (
        o_id
      , i_template_id
      , i_param_id
      , i_param_value
    );
end;

procedure modify(
    i_id                in     com_api_type_pkg.t_long_id
  , i_template_id       in     com_api_type_pkg.t_long_id
  , i_param_id          in     com_api_type_pkg.t_short_id
  , i_param_value       in     com_api_type_pkg.t_name
) is
begin

    update pmo_order_data_vw
       set order_id    = i_template_id
         , param_id    = i_param_id
         , param_value = i_param_value
     where id          = i_id;

end;

procedure remove(
    i_id                in     com_api_type_pkg.t_long_id
) is
begin
    delete pmo_order_data_vw
     where id = i_id;
end;

end pmo_ui_template_data_pkg;
/
