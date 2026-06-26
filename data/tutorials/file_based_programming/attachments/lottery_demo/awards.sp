#if defined _lottery_demo_awards_included
 #endinput
#endif
#define _lottery_demo_awards_included

public void PGivePlayerHealth(int client, bool toMax, int amount)
{
    int curHp = GetEntProp(client, Prop_Data, "m_iHealth");
    int maxHp = GetEntProp(client, Prop_Data, "m_iMaxHealth");

    if (toMax)
    {
        SetEntProp(client, Prop_Data, "m_iHealth", maxHp);
    }
    else
    {
        int result = curHp + amount;
        if (result > maxHp)
            result = maxHp;
        SetEntProp(client, Prop_Data, "m_iHealth", result);
    }
}
