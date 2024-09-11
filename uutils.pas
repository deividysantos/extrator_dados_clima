unit uUtils;

{$mode Delphi}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Zipper, Process;

procedure DeleteDirectory(const Dir: string);
procedure UnZip(FileName, OutputPath: String);
procedure Download(pOwner: TComponent; pLink, pCaminhoDestino, pApplicationPath: String);

implementation

procedure DeleteDirectory(const Dir: string);
var
  SearchRec: TSearchRec;
  FilePath: string;
begin
  // Ajusta o caminho para garantir que a barra invertida está presente
  FilePath := IncludeTrailingPathDelimiter(Dir);

  // Encontra o primeiro arquivo ou subdiretório
  if FindFirst(FilePath + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        // Ignora diretórios especiais '.' e '..'
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          // Verifica se é um diretório
          if (SearchRec.Attr and faDirectory) = faDirectory then
          begin
            // Recursivamente apaga o subdiretório
            DeleteDirectory(FilePath + SearchRec.Name);
          end
          else
          begin
            // Apaga o arquivo
            DeleteFile(FilePath + SearchRec.Name);
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;

  // Remove o diretório
  RemoveDir(Dir);
end;

procedure UnZip(FileName, OutputPath: String);
var
  UnZipper : TUnZipper;
begin
  UnZipper := TUnZipper.Create;
  try
    UnZipper.FileName := FileName;
    UnZipper.OutputPath := OutputPath;
    UnZipper.Examine;
    UnZipper.UnZipAllFiles;
  finally
    UnZipper.Free;
  end;
end;

procedure Download(pOwner: TComponent; pLink, pCaminhoDestino, pApplicationPath: String);
var
  mArquivo: String;
  mProcess: TProcess;
  BatchFile: TStringList;
begin
  mProcess := TProcess.Create(pOwner);
  BatchFile := TStringList.Create;
  try
    // Create the batch script for the download process
    BatchFile.Add('bitsadmin /transfer myDownloadJob /download /priority normal "' + pLink + '" "%cd%\' + pCaminhoDestino + '"');
    mArquivo := pApplicationPath + 'download.bat';
    BatchFile.SaveToFile(mArquivo);

    // Set up the process to execute the batch file
    mProcess.ShowWindow := swoHIDE;
    mProcess.Executable := mArquivo;

    // Start the process
    mProcess.Execute;

    // Wait for a few seconds (optional)
    Sleep(3000);

    while not FileExists(pCaminhoDestino) do
    begin


    end;

    // Clean up: Delete the batch file after execution
    if FileExists(mArquivo) then
      DeleteFile(mArquivo);
  finally
    BatchFile.Free;
    mProcess.Free;
  end;
end;


end.
