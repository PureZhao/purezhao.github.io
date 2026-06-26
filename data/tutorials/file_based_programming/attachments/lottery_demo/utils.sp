#if defined _lottery_demo_utils_included
 #endinput
#endif
#define _lottery_demo_utils_included

stock bool IsSurvivor(int client)
{
    return IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVOR;
}

stock bool IsInfected(int client)
{
    return IsClientInGame(client) && GetClientTeam(client) == TEAM_INFECTED;
}

stock void KillTimerSafety(Handle& timer)
{
    if (timer != null)
    {
        delete timer;
    }
    timer = null;
}
