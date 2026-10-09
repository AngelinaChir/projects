program lab5;

uses windows,messages, {интерфейсы к системным DLL}
     sysUtils; {Служебные функции Дельфи для форматирования строк и т.д.}

function WndProc(hWnd: THandle; Msg: integer;
                 wParam: longint; lParam: longint): longint;
                 stdcall; forward;

procedure WinMain; {Основной цикл обработки сообщений}
  const szClassName='Shablon';
  var   wndClass:TWndClassEx;
        hWnd: THandle;
        msg:TMsg;
begin
  wndClass.cbSize:=sizeof(wndClass);
  wndClass.style:=cs_hredraw or cs_vredraw;
  wndClass.lpfnWndProc:=@WndProc;
  wndClass.cbClsExtra:=0;
  wndClass.cbWndExtra:=0;
  wndClass.hInstance:=hPrevInst;
  wndClass.hInstance:=hInstance;
  wndClass.hIcon:=loadIcon(0, idi_Application);
  wndClass.hCursor:=loadCursor(0, idc_Arrow);
  wndClass.hbrBackground:=GetStockObject(white_Brush);
  wndClass.lpszMenuName:=nil;
  wndClass.lpszClassName:=szClassName;
  wndClass.hIconSm:=loadIcon(0, idi_Application);

  RegisterClassEx(wndClass);

  hwnd:=CreateWindowEx(
         0,
         szClassName, {имя класса окна}
         'Двигайте надпись стрелками, щелкайте левой кнопкой',    {заголовок окна}
         ws_overlappedWindow,     {стиль окна}
         cw_useDefault,           {Left}
         cw_useDefault,           {Top}
         500,                     {Width}
         200,                     {Height}
         0,                       {хэндл родительского окна}
         0,                       {хэндл оконного меню}
         hInstance,               {хэндл экземпляра приложения}
         nil);                    {параметры создания окна}

  ShowWindow(hwnd,sw_Show);  {отобразить окно}
  updateWindow(hwnd);   {послать wm_paint оконной процедуре, прорисовав
                         окно минуя очередь сообщений (необязательно)}

  while GetMessage(msg,0,0,0) do begin {получить очередное сообщение}
    TranslateMessage(msg);   {Windows транслирует сообщения от клавиатуры}
    DispatchMessage(msg);    {Windows вызовет оконную процедуру}
  end; {выход по wm_quit, на которое GetMessage вернет FALSE}
end;

function WndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
  const xOffset:integer=0; //Фактически это статические переменные
        yOffset:integer=0;
        timeStamp:integer=-1;

  var ps:TPaintStruct;
      hdc:THandle;
      rect:TRect;
      s:shortstring; //Строка как в Турбо-Паскале
      moveFlag:boolean;
begin
  result:=0;
  case Msg of
    wm_create:
      begin
        SetTimer(hwnd,0,1000,nil); // Таймер ~1 с, посылает WM_TIMER
      end;

    wm_paint:
      begin
        hdc:=BeginPaint(hwnd,ps); //Удалить WM_PAINT из очереди и начать рисование
        GetClientRect(hwnd,rect);

        s:='Время после щелчка левой кнопкой составило:';
        TextOut(hdc,xOffset+5,yOffset+5,@s[1],length(s));

        if TimeStamp>0 then begin
          s:=intToStr(GetTickCount-TimeStamp);
          TextOut(hdc,xOffset+5,yOffset+20,@s[1],length(s));
        end;

        endPaint(hwnd,ps);
      end;

    WM_KEYDOWN:
      begin
        moveFlag:=true;
        case wParam of
          vk_up: dec(yOffset); // Движение надписи стрелками
          vk_down: inc(yOffset);
          vk_left: dec(xOffset);
          vk_right: inc(xOffset);
          vk_escape: begin xOffset:=0; yOffset:=0; end; // Вернуть по умолчанию
        else
          moveFlag:=false; // иначе надпись не двигалась
        end;
        if moveFlag then begin // Если надпись двигалась
          invalidaterect(hwnd,nil,true);
          updateWindow(hwnd); //Перерисовать окно сейчас же, не дожидаясь опустошения очереди
        end;
      end;

    wm_lbuttondown:
      begin
        TimeStamp:=GetTickCount;
        invalidateRect(hwnd,nil,true);
      end;

    wm_timer:
      if timeStamp>0 then begin // Если время не идет, то не нужно перерисовывать
        invalidateRect(hwnd,nil,true);
      end;

    wm_destroy:
      begin
        killTimer(hwnd,0);
        PostQuitMessage(0);
      end;

    else
      result:=DefWindowProc(hwnd,msg,wparam,lparam);
  end;
end;



begin
  WinMain;
end.
