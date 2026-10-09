{$H+}
library Lib7;

uses windows, SysUtils;

{$R libres7.res}

procedure procd1(a,b:integer); cdecl;
  var s:string;
begin
  s:='Первый параметр '+intToStr(a)+#13#10+'Второй параметр '+intToStr(b);
  MessageBox(0,pchar(s),
              'Procedure 1',mb_ok or MB_ICONINFORMATION);
end;

function procd2(a,b:pchar):integer ; pascal;
  var s:string;
begin
  result:=integer(strPos(a,b));
  if result>integer(a) then result:=result-integer(a)+1;
  s:='Первая строка: "'+a+'"'#13#10'Вторая строка: "'+b+'"'#13#10;
  MessageBox(0,pchar(s),
              'Procedure 2',mb_ok or MB_ICONINFORMATION);
end;

function procd3(a:pchar; b:char):boolean; stdcall;
  var s:string;
begin
  result:=StrScan(a,b)<>nil;
  s:='Символ "'+b+'" в строке "'+a+'" ';
  if not result then s:=s+'не ';
  s:=s+'встречается';
  MessageBox(0,pchar(s),
              'Procedure 3',mb_ok or MB_ICONINFORMATION);
end;

function procd4(a,b:pchar):pointer ;  cdecl;
  var s:string;
begin
  s:='Первая строка: "'+a+'"'#13#10'Вторая строка: "'+b+'"'#13#10;
  result:=a;
  MessageBox(0,pchar(s),
              'Procedure 4',mb_ok or MB_ICONINFORMATION);
end;

procedure procd5(a:pchar; var b:integer); pascal;
  var s:string;
begin
  s:='Первая строка: "'+a+'"'#13#10'Второе число: '+intToStr(b);
  inc(b);
  MessageBox(0,pchar(s),
              'Procedure 5',mb_ok or MB_ICONINFORMATION);
end;

function procd6(a,b:integer):integer ; stdcall;
  var s:string;
begin
  s:='Первый параметр '+intToStr(a)+#13#10+'Второй параметр '+intToStr(b);
  result:=a+b;
  MessageBox(0,pchar(s),
              'Procedure 6',mb_ok or MB_ICONINFORMATION);
end;

function procd7(a,b:pchar):char;  cdecl;
  var s:string;
begin
  result:=b^;
  s:='Первая строка: "'+a+'"'#13#10'Вторая строка: "'+b+'"'#13#10;
  MessageBox(0,pchar(s),
              'Procedure 7',mb_ok or MB_ICONINFORMATION);
end;

function procd8(a:pchar; b:char):smallint; pascal;
  var s:string;
begin
  result:=integer(a^=b);
  s:='Символом "'+b+'" строка "'+a+'" ';
  if result=0 then s:=s+'не ';
  s:=s+'начинается';
  MessageBox(0,pchar(s),
              'Procedure 8',mb_ok or MB_ICONINFORMATION);
end;

function procd9(a,b:pchar):boolean; stdcall;
  var s:string;
begin
  result:=boolean(strcomp(a,b));
  s:='Первая строка: "'+a+'"'#13#10'Вторая строка: "'+b+'"'#13#10;
  MessageBox(0,pchar(s),
              'Procedure 9',mb_ok or MB_ICONINFORMATION);
end;

procedure procd10(a:pchar; var b:integer);  cdecl;
  var s:string;
begin
  s:='Первая строка: "'+a+'"'#13#10'Второе число: '+intToStr(b);
  dec(b);
  MessageBox(0,pchar(s),
              'Procedure 10',mb_ok or MB_ICONINFORMATION);
end;


procedure stat(a,b:integer); stdcall;
  var s:string;
begin
  s:='Первый параметр '+intToStr(a)+#13#10+'Второй параметр '+intToStr(b);
  MessageBox(0,pchar(s),
              'Static:',mb_ok or MB_ICONINFORMATION);
end;

function dynam(a,b:integer):boolean ; stdcall;
  var s:string;
begin
  s:='Первый параметр '+intToStr(a)+#13#10+'Второй параметр '+intToStr(b);
  MessageBox(0,pchar(s),
              'Dynamic:',mb_ok or MB_ICONINFORMATION);
end;

exports
  procd1 index 1,
  procd2 index 2,
  procd3 name 'proc3',
  procd4 name 'proc4',
  procd5 index 5,
  procd6 index 6,
  procd7 name 'proc7',
  procd8 name 'proc8',
  procd9 index 9,
  procd10 name 'proc10',
  stat name 'static',
  dynam index 100;

end.
