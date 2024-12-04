/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac1
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion) default OnHeart beat script for
  henchman.
  This will usually fire every 6 seconds (1 game round).
  We use this to change the creatures event scripts to the new AI event scripts.
*///////////////////////////////////////////////////////////////////////////////
#include "X2_INC_SUMMSCALE"
//#include "0i_server"
//#include "0i_replace_j_ai"
#include "0i_single_player"
void main()
{
    // GZ: Fallback for timing issue sometimes preventing epic summoned creatures from leveling up to their master's level.
    // There is a timing issue with the GetMaster() function not returning the fof a creature
    // immediately after spawn. Some code which might appear to make no sense has been added
    // to the nw_ch_ac1 and x2_inc_summon files to work around this
    // This code is only run at the first hearbeat
    // We then change to 0e_ch_1_hb script for the remaining heart beats.
    int nLevel = SSMGetSummonFailedLevelUp(OBJECT_SELF);
    if (nLevel != 0)
    {
        int nRet;
        if (nLevel == -1) // special shadowlord treatment
        {
          SSMScaleEpicShadowLord(OBJECT_SELF);
        }
        else if  (nLevel == -2)
        {
          SSMScaleEpicFiendishServant(OBJECT_SELF);
        }
        else
        {
            nRet = SSMLevelUpCreature(OBJECT_SELF, nLevel, CLASS_TYPE_INVALID);
            if (nRet == FALSE)
            {
                WriteTimestampedLogEntry("WARNING - nw_ch_ac1:: could not level up " + GetTag(OBJECT_SELF) + "!");
            }
        }
        // regardless if the actual levelup worked, we give up here, because we do not
        // want to run through this script more than once.
        SSMSetSummonLevelUpOK(OBJECT_SELF);
    }
    ai_OnAssociateSpawn(OBJECT_SELF);
}




