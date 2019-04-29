create or replace package body prd_api_attribute_pkg as
/*********************************************************
 *  Attributes API <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com) at 23.05.2013 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2016-03-03 18:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: PRD_API_ATTRIBUTE_PKG <br />
 *  @headcom
 **********************************************************/ 

procedure get_object_attributes(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , o_xml                      out  clob
) is
    l_product_id            com_api_type_pkg.t_short_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_last_reset_date       date;
    l_count_curr            com_api_type_pkg.t_long_id; 
    l_count_limit           com_api_type_pkg.t_long_id; 
    l_sum_limit             com_api_type_pkg.t_money;
    l_sum_curr              com_api_type_pkg.t_money;
    l_currency              com_api_type_pkg.t_curr_code;
    l_value_char            com_api_type_pkg.t_name;
    l_value_num             com_api_type_pkg.t_long_id;
    l_value_date            date;
begin

    l_product_id := 
        prd_api_product_pkg.get_product_id(
            i_entity_type     => i_entity_type
          , i_object_id       => i_object_id
        );    

    l_split_hash := 
        com_api_hash_pkg.get_split_hash(
            i_entity_type     => i_entity_type
          , i_object_id       => i_object_id
        );    

    o_xml := '<service_terms>';
    for r in (
        select data_type
             , attr_name
             , attr_entity_type
             , attr_object_type object_type
             , service_id
             , inst_id
          from prd_ui_attribute_object_vw
         where entity_type = i_entity_type
           and object_id   = i_object_id
           and attr_entity_type not in (rul_api_const_pkg.ENTITY_TYPE_GROUP_ATTR, fcl_api_const_pkg.ENTITY_TYPE_FEE, fcl_api_const_pkg.ENTITY_TYPE_CYCLE)
           and lang        = com_ui_user_env_pkg.get_user_lang
         order by display_order
    ) loop
        l_currency := null;
        
        o_xml := o_xml || '<service_term><name>'||r.attr_name||'</name><type>'||nvl(r.attr_entity_type, r.data_type)||'</type>';
        
        if r.attr_entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE then
            null;
            
        elsif r.attr_entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT then
            begin
                fcl_api_limit_pkg.get_limit_counter(
                    i_limit_type        => r.object_type
                  , i_product_id        => l_product_id
                  , i_entity_type       => i_entity_type
                  , i_object_id         => i_object_id
                  , i_params            => l_param_tab
                  , io_currency         => l_currency
                  , i_split_hash        => l_split_hash
                  , o_last_reset_date   => l_last_reset_date
                  , o_count_curr        => l_count_curr
                  , o_count_limit       => l_count_limit
                  , o_sum_limit         => l_sum_limit
                  , o_sum_curr          => l_sum_curr
                );
                
                o_xml := o_xml||'<limit><type>'||r.object_type||'</type><currency>'||l_currency||
                '</currency><sum_value>'||com_api_currency_pkg.get_amount_str(l_sum_curr, l_currency, com_api_const_pkg.TRUE)||
                '</sum_value><sum_limit>'||com_api_currency_pkg.get_amount_str(l_sum_limit, l_currency, com_api_const_pkg.TRUE)||'</sum_limit></limit>';
            exception
                when com_api_error_pkg.e_application_error then
                    if com_api_error_pkg.get_last_error = 'LIMIT_NOT_DEFINED' then
                        null;
                    else
                        raise;
                    end if;
            end;            
        elsif r.attr_entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE then
--            l_fee_id := 
--                prd_api_product_pkg.get_fee_id (
--                    i_product_id   => l_product_id
--                  , i_entity_type  => i_entity_type
--                  , i_object_id    => i_object_id
--                  , i_fee_type     => r.object_type
--                  , i_params       => l_param_tab
--                  , i_service_id   => r.service_id
--                  , i_split_hash   => l_split_hash
--                );
            null;
                    
        elsif r.attr_entity_type is null then
            o_xml := o_xml || '<simple><date_type>' || r.data_type ||'</data_type>';
            
            if r.data_type = com_api_const_pkg.DATA_TYPE_CHAR then
                l_value_char := 
                    prd_api_product_pkg.get_attr_value_char (
                        i_product_id   => l_product_id
                      , i_entity_type  => i_entity_type
                      , i_object_id    => i_object_id
                      , i_attr_name    => r.attr_name
                      , i_params       => l_param_tab
                      , i_service_id   => r.service_id
                      , i_split_hash   => l_split_hash
                      , i_inst_id      => r.inst_id 
                    );
                o_xml := o_xml || '<value_char>'||l_value_char||'</value_char>';
            elsif r.data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
                l_value_num := 
                    prd_api_product_pkg.get_attr_value_number (
                        i_product_id   => l_product_id
                      , i_entity_type  => i_entity_type
                      , i_object_id    => i_object_id
                      , i_attr_name    => r.attr_name
                      , i_params       => l_param_tab
                      , i_service_id   => r.service_id
                      , i_split_hash   => l_split_hash
                      , i_inst_id      => r.inst_id 
                    );
                o_xml := o_xml || '<value_number>'||to_char(l_value_num, com_api_const_pkg.XML_NUMBER_FORMAT)||'</value_number>';
            elsif r.data_type = com_api_const_pkg.DATA_TYPE_DATE then
                l_value_date := 
                    prd_api_product_pkg.get_attr_value_date (
                        i_product_id   => l_product_id
                      , i_entity_type  => i_entity_type
                      , i_object_id    => i_object_id
                      , i_attr_name    => r.attr_name
                      , i_params       => l_param_tab
                      , i_service_id   => r.service_id
                      , i_split_hash   => l_split_hash
                      , i_inst_id      => r.inst_id 
                    );
                o_xml := o_xml || '<value_date>'||to_char(l_value_date, com_api_const_pkg.XML_DATETIME_FORMAT)||'</value_date>';
            end if;
            o_xml := o_xml||'</simple>';
        end if;
        o_xml := o_xml||'</service_term>';
    end loop;
    o_xml := o_xml||'</service_terms>';
end get_object_attributes;

-- This method is used in GUI which changes attribute, therefore, it can not contain "result_cache"
function get_attribute(
    i_attr_name             in      com_api_type_pkg.t_name
  , i_mask_error            in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_is_result_cache       in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return prd_api_type_pkg.t_attribute
is
    l_attribute_rec                 prd_api_type_pkg.t_attribute;
    l_attr_name                     com_api_type_pkg.t_name := upper(i_attr_name);
begin
    begin
        if i_is_result_cache = com_api_const_pkg.TRUE then
            l_attribute_rec := get_attribute_rec(
                                   i_attr_name => l_attr_name
                               );
        else
            select id
                 , service_type_id
                 , attr_name
                 , data_type
                 , entity_type
                 , object_type
                 , definition_level
              into l_attribute_rec
              from prd_attribute
             where attr_name = l_attr_name;
        end if;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'ATTRIBUTE_NOT_FOUND'
                  , i_env_param1  => l_attr_name
                );
            end if;
    end;
    return l_attribute_rec;
end get_attribute;

-- This method is used in GUI which changes attribute, therefore, it can not contain "result_cache"
function get_attribute(
    i_attr_id               in      com_api_type_pkg.t_short_id
  , i_mask_error            in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_is_result_cache       in      com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return prd_api_type_pkg.t_attribute
is
    l_attribute_rec                 prd_api_type_pkg.t_attribute;
begin
    begin
        if i_is_result_cache = com_api_const_pkg.TRUE then
            l_attribute_rec := get_attribute_rec(
                                   i_attr_id => i_attr_id
                               );
        else
            select id
                 , service_type_id
                 , attr_name
                 , data_type
                 , entity_type
                 , object_type
                 , definition_level
              into l_attribute_rec
              from prd_attribute
             where id = i_attr_id;
        end if;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'ATTRIBUTE_NOT_FOUND'
                  , i_env_param1  => i_attr_id
                );
            end if;
    end;
    return l_attribute_rec;
end get_attribute;

-- This "result_cache" method can not contain any methods and global variables.
function get_attribute_rec(
    i_attr_name             in      com_api_type_pkg.t_name
) return prd_api_type_pkg.t_attribute
result_cache
relies_on (prd_attribute)
is
    l_attribute_rec   prd_api_type_pkg.t_attribute;
    l_attr_name       com_api_type_pkg.t_name := upper(i_attr_name);
begin
        select id
             , service_type_id
             , attr_name
             , data_type
             , entity_type
             , object_type
             , definition_level
          into l_attribute_rec
          from prd_attribute
         where attr_name = l_attr_name;

    return l_attribute_rec;
end get_attribute_rec;

-- This "result_cache" method can not contain any methods and global variables.
function get_attribute_rec(
    i_attr_id               in      com_api_type_pkg.t_short_id
) return prd_api_type_pkg.t_attribute
result_cache
relies_on (prd_attribute)
is
    l_attribute_rec   prd_api_type_pkg.t_attribute;
begin
        select id
             , service_type_id
             , attr_name
             , data_type
             , entity_type
             , object_type
             , definition_level
          into l_attribute_rec
          from prd_attribute
         where id = i_attr_id;

    return l_attribute_rec;
end get_attribute_rec;

-- This "result_cache" method can not contain any methods and global variables.
function get_attr_name(
    i_object_type       in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name
result_cache
relies_on (prd_attribute)
is
    l_attr_name   com_api_type_pkg.t_name;
begin
    select attr_name
      into l_attr_name
      from prd_attribute
     where object_type = i_object_type;

    return l_attr_name;
end get_attr_name;

end prd_api_attribute_pkg;
/
