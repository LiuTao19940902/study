create or replace function transformation2(choose_key in varchar2)
  return varchar2 is
  str varchar2(100);

begin
  if instr(choose_key, '1') > 0 then
    str := 'A';
  end if;
  if instr(choose_key, '2') > 0 then
    str := str || 'B';
  end if;
  if instr(choose_key, '3') > 0 then
    str := str || 'C';
  end if;
  if instr(choose_key, '4') > 0 then
    str := str || 'D';
  end if;
  return(str);
end;
/
