program mko_test;

uses
  //FastMM4,
  //uExceptionsLog,
  Vcl.Forms,
  uDllParam in '..\common_modules\uDllParam.pas',
  uMainForm in 'uMainForm.pas' {frmMainForm},
  uCommonType in '..\common_modules\uCommonType.pas',
  uBaseFunction in 'uBaseFunction.pas',
  uParamsForm in 'uParamsForm.pas' {formParams};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.Run;
end.
