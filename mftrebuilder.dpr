{
mftrebuilder - Rebuilds an corrupted MFT structure based on RAW files
By Lucas Alexandre
In 2016-01-20
}

program mftrebuilder;
{$APPTYPE console}
uses classes, filectrl, mftdirs, sysUtils, windows;
var
DriveStruct,rawlist: TStringList;
DestDrive: string;
i,j: integer;
log: text;
recvd: integer;
PromptReplace: boolean;
sr: TSearchRec;

procedure SetFileCreationTime(const FileName: string; const DateTime:
TDateTime);
const
  FILE_WRITE_ATTRIBUTES = $0100;
var
  Handle: THandle;
  SystemTime: TSystemTime;
  FileTime: TFileTime;
begin
  Handle := CreateFile(PChar(FileName), FILE_WRITE_ATTRIBUTES,
    FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL, 0);
  if Handle=INVALID_HANDLE_VALUE then
    RaiseLastOSError;
  try
    DateTimeToSystemTime(DateTime, SystemTime);
    if not SystemTimeToFileTime(SystemTime, FileTime) then
      RaiseLastOSError;
    if not SetFileTime(Handle, @FileTime,@fileTime,@FileTime) then
      RaiseLastOSError;
  finally
    CloseHandle(Handle);
  end;
end;

procedure ReplaceDamagedFile(file1: string; file2: string);
var
FILEDT: integer;
c: string;
DirPath: string;
begin
if PromptReplace then
begin
writeln('Replace the file (Y/N)?');
readln(c);
case upcase(c[1]) of
'N': exit;
end;
end;
FileDT:=FileAge(file1);
DirPath:=ExtractFilePath(file1);
DirPath[1]:=DestDrive[1];
dirPath[length(DirPath)]:=#0;
if not DirectoryExists(DirPath) then ForceDirectories(DirPath);
file1[1]:=DestDrive[1];
if copyfile(pchar(file2),pchar(file1),false) then
begin
write('Ok!');
findfirst('*.*',faAnyFile,SR2);
inc(recvd);
end
else
writeln('Failled');
writeln;
SetFileCreationTime(file1,FileDateToDateTime(FileDT));
end;

procedure CompareFileSize(file1: string; file2: string);
var ext1,ext2: string;
SR,SR2: TSearchRec;
begin
writeln(log,file2);
ext1:=copy(file1,length(file1)-2,length(file1));
ext2:=copy(file2,length(file2)-2,length(file2));
ext1:=AnsiUpperCase(ext1);
ext2:=AnsiUpperCase(ext2);
findfirst(file1,faAnyFile,SR);
findfirst(file2,faAnyFile,SR2);
if (SR.size=SR2.size) or (SR.size=SR2.size-1) then
{-1-byte supplementary}
begin
writeln('The file '+drivestruct[i]+' is equal a the file '+file2);
writeln('Replacing damaged file... ');
ReplaceDamagedFile(file1,file2);
end;
SysUtils.FindClose(SR); SysUtils.FindClose(SR2);
end;

begin
assign(log,'log.txt');
rewrite(log);
writeln('MFTRebuilder v0.1');
writeln('Copyright (c) 2015 Lucas Alexandre');
writeln;
if paramCount=0 then
begin
writeln('Usage: mftrebuilder [MFT__ORIGIN] [RAW_FILES_ORIGIN] [OUTPUT_PATH]');
writeln;
writeln('MFTRebuilder allows to rebuild an corrupted MFT based on the attributes and signatures of RAW files.');
writeln;
writeln('Arguments:'); writeln;
writeln('MFT_ORIGIN    Defines the path of the corrupted MFT (like a mount point or a letter of a drive).');
writeln('RAW_FILES_ORIGIN    Defines the local  containing the RAW data to compare.');
writeln('OUTPUT_PATH   Defines the output path to save recovered data (like a folder, mount point or drive letter).');
writeln('/S  Silent Mode (does not ask when replace a file)');
writeln;
writeln('Examples');
writeln;
writeln('MFTRebuilder F: D:\RAWData G:');
writeln;
writeln('F: Is the drive containing damaged MFT structure (like an Flash drive or a external Hard Disk).');
writeln('D:\RAWData - Is the local containing RAW files to compare with the corrupted MFT.');
writeln('G: Is a drive to save recovered files.');
writeln;
writeln('This is a forensic tool, developped by Lucas Alexandre (http://www.lucaspcs.com.br)');
end;
if ParamCount>0 then
begin
if AnsiUpperCase(ParamStr(4))='/S' then
PromptReplace:=false
else
PromptReplace:=true;
DriveStruct:=TStringList.Create;
    GetDriveStructure(paramStr(1),DriveStruct);
DestDrive:=copy(ParamStr(3),1,3);
writeln('Loading list of RAW files... please wait');
rawlist:=TStringList.Create;
    GetDriveStructure(paramStr(2),RAWList);
writeln(RAWList.count,' RAW files loaded succesfully');
writeln(DriveStruct.count,' files to process');
for i:=0 to DriveStruct.count-1 do
begin
writeln('Comparing file '+drivestruct[i]);
for j:=0 to RAWList.count-1 do
CompareFileSize(DriveStruct[i],RAWList[j]);
end;
end;
writeln(DriveStruct.Count,' files processed, ',recvd,' files recovered');
close(log);
end.
