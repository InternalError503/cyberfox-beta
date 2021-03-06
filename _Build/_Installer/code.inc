[Code]
var
	UpdateNoStart: String;
	
// Setup exit code for check for running function.
procedure ExitProcess(exitCode:integer);
  external 'ExitProcess@kernel32.dll stdcall';
 
// Setup check cpu support function 
function IsProcessorFeaturePresent(Feature: Integer): Boolean;
external 'IsProcessorFeaturePresent@kernel32.dll stdcall';

// Check for running process before initializing the installer (Boolean)
function IsAppRunning(const FileName : string): Boolean;
	var
		FSWbemLocator: Variant;
			FWMIService   : Variant;
		FWbemObjectSet: Variant;
	begin
		Result := false;
		log('Checking for ' + FileName + ' process!');
	try
		FSWbemLocator := CreateOleObject('WBEMScripting.SWBEMLocator');
		FWMIService := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
		FWbemObjectSet := FWMIService.ExecQuery(Format('SELECT Name FROM Win32_Process Where Name="%s"',[FileName]));
	finally
		Result := (FWbemObjectSet.Count > 0);			
		FWbemObjectSet := Unassigned;
		FWMIService := Unassigned;
		FSWbemLocator := Unassigned;			
	except
			// Catch the exception, dump it to error log if /log set, and continue.
			log('Exception occurred when checking for running process! ' + GetExceptionMessage);
			Result := false;
		end;		
	end;

// Check if force install command line argument was set.
function forcedInstallation(const Count : LongInt): boolean;
var
	ForceInstallation : Boolean;
	ii : LongInt;
	Param : String;	
	begin
		ForceInstallation := FALSE;
		for ii := 0 to Count do
		begin
			Param := ParamStr(ii)
			if CompareText(Param,'--FORCE')=0 then
			begin
				ForceInstallation := TRUE;
				Result := TRUE;
			end;
		end;
end;

// Check if clean install command line argument was set.
function DoCleanInstall(const Count : LongInt): boolean;
var
	CleanInstallation : Boolean;
	ii : LongInt;
	Param : String;	
	begin
		CleanInstallation := FALSE;
		for ii := 0 to Count do
		begin
			Param := ParamStr(ii)
			if CompareText(Param,'--cleaninstall')=0 then
			begin
				CleanInstallation := TRUE;
				Result := TRUE;
			end;
		end;
end;

// Check if run command line argument was set.
function StartAfterInstall(const Count : LongInt): boolean;
var
	StartAfterInstallation : Boolean;
	ii : LongInt;
	Param : String;	
	begin
		StartAfterInstallation := FALSE;
		for ii := 0 to Count do
		begin
			Param := ParamStr(ii)
			if CompareText(Param,'--run')=0 then
			begin
				StartAfterInstallation := TRUE;
				Result := TRUE;
			end;
		end;
end;

// Check if update command line argument was set.
function WasUpdateInstall(const Count : LongInt): boolean;
var
	WasUpgradeInstallation : Boolean;
	ii : LongInt;
	Param : String;	
	begin
		WasUpgradeInstallation := FALSE;
		for ii := 0 to Count do
		begin
			Param := ParamStr(ii)
			if CompareText(Param,'--upgrade')=0 then
			begin
				WasUpgradeInstallation := TRUE;
				Result := TRUE;
			end;
		end;
end;

// Check if nost command line argument was set.
function UpdateNoStInstall(const Count : LongInt): boolean;
var
	UpgradeNoStInstallation : Boolean;
	ii : LongInt;
	Param : String;	
	begin
		UpgradeNoStInstallation := FALSE;
		for ii := 0 to Count do
		begin
			Param := ParamStr(ii)
			if CompareText(Param,'--nost')=0 then
			begin
				UpdateNoStart := ' --nost';
				UpgradeNoStInstallation := TRUE;
				log('Do not start after update install set: True');
				Result := TRUE;
			end;
		end;
end;
	
// Get the uninstall string;
function GetUninstallString: string;
	var
		sUnInstPath: string;
		sUnInstallString: String;
	begin
		Result := '';
		sUnInstPath := ExpandConstant('{#UNINSTKEY}');
		sUnInstallString := '';
	if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
		RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
	log('Getting uninstall string ' + sUnInstPath);
	Result := sUnInstallString;
end;	

// Helper function for clean install. 
function cleanUninstall : boolean;
	var
		iResultCode: Integer;
		sUnInstallString: string;
    begin
			// Perform clean install and uninstall existing installation.
			if RegValueExists(HKEY_LOCAL_MACHINE, ExpandConstant('{#UNINSTKEY}'), 'UninstallString') then
				begin
					sUnInstallString := GetUninstallString();
					sUnInstallString :=  RemoveQuotes(sUnInstallString);
					Wizardform.NextButton.Enabled := False;
					Wizardform.BackButton.Enabled := False;
					WizardForm.CancelButton.Enabled := False;
					log('Current installation found!');
			if Exec(ExpandConstant(sUnInstallString), '/VERYSILENT', '', SW_SHOW, ewWaitUntilTerminated, iResultCode) then
			begin
				// All IO operations have completed.
				log('Older installation was uninstalled');
				// Ensure time out between uninstall and install.
				sleep(1000);
				Result := True;
			end
			else begin
			    log('Error occurred trying to uninstall older version.');
				if UninstallSilent() then begin ExitProcess(11); end; // Our Exit code for clean install fail.
				Result := False;				
			end
		end	
end;

// Helper function for upgrade command line argument.
function wasUpdate : boolean;
	var
		iResultCode: Integer;
    begin
			if ExecAsOriginalUser(ExpandConstant('{app}\updater.exe'), '--upgrade' + UpdateNoStart, '', SW_SHOWNORMAL, ewNoWait, iResultCode) then
			begin
				log('Program was launched successfully.');
				Result := True;
			end
			else begin
				log('Error occurred trying to start program.');
				ExitProcess(14); // Our Exit code for upgrade complete after install.
				Result := False;				
			end;
end;

// Helper function for run command line argument.
function startBrowser : boolean;
	var
		iResultCode: Integer;
    begin
			if ExecAsOriginalUser(ExpandConstant('{app}\{#MyAppExeName}'), '', '',SW_SHOWNORMAL, ewNoWait, iResultCode) then
			begin
				log('Program was launched successfully.');
				Result := True;
			end
			else begin
				log('Error occurred trying to start program.');
				ExitProcess(12); // Our Exit code for startBrowser after install.
				Result := False;				
			end;
end;

// Check task.
function TaskSelected(const Tasks: String): Boolean;
begin
	if IsTaskSelected(Tasks) then
		begin
			log(Tasks + ' was True');
			Result := True;
		end
	else
		begin
			log(Tasks + ' was False');
			Result := False;
		end
end;

// Check for windows Vista.
function CheckIfVista: boolean;
var 
	Version: TWindowsVersion;
begin
	GetWindowsVersionEx(Version);
	Result := False;
	if (Version.Major = 6) and (Version.Minor = 0) then
	begin
		log('Windows vista detected ' + IntToStr(Version.Major) + '.' + IntToStr(Version.Minor));
		Result := True;
	end
end;

// Check if cpu supports SSE2
function Is_SSE2_Supported(): Boolean;
// PF_XMMI64_INSTRUCTIONS_AVAILABLE:= 10;
begin
  Result := IsProcessorFeaturePresent(10);
end;

// Check if instllation is upgrading previous install.
function IsUpgrade(): Boolean;
var
  sPrevPath: String;
begin
  sPrevPath := WizardForm.PrevAppDir;
  Result := (sPrevPath <> '');
end;

// Initialize installer run check for running process.	
#if Arch == "amd64"
// Check and warn user if installing Cyberfox x64 bit on x86 OS.
#endif
function InitializeSetup(): Boolean;
var 
	ErrorCode: Integer;
	begin
		if (IsAppRunning(ExpandConstant ('{#MyAppExeName}'))) then
	begin
		if (forcedInstallation(ParamCount())) then
	begin
		ShellExec('open','taskkill.exe','/f /im {#MyAppExeName}','',SW_HIDE,ewNoWait,ErrorCode);
		log(ExpandConstant ('Installation was forced, {#MyAppExeName} was running!'));
		Result := true;
#if Arch == "amd64"		
		if not IsWin64 then
		begin
			msgbox(ExpandConstant ('{cm:Isx64BitOS}'), mbInformation, MB_OK)
			log('Incompatible OS: Unable to install x64bit application on x86 operating system!');
			ExitProcess(10); // Our Exit code for incompatible OS.
		end	
#endif
	end
		else
	begin
			msgbox(ExpandConstant ('{cm:ProcessName}{cm:IsAppRunning}'), mbInformation, MB_OK)
				ExitProcess(9); // Our Exit code for process is running.
		end	
	end
		else
	begin
		Result := true;
#if Arch == "amd64"		
		if not IsWin64 then
		begin
			msgbox(ExpandConstant ('{cm:Isx64BitOS}'), mbInformation, MB_OK)
			log('Incompatible OS: Unable to install x64bit application on x86 operating system!');
			ExitProcess(10); // Our Exit code for incompatible OS.
		end;	
#endif
		// Check if running windows vista, We no longer support it but still allow the executables to run.
		// When run in silent or verysilent modes the user must pass /suppressmsgboxes to suppress the warning notification.
		if CheckIfVista() then
		begin
			SuppressibleMsgBox(ExpandConstant('{cm:IsAppRunningOnVista}'), mbCriticalError, MB_OK, IDOK)
		end;	
		// Check if PC supports SSE2, If not then show error and exit.
		if not Is_SSE2_Supported() then
		begin
			msgbox(ExpandConstant('{cm:SystemCpuUnsupported}'), mbError, MB_OK)
			log('Incompatible CPU: This computer has an older CPU that lacks SSE2 instruction set support. Cyberfox 49.0 and later can not run on this computer.');
			ExitProcess(13); // Our Exit code for no sse2 support.
		end;	
	end
end;
// After initializing installer event.
procedure InitializeWizard();
begin
	if (DoCleanInstall(ParamCount())) then begin cleanUninstall(); end;
end;
// Make sure to remove start-menu entries during install as not to have many of the same short-cuts in other languages.
procedure CurStepChanged(CurStep: TSetupStep);
	begin
			if CurStep = ssInstall then
	begin
		if FileOrDirExists(ExpandConstant('{group}')) then
				log('Removing start-menu group to prevent duplicate.');
				DelTree(ExpandConstant('{group}'), True, True, True);
		end;
			if CurStep = ssDone then
	begin
		if (WasUpdateInstall(ParamCount())) then 
		begin
			UpdateNoStInstall(ParamCount());
			wasUpdate(); 
		end;
		if (StartAfterInstall(ParamCount())) and not (WasUpdateInstall(ParamCount())) then begin startBrowser(); end;
	end
end;

// Skip license page if already installed
function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if IsUpgrade() and (PageID = wpLicense) then
    Result := True;
end;

// Check if install exists of not disable clean install check-box
// Note when changing task ordering to update array order below for clean install checkbox.
procedure CurPageChanged(CurPageID: Integer);
	begin
		if CurPageID = wpSelectTasks then
	begin
		if not RegValueExists(HKEY_LOCAL_MACHINE, ExpandConstant('{#UNINSTKEY}'), 'UninstallString') then 
			begin
				WizardForm.TasksList.Checked[3] := False;
				WizardForm.TasksList.ItemEnabled[2] := False;
				WizardForm.TasksList.ItemEnabled[3] := False;
		end
		else begin
				WizardForm.TasksList.Checked[3] := False;
		end;
	end;
end;	

// Check if cleanInstall has been selected
function NextButtonClick(CurPageID: Integer): Boolean;
	begin
		Result := True;
	if CurPageID = wpSelectTasks then
	begin
		if TaskSelected('cleaninstall') then
			 cleanUninstall();			
	end;
end;
// Initialize uninstaller run check for process
function InitializeUninstall(): Boolean;
begin
  if (IsAppRunning(ExpandConstant ('{#MyAppExeName}'))) then
	begin
		msgbox(ExpandConstant ('{cm:ProcessName}{cm:IsAppRunningUninstall}'), mbInformation, MB_OK)
			ExitProcess(9); // Our Exit code for process is running.		
	end
		else
	begin
		Result := true;
	end
end;
// Make sure to remove distribution folder on uninstall, Get user input if they want to delete profile data.
// Keep distribution folder clean up for next few releases of 45* to ensure clean up.
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
	begin
		if CurUninstallStep = usPostUninstall then
	begin
	log('Running uninstall clean-up event!');
	if not UninstallSilent() then
		begin
			if FileOrDirExists(ExpandConstant('{app}\distribution')) then
				DelTree(ExpandConstant('{app}\distribution'), True, True, True);
				
			#if Arch == "i368"	
			if FileExists(ExpandConstant('{userdesktop}\{#MyAppName} (x86).LNK')) then
				DeleteFile(ExpandConstant('{userdesktop}\{#MyAppName} (x86).LNK'));
			#elif Arch == "amd64"	
			if FileExists(ExpandConstant('{userdesktop}\{#MyAppName}.LNK')) then
				DeleteFile(ExpandConstant('{userdesktop}\{#MyAppName}.LNK'));
			#endif
			
			if MsgBox(ExpandConstant('{cm:DeleteProfileData}'), mbConfirmation, MB_YESNO) = IDYES  then begin
			if MsgBox(ExpandConstant('{cm:ConfirmDeleteProfileData}'),mbConfirmation, MB_YESNO) = IDYES then begin
				begin
					if FileOrDirExists(ExpandConstant('{localappdata}\{#MyAppPublisher}\{#MyAppName}')) then
						DelTree(ExpandConstant('{localappdata}\{#MyAppPublisher}\{#MyAppName}'), True, True, True);
					if FileOrDirExists(ExpandConstant('{userappdata}\{#MyAppPublisher}')) then
						DelTree(ExpandConstant('{userappdata}\{#MyAppPublisher}'), True, True, True);
					end
				end	
			end
		end
		else
			if FileOrDirExists(ExpandConstant('{app}\distribution')) then
			begin
				DelTree(ExpandConstant('{app}\distribution'), True, True, True);
				
			#if Arch == "i368"	
			if FileExists(ExpandConstant('{userdesktop}\{#MyAppName} (x86).LNK')) then
				DeleteFile(ExpandConstant('{userdesktop}\{#MyAppName} (x86).LNK'));
			#elif Arch == "amd64"	
			if FileExists(ExpandConstant('{userdesktop}\{#MyAppName}.LNK')) then
				DeleteFile(ExpandConstant('{userdesktop}\{#MyAppName}.LNK'));
			#endif			
		end				
	end
end;