/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_1_hb_fix
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion)
  This will usually fire every 6 seconds (1 game round).
  This script reverts all NPC's back to the original games event scripts that
  were changed by Philos' AI scripts.

  To use just place this script and 0e_c2_1_hb_fix in the cleaned up override
  folder and remove the "_fix" part of the name.
  When the game runs it will change all creatures event scripts back to normal.
  and set them up for the default bioware AI scripts.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_module"
void main()
{
    object oCreature = OBJECT_SELF;
    ai_FixEventScriptsForAssociate(OBJECT_SELF);
    //SpeakString("Philos' AI has reverted my event scripts!");
    // Need to setup all the old associate stuff!
    string sTag;
    object oNPC;
    SetAssociateListenPatterns();//Sets up the special henchmen listening patterns

    bkSetListeningPatterns();      // Goes through and sets up which shouts the NPC will listen to.
    /*
    SetAssociateState(NW_ASC_POWER_CASTING);
    SetAssociateState(NW_ASC_HEAL_AT_50);
    SetAssociateState(NW_ASC_RETRY_OPEN_LOCKS);
    SetAssociateState(NW_ASC_DISARM_TRAPS);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    SetAssociateState(NW_ASC_USE_RANGED_WEAPON, FALSE); //User ranged weapons by default if true.
    SetAssociateState(NW_ASC_DISTANCE_2_METERS);

    // April 2002: Summoned monsters, associates and familiars need to stay
    // further back due to their size.
    int nType = GetAssociateType(OBJECT_SELF);
    switch (nType)
    {
        case ASSOCIATE_TYPE_ANIMALCOMPANION:
        case ASSOCIATE_TYPE_DOMINATED:
        case ASSOCIATE_TYPE_FAMILIAR:
        case ASSOCIATE_TYPE_SUMMONED:
            SetAssociateState(NW_ASC_DISTANCE_4_METERS);
            break;

    }
    sTag=GetLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
    if (GetStringLength(sTag)>0)
    { // look for master
        oNPC=GetNearestObjectByTag(sTag);
        if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
        { // master found
            AddHenchman(oNPC);
        } // master found
        else
        { // look in module
            oNPC=GetObjectByTag(sTag);
            if (GetIsObjectValid(oNPC)&&GetObjectType(oNPC)==OBJECT_TYPE_CREATURE)
            { // master found
                AddHenchman(oNPC);
            } // master found
            else
            { // master does not exist - remove X3_HORSE_OWNER_TAG
                DeleteLocalString(OBJECT_SELF,"X3_HORSE_OWNER_TAG");
            } // master does not exist - remove X3_HORSE_OWNER_TAG
        } // look in module
    } // look for master
    // * Feb 2003: Set official campaign henchmen to have no inventory
    SetLocalInt(OBJECT_SELF, "X0_L_NOTALLOWEDTOHAVEINVENTORY", 10) ;
    SetAssociateStartLocation();
    */
}
