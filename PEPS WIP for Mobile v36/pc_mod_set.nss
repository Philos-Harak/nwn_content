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
    object oPC = GetFirstPC();
    if(GetIsNight())
    {
        if(!GetLocalInt(oPC, "AI_TIME_CHANGING"))
        {
            SetTime(8, 0, 0, 0);
            if(!GetIsAreaInterior(GetArea(oPC))) NightToDay(oPC, 2.0f);
            SendMessageToPC(oPC, "The night passes quickly into the morning!");
            SetLocalInt(oPC, "AI_TIME_CHANGING", TRUE);
        }
        else DeleteLocalInt(oPC, "AI_TIME_CHANGING");
    }
    ExecuteScript(GetLocalString(oPC, AI_MODULE_HEARTBEAT_SCRIPT));
}
