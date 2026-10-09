program lab7;

uses windows, messages; {интерфейсы к системным DLL}

{$R res7.res} // Подключается файл ресурсов

procedure static(a,b:integer); stdcall; external 'lib7.dll' name 'static';
  //Статическая загрузка функции

var dyn:procedure(a,b:integer) stdcall; //Переменная для динамической загрузки
    hLib7:hModule;


function dlgProc(hdlg: THandle; Msg: integer; wParam: longint; lParam: longint): LRESULT; stdcall;
  const
      btnGet=1;         btnSet=2;
      btnClear=3;       btnExecute=4;
      list=5;           edit=6;

  var i,j:integer;
      buffer: array[0..255] of char;
begin
  result:=1;
  case Msg of
    wm_command: // Обработка команд от всех органов управления
      case hiword(wParam) of
        BN_Clicked:
          if loword(wParam)=btnExecute then begin

            if SendMessage(GetDlgItem(hdlg,btnSet), BM_GETCHECK,0,0)<>0 then begin
              SendMessage(GetDlgItem(hdlg,edit),wm_gettext,sizeof(buffer),integer(@buffer));
              SendMessage(GetDlgItem(hdlg,list),LB_ADDSTRING,0,integer(@buffer))
            end

            else if SendMessage(GetDlgItem(hdlg,btnGet), BM_GETCHECK,0,0)<>0 then begin
              i:=SendDlgItemMessage(hdlg,list,LB_GETCURSEL,0,0);
              if i>=0 then
                SendDlgItemMessage(hdlg,list,LB_GETTEXT,i,integer(@buffer))
                {Т.к. заполнение идет из этого буфера, то длины буфера хватит}
              else
                buffer[0]:=#0; // Ничего не выбрано => пустой буфер
              SendDlgItemMessage(hdlg,edit,wm_settext,sizeof(buffer),integer(@buffer));
            end

            else if SendMessage(GetDlgItem(hdlg,btnClear), BM_GETCHECK,0,0)<>0 then begin
              SendDlgItemMessage(hdlg,list,LB_RESETCONTENT,0,0);
            end;
          end;
      end; //case hiword(wparam) in for WM_COMMAND message

    wm_close:
      begin
        EndDialog(hdlg,idCancel);
      end;
    else
      result:=0;
      // Никаких DefDlgProc!
  end;
end;


function wndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
begin
  result:=0;
  case Msg of
    wm_create:
      begin
        // А теперь -- загрузка вручную. На самом деле эта DLL уже загружена,
        // поэтому еще раз не загружается, увеличивается лишь счетчик ссылок на нее
        hLib7:=loadLibrary('lib7.dll');
        // Настройка переменной процедурного типа на индекс 100 в DLL
        @dyn:=GetProcAddress(hLib7,pointer(100));
      end;
    wm_command: // Обработка команд от всех органов управления
      if hiword(wparam)=0 then begin //В сообщениях меню нулевой код уведомления
        case loword(wparam) of
          101: static(101,1);
          102: dyn(102,1);
          103: // Диалог из ресурса другого модуля -- hLib7 !
            DialogBox(hLib7,'lib7dlg',hwnd,@dlgproc);
          104: sendmessage(hwnd,wm_close,0,0);
        end;
      end;
    wm_close:
      begin // Органы управления уничтожаются автоматически
        FreeLibrary(hLib7);
        PostQuitMessage(0);
      end;
    else
      result:=DefWindowProc(hwnd,msg,wparam,lparam);
  end;
end;

procedure WinMain; {Основной цикл обработки сообщений}
  const szClassName='Controls demo';
  var   wndClass:TWndClassEx;
        msg:TMsg;
        hwnd1,hwnd2:THandle;
        sbuf:array[byte] of char;
begin
  loadString(hInstance,1,@sbuf,256);

  wndClass.cbSize:=sizeof(wndClass);
  wndClass.style:=0;
  wndClass.lpfnWndProc:=@WndProc;
  wndClass.cbClsExtra:=0;
  wndClass.cbWndExtra:=0;
  wndClass.hInstance:=hInstance;
  wndClass.hIcon:=loadIcon(hInstance, 'lab7');
  wndClass.hCursor:=loadCursor(hInstance, 'TRIANGLE');
  wndClass.hbrBackground:=GetStockObject(white_Brush);
  wndClass.lpszMenuName:='lab7menu';
  wndClass.lpszClassName:=szClassName;
  wndClass.hIconSm:=wndClass.hIcon;

  RegisterClassEx(wndClass);

  hwnd1:=CreateWindowEx(0,
         szClassName, {имя класса окна}
         @sbuf,    {заголовок окна}
         ws_overlappedwindow,       {стиль окна}
         10,           {Left}
         10,           {Top}
         500,                     {Width}
         300,                     {Height}
         0,                       {хэндл родительского окна}
         0,                       {хэндл оконного меню}
         hInstance,               {хэндл экземпляра приложения}
         nil);                    {параметры создания окна}

  ShowWindow(hwnd1,sw_showmaximized);

  while GetMessage(msg,0,0,0) do begin {получить очередное сообщение}
      TranslateMessage(msg);   {Windows транслирует сообщения от клавиатуры}
      DispatchMessage(msg);    {Windows вызовет оконную процедуру}
  end; {выход по wm_quit, на которое GetMessage вернет FALSE}
end;


begin
  WinMain;
end.
