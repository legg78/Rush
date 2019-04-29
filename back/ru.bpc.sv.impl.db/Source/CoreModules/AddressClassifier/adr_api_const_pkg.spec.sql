create or replace package adr_api_const_pkg as

    UNDEFINED_COUNTRY_ID                    constant    com_api_type_pkg.t_tiny_id      := 255;

    ADDRESS_COMPONENT_DEPARTMENT            constant    com_api_type_pkg.t_tiny_id      := 101;
    ADDRESS_COMPONENT_MUNICIPALITY          constant    com_api_type_pkg.t_tiny_id      := 102;

end adr_api_const_pkg;
/
