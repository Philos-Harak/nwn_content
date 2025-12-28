/*//////////////////////////////////////////////////////////////////////////////
 Harpies Captivating Song
 x2_s1_harpycry
//./////////////////////////////////////////////////////////////////////////////
 Will charm any creature failing saving a will throw DC 15 x
 Charm song in a RADIUS_SIZE_HUGE radius for 6 rounds

 If cast by a Shifter Character, the DC is 15 + Shifter Level / 3
//////////////////////////////////////////////////////////////////////////////*/
#include "0i_creature"
void main()
{
    object oTarget;
    effect eCharm = EffectCharmed();
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eCenter = EffectVisualEffect (VFX_FNF_LOS_NORMAL_30);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects (eMind, eCharm);
    eLink = EffectLinkEffects(eLink, eDuration);
    effect eImpact = EffectVisualEffect(VFX_IMP_CHARM);
    int nRacial;
    int nDuration = 6;
    float fDelay;
    location lLocation = GetLocation (OBJECT_SELF);
    int nSaveDC;
    if (GetIsPC (OBJECT_SELF))
    {
        int nShifter = GetLevelByClass (CLASS_TYPE_SHIFTER, OBJECT_SELF) / 3 ;
        if (nShifter < 1) nShifter = 0;
        nSaveDC = 15 + nShifter;
    }
    else nSaveDC = 15;
    // Apply song Effect on Self
    effect eSong = EffectVisualEffect (VFX_DUR_BARD_SONG);
    ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eSong, OBJECT_SELF, RoundsToSeconds (nDuration));
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, lLocation);
    oTarget = GetFirstObjectInShape (SHAPE_SPHERE, RADIUS_SIZE_HUGE, lLocation);
    while (GetIsObjectValid (oTarget))
    {
        if (oTarget != OBJECT_SELF && GetIsEnemy (oTarget))
        {
            nRacial = GetTrueRacialType (oTarget);
            fDelay = GetRandomDelay();
            //Check that the target is humanoid or animal
            if  ((nRacial == RACIAL_TYPE_DWARF) ||
                (nRacial == RACIAL_TYPE_ELF) ||
                (nRacial == RACIAL_TYPE_GNOME) ||
                (nRacial == RACIAL_TYPE_HUMANOID_GOBLINOID) ||
                (nRacial == RACIAL_TYPE_HALFLING) ||
                (nRacial == RACIAL_TYPE_HUMAN) ||
                (nRacial == RACIAL_TYPE_HALFELF) ||
                (nRacial == RACIAL_TYPE_HALFORC) ||
                (nRacial == RACIAL_TYPE_HUMANOID_MONSTROUS) ||
                (nRacial == RACIAL_TYPE_HUMANOID_ORC) ||
                (nRacial == RACIAL_TYPE_HUMANOID_REPTILIAN))
            {
                //Fire cast spell at event for the specified target
                SignalEvent (oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
                //Make an SR check
                if (ResistSpell (OBJECT_SELF, oTarget) < 1)
                {
                    //Make a Will save to negate
                    if (!WillSave (oTarget, nSaveDC, SAVING_THROW_TYPE_MIND_SPELLS))
                    {
                        //Apply the linked effects and the VFX impact
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration)));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
                    }
                }

            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape (SHAPE_SPHERE, RADIUS_SIZE_HUGE, lLocation);
    }

}



