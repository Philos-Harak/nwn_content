/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_7_ondeath
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate OnSpawn script;
  This fires when an associate dies.
  Philos AI does not use this in override versions.
  Included for servers as an example to help add Philos AI to a server.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_server"
#include "0i_single_player"
//#include "x3_inc_horse"
void main()
{
    object oCreature = OBJECT_SELF;
    // * Philos AI - Horse code has not been tested with it, use at own risk!
    //SetLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT","nw_ch_ac7");
    //if (HorseHandleDeath()) return;
    //DeleteLocalString(OBJECT_SELF,"sX3_DEATH_SCRIPT");
    // * I am a familiar, give 1d6 damage to my master
    object oMaster = GetMaster(oCreature);
    if (GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oMaster) == oCreature)
    {
        // April 2002: Made it so that familiar death can never kill the player
        // only wound them.
        int nDam =d6();
        if (nDam >= GetCurrentHitPoints(oMaster))
        {
            nDam = GetCurrentHitPoints(oMaster) - 1;
        }
        effect eDam = EffectDamage(nDam);
        FloatingTextStrRefOnCreature(63489, oMaster, FALSE);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDam, oMaster);
    }
//****************************  ADDED AI CODE  *****************************
    // Added code to allow for permanent associates in the battle!
    int nAssociateType = GetAssociateType(oCreature);
    if((nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION ||
       nAssociateType == ASSOCIATE_TYPE_FAMILIAR ||
       nAssociateType == ASSOCIATE_TYPE_SUMMONED) &&
       !ai_GetIsCharacter(oMaster) && AI_PERMANENT_ASSOCIATES)
    {
        ChangeFaction(oCreature, oMaster);
    }
//****************************  ADDED AI CODE  *****************************
}
