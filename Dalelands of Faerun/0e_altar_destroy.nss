/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_altar_destroy
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script on death for altars with unique effects.

 Altar of Auril [0_altar_auril] - when destroyed summons a Villian to kill the Destroyer.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_specialevents"
#include "0i_s_message"
#include "0i_checks"
void main()
{
    object oKiller = GetLastKiller();
    object oPC = GetPlayerMaster(oKiller);
    // Check which altar this is.
    // Altar of Auril
    // Spawn Cold Villain to attack the Destroyer.
    ExecuteScript("0e_rolltreasure", OBJECT_SELF);
    if (GetTag (OBJECT_SELF) == "0_altar_auril")
    {
        if(oPC != OBJECT_INVALID)
        {
            // Save the number Auril altars destroyed on your players book.
            object oPlayerBook = GetCreatureHasItem(oPC, "players_book");
            int nDestroyed;
            string sYear = GetLocalString(oPlayerBook, "0_AURIL_ALTAR_LAST_DESTROYED");
            if(sYear == AURIL_CURRENT_YEAR) nDestroyed = GetLocalInt(oPlayerBook, "0_AURIL_ALTARS_DESTROYED") + 1;
            else nDestroyed = 1;
            SetLocalInt(oPlayerBook, "0_AURIL_ALTARS_DESTROYED", nDestroyed);
            SetLocalString(oPlayerBook, "0_AURIL_ALTAR_LAST_DESTROYED", AURIL_CURRENT_YEAR);
        }
        else oPC = oKiller;
        effect eBlast = EffectVisualEffect(477, FALSE, 5.0);
        location lLocation = GetLocation(OBJECT_SELF);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eBlast, lLocation);
        // Do knockdown checks.
        int nSave, nDC = GetCharacterLevels(oPC) + 10;
        float fDuration;
        effect eFrozen = EffectCutsceneParalyze();
        eFrozen = EffectLinkEffects(EffectVisualEffect(465), eFrozen);
        eFrozen = EffectLinkEffects(EffectVisualEffect(352), eFrozen);
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 15.0, lLocation, TRUE, OBJECT_TYPE_CREATURE);
        while(oTarget != OBJECT_INVALID)
        {
            if(!ReflexSave(oTarget, nDC))
            {
                fDuration = RoundsToSeconds(d3());
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFrozen, oTarget, fDuration);
                if(GetIsCharacter(oTarget)) SendMessages("The Frostmaiden curses you with her chill touch. You are frozen!", COLOR_BLUE, oTarget);
            }  
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 15.0, lLocation, TRUE, OBJECT_TYPE_CREATURE);  
        }
        CreateAurilVillain(oPC);
    }
}

