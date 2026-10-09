program lab6;

uses windows, messages;

function AdminWndProc(hWnd: THandle; Msg: integer;   // обработка окна
                      wParam: longint; lParam: longint): longint;
                      stdcall; forward;

function DialogWndProc(hWnd: THandle; Msg: integer;
                       wParam: longint; lParam: longint): longint;
                       stdcall; forward;

var CreationCounter: integer = 0;
    hwndDialog: THandle; // хэндл окна диалога для доступа из администратора

procedure WinMain;
const
  szAdminClass = 'AdminWindow';
  szDialogClass = 'DialogWindow';
var
  wndClass: TWndClassEx;
  msg: TMsg;
  hwndAdmin: THandle;
begin
// регистрация класса окна администратора
  wndClass.cbSize := sizeof(wndClass);
  wndClass.style := 0;
  wndClass.lpfnWndProc := @AdminWndProc;   // указатель на процедуру обработки сообщений
  wndClass.cbClsExtra := 0;
  wndClass.cbWndExtra := dlgwindowextra;
  wndClass.hInstance := hInstance;
  wndClass.hIcon := loadIcon(0, idi_Application);
  wndClass.hCursor := loadCursor(0, idc_Arrow);
  wndClass.hbrBackground := GetStockObject(ltgray_Brush);
  wndClass.lpszMenuName := nil;
  wndClass.lpszClassName := szAdminClass;
  wndClass.hIconSm := loadIcon(0, idi_Application);
  RegisterClassEx(wndClass);

// регистрация класса окна диалога
  wndClass.lpfnWndProc := @DialogWndProc;
  wndClass.lpszClassName := szDialogClass;
  RegisterClassEx(wndClass);

// сохдание окна администратора
  hwndAdmin := CreateWindowEx(ws_ex_controlparent, // расширенный стиль окна, может содержать дочерние элементы управления
    szAdminClass, // имя класса
    'Администратор паролей', // заголовок окна
    ws_popupwindow or ws_sysmenu or ws_caption or ws_border or ws_visible,
    10, 10, 400, 350,
    0, 0, hInstance, nil);

  // создание окна диалога
  hwndDialog := CreateWindowEx(ws_ex_controlparent,
    szDialogClass,
    'Проверка пароля',
    ws_popupwindow or ws_sysmenu or ws_caption or ws_border or ws_visible,
    420, 10, 350, 200,
    0, 0, hInstance, nil);

  while GetMessage(msg, 0, 0, 0) do begin
    if not IsDialogMessage(GetActiveWindow, msg) then begin
      TranslateMessage(msg);
      DispatchMessage(msg);
    end;
  end;
end;

function AdminWndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
const
  editPassword = 101;    // ID дочерних элементов
  btnAdd = 102;
  btnDelete = 103;
  listPasswords = 104;
var
  rect: TRect;
  buffer: array[0..255] of char;
  selIndex: integer;
begin
  result := 0;
  case Msg of
    wm_create:  // инициализация окна
      begin
        inc(CreationCounter);
        GetClientRect(hwnd, rect);

        // Группа управления
        CreateWindow('button', 'Управление паролями:',
          ws_visible or ws_child or bs_groupbox,
          10, 10, rect.right - 20, 80,
          hwnd, 0, hInstance, nil);

        // Поле ввода пароля
        CreateWindow('edit', '',
          ws_visible or ws_child or ws_border or ws_tabstop,
          20, 30, 200, 25,
          hwnd, editPassword, hInstance, nil);

        // Кнопка добавления
        CreateWindow('button', 'Добавить',
          ws_visible or ws_child or bs_pushbutton or ws_tabstop,
          230, 30, 100, 25,
          hwnd, btnAdd, hInstance, nil);

        // Кнопка удаления
        CreateWindow('button', 'Удалить',
          ws_visible or ws_child or bs_pushbutton or ws_tabstop,
          230, 60, 100, 25,
          hwnd, btnDelete, hInstance, nil);

        // Список паролей
        CreateWindow('listbox', '',
          ws_visible or ws_child or ws_border or ws_tabstop or ws_vscroll or LBS_NOTIFY,
          10, 100, rect.right - 20, rect.bottom - 110,
          hwnd, listPasswords, hInstance, nil);
      end;

    wm_command:  // обработка действий пользователя
      case hiword(wParam) of
        BN_Clicked:
          begin
            // Добавление пароля
            if loword(wParam) = btnAdd then begin
              SendMessage(GetDlgItem(hwnd, editPassword), wm_gettext, sizeof(buffer), integer(@buffer));
              if buffer[0] <> #0 then begin
                SendMessage(GetDlgItem(hwnd, listPasswords), LB_ADDSTRING, 0, integer(@buffer));
                buffer[0] := #0;
                SendMessage(GetDlgItem(hwnd, editPassword), wm_settext, 0, integer(@buffer));
              end;
            end
            // Удаление пароля
            else if loword(wParam) = btnDelete then begin
              selIndex := SendMessage(GetDlgItem(hwnd, listPasswords), LB_GETCURSEL, 0, 0);
              if selIndex >= 0 then
                SendMessage(GetDlgItem(hwnd, listPasswords), LB_DELETESTRING, selIndex, 0);
            end;
          end;
      end;

    wm_close: DestroyWindow(hwnd);
    wm_destroy:
      begin
        dec(CreationCounter);
        if CreationCounter = 0 then PostQuitMessage(0);
      end;
    else
      result := DefDlgProc(hwnd, msg, wparam, lparam);
  end;
end;

// обаботка окна проверки пароля
function DialogWndProc(hWnd: THandle; Msg: integer; wParam: longint; lParam: longint): longint; stdcall;
const
  editInput = 105;
  btnCheck = 106;
  staticResult = 107;
var
   rect: TRect;                    // Хранение размеров клиентской области
  buffer: array[0..255] of char;  // Буфер для введенного пароля
  password: array[0..255] of char;// Буфер для пароля из списка
  i, count: integer;              // Счетчик, кол-во элементов
  found: boolean;                 // Флаг нахождения пароля
  hwndAdmin: THandle;             // Хэндл окна администратора
begin
  result := 0;
  case Msg of
    wm_create:
      begin
        inc(CreationCounter);
        GetClientRect(hwnd, rect);

        // Метка
        CreateWindow('static', 'Введите пароль:',
          ws_visible or ws_child,
          10, 20, 150, 20,
          hwnd, 0, hInstance, nil);

        // Поле ввода пароля в секретном режиме
        CreateWindow('edit', '',
          ws_visible or ws_child or ws_border or ws_tabstop or ES_PASSWORD,
          10, 45, rect.right - 20, 25,
          hwnd, editInput, hInstance, nil);

        // Кнопка проверки
        CreateWindow('button', 'Проверка',
          ws_visible or ws_child or bs_defpushbutton or ws_tabstop,
          10, 80, 100, 30,
          hwnd, btnCheck, hInstance, nil);

        // Поле результата
        CreateWindow('static', '',
          ws_visible or ws_child or SS_CENTER,
          10, 120, rect.right - 20, 30,
          hwnd, staticResult, hInstance, nil);
      end;

    wm_command:
      case hiword(wParam) of
        BN_Clicked:
          if loword(wParam) = btnCheck then begin
            // Получаем введенный пароль
            // Получаем хэндл поля ввода
            SendMessage(GetDlgItem(hwnd, editInput), wm_gettext, sizeof(buffer), integer(@buffer));
            
            // Поиск окна администратора
            hwndAdmin := FindWindow('AdminWindow', nil);
            if hwndAdmin <> 0 then begin
              found := false;
              count := SendMessage(GetDlgItem(hwndAdmin, 104), LB_GETCOUNT, 0, 0);
              
              // Проверка всех паролей в списке
              for i := 0 to count - 1 do begin
                SendMessage(GetDlgItem(hwndAdmin, 104), LB_GETTEXT, i, integer(@password));
                if lstrcmp(@buffer, @password) = 0 then begin // 0 если строки идентичны, <0 если первая строка меньше
                  found := true; // Пароль найден
                  break;
                end;
              end;
              
              // Вывод результата
              if found then
                SetWindowText(GetDlgItem(hwnd, staticResult), 'Доступ открыт!')
              else
                SetWindowText(GetDlgItem(hwnd, staticResult), 'Доступ запрещен!');
            end;
          end;
      end;

    wm_close: DestroyWindow(hwnd);
    wm_destroy:
      begin
        dec(CreationCounter);
        if CreationCounter = 0 then PostQuitMessage(0); //Помещаем сообщение WM_QUIT в очередб сообщений и приводим к завершению цикла сообщений
      end;
    else
      result := DefDlgProc(hwnd, msg, wparam, lparam);
  end;
end;

begin
  WinMain;
end.