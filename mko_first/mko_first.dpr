library mko_first;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.

  Important note about VCL usage: when this DLL will be implicitly
  loaded and this DLL uses TWicImage / TImageCollection created in
  any unit initialization section, then Vcl.WicImageInit must be
  included into your library's USES clause. }

uses
  //FastMM4,
  System.SysUtils,
  System.Classes,
  Windows,
  uDllParam in '..\common_modules\uDllParam.pas',
  uTaskBaseThread in '..\common_modules\uTaskBaseThread.pas',
  uMain in 'uMain.pas',
  uFindFiles in 'uFindFiles.pas',
  uCommonType in '..\common_modules\uCommonType.pas' {,uFoundFilesForm in 'uFoundFilesForm.pas' {formFoundFiles},
  uListForm in 'uListForm.pas' {formList},
  uFindInFile in 'uFindInFile.pas';

{$R *.res}

exports
  GetTaskTypes,
  RunTask;

begin

end.
