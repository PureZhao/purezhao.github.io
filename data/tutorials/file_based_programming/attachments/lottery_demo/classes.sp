#if defined _lottery_demo_classes_included
 #endinput
#endif
#define _lottery_demo_classes_included

enum struct PlayerGameInfo
{
    int ldwCnt;
    bool isRolling;
    Handle rollTimer;

    void StartRoll(Timer func, int client)
    {
        this.rollTimer = CreateTimer(ROLL_INTERVAL, func, client, TIMER_REPEAT);
        this.isRolling = true;
        this.ldwCnt--;
    }

    void StopRoll()
    {
        this.isRolling = false;
        KillTimerSafety(this.rollTimer);
    }

    void Clear()
    {
        this.ldwCnt = 0;
        this.StopRoll();
    }
}
