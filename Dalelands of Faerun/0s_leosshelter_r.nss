/*/////////////////////////////////////////////////////
 Script: 0s_leosshelter_r
 Programmer: Philos
///////////////////////////////////////////////////////
 This removes the bonuses from the spell Leomund's Secure Shelter
 OBJECT_SELF is the target of the effect.
/*/////////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_effect"

void RemoveShelter (object oArea, object oWaypoint, string sName)
{
    // Create visual effects
    effect eCenter = EffectVisualEffect (VFX_FNF_NATURES_BALANCE);
    // Do magical lower into the ground.
    object oCottage = GetObjectByTag ("Place_Shelter_" + sName);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, GetLocation (oCottage));
    MoveObject (oCottage, 0.0f, 0.0f, -10.5f, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR, 5.0f);
    //Destroy the Cottage.
    SetPlotFlag (oCottage, FALSE);
    DestroyObject (oCottage, 11.0f);
    DestroyObject (oWaypoint, 12.0f);
    DestroyArea (oArea);
}

void main()
{
    int iCounter = 1;
    float fDelay = 0.5f;
    string sName;
    object oArea, oCaster = GetExitingObject ();
    // Check to see if they are exiting first. If not then the spell is ending.
    // Code for spell is ending.
    if (oCaster == OBJECT_INVALID)
    {
        oCaster = OBJECT_SELF;
        effect eEffect = GetLastRunScriptEffect ();
        string sName = GetEffectString (eEffect, 0);
        oArea = GetObjectByTag ("Area_Shelter_" + sName);
    }
    // Code for exiting shelter.
    else
    {
        oArea = OBJECT_SELF;
        string sAreaTag = GetTag (oArea);
        sName = GetStringRight (sAreaTag, GetStringLength (sAreaTag) - 13);
        fDelay = 12.0f;
    }
    if (oArea == OBJECT_INVALID) return;
    // Check to make sure oCaster is the caster incase others exit the area.
    if (sName == RemoveIllegalCharacters (StripColorCodes (GetName (oCaster))))
    {
        // Skip removal in that case as we don't want the shelter to dissappear
        // while the caster is in it.
        if(GetArea(oCaster) == oArea) return;
        object oWaypoint = GetObjectByTag ("WP_LEO_EXIT_" + sName);
        // Remove any creatures within the shelter.
        object oPC = GetObjectInArea (oArea, iCounter, OBJECT_TYPE_CREATURE);
        while (oPC != OBJECT_INVALID)
        {
            AssignCommand (oPC, JumpToObject (oWaypoint));
            iCounter ++;
            oPC = GetObjectInArea (oArea, iCounter, OBJECT_TYPE_CREATURE);
        }
        DelayCommand (fDelay, RemoveShelter (oArea, oWaypoint, sName));
    }
}

