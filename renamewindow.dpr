program renamewindow;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, WinAPI.Windows, unitWindowFinder, IniFiles, System.Classes;

var
  config: TIniFile;
  appPath: string;
  finder: TWindowFinder;
  sections: TStringList;
  loop: integer;
  exeToFind: string;
  titleToFind: string;
  titleToSet: string;
  classToFind: string;
  win: TWindowRec;
  command: string;
begin
  writeln('RenameWindow - Version 1.0 - Copyright (c) 2022 AthenaOfDelphi (athena.outer-reaches.com)');

  writeln('Finding windows...');
  appPath := extractFilePath(paramStr(0));
  finder := TWindowFinder.create;
  finder.loadWindowList;

  if (paramCount > 0) then
  begin
    command := uppercase(paramStr(1));

    if (command = '/LIST') then
    begin
      writeln('Window List (Entries => [EXE] - TITLE - {CLASS})');
      for loop := 0 to finder.count - 1 do
      begin
        writeln(format('[%s] - %s - {%s}', [
          finder.items[loop].exeName,
          finder.items[loop].windowTitle,
          finder.items[loop].windowClass
          ]));
      end;
    end
    else
    begin
      writeln('Unknown option - Use /list to get a list of windows');
    end;
  end
  else
  begin
    if (fileExists(includeTrailingPathDelimiter(appPath) + 'renamewindow.ini')) then
    begin
      config := TIniFile.create(includeTrailingPathDelimiter(appPath) + 'renamewindow.ini');
      sections := TStringList.create;

      config.ReadSections(sections);
      for loop := 0 to sections.count - 1 do
      begin
        if (uppercase(sections[loop]) <> '_DEFAULT') then
        begin
          writeln('Processing ' + sections[loop]);

          exeToFind := config.ReadString(sections[loop], 'exe', config.readString('_default', 'exe', ''));
          titleToFind := config.ReadString(sections[loop], 'title', config.readString('_default', 'title', ''));
          classToFind := config.ReadString(sections[loop], 'class', config.readString('_default', 'class', ''));
          titleToSet := config.ReadString(sections[loop], 'settitle', '');

          if (exeToFind <> '') or (titleToFind <> '') or (classToFind <> '') then
          begin
            if (titleToSet <> '') then
            begin
              win := finder.getWindow(exeToFind, titleToFind, classToFind);

              if (assigned(win)) then
              begin
                if setWindowText(win.currentHandle, titleToSet) then
                begin
                  writeln('-- Success');
                end
                else
                begin
                  writeln('** Failed to set title - Last Error 0x' + intToHex(GetLastError,8));
                end;
              end
              else
              begin
                writeln('** Could not find window for this section');
              end;
            end
            else
            begin
              writeln('** Not ''settitle'' for section');
            end;
          end
          else
          begin
            writeln('** No search criteria specified for section');
          end;
        end;
      end;
    end
    else
    begin
      writeln('** No configuration file (renamewindow.ini) found in application directory');
    end;
  end;
//  [_Default]
//  Class=Chrome_WidgetWin_1
//
//  [Discord]
//  Exe=discord.exe
//  SetTitle=Discord
//
//  [Notion]
//  Exe=notion.exe
//  SetTitle=Notion
end.
