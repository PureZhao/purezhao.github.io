#include <sourcemod>

public void OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath);
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int userid = GetClientOfUserId(event.GetInt("userid"));
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    PrintToChatAll("玩家%d死亡，攻击者%d", userid, attacker);
}