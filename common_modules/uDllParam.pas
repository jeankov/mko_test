unit uDllParam;

interface

uses
  Windows, Variants, SysUtils;

type
  PDLLParam = ^TDLLParam;

  TDLLParam = record
  private
    FName: string;
    FCaption: string;
    FValue: Variant;
    FDefValue: Variant;
  public
    property Name: string read FName write FName;
    property Caption: string read FCaption write FCaption;
    property Value: Variant read FValue write FValue;
    property DefValue: Variant read FDefValue write FDefValue;
  end;

  PDLLParamArray = ^TDLLParamArray;
  TDLLParamArray = array of TDLLParam;

  TDLLParamArrayHelper = record helper for TDLLParamArray
  public
    function AddDLLParam(const aName: string; const aValue: Variant): integer; overload;
    function AddDLLParam(const aName, aCaption: string;
      const aValue, aDefValue: Variant): integer; overload;
    function IndexOf(const aName: string): Integer;
    procedure CopyTo(var aDest: TDLLParamArray);
  end;

implementation

{ TDLLParamArrayHelper }

function TDLLParamArrayHelper.AddDLLParam(const aName: string; const aValue: Variant): integer;
begin
  Result := Length(Self);
  SetLength(Self, Result + 1);
  Self[Result].FName := aName;
  Self[Result].FValue := aValue;
  Self[Result].FCaption := EmptyStr;
  Self[Result].FDefValue := null;
end;

function TDLLParamArrayHelper.AddDLLParam(const aName, aCaption: string;
  const aValue, aDefValue: Variant): integer;
begin
  Result := AddDLLParam(aName, aValue);
  Self[Result].FCaption := aCaption;
  Self[Result].FDefValue := aDefValue;
end;

procedure TDLLParamArrayHelper.CopyTo(var aDest: TDLLParamArray);
var
  i: Integer;
begin
  SetLength(aDest, Length(Self));
  for i := 0 to High(Self) do
  begin
    aDest[i].FName := Self[i].FName;
    aDest[i].FCaption := Self[i].FCaption;
    aDest[i].FValue := Self[i].FValue;
    aDest[i].DefValue := Self[i].FDefValue;
  end;
end;

function TDLLParamArrayHelper.IndexOf(const aName: string): Integer;
var
  vParamName: string;
  i: Integer;
begin
  Result := -1;
  vParamName := UpperCase(aName);
  for i := 0 to High(Self) do
    if UpperCase(Self[i].Name) = vParamName then
    begin
      Result := i;
      Break;
    end;
end;

end.
