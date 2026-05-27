# VHDL Digital Pong Game for Cyclone V FPGA

Welcome to the **VHDL Hardware Pong Game** project! This repository contains a complete hardware implementation of the classic Pong game, designed specifically for the **Altera Cyclone V GX FPGA**. This project demonstrates how to build a real-time interactive system using VHDL, covering everything from HDMI video generation to I2S audio processing.

---

## 1. Project Overview
The goal of this project is to recreate the iconic Pong game entirely in hardware. It supports **two-player gameplay**, where players use buttons to control their paddles and prevent a ball from passing their side. The system features:
*   **HDMI Video Output:** Real-time rendering of the game arena, paddles, and ball using 640x480 @ 60Hz timing".
*   **Dynamic Audio:** Sound effects for ball hits and custom melodies for the start and game-over screens.
*   **Score Tracking:** A 7-segment display shows the score for both players.
*   **Robust Input:** Button signals are cleaned using debounce filters to ensure smooth paddle movement.

---

## 2. System Architecture
The architecture follows a hierarchical design. At the center is the **Top-Level Module (`pong_top`)**, which connects the game logic, video generation, and audio systems. 

The system operates on a **50MHz main clock**, which is divided down to **25MHz** for the video synchronization. The **Game State Machine (`pong_SM`)** acts as the controller, managing whether the game is in the "Start," "Play," or "Game Over" phase. It receives inputs from the paddles and ball modules and decides what should be drawn on the screen and what sounds should play.

---

## 3. Detailed Module Descriptions

### Core Logic & Control
*   **`pong_top.vhd`**: This is the master wrapper. It connects the FPGA pins (buttons, switches, VGA, and Audio) to the internal logic.
*   **`pong_SM.vhd`**: The "brain" of the game. It handles the main game states and combines the video signals from the ball, paddles, and borders to create the final RGB output for the monitor.
*   **`pongPack.vhd`**: A utility package containing shared constants and functions, such as logic for drawing text characters (S, T, A, R, G, etc.) on the screen.

### Video Generation
*   **`HVsync.vhd`**: This module generates the Horizontal (HS) and Vertical (VS) sync signals required for a standard VGA display. it also provides the current pixel coordinates (X and Y) to the rest of the system.
*   **`pong_ball.vhd`**: Tracks the ball's position and movement. It calculates when the ball hits a paddle or a wall and signals when a point is scored.
*   **`pong_paddle.vhd`**: Manages the vertical position of the paddles. It listens to the "Up" and "Down" buttons and ensures the paddles stay within the screen boundaries.
*   **`pong_border.vhd`, `pong_start.vhd`, `pong_gameOver.vhd`**: These modules are responsible for drawing static elements like the arena borders, the "START" text, and the "GAME OVER" message.

### Audio System
*   **`audio_top.vhd`**: The coordinator for all sounds. It selects which audio signal (beep or melody) should be sent to the transmitter based on the game state.
*   **`i2s_tx.vhd`**: Converts digital audio samples into the I2S format required by external Audio DACs.
*   **`beep_gen.vhd`, `start_melody_gen.vhd`, `gameOver_melody_gen.vhd`**: These modules generate the actual sound waves. The `beep_gen` creates a simple tone for hits, while the melody generators play sequences of notes for the game transitions.

### Hardware Support
*   **`debounce_filter.vhd`**: This module filters the mechanical "noise" from the physical buttons to prevent a single press from being detected multiple times.
*   **`sevenSeg_display.vhd`**: A decoder that converts the player's integer score into the signals needed to light up a 7-segment display.
*   **`freq_divider.vhd`**: A simple clock divider that creates slower clock signals for various components.

---

## 4. Hardware Deployment & Setup Guide

### Requirements
*   **FPGA:** Cyclone V GX (Target Device: `5CGXFC5C6F27C7`).
*   **Software:** Quartus II (Tested on Version 13.0.1).
*   **Peripherals:** 
    *   A HDMI-compatible monitor.
    *   Push buttons for Player 1 and Player 2 controls.
    *   An I2S Audio DAC for sound output.

### Setup Steps
1.  **Open the Project:** Load the project files into Quartus II.
2.  **Assign Pins:** Use the Pin Planner to map the inputs (buttons, 50MHz clock) and outputs (HDMI Data-Bus, HS, VS, DE, Audio I2S, 7-segment display) according to your specific board's manual.
3.  **Compile:** Run the compilation process. The design is efficient, using only about **2% of the available ALMs** (Logic units) and **478 registers**.
4.  **Program the FPGA:** Connect your board via USB-Blaster and upload the generated `.sof` file.
5.  **Play:** Press the "Start" button to begin! Use the Up/Down buttons to control your paddle. The score will update automatically on the 7-segment display when the ball passes a player.



