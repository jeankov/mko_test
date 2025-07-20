unit uMain;

interface

uses
  Vcl.Forms, uDllParam;

  function GetTaskTypes(aDLLParamsPtr: PDLLParamArray): boolean; cdecl;
  function RunTask(aDLLParamsPtr: PDLLParamArray): THandle; cdecl;

implementation

uses
  uFindFiles, uCommonType,  uListForm, uFindInFile, Winapi.Windows;

function GetTaskTypes(aDLLParamsPtr: PDLLParamArray): boolean; cdecl;
var
  vInd: integer;
  vTaskTypeArrayPtr: PTaskTypeArray;
begin
  Result := False;
  vInd := aDLLParamsPtr^.IndexOf('task_type_array_ptr');
  if vInd > -1 then
  begin
    vTaskTypeArrayPtr := PTaskTypeArray(NativeInt(aDLLParamsPtr^[vInd].Value));
    SetLength(vTaskTypeArrayPtr^, 2);

    vTaskTypeArrayPtr^[0].SysName := 'find_files';
    vTaskTypeArrayPtr^[0].Caption := 'Поиск файлов по маске';
    vTaskTypeArrayPtr^[0].Params.AddDLLParam('path', 'Папка', '', C_PARAM_MACRO_PATH);
    vTaskTypeArrayPtr^[0].Params.AddDLLParam('mask', 'Маска', '', '*.txt;*.dll');

    vTaskTypeArrayPtr^[1].SysName := 'find_in_file';
    vTaskTypeArrayPtr^[1].Caption := 'Поиск в файле';
    vTaskTypeArrayPtr^[1].Params.AddDLLParam('file', 'Файл', '', C_PARAM_MACRO_PATH + 'mko_first.dll');
    vTaskTypeArrayPtr^[1].Params.AddDLLParam('chars', 'Искомые символы', '', 'TWaiterFlag');
    Result := True;
  end;
end;

function RunTask(aDLLParamsPtr: PDLLParamArray): THandle; cdecl;
var
  vInd: integer;
  vTaskName: String;
  vParamPatch: String;
  vParamMask: String;
  vSearchCharactersStr: String;
  vDllHandle, vFormHandle: THandle;
begin
  Result := 0;

  vInd := aDLLParamsPtr^.IndexOf('task_type');
  if vInd > -1 then
  begin
    vTaskName := aDLLParamsPtr^[vInd].Value;
    if vTaskName = 'find_files' then
    begin
      vInd := aDLLParamsPtr^.IndexOf('form_handle');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', 'Некорректные параметры');
        Exit;
      end
      else
        vFormHandle := THandle(aDLLParamsPtr^[vInd].Value);

      vInd := aDLLParamsPtr^.IndexOf('dll_handle');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', 'Некорректные параметры');
        Exit;
      end
      else
        vDllHandle := THandle(aDLLParamsPtr^[vInd].Value);

      vInd := aDLLParamsPtr^.IndexOf('path');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', 'Не задан путь');
        Exit;
      end
      else
        vParamPatch := aDLLParamsPtr^[vInd].Value;

      vInd := aDLLParamsPtr^.IndexOf('mask');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', 'Не задана маска');
        Exit;
      end
      else
        vParamMask := aDLLParamsPtr^[vInd].Value;

      Result := FindFiles(vParamPatch, vParamMask, vDllHandle, vFormHandle);
    end
    else
    if vTaskName = 'show_found_files' then
    begin
      ShowListForm('Найдено файлов: {cnt}', 'found_files', aDLLParamsPtr);
      Result := 1;
    end
    else
    if vTaskName = 'find_in_file' then
    begin
      vInd := aDLLParamsPtr^.IndexOf('form_handle');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', 'Некорректные параметры');
        Exit;
      end
      else
        vFormHandle := THandle(aDLLParamsPtr^[vInd].Value);

      vInd := aDLLParamsPtr^.IndexOf('dll_handle');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', 'Некорректные параметры');
        Exit;
      end
      else
        vDllHandle := THandle(aDLLParamsPtr^[vInd].Value);

      vInd := aDLLParamsPtr^.IndexOf('file');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', 'Не задан путь');
        Exit;
      end
      else
        vParamPatch := aDLLParamsPtr^[vInd].Value;

      vInd := aDLLParamsPtr^.IndexOf('chars');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', 'Не задана маска');
        Exit;
      end
      else
        vSearchCharactersStr := aDLLParamsPtr^[vInd].Value;

      Result := FindInFile(vParamPatch, vSearchCharactersStr, vDllHandle, vFormHandle);
    end
    else
    if vTaskName = 'show_found_positions' then
    begin
      ShowListForm('Найдено вхождений: {cnt}', 'found_positions', aDLLParamsPtr);
      Result := 1;
    end
    else
      aDLLParamsPtr^.AddDLLParam('error_text', 'Некорректные параметры')
  end;
end;

end.
