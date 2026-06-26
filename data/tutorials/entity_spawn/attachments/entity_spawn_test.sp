#include <sourcemod>
#include <sdktools>

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_COMMON "models/infected/common_male_riot.mdl"
#define PARTICLE_EXPLODE "boomer_explode"

public void OnPluginStart()
{
    RegAdminCmd("sm_spawnprop", Command_SpawnProp, ADMFLAG_GENERIC, "在脚下生成油桶");
    RegAdminCmd("sm_spawnzombie", Command_SpawnZombie, ADMFLAG_GENERIC, "在准星位置召唤小僵尸");
    RegAdminCmd("sm_spawnfx", Command_SpawnFx, ADMFLAG_GENERIC, "在准星位置播放粒子");
}

public void OnMapStart()
{
    PrecacheModel(MODEL_GASCAN, true);
    PrecacheModel(MODEL_COMMON, true);
    PrecacheParticleEffect(PARTICLE_EXPLODE);
}

public Action Command_SpawnProp(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    SpawnPropAtClient(client);
    return Plugin_Handled;
}

public Action Command_SpawnZombie(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    float pos[3];
    if (!GetAimPosition(client, pos))
    {
        ReplyToCommand(client, "[错误] 无法获取准星位置");
        return Plugin_Handled;
    }

    SpawnCommonInfected(client, pos);
    return Plugin_Handled;
}

public Action Command_SpawnFx(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    float pos[3];
    if (!GetAimPosition(client, pos))
    {
        ReplyToCommand(client, "[错误] 无法获取准星位置");
        return Plugin_Handled;
    }

    if (CreateParticle(PARTICLE_EXPLODE, pos) == -1)
        ReplyToCommand(client, "[错误] 粒子创建失败");
    else
        ReplyToCommand(client, "[成功] 已播放粒子效果");

    return Plugin_Handled;
}

void SpawnPropAtClient(int client)
{
    float pos[3];
    GetClientAbsOrigin(client, pos);

    int entity = CreateEntityByName("prop_dynamic_override");
    if (entity <= 0)
    {
        PrintToChat(client, "[错误] 实体创建失败");
        return;
    }

    char name[64];
    Format(name, sizeof(name), "Prop-%d-%d", entity, client);
    DispatchKeyValue(entity, "targetname", name);
    DispatchKeyValue(entity, "model", MODEL_GASCAN);
    DispatchKeyValue(entity, "solid", "0");

    if (!DispatchSpawn(entity))
    {
        DeleteEntity(entity);
        PrintToChat(client, "[错误] 实体生成失败");
        return;
    }

    TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
    ActivateEntity(entity);
    PrintToChat(client, "[成功] 已在脚下生成油桶");
}

void SpawnCommonInfected(int client, const float pos[3])
{
    int zombie = CreateEntityByName("infected");
    if (zombie == -1)
    {
        PrintToChat(client, "[错误] 感染者创建失败");
        return;
    }

    SetEntityModel(zombie, MODEL_COMMON);
    TeleportEntity(zombie, pos, {0.0, 0.0, 0.0});
    DispatchSpawn(zombie);
    PrintToChat(client, "[成功] 已召唤一只小僵尸");
}

int CreateParticle(const char[] effectName, const float pos[3])
{
    int particle = CreateEntityByName("info_particle_system");
    if (particle <= 0)
        return -1;

    DispatchKeyValue(particle, "effect_name", effectName);
    DispatchKeyValue(particle, "targetname", effectName);

    if (!DispatchSpawn(particle))
    {
        DeleteEntity(particle);
        return -1;
    }

    TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
    ActivateEntity(particle);
    AcceptEntityInput(particle, "Start");
    return particle;
}

void PrecacheParticleEffect(const char[] effectName)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("ParticleEffectNames");
    }
    bool save = LockStringTables(false);
    AddToStringTable(table, effectName);
    LockStringTables(save);
}

bool GetAimPosition(int client, float hitPoint[3])
{
    float origin[3], angles[3];
    GetClientEyePosition(client, origin);
    GetClientEyeAngles(client, angles);

    Handle trace = TR_TraceRayFilterEx(origin, angles, MASK_SHOT, RayType_Infinite, TraceFilterPlayers);
    if (TR_DidHit(trace))
    {
        TR_GetEndPosition(hitPoint, trace);
        delete trace;
        return true;
    }
    delete trace;
    return false;
}

public bool TraceFilterPlayers(int entity, int contentsMask)
{
    return entity > MaxClients;
}
