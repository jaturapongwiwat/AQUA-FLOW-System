# 🌊 AQUA-FLOW: Industrial Water Tank Control System

A complete PLC and HMI SCADA simulation project built with **CODESYS V3.5**. This project demonstrates standard industrial automation programming, safety interlocks, and state management using both Structured Text (ST) and Ladder Diagram (LD).

![AQUA-FLOW HMI Main Screen](Images/HMI_MainScreen.png)

##  Project Overview
The AQUA-FLOW system simulates an automated water tank control process. It features a robust state machine handling multiple operation modes (Auto/Manual/Standby), hardware interlocks for equipment protection, and a streamlined alarm management system designed for optimal operator user experience (UX) on the factory floor.

##  Key Engineering Features
* **Multi-Mode Operation:** Seamless switching between Auto, Manual, and Standby sequences.
* **Safety & Hardware Interlocks:** * Failsafe E-Stop latching logic (requires physical reset).
  * Float switch integration to prevent tank overflow and pump dry-run cavitation.
* **Smart Alarm Management:** * Single-button Fault Reset mechanism (Optimized from standard REP_ACK).
  * Real-time UI feedback with priority routing (E-Stop overrides normal faults).
* **Mixed-Language Architecture (IEC 61131-3):** * **Ladder Diagram (LD):** Used for visual relay logic, sequence steps, and motor control clarity.
  * **Structured Text (ST):** Used for complex mathematical simulations, state machines, and routing logic.

##  Tech Stack & Standards
* **Environment:** CODESYS V3.5
* **Languages:** Ladder Diagram (LD), Structured Text (ST)
* **Visualization:** CODESYS HMI / SCADA Integration
* **Concepts:** Finite State Machine (FSM), Hardware Interlocks, ISA-18.2 Alarm Management Concepts

##  Repository Structure
This repository is organized to allow easy review of the logic without requiring the CODESYS environment:

* `CODESYS_Project/` : Contains the fully functional `.project` file.
* `Source_Code/` : 
  * `PLC_PRG_LD.pdf` (Main program sequencing and motor control written in Ladder Diagram).
  * `FB_TankLogic.st` (Water level mathematical simulation written in Structured Text).
  * `GVL_Tank.st` (Global Variable List mapping physical I/O and HMI tags).
* `Images/` : UI screenshots, interlock logic snippets, and system behavior demonstrations.

## ⚙️ Core Logic Snippet (Failsafe Execution)
```pascal
// Absolute hardware override at the end of the scan cycle (Failsafe execution)
IF NOT GVL_Tank.xSystemRunning OR GVL_Tank.xEmStop_Latched THEN
    GVL_Tank.xInletValve := FALSE;
    GVL_Tank.xOutletPump := FALSE;
END_IF
## 👨‍💻 Author
**Jaturapong Wiwat**
*่Junior Automation Engineer*
A recent engineering graduate passionate about industrial automation, PLC programming, and SCADA systems. Always eager to learn and develop practical skills in control systems and industrial robotics.

* **Email:** jaturapongwiwat@gmail.com
* **GitHub:** https://github.com/jaturapongwiwat
