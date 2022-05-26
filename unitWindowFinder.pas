unit unitWindowFinder;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, VCL.StdCtrls,
  WinAPI.Windows;

type
  TWindowRec = class(TObject)
  protected
    fExeName: string;
    fWindowTitle: string;
    fWindowClass: string;
    fCurrentHandle: THandle;
  public
    constructor create(anExeName: string; aWinTitle: string; aWinClass: string; aHandle: THandle);

    property exeName: string read fExeName;
    property windowTitle: string read fWindowTitle;
    property windowClass: string read fWindowClass;
    property currentHandle: THandle read FcurrentHandle;
  end;

  TWindowFinder = class(TObject)
  protected
    fSubscribers: TList<TNotifyEvent>;
    fWindows: TList<TWindowRec>;

    function getCount: integer;
    function getItem(index: integer): TWindowRec;
  public
    constructor create;
    destructor Destroy; override;

    procedure clear;
    procedure loadWindowList;

    procedure loadComboWithList(aComboBox: TCOmboBox);

    procedure subscribe(aNotifyEvent: TNotifyEvent);
    procedure unsubscribe(aNotifyEvent: TNotifyEvent);

    function getWindow(anExeName: string; aWindowTitle: string; aWindowClass: string): TWindowRec;

    function getWindowIndex(anExeName: string; aWindowTitle: string; aWindowClass: string): integer; overload;
    function getWindowIndex(partialWindowTitle: string): integer; overload;

    property count: integer read getCount;
    property items[index: integer]: TWindowRec read getItem;
  end;

var
  windowFinder: TWindowFinder;

implementation

uses
  TlHelp32;

{ TWindowFinder }

constructor TWindowFinder.create;
begin
  inherited create;

  fSubscribers := TList<TNotifyEvent>.create;
  fWindows := TList<TWindowRec>.create;
end;

destructor TwindowFinder.destroy;
begin
  clear;
  fWindows.free;
  fSubscribers.free;

  inherited;
end;

function TWindowFinder.getCount: integer;
begin
  result := fWindows.count;
end;

function TWindowFinder.getItem(index: integer): TWindowRec;
begin
  result := fWindows[index];
end;

function TWindowFinder.getWindowIndex(partialWindowTitle: string): integer;
var
  loop: integer;
  temp: string;
begin
  result := -1;

  partialWindowTitle := upperCase(partialWindowTitle);

  for loop := 0 to fWindows.count - 1 do
  begin
    temp := upperCase(fWindows[loop].windowTitle);

    if (pos(partialWindowTitle, temp) > 0) then
    begin
      result := loop;
      break;
    end;
  end;
end;

function TWindowFinder.getWindowIndex(anExeName, aWindowTitle,
  aWindowClass: string): integer;
var
  loop: integer;
begin
  result := -1;

  for loop := 0 to fWIndows.count - 1 do
  begin
    if (
      ( ((anExeName <> '') and (compareText(fWindows[loop].exeName, anExeName) = 0)) or (anExeName = '') ) and
      ( ((aWindowTitle <> '') and (compareText(fWindows[loop].windowTitle, aWindowTitle) = 0)) or (aWindowTitle = '') ) and
      ( ((aWindowClass <> '') and (compareText(fWindows[loop].windowClass, aWindowClass) = 0)) or (aWindowClass = '') )
      ) then
    begin
      result := loop; // fWindows[loop];
      break;
    end;
  end;
end;

function TWindowFinder.getWindow(anExeName, aWindowTitle, aWindowClass: string): TWindowRec;
var
  idx: integer;
begin
  idx := getWindowIndex(anExeName, aWindowTitle, aWindowClass);

  if (idx >= 0) then
  begin
    result := fWindows[idx];
  end
  else
  begin
    result := nil;
  end;
end;

procedure TWindowFinder.loadComboWithList(aComboBox: TCOmboBox);
var
  loop: integer;
begin
  aComboBox.items.clear;
  for loop := 0 to fWindows.count - 1 do
  begin
    aComboBox.items.addObject(format('[%s] - %s (Class %s)',
      [fWindows[loop].exeName, fWindows[loop].windowTitle, fWindows[loop].windowClass]),
      pointer(fWindows[loop].currentHandle));
  end;
end;

procedure TWindowFinder.subscribe(aNotifyEvent: TNotifyEvent);
begin
  if (fSubscribers.IndexOf(aNotifyEvent) < 0) then
  begin
    fSubscribers.add(aNotifyEvent);
  end;
end;

procedure TWindowFinder.unsubscribe(aNotifyEvent: TNotifyEvent);
var
  idxPos: integer;
begin
  idxPos := fSubscribers.indexOf(aNotifyEvent);

  if (idxPos >= 0) then
  begin
    fSubscribers.delete(idxPos);
  end;
end;

function getWindowExeName(Handle: THandle): String;
var
 PE: TProcessEntry32;
 Snap: THandle;
 ProcessId: cardinal;
begin
  result := '';

  pe.dwsize:=sizeof(PE);
  GetWindowThreadProcessId(Handle,@ProcessId);
  Snap := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snap <> 0 then
  begin
    if Process32First(Snap, PE) then
    begin
      if PE.th32ProcessID = ProcessId then
      begin
        Result:= String(PE.szExeFile)
      end
      else
      begin
        while Process32Next(Snap, PE) do
        begin
          if PE.th32ProcessID = ProcessId then
          begin
            Result:= String(PE.szExeFile);
            break;
          end;
        end;
      end;
    end;

    closeHandle(Snap);
  end;
end;

function processWindow(wnd: Thandle; list: TStringList):boolean;  stdcall;
var
  temp:array[0..255] of char;
  exeName: string;
  winTitle: string;
  winClass: string;
  info:tagWINDOWINFO;
  itemText: string;
  idx: integer;
begin
  getWindowInfo(wnd, info);
  if ((info.dwStyle and WS_CHILD) = 0) and ((info.dwExStyle and WS_EX_TOOLWINDOW) = 0) then // and (isWindowVisible(wnd)) then
  begin
    getWindowText(wnd, temp, 256);
    winTitle := PChar(@temp);
    getClassNameW(wnd, temp, 256);
    winClass := PChar(@temp);

    exeName := getWindowExeName(wnd);

    if (winTitle = '') then
    begin
      winTitle := '(untitled)';
    end;

    itemText := exename + '|' + winTitle + '|' +winClass;
    idx := list.indexOf(itemText);
    if (idx >= 0) then
    begin
      if (assigned(list.objects[idx])) then
      begin
        TWindowRec(list.objects[idx]).free;
        list.objects[idx] := nil;
      end;
    end
    else
    begin
      list.addObject(itemText, TWindowRec.create(exeName, winTitle, winClass, wnd));
    end;
  end;

  result:=true;
end;

procedure TWindowFinder.clear;
var
  loop: integer;
begin
  for loop := 0 to fWIndows.count - 1 do
  begin
    fWindows[loop].free;
  end;

  fWindows.clear;
end;

procedure TWindowFinder.loadWindowList;
var
  loop: integer;
  temp: TStringList;
begin
  temp := TStringList.create;
  temp.caseSensitive := false;

  clear;

  enumDesktopwindows(getThreadDesktop(getCurrentThreadId), @processWindow, lparam(temp));

  temp.sorted := true;

  for loop := 0 to temp.count - 1 do
  begin
    if (assigned(temp.objects[loop])) then
    begin
      fWindows.add(TWindowRec(temp.objects[loop]));
    end;
  end;

  temp.free;

  for loop := 0 to fSubscribers.count - 1 do
  begin
    fSubscribers[loop](self);
  end;
end;


{ TWindowRec }

constructor TWindowRec.create(anExeName, aWinTitle, aWinClass: string;
  aHandle: THandle);
begin
  inherited create;

  fExeName := anExeName;
  fWindowTitle := aWinTitle;
  fWindowClass := aWinClass;
  fCurrentHandle := aHandle;
end;

end.
