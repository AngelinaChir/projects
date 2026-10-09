program lab4;

uses windows, messages; {интерфейсы к системным DLL}

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
         szClassName, {имя класса окна}
         'Lab 4 - Var 5',    {заголовок окна}
         ws_overlappedWindow,     {стиль окна}
         cw_useDefault,           {Left}
         cw_useDefault,           {Top}
         800,                     {Width}
         600,                     {Height}
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
  var ps:TPaintStruct;
      hdc:THandle;
      hpen:THandle;
      rect:TRect;
      p:pointer;
      bmi:^TBitmapInfo;
      data:pointer;
      f:file;
      sze:integer;

  var x, y: Integer;
      tileW, tileH: Integer;
      width, height: Integer;
      left, top: Integer;
      hFont, oldFont: THandle;
      oldMode: Integer;
      textLines: array[0..5] of string;
      i, lineHeight: Integer;
      fileExists: Boolean;

begin
  result:=0;
  case Msg of
    wm_paint:
      begin
        hdc := BeginPaint(hwnd, ps);
        GetClientRect(hwnd, rect);

        // Проверяем существование файла
        fileExists := False;
        {$I-} // Отключаем проверку ввода-вывода
        assignFile(f, 'wallppr.bmp');
        reset(f, 1);
        {$I+} // Включаем проверку ввода-вывода обратно
        if IOResult = 0 then
        begin
          fileExists := True;
          sze := filesize(f);
          getmem(p, sze);
          seek(f, 0);
          blockread(f, p^, sze);
          closeFile(f);

          integer(bmi) := integer(p) + sizeof(TBitmapFileheader);
          integer(data) := integer(p) + TBitmapFileheader(p^).bfOffBits;

          // мозаичное заполнение фона
          tileW := bmi^.bmiHeader.biWidth;
          tileH := bmi^.bmiHeader.biHeight;

          y := rect.top;
          while y < rect.bottom do
          begin
            x := rect.left;
            while x < rect.right do
            begin
              StretchDIBits(
                hdc,
                x, y, tileW, tileH,
                0, 0, tileW, tileH,
                data, bmi^, DIB_RGB_COLORS, SRCCOPY
              );
              x := x + tileW;
            end;
            y := y + tileH;
          end;

          FreeMem(p);
        end
        else
        begin
          // Если файл не найден, создаем градиентный фон
          for y := rect.top to rect.bottom do
          begin
            hpen := CreatePen(PS_SOLID, 1, RGB(
              Round(255 * y / rect.bottom),
              Round(128 * y / rect.bottom),
              Round(64 * y / rect.bottom)
            ));
            SelectObject(hdc, hpen);
            MoveToEx(hdc, rect.left, y, nil);
            LineTo(hdc, rect.right, y);
            DeleteObject(hpen);
          end;
        end;

        // рисуем рамку 70% по ширине и высоте окна
        width := Round((rect.right - rect.left) * 0.7);   // 70% ширины окна
        height := Round((rect.bottom - rect.top) * 0.7);  // 70% высоты окна

        left := (rect.right - width) div 2;
        top := (rect.bottom - height) div 2;

        hPen := CreatePen(PS_SOLID, 3, RGB(255, 255, 255)); // белая рамка
        SelectObject(hdc, hPen);
        SelectObject(hdc, GetStockObject(NULL_BRUSH));
        Rectangle(hdc, left, top, left + width, top + height);

        // создаем шрифт Times New Roman 12pt
        hFont := CreateFont(
          -MulDiv(12, GetDeviceCaps(hdc, LOGPIXELSY), 72), // размер 12pt
          0, 
          0, // без наклона
          0, 
          FW_NORMAL, // обычный вес
          0, 
          0, 
          0, 
          RUSSIAN_CHARSET, 
          OUT_TT_PRECIS, 
          CLIP_DEFAULT_PRECIS,
          PROOF_QUALITY, 
          DEFAULT_PITCH or FF_DONTCARE,
          'Times New Roman'
        );
        
        oldFont := SelectObject(hdc, hFont);
        oldMode := SetBkMode(hdc, TRANSPARENT);
        
        if fileExists then
          SetTextColor(hdc, RGB(255, 255, 255)) // белый текст на изображении
        else
          SetTextColor(hdc, RGB(0, 0, 0)); // черный текст на градиенте

        // Определяем строки программы для отображения
        textLines[0] := 'program lab4;';
        textLines[1] := 'uses windows, messages;';
        textLines[2] := 'function WndProc(hWnd: THandle; Msg: integer;';
        textLines[3] := '  wParam: longint; lParam: longint): longint;';
        textLines[4] := '  stdcall; forward;';
        textLines[5] := 'procedure WinMain;';

        // Вычисляем высоту строки
        lineHeight := MulDiv(16, GetDeviceCaps(hdc, LOGPIXELSY), 72);

        // Выводим строки программы внутри рамки
        for i := 0 to 5 do
        begin
          TextOut(hdc, 
                  left + 10, 
                  top + 10 + i * lineHeight, 
                  PChar(textLines[i]), 
                  Length(textLines[i]));
        end;

        // восстанавливаем контекст
        SetBkMode(hdc, oldMode);
        SelectObject(hdc, oldFont);
        DeleteObject(hFont);
        DeleteObject(hPen);

        EndPaint(hwnd, ps);
      end;

    wm_destroy:
      begin
        PostQuitMessage(0);
      end;
      
    else
      result:=DefWindowProc(hwnd,msg,wparam,lparam);
  end;
end;

begin
  WinMain;
end.
