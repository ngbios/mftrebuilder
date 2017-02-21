{
MFTRebuilder - Directory routines
By Lucas Alexandre
In 2016-01-20
}

unit mftdirs;
interface
uses classes, sysUtils, windows;
procedure GetDriveStructure(const drive: string; var list: TStringList);
implementation
procedure GetDriveStructure(const drive: string; var list: TStringList);
var
  SR: TSearchRec;
begin
if FindFirst(IncludeTrailingBackslash(Drive) + '*.*', faAnyFile or
faDirectory, SR) = 0 then
    try
      repeat
        if (SR.Attr and faDirectory) = 0 then
    list.Add(IncludeTrailingBackslash(drive) + SR.Name)
        else if (SR.Name <> '.') and (SR.Name <> '..') then
    GetDriveStructure(IncludeTrailingBackslash(drive) + SR.Name,list);  // recursive call!
      until FindNext(Sr) <> 0;
    finally
      sysUtils.FindClose(SR);
    end;
end;
end.
