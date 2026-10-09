program lab4;

uses windows,messages; {интерфейсы к системным DLL}

function WndProc(hWnd: THandle; Msg: integer;
                 wParam: longint; lParam: longint): longint;
                 stdcall; forward;

procedure WinMain; {ќсновной цикл обработки сообщений}
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
  wndClass.hInstance:=hInstance;
  wndClass.hIcon:=loadIcon(0, idi_Application);
  wndClass.hCursor:=loadCursor(0, idc_Arrow);
  wndClass.hbrBackground:=GetStockObject(black_Brush);
  wndClass.lpszMenuName:=nil;
  wndClass.lpszClassName:=szClassName;
  wndClass.hIconSm:=loadIcon(0, idi_Application);

  RegisterClassEx(wndClass);

  hwnd:=CreateWindowEx(
         0,
         szClassName, {им€ класса окна}
         '«аголовок окна',    {заголовок окна}
         ws_overlappedWindow,     {стиль окна}
         cw_useDefault,           {Left}
         cw_useDefault,           {Top}
         cw_useDefault,           {Width}
         cw_useDefault,           {Height}
         0,                       {хэндл родительского окна}
         0,                       {хэндл оконного меню}
         hInstance,               {хэндл экземпл€ра приложени€}
         nil);                    {параметры создани€ окна}

  ShowWindow(hwnd,sw_Show);  {отобразить окно}
  updateWindow(hwnd);   {послать wm_paint оконной процедуре, прорисовав
                         окно мину€ очередь сообщений (необ€зательно)}

  while GetMessage(msg,0,0,0) do begin {получить очередное сообщение}
    TranslateMessage(msg);   {Windows транслирует сообщени€ от клавиатуры}
    DispatchMessage(msg);    {Windows вызовет оконную процедуру}
  end; {выход по wm_quit, на которое GetMessage вернет FALSE}
end;

function WndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
  var ps:TPaintStruct;
      hdc:THandle;
      hpen:THandle;
      rect:TRect;
      color:integer;
      p:pointer;
      bmi:^TBitmapInfo;
      data:pointer;
      f:file;
      sze:integer;
begin
  result:=0;
  case Msg of
    wm_paint:
      begin
        hdc:=BeginPaint(hwnd,ps); //”далить WM_PAINT из очереди и начать рисование
        GetClientRect(hwnd,rect);

        hPen:=SelectObject(hdc,createPen(ps_Solid,3,rgb(0,200,0)));
        SetRop2(hdc,r2_xorpen);

        assignFile(f,'wallppr.bmp'); reset(f,1);
        sze:=filesize(f);
        getmem(p,sze);
        blockread(f,p^,sze);
        closeFile(f);

        integer(bmi):=integer(p)+sizeof(TBitmapFileheader);
        integer(data):=integer(p)+TBitmapFileheader(p^).bfOffBits;

        stretchDiBits(hdc,
                      rect.left,rect.top,rect.right,rect.bottom,
                      0,0,bmi^.bmiheader.biWidth, bmi^.bmiheader.biHeight,
                      data,
                      bmi^,DIB_RGB_COLORS,srccopy);

        SelectObject(hdc,GetStockObject(black_Brush));
        rectangle(hdc,10,10,130,130);
        textOut(hdc,30,30,'sdf',3);

        SetRop2(hdc,r2_copypen);
        DeleteObject(SelectObject(hdc,hPen));

        freemem(p);
        endPaint(hwnd,ps);
      end;
    wm_destroy:
      PostQuitMessage(0);
    else
      result:=DefWindowProc(hwnd,msg,wparam,lparam);
  end;
end;



begin
  WinMain;
end.
