#include <sourcemod>

Handle g_CountdownTimer[MAXPLAYERS + 1];
int g_Remaining[MAXPLAYERS + 1];

public void OnPluginStart()
{
    RegConsoleCmd("sm_delay", Command_Delay, "3秒后显示消息");
    RegConsoleCmd("sm_countdown", Command_Countdown, "开始倒计时");
    RegConsoleCmd("sm_delaymsg", Command_DelayMsg, "5秒后显示自定义消息");
}

public void OnClientDisconnect(int client)
{
    KillTimerSafety(g_CountdownTimer[client]);
    g_Remaining[client] = 0;
}

public Action Command_Delay(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    ReplyToCommand(client, "[提示] 3秒后显示消息...");
    CreateTimer(3.0, Timer_DelayMessage, client);
    return Plugin_Handled;
}

public Action Timer_DelayMessage(Handle timer, int client)
{
    if (!IsClientInGame(client))
        return Plugin_Stop;

    PrintToChat(client, "[提示] 延迟消息到了！");
    return Plugin_Stop;
}

public Action Command_Countdown(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    int seconds = 10;
    if (args >= 1)
        seconds = GetCmdArgInt(1);

    if (seconds <= 0)
        return Plugin_Handled;

    KillTimerSafety(g_CountdownTimer[client]);
    g_Remaining[client] = seconds;
    g_CountdownTimer[client] = CreateTimer(1.0, Timer_Countdown, client, TIMER_REPEAT);
    ReplyToCommand(client, "[提示] 倒计时开始，共 %d 秒", seconds);
    return Plugin_Handled;
}

public Action Timer_Countdown(Handle timer, int client)
{
    if (!IsClientInGame(client))
    {
        g_CountdownTimer[client] = null;
        g_Remaining[client] = 0;
        return Plugin_Stop;
    }

    PrintToChat(client, "[倒计时] 剩余 %d 秒", g_Remaining[client]);
    g_Remaining[client]--;

    if (g_Remaining[client] <= 0)
    {
        PrintToChat(client, "[倒计时] 时间到！");
        g_CountdownTimer[client] = null;
        return Plugin_Stop;
    }
    return Plugin_Continue;
}

public Action Command_DelayMsg(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    char message[128] = "默认延迟消息";
    if (args >= 1)
        GetCmdArgString(message, sizeof(message));

    ReplyToCommand(client, "[提示] 5秒后显示消息...");
    StartDelayedMessage(client, 5.0, message);
    return Plugin_Handled;
}

void StartDelayedMessage(int client, float delay, const char[] message)
{
    DataPack dp;
    CreateDataTimer(delay, Timer_DelayedMessage, dp);
    dp.WriteCell(client);
    dp.WriteString(message);
}

public Action Timer_DelayedMessage(Handle timer, DataPack dp)
{
    dp.Reset();
    int client = dp.ReadCell();

    char message[128];
    dp.ReadString(message, sizeof(message));

    if (!IsClientInGame(client))
        return Plugin_Stop;

    PrintToChat(client, "[延迟消息] %s", message);
    return Plugin_Stop;
}

void KillTimerSafety(Handle& timer)
{
    if (timer != null)
    {
        delete timer;
    }
    timer = null;
}
