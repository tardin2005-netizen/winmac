Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
shell.Run "powershell -WindowStyle Hidden -Command ""Start-Process cmd -ArgumentList '/c cd /d """ & dir & """ && INICIAR.bat' -Verb RunAs -WindowStyle Hidden""", 0, False
