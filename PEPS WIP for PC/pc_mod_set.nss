/*//////////////////////////////////////////////////////////////////////////////
 Script Name: pc_mod_set
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    PEPS Plugin to set module and area settings.
    This is setup in the heartbeat of the module to inject code.
/*//////////////////////////////////////////////////////////////////////////////
const string AI_MODULE_HEARTBEAT_SCRIPT = "AI_MODULE_HEARTBEAT_SCRIPT";
void main()
{
    object oPC = GetLocalObject(GetModule(), "AI_PC_TIME_SET");
    if(GetIsNight())
    {
        if(!GetLocalInt(oPC, "AI_TIME_CHANGING"))
        {
            if(GetIsInCombat(oPC))
            {
                SetTime(8, 0, 0, 0);
                if(!GetIsAreaInterior(GetArea(oPC))) NightToDay(oPC, 2.0f);
                SendMessageToPC(oPC, "The night passes quickly into the morning!");
                SetLocalInt(oPC, "AI_TIME_CHANGING", TRUE);
            }
        }
        else DeleteLocalInt(oPC, "AI_TIME_CHANGING");
    }
    ExecuteScript(GetLocalString(oPC, AI_MODULE_HEARTBEAT_SCRIPT));
}
