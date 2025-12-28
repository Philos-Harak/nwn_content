/*////////////////////////////////////////////////
 Script Name: NW_S2_Familiar
 Programmer: Preston Watamaniuk
/////////////////////////////////////////////////
 This spell summons an Arcane casters familiar
 If they have the Improved Familiar feat (1260)
 then they will get a more powerful familiar.
 In the hen_familiar.2da file the familiars are set
 as 0 - 9 normal familiars.
 and 10 - 19 improved familiars.
/*////////////////////////////////////////////////
#include "0i_s_message"
#include "nwnx_creature"
void main()
{
    int nFamiliarType;
    nFamiliarType = GetFamiliarCreatureType (OBJECT_SELF);
    // Check to see if they have the improved familiar feat.
    if (GetHasFeat (1260))
    {
        if (nFamiliarType < 10)
        {
            nFamiliarType = nFamiliarType + 10;
            NWNX_Creature_SetFamiliarCreatureType (OBJECT_SELF, nFamiliarType);
        }
    }
    // If not then give them a normal familiar.
    else
    {
        if (nFamiliarType > 9)
        {
            nFamiliarType = nFamiliarType - 10;
            NWNX_Creature_SetFamiliarCreatureType (OBJECT_SELF, nFamiliarType);
        }
    }
    SummonFamiliar();
    object oFamiliar = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);
    SetLocalInt(oFamiliar, PC_ASSOCIATE_TYPE, ASSOCIATE_TYPE_FAMILIAR);
}
