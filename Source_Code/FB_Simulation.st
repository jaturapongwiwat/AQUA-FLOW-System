FUNCTION_BLOCK FB_Simulation
VAR_INPUT
    xInletOpen  : BOOL;     
    xOutletRun  : BOOL;     
END_VAR
VAR_IN_OUT
    rLevel      : REAL;     
END_VAR
VAR 
    fbTimer     : TON;      
    xTrigger    : BOOL;    
END_VAR
/////////////////////////////
(* ==========================================================
   Water Tank Behavior Simulator Block - FIXED
   ========================================================== *)

// Generate a continuous 100ms pulse for the simulation step
fbTimer(IN := NOT xTrigger, PT := T#100MS);

// Create a 1-scan-cycle trigger when the timer completes
IF fbTimer.Q THEN
    xTrigger := TRUE;
ELSE
    xTrigger := FALSE;
END_IF;

// Execute level calculations only when the trigger is active
IF xTrigger THEN
    
    // 1. Simulation: Filling Phase (Inlet Open, Pump Stopped)
    IF xInletOpen AND NOT xOutletRun THEN
        IF rLevel < 100.0 THEN
            rLevel := rLevel + 0.5; // Increase level by 0.5% per 100ms
        END_IF
    END_IF
    
    // 2. Simulation: Draining Phase (Pump Running, Inlet Closed)
    IF xOutletRun AND NOT xInletOpen THEN
        IF rLevel > 0.0 THEN
            rLevel := rLevel - 0.8; // Decrease level by 0.8% per 100ms
        END_IF
    END_IF
    
    // 3. Simulation: Simultaneous Operation (Both Active)
    IF xInletOpen AND xOutletRun THEN
        IF rLevel < 100.0 AND rLevel > 0.0 THEN
            rLevel := rLevel - 0.3; // Net decrease (Draining rate > Filling rate)
        END_IF
    END_IF  
    
    // 4. Boundary Protection (Clamp values to prevent out-of-bounds)
    IF rLevel > 100.0 THEN
        rLevel := 100.0;
    ELSIF rLevel < 0.0 THEN
        rLevel := 0.0;
    END_IF

END_IF