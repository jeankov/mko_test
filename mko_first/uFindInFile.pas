unit uFindInFile;

interface

uses
  System.Classes, System.SyncObjs, Types, System.IOUtils, System.SysUtils,
  uTaskBaseThread, uCommonType, uDllParam;

type
  TFindInFileThread = class(TTaskThread)
  protected
    procedure TaskExecute; override;
  private
    FFilePath: String;
    FSearchStr: AnsiString;
    FFoundPositions: TStringDynArray;
    procedure FindInFile;
  end;

  function FindInFile(const aFilePath: String; const aSearchStr: string;
    aDllHandle, aFormHandle: THandle): NativeUInt;

implementation

uses
  RegularExpressions;

function FindInFile(const aFilePath: String; const aSearchStr: string;
  aDllHandle, aFormHandle: THandle): NativeUInt;
var
  vThread: TFindInFileThread;
begin
  vThread := TFindInFileThread.Create(aDllHandle, aFormHandle);
  vThread.FFilePath := aFilePath;
  vThread.FSearchStr := AnsiString(aSearchStr);
  vThread.FFoundPositions := nil;
  Result := vThread.Handle;
  vThread.Start;
end;

{ TFindInFileThread }

procedure TFindInFileThread.TaskExecute;
begin
  inherited;
  FindInFile;
  FResultDLLParams.AddDLLParam('found_positions', FFoundPositions);
  FResultDLLParams.AddDLLParam('task_type', 'show_found_positions');
end;

procedure TFindInFileThread.FindInFile;
const
  BufferSize = 4096;
var
  vFileStream: TFileStream;
  vBuffer: TBytes;
  i, vBytesRead, vStartIndex, vSearchStrLength: UInt64;
  vSearchStr: AnsiString;
begin
  vFileStream := TFileStream.Create(FFilePath, fmOpenRead);
  try
    vSearchStr := AnsiString(FSearchStr);
    vSearchStrLength := Length(vSearchStr);
    SetLength(vBuffer, BufferSize);
    vStartIndex := 0;
    while not Terminated do
    begin
      vBytesRead := vFileStream.Read(vBuffer[0], BufferSize);
      if vBytesRead = 0 then
        Break;

      for i := 0 to vBytesRead - vSearchStrLength do
      begin
        if CompareMem(@vBuffer[i], PAnsiChar(vSearchStr), vSearchStrLength) then
          FFoundPositions := FFoundPositions + [(vStartIndex + i).ToString];
      end;
      vStartIndex := vStartIndex + vBytesRead;
    end;
  finally
    vFileStream.Free;
  end;
end;

end.
