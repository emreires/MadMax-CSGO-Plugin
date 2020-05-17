#include <sourcemod>
#include <multicolors>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <cstrike>

char current_map[128];
ConVar KlanTagi;
int roundTime;
int currentTime; 

public Plugin myinfo =
{
	name = "Mad Max Eklentisi",
	author = ".#Vortex - TurkModders.com",
	description = "Mad Max Eklentisi | VORTEX-EMRE",
	version = "1.0.0"
}

public void OnPluginStart()
{
	KlanTagi = CreateConVar("turkmodders_madmax_tag", "TurkModders.COM", "Sunucunuzun Adini Giriniz | Reklamlar Icindir | MADMAX | EMRE", FCVAR_PLUGIN);
	HookEvent("round_start", OnRoundStart);
	HookEvent("player_death", Event_PlayerDeath);
}

public void OnMapStart()
{
	GetCurrentMap(current_map, sizeof(current_map));
	if(StrContains(current_map, "mm_", false) == -1 || StrContains(current_map, "truck_", false) == -1)
	{
		ServerCommand("sm plugins unload emre_madmax_eklentisi");
	}
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(1.0, SN30ss, _, TIMER_REPEAT);
    roundTime = GetTime();
    CreateTimer(10.0, silahmesaji);
	return Plugin_Continue;
}

public Action SN30ss(Handle timer)
{
	char GerekenTAG[32];
	GetConVarString(KlanTagi, GerekenTAG, sizeof(GerekenTAG));  
	static int numPrinted = 0;
	int timeleft = 30 - numPrinted;
	if (numPrinted >= 30) 
	{
		ServerCommand("sv_talk_enemy_dead 0");
		ServerCommand("sv_talk_enemy_living 0");
		ServerCommand("sv_alltalk 0");
		ServerCommand("sv_deadtalk 0");
		CPrintToChatAll("{darkred}[%s] {green}Takımlar arası konuşmalar kapatılmıştır.", GerekenTAG);
		CPrintToChatAll("{darkred}[%s] {lime}Oyun başladı!", GerekenTAG);
		CPrintToChatAll("{darkred}[%s] {green}Oyunun amacı, {darkred}T{green}'lerin {darkred}CT Base{green}'deki \x01\x0B\x10tankı alıp {darkred}T Base\x01\x0B\x10'ye götürmesidir.", GerekenTAG);
		PrintHintTextToAll("<b><font color='#ff0000'>[%s]</font> <font color='#2fff00'>Oyunun Amacı,</font> \n<font color='#00ecff'>T'lerin CT Base'deki tankı alıp T Base'ye götürmesidir.</font></b>", GerekenTAG);
		numPrinted = 0;
		return Plugin_Stop;
	}
	else if(timeleft <= 10)
	{
		CPrintToChatAll("\x01\x0B\x10Oyun {green}%i \x01\x0B\x10saniye sonra başlayacak!", timeleft);
		PrintHintTextToAll("<b><font color='#ff0000'>[%s]</font> \n<font color='#2fff00'>%i Saniye</font> <font color='#00ecff'>sonra oyun başlayacak!</font></b>", GerekenTAG, timeleft);
	}
	PrintHintTextToAll("<b><font color='#ff0000'>[%s]</font> \n<font color='#2fff00'>%i Saniye</font> <font color='#00ecff'>sonra oyun başlayacak!</font></b>", GerekenTAG, timeleft);
	
	numPrinted++;
 
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	char GerekenTAG[32];
	GetConVarString(KlanTagi, GerekenTAG, sizeof(GerekenTAG));  	
    currentTime = GetTime();
    
    if (currentTime-roundTime < 30)
    {
    	int client = GetClientOfUserId(GetEventInt(event, "userid"));
    	CreateTimer(1.0, ExecRespawn, client);
    	CPrintToChatAll("{darkred}[%s] {orchid}%N \x01\x0B\x10ilk 30 saniye içerisinde {orchid}öldüğü {default}için {lime}yeniden canlandırıldı.", GerekenTAG, client);
	}
	return Plugin_Continue;
}

public Action ExecRespawn(Handle timer, any client)
{
	CS_RespawnPlayer(client);  
    return Plugin_Stop;
} 

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
    currentTime = GetTime();
    
    if (currentTime-roundTime < 30)
    {
		if (buttons & IN_ATTACK)
		{
			buttons &= ~IN_ATTACK;
		}
		if (buttons & IN_ATTACK2)
		{
			buttons &= ~IN_ATTACK2;
		}
	}
	return Plugin_Continue;
}

public Action silahmesaji(Handle timer)
{
	char GerekenTAG[32];
	GetConVarString(KlanTagi, GerekenTAG, sizeof(GerekenTAG));  
	CPrintToChatAll("[%s] {blue}MadMax'de {green}ilk 30 saniye {blue}silah kullanamazsınız.", GerekenTAG);
	return Plugin_Stop;
}
