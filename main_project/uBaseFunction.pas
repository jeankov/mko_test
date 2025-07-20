unit uBaseFunction;

interface

uses
  uDllParam, uCommonType;

  function LoadDll(aDllName: string): HModule;
  function GetTaskTypes(aDllHandle: HModule): TTaskTypeArray;
  function RunTask(aDllHandle: HModule; aDLLParamsPtr: PDLLParamArray): HModule;

implementation

uses
  System.SysUtils, Winapi.Windows, Vcl.Dialogs, Vcl.Forms;

function LoadDll(aDllName: string): HModule;
var
  vFileName: string;
begin
  aDllName := ChangeFileExt(aDllName, '.dll');
  vFileName := ExtractFileName(aDllName);

  Result := GetModuleHandle(PWideChar(vFileName));
  if Result = 0 then
    Result := LoadLibrary(PWideChar(aDllName));
end;

function GetTaskTypes(aDllHandle: HModule): TTaskTypeArray;
var
  vDLLParams: TDLLParamArray;
  vTaskArray: TTaskTypeArray;
  vGetTasks: function(aDLLParamsPtr: PDLLParamArray): boolean; cdecl;
begin
  Result := nil;
  if aDllHandle <> 0 then
  begin
    @vGetTasks := GetProcAddress(aDllHandle, PWideChar('GetTaskTypes'));
    if (@vGetTasks <> nil) then
    begin
      vDLLParams.AddDLLParam('task_type_array_ptr', NativeInt(Addr(vTaskArray)));
      if vGetTasks(@vDLLParams) then
        Result := vTaskArray;
    end;
  end;
end;

function RunTask(aDllHandle: HModule; aDLLParamsPtr: PDLLParamArray): HModule;
var
  vInd: integer;
  vErrorText: string;
  vRunTask: function (aDLLParamsPtr: PDLLParamArray): HModule; cdecl;
begin
  Result := 0;
  if aDllHandle <> 0 then
  begin
    @vRunTask := GetProcAddress(aDllHandle, PWideChar('RunTask'));
    if @vRunTask <> nil then
    begin
      Result := vRunTask(aDLLParamsPtr);
      if Result = 0 then
      begin
        vInd := aDLLParamsPtr^.IndexOf('error_text');
        if vInd = -1 then
          vErrorText := 'Неизвестная ошибка'
        else
          vErrorText := aDLLParamsPtr^[vInd].Value;

        Showmessage(Format('Задача не запущена. Текст ошибки: %s', [vErrorText]));
      end;
    end;
  end;
end;

end.
