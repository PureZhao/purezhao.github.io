#include <sourcemod>

#include "lottery_demo/consts.sp"
#include "lottery_demo/utils.sp"
#include "lottery_demo/classes.sp"
#include "lottery_demo/variables.sp"
#include "lottery_demo/awards.sp"

public Plugin myinfo =
{
    name = "Lottery Demo",
    author = "Pure_*",
    description = "分文件编程示例（简化版抽奖插件）",
    version = "1.0",
    url = ""
};

public void OnPluginStart()
{
    RegConsoleCmd("sm_ldw", Command_Ldw, "打开抽奖（示例）");
    HookEvent("player_death", Event_PlayerDeath);
}

public void OnClientDisconnect(int client)
{
    playerInfo[client].Clear();
}

public Action Command_Ldw(int client, int args)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
        return Plugin_Handled;

    if (!IsSurvivor(client))
    {
        PrintToChat(client, "只有幸存者可以抽奖");
        return Plugin_Handled;
    }

    if (playerInfo[client].isRolling)
    {
        playerInfo[client].StopRoll();
        Award(client);
        return Plugin_Handled;
    }

    if (playerInfo[client].ldwCnt <= 0)
    {
        PrintToChat(client, "没有抽奖机会，击杀僵尸可获得");
        return Plugin_Handled;
    }

    playerInfo[client].StartRoll(Roll, client);
    PrintToChat(client, "抽奖中... 再次输入 !ldw 停止并开奖");
    return Plugin_Handled;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));

    if (IsSurvivor(victim) && playerInfo[victim].isRolling)
    {
        playerInfo[victim].StopRoll();
        PrintToChat(victim, "死亡，抽奖终止");
        return;
    }

    if (IsSurvivor(attacker) && IsInfected(victim))
    {
        playerInfo[attacker].ldwCnt++;
        PrintHintText(attacker, "抽奖机会+1");
    }
}

public Action Roll(Handle timer, int client)
{
    luckyNumber[client] = GetRandomInt(1, 1000);
    PrintCenterText(client, "抽奖中 → %d", luckyNumber[client]);
    return Plugin_Continue;
}

void Award(int client)
{
    if (luckyNumber[client] <= 500)
    {
        PGivePlayerHealth(client, true, 0);
        PrintToChatAll("%N 抽到了：满血奖励", client);
    }
    else
    {
        PrintToChat(client, "没抽中，下次再来");
    }
}
