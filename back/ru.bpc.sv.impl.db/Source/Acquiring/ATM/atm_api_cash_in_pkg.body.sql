create or replace package body atm_api_cash_in_pkg as
/*********************************************************
 *  Api for cash in <br>
 *  Created by Kryukov E.(krukov@bpcbt.com)  at 17.11.2011  <br>
 *  Last changed by $Author$ <br>
 *  $LastChangedDate::                           $  <br>
 *  Revision: $LastChangedRevision$ <br>
 *  Module: atm_api_cash_in_pkg <br>
 *  @headcom
 **********************************************************/


procedure sync(
    i_params      in     atm_cash_in_tpt
) is
    seqnum number;
begin
    for rec in (
        select
            terminal_id
        from
            table(cast(i_params as atm_cash_in_tpt))
        group by terminal_id)
    loop
        delete
            atm_bna_counts b
        where
            b.id in (
                select
                    a.id
                from
                    atm_cash_in a
                where
                    a.terminal_id = rec.terminal_id
            );

        delete
            atm_cash_in a
        where
            a.terminal_id = rec.terminal_id;

        for note in (
            select
                terminal_id
              , face_value
              , currency
              , denomination_code
              , is_active
              , encashed4
              , encashed3
              , encashed2
              , retracted4
              , retracted3
              , retracted2
              , counterfeit3
              , counterfeit2
            from table(cast(i_params as atm_cash_in_tpt))
            where
                terminal_id = rec.terminal_id )
        loop
            select
                atm_cash_in_seq.nextval
            into
                seqnum
            from dual;

            insert into atm_cash_in (
                id
              , terminal_id
              , face_value
              , currency
              , denomination_code
              , is_active
            )
            values (
                seqnum
              , note.terminal_id
              , note.face_value
              , note.currency
              , note.denomination_code
              , note.is_active
            );

            insert into atm_bna_counts (
                id
              , note_encashed_type4
              , note_encashed_type3
              , note_encashed_type2
              , note_retracted_type4
              , note_retracted_type3
              , note_retracted_type2
              , note_counterfeit_type3
              , note_counterfeit_type2
            )
            values (
                seqnum
              , note.encashed4
              , note.encashed3
              , note.encashed2
              , note.retracted4
              , note.retracted3
              , note.retracted2
              , note.counterfeit3
              , note.counterfeit2
            );

        end loop;
    end loop;
end sync;

end;
/
