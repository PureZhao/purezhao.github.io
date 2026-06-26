#include <sourcemod>

public void OnPluginStart()
{
    RegConsoleCmd("sm_hello", Command_Hello, "向玩家发送问候消息");
    RegConsoleCmd("sm_echo", Command_Echo, "在聊天框广播一条消息");
    RegAdminCmd("sm_slay", Command_Slay, ADMFLAG_SLAY, "处死指定玩家");
}

public Action Command_Hello(int client, int args)
{
    if (client == 0)
    {
        PrintToServer("[Hello] 该指令只能由玩家在游戏内使用");
        return Plugin_Handled;
    }

    ReplyToCommand(client, "[Hello] 你好，%N！", client);
    return Plugin_Handled;
}

public Action Command_Echo(int client, int args)
{
    if (client == 0 || args < 1)
    {
        ReplyToCommand(client, "[用法] !echo <消息>");
        return Plugin_Handled;
    }

    char message[256];
    GetCmdArg(1, message, sizeof(message));
    PrintToChatAll("%N 说: %s", client, message);
    return Plugin_Handled;
}

public Action Command_Slay(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "[用法] !slay <客户端ID>");
        return Plugin_Handled;
    }

    char arg[16];
    GetCmdArg(1, arg, sizeof(arg));
    int target = StringToInt(arg);

    if (target < 1 || target > MaxClients || !IsClientInGame(target))
    {
        ReplyToCommand(client, "[错误] 无效的玩家ID");
        return Plugin_Handled;
    }

    ForcePlayerSuicide(target);
    ReplyToCommand(client, "[成功] 已处死 %N", target);
    return Plugin_Handled;
}
