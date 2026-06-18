{attribute 'qualified_only'}
VAR_GLOBAL
    // ============================================================
    // 1. INPUTS (HMI Pushbuttons & Physical Control Panel Switches)
    // ============================================================
    xStartButton        : BOOL;     // System Start / Resume command
    xStopButton         : BOOL;     // System Stop command (Normal shutdown)
    xHoldButton         : BOOL;     // System Pause / Hold command
    xEmStop             : BOOL;     // Emergency Stop physical input (NC contact)
    xEmStop_Latched     : BOOL;     // Latched Emergency Stop state (Requires reset)
    xAutoModeButton     : BOOL;     // HMI pushbutton for Auto mode selection
    xManualModeButton   : BOOL;     // HMI pushbutton for Manual mode selection
    
    xResetButton        : BOOL;     // Fault / Alarm Reset command (HMI or Physical)
    xAlarmTrip          : BOOL;     // Latched System Fault state (Locks system)
    
    xSelectorSwitch     : BOOL;     // HMI Mode Selector Switch (FALSE = Manual, TRUE = Auto)
    
    // ============================================================
    // 2. MANUAL CONTROLS (Direct Actuator Overrides in Manual Mode)
    // ============================================================
    xManualInlet        : BOOL;     // Manual command to open inlet valve
    xManualOutlet       : BOOL;     // Manual command to run outlet pump
    
    // ============================================================
    // 3. PROCESS VARIABLES (Analog & Continuous Data)
    // ============================================================
    rTankLevel          : REAL;     // Current tank water level (Scaled: 0.0 - 100.0 %)
    
    // ============================================================
    // 4. OUTPUTS (Physical Hardware Control Signals)
    // ============================================================
    xInletValve         : BOOL;     // Inlet Valve command (TRUE = Open)
    xOutletPump         : BOOL;     // Outlet Pump command (TRUE = Run)
    
    // ============================================================
    // 5. SYSTEM STATUS & ALARMS (HMI Indicators & SCADA Integration)
    // ============================================================
    xSystemRunning      : BOOL;     // System is currently active and executing sequence
    xSystemHold         : BOOL;     // System is temporarily paused (Hold state)
    xLevelAlarm         : BOOL;     // Critical level alarm trigger (Tank < 5% or > 95%)
    
    xAutoModeActive     : BOOL;     // Active control mode feedback flag: Auto
    xManualModeActive   : BOOL;     // Active control mode feedback flag: Manual
    
    // Hardware Interlocks (Failsafe Sensors)
    xHighFloatSwitch    : BOOL;     // High-Level Hardware Interlock (TRUE = Overflow risk)
    xLowFloatSwitch     : BOOL;     // Low-Level Hardware Interlock (TRUE = Pump dry-run risk)

    iCycleCount         : INT := 0; // Accumulated water draining cycles counter
    
    sStatusText         : STRING;   // Current system state message for HMI display
    
    // ============================================================
    // 6. INDICATOR LAMPS (Control Panel Status Lights)
    // ============================================================
    xLamp_Red           : BOOL;     // Red light (System Fault / Alarm Active)
    xLamp_Yellow        : BOOL;     // Yellow light (System in Standby / Manual Mode)
    xLamp_Green         : BOOL;     // Green light (System Running normally in Auto)
END_VAR