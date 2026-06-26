#include <sourcemod>

Handle g_Timer[MAXPLAYERS + 1];
ArrayList g_PlayerNames;
StringMap g_PlayerScores;

public void OnPluginStart()
{
    RegConsoleCmd("sm_handle_demo", Command_HandleDemo, "Handle 示例：DataPack 延迟消息");
    RegConsoleCmd("sm_list_demo", Command_ListDemo, "Handle 示例：ArrayList 列表");
    RegConsoleCmd("sm_map_demo", Command_MapDemo, "Handle 示例：StringMap 映射");

    g_PlayerNames = new ArrayList(ByteCountToCells(64));
    g_PlayerScores = new StringMap();
}

public void OnPluginEnd()
{
    for (int i = 1; i <= MaxClients; i++)
        KillTimerSafe(g_Timer[i]);

    delete g_PlayerNames;
    delete g_PlayerScores;
}

public void OnClientDisconnect(int client)
{
    KillTimerSafe(g_Timer[client]);
}

public Action Command_HandleDemo(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    KillTimerSafe(g_Timer[client]);

    DataPack dp;
    g_Timer[client] = CreateDataTimer(3.0, Timer_DelayedHello, dp);
    dp.WriteCell(client);
    dp.WriteString("Handle 示例消息");

    PrintToChat(client, "[Handle] 3 秒后显示消息...");
    return Plugin_Handled;
}

public Action Timer_DelayedHello(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();

    char message[128];
    dp.ReadString(message, sizeof(message));

    if (!IsClientInGame(client))
        return Plugin_Stop;

    PrintToChat(client, "[Handle] %s", message);
    g_Timer[client] = null;
    return Plugin_Stop;
}

public Action Command_ListDemo(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    g_PlayerNames.Clear();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i))
            continue;

        char name[64];
        Format(name, sizeof(name), "%N", i);
        g_PlayerNames.PushString(name);
    }

    PrintToChat(client, "[ArrayList] 当前在线 %d 人:", g_PlayerNames.Length);
    for (int i = 0; i < g_PlayerNames.Length; i++)
    {
        char name[64];
        g_PlayerNames.GetString(i, name, sizeof(name));
        PrintToChat(client, "  %d. %s", i + 1, name);
    }

    return Plugin_Handled;
}

public Action Command_MapDemo(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    char key[16];
    IntToString(client, key, sizeof(key));

    int score;
    if (g_PlayerScores.GetValue(key, score))
        score++;
    else
        score = 1;

    g_PlayerScores.SetValue(key, score);
    PrintToChat(client, "[StringMap] 你使用 !map_demo 的次数: %d", score);
    return Plugin_Handled;
}

void KillTimerSafe(Handle& timer)
{
    if (timer != null)
        delete timer;

    timer = null;
}
