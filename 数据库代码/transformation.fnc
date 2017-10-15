create or replace function transformation(right_key in varchar2)
  return varchar2 is
  str varchar2(100);

begin
  if instr(upper(right_key), 'A') > 0 then
    str := '1';
  end if;
  if instr(upper(right_key), 'B') > 0 then
    str := str || '2';
  end if;
  if instr(upper(right_key), 'C') > 0 then
    str := str || '3';
  end if;
  if instr(upper(right_key), 'D') > 0 then
    str := str || '4';
  end if;
  if instr(right_key, '¶Ô') > 0 then
    str := str || '1';
  end if;
  if instr(right_key, '´í') > 0 then
    str := str || '2';
  end if;
  if instr(right_key, '1') > 0 then
    str := str || 'A';
  end if;
  if instr(right_key, '2') > 0 then
    str := str || 'B';
  end if;
  if instr(right_key, '3') > 0 then
    str := str || 'C';
  end if;
  if instr(right_key, '4') > 0 then
    str :=str ||'D';
  end if;
  return(str);
end;
/
