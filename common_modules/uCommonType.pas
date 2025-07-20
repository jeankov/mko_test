unit uCommonType;

interface

uses
  uDllParam, Messages;

type
  PTaskResultProc = ^TTaskResultProc;
  TTaskResultProc = procedure(aDLLParamsPtr: PDLLParamArray) of object;

  PTaskType = ^TTaskType;
  TTaskType = record
  private
    FSysName: string;
    FCaption: string;
    FParams: TDLLParamArray;
  public
    property SysName: string read FSysName write FSysName;
    property Caption: string read FCaption write FCaption;
    property Params: TDLLParamArray read FParams write FParams;
  end;

  PTaskTypeArray = ^TTaskTypeArray;
  TTaskTypeArray = array of TTaskType;

const
  WM_TASK_RESULT = WM_USER + 1;
  WM_TASK_STOP = WM_USER + 2;

  C_PARAM_MACRO_PATH = '{app_path}';

implementation

end.
