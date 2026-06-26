#include <sourcemod>

methodmap PlayerStats < ArrayList
{
    public PlayerStats()
    {
        ArrayList data = new ArrayList();
        data.Resize(2);
        return view_as<PlayerStats>(data);
    }

    property int Score
    {
        public get()
        {
            return this.Get(0);
        }
        public set(int value)
        {
            this.Set(0, value);
        }
    }

    property int Kills
    {
        public get()
        {
            return this.Get(1);
        }
        public set(int value)
        {
            this.Set(1, value);
        }
    }

    public void AddScore(int amount)
    {
        this.Score += amount;
    }

    public void AddKill()
    {
        this.Kills++;
        this.AddScore(10);
    }

    public void Reset()
    {
        this.Score = 0;
        this.Kills = 0;
    }
}

methodmap PlayerRegistry < StringMap
{
    public PlayerRegistry()
    {
        return view_as<PlayerRegistry>(new StringMap());
    }

    public void Register(int client)
    {
        char key[16];
        IntToString(client, key, sizeof(key));
        this.SetValue(key, 1);
    }

    public bool IsRegistered(int client)
    {
        char key[16];
        IntToString(client, key, sizeof(key));

        int value;
        return this.GetValue(key, value);
    }

    public int Count()
    {
        return this.Size;
    }
}

PlayerStats g_Stats[MAXPLAYERS + 1];
PlayerRegistry g_Registry;

public void OnPluginStart()
{
    RegConsoleCmd("sm_stats", Command_Stats, "查看玩家统计");
    RegConsoleCmd("sm_addscore", Command_AddScore, "增加 50 分");
    RegConsoleCmd("sm_registry", Command_Registry, "查看注册表信息");

    g_Registry = new PlayerRegistry();

    HookEvent("player_death", Event_PlayerDeath);
}

public void OnPluginEnd()
{
    for (int i = 1; i <= MaxClients; i++)
        delete g_Stats[i];

    delete g_Registry;
}

public void OnClientPutInServer(int client)
{
    g_Stats[client] = new PlayerStats();
    g_Registry.Register(client);
}

public void OnClientDisconnect(int client)
{
    delete g_Stats[client];
    g_Stats[client] = null;
}

public Action Command_Stats(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    PrintToChat(client, "[Stats] 分数: %d | 击杀: %d", g_Stats[client].Score, g_Stats[client].Kills);
    return Plugin_Handled;
}

public Action Command_AddScore(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    g_Stats[client].AddScore(50);
    PrintToChat(client, "[Stats] 已增加 50 分，当前 %d", g_Stats[client].Score);
    return Plugin_Handled;
}

public Action Command_Registry(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    PrintToChat(client, "[Registry] 已注册: %s | 总数: %d",
        g_Registry.IsRegistered(client) ? "是" : "否",
        g_Registry.Count());
    return Plugin_Handled;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    if (attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker))
        return;

    g_Stats[attacker].AddKill();
}
