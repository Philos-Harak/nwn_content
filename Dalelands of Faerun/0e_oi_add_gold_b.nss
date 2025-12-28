/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_oi_add_gold_b
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a creature gains gold.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "nwnx_events"

void main()
{
    /*object oCreature = OBJECT_SELF;
    if (!GetIsCharacter (oCreature)) return;
    // Get if they have a henchman no leadership and are not bartering.
    if (!GetIsDead (GetLocalObject (oCreature, "0_HENCHMAN")) &&
        !GetHasFeat (1270/*Leadership/, oCreature) &&
        !GetLocalInt (oCreature, "0_BARTERING"))
    {
        // Make sure we only dip into the gold one time.
        if (!GetLocalInt (oCreature, "0_HENCH_TAKE_GOLD"))
        {
            int nGold = StringToInt (NWNX_Events_GetEventData ("GOLD"));
            // We only take gold when it is positive i.e given.
            if (nGold > 0)
            {
                float fGold = IntToFloat (nGold);
                int nHenchGold = FloatToInt (fGold * 0.25);
                int nPCGold = nGold - nHenchGold;
                SetLocalInt (oCreature, "0_HENCH_TAKE_GOLD", TRUE);
                if (nHenchGold > 0) SendMessages ("Your henchman takes " + IntToString (nHenchGold) + "gp for their services.", COLOR_GRAY, oCreature);
                GiveGoldToCreature (oCreature, nPCGold);
                NWNX_Events_SkipEvent ();
            }
        }
        // This is the pass where we don't take gold so setup the next one.
        else SetLocalInt (oCreature, "0_HENCH_TAKE_GOLD", FALSE);
    } */
}

