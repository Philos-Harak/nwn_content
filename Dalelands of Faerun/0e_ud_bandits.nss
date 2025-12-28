/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ud_bandits
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  UserDefined script for Bandits.
  Used to randomize the name.
/*//////////////////////////////////////////////////////////////////////////////
//const int NW_FLAG_PERCIEVE_EVENT              = 0x00000200;
//const int NW_FLAG_ATTACK_EVENT                = 0x00000400;
//const int NW_FLAG_DAMAGED_EVENT               = 0x00000800;
//const int NW_FLAG_SPELL_CAST_AT_EVENT         = 0x00001000;
//const int NW_FLAG_DISTURBED_EVENT             = 0x00002000;
//const int NW_FLAG_END_COMBAT_ROUND_EVENT      = 0x00004000;
//const int NW_FLAG_ON_DIALOGUE_EVENT           = 0x00008000;
//const int NW_FLAG_RESTED_EVENT                = 0x00010000;
//const int NW_FLAG_HEARTBEAT_EVENT             = 0x00100000;

string RandomizeBanditName()
{
    int nRoll = d100();
    string sName = "Bandit";
    if(nRoll < 11) sName = "Zhentarim ";
    else if(nRoll < 22) sName = "Brigand ";
    else if(nRoll < 33) sName = "Sons of Gondegal ";
    else if(nRoll < 44) sName = "Seven Snake ";
    else if(nRoll < 55) sName = "Ruffian ";
    else if(nRoll < 66) sName = "Renegade ";
    else if(nRoll < 77) sName = "Daleland ";
    else if(nRoll < 88) sName = "Escaped ";
    return sName;
}
void main()
{
    int nEvent = GetUserDefinedEventNumber();
    switch(nEvent)
    {
        // We define 1000 as OnSpawn.
        case 1000:
        {
            // *****************************************************************
            // ********** Renameing: OnSpawn Event  ****************************
            // *****************************************************************
            object oCreature = OBJECT_SELF;
            object oArea = GetArea(oCreature);
            string sName = GetLocalString(oArea, "0_BANDIT_NAME");
            if(sName == "")
            {
                sName = RandomizeBanditName();
                SetLocalString(oArea, "0_BANDIT_NAME", sName);
            }
            string sOriginalName = GetName(oCreature);
            SetName(oCreature, sName + sOriginalName);
            break;
        }
    }
}
