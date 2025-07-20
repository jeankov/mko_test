unit uTasksBaseThread;

interface

uses
  uDllParam;

type
  TTaskThread = class(TThread)
  protected
    FFormHandle: THandle;
    FResultDLLParams: TDLLParamArray;

    procedure Execute; override;
    procedure TaskExecute; virtual; abstract;
  public
    constructor Create(aDllHandle, aFormHandle: THandle); reintroduce; virtual;
    destructor Destroy; override;
  end;

implementation

uses
  Winapi.Windows, System.SysUtils, Messages;

{ TTaskThread }

constructor TTaskThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FFormHandle := aFormHandle;
  FResultDLLParams := nil;
  FResultDLLParams.AddDLLParam('dll_handle', aDllHandle);
  FResultDLLParams.AddDLLParam('thread_handle', Handle);
end;

destructor TTaskThread.Destroy;
begin
  inherited;
end;

procedure TTaskThread.Execute;
begin
  inherited;
  try
    try
      TaskExecute;
    except
      on E: Exception do
        FResultDLLParams.AddDLLParam('error_text', E.Message);
    end;
  finally
    SendMessage(FFormHandle, WM_TASK_RESULT, 0, LParam(Addr(FResultDLLParams)));
  end;
end;

end.
