#include <sourcemod>
#include <dhooks>

#define GAMEDATA_FILE "dhook_demo"

public Plugin myinfo =
{
    name = "DHook Demo",
    author = "Pure_*",
    description = "DHook Detour 示例（教程附件）",
    version = "1.0",
    url = ""
};

public void OnPluginStart()
{
    GameData data = LoadGameConfigFile(GAMEDATA_FILE);
    if (data == null)
    {
        SetFailState("[DHook Demo] 未能加载 gamedata: %s.txt", GAMEDATA_FILE);
        return;
    }

    SetupDetour_Reload(data);
    SetupDetour_PrimaryAttack(data);

    delete data;
}

void SetupDetour_Reload(GameData data)
{
    DHookSetup detour = DHookCreateFromConf(data, "CTerrorGun::Reload");
    if (detour == null)
    {
        LogError("[DHook Demo] CTerrorGun::Reload 创建失败");
        return;
    }

    if (!DHookEnableDetour(detour, false, Detour_Reload_Pre))
        LogError("[DHook Demo] CTerrorGun::Reload Pre Detour 启用失败");

    delete detour;
}

void SetupDetour_PrimaryAttack(GameData data)
{
    DHookSetup detour = DHookCreateFromConf(data, "CTerrorGun::PrimaryAttack");
    if (detour == null)
    {
        LogError("[DHook Demo] CTerrorGun::PrimaryAttack 创建失败");
        return;
    }

    if (!DHookEnableDetour(detour, false, Detour_PrimaryAttack_Pre))
        LogError("[DHook Demo] CTerrorGun::PrimaryAttack Pre Detour 启用失败");

    if (!DHookEnableDetour(detour, true, Detour_PrimaryAttack_Post))
        LogError("[DHook Demo] CTerrorGun::PrimaryAttack Post Detour 启用失败");

    delete detour;
}

MRESReturn Detour_Reload_Pre(int weapon, DHookReturn hookReturn)
{
    if (!IsValidEntity(weapon))
        return MRES_Ignored;

    static char classname[32];
    GetEntityClassname(weapon, classname, sizeof(classname));

    int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
    if (owner <= 0 || !IsClientInGame(owner))
        return MRES_Ignored;

    int clip = GetEntProp(weapon, Prop_Send, "m_iClip1");
    int maxClip = GetEntProp(weapon, Prop_Data, "m_iClip1");

    if (clip >= maxClip)
    {
        PrintToChat(owner, "[DHook Demo] 弹匣已满，阻止换弹");
        DHookSetReturn(hookReturn, 0);
        return MRES_Supercede;
    }

    PrintToChat(owner, "[DHook Demo] Reload Pre -> %s (%d/%d)", classname, clip, maxClip);
    return MRES_Ignored;
}

MRESReturn Detour_PrimaryAttack_Pre(int weapon, DHookReturn hookReturn)
{
    if (!IsValidEntity(weapon))
        return MRES_Ignored;

    int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
    if (owner <= 0 || !IsClientInGame(owner))
        return MRES_Ignored;

    PrintToChat(owner, "[DHook Demo] PrimaryAttack Pre");
    return MRES_Ignored;
}

MRESReturn Detour_PrimaryAttack_Post(int weapon, DHookReturn hookReturn)
{
    if (!IsValidEntity(weapon))
        return MRES_Ignored;

    int owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
    if (owner <= 0 || !IsClientInGame(owner))
        return MRES_Ignored;

    PrintToChat(owner, "[DHook Demo] PrimaryAttack Post");
    return MRES_Ignored;
}
