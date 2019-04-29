create or replace function get_translit(i_text in varchar2) return varchar2 is
    l_text varchar2(2000);
begin
    l_text := i_text;
    for rec in (select t.char_from, t.char_to from com_translit t  order by length(t.char_from) desc)
    loop
        l_text := replace(l_text, rec.char_from, rec.char_to);
    end loop;
    return l_text;
end get_translit;
/
