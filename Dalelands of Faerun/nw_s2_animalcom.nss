/*////////////////////////////////////////////////
 Script Name: NW_S2_AnimalComp
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
 This spell summons an animal companion
 If they have the Improved Animal Companion feat (1261)
 then they will get a more powerful companion.
 In the hen_companion.2da file the companions are set
 as 0 - 8 normal familiars.
 and 9 - 17 improved familiars.
/*///////////////////////////////////////////////
#include "0i_s_message"
#include "nwnx_creature"
void main()
{
    int iCompanionType;
    iCompanionType = GetAnimalCompanionCreatureType (OBJECT_SELF);
    // Check to see if they have the improved familiar feat.
    if (GetHasFeat (1261))
    {
        if (iCompanionType < 9)
        {
            iCompanionType = iCompanionType + 9;
            NWNX_Creature_SetAnimalCompanionCreatureType (OBJECT_SELF, iCompanionType);
        }
    }
    // If not then give them a normal familiar.
    else
    {
        if (iCompanionType > 8)
        {
            iCompanionType = iCompanionType - 9;
            NWNX_Creature_SetAnimalCompanionCreatureType (OBJECT_SELF, iCompanionType);
        }
    }
    SummonAnimalCompanion ();
    object oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION);
    SetLocalInt(oCompanion, PC_ASSOCIATE_TYPE, ASSOCIATE_TYPE_ANIMALCOMPANION);
}
