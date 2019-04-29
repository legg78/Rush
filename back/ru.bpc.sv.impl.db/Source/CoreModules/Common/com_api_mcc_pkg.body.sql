create or replace package body com_api_mcc_pkg is
    
procedure apply_mcc_update (
    i_mcc_tab           in      com_api_type_pkg.t_mcc_tab
  , i_cab_type_tab      in      com_api_type_pkg.t_mcc_tab
) is
begin
    forall i in 1 .. i_mcc_tab.count
        merge into
            com_mcc dst
        using (
            select
                i_mcc_tab(i) mcc
                , i_cab_type_tab(i) mastercard_cab_type
            from dual
        ) src
        on (
            src.mcc = dst.mcc
        )
        when matched then
            update
            set
                dst.mastercard_cab_type = src.mastercard_cab_type
        when not matched then
            insert (
                dst.id
                , dst.seqnum
                , dst.mcc
                , dst.diners_code
                , dst.mastercard_cab_type
            ) values (
                com_mcc_seq.nextval
                , 1
                , src.mcc
                , null
                , src.mastercard_cab_type
            );

end;

procedure apply_mcc_update (
    i_mcc_tab           in      com_api_type_pkg.t_mcc_tab
  , i_cab_type_tab      in      com_api_type_pkg.t_mcc_tab
  , i_active_records    in      com_api_type_pkg.t_integer_tab
) is
begin
    if i_active_records.count > 0 then
        forall i in values of i_active_records
            merge into
                com_mcc dst
            using (
                select
                    i_mcc_tab(i) mcc
                    , i_cab_type_tab(i) mastercard_cab_type
                from dual
            ) src
            on (
                src.mcc = dst.mcc
            )
            when matched then
                update
                set
                    dst.mastercard_cab_type = src.mastercard_cab_type
            when not matched then
                insert (
                    dst.id
                    , dst.seqnum
                    , dst.mcc
                    , dst.diners_code
                    , dst.mastercard_cab_type
                ) values (
                    com_mcc_seq.nextval
                    , 1
                    , src.mcc
                    , null
                    , src.mastercard_cab_type
                );
    end if;
end;

procedure get_mcc_info(
    i_mcc               in      com_api_type_pkg.t_mcc
  , o_tcc                  out  varchar2
  , o_diners_code          out  varchar2
  , o_mc_cab_type          out  varchar2
) is
begin
    select tcc
         , diners_code
         , mastercard_cab_type
      into o_tcc
         , o_diners_code
         , o_mc_cab_type
      from com_mcc
     where mcc = i_mcc;
     
exception
    when no_data_found then
        null;     
end;


end;
/