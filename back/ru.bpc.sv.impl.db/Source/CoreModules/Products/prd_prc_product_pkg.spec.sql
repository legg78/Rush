create or replace package prd_prc_product_pkg as

procedure import_products;

/*
 * Export product and his components into XML file.
 * Limitations: The complex tags <product_account_type> and <product_card_type> is not supported now.
 * @param i_full_export          – full export mode when com_api_const_pkg.TRUE,
 *                                 incremental export mode when com_api_const_pkg.FALSE.
 * @param i_eff_date             - effective date.
 * @param i_inst_id              - export for this institution id.
 * @param i_export_clear_pan     - if it is FALSE then process unloads undecoded PANs (tokens)
 *                                 for the case when Message Bus is capable to handle them.
 */
procedure export_products(
    i_full_export         in     com_api_type_pkg.t_boolean    default null
  , i_eff_date            in     date
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
);

/*
 * Generate XML block for product and his components.
 * @param i_full_export          – full export mode when com_api_const_pkg.TRUE,
 *                                 incremental export mode when com_api_const_pkg.FALSE.
 * @param i_eff_date             - effective date.
 * @param i_inst_id              - export for this institution id.
 * @param i_export_clear_pan     - if it is FALSE then process unloads undecoded PANs (tokens)
 *                                 for the case when Message Bus is capable to handle them.
 * @param i_product_id           – it's product id.
 */
function generate_product_block(
    i_full_export         in     com_api_type_pkg.t_boolean    default null
  , i_eff_date            in     date
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_product_id          in     com_api_type_pkg.t_short_id
) return xmltype;

/*
 * Generate XML block for limit and his components.
 * @param i_limit_id    – it's limit id.
 */
function generate_limit_block(
    i_limit_id            in     com_api_type_pkg.t_long_id
) return xmltype;

/*
 * Generate XML block for cycle and his components.
 * @param i_cycle_id    – it's cycle id.
 */
function generate_cycle_block(
    i_cycle_id            in     com_api_type_pkg.t_short_id
) return xmltype;

/*
 * Generate XML block for service and his components.
 * @param i_product_id           – it's product id.
 * @param i_product_service_id   – it is product's service id.
 * @param i_full_export          – full export mode when com_api_const_pkg.TRUE,
 *                                 incremental export mode when com_api_const_pkg.FALSE.
 * @param i_eff_date             - effective date.
 * @param i_export_clear_pan     - if it is FALSE then process unloads undecoded PANs (tokens)
 *                                 for the case when Message Bus is capable to handle them.
 */
function generate_service_block(
    i_product_id          in     com_api_type_pkg.t_short_id
  , i_product_service_id  in     com_api_type_pkg.t_short_id
  , i_service_id          in     com_api_type_pkg.t_short_id
  , i_full_export         in     com_api_type_pkg.t_boolean    default null
  , i_eff_date            in     date
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return xmltype;

procedure check_contract_type(
    i_product_id          in     com_api_type_pkg.t_short_id
  , i_old_contract_type   in     com_api_type_pkg.t_dict_value
  , i_new_contract_type   in     com_api_type_pkg.t_dict_value
);

end prd_prc_product_pkg;
/
