program lab5;

uses
  windows,
  messages,
  sysUtils;

var
  RedValue: byte = 128;     //глобальные переменные
  GreenValue: byte = 128;
  BlueValue: byte = 128;

function WndProc(hWnd: THandle; Msg: integer;
                 wParam: longint; lParam: longint): longint;
                 stdcall; forward;

procedure WinMain;
  const szClassName='RGBColorWindow';
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
  wndClass.hbrBackground:=0;
  wndClass.lpszMenuName:=nil;
  wndClass.lpszClassName:=szClassName;
  wndClass.hIconSm:=loadIcon(0, idi_Application);

  RegisterClassEx(wndClass);

  hwnd:=CreateWindowEx(
         0,
         szClassName,
         'ЛАБ 5',
         ws_overlappedWindow,
         cw_useDefault,
         cw_useDefault,
         500,
         300,
         0,
         0,
         hInstance,
         nil);

  ShowWindow(hwnd,sw_Show);
  updateWindow(hwnd);

  while GetMessage(msg,0,0,0) do begin
    TranslateMessage(msg);
    DispatchMessage(msg);
  end;
end;

function WndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
  var ps:TPaintStruct;       // Структура для BeginPaint/EndPaint
      hdc:THandle;           // Дескриптор контекста устройства
      rect:TRect;            // Прямоугольник клиентской области
      s:shortstring;         // Строка для вывода текста
      hBrush:THandle;        // Дескриптор кисти для заливки фона
      colorRef:DWORD;        // Значение цвета в формате RGB
      needUpdate:boolean;    // Флаг необходимости перерисовки окна
      shiftPressed:boolean;  // Флаг нажатия клавиши Shift
      keyState:TKeyboardState;  // Массив состояний всех клавиш
begin
  result:=0;

  // Обрабатываем сообщения в зависимости от их типа
  case Msg of

    // Сообщение WM_PAINT - требуется перерисовать окно
    wm_paint:
      begin
        // Начинаем рисование, получаем контекст устройства
        hdc:=BeginPaint(hwnd,ps);
        // Получаем размеры клиентской области окна
        GetClientRect(hwnd,rect);

        // Создаем цвет из трех составляющих RGB
        colorRef:=RGB(RedValue, GreenValue, BlueValue);
        hBrush:=CreateSolidBrush(colorRef);
        FillRect(hdc, rect, hBrush);
        DeleteObject(hBrush);

        // Настраиваем параметры вывода текста
        SetBkMode(hdc, TRANSPARENT);

        // Если фон светлый (сумма RGB > 384), используем черный текст
        // Иначе используем белый текст для читаемости
        if (RedValue + GreenValue + BlueValue) > 384 then
          SetTextColor(hdc, RGB(0,0,0))
        else
          SetTextColor(hdc, RGB(255,255,255));

        // Выводим инструкцию по использованию
        s:='Управление: R/G/B + Shift (увеличить) или без Shift (уменьшить)';
        TextOut(hdc, 10, 10, @s[1], length(s));

        // Дополнительная подсказка
        s:='Можно удерживать несколько клавиш одновременно';
        TextOut(hdc, 10, 30, @s[1], length(s));

        // Выводим текущее значение красной составляющей
        s:='R (красный):   ' + intToStr(RedValue);
        TextOut(hdc, 10, 70, @s[1], length(s));

        // Выводим текущее значение зеленой составляющей
        s:='G (зеленый):   ' + intToStr(GreenValue);
        TextOut(hdc, 10, 90, @s[1], length(s));

        // Выводим текущее значение синей составляющей
        s:='B (синий):     ' + intToStr(BlueValue);
        TextOut(hdc, 10, 110, @s[1], length(s));

        endPaint(hwnd,ps);
      end;

    // Сообщение WM_KEYDOWN - клавиша нажата
    WM_KEYDOWN:
      begin
        needUpdate:=false;  // Изначально не требуется обновление

        // Получаем состояние ВСЕХ клавиш клавиатуры
        // Старший бит (0x80) = 1, если клавиша нажата
        GetKeyboardState(keyState);
        
        // Проверяем, нажата ли клавиша Shift
        // $80 = 10000000 в двоичной системе (маска старшего бита)
        shiftPressed:=(keyState[VK_SHIFT] and $80)<>0;

        // Обрабатываем клавишу R (красный)
        // ord('R') - получаем ASCII-код символа 'R'
        if (keyState[ord('R')] and $80)<>0 then begin  // Если R нажата
          if shiftPressed then begin      // Если Shift нажат
            if RedValue < 255 then        // Проверяем верхнюю границу
              inc(RedValue);              // Увеличиваем на 1
          end else begin                  // Если Shift не нажат
            if RedValue > 0 then
              dec(RedValue);
          end;
          needUpdate:=true;  // Помечаем, что нужно обновить окно
        end;

        // Обрабатываем клавишу G (зеленый)
        if (keyState[ord('G')] and $80)<>0 then begin
          if shiftPressed then begin
            if GreenValue < 255 then
              inc(GreenValue);
          end else begin
            if GreenValue > 0 then
              dec(GreenValue);
          end;
          needUpdate:=true;
        end;

        // Обрабатываем клавишу B (синий)
        if (keyState[ord('B')] and $80)<>0 then begin
          if shiftPressed then begin
            if BlueValue < 255 then
              inc(BlueValue);
          end else begin
            if BlueValue > 0 then
              dec(BlueValue);
          end;
          needUpdate:=true;
        end;
        
        // Если хотя бы одна составляющая изменилась
        if needUpdate then begin
          // Помечаем всю клиентскую область как недействительную
          // nil - вся область, true - стирать фон перед перерисовкой
          invalidaterect(hwnd,nil,true);
          // Немедленно перерисовываем окно, не дожидаясь опустошения очереди
          updateWindow(hwnd);
        end;
      end;

    wm_destroy:
      begin
        PostQuitMessage(0);
      end;

    // Все остальные сообщения обрабатываются стандартным образом
    else
      result:=DefWindowProc(hwnd,msg,wparam,lparam);
  end;
end;

begin
  WinMain;
end.
