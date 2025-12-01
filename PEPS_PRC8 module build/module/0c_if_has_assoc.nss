/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_assoc
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if caller has the specified feat
 to summon either a companion or a familiar and they are not summoned.
 Param
 sAssociate - "Familiar" or "Companion"
*///////////////////////////////////////////////////////////////////////////////
int StartingConditional()
{
    object oHenchman = OBJECT_SELF;
    string sAssociate = GetScriptParam("sAssociate");
    if(sAssociate == "Familiar" && GetHasFeat(FEAT_SUMMON_FAMILIAR, oHenchman) &&
        GetAssociate(ASSOCIATE_TYPE_FAMILIAR) == OBJECT_INVALID) return TRUE;
    return (sAssociate == "Companion" && GetHasFeat(FEAT_ANIMAL_COMPANION, oHenchman) &&
             GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION) == OBJECT_INVALID);
}
