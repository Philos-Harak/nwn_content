/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Include Name: 0i_effects
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts to run effects on objects within the game and manage all spell
 effects that run after the spell is cast.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_itemproperty"
#include "0i_datetime"
#include "nwnx_area"
#include "nwnx_effect"

// Creates a feat like effect for oCraeture from eEffect with sEffectTag.
// Removes any old effects and adds the new effect.
void CreateFeatEffect(object oCreature, effect eEffect, string sEffectTag);

effect GetTaggedEffect(string sTag, object oTarget = OBJECT_SELF);

int GetHasEffect(int nEffectType, object oTarget = OBJECT_SELF);

int HasEffectWithTag(object oCreature, string sTag);

// Removes any effects from nSpellID on oTarget from oCaster.
// if oCaster is OBJECT_INVALID then it will remove all effects from nSpellID
// reguardless of who cast it.
void RemoveSpellEffects(int nSpellID, object oTarget, object oCaster = OBJECT_INVALID);

// This function checks to see if oCreature is disabled and cannot act.
// Returns a value based on the disabling effect.
// Dead = 1, Bleeding = 2, Dying = 2, Stunned = 29, Confused = 24, Paralyzed = 27
// Frightened 25, Turned = 35, Petrified = 79, Charmed = 23, Disappearappear = 75,
// Time Stop = 66, Dazed = 28, Sleep = 30.
// Returns 0 (FALSE) if not Disabled.
int Disabled(object oCreature = OBJECT_SELF);
// This function makes oCreature become shaken for fDuration.
// The shaken effect penalizes oCreature with -2 attack, saves, skill, and checks.
void Shaken(object oCreature, float fDuration, int nCasterLevel);
// This function makes oCreature become frightened for fDuration.
// The frightened effect penalizes oCreature with -4 attack, saves, skill, and checks.
void Frightened(object oCreature, float fDuration, int nCasterLevel);
// This function makes oCreature become panicked for fDuration.
// The panicked effect penalizes oCreature with -6 attack, saves, skill, and checks.
// and non-player characters become paralyzed for 1-3 rounds.
void Panicked(object oCreature, float fDuration, int nCasterLevel);
// Create fly effect for oPC to lTarget.
void FlyEffect(object oPC, location lTarget);
// Will move an object for special effects.
// fX moves the object in the x axis.
// fY moves the object in the y axis.
// fZ moves the object in the z axis (+up and -down).
// nLerp the transform_lerp type Constatns: OBJECT_VISUAL_TRANSFORM_LERP_*
// fDuration is the duration of the lerp effect.
void MoveObject(object oObject, float fX = 0.0f, float fY = 0.0f, float fZ = 0.0f, int nLerp = OBJECT_VISUAL_TRANSFORM_LERP_NONE, float fDuration = 0.0f);

void AdjustMoonPhase(object oArea, object oPC);

// Checks weather and if needed changes it otherwise sets any exterior areas weather.
void CheckWeather(object oArea, object oPC);

// fWindMagnitude is the power of the wind 0.0f to 3.0f should be followed.
// bKeepDirection True will not change the winds direction. False randomizes it.
void SetWind(float fWindMagnitude, int bKeepDirection = FALSE);

// Used to delay the creation of an object for effect.
void DelayCreateObject(int iObjectType, string sResRef, location lLocation);

// Remove Effect of Type specified on oCreature;
// iEffect is EFFECT_TYPE_*
void RemoveASpecificEffect(object oCreature, int iEffect);

// Remove Effect of type specified from oCreature;
// sEffectTag is the tag of the effect to remove.
// Feat, Class, Racial.
void RemoveTagedEffects(object oCreature, string sEffectTag);

// oCreature the effects are to be reomved from.
// bResting if these effects are being removed due to resting.
void CheckSpellEffectsForRemoval(object oCreature, int bResting = FALSE);

// Removes effects All, Bad, or Good effects from a creature.
// iEffectGroup can be 0 - All, 1 - Bad Effects only, 2 - Good Effects only.
// iEffectTypeKeep will not remove a specific effect if desired.
void RemoveCreatureEffects(object oCreature, int iEffectGroup = 0, int iEffectTypeKeep = EFFECT_TYPE_INVALIDEFFECT, int iEffectSubTypeKeep = 0);
// Applies oHelm vfx to oCreature that equiped oHelm.
void DoOpenFaceHelmetVisuals(object oCreature,object oHelm, int bReplace = FALSE);
// Applies oAccessory vfx to oCreature that used oAccessory.
// bReplace allows the function to remove the old VFX and add it again.
// This is used for the crafting plugin to update the scale of the VFX when the player changes it.
void DoAccessoryVisuals(object oCreature,object oAccessory, int bReplace = FALSE, int bRemove = FALSE);
// Put demonic legs on PC if they have them.
// oPC is the pc to change.
// oItem is the armor to change.
// iAction is either 1 - Equip or 2 Unequip
void CheckDemonicAppearance(object oPC, object oItem, int iAction = 1);

// Applies the glowing eyes effect on a creature.
// oCreature is the creature to put the effect on.
// iFX is the Color and effect required.
// 0:None 1:Red flaming 2:Green 3:Yellow flaming
// 4:Cyan 5:Orange 6:Purple 7:White 8:Yellow
void ApplyGlowingEyes(int iFX, object oCreature);

// Checks feats for equiping and unequiping weapons.
// oCreature is the creature equiping or unequiping.
// oItem is the item being equiped.
// iEquip tells if we are equiping or unequiping.
void CheckEquipWeaponFeats(object oCreature, object oItem, int bEquip = TRUE);

// Checks feats for equiping and unequiping shields.
// oCreature is the creature equiping or unequiping.
// oItem is the item being equiped.
// iEquip tells if we are equiping or unequiping.
void CheckEquipShieldFeats(object oCreature, object oItem, int bEquip = TRUE);

// Burning effect.
// Spell is the spell causing the burning effect
// oTarget is the target of the burning effect.
// nNumOfDie is the number of damage dice used.
// nDie is the die to roll.
// nBonus is any bonus to be added.
// bSave is if they get a save or not.
void Burning(struct stSpell Spell, int nNumOfDice, int nDie, int nBonus, int bSave);

// Sets Armor bonus based upon variable 0_Armor_Bonus and armor worn.
// oCreature is the creature with the armor bonus.
void CheckForArmorBonus(object oCreature);

// Sets Armor Spell Failure on the armor if they have the correct feats and armor.
// oCreature is the craature with the armor.
// oItem is the armor being equiped.
void CheckForArmorArcaneSpellFailure(object oCreature, object oItem);

// Changes the size of a creature with an effect of enlarge or shrinking.
// oTarget is creature to change.
// fSizeTo is the size to change them to.
void ChangeSize(object oTarget, float fSizeTo);

// Removes bard song effects required in songs and on relogging.
// oTarget is the target to remove the effects from.
void RemoveBardSongEffects(object oTarget);

// Removes an icon from an effect. Usually a spell.
effect RemoveEffectIcon(effect eEffect);

int GetNextFogColor(int nFogColor);

string GetFogTextColor(int nFogColor);

// Kills a regenerating creature (the only way to kill them!).
void KillRegeneratingCreature(object oCreature, int bAcid, int bFire);

// Calculates the permanent and temporary damage for a regerating creature.
int CalculateRegeneratingCreatureDamage();

// Regenerates a regenerating creature (only temporary damage!).
void Regenerate();

// Used a villain is killed and the journal is updated.
float KillVillainEffect(object oTarget);

// Used by the divine power to return the player to the prime plane.
void ReturnToPrimeEffect(object oCaster, object oTarget);

// Portal effect used in the undermountain arch portals.
// returns the wait period before jumping the character.
float PortalEffect(object oPortal, object oUser);

// The effect placed on a player when they die.
float DeathEffect(object oPC);

// The effects from using the rod of returning.
// returns the wait period before jumping the character.
float RodOfRecallEffect(object oUser);

// Close portal effect.
// returns the wait period before destroying the portal.
// oPortal is the portal to close.
// oUser is the user closing the portal.
float ClosePortalEffect(object oPortal, object oUser);

// Creates a feat like effect for oCraeture from eEffect with sEffectTag.
// Removes any old effects and adds the new effect.
void CreateFeatEffect(object oCreature, effect eEffect, string sEffectTag)
{
    RemoveTagedEffects(oCreature, sEffectTag);
    eEffect = UnyieldingEffect(eEffect);
    struct NWNX_EffectUnpacked n_effect;
    n_effect = NWNX_Effect_UnpackEffect(eEffect);
    n_effect.bShowIcon = FALSE;
    n_effect.sTag = sEffectTag;
    eEffect = NWNX_Effect_PackEffect (n_effect);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oCreature);
}

effect GetTaggedEffect (string sTag, object oTarget = OBJECT_SELF)
{
    effect eEffect = GetFirstEffect (oTarget);
    while (GetIsEffectValid (eEffect))
    {
        if (GetEffectTag (eEffect) == sTag) return eEffect;
        eEffect = GetNextEffect (oTarget);
    }
    return eEffect;
}

int GetHasEffect (int nEffectType, object oTarget = OBJECT_SELF)
{
    effect eEffect = GetFirstEffect (oTarget);
    while (GetIsEffectValid (eEffect))
    {
        if (GetEffectType (eEffect) == nEffectType) return TRUE;
        eEffect = GetNextEffect (oTarget);
    }
    return FALSE;
}

int HasEffectWithTag (object oCreature, string sTag)
{
   effect eEffect = GetFirstEffect (oCreature);
   while (GetIsEffectValid (eEffect))
   {
      if (GetEffectTag (eEffect) == sTag) return TRUE;
      eEffect = GetNextEffect (oCreature);
   }
   return FALSE;
}

void RemoveSpellEffects(int nSpellID, object oTarget, object oCaster = OBJECT_INVALID)
{
    effect eEffect;
    if(GetHasSpellEffect(nSpellID, oTarget))
    {
        eEffect = GetFirstEffect(oTarget);
        while(GetIsEffectValid(eEffect))
        {
            if(GetEffectCreator(eEffect) == oCaster || oCaster == OBJECT_INVALID)
            {
                if(GetEffectSpellId(eEffect) == nSpellID)
                {
                    RemoveEffect(oTarget, eEffect);
                }
            }
            eEffect = GetNextEffect(oTarget);
        }
    }
}

void RemoveEffectsFromSpell (object oTarget, int nSpellID)
{
    effect eEffect = GetFirstEffect (oTarget);
    while (GetIsEffectValid (eEffect))
    {
      if (GetEffectSpellId (eEffect) == nSpellID) RemoveEffect(oTarget, eEffect);
      eEffect = GetNextEffect (oTarget);
    }
}
void Shaken(object oCreature, float fDuration, int nCasterLevel)
{
    effect eShaken = EffectAttackDecrease(2);
    eShaken = EffectLinkEffects(EffectSavingThrowDecrease (SAVING_THROW_ALL, 2), eShaken);
    eShaken = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, 2), eShaken);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    eShaken = EffectLinkEffects(eDuration, eShaken);
    eShaken = EffectLinkEffects(eVisual, eShaken);
    eShaken = SetEffectCasterLevel(eShaken, nCasterLevel);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShaken, oCreature, fDuration);
}
void Frightened(object oCreature, float fDuration, int nCasterLevel)
{
    effect eFrightened = EffectAttackDecrease(4);
    eFrightened = EffectLinkEffects(EffectSavingThrowDecrease (SAVING_THROW_ALL, 4), eFrightened);
    eFrightened = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, 4), eFrightened);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    eFrightened = EffectLinkEffects(eDuration, eFrightened);
    eFrightened = EffectLinkEffects(eVisual, eFrightened);
    eFrightened = SetEffectCasterLevel(eFrightened, nCasterLevel);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFrightened, oCreature, fDuration);
    if(!GetIsPC(oCreature))
    {
        effect eParalyzed = EffectParalyze();
        eParalyzed = EffectLinkEffects(EffectVisualEffect(VFX_DUR_PARALYZED), eParalyzed);
        eParalyzed = SetEffectCasterLevel(eParalyzed, nCasterLevel);
        // Don't let the paralyzing effect last longer than the fear effect.
        float fParalyzeDuration = RoundsToSeconds(d2());
        if(fParalyzeDuration > fDuration) fParalyzeDuration = fDuration;
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eParalyzed, oCreature, fParalyzeDuration);
    }
}
void Panicked(object oCreature, float fDuration, int nCasterLevel)
{
    effect ePanicked = EffectAttackDecrease(6);
    ePanicked = EffectLinkEffects(EffectSavingThrowDecrease (SAVING_THROW_ALL, 6), ePanicked);
    ePanicked = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, 6), ePanicked);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    ePanicked = EffectLinkEffects(eDuration, ePanicked);
    ePanicked = EffectLinkEffects(eVisual, ePanicked);
    ePanicked = SetEffectCasterLevel(ePanicked, nCasterLevel);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePanicked, oCreature, fDuration);
    if(!GetIsPC(oCreature))
    {
        effect eParalyzed = EffectParalyze();
        eParalyzed = SetEffectCasterLevel(eParalyzed, nCasterLevel);
        eParalyzed = EffectLinkEffects(EffectVisualEffect(VFX_DUR_PARALYZED), eParalyzed);
        // Don't let the paralyzing effect last longer than the fear effect.
        float fParalyzeDuration = RoundsToSeconds(d4());
        if(fParalyzeDuration > fDuration) fParalyzeDuration = fDuration;
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eParalyzed, oCreature, fParalyzeDuration);
    }
}
// Create fly effect for oPC to lTarget.
void FlyEffect (object oPC, location lTarget)
{
    effect eFly = EffectDisappearAppear (lTarget, 1);
    effect eVis = EffectVisualEffect (VFX_IMP_PULSE_WIND);
    ClearAllActions ();
    // Face the direction you will be flying to
    AssignCommand (oPC, SetFacingPoint (GetPositionFromLocation (lTarget)));
    // Give a wind effect.
    DelayCommand (0.75f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVis, oPC));
    // Fly up off of the screen.
    ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eFly, oPC, 4.0f);
}

// Will move an object for special effects.
// fX moves the object in the x axis.
// fY moves the object in the y axis.
// fZ moves the object in the z axis (+up and -down).
// nLerp the transform_lerp type Constatns: OBJECT_VISUAL_TRANSFORM_LERP_*
// fDuration is the duration of the lerp effect.
void MoveObject (object oObject, float fX = 0.0f, float fY = 0.0f, float fZ = 0.0f, int nLerp = OBJECT_VISUAL_TRANSFORM_LERP_NONE, float fDuration = 0.0f)
{
    if (fX != 0.0f) SetObjectVisualTransform (oObject, OBJECT_VISUAL_TRANSFORM_TRANSLATE_X, fX, nLerp, fDuration);
    if (fY != 0.0f) SetObjectVisualTransform (oObject, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y, fY, nLerp, fDuration);
    if (fZ != 0.0f) SetObjectVisualTransform (oObject, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fZ, nLerp, fDuration);
}

void AdjustMoonPhase (object oArea, object oPC)
{
    if (GetIsAreaAboveGround (oArea) && !GetIsAreaInterior (oArea))
    {
        if (!GetIsDay())
        {
            string sText;
            int nMoonColor;
            int nDay = GetCalendarDay ();
            switch (nDay)
            {
                case 1: case 2: case 3: case 4: nMoonColor = 0x000000; sText = "new moon"; break;
                case 5: case 6: case 7: nMoonColor = 0x111111; break;
                case 8: case 9: case 10: nMoonColor = 0x222222; break;
                case 11: case 12: case 13: nMoonColor = 0x333333; break;
                case 14: case 15: case 16: nMoonColor = 0x444444; sText = "full moon"; break;
                case 17: case 18: case 19: nMoonColor = 0x444444; sText = "full moon"; break;
                case 20: case 21: case 22: nMoonColor = 0x333333; break;
                case 23: case 24: case 25: nMoonColor = 0x222222; break;
                case 26: case 27: case 28: nMoonColor = 0x111111; break;
                default:
            }
            NWNX_Area_SetSunMoonColors (oArea, NWNX_AREA_COLOR_TYPE_MOON_AMBIENT, nMoonColor);
            if (sText != "") SendMessages ("Tonight is a " + sText + ".", COLOR_BLUE, oPC, FALSE, FALSE);
        }
        CheckWeather (oArea, oPC);
    }
}

void CheckWeather (object oArea, object oPC)
{
    int nVolume;
    int nSpotAdj, nMinTemp, nMaxTemp, nChange, nChance, nAmbientSound = -1, nMultiplier, nRoll;
    string sTemp, sTextColor, sMonth, sSuffix;
    object oModule = GetModule ();
    vector vDirection;
    // Get DMWeather 0)Random 1)Clear 2)Snow 3)Rain 4)Storm
    int nDMWeather = GetLocalInt (oModule, "0_DMWeather");
    // Get the weather information.
    int nTemp = GetServerDatabaseInt (oModule, SERVER_TABLE, "temperature");
    int nPrecipitation = GetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation");
    int nStorm = GetServerDatabaseInt (oModule, SERVER_TABLE, "storm");
    float fWindx = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windx");
    float fWindy = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windy");
    float fWindz = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windz");
    float fWindMagnitude = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude");
    float fWindYaw = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windyaw");
    float fWindPitch = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windpitch");
    int nMonth = GetCalendarMonth ();
    // Get the minimum and maximum temps by month as well as name.
    // nMultiplier is multiplied by the chance to have precipitation, storms, and winds.
    /*/ This is the temps for the Frostmaiden event!
    switch (nMonth)
    {
        case 1:   {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 1; sMonth = "Hammer";    break;} // Jan
        case 2:   {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 1; sMonth = "Alturiak";  break;} // Feb
        case 3:   {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 2; sMonth = "Ches";      break;} // March  (Spring)
        case 4:   {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 2; sMonth = "Tarsakh";   break;} // April
        case 5:   {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 3; sMonth = "Mirtul";    break;} // May
        case 6:   {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 4; sMonth = "Kythorn";   break;} // Jun   (Summer)
        case 7:   {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 2; sMonth = "Flamerule"; break;} // July
        case 8:   {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 2; sMonth = "Eleasis";   break;} // August
        case 9:   {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 3; sMonth = "Eleint";    break;} // Sept  (Autumn)
        case 10:  {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 3; sMonth = "Marpenoth"; break;} // Oct
        case 11:  {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 1; sMonth = "Uktar";     break;} // Nov
        case 12:  {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 1; sMonth = "Nightal";   break;} // Dec   (Winter)
        default : {nMinTemp = 5; nMaxTemp = 26; nMultiplier = 1; sMonth = "";          break;}
    } */
    // This is the normal temps for the server.
    switch (nMonth)
    {
        case 1:   {nMinTemp = 15; nMaxTemp = 71; nMultiplier = 1; sMonth = "Hammer";    break;} // Jan
        case 2:   {nMinTemp = 15; nMaxTemp = 71; nMultiplier = 1; sMonth = "Alturiak";  break;} // Feb
        case 3:   {nMinTemp = 42; nMaxTemp = 78; nMultiplier = 2; sMonth = "Ches";      break;} // March  (Spring)
        case 4:   {nMinTemp = 43; nMaxTemp = 79; nMultiplier = 2; sMonth = "Tarsakh";   break;} // April
        case 5:   {nMinTemp = 43; nMaxTemp = 79; nMultiplier = 3; sMonth = "Mirtul";    break;} // May
        case 6:   {nMinTemp = 70; nMaxTemp = 86; nMultiplier = 4; sMonth = "Kythorn";   break;} // Jun   (Summer)
        case 7:   {nMinTemp = 70; nMaxTemp = 86; nMultiplier = 2; sMonth = "Flamerule"; break;} // July
        case 8:   {nMinTemp = 70; nMaxTemp = 86; nMultiplier = 2; sMonth = "Eleasis";   break;} // August
        case 9:   {nMinTemp = 43; nMaxTemp = 79; nMultiplier = 3; sMonth = "Eleint";    break;} // Sept  (Autumn)
        case 10:  {nMinTemp = 42; nMaxTemp = 78; nMultiplier = 3; sMonth = "Marpenoth"; break;} // Oct
        case 11:  {nMinTemp = 42; nMaxTemp = 78; nMultiplier = 1; sMonth = "Uktar";     break;} // Nov
        case 12:  {nMinTemp = 15; nMaxTemp = 71; nMultiplier = 1; sMonth = "Nightal";   break;} // Dec   (Winter)
        default : {nMinTemp = 40; nMaxTemp = 80; nMultiplier = 1; sMonth = "";          break;}
    }
    // Make roll to check for temepature and weather changes.
    if (d100() >= 90 && nDMWeather == 0)
    {
        nChange = d10();
        // Check chance that the temp goes down, Spring Summer 50% / Fall Winter 75%.
        if (nMonth > 2 && nMonth < 9) nChance = 50;
        else nChance = 75;
        // Adjust the temp.
        if (d100() > nChance) { nTemp = nTemp - nChange; } //bDown = TRUE;}
        else nTemp = nTemp + nChange;
        // Cap the temps.
        if (nTemp > nMaxTemp) nTemp = nMaxTemp;
        else if (nTemp < nMinTemp) nTemp = nMinTemp;
        SetServerDatabaseInt (oModule, SERVER_TABLE, "temperature", nTemp);
        //Debug ("0i_effects", "238", "Temp [" + IntToString (nTemp) + " ] Change: -" + IntToString (nChange));
        //else //Debug ("0i_effects", "238", "Temp [" + IntToString (nTemp) + " ] Change: +" + IntToString (nChange));
        if (nPrecipitation == 0)
        {
            // Check for precipitation 2% to 50% (avg: 15%).
            if (d100() <= (nChange * (nMultiplier + 1)))
            {
                // Calculate the precipitation duration based on area transitions.
                nPrecipitation = GetCurrentDateTimeInMinutes () + (d10() + 5);
                SetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation", nPrecipitation);
                // Check for a storm 0% to 32% Avg: 6%).
                if (d100() <= ((nChange - 2) * nMultiplier))
                {
                    nStorm = nPrecipitation;
                    SetServerDatabaseInt (oModule, SERVER_TABLE, "storm", nStorm);
                    // Winds of 1.5 to 3.0 magnitude (Moderate to Heavy).
                    fWindMagnitude = IntToFloat (Random (151) + 150) / 100.0f;
                    SetWind (fWindMagnitude);
                }
            }
        }
        // Check for wind changes.
        if (fWindMagnitude == 0.0f)
        {
            // Check for wind 2% to 50% avg: 15% with magnitude of 1.0 to 2.0
            if (d100() <= (nChange * (nMultiplier + 1)))
            {
                fWindMagnitude = IntToFloat (Random (100) + 100) / 100.0f;
                SetWind (fWindMagnitude);
            }
        }
    }
    else if (fWindMagnitude > 0.0f && nDMWeather == 0)
    {
        // Chance the wind dies down.
        if (d100 () < 26 && nStorm == 0)
        {
            fWindMagnitude = fWindMagnitude - 0.2f;
            if (fWindMagnitude < 0.1f) SetWind (0.0f, TRUE);
            else SetWind (fWindMagnitude, TRUE);
        }
    }
    // Check for precipitation and set the area.
    // DMWeather 0)Random 1)Clear 2)Snow 3)Rain 4)Storm
    if (nPrecipitation > GetCurrentDateTimeInMinutes () || nDMWeather > 1)
    {
        // Check the temp to see if it is snowing or raining.
        if (nTemp <= 32 || nDMWeather == 3)
        {
            NWNX_Area_SetWeatherChance (oArea, NWNX_AREA_WEATHER_CHANCE_LIGHTNING, 0);
            SetWeather (oArea, WEATHER_SNOW);
            nSpotAdj = -2;
            if (fWindMagnitude < 1.0f) -1;
            else nAmbientSound = -1;
        }
        else
        {
            // Add storm effects if we are in a storm.
            SetWeather (oArea, WEATHER_RAIN);
            if (nStorm > 0 || nDMWeather == 4)
            {
                NWNX_Area_SetWeatherChance (oArea, NWNX_AREA_WEATHER_CHANCE_LIGHTNING, 100);
                nAmbientSound = -1;
                SetSkyBox (SKYBOX_GRASS_STORM, oArea);
                nSpotAdj = -6;
                nVolume = 100;
            }
            else
            {
                // -1 to 4 to spot checks when in rain.
                nAmbientSound = -1;
                nSpotAdj = d4() * -1;
            }
        }
    }
    else
    {
        if (nPrecipitation > 0 || nDMWeather == 1)
        {
            nPrecipitation = 0;
            SetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation", 0);
            if (nStorm > 0)
            {
                nStorm = 0;
                SetServerDatabaseInt (oModule, SERVER_TABLE, "storm", 0);
                NWNX_Area_SetWeatherChance (oArea, NWNX_AREA_WEATHER_CHANCE_LIGHTNING, 0);
                SetSkyBox (SKYBOX_GRASS_CLEAR, oArea);
                fWindMagnitude = fWindMagnitude - 1.5f;
                //fWindYaw = fWindYaw - 115.0f;
                //fWindPitch = fWindPitch - 3.75f;
            }
            SetWeather (oArea, WEATHER_CLEAR);
        }
        // Check for sound changes based on wind.
        if (fWindMagnitude > 2.49f) nAmbientSound = AMBIENT_SOUND_WIND_STRONG;
        else if (fWindMagnitude > 1.99f) nAmbientSound = AMBIENT_SOUND_WIND_MEDIUM;
        else if (fWindMagnitude > 1.49f) nAmbientSound = AMBIENT_SOUND_WIND_SOFT;
        else nAmbientSound = -1;
        nVolume = 50;
    }
    //Debug ("0i_effects", "314", "WindMag: " + FloatToString (fWindMagnitude, 0, 1));
    //Debug ("0i_effects", "315", "Windx: " + FloatToString (fWindx, 0, 1));
    //Debug ("0i_effects", "316", "Windy: " + FloatToString (fWindy, 0, 1));
    //Debug ("0i_effects", "317", "WindYaw: " + FloatToString (fWindYaw, 0, 1));
    //Debug ("0i_effects", "318", "WindPitch: " + FloatToString (fWindPitch, 0, 1));
    //Debug ("0i_effects", "319", "Precipitation: " + IntToString (nPrecipitation) + " Storm: " + IntToString (nStorm));
    //Debug ("0i_effects", "320", "CurrentDateTimeInSeconds: " + IntToString (GetCurrentDateTimeInMinutes ()));
    vDirection = Vector (fWindx, fWindy, 0.0f);
    SetAreaWind (oArea, vDirection, fWindMagnitude, fWindYaw, fWindPitch);
    if (nAmbientSound > -1)
    {
        if (GetIsDay ())
        {
            AmbientSoundChangeDay (oArea, nAmbientSound);
            AmbientSoundSetDayVolume (oArea, nVolume);
        }
        else
        {
            AmbientSoundChangeNight (oArea, nAmbientSound);
            AmbientSoundSetNightVolume (oArea, nVolume);
        }
        AmbientSoundPlay (oArea);
    }
    else
    {
        AmbientSoundChangeDay (oArea, GetLocalInt (oArea, "0_AmbientDaySound"));
        AmbientSoundChangeNight (oArea, GetLocalInt (oArea, "0_AmbientNightSound"));
    }
    if (nPrecipitation == 0)
    {
        if (GetIsDay ())
        {
            nAmbientSound = GetLocalInt (oArea, "0_AmbientDaySound");
            if (nAmbientSound > 0) AmbientSoundChangeDay (oArea, nAmbientSound);
            AmbientSoundSetDayVolume (oArea, 50);
        }
        else
        {
            nAmbientSound = GetLocalInt (oArea, "0_AmbientNightSound");
            if (nAmbientSound > 0) AmbientSoundChangeNight (oArea, nAmbientSound);
            AmbientSoundSetNightVolume (oArea, 50);
        }
        AmbientSoundPlay (oArea);
    }
    int nListenAdj = FloatToInt (fWindMagnitude * 3.0f) * -1;
    NWNX_Area_SetAreaListenModifier (oArea, nListenAdj);
    NWNX_Area_SetAreaSpotModifier (oArea, nSpotAdj);
    // Give weather description.
    int nCurrentTime = GetTimeHour ();
    if (GetLocalInt (oModule, "0_LastWeatherCheck") != nCurrentTime)
    {
        SetLocalInt (oModule, "0_LastWeatherCheck", nCurrentTime);
        if (nTemp <= 15) { sTemp = "subfreezing!"; sTextColor = COLOR_DARK_BLUE; }
        else if (nTemp <= 30) { sTemp = "freezing."; sTextColor = COLOR_BLUE; }
        else if (nTemp <= 50) { sTemp = "cold."; sTextColor = COLOR_BLUE; }
        else if (nTemp <= 70) { sTemp = "cool."; sTextColor = COLOR_GREEN; }
        else if (nTemp <= 75) { sTemp = "warm."; sTextColor = COLOR_GREEN; }
        else if (nTemp <= 85) { sTemp = "hot."; sTextColor = COLOR_RED; }
        else { sTemp = "very hot."; sTextColor = COLOR_RED; }
        int nCurrentDay = GetCalendarDay ();
        switch (nCurrentDay)
        {
            case 1:  case 21: case 31: sSuffix = "st"; break;
            case 2:  case 22: case 32: sSuffix = "nd"; break;
            case 3:  case 23: case 33: sSuffix = "rd"; break;
            default : sSuffix = "th"; break;
        }
        // Let the DM's know the actual temp but give players a description.
        if (GetIsDungeonMaster (oPC)) SendMessages ("For the " + IntToString (nCurrentDay) + sSuffix + " day of " + sMonth + " it is " + sTemp + " (" + IntToString (nTemp) + ").", sTextColor, oPC, FALSE, FALSE);
        else SendMessages ("For the " + IntToString (nCurrentDay) + sSuffix + " day of " + sMonth + " it is " + sTemp, sTextColor, oPC, FALSE, FALSE);
    }
}
// fWindMagnitude is the power of the wind 0.0f to 3.0f should be followed.
// bKeepDirection True will not change the winds direction. False randomizes it.
void SetWind (float fWindMagnitude, int bKeepDirection = FALSE)
{
    object oModule = GetModule ();
    if (!bKeepDirection)
    {
        int nRoll = d4();
        float fWindx, fWindy;
        if (nRoll == 1)
        {
            fWindx = 1.0f;
            fWindy = (IntToFloat (Random (200)) - 100.0f) / 100.0f;
        }
        else if (nRoll == 2)
        {
            fWindx = -1.0f;
            fWindy = (IntToFloat (Random (200)) - 100.0f) / 100.0f;
        }
        else if (nRoll == 3)
        {
            fWindx = (IntToFloat (Random (200)) - 100.0f) / 100.0f;
            fWindy = 1.0f;
        }
        else
        {
            fWindx = (IntToFloat (Random (200)) - 100.0f) / 100.0f;
            fWindy = -1.0f;
        }
        SetServerDatabaseFloat (oModule, SERVER_TABLE, "windx", fWindx);
        SetServerDatabaseFloat (oModule, SERVER_TABLE, "windy", fWindy);
    }
    float fWindYaw = fWindMagnitude * 100.0f;
    float fWindPitch = fWindMagnitude * 3.0f;
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude", fWindMagnitude);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windyaw", fWindYaw);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windpitch", fWindPitch);
}
// Used to delay the creation of an object for effect.
// Use the DelayCommand (0.0f, DelayCreateObject (); to get a delayed object.
void DelayCreateObject (int iObjectType, string sResRef, location lLocation)
{
    // Create the object with the temp tag so we can clean it up.
    CreateObject (iObjectType, sResRef, lLocation, FALSE, "00_temp_placeable");
}
// Remove Effect of type specified from oCreature;
// iEffect is EFFECT_TYPE_*
void RemoveASpecificEffect (object oCreature, int iEffect)
{
   effect eEffect = GetFirstEffect(oCreature);
   //Search for the effect.
   while(GetIsEffectValid(eEffect))
   {
      if (GetEffectType(eEffect) == iEffect)
      {
         //Remove effect.
         RemoveEffect(oCreature, eEffect);
         eEffect = GetFirstEffect(oCreature);
      }
      else  eEffect = GetNextEffect(oCreature);
   }
}
// Remove Effect of type specified from oCreature;
// sEffectTag is the tag of the effect to remove.
// Base tags are Feat, Class, Racial.
void RemoveTagedEffects (object oCreature, string sEffectTag)
{
   //Search for the effect.
   //Debug ("0i_effects", "578", "RemoveTagedEffects: " + sEffectTag);
   effect eEffect = GetFirstEffect (oCreature);
   while (GetIsEffectValid (eEffect))
   {
      //Debug ("0i_effects", "582", "Effect Tag: " + GetEffectTag (eEffect));
      if (GetEffectTag (eEffect) == sEffectTag) RemoveEffect (oCreature, eEffect);
      eEffect = GetNextEffect (oCreature);
   }
}
// Checks for bad effects only.
int GetIsEffectTypeBad (effect eEffect)
{
    // These spell effects are good.
    if (GetEffectSpellId (eEffect) == SPELL_MAGE_ARMOR) return FALSE;
    int iEffectType = GetEffectType (eEffect);
    // Check these bad effects.
    return ((iEffectType == EFFECT_TYPE_ABILITY_DECREASE) ||
            (iEffectType == EFFECT_TYPE_AC_DECREASE) ||
            (iEffectType == EFFECT_TYPE_ARCANE_SPELL_FAILURE) ||
            (iEffectType == EFFECT_TYPE_ATTACK_DECREASE) ||
            (iEffectType == EFFECT_TYPE_BLINDNESS) ||
            (iEffectType == EFFECT_TYPE_CHARMED) ||
            (iEffectType == EFFECT_TYPE_CONFUSED) ||
            (iEffectType == EFFECT_TYPE_CURSE) ||
            (iEffectType == EFFECT_TYPE_CUTSCENE_PARALYZE) ||
            (iEffectType == EFFECT_TYPE_CUTSCENEGHOST) ||
            (iEffectType == EFFECT_TYPE_CUTSCENEIMMOBILIZE) ||
            (iEffectType == EFFECT_TYPE_DAMAGE_DECREASE) ||
            (iEffectType == EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE) ||
            (iEffectType == EFFECT_TYPE_DARKNESS) ||
            (iEffectType == EFFECT_TYPE_DAZED) ||
            (iEffectType == EFFECT_TYPE_DEAF) ||
            (iEffectType == EFFECT_TYPE_DISEASE) ||
            (iEffectType == EFFECT_TYPE_DOMINATED) ||
            (iEffectType == EFFECT_TYPE_ENTANGLE) ||
            (iEffectType == EFFECT_TYPE_FRIGHTENED) ||
            (iEffectType == EFFECT_TYPE_MOVEMENT_SPEED_DECREASE) ||
            (iEffectType == EFFECT_TYPE_NEGATIVELEVEL) ||
            (iEffectType == EFFECT_TYPE_PARALYZE) ||
            (iEffectType == EFFECT_TYPE_PETRIFY) ||
            (iEffectType == EFFECT_TYPE_POISON) ||
            (iEffectType == EFFECT_TYPE_POLYMORPH) ||
            (iEffectType == EFFECT_TYPE_SAVING_THROW_DECREASE) ||
            (iEffectType == EFFECT_TYPE_SILENCE) ||
            (iEffectType == EFFECT_TYPE_SKILL_DECREASE) ||
            (iEffectType == EFFECT_TYPE_SLEEP) ||
            (iEffectType == EFFECT_TYPE_SLOW) ||
            (iEffectType == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE) ||
            (iEffectType == EFFECT_TYPE_STUNNED)    ||
            (iEffectType == EFFECT_TYPE_SWARM)  ||
            (iEffectType == EFFECT_TYPE_TURNED) ||
            (iEffectType == EFFECT_TYPE_TURN_RESISTANCE_DECREASE)
            );
}

// Checks for good effects only.
int GetIsEffectTypeGood (effect eEffect)
{
    // These spell effects are good.
    if (GetEffectSpellId (eEffect) == SPELL_MAGE_ARMOR) return TRUE;
    int iEffectType = GetEffectType (eEffect);
    // Check these good effects.
    return ((iEffectType == EFFECT_TYPE_ABILITY_INCREASE) ||
            (iEffectType == EFFECT_TYPE_AC_INCREASE) ||
            (iEffectType == EFFECT_TYPE_ATTACK_INCREASE) ||
            (iEffectType == EFFECT_TYPE_CONCEALMENT) ||
            (iEffectType == EFFECT_TYPE_DAMAGE_INCREASE) ||
            (iEffectType == EFFECT_TYPE_DAMAGE_REDUCTION) ||
            (iEffectType == EFFECT_TYPE_DAMAGE_RESISTANCE) ||
            (iEffectType == EFFECT_TYPE_ELEMENTALSHIELD) ||
            (iEffectType == EFFECT_TYPE_ETHEREAL) ||
            (iEffectType == EFFECT_TYPE_IMPROVEDINVISIBILITY) ||
            (iEffectType == EFFECT_TYPE_HASTE) ||
            (iEffectType == EFFECT_TYPE_INVISIBILITY) ||
            (iEffectType == EFFECT_TYPE_INVULNERABLE) ||
            (iEffectType == EFFECT_TYPE_MOVEMENT_SPEED_INCREASE) ||
            (iEffectType == EFFECT_TYPE_REGENERATE) ||
            (iEffectType == EFFECT_TYPE_SANCTUARY) ||
            (iEffectType == EFFECT_TYPE_SAVING_THROW_INCREASE) ||
            (iEffectType == EFFECT_TYPE_SEEINVISIBLE) ||
            (iEffectType == EFFECT_TYPE_SKILL_INCREASE) ||
            (iEffectType == EFFECT_TYPE_SPELL_IMMUNITY) ||
            (iEffectType == EFFECT_TYPE_SPELL_RESISTANCE_INCREASE) ||
            (iEffectType == EFFECT_TYPE_SPELLLEVELABSORPTION)   ||
            (iEffectType == EFFECT_TYPE_TEMPORARY_HITPOINTS) ||
            (iEffectType == EFFECT_TYPE_TRUESEEING) ||
            (iEffectType == EFFECT_TYPE_TURN_RESISTANCE_INCREASE)
            );
}
// oCreature the effects are to be removed from.
// bResting if these effects are being removed due to resting.
void CheckSpellEffectsForRemoval (object oCreature, int bResting = FALSE)
{
    //if (!GetHasSpellEffect (902 /*SPELL_ENLARGE_PERSON*/, oCreature)) ChangeSize (oCreature, 1.0f);
    RemoveBardSongEffects(oCreature);
    object oToken = GetCreatureHasItem(oCreature, "0_fly_token");
    if(GetIsObjectValid(oToken)) DestroyObject(oToken);
    ExecuteScript("0s_tenstrans_r", oCreature);
}
// Removes effects All, Bad, or Good effects from a creature.
// Any effects Tagged "Permanent", "Class", or "Racial" will never be removed.
// nEffectType can be 0 - All, 1 - Bad Effects only, 2 - Good Effects only.
// nEffectTypeKeep will not remove a specific effect if desired.
// nEffectSubTypeKeep will not remove a subtype of the effect (Extraordinary, Magical, SuperNatural).
// Permanent, Class, and Racial effects are not removed.
void RemoveCreatureEffects(object oCreature, int nEffectGroup = 0, int nEffectTypeKeep = EFFECT_TYPE_INVALIDEFFECT, int nEffectSubTypeKeep = 0)
{
    string sAppearanceArray, sEffectTag;
    effect eEffect = GetFirstEffect(oCreature);
    int nEye, nEffectType, nEffectSubType, nRemoveEffect = FALSE;
    // For each effect
    while(GetIsEffectValid(eEffect))
    {
        // Get the Type of effect.
        nEffectType = GetEffectType(eEffect, TRUE);
        // Get the SubType of the effect.
        nEffectSubType = GetEffectSubType(eEffect);
        // Remove all effects.
        // Check for the SubType
        if(nEffectSubType != nEffectSubTypeKeep)
        {
            // Check for a specific effect.
            if(nEffectTypeKeep != nEffectType)
            {
                switch(nEffectGroup)
                {
                    // Remove all effects.
                    case 0 :
                    {
                        RemoveEffect(oCreature, eEffect);
                        break;
                    }
                    // Remove bad effects.
                    case 1 :
                    {
                        if(GetIsEffectTypeBad(eEffect))
                        {
                            RemoveEffect(oCreature, eEffect);
                            break;
                        }
                    }
                    // Remove good effects.
                    case 2 :
                    {
                        if (GetIsEffectTypeGood(eEffect))
                        {
                            RemoveEffect(oCreature, eEffect);
                        }
                    }
                }
            }
        }
        eEffect = GetNextEffect(oCreature);
    }
    CheckSpellEffectsForRemoval (oCreature);
    // Reapply any open face visuals.
    object oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oCreature);
    int iBaseItemType = GetBaseItemType(oItem);
    if(iBaseItemType == BASE_ITEM_OPEN_FACE_HELMET) DoOpenFaceHelmetVisuals(oCreature, oItem);
    // Reapply any glowing eyes.
    if(GetIsCharacter(oCreature))
    {
        sAppearanceArray = GetObjectDatabaseString(oCreature, CHARACTER_TABLE, "appearance");
        nEye = StringToInt(GetStringArray(sAppearanceArray, 0));
        if(nEye > 0) ApplyGlowingEyes(nEye, oCreature);
    }
}

void ApplyVisEffectWithNewCreator(object oPC, int nVisual, string sTagEffect)
{
    // Get the visual translations from oObject.
    object oObject = OBJECT_SELF;
    json jVFX = GetLocalJson(oObject, "VFX_JSON");    
    float fScale;
    vector vTranslate, vRotate;
    if(JsonGetType(jVFX) == JSON_TYPE_NULL) 
    {
        jVFX = JsonObject();
        jVFX = JsonObjectSet(jVFX, "scale", JsonFloat(1.0));
        jVFX = JsonObjectSet(jVFX, "Translate_x", JsonFloat(0.0));
        jVFX = JsonObjectSet(jVFX, "Translate_y", JsonFloat(0.0));
        jVFX = JsonObjectSet(jVFX, "Translate_z", JsonFloat(0.0));
        jVFX = JsonObjectSet(jVFX, "Rotate_x", JsonFloat(0.0));
        jVFX = JsonObjectSet(jVFX, "Rotate_y", JsonFloat(0.0));
        jVFX = JsonObjectSet(jVFX, "Rotate_z", JsonFloat(0.0));
        SetLocalJson(oObject, "VFX_JSON", jVFX);
        fScale = 1.0;
        vTranslate = Vector(0.0, 0.0, 0.0);
        vRotate = Vector(0.0, 0.0, 0.0);
    }
    else 
    {
        fScale = JsonGetFloat(JsonObjectGet(jVFX, "scale"));
        if(fScale == 0.0) fScale = 1.0;
        vTranslate = Vector(JsonGetFloat(JsonObjectGet(jVFX, "Translate_x")),
                                JsonGetFloat(JsonObjectGet(jVFX, "Translate_y")), 
                                JsonGetFloat(JsonObjectGet(jVFX, "Translate_z")));
        vRotate = Vector(JsonGetFloat(JsonObjectGet(jVFX, "Rotate_x")),
                                JsonGetFloat(JsonObjectGet(jVFX, "Rotate_y")), 
                                JsonGetFloat(JsonObjectGet(jVFX, "Rotate_z")));
    }
    effect eEffect = EffectVisualEffect(nVisual, FALSE, fScale, vTranslate, vRotate);
    // Tag the effect permanent so we don't remove them on death and other places.
    eEffect = TagEffect(eEffect, sTagEffect);
    eEffect = UnyieldingEffect(eEffect);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oPC);
}

int GetOpenFaceVisualID(object oItem, object oCreature)
{
    int nVFX;
    int nGender = GetGender(oCreature);
    int nRace = GetRacialType(oCreature);
    int nItemApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
    // Adjust for new races.
    // Humans
    if(nRace > 29 && nRace < 36) nRace = RACIAL_TYPE_HUMAN;
    // Dwarves
    else if(nRace > 35 && nRace < 39) nRace = RACIAL_TYPE_DWARF;
    // Elves
    else if(nRace > 38 && nRace < 44) nRace = RACIAL_TYPE_ELF;
    // Gnomes
    else if(nRace > 43 && nRace < 47) nRace = RACIAL_TYPE_GNOME;
    // Halflings
    else if(nRace > 46 && nRace < 51) nRace = RACIAL_TYPE_HALFLING;
    // Half-elves
    else if(nRace > 50 && nRace < 56) nRace = RACIAL_TYPE_HALFELF;
    // Kobolds
    else if(nRace == 57) nRace = RACIAL_TYPE_HALFLING;
    // Orcs
    else if(nRace == 56 || nRace == 58 || nRace == 59) nRace = RACIAL_TYPE_HALFORC;
    // Outsiders
    else if(nRace > 59 && nRace < 66) nRace = RACIAL_TYPE_HUMAN;
    if(nItemApp < 31)
    {
        int nNewVfx = 12 * nItemApp;
        if(nGender == GENDER_FEMALE) nGender = 6;
        switch(nRace)
        {
            case RACIAL_TYPE_DWARF: nVFX = 1489 + nNewVfx + nGender; break;
            case RACIAL_TYPE_ELF: nVFX = 1490 + nNewVfx + nGender; break;
            case RACIAL_TYPE_GNOME: nVFX = 1491 + nNewVfx + nGender; break;
            case RACIAL_TYPE_HALFLING: nVFX = 1492 + nNewVfx + nGender; break;
            case RACIAL_TYPE_HALFORC: nVFX = 1493 + nNewVfx + nGender; break;
            case RACIAL_TYPE_HALFELF:
            case RACIAL_TYPE_HUMAN: nVFX = 1494 + nNewVfx + nGender; break;
        }
    }
    else
    {
        int nNewVfx = 24 * nItemApp;
        int nPheno = GetPhenoType(oCreature);
        // The large pheno is 2 but we need to make it 1 for calculations.
        if(nPheno == 2) nPheno = 1;
        // Female is 1 but we need to make it 2 for calculations.
        if(nGender == GENDER_FEMALE) nGender = 2;
        switch(nRace)
        {
            case RACIAL_TYPE_DWARF: nVFX = 1121 + nNewVfx + nGender + nPheno; break;
            case RACIAL_TYPE_ELF: nVFX = 1125 + nNewVfx + nGender + nPheno; break;
            case RACIAL_TYPE_GNOME: nVFX = 1129 + nNewVfx + nGender + nPheno; break;
            case RACIAL_TYPE_HALFLING: nVFX = 1133 + nNewVfx + nGender + nPheno; break;
            case RACIAL_TYPE_HALFORC: nVFX = 1137 + nNewVfx + nGender + nPheno; break;
            case RACIAL_TYPE_HALFELF:
            case RACIAL_TYPE_HUMAN: nVFX = 1117 + nNewVfx + nGender + nPheno; break;
        }
    }
    return nVFX;
}
// Applies oHelm vfx to oCreature that equiped oHelm.
void DoOpenFaceHelmetVisuals(object oCreature,object oHelm, int bReplace = FALSE)
{
    // OpenFaceHelm should be applied if the server is loaded or the server has been reset.
    //Debug ("0i_effects", "824", "Loaded: " + IntToString (GetLocalInt (oPC, "0_Character_Loaded")) +
    //       " Reset: " + IntToString (!GetLocalInt (oCreature, "0_Server_Not_Reset")));
    if(GetLocalInt (oCreature, "0_Character_Loaded") || !GetLocalInt (oCreature, "0_Server_Not_Reset"))
    {
        if(bReplace) RemoveTagedEffects(oCreature, "EFFECT_HELM");
        //Debug ("0i_effects", "822", "Adding helm effect!");
        int nVisual = GetOpenFaceVisualID(oHelm, oCreature);
        AssignCommand(oHelm, ApplyVisEffectWithNewCreator(oCreature, nVisual, "EFFECT_HELM"));
    }
    SetHiddenWhenEquipped(oHelm, TRUE);
}
int GetAccessoryVisualID(object oItem, object oCreature, int nVFX)
{
    int nGender = GetGender(oCreature);
    int nRace = GetRacialType(oCreature);
    int nItemApp = GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
    // Adjust for new races.
    // Humans
    if(nRace > 29 && nRace < 36) nRace = RACIAL_TYPE_HUMAN;
    // Dwarves
    else if(nRace > 35 && nRace < 39) nRace = RACIAL_TYPE_DWARF;
    // Elves
    else if(nRace > 38 && nRace < 44) nRace = RACIAL_TYPE_ELF;
    // Gnomes
    else if(nRace > 43 && nRace < 47) nRace = RACIAL_TYPE_GNOME;
    // Halflings
    else if(nRace > 46 && nRace < 51) nRace = RACIAL_TYPE_HALFLING;
    // Half-elves
    else if(nRace > 50 && nRace < 56) nRace = RACIAL_TYPE_HALFELF;
    // Kobolds
    else if(nRace == 57) nRace = RACIAL_TYPE_HALFLING;
    // Orcs
    else if(nRace == 56 || nRace == 58 || nRace == 59) nRace = RACIAL_TYPE_HALFORC;
    // Outsiders
    else if(nRace > 59 && nRace < 66) nRace = RACIAL_TYPE_HUMAN;
    int nNewVfx = 24 * nItemApp;
    int nPheno = GetPhenoType(oCreature);
    // The large pheno is 2 but we need to make it 1 for calculations.
    if(nPheno == 2) nPheno = 1;
    // Female is 1 but we need to make it 2 for calculations.
    if(nGender == GENDER_FEMALE) nGender = 2;
    switch(nRace)
    {
        case RACIAL_TYPE_DWARF: nVFX = nVFX + 4 + nNewVfx + nGender + nPheno; break;
        case RACIAL_TYPE_ELF: nVFX = nVFX + 8 + nNewVfx + nGender + nPheno; break;
        case RACIAL_TYPE_GNOME: nVFX = nVFX + 12 + nNewVfx + nGender + nPheno; break;
        case RACIAL_TYPE_HALFLING: nVFX = nVFX + 16 + nNewVfx + nGender + nPheno; break;
        case RACIAL_TYPE_HALFORC: nVFX = nVFX + 20 + nNewVfx + nGender + nPheno; break;
        case RACIAL_TYPE_HALFELF:
        case RACIAL_TYPE_HUMAN: nVFX = nVFX + nNewVfx + nGender + nPheno; break;
    }
    return nVFX;
}
// Applies oAccessory vfx to oCreature that used oAccessory.
void DoAccessoryVisuals(object oCreature, object oAccessory, int bReplace = FALSE, int bRemove = FALSE)
{
    int nVFX, nBaseItemType = GetBaseItemType(oAccessory);
    string sTag;
    if(nBaseItemType == 179/*ITEM_HEAD_ACCESSORY*/) { nVFX = 3205; sTag = "VFX_HEAD_" + GetResRef(oAccessory); }
    else if(nBaseItemType == 180/*ITEM_EYE_ACCESSORY*/) { nVFX = 3246; sTag = "VFX_EYES_" + GetResRef(oAccessory); }
    else if(nBaseItemType == 181/*ITEM_MOUTH_ACCESSORY*/) 
    { 
        if(!bReplace) AssignCommand(oCreature, ActionUnequipItem(oAccessory));
        nVFX = 3309; 
        sTag = "VFXMOUTH_" + GetResRef(oAccessory); 
    }
    else if(nBaseItemType == 182/*ITEM_BACK_ACCESSORY*/) { nVFX = 3326; sTag = "VFX_BACK_" + GetResRef(oAccessory); }
    else if(nBaseItemType == 183/*ITEM_SIDE_ACCESSORY*/) { nVFX = 3356; sTag = "VFX_SIDE_" + GetResRef(oAccessory); }
    int bHasEffect = HasEffectWithTag(oCreature, sTag);
    if(bHasEffect) 
    {
        RemoveTagedEffects(oCreature, sTag);
        if(!bReplace) DeleteLocalInt(oAccessory, "VFX_APPLIED");
    }
    if((!bHasEffect || bReplace) && !bRemove)
    {
        // Remove any effect that is already using the new effects slot.
        string sEffectTag;
        effect eVFX = GetFirstEffect(oCreature);
        while(GetIsEffectValid(eVFX))
        {
            sEffectTag = GetEffectTag(eVFX);
            if(GetStringLeft(sEffectTag, 9) == "VFX_HEAD_" && nBaseItemType == 179) RemoveEffect(oCreature, eVFX);
            else if(GetStringLeft(sEffectTag, 9) == "VFX_EYES_" && nBaseItemType == 180) RemoveEffect(oCreature, eVFX);
            else if(GetStringLeft(sEffectTag, 9) == "VFXMOUTH_" && nBaseItemType == 181) RemoveEffect(oCreature, eVFX);
            else if(GetStringLeft(sEffectTag, 9) == "VFX_BACK_" && nBaseItemType == 182) RemoveEffect(oCreature, eVFX);
            else if(GetStringLeft(sEffectTag, 9) == "VFX_SIDE_" && nBaseItemType == 183) RemoveEffect(oCreature, eVFX);
            eVFX = GetNextEffect(oCreature);
        }
        nVFX += GetItemAppearance(oAccessory, ITEM_APPR_TYPE_SIMPLE_MODEL, 0) - 1;
        if(bReplace) AssignCommand(oAccessory, ApplyVisEffectWithNewCreator(oCreature, nVFX, sTag));
        else DelayCommand(1.5, AssignCommand(oAccessory, ApplyVisEffectWithNewCreator(oCreature, nVFX, sTag)));
        SetLocalInt(oAccessory, "VFX_APPLIED", TRUE);
    }
}
// Put demonic appearances on PC if they have them.
// oPC is the pc to change.
// oItem is the armor to change.
// iAction is either 1 - Equip or 2 Unequip
void CheckDemonicAppearance (object oPC, object oItem, int iAction = 1)
{
    int iAppearance, iChange;
    object oItem2;
    // Check to see if we are already checking.
    if (GetLocalInt (oItem, "CheckingAppearance")) return;
    // See which action we are doing.
    if (iAction == 1)
    {
        // Check to see if they are a tiefling.
        if (GetRacialType (oPC) == 61)
        {
            // Now see if we need to give demonic legs.
            // Appearance Array is :Eyes:Legs:Claws:
            string sAppearanceArray = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "appearance");
            iAppearance = StringToInt (GetStringArray (sAppearanceArray, 1));
            // If appearance should change and the armor has not already been changed.
            if (iAppearance > 0 && GetLocalInt (oItem, "LSHIN") == 0)
            {
                // Lockout the script until we are done.
                SetLocalInt (oItem, "CheckingAppearance", TRUE);
                // Move armor to the crafting box.
                object oBox = GetObjectByTag (TEMP_CHEST);
                oItem2 = CopyItem (oItem, oBox, TRUE);
                DestroyObject (oItem);
                // Save the original armor information.
                int iLShin = GetItemAppearance (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHIN);
                SetLocalInt (oItem2, "LSHIN", iLShin);
                int iRShin = GetItemAppearance (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHIN);
                SetLocalInt (oItem2, "RSHIN", iRShin);
                int iLThigh = GetItemAppearance (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LTHIGH);
                SetLocalInt (oItem2, "LTHIGH", iLThigh);
                int iRThigh = GetItemAppearance (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RTHIGH);
                SetLocalInt (oItem2, "RTHIGH", iRThigh);
                int iLFoot = GetItemAppearance (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT);
                SetLocalInt (oItem2, "LFOOT", iLFoot);
                int iRFoot = GetItemAppearance (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT);
                SetLocalInt (oItem2, "RFOOT", iRFoot);
                // Change the armor.
                if (iLShin == 1) iChange = 117;
                else iChange = 116;
                oItem = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHIN, iChange, TRUE);
                DestroyObject (oItem2);
                if (iRShin == 1) iChange = 117;
                else iChange = 116;
                oItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHIN, iChange, TRUE);
                DestroyObject (oItem);
                // Sets the no armor model.
                if (iLThigh == 1 || iLThigh == 12) iChange = 117;
                else
                {
                    // Sets the light armor model.
                    if (iLThigh < 8) iChange = 116;
                    // Sets the heavy armor model.
                    else iChange = 118;
                }
                oItem = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LTHIGH, iChange, TRUE);
                DestroyObject (oItem2);
                // Sets the no armor model.
                if (iRThigh == 1 || iRThigh == 12) iChange = 117;
                else
                {
                    // Sets the light armor model.
                    if (iRThigh < 8) iChange = 116;
                    // Sets the heavy armor model.
                    else iChange = 118;
                }
                oItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RTHIGH, iChange, TRUE);
                DestroyObject (oItem);
                oItem = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT, iAppearance, TRUE);
                DestroyObject (oItem2);
                oItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT, iAppearance, TRUE);
                DestroyObject (oItem);
                // Reset to oItem for the rest of the script.
                oItem = oItem2;
            }
            // Now check to see if they have claws.
            // Set the player to have claws.
            iAppearance = StringToInt (GetStringArray (sAppearanceArray, 2));
            // If appearance should change and the armor has not already been changed.
            if (iAppearance > 0 && GetLocalInt (oItem, "LHAND") == 0)
            {
                // Lockout the script until we are done.
                SetLocalInt (oItem, "CheckingAppearance", TRUE);
                // if armor is not in box then move armor to the crafting box.
                object oBox = GetObjectByTag (TEMP_CHEST);
                if (GetItemPossessor (oItem) != oBox)
                {
                    oItem2 = CopyItem (oItem, oBox, TRUE);
                    DestroyObject (oItem);
                }
                // Save the original armor information.
                int iLHand = GetItemAppearance (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LHAND);
                SetLocalInt (oItem2, "LHAND", iLHand);
                int iRHand = GetItemAppearance (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RHAND);
                SetLocalInt (oItem2, "RHAND", iRHand);
                // Change the armor to show the hands.
                oItem = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LHAND, 1, TRUE);
                DestroyObject (oItem2);
                oItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RHAND, 1, TRUE);
                DestroyObject (oItem);
                // Reset to oItem for the rest of the script.
                oItem = oItem2;
            }
            // See if we need to copy item over and delete.
            if (GetLocalInt (oItem, "CheckingAppearance"))
            {
                // Copy item to the PC.
                oItem2 = CopyItem (oItem, oPC, TRUE);
                DestroyObject (oItem);
                // Equip the armor.
                DelayCommand (0.1f, AssignCommand(oPC, ActionEquipItem(oItem2, INVENTORY_SLOT_CHEST)));
                DelayCommand (0.2f, DeleteLocalInt (oItem2, "CheckingAppearance"));
            }
        }
    }
    else
    {
        // Check to see if they are a tiefling.
        if (GetRacialType (oPC) == 61)
        {
            // Now see if we need to remove demonic legs.
            if (GetLocalInt (oItem, "LSHIN") > 0)
            {
                // Lockout the script until we are done.
                SetLocalInt (oItem, "CheckingAppearance", TRUE);
                // Move armor to the crafting box.
                object oBox = GetObjectByTag (TEMP_CHEST);
                oItem2 = CopyItem (oItem, oBox, TRUE);
                DestroyObject (oItem);
                // Get the original armor information.
                // and change the armor.
                iAppearance = GetLocalInt (oItem2, "LSHIN");
                oItem = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LSHIN, iAppearance, TRUE);
                DestroyObject (oItem2);
                iAppearance = GetLocalInt (oItem, "RSHIN");
                oItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RSHIN, iAppearance, TRUE);
                DestroyObject (oItem);
                iAppearance = GetLocalInt (oItem2, "LTHIGH");
                oItem = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LTHIGH, iAppearance, TRUE);
                DestroyObject (oItem2);
                iAppearance = GetLocalInt (oItem, "RTHIGH");
                oItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RTHIGH, iAppearance, TRUE);
                DestroyObject (oItem);
                iAppearance = GetLocalInt (oItem2, "LFOOT");
                oItem = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LFOOT, iAppearance, TRUE);
                DestroyObject (oItem2);
                iAppearance = GetLocalInt (oItem, "RFOOT");
                oItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RFOOT, iAppearance, TRUE);
                DestroyObject (oItem);
                // Reset to oItem for the rest of the script.
                oItem = oItem2;
            }
            // Now see if we need to remove hand change.
            if (GetLocalInt (oItem, "LHAND") > 0)
            {
                // Lockout the script until we are done.
                SetLocalInt (oItem, "CheckingAppearance", TRUE);
                // if armor is not in box then move armor to the crafting box.
                object oBox = GetObjectByTag (TEMP_CHEST);
                if (GetItemPossessor (oItem) != oBox)
                {
                    oItem2 = CopyItem (oItem, oBox, TRUE);
                    DestroyObject (oItem);
                }
                // Get the original armor information.
                // and change the armor.
                iAppearance = GetLocalInt (oItem2, "LHAND");
                oItem = CopyItemAndModify (oItem2, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_LHAND, iAppearance, TRUE);
                DestroyObject (oItem2);
                iAppearance = GetLocalInt (oItem, "RHAND");
                oItem2 = CopyItemAndModify (oItem, ITEM_APPR_TYPE_ARMOR_MODEL, ITEM_APPR_ARMOR_MODEL_RHAND, iAppearance, TRUE);
                DestroyObject (oItem);
                // Reset to oItem for the rest of the script.
                oItem = oItem2;
            }
            // See if we need to copy item over and delete.
            if (GetLocalInt (oItem, "CheckingAppearance"))
            {
                // Copy item to the PC.
                oItem2 = CopyItem (oItem, oPC, TRUE);
                DestroyObject (oItem);
                // Destroy local variables.
                DeleteLocalInt (oItem2, "LSHIN");
                DeleteLocalInt (oItem2, "RSHIN");
                DeleteLocalInt (oItem2, "LTHIGH");
                DeleteLocalInt (oItem2, "RTHIGH");
                DeleteLocalInt (oItem2, "LFOOT");
                DeleteLocalInt (oItem2, "RFOOT");
                DeleteLocalInt (oItem2, "LHAND");
                DeleteLocalInt (oItem2, "RHAND");
                DeleteLocalInt (oItem2, "CheckingAppearance");
            }
        }
    }
}

// Applies the glowing eyes effect on a creature.
// oCreature is the creature to put the effect on.
// iFX is the Color and effect required.
// 0:None 1:Red flaming 2:Green 3:Yellow flaming
// 4:Cyan 5:Orange 6:Purple 7:White 8:Yellow
void ApplyGlowingEyes(int iFX, object oCreature)
{
  int iGender = GetGender(oCreature);
  int iRace = GetAppearanceType(oCreature);
  switch(iRace)
  {//-- this will make the races translate to proper advances on the fx constants.  trust me.
    // Dwarves
    case 0:
    case 36:
    case 37:
    case 38: iRace = 2; break;
    // Elves
    case 1:
    case 39:
    case 40:
    case 41:
    case 42:
    case 43: iRace = 4; break;
    // Gnomes
    case 2:
    case 44:
    case 45:
    case 46: iRace = 6; break;
    // Halflings
    case 3:
    case 47:
    case 48:
    case 49:
    case 50: iRace = 8; break;
    // Orcs
    case 5:
    case 58:
    case 59: iRace = 10; break;
    // All others, Human, Half-elves, Outsiders.
    default: iRace = 0; break;
  }

  switch (iFX)
  {
  // Red flaming eyes.
  case 1:
    {
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_VISUALEFFECT);
        effect eEyes = SupernaturalEffect(EffectVisualEffect( VFX_EYES_RED_FLAME_HUMAN_MALE + iGender + iRace));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEyes, oCreature);
        break;
    }
    // Green eyes.
  case 2:
    {
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_VISUALEFFECT);
        effect eEyes = SupernaturalEffect(EffectVisualEffect( VFX_EYES_GREEN_HUMAN_MALE + iGender + iRace));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEyes, oCreature);
        break;
    }
    // yellow flaming eyes.
  case 3:
    {
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_VISUALEFFECT);
        effect eEyes1 = SupernaturalEffect(EffectVisualEffect( VFX_EYES_GREEN_HUMAN_MALE + iGender + iRace));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEyes1, oCreature);
        effect eEyes2 = SupernaturalEffect(EffectVisualEffect( VFX_EYES_RED_FLAME_HUMAN_MALE + iGender + iRace));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEyes2, oCreature);
        break;
    }
    // Cyan colored eyes.
  case 4:
    {
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_VISUALEFFECT);
        effect eEyes = SupernaturalEffect(EffectVisualEffect( VFX_EYES_CYN_HUMAN_MALE + iGender + iRace));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEyes, oCreature);
        break;
    }
    // Orange colored eyes.
  case 5:
    {
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_VISUALEFFECT);
        effect eEyes = SupernaturalEffect(EffectVisualEffect( VFX_EYES_ORG_HUMAN_MALE + iGender + iRace));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEyes, oCreature);
        break;
    }
    // Purple colored eyes.
  case 6:
    {
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_VISUALEFFECT);
        effect eEyes = SupernaturalEffect(EffectVisualEffect( VFX_EYES_PUR_HUMAN_MALE + iGender + iRace));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEyes, oCreature);
        break;
    }
    // White colored eyes.
  case 7:
    {
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_VISUALEFFECT);
        effect eEyes = SupernaturalEffect(EffectVisualEffect( VFX_EYES_WHT_HUMAN_MALE + iGender + iRace));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEyes, oCreature);
        break;
    }
    // Yellow colored eyes.
  case 8:
    {
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_VISUALEFFECT);
        effect eEyes = SupernaturalEffect(EffectVisualEffect( VFX_EYES_YEL_HUMAN_MALE + iGender + iRace));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEyes, oCreature);
        break;
    }
  case 0:
    {
        RemoveASpecificEffect (oCreature, EFFECT_TYPE_VISUALEFFECT);
        break;
    }
  }
}

// Checks feats for equiping and unequiping weapons.
// oCreature is the creature equiping or unequiping.
// oItem is the item being equiped.
// iEquip tells if we are equiping or unequiping.
void CheckEquipWeaponFeats (object oCreature, object oItem, int bEquip = TRUE)
{
    if(GetHasFeat(FEAT_2_HAND_WEAPON_STYLE, oCreature))
    {
        if(GetIsTwoHandedWeapon(oItem, oCreature) && bEquip)
        {
            int nWeaponDmg, nDmgBonus;
            // Do they have Greater 2H weapon specialization?
            if(GetHasFeat(FEAT_GREATER_2_HAND_WEAPON_STYLE, oCreature)) nDmgBonus = DAMAGE_BONUS_4;
            else nDmgBonus = DAMAGE_BONUS_2;
            // Get Weapon damage.
            if(GetIsPiercingWeapon(oItem)) nWeaponDmg = DAMAGE_TYPE_PIERCING;
            else if(GetIsSlashingWeapon(oItem)) nWeaponDmg = DAMAGE_TYPE_SLASHING;
            else nWeaponDmg = DAMAGE_TYPE_BLUDGEONING;
            CreateFeatEffect(oCreature, EffectDamageIncrease(nDmgBonus, nWeaponDmg), "FEAT_2_HAND_WEAPON_STYLE");
        }
        else RemoveTagedEffects(oCreature, "FEAT_2_HAND_WEAPON_STYLE");
    }
    if(GetHasFeat(FEAT_1_HAND_WEAPON_STYLE, oCreature))
    {
        // Cannot have anything in the left hand.
        if(GetIsSingleHandedWeapon(oItem, oCreature) &&
           GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature) == OBJECT_INVALID && bEquip)
        {
            int nBaseType, nBonus;
            // Do they have Greater 1 handed weapon style?
            if(GetHasFeat(FEAT_GREATER_1_HAND_WEAPON_STYLE, oCreature)) nBonus = 4;
            else nBonus = 2;
            // Get Effect.
            effect eEffect = EffectSkillIncrease(SKILL_PARRY, nBonus + 2);
            effect eEffect2 = EffectACIncrease(nBonus, AC_DODGE_BONUS, DAMAGE_TYPE_PIERCING);
            CreateFeatEffect(oCreature, EffectLinkEffects(eEffect, eEffect2), "FEAT_1_HAND_WEAPON_STYLE");
        }
        else RemoveTagedEffects(oCreature, "FEAT_1_HAND_WEAPON_STYLE");
    }
    if (GetHasFeat (FEAT_SWORD_SHIELD_STYLE, oCreature))
    {
        // They must have a shield.
        if(GetIsSingleHandedWeapon(oItem, oCreature) &&
           GetIsShield(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature)) && bEquip)
        {
            int nBonus;
            // Do they have Improved sword and shield?
            if(GetHasFeat(FEAT_IMPROVED_SWORD_SHIELD_STYLE, oCreature)) nBonus = 4;
            else nBonus = 2;
            // Get Effect.
            effect eEffect = EffectACIncrease(nBonus, AC_DODGE_BONUS, DAMAGE_TYPE_SLASHING);
            effect eEffect2 = EffectACIncrease(nBonus, AC_DODGE_BONUS, DAMAGE_TYPE_BLUDGEONING);
            CreateFeatEffect(oCreature, EffectLinkEffects(eEffect, eEffect2), "FEAT_SWORD_AND_SHIELD_STYLE");
        }
        else RemoveTagedEffects(oCreature, "FEAT_SWORD_AND_SHIELD_STYLE");
    }
    if(GetHasFeat(FEAT_INSIGHTFUL_STRIKE, oCreature))
    {
        if(GetIsFinesseWeapon(oItem) && bEquip)
        {
            // Get the Int of the character.
            int nWeaponDmg, nIntMod = GetAbilityModifier (ABILITY_INTELLIGENCE, oCreature);
            // Get the Damage Bonus const, minimum of 1.
            if (nIntMod < 2) nIntMod = DAMAGE_BONUS_1;
            else if (nIntMod == 2) nIntMod = DAMAGE_BONUS_2;
            else if (nIntMod == 3) nIntMod = DAMAGE_BONUS_3;
            else if (nIntMod == 4) nIntMod = DAMAGE_BONUS_4;
            else if (nIntMod == 5) nIntMod = DAMAGE_BONUS_5;
            else if (nIntMod == 6) nIntMod = DAMAGE_BONUS_6;
            else if (nIntMod == 7) nIntMod = DAMAGE_BONUS_7;
            else if (nIntMod == 8) nIntMod = DAMAGE_BONUS_8;
            else if (nIntMod == 9) nIntMod = DAMAGE_BONUS_9;
            else nIntMod = DAMAGE_BONUS_10;
            // Get Weapon damage.
            if(GetIsPiercingWeapon(oItem)) nWeaponDmg = DAMAGE_TYPE_PIERCING;
            else if(GetIsSlashingWeapon(oItem)) nWeaponDmg = DAMAGE_TYPE_SLASHING;
            else nWeaponDmg = DAMAGE_TYPE_BLUDGEONING;
            CreateFeatEffect(oCreature, EffectDamageIncrease(nIntMod, nWeaponDmg), "FEAT_INSIGHTFULL_STRIKE");
        }
        else RemoveTagedEffects(oCreature, "FEAT_INSIGHTFULL_STRIKE");
    }
}
// Checks feats for equiping and unequiping shields.
// oCreature is the creature equiping or unequiping.
// oItem is the item being equiped.
// iEquip tells if we are equiping or unequiping.
void CheckEquipShieldFeats (object oCreature, object oItem, int bEquip = TRUE)
{
    if(GetHasFeat(FEAT_SWORD_SHIELD_STYLE, oCreature))
    {
        // Do they have a weapon equiped?
        object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
        if(GetIsSingleHandedWeapon(oWeapon, oCreature) && bEquip)
        {
            int nBonus;
            // Do they have Improved sword and shield?
            if(GetHasFeat(FEAT_IMPROVED_SWORD_SHIELD_STYLE, oCreature)) nBonus = 4;
            else nBonus = 2;
            // Get Effect.
            effect eEffect = EffectACIncrease(nBonus, AC_DODGE_BONUS, DAMAGE_TYPE_SLASHING);
            effect eEffect2 = EffectACIncrease(nBonus, AC_DODGE_BONUS, DAMAGE_TYPE_BLUDGEONING);
            CreateFeatEffect(oCreature, EffectLinkEffects(eEffect, eEffect2), "FEAT_SWORD_AND_SHIELD_STYLE");
        }
        else RemoveTagedEffects (oCreature, "FEAT_SWORD_AND_SHIELD_STYLE");
    }
}

// Burning effect. Burning Causes xdx + x damage.
// Each round they may get a reflex save to put out the flames.
// Spell is the spell causing the burning effect
// nNumOfDie is the number of damage dice used.
// nDie is the die to roll.
// nBonus is any bonus to be added.
// bSave is if they get a save or not.
void Burning (struct stSpell Spell, int nNumOfDice, int nDie, int nBonus, int bSave)
{
    int nDamage;
    // Check for spell effect to see if the spell is still active.
    if (!GetHasSpellEffect (Spell.iSpellID, Spell.oAreaTarget)) DeleteLocalInt(Spell.oAreaTarget,"0_BURNING");
    // If oTarget is not dead then check save.
    else if (!GetIsDead (Spell.oAreaTarget))
    {
        // Calculate the damage.
        if (Spell.iMetaMagic == METAMAGIC_MAXIMIZE) nDamage = (nNumOfDice * nDie) + nBonus;
        else
        {
            nDamage = RollDiceString (IntToString (nNumOfDice) + "d" + IntToString (nDie) +
                                     "+" + IntToString (nBonus));
            if (Spell.iMetaMagic == METAMAGIC_EMPOWER)
            {
                nDamage = nDamage + (nDamage / 2);
            }
        }
        effect eDmg = EffectDamage (nDamage, DAMAGE_TYPE_FIRE);
        effect eVFX = EffectVisualEffect (VFX_IMP_FLAME_S);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX, Spell.oAreaTarget);
        if (bSave)
        {
            if (!ReflexSave (Spell.oAreaTarget, Spell.iSaveDC, SAVING_THROW_TYPE_FIRE))
            {
                // After six seconds (1 round), check damage again.
                DelayCommand (6.0f, Burning (Spell, nNumOfDice, nDie, nBonus, bSave));
            }
            // Reflex has been made so remove the burning effect.
            else
            {
                DeleteLocalInt (Spell.oAreaTarget, "0_BURNING");
                RemoveSpellEffects(Spell.iSpellID, Spell.oAreaTarget, Spell.oCaster);
            }
        }
        else
        {
            // After six seconds (1 round), check damage again.
            DelayCommand (6.0f, Burning (Spell, nNumOfDice, nDie, nBonus, bSave));
        }
   }
   // If they are dead then remove the burning effect.
   else
   {
       DeleteLocalInt (Spell.oAreaTarget, "0_BURNING");
       RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget, Spell.oCaster);
   }
}

void VisualTransform (object oTarget, float fSize)
{
    SetObjectVisualTransform (oTarget, OBJECT_VISUAL_TRANSFORM_SCALE, fSize);
}

// Sets Armor bonus based upon variable 0_Armor_Bonus and armor worn.
// Note: the On_unequip script must use a delay or the unequiped armor
//       may still be shown as equiped!
// oCreature is the creature with the armor bonus.
void CheckForArmorBonus(object oCreature)
{
    if(oCreature == OBJECT_INVALID) return;
    // Adjust for magical armor bonus i.e. Mage Armor spell.
    int nArmorAC, nArmorBonus = GetLocalInt(oCreature, "0_Armor_Bonus");
    // Get equiped Armor AC.
    object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature);
    if(oItem != OBJECT_INVALID)
    {
        nArmorAC = NWNX_Item_GetBaseArmorClass(oItem);
    }
    if(GetIsPC(oCreature))
    {
        // If you have an armor bonus and Armor on then inform the player!
        if(nArmorBonus > 0 && nArmorAC > 0)
        {
            SendMessages ("You already have an armor bonus. Armor bonuses do not stack!", COLOR_YELLOW, oCreature);
        }
    }
    nArmorBonus -= nArmorAC;
    // If the armor bonus is less than the armor ac set it to 0.
    if(nArmorBonus < 0) nArmorBonus = 0;

    NWNX_Creature_SetBaseAC(oCreature, nArmorBonus);
}

// Sets Armor's Arcane Spell Failure on the armor if they have the correct feats and armor.
// oCreature is the craature with the armor.
// oItem is the Item being equiped.
void CheckForArmorArcaneSpellFailure(object oCreature, object oItem)
{
    int nASFMod;
    if(GetHasFeat(1525/*FEAT_ARMORED_MAGE_MEDIUM*/, oCreature))
    {
        int nBaseItemType = GetBaseItemType(oItem);
        if(nBaseItemType == BASE_ITEM_SMALLSHIELD) nASFMod = 9;
        else if(nBaseItemType == BASE_ITEM_ARMOR)
        {
            int nAC = NWNX_Item_GetBaseArmorClass(oItem);
            // Light armors
            if(nAC == 1) nASFMod = 9;
            else if(nAC == 2) nASFMod = 8;
            else if(nAC == 3) nASFMod = 7;
            // Medium armors
            else if(nAC == 4) nASFMod = 6;
            else if(nAC == 5) nASFMod = 4;
        }
    }
    else if(GetHasFeat (1524/*FEAT_ARMORED_MAGE_LIGHT*/, oCreature))
    {
        int nBaseItemType = GetBaseItemType(oItem);
        if(nBaseItemType == BASE_ITEM_SMALLSHIELD) nASFMod = 9;
        else if(nBaseItemType == BASE_ITEM_ARMOR)
        {
            int nAC = NWNX_Item_GetBaseArmorClass(oItem);
            // Light armors.
            if(nAC == 1) nASFMod = 9;
            else if(nAC == 2) nASFMod = 8;
            else if(nAC == 3) nASFMod = 7;
        }
    }
    if(nASFMod > 0)
    {
        // Check the item to see if it already has ASF. If so adjust the
        // amount we are adding to see if we still need to add some.
        itemproperty ipASF = HasProperty(oItem, ITEM_PROPERTY_ARCANE_SPELL_FAILURE);
        int nASFCTMod;
        if (GetIsItemPropertyValid(ipASF)) nASFCTMod = 10 - GetItemPropertyCostTableValue(ipASF);
        nASFMod = nASFMod + nASFCTMod;
        // If there is still some arcane spell failure needed then add it.
        if(nASFMod < 10)
        {
            AddCostReductionItemProperty(oItem, "0_ASF_EQUIP");
            itemproperty ipProperty = ItemPropertyArcaneSpellFailure(nASFMod);
            ipProperty = TagItemProperty(ipProperty, "0_ASF_EQUIP");
            AddItemProperty(DURATION_TYPE_PERMANENT, ipProperty, oItem);
        }
    }
}

// Changes the size of a creature with an effect of enlarge or shrinking.
// oTarget is creature to change.
// fSizeTo is the size to change them to.
void ChangeSize (object oTarget, float fSizeTo)
{
    // Get the current size of the creature.
    float fCounter, fChange;
    float fSizeFrom = GetObjectVisualTransform (oTarget, OBJECT_VISUAL_TRANSFORM_SCALE);
    // Run system to make them bigger.
    if (fSizeFrom < fSizeTo)
    {
        // Cycle the size of the creature to get to the size needed.
        // Once fSizeFrom is bigger we are done.
        while (fSizeFrom < fSizeTo && fCounter < 1.1f)
        {
            fSizeFrom = fSizeFrom + 0.1f;
            // Change size in timed increments.
            DelayCommand (fCounter, VisualTransform (oTarget, fSizeFrom));
            // Increment the counter for the next delay and sanity check.
            fCounter = fCounter + 0.1f;
        }
    }
    // Run system to make them smaller.
    else
    {
        // Cycle the size of the creature to get to the size needed.
        // Once fSizeFrom is bigger we are done.
        while (fSizeFrom > fSizeTo && fCounter < 1.1f)
        {
            fSizeFrom = fSizeFrom - 0.1f;
            // Change size in timed increments.
            DelayCommand (fCounter, VisualTransform (oTarget, fSizeFrom));
            // Increment the counter for the next delay and sanity check.
            fCounter = fCounter + 0.1f;
        }
    }
}

// Removes bard song effects required in songs and on relogging.
// oTarget is the target to remove the effects from.
void RemoveBardSongEffects (object oTarget)
{
    object oSkin;
    oSkin = GetItemInSlot (INVENTORY_SLOT_CARMOUR, oTarget);
    RemoveTaggedItemProperties (oSkin, "Bard_Song");
    RemoveTagedEffects (oTarget, "Bard_Song");
}

// Removes an icon from an effect. Usually a spell.
effect RemoveEffectIcon (effect eEffect)
{
    struct NWNX_EffectUnpacked n_Effect;
    n_Effect = NWNX_Effect_UnpackEffect (eEffect);
    n_Effect.bShowIcon = FALSE;
    return NWNX_Effect_PackEffect (n_Effect);
}

int GetNextFogColor (int nFogColor)
{
    switch(nFogColor)
    {
        case 0x000000: return 0x606060;
        case 0x606060: return 0xC0C0C0;
        case 0xC0C0C0: return 0xFFFFFF;
        case 0xFFFFFF: return 0x660000;
        case 0x660000: return 0xff0000;
        case 0xff0000: return 0x006600;
        case 0x006600: return 0x00FF00;
        case 0x00FF00: return 0x000066;
        case 0x000066: return 0x0000FF;
        case 0x0000FF: return 0x666600;
        case 0x666600: return 0xFFFF00;
        case 0xFFFF00: return 0x006666;
        case 0x006666: return 0x00FFFF;
        case 0x00FFFF: return 0x660066;
        case 0x660066: return 0xFF00FF;
        case 0xFF00FF: return 0xCC3300;
        case 0xCC3300: return 0xFF8000;
        case 0xFF8000: return 0x663300;
        case 0x663300: return 0x994C00;
        case 0x994C00: return 0xB8860B;
        case 0xB8860B: return 0xFFD700;
        case 0xFFD700: return 0x000000;
        default: return 0x000000;
    }
    return 0x000000;
}

string GetFogTextColor (int nFogColor)
{
    switch(nFogColor)
    {
        case 0x000000: return "Black";
        case 0x606060: return "Grey";
        case 0xC0C0C0: return "Silver";
        case 0xFFFFFF: return "White";
        case 0x660000: return "Dark red";
        case 0xff0000: return "Red";
        case 0x006600: return "Dark green";
        case 0x00FF00: return "Green";
        case 0x000066: return "Dark blue";
        case 0x0000FF: return "Blue";
        case 0x666600: return "Dark yellow";
        case 0xFFFF00: return "Yellow";
        case 0x006666: return "Teal";
        case 0x00FFFF: return "Cyan";
        case 0x660066: return "Purple";
        case 0xFF00FF: return "Magenta";
        case 0xCC3300: return "Dark orange";
        case 0xFF8000: return "Orange";
        case 0x663300: return "Dark brown";
        case 0x994C00: return "Brown";
        case 0xB8860B: return "Dark golden";
        case 0xFFD700: return "Golden";
    }
    return "Unknown";
}

void KillRegeneratingCreature (object oCreature, int bAcid, int bFire)
{
    effect eAcid, eFire, eVisual;
    if(bAcid) eAcid = EffectVisualEffect (VFX_IMP_ACID_L);
    if(bFire) eFire = EffectVisualEffect (VFX_IMP_FLAME_M);
    eVisual = EffectLinkEffects (eAcid, eFire);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, oCreature);
    SetImmortal (oCreature, FALSE);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, EffectDeath(), oCreature);
}

int CalculateRegeneratingCreatureDamage ()
{
    int nPermDmg, nAcidDmg, nFireDmg, nDmg, nTemp, bFire = FALSE, bAcid = FALSE;
    nFireDmg = GetDamageDealtByType (DAMAGE_TYPE_FIRE);
    if (nFireDmg > 0) bFire = TRUE;
    else nFireDmg = 0;
    nAcidDmg = GetDamageDealtByType (DAMAGE_TYPE_ACID);
    if (nAcidDmg > 0) bAcid = TRUE;
    else nAcidDmg = 0;
    nDmg = GetTotalDamageDealt ();
    nTemp = nFireDmg + nAcidDmg;
    // If the troll took permanent damage while unconscious it will be killed.
    if (nTemp > 0 && GetLocalInt (OBJECT_SELF, "0_Unconscious")) KillRegeneratingCreature (OBJECT_SELF, bAcid, bFire);
    nPermDmg = GetLocalInt (OBJECT_SELF, "0_PermDmg") + nTemp;
    if (nPermDmg >= GetCurrentHitPoints ()) KillRegeneratingCreature (OBJECT_SELF, bAcid, bFire);
    SetLocalInt (OBJECT_SELF, "0_PermDmg", nPermDmg);
    // Calculate the new temporary damage and then add it to the existing temporary damage.
    // nTemp still holds the new permanent damage
    nTemp = nDmg - nTemp;
    SetLocalInt (OBJECT_SELF, "0_TempDmg", GetLocalInt (OBJECT_SELF, "0_TempDmg") + nTemp);
    return nDmg;
}

void Regenerate ()
{
    int nMaxHPs = GetMaxHitPoints();
    effect eHeal;
    int nTempDmg = GetLocalInt (OBJECT_SELF, "0_TempDmg");
    int nPermDmg = GetLocalInt (OBJECT_SELF, "0_PermDmg");
    int nHeal = GetLocalInt (OBJECT_SELF, "0_Regenerate");
    // Reduce temporary damage by the lesser of five hitpoints or the troll's
    // temporary damage.
    int nRegenerate = (nTempDmg < nHeal) ? nTempDmg : nHeal;
    nTempDmg -= nRegenerate;
    SetLocalInt (OBJECT_SELF, "0_TempDmg", nTempDmg);
    if ((nTempDmg + nPermDmg) < nMaxHPs)
    {
        eHeal = EffectHeal (nRegenerate);
        ApplyEffectToObject (DURATION_TYPE_INSTANT , eHeal, OBJECT_SELF);
    }
}

//******************************************************************************
// VFX effects used in game.
//******************************************************************************

// Used a villain is killed and the journal is updated.
float KillVillainEffect (object oTarget)
{
    AssignCommand (oTarget, PlaySound ("as_mg_telepout1"));
    effect eVFX = EffectVisualEffect (VFX_IMP_PDK_GENERIC_PULSE, FALSE, 0.25f);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVFX, GetLocation (oTarget));
    effect eVFX2 = EffectVisualEffect (VFX_IMP_DEATH_L);
    DelayCommand (0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX2, oTarget));
    return 1.5f;
}

// Used by the divine power to return the player to the prime plane.
void ReturnToPrimeEffect (object oCaster, object oTarget)
{
   AssignCommand (oCaster, ActionCastFakeSpellAtObject (SPELL_SUMMON_CREATURE_VIII, oTarget));
   effect eVisualCaster = EffectVisualEffect (VFX_IMP_DIVINE_STRIKE_HOLY, FALSE);
   DelayCommand (1.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisualCaster, oCaster));
   effect eVisualTarget = EffectVisualEffect (VFX_FNF_SUMMON_GATE, FALSE);
   DelayCommand (2.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisualTarget,oTarget));
}

// Portal effect used in most portals.
// returns the wait period before jumping the character.
float PortalEffect (object oPortal, object oUser)
{
    effect eVFX = EffectVisualEffect (VFX_IMP_DEATH_WARD, FALSE, 2.0f);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVFX, GetLocation (oPortal));
    effect eVFX2 = EffectVisualEffect (VFX_FNF_DISPEL, FALSE, 0.25f);
    DelayCommand (1.0f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX2, oUser));
    effect eVFX3 = EffectVisualEffect (VFX_DUR_AURA_PULSE_GREY_WHITE);
    DelayCommand (1.0f, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eVFX3, oUser, 6.0f));
    return 3.0f;
}

// The effect placed on a player when they die.
float DeathEffect (object oPC)
{
   effect eVFX = EffectVisualEffect (VFX_FNF_LOS_EVIL_20);
   ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX, oPC);
   eVFX = EffectVisualEffect (VFX_IMP_DEATH);
   DelayCommand (1.0f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX, oPC));
   return 2.0f;
}

// The effects from using the rod of returning.
// returns the wait period before jumping the character.
float RodOfRecallEffect (object oUser)
{
   PlayAnimation (ANIMATION_LOOPING_CONJURE2); // wait period for this is 0.83f
   effect eVFX = EffectVisualEffect (VFX_FNF_DISPEL);
   ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX, oUser, 3.0f);
   eVFX = EffectVisualEffect (VFX_IMP_UNSUMMON);
   DelayCommand (1.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX, oUser, 3.0f));
   return 2.0f;
}

// Close portal effect.
// returns the wait period before destroying the portal.
// oPortal is the portal to close.
// oUser is the user closing the portal.
float ClosePortalEffect (object oPortal, object oUser)
{
    // Make user do mid animation.
    ActionPlayAnimation (ANIMATION_LOOPING_GET_LOW, 1.0f, 3.0f);
    effect eVFX = EffectVisualEffect (VFX_FNF_LOS_EVIL_30);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX, oPortal);
    eVFX = EffectVisualEffect (VFX_FNF_GAS_EXPLOSION_EVIL);
    DelayCommand (1.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVFX, oPortal));
    return 2.0f;
}

// Will set the wind values for the server.
// Any values set to -1.0 will not be changed from the server value.
void SetServerWind (float fX, float fY, float fZ, float fMagnitude, float fYaw, float fPitch)
{
    int nAmbientSound = 0;
    object oArea, oModule = GetModule ();
    if (fX == -1.0) fX = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windx");
    if (fY == -1.0) fY = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windy");
    if (fZ == -1.0) fZ = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windz");
    if (fMagnitude == -1.0) fMagnitude = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude");
    if (fYaw == -1.0) fYaw = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windyaw");
    if (fPitch == -1.0) fPitch = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windpitch");
    vector vDirection = Vector (fX, fY, fZ);
    // Check for sound changes based on wind.
    if (fMagnitude > 2.49f) nAmbientSound = AMBIENT_SOUND_WIND_STRONG;
    else if (fMagnitude > 1.99f) nAmbientSound = AMBIENT_SOUND_WIND_MEDIUM;
    else if (fMagnitude > 1.49f) nAmbientSound = AMBIENT_SOUND_WIND_SOFT;
    object oPC = GetFirstPC ();
    while (GetIsObjectValid (oPC))
    {
        oArea = GetArea (oPC);
        SetAreaWind (GetArea (oPC), vDirection, fMagnitude, fYaw, fPitch);
        if (nAmbientSound > 0)
        {
            if (GetIsDay ()) AmbientSoundChangeDay (oArea, nAmbientSound);
            else AmbientSoundChangeNight (oArea, nAmbientSound);
        }
        else
        {
            AmbientSoundChangeDay (oArea, GetLocalInt (oArea, "0_AmbientDaySound"));
            AmbientSoundChangeNight (oArea, GetLocalInt (oArea, "0_AmbientNightSound"));
        }
        AmbientSoundSetNightVolume (oArea, 50);
        AmbientSoundPlay (oArea);
        oPC = GetNextPC ();
    }
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windx", fZ);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windy", fY);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windz", fZ);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude", fMagnitude);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windyaw", fYaw);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windpitch", fPitch);
}

// Will set the precipitation for the server.
// nWeather is WEATHER_* constant.
// bStorm is a TRUE/FALSE that will set the wind to strong.
// nLightningChance is % chance lighting will be in area.
void SetPrecipitation (int nWeather, int bStorm, int nLightningChance)
{
    int nListenAdj, nSpotAdj, nSkyBox, nAmbientSound;
    object oArea;
    object oModule = GetModule ();
    object oPC = GetFirstPC ();
    float fMagnitude = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude");
    if (nWeather == WEATHER_CLEAR)
    {
        SetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation", 0);
        SetServerDatabaseInt (oModule, SERVER_TABLE, "storm", 0);
        nSkyBox = SKYBOX_GRASS_CLEAR;
        nSpotAdj = 0;
    }
    if (nWeather == WEATHER_RAIN)
    {
        SetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation", GetCurrentDateTimeInMinutes () + 100);
        SetServerDatabaseInt (oModule, SERVER_TABLE, "storm", 0);
        nSkyBox = SKYBOX_GRASS_CLEAR;
        nSpotAdj = -2;
    }
    if (nWeather == WEATHER_SNOW)
    {
        SetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation", GetCurrentDateTimeInMinutes () + 100);
        SetServerDatabaseInt (oModule, SERVER_TABLE, "storm", 0);
        nSkyBox = SKYBOX_WINTER_CLEAR;
        nSpotAdj = -6;
    }
    if (bStorm)
    {
        int nPrecipitation = GetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation");
        int nStorm = GetServerDatabaseInt (oModule, SERVER_TABLE, "storm");
        fMagnitude = IntToFloat (Random (151) + 150) / 100.0f;
        SetWind (fMagnitude, TRUE);
        nSkyBox = SKYBOX_GRASS_STORM;
        SetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation", GetCurrentDateTimeInMinutes () + 100);
        SetServerDatabaseInt (oModule, SERVER_TABLE, "storm", GetCurrentDateTimeInMinutes () + 100);

    }
    // Check for sound changes based on wind.
    if (fMagnitude > 2.49f) nAmbientSound = AMBIENT_SOUND_WIND_STRONG;
    else if (fMagnitude > 1.99f) nAmbientSound = AMBIENT_SOUND_WIND_MEDIUM;
    else if (fMagnitude > 1.49f) nAmbientSound = AMBIENT_SOUND_WIND_SOFT;
    nListenAdj = FloatToInt (fMagnitude * -3.0f);
    while (GetIsObjectValid (oPC))
    {
        oArea = GetArea (oPC);
        NWNX_Area_SetWeatherChance (oArea, NWNX_AREA_WEATHER_CHANCE_LIGHTNING, nLightningChance);
        SetWeather (oArea, nWeather);
        NWNX_Area_SetAreaListenModifier (oArea, nListenAdj);
        NWNX_Area_SetAreaSpotModifier (oArea, nSpotAdj);
        SetSkyBox (nSkyBox, oArea);
        if (nAmbientSound > 0)
        {
            if (GetIsDay ()) AmbientSoundChangeDay (oArea, nAmbientSound);
            else AmbientSoundChangeNight (oArea, nAmbientSound);
        }
        else
        {
            AmbientSoundChangeDay (oArea, GetLocalInt (oArea, "0_AmbientDaySound"));
            AmbientSoundChangeNight (oArea, GetLocalInt (oArea, "0_AmbientNightSound"));
        }
        AmbientSoundSetNightVolume (oArea, 50);
        AmbientSoundPlay (oArea);
        oPC = GetNextPC ();
    }
}
void AdjustAreaTextures(object oArea)
{
    // SpecialEvent Texture overrides.
    /*/ Changes grass to snow covered for the winter event.
    SetTextureOverride("ttr01_grass02", "tts01_grass02");
    SetTextureOverride("ttr01_grass03", "tts01_grass03");
    SetTextureOverride("ttr01_grassrim01", "tts01_grassrim01");
    // Changes dirt to snow covered.
    SetTextureOverride("ttr01_dirt03", "tts01_dirt03");
    SetTextureOverride("ttr01_dirt06", "tts01_grass03");
    // Bridge surfaces to snow covered.
    SetTextureOverride("ttr01_bridge01", "tts01_bridge01");
    SetTextureOverride("ttr01_bridge02", "tts01_bridge02");
    // Roof tops
    SetTextureOverride("lok_shingles1", "tts01_roof02");
    SetTextureOverride("ttr01_roof02", "tts01_roof02");
    // Trees.
    SetTextureOverride("ttr01_treefol01", "tts01_treefol01");
    SetTextureOverride("ttr01_treefol02", "tts01_treefol02");
    SetTextureOverride("ttr01_treefol03", "tts01_treefol03");
    SetTextureOverride("ttr01_bark01", "tts01_bark01");
    // Roads
    //SetTextureOverride("ttr01_road01", "");
    //SetTextureOverride("ttr01_road02", "");
    //SetTextureOverride("ttr01_road03", "");
    // Stone walls.
    SetTextureOverride("ttr01_wall01", "tts01_wall01a");
    SetTextureOverride("ttr01_brick02", "tts01_brick03");
    SetTextureOverride("ttr01_stone05", "tts01_stone05");
    // Wood fence
    SetTextureOverride("ttr01_wdfence", "tts01_wdfence");
    SetTextureOverride("ttr01_wood01b", "tts01_wood01b");
    */
}
