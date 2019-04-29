begin
    for rec in (select 1 from dual where not exists(
        select 1 from user_tab_cols
        where table_name = upper('rus_form_250_cards')
              and column_name = upper('is_contactless')) )
    loop
        execute immediate 'alter table rus_form_250_cards add (is_contactless number (1))';
    end loop;
end;
/

comment on column rus_form_250_cards.is_contactless is 'Flag that card is contactless.'
/

begin
    for rec in (select 1 from dual where not exists(
        select 1 from user_tab_cols
        where table_name = upper('rus_form_250_opers')
              and column_name = upper('is_contactless')) )
    loop
        execute immediate 'alter table rus_form_250_opers add (is_contactless number (1))';
    end loop;
end;
/

comment on column rus_form_250_opers.is_contactless is 'Flag that operation is contactless.'
/
