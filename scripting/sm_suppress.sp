#include	<suppress_manager>
#undef REQUIRE_PLUGIN
#tryinclude	<updater>
#define REQUIRE_PLUGIN

#pragma		semicolon	1
#pragma		newdecls	required

#define PLUGIN_VERSION "0.7.1"
#define PluginUrl "https://raw.githubusercontent.com/Teamkiller324/Suppress-Manager/main/SupressManagerUpdater.txt"

char	gamefolder[64];

ConVar	SuppressTeams,
		SuppressConnect,
		SuppressDisconnect,
		SuppressKillfeed,
		SuppressWinPanel,
		SuppressAchievement,
		SuppressAnnotation,
		SuppressNameChange,
		SuppressVoiceSubTitles,
		SuppressCvar,
		SuppressChat;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)	{
	CreateNative("SuppressManager_IsTeamJoinMsgBlocked",		Native_IsTeamJoinMsgBlocked);
	CreateNative("SuppressManager_IsConnectMsgBlocked",			Native_IsConnectMsgBlocked);
	CreateNative("SuppressManager_IsDisconnectMsgBlocked",		Native_IsDisconnectMsgBlocked);
	CreateNative("SuppressManager_IsKillfeedBlocked",			Native_IsKillfeedBlocked);
	CreateNative("SuppressManager_TF2_IsWinpanelBlocked",		Native_TF2_IsWinpanelBlocked);
	CreateNative("SuppressManager_IsAchievementsBlocked",		Native_IsAchievementsBlocked);
	CreateNative("SuppressManager_TF2_IsAnnotationsBlocked",	Native_TF2_IsAnnotationsBlocked);
	CreateNative("SuppressManager_IsNameChangeBlocked",			Native_IsNameChangeBlocked);
	CreateNative("SuppressManager_TF2_IsVoiceSubTitlesBlocked",	Native_TF2_IsVoiceSubTitlesBlocked);
	CreateNative("SuppressManager_IsServerCvarChangesBlocked",	Native_IsServerCvarChangesBlocked);
	CreateNative("SuppressManager_IsChatMessagesBlocked",		Native_IsChatMessagesBlocked);
	RegPluginLibrary("SuppressManager");
	return	APLRes_Success;
}

any Native_IsTeamJoinMsgBlocked(Handle plugin, int params)			{	return	SuppressTeams.BoolValue;			}
any Native_IsConnectMsgBlocked(Handle plugin, int params)			{	return	SuppressConnect.IntValue;			}
any Native_IsDisconnectMsgBlocked(Handle plugin, int params)		{	return	SuppressDisconnect.IntValue;		}
any Native_IsKillfeedBlocked(Handle plugin, int params)				{	return	SuppressKillfeed.BoolValue;			}
any Native_TF2_IsWinpanelBlocked(Handle plugin, int params)			{	return	SuppressWinPanel.BoolValue;			}
any Native_IsAchievementsBlocked(Handle plugin, int params)			{	return	SuppressAchievement.BoolValue;		}
any Native_TF2_IsAnnotationsBlocked(Handle plugin, int params)		{	return	SuppressAnnotation.BoolValue;		}
any Native_IsNameChangeBlocked(Handle plugin, int params)			{	return	SuppressNameChange.BoolValue;		}
any Native_TF2_IsVoiceSubTitlesBlocked(Handle plugin, int params)	{	return	SuppressVoiceSubTitles.BoolValue;	}
any Native_IsServerCvarChangesBlocked(Handle plugin, int params)	{	return	SuppressCvar.BoolValue;				}
any Native_IsChatMessagesBlocked(Handle plugin, int params)			{	return	SuppressChat.IntValue;				}

public Plugin myinfo = {
	name		=	"[ANY] Suppress Manager",
	author		=	"Tk /id/Teamkiller324",
	description	=	"Blocks specific messages & outputs from showing.",
	version		=	PLUGIN_VERSION,
	url			=	"https://steamcommunity.com/id/Teamkiller324"
}

public void OnPluginStart()	{
	GetGameFolderName(gamefolder, sizeof(gamefolder));
	CreateConVar("sm_suppress_version",	PLUGIN_VERSION,	"Suppress Manager Version", FCVAR_DONTRECORD|FCVAR_SPONLY);
	SuppressTeams		= CreateConVar("sm_suppress_teams",			"0",	"Block Player Joined Team Message? \n0 = Enable Player Joined Team Message \n1 = Block Player Joined Team Message.", _, true, 0.0, true, 1.0);
	SuppressConnect		= CreateConVar("sm_suppress_connect",		"0",	"Block Player Connected Message? \n0 = Enable Connect Message \n1 = Block Connect Message \n2 = Block Only Bot Connect Message \n3 = Block Only Player Connect Message", _, true, 0.0, true, 3.0);
	SuppressDisconnect	= CreateConVar("sm_suppress_disconnect",	"0",	"Block Player Disconnect Message? \n0 = Enable Disconnect Message \n1 = Block Disconnect Message \n2 = Block Only Bot Disconnect Message \n3 = Block Only Player Disconnect Message", _, true, 0.0, true, 3.0);
	SuppressKillfeed	= CreateConVar("sm_suppress_killfeed",		"0",	"Block Player Killfeed? \n0 = Enable Killfeed \n1 = Block Killfeed", _, true, 0.0, true, 1.0);
	SuppressNameChange	= CreateConVar("sm_suppress_namechange",	"0",	"Block Player Name Change Message? \n0 = Enable Player Name Change Message \n1 = Block Player Name Change Message", _, true, 0.0, true, 1.0);
	SuppressAchievement	= CreateConVar("sm_suppress_achievement",	"0",	"Block Player Achievement Get Message? \n0 = Enable Player Achievement Get Message \n1 = Block Player Achievement Get Message", _, true, 0.0, true, 1.0);
	SuppressCvar		= CreateConVar("sm_suppress_cvar",			"0",	"Block Cvar Has Changed To Message? \n0 = Enable Cvar Has Changed To Message \n1 = Block Cvar Has Changed To Message", _, true, 0.0, true, 1.0);
	SuppressChat		= CreateConVar("sm_suppress_chat",			"0",	"Block Player Chat Messages? \0 = Enable Chat Messages \n1 = Disable Public Chat \n2 = Disable Team Chat \n3 = Disable Public and Team Chat", _, true, 0.0, true, 3.0);
	HookUserMessage(GetUserMessageId("SayText2"), suppress_NameChange, true);
	HookEvent("player_team",				suppress_Teams,			EventHookMode_Pre);
	HookEvent("player_connect",				suppress_Connect,		EventHookMode_Pre);
	HookEvent("player_disconnect",			suppress_Disconnect,	EventHookMode_Pre);
	HookEvent("player_death",				suppress_Killfeed,		EventHookMode_Pre);
	HookEvent("achievement_earned",			suppress_Achievement,	EventHookMode_Pre);
	HookEvent("server_cvar",				suppress_Cvar,			EventHookMode_Pre);
	//Check game version
	switch(GetEngineVersion())	{
		case	Engine_CSS, Engine_Contagion:	{	//Counter-Strike: Source, Contagion.
			HookEvent("player_connect_client",		suppress_Connect,		EventHookMode_Pre);
			HookEvent("achievement_event",			suppress_Achievement,	EventHookMode_Pre);
		}
		//Source SDK Base 2013, Half-Life 2: Deathmatch
		case	Engine_SDK2013, Engine_HL2DM:	HookEvent("player_connect_client",		suppress_Connect,		EventHookMode_Pre);
		case Engine_TF2:	{	//Team Fortress 2
			HookEvent("player_connect_client",	suppress_Connect,		EventHookMode_Pre);
			HookEvent("achievement_event",		suppress_Achievement,	EventHookMode_Pre);
			HookEvent("teamplay_win_panel",		suppress_WinPanel,		EventHookMode_Pre);
			HookEvent("show_annotation",		suppress_Annotation,	EventHookMode_Pre);
			
			//These events doesn't exist in TF2 Classic
			if(StrEqual(gamefolder, "tf", false))	{
				HookEvent("slap_notice",			suppress_Killfeed,		EventHookMode_Pre);
				HookEvent("fish_notice",			suppress_Killfeed,		EventHookMode_Pre);
				HookEvent("fish_notice__arm",		suppress_Killfeed,		EventHookMode_Pre);
			}
			
			HookUserMessage(GetUserMessageId("VoiceSubtitle"),	suppress_VoiceSubTitles,	true); 
		
			SuppressWinPanel		=	CreateConVar("sm_suppress_winpanel",		"0",	"Block Player Winpanel From Showing on Win?",		_, true, 0.0, true, 1.0);
			SuppressAnnotation		=	CreateConVar("sm_suppress_annotation",		"0",	"Block Player Annotation Message From Showing?",	_, true, 0.0, true, 1.0);
			SuppressVoiceSubTitles	=	CreateConVar("sm_suppress_voicesubtitles",	"0",	"Block Player Voice Subtitles?",					_, true, 0.0, true, 1.0);
		}
	}
	AutoExecConfig(true, "sm_suppress_manager");
	
	#if defined _updater_included
		Updater_AddPlugin(PluginUrl);
	#endif
}

#if defined _updater_included
public void Updater_OnPluginUpdated()	{
	PrintToServer("[Suppress Manager] Update was found and installed, restarting..");
	ReloadPlugin();
}
#endif

//Cvar has changed to Event
void suppress_Cvar(Event event, const char[] event_name, bool dontBroadcast)	{
	event.BroadcastDisabled = SuppressCvar.BoolValue;
}
//Player has joined team Event
void suppress_Teams(Event event, const char[] event_name, bool dontBroadcast)	{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(!IsValidClient(client))
		return;
	
	switch(SuppressTeams.IntValue)	{
		case	Suppress_Disabled:	event.BroadcastDisabled = false;
		case	Suppress_Enabled:	event.BroadcastDisabled = true;
		case	Suppress_BlockOnlyBots:	{
			if(IsFakeClient(client))
				event.BroadcastDisabled = true;
			else if(!IsFakeClient(client))
				event.BroadcastDisabled = false;
		}
		case	Suppress_BlockOnlyPlayers:	{
			if(!IsFakeClient(client))
				event.BroadcastDisabled = true;
			else if(!IsFakeClient(client))
				event.BroadcastDisabled = false;
		}
	}
}
//Connect Event
void suppress_Connect(Event event, const char[] event_name, bool dontBroadcast)	{
	switch(SuppressConnect.IntValue)	{
		case	Suppress_Disabled:	event.BroadcastDisabled = false;
		case	Suppress_Enabled,
				Suppress_BlockOnlyBots,
				Suppress_BlockOnlyPlayers:	event.BroadcastDisabled = true;
	}
}
public void OnClientAuthorized(int client)	{
	if(!IsValidClient(client))
		return;
	
	switch(SuppressConnect.IntValue)	{
		case	Suppress_BlockOnlyBots:	{
			if(!IsFakeClient(client))
				PrintToChatAll("%N has joined the game", client);
		}
		case	Suppress_BlockOnlyPlayers:	{
			if(IsFakeClient(client))
				PrintToChatAll("%N has joined the game", client);
		}
	}
}

//Disconnect Event
void suppress_Disconnect(Event event, const char[] name, bool dontBroadcast)	{
	int client = GetClientOfUserId(event.GetInt("userid"));
	char reason[256];
	event.GetString("reason", reason, sizeof(reason));
	
	if(!IsValidClient(client))
		return;	//Quits the process, thus saving some time for the dedicated server process.
	
	switch(SuppressDisconnect.IntValue)	{
		case	Suppress_Enabled:	event.BroadcastDisabled = true;
		case	Suppress_BlockOnlyBots:	{
			if(!IsFakeClient(client))	{
				event.BroadcastDisabled = true;
				PrintToChatAll("%N has left the game (%s)", client, reason);
			}
		}
		case	Suppress_BlockOnlyPlayers:	{
			if(IsFakeClient(client))	{
				event.BroadcastDisabled = true;
				PrintToChatAll("%N has left the game (%s)", client, reason);
			}
		}
		case	Suppress_Disabled:	event.BroadcastDisabled = false;
	}
}
//Killfeed Event
void suppress_Killfeed(Event event, const char[] event_name, bool dontBroadcast)	{
	event.BroadcastDisabled = SuppressKillfeed.BoolValue;
}
//Winpanel Event
void suppress_WinPanel(Event event, const char[] event_name, bool dontBroadcast)	{
	event.BroadcastDisabled = SuppressWinPanel.BoolValue;
}
//Achievement get Event
void suppress_Achievement(Event event, const char[] event_name, bool dontBroadcast)	{
	event.BroadcastDisabled = SuppressAchievement.BoolValue;
}
//Annotation Event
void suppress_Annotation(Event event, const char[] event_name, bool dontBroadcast)	{
	event.BroadcastDisabled = SuppressAnnotation.BoolValue;
}
//Name change Event || Credits GORRageBoy
Action suppress_NameChange(UserMsg msg_id, Handle read, const players[], int playersNum, bool reliable, bool init)	{
	if(SuppressNameChange.BoolValue)	{
		if(!reliable)
			return Plugin_Continue;
		
		char buffer[25];
		switch(GetUserMessageType())	{
			case	UM_Protobuf:	{
				view_as<Protobuf>(read).ReadString("msg_name", buffer, sizeof(buffer));
				if(StrContains(buffer, "Name_Change", false) != -1)
					return Plugin_Handled;
			}
			case	UM_BitBuf:	{
				view_as<BfRead>(read).ReadChar();
				view_as<BfRead>(read).ReadChar();
				view_as<BfRead>(read).ReadString(buffer, sizeof(buffer));
	
				if(StrContains(buffer, "Name_Change", false) != -1)
					return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}
//Voice Subtitles Event || Credits Bacardi
Action suppress_VoiceSubTitles(UserMsg msg_id, BfRead bf, const players[], int playersNum, bool reliable, bool init)	{
	int client = bf.ReadByte();
	
	if(SuppressVoiceSubTitles.BoolValue)	{
		if(IsValidClient(client, true))
			return	Plugin_Handled;
	}
	
	return	Plugin_Continue;
}

public Action OnClientSayCommand(int client, const char[] command)	{
	if(StrEqual(command, "say", false))	{
		switch(SuppressChat.IntValue)	{
			case	Suppress_Disabled:			return	Plugin_Continue;
			case	Suppress_Enabled:			return	Plugin_Handled;
			case	Suppress_BlockOnlyBots:		return	Plugin_Continue;
			case	Suppress_BlockOnlyPlayers:	return	Plugin_Handled;
		}
	}
	if(StrEqual(command, "say_team", false))	{
		switch(SuppressChat.IntValue)	{
			case	Suppress_Disabled:			return	Plugin_Continue;
			case	Suppress_Enabled:			return	Plugin_Continue;
			case	Suppress_BlockOnlyBots:		return	Plugin_Handled;
			case	Suppress_BlockOnlyPlayers:	return	Plugin_Handled;
		}
	}
	return	Plugin_Continue;
}

bool IsValidClient(int client, bool CheckAlive=false)	{
	if(client == 0 || client == -1)
		return	false;
	if(client < 1 || client > MaxClients)
		return	false;
	if(!IsClientInGame(client))
		return	false;
	if(!IsClientConnected(client))
		return	false;
	if(IsClientReplay(client))
		return	false;
	if(IsClientSourceTV(client))
		return	false;
	if(CheckAlive)	{
		if(!IsPlayerAlive(client))
			return	false;
	}
	if(GetClientTeam(client) < 1)
		return	false;	//If the client has no team
	return true;
}