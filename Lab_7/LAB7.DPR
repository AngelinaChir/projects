//+----------------------------------------------------------------------------+
//¦                       Лабораторная работа по ОС			                       ¦
//¦                     Использование ресурсов и DLL                           ¦
//¦----------------------------------------------------------------------------¦
//¦				   Студент: Базарнов Д.И.  			                    				         ¦
//¦					  Группа: A-07-20															                     ¦
//¦		Номер варианта: 3 															                         ¦
//¦		  	   Задание: В этой работе необходимо написать программу, пользующуюся¦
//¦                   ресурсами и функциями из DLL. Главное окно программы     ¦
//¦                   должно быть снабжено меню и собственным нестандартным    ¦
//¦                   значком. В одном из окон программы должен использоваться ¦
//¦                   нестандартный курсор мыши. Все строки, битовые образы,   ¦
//¦                   курсоры, значки, используемые в программе, должны быть   ¦
//¦                   описаны в ресурсах.                                      ¦
//¦		  	   Один из пунктов меню должен активизировать модальный диалог из    ¦
//¦          ресурса, поведение которого соответствует заданию на ЛР №6.       ¦
//¦                                                                            ¦
//¦          Другой пункт меню должен активизировать "окно-заставку", фон      ¦
//¦          которого заполнен битовым образом способом, указанным в задании ЛР¦
//¦          №4, предусмотреть вывод номера бригады в этом окне.               ¦
//¦                                                                            ¦
//¦          Выход из программы также предусмотреть при помощи соответствующего¦
//¦          пункта меню.                                                      ¦
//¦                                                                            ¦
//¦          Еще один пункт меню должен приводить к вызову функции готовой DLL ¦
//¦          с именем LIB7.DLL в соответствии с вариантом (см. таблицу). В     ¦
//¦          качестве параметра PChar необходимо передавать указатель на       ¦
//¦          существующую строку, заканчивающуюся нулем.                       ¦
//¦            №	        Идентификатор        Параметры                       ¦
//¦            3	          'proc3'	       a: pchar; b: char;                  ¦
//¦      Возвр.значение	 Модель вызова	   Способ загрузки DLL¦                ¦
//¦ 	      boolean	         API	            статический                      ¦
//+----------------------------------------------------------------------------+

program Lab_7_Dmitry;

uses windows, messages,  {интерфейсы к системным DLL}
     Sysutils, ResConst;

{$R DescRes.res} // Подключается файл ресурсов
{$H+}

const
  LIB7 = 'LIB7.DLL';
  szClassNameAbout = 'AboutWnd';

var
  str1, str2: string;
  TeamNameLen: integer;
  next_val, AboutWndCreate: boolean;
  hWnd,hWndAb: THandle;                    {Хэндлы главного окна и окна-заставки}
  BkGnd: HBitmap;                           {Хэндл битового образа}
  TeamNameBuf: array [byte] of char;        {Буфер под номер бригады}
  Symbol: array[0..1] of Char;
  lenSymbol:Integer;
  Operation: array[0..1] of Char;


{Статическая загрузка функции из DLL}
function MyProc3(a:PChar; b:Char):boolean; stdcall; external LIB7 name 'proc3';
function WndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint;  stdcall; forward;
function WndProcAbout(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint;  stdcall; forward;
function DlgProc(hDlg: THandle; Msg: integer; wParam: longint; lParam: longint): LRESULT; stdcall; forward;

{---------------------Основная процедура программы-----------------------------}
procedure WinMain;
  const
    szClassName='Calculator';

  var
    WndClass, WndClassAbout:TWndClassEx;
    Msg:TMsg;
    WndNameBuf: array [byte] of char;    {Буфер под имя главного окна}
    hAccel:THandle;

begin
  AboutWndCreate:=false;
  
  {Загрузка имени окна из файла ресурсов}
  LoadString(hInstance,IDS_WNDNAME,@WndNameBuf,MAXBYTE);

  {Заполнение описания оконного класса}
  wndClass.cbSize:=sizeof(wndClass);
  wndClass.style:=CS_HREDRAW or CS_VREDRAW;
  wndClass.lpfnWndProc:=@WndProc;
  wndClass.cbClsExtra:=0;
  wndClass.cbWndExtra:=0;
  wndClass.hInstance:=hInstance;
  wndClass.hIcon:=LoadIcon(hInstance, 'MainIcon');
  wndClass.hCursor:=LoadCursor(hInstance, 'Skelet');
  wndClass.hbrBackground:=GetStockObject(white_Brush);
  wndClass.lpszMenuName:='CalcMenu';
  wndClass.lpszClassName:=szClassName;
  wndClass.hIconSm:=wndClass.hIcon;

  RegisterClassEx(wndClass);

  {Заполнение описания оконного класса для "окна-заставки"}
  wndClassAbout.cbSize:=sizeof(wndClassAbout);
  wndClassAbout.style:=CS_HREDRAW or CS_VREDRAW;
  wndClassAbout.lpfnWndProc:=@WndProcAbout;
  wndClassAbout.cbClsExtra:=0;
  wndClassAbout.cbWndExtra:=0;
  wndClassAbout.hInstance:=hInstance;
  wndClassAbout.hIcon:=LoadIcon(0,idi_Application);
  wndClassAbout.hCursor:=LoadCursor(0,idc_Arrow);
  wndClassAbout.hbrBackground:=0;
  wndClassAbout.lpszMenuName:=nil;
  wndClassAbout.lpszClassName:=szClassNameAbout;
  wndClassAbout.hIconSm:=LoadIcon(0,idi_Application);

  RegisterClassEx(wndClassAbout);

  hWnd:=CreateWindowEx(0,
         szClassName,   {имя класса окна}
         @WndNameBuf,   {заголовок окна}
         ws_overlappedwindow, {стиль окна}
         10,            {Left}
         10,            {Top}
         600,           {Width}
         500,           {Height}
         0,             {хэндл родительского окна}
         0,             {хэндл оконного меню}
         hInstance,     {хэндл экземпляра приложения}
         nil);          {параметры создания окна}

  ShowWindow(hWnd,SW_SHOW);

  hAccel:= LoadAccelerators(hInstance, 'ComboKeys');

  {Основной цикл обработки сообщений}
  while GetMessage(Msg,0,0,0) do begin {получить очередное сообщение}
    if TranslateAccelerator(hWnd, hAccel, Msg) = 0 then begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  end;   
end;

{---------------------Оконная процедура класса основного окна------------------}
function WndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
var
  StringBuf: array [byte] of char;  {Буфер под строку, передаваемую в функцию DLL}
  WndAboutNameBuf: array [byte] of char; {Буфер под строку-заголовок "окна-заставки"}
  TempVal: boolean;   {Переменная для хранения возвращаемого функцией DLL значения}

begin
  result:=0;
  case Msg of
    WM_COMMAND:
      if ((HiWord(wParam) = 0) or (HiWord(wParam) = 1)) then  {Если сообщение от меню или аксселератора}
        case LoWord(wParam) of
          IDM_DLLFUNC:
            begin
              LoadString(hInstance,IDS_STRINGFORDLL,@StringBuf,MAXBYTE);
              TempVal:=MyProc3(@StringBuf,'С');
            end;
          IDM_EXIT:
            SendMessage(hWnd,WM_DESTROY,0,0);
          IDM_ABOUT:
            if not AboutWndCreate then
            begin
              LoadString(hInstance,IDS_WNDABOUTNAME,@WndAboutNameBuf,MAXBYTE);
              TeamNameLen:=LoadString(hInstance,IDS_TEAMNAME,@TeamNameBuf,MAXBYTE);
              BkGnd:=LoadBitmap(hInstance,'AboutBMP');
                                               {Создание "окна-заставки"}
              hWndAb:=CreateWindow(szClassNameAbout,
                                    @WndAboutNameBuf,
                                    WS_CHILD or WS_CAPTION or WS_SYSMENU,
                                    100,
                                    25,
                                    350,
                                    300,
                                    hWnd,
                                    0,
                                    hInstance,
                                    nil);
              AboutWndCreate:=true;        {"Окно-заставка" создано}
              ShowWindow(hWndAb,SW_SHOW);
            end;
          IDM_CALC:
            begin
              {Инициализация переменных}
              next_val:=false;
              str1:=' ';
              str2:=' ';

              {Создание диалога-калькулятора}
              DialogBox(hInstance,'CalcDialog',hWnd,@DlgProc);
            end;
        end;
      WM_DESTROY:
        PostQuitMessage(0);
  else
    result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  end;
end;

{---------------------Оконная процедура класса окна "о программе"--------------}
function WndProcAbout(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
var
  hdc,hdcMem: Thandle;
  ps: TPaintStruct;
  rect: TRect;

  bm: TBitmap;           {Информация о битовом образе}
  PrevBkMode: integer;   {Режим фона окна}

begin
  result:=0;
  case Msg of
    WM_PAINT:
      begin
        hdc:=BeginPaint(hwnd,ps);
        GetClientRect(hwnd,rect);

        {Вывод изображения}
        hdcMem:=CreateCompatibleDC(hdc);
        SelectObject(hdcMem,Bkgnd);
        GetObject(BkGnd,sizeof(TBitmap),@bm);
        SetStretchBltMode(hdc, ColorOnColor);
        StretchBlt(hdc,
                    rect.left,rect.top,rect.right-rect.left,rect.bottom-rect.top,
                    hdcMem,0,0,bm.bmWidth,bm.bmHeight,
                    SRCCOPY);
        DeleteDC(hdcMem);

        {Вывод номера бригады}
        PrevBkMode:=SetBkMode(hdc,TRANSPARENT);
        TextOut(hdc,130,20,@TeamNameBuf,TeamNameLen);
        SetBkMode(hdc,PrevBkMode);
        EndPaint(hwnd,ps);

      end;
    WM_DESTROY:
      begin
        DeleteObject(BkGnd);
        AboutWndCreate:=false;              {"Окно-заставка" закрыто}
      end;
  else
    result:=DefWindowProc(hWnd,Msg,wParam,lParam);
  end;
end;

{---------------------Диалоговая процедура окна-калькулятора-------------------}
function DlgProc(hDlg: THandle; Msg: integer; wParam: longint; lParam: longint): LRESULT; stdcall;
var
  MsgBuf: array [byte] of char;            {Буфер под сообщение об ошибке}
  MsgBoxNameBuf: array [byte] of char;     {Буфер под заголовок сообщения об ошибке}

  Buffer: array[0..30] of Char;
  str:string;
  Res:Int64;
  i, j, FirstOperand, SecondOperand:integer;


begin
  result:=1;
  case Msg of
    WM_COMMAND: // Обработка команд от всех органов управления
      case HiWord(wParam) of
        BN_Clicked:
          begin
            FillChar(Buffer, SizeOf(Buffer), 0);
            SendMessage(GetDlgItem(hDlg,IDC_CALCEDITBOX),WM_GETTEXT,SizeOf(Buffer),Integer(@Buffer));
            case LoWord(wParam) of
              IDC_BTNDEL:
                begin
                  for i:=0 to Length(Buffer) do
                    Buffer[i]:=#0;
                  lenSymbol:=0;
                end;
              IDC_BTNPLUS, IDC_BTNMINUS, IDC_BTNMUL, IDC_BTNDIV:
                begin
                  if (Operation = '') and (Buffer[0] <> #0) then begin
                    GetWindowText(GetDlgItem(hDlg, LoWord(wParam)), @Operation, SizeOf(Operation));
                    i:=0;
                    While (Buffer[i] <> Chr(0)) do i:=i+1;
                    Buffer[i]:=Operation[0];
                    lenSymbol:=0;
                  end;
                end;
              IDC_BTNEQU:
                begin
                  {Выделяем первый операнд}
                  i:=0;
                  While ((Buffer[i] <> Operation[0]) and (Buffer[i] <> #0)) do
                    begin
                      str:=str+Buffer[i];
                      i:=i+1;
                    end;
                  if str <> EmptyStr then
                    begin
                      FirstOperand:=StrToInt(str);
                      Delete(str, 1, Length(str));

                      {Проверяем количество операндов}
                      if Operation[0] <> #0 then begin
                        //Ищем позицию знака
                        i:=0;
                        While ((Buffer[i] <> Operation[0]) and (Buffer[i] <> #0)) do i:=i+1;

                        {Выделяем второй операнд}
                        i:=i+1;
                        While (Buffer[i] <> #0) do
                          begin
                            str:=str+Buffer[i];
                            i:=i+1;
                          end;

                        if str <> EmptyStr then
                          begin
                            SecondOperand:=StrToInt(str);
                            Delete(str, 1, Length(str));

                            {В зависимости от знака производим операцию}
                            case Operation[0] of
                              '/':
                                begin
                                  if (SecondOperand = 0) then begin
                                    LoadString(hInstance,IDS_NULLDIV,@MsgBoxNameBuf,MAXBYTE);
                                    LoadString(hInstance,IDS_NULLDIVMSG,@MsgBuf,MAXBYTE);
                                    MessageBox(hDlg,@MsgBuf,@MsgBoxNameBuf,MB_OK);
                                    res:=0;
                                  end
                                  else Res:=FirstOperand div SecondOperand;
                                end;
                              '*':
                                begin
                                  Res:=FirstOperand * SecondOperand;
                                end;
                              '+':
                                begin
                                  Res:=FirstOperand + SecondOperand;
                                end;
                              '-':
                                begin
                                  Res:=FirstOperand - SecondOperand;
                                end;
                            end;
                            FillChar(Buffer, SizeOf(Buffer), 0);
                            str:=IntToStr(Res);
                            for i:=1 to Length(str) do
                              Buffer[i-1]:=str[i];

                            SendDlgItemMessage(hDlg,IDC_CALCEDITBOX,WM_SETTEXT,0,Integer(@Buffer));

                            FirstOperand:=-1;
                            SecondOperand:=-1;
                            Operation:=#0;
                          end;
                      end;
                    end;
                end;
            else begin
              j:=LoWord(wParam) - IDC_CALCEDITBOX - 1;
              if (lenSymbol < 9) and (j >= 0) and (j <= 9) then begin
                i:=0;
                While (Buffer[i] <> #0) do i:=i+1;
                if (i < (Length(Buffer)-1)) and (Buffer[Length(Buffer)-1] = #0) then
                  begin
                    Buffer[i]:=IntToStr(j)[1];
                    lenSymbol:=lenSymbol+1;
                  end;
              end;
            end;
            end;
            SendDlgItemMessage(hDlg,IDC_CALCEDITBOX,WM_SETTEXT,0,Integer(@Buffer));
          end;
      end;
    WM_CLOSE:
        EndDialog(hdlg,idCancel);
  else
    result:=0;                  {Сообщение не обрабатывалось}
    // Никаких DefDlgProc!
  end;
end;


begin
  WinMain;
end.
