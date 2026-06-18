FUNCTION_BLOCK FB_TankLogic_Updated
VAR_INPUT
	
END_VAR
VAR_OUTPUT
END_VAR
VAR
    iState : INT := 0;  
END_VAR
////////////////////////////
// ==========================================================
// 1. Mode Selection & Safety Latching
// ==========================================================
// Map physical/HMI selector switch to internal mode flags
GVL_Tank.xAutoModeActive   := GVL_Tank.xSelectorSwitch;
GVL_Tank.xManualModeActive := NOT GVL_Tank.xSelectorSwitch;

// --- E-STOP Latching Logic ---
// Immediately latch the E-Stop state upon activation to prevent accidental restart
IF GVL_Tank.xEmStop THEN
    GVL_Tank.xEmStop_Latched := TRUE;
END_IF

// Unlatch E-Stop only if the physical button is released (pulled up) AND the operator issues a Reset command
IF GVL_Tank.xResetButton AND NOT GVL_Tank.xEmStop THEN
    GVL_Tank.xEmStop_Latched := FALSE;
END_IF


// ==========================================================
// 2. Alarm Management
// ==========================================================
// 2.1 Detect and latch critical process alarms (Overflow or Dry-run conditions)
IF (GVL_Tank.rTankLevel > 95.0) OR GVL_Tank.xHighFloatSwitch OR GVL_Tank.xLowFloatSwitch THEN
    GVL_Tank.xLevelAlarm := TRUE;
    GVL_Tank.xAlarmTrip  := TRUE;   
ELSE
    GVL_Tank.xLevelAlarm := FALSE; 
END_IF

// 2.2 Acknowledge and clear alarms only when process values return to safe boundaries and a Reset is triggered
IF GVL_Tank.xResetButton AND (GVL_Tank.rTankLevel <= 95.0) AND NOT GVL_Tank.xHighFloatSwitch AND NOT GVL_Tank.xLowFloatSwitch THEN
    GVL_Tank.xAlarmTrip := FALSE;  
END_IF


// ==========================================================
// 3. Safety Interlock State Management
// ==========================================================
// Force the sequence state machine back to initialization (State 0) if the system is halted or E-Stop is active
IF NOT GVL_Tank.xSystemRunning OR GVL_Tank.xEmStop_Latched THEN
    iState := 0; 
END_IF


// ==========================================================
// 4. Auto / Manual / Standby Control
// ==========================================================
// ------------------------------------------------------
// 4.1 Auto Mode Sequence
// ------------------------------------------------------
IF GVL_Tank.xAutoModeActive AND NOT GVL_Tank.xSystemHold AND NOT GVL_Tank.xAlarmTrip AND NOT GVL_Tank.xEmStop_Latched THEN

    // Sequence progression based on tank level thresholds
    IF GVL_Tank.rTankLevel <= 20.0 THEN
        iState := 1;     // Transition to Filling Phase
    ELSIF GVL_Tank.rTankLevel >= 80.0 THEN
        IF iState = 1 THEN
            GVL_Tank.iCycleCount := GVL_Tank.iCycleCount + 1; // Increment cycle counter upon fill completion
        END_IF
        iState := 2;     // Transition to Draining Phase
    ELSIF iState = 0 THEN
        iState := 1;     // Initial Startup Phase
    END_IF

    // Actuator control mapped to current sequence state
    IF iState = 1 THEN
        GVL_Tank.xInletValve := TRUE;
        GVL_Tank.xOutletPump := FALSE;
    ELSIF iState = 2 THEN
        GVL_Tank.xInletValve := FALSE;
        GVL_Tank.xOutletPump := TRUE;
    END_IF

// ------------------------------------------------------
// 4.2 Manual Mode Override
// ------------------------------------------------------
ELSIF GVL_Tank.xManualModeActive AND NOT GVL_Tank.xEmStop_Latched THEN

    iState := 0; // Override and reset Auto sequence state

    // Mutual exclusion interlock: Prevent simultaneous opening of inlet and outlet to avoid hydraulic bypass
    IF GVL_Tank.xManualInlet AND GVL_Tank.xManualOutlet THEN
        GVL_Tank.xInletValve := FALSE;
        GVL_Tank.xOutletPump := FALSE; 
    ELSE
        GVL_Tank.xInletValve := GVL_Tank.xManualInlet;   
        GVL_Tank.xOutletPump := GVL_Tank.xManualOutlet; 
    END_IF

// ------------------------------------------------------
// 4.3 Standby / Idle Mode 
// ------------------------------------------------------
ELSE
    // Ensure all actuators are safely de-energized
    GVL_Tank.xInletValve := FALSE;
    GVL_Tank.xOutletPump := FALSE;
    iState := 0;
END_IF


// ==========================================================
// 5. Status Message Display (Priority Routing)
// ==========================================================
// Prioritized HMI messaging pipeline (Highest priority conditions overwrite lower ones)
IF GVL_Tank.xEmStop_Latched THEN
    GVL_Tank.sStatusText := 'EMERGENCY STOP ACTIVATED!';
ELSIF GVL_Tank.xAlarmTrip THEN
    GVL_Tank.sStatusText := 'SYSTEM FAULT (ALARM)';
ELSIF (GVL_Tank.rTankLevel <= 0.0) AND GVL_Tank.xManualOutlet THEN
    GVL_Tank.sStatusText := 'WARNING: TANK EMPTY (DRY-RUN)'; 
ELSIF (GVL_Tank.rTankLevel >= 95.0) AND GVL_Tank.xManualInlet THEN
    GVL_Tank.sStatusText := 'WARNING: TANK FULL (OVERFLOW)'; 
ELSIF iState = 1 THEN
    GVL_Tank.sStatusText := 'FILLING WATER';
ELSIF iState = 2 THEN
    GVL_Tank.sStatusText := 'DRAINING WATER';
ELSE
    GVL_Tank.sStatusText := 'STANDBY';
END_IF


// ==========================================================
// 6. Control Panel Indicator Lamps
// ==========================================================
// Red: Active when an alarm is tripped or E-Stop is engaged
GVL_Tank.xLamp_Red    := GVL_Tank.xAlarmTrip OR GVL_Tank.xEmStop_Latched;

// Yellow: Active when the system is not running or switched to Manual mode
GVL_Tank.xLamp_Yellow := (NOT GVL_Tank.xSystemRunning) OR GVL_Tank.xManualModeActive;

// Green: Active only when the system is running smoothly in Auto mode with no faults
GVL_Tank.xLamp_Green  := GVL_Tank.xSystemRunning AND GVL_Tank.xAutoModeActive AND NOT GVL_Tank.xAlarmTrip AND NOT GVL_Tank.xEmStop_Latched;


// ==========================================================
// 7. Process Hardware Protection (End-of-scan Override)
// ==========================================================
// Absolute hardware override at the end of the scan cycle (Failsafe execution)
IF NOT GVL_Tank.xSystemRunning OR GVL_Tank.xEmStop_Latched THEN
    GVL_Tank.xInletValve := FALSE;
    GVL_Tank.xOutletPump := FALSE;
END_IF

// Prevent tank overflow regardless of active control mode
IF (GVL_Tank.rTankLevel >= 95.0) OR GVL_Tank.xHighFloatSwitch THEN
    GVL_Tank.xInletValve := FALSE; 
END_IF

// Prevent pump dry-run cavitation regardless of active control mode
IF (GVL_Tank.rTankLevel <= 0.0) OR GVL_Tank.xLowFloatSwitch THEN
    GVL_Tank.xOutletPump := FALSE; 
END_IF
