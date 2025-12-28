/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_portal_summon
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Onheartbeat event that may summon a outerplanar.
*/////////////////////////////////////////////////////////////////////////////////////////////////////


void main()
{
    int iLevel, iEffect;
    string sResRef;
    object oArea;
    effect eVisual;
    location lLocation;
    // Get area level.
    oArea = GetArea (OBJECT_SELF);
    iLevel = GetLocalInt (oArea, "0_Area_Level");
    // Check to see if we should summon a demon.
    if (d100() <= iLevel)
    {
        // Get the portal location.
        lLocation = GetLocation (OBJECT_SELF);
        // Get summon effect and ResRef based on area level.
        if (iLevel < 5)
        {
            iEffect = VFX_FNF_SUMMON_MONSTER_1;
            if (d2() == 1) sResRef = "imp";
            else sResRef = "quasit";
        }
        else if (iLevel < 10)
        {
            iEffect = VFX_FNF_SUMMON_MONSTER_2;
            sResRef = "hell_hound";
        }
        else if (iLevel < 15)
        {
            iEffect = VFX_FNF_SUMMON_MONSTER_3;
            sResRef = "demon_sucubus";
        }
        else
        {
            iEffect = VFX_FNF_SUMMON_GATE;
            sResRef = "demon_vrock";
        }
        eVisual = EffectVisualEffect(iEffect);
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisual, lLocation);
        CreateObject (OBJECT_TYPE_CREATURE, sResRef, lLocation);
    }
}
