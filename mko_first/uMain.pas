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
    vTaskTypeArrayPtr^[0].Caption := '����� ������ �� �����';
    vTaskTypeArrayPtr^[0].Params.AddDLLParam('path', '�����', '', C_PARAM_MACRO_PATH);
    vTaskTypeArrayPtr^[0].Params.AddDLLParam('mask', '�����', '', '*.txt;*.dll');

    vTaskTypeArrayPtr^[1].SysName := 'find_in_file';
    vTaskTypeArrayPtr^[1].Caption := '����� � �����';
    vTaskTypeArrayPtr^[1].Params.AddDLLParam('file', '����', '', C_PARAM_MACRO_PATH + 'mko_first.dll');
    vTaskTypeArrayPtr^[1].Params.AddDLLParam('chars', '������� �������', '', 'TWaiterFlag');
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
        aDLLParamsPtr^.AddDLLParam('error_text', '������������ ���������');
        Exit;
      end
      else
        vFormHandle := THandle(aDLLParamsPtr^[vInd].Value);

      vInd := aDLLParamsPtr^.IndexOf('dll_handle');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', '������������ ���������');
        Exit;
      end
      else
        vDllHandle := THandle(aDLLParamsPtr^[vInd].Value);

      vInd := aDLLParamsPtr^.IndexOf('path');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', '�� ����� ����');
        Exit;
      end
      else
        vParamPatch := aDLLParamsPtr^[vInd].Value;

      vInd := aDLLParamsPtr^.IndexOf('mask');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', '�� ������ �����');
        Exit;
      end
      else
        vParamMask := aDLLParamsPtr^[vInd].Value;

      Result := FindFiles(vParamPatch, vParamMask, vDllHandle, vFormHandle);
    end
    else
    if vTaskName = 'show_found_files' then
    begin
      ShowListForm('������� ������: {cnt}', 'found_files', aDLLParamsPtr);
      Result := 1;
    end
    else
    if vTaskName = 'find_in_file' then
    begin
      vInd := aDLLParamsPtr^.IndexOf('form_handle');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', '������������ ���������');
        Exit;
      end
      else
        vFormHandle := THandle(aDLLParamsPtr^[vInd].Value);

      vInd := aDLLParamsPtr^.IndexOf('dll_handle');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', '������������ ���������');
        Exit;
      end
      else
        vDllHandle := THandle(aDLLParamsPtr^[vInd].Value);

      vInd := aDLLParamsPtr^.IndexOf('file');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', '�� ����� ����');
        Exit;
      end
      else
        vParamPatch := aDLLParamsPtr^[vInd].Value;

      vInd := aDLLParamsPtr^.IndexOf('chars');
      if vInd = -1 then
      begin
        aDLLParamsPtr^.AddDLLParam('error_text', '�� ������ �����');
        Exit;
      end
      else
        vSearchCharactersStr := aDLLParamsPtr^[vInd].Value;

      Result := FindInFile(vParamPatch, vSearchCharactersStr, vDllHandle, vFormHandle);
    end
    else
    if vTaskName = 'show_found_positions' then
    begin
      ShowListForm('������� ���������: {cnt}', 'found_positions', aDLLParamsPtr);
      Result := 1;
    end
    else
      aDLLParamsPtr^.AddDLLParam('error_text', '������������ ���������')
  end;
end;

end.
