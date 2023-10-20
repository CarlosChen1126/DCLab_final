# Electrical Engineering Lab(Digital Circuit) Final Project

## Team 09 
## DEMO
https://www.youtube.com/watch?v=20aysfmDwVc&t=307s
## Structure

```
DE2_115_CAMERA (Motion Detection)
├── CCD_Capture.v(Capture camera frames)
├── CalcDir.v
├── DE2_115_CAMERA.v
├── I2C_CCD_Config.v(D5M module's I2C)
├── I2C_Controller.v
├── Line_Buffer.v
├── Line_Buffer1.v
├── Motion_Detection.v
├── Purify
│   ├── Purify.v(Reduce noise)
│   ├── Purify_Line_Buffer.v
│   ├── Purify_Line_Buffer_bb.v
│   └── Purify_buffer_3.v(The line buffer is used to store the previous row's data)
├── RAW2RGB.v(Convert D5M data to RGB format)
├── Reset_Delay.(Output reset signal)
├── SEG7_LUT.v
├── SEG7_LUT_8.v(Seven-segment display)
├── Sdram_Control
│   ├── Sdram_Control.v
│   ├── Sdram_Params.h
│   ├── Sdram_RD_FIFO.v
│   ├── Sdram_WR_FIFO.v
│   ├── command.v
│   ├── control_interface.v
│   └── sdr_data_path.v
├── VGA_Controller.v(Control VGA display)
└── sdram_pll.v
```
```
DE2_115 (Game Control)
├── Arduino_Module
│   └── DCLab_Servo_Laser.ino(Receive signal from Top via GPIO and control Arduino to implement laser)
├── Audio_Processing
│   ├── AudDSP.sv(Control playback speed)
│   ├── AudPlayer.sv(Play sounds)
│   ├── AudRecorder.sv(Write sound effects into SRAM)
│   ├── AudTop.sv(Select and play specific sound effect based on the signal in the Game)
│   └── I2cInitializer.sv(Control I2C protocal and initialize wm8731)
├── DE2_115(Setup Configured Documents)
├── Debounce.sv(Handle key debounce issues)
├── Image_Processing
│   ├── display.sv(Control VGA's output signal)
│   ├── item.sv(Control game picture's display)
│   ├── rom_async.sv(Control fpga's LUT/ROM)
│   ├── rom_sync.sv(Control BRAM)
│   └── sprite_1.sv(Control game picture's display)
├── Python
│   ├── img2mem.py(Convert images into .mem files in hexadecimal format)
│   └── motion_detection_simulation.py(Simulate motion detection algorithm)
├── SevenHexDecoder.sv(Control seven-segment display)
├── Top.sv(Integrate all submodules and control the Game's finite-state machine)
├── lfsr.sv(Generate random numbers as input for AudDSP playback speed)
├── pictures(store game pictures)
└── timer.sv(Display countdown timer on the screen during the game)
```
## Block Diagram

- motion detection
![圖片 5](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/014aed68-acb6-4c5b-9829-08f7aad3d1bb)

- game
![圖片 6](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/9bdacfc1-4379-4872-ae68-ef7fb0e98454)


## FSM

### Fitter Summary

- Motion Detection

![圖片 7](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/f4334868-c477-46ac-80c7-00956d25dd52)

- Game

![圖片 8](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/11f43ecd-e749-4b64-a27a-7080b1b9ef1f)
![圖片 9png](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/2a0717f1-aec9-43e0-b632-908234f47916)




## Materials

DE2-115*2、TRDB-D5M camera、Arduino Nano、SG90 servo motor、Laser module、Dupont wire、
Microphone、Speaker、Screen、VGA cable、Power cord。

## Game Instructions and Rules

1. After pressing key0, a countdown of five seconds will begin, and the game will start. During this time, the game music will play, indicating that the player can start moving
2. At this point, the game screen will display the remaining time in the top left corner, and the character (wooden figure) will be facing away from the player
3. When the music playback ends, the timer will pause, and the wooden figure will turn around, entering the detection state.
4. If the player makes any movement at this point, the wooden figure will detect it and shoot laser beams, signifying game over
5. Conversely, if the wooden figure doesn't detect any movement, it will turn back after five seconds. At this point, the background music will replay, indicating that the player can move again
6. If the player presses key1 before the countdown timer reaches zero, it signifies victory in the game.
7. On the contrary, if key1 is not pressed when the timer reaches zero, even if the player is not hit by the laser beams, the game is considered a failure.


## Implementation Methods and Design Details

**1. Motion Detection:**
The reason we chose the algorithm shown in the following image for our motion detection is due to considerations for processing speed and the complexity of implementation on FPGA.This algorithm reads the image It from the camera, then calculates the difference with the estimated background Mt. If the absolute value of this difference is less than the variance Vt, the pixel is considered not in motion. Conversely, if the absolute difference is greater than Vt, the pixel is classified as in motion.he values of Mt and Vt are updated based on the magnitude of the difference. After performing the motion detection computation, we also implemented a noise removal step. For each pixel, if all surrounding pixels are classified as not in motion, then this pixel is also considered not in motion. This process reduces noise in the image, enhancing the precision of the motion detection.
![圖片 10](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/71dbfa68-ef59-4b63-8afa-8c61656dce84)



**2. Index Calculation:**
To recognize the left-right movement of objects, we divided the screen into seven equal segments proportionally. We calculated the number of motion-detected pixels in each segment. The segment with the highest number of pixels was selected. If the pixel count in that segment exceeded a predefined threshold, the corresponding movement signal was sent to the game control FPGA board. The screen segments from right to left correspond to 0 to 6.
![圖片 11](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/ca0c18ba-c53c-4ed3-b0e1-e2394ec55c29)

**3. Image_Display:**
  In the image display section, we referred to(https://projectf.io/posts/hardware-sprites/) using
    img2mem.py to save each images as separate pixel and palette files. The palette represents the colors used in the image, while the pixel file indicates the index of each pixel corresponding to a specific color in the palette.We stored game images using a palette of 16 colors, with each color represented by 4 bits for each RGB channel, as shown in the diagram below.
    
Palette:
![圖片 12](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/b913c9f3-49e6-44a1-a8a3-fb208de1f7d8)

Pixel:
![圖片 13](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/d2be6b70-f21d-481b-931c-3e6190f3a7ee)

A pixel value of 1 (indicated by the red box) represents that the color of this pixel corresponds to the first color in the palette file, which is ACC (as indicated by the red box). 
And a pixel value of 5 (indicated by the green box) represents the fifth color in the palette file, which is 9 BD (as indicated by the green box). 
This pattern continues for other pixel values." 
We stored the smaller palette file in a smaller capacity ROM, while the larger pixel file was stored in a larger capacity Block RAM. 
This design choice helps reduce latency and memory usage.
The design of storing images directly in the FPGA eliminated the need for a computer host in our gaming device. This setup allows the game to be executed anywhere without reliance on a computer host, ***making it closer to real gaming environments.***


***4. Audio_Processing:***
For the game music, we recorded it in segments during the game setup. After recording each segment of the desired audio, we paused the recording and noted the current address displayed on the seven-segment display. This address in the SRAM was then used as the finish address for that specific audio segment.
Therefore, after recording the start/finish addresses for each audio segment, Top can assign AudDSP to different address ranges based on different states. This approach allows for playing multiple different sound effects during the game.
    
***5. Random Speed:***
To enhance the game's excitement, we employed a Linear Feedback Shift Register (LFSR) as a random number generator (as shown in the diagram below). Each time the wooden figure turns around, a random speed is generated and sent to AudDSP, providing different music speeds. This creates a randomized adjustment in the player's movement time, enhancing the game's difficulty and fun.

![圖片 14](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/2021eee0-8010-4bf3-bfdb-e82aceb5da72)

***6. Laser Module:***
>To better recreate the scenes from the storyline, we incorporated laser gun elements into the game.
    
We utilized the Arduino Nano development board, SG-90 servo motor, and laser module to control the direction and signals of the laser gun.
The Top module of the game controller first receives signals from the D5M camera, indicating the presence of moving objects and their location within specific segments. If the game is in the wooden figure detection state, Top communicates these signals to Arduino via GPIO.
After receiving the firing signal, Arduino translates the segment signal into an angle signal, controlling the servo motor to rotate to a specific angle before emitting the laser light. Adding the laser feature not only enhances the interactivity beyond just the screen and camera but also increases the game's playability. The presence of the figurine on the laser module adds a unique highlight to the overall gaming experience!"
![圖片 15](https://github.com/CarlosChen1126/DCLab_final/assets/60618505/ff4da9fd-dad0-421a-b946-e96b551983a7)



## 心得

### 在修這門課以前就有耳聞數電實驗是一門相當紮實的課程，甚至號稱是電機系

大學部最紮實的課，在打這篇report的此時此刻，我回想過去的 3 個lab, bonus lab和
這次的final project，雖然沒有哪一次的lab是很輕鬆的完成，但隨著解決一個又一
個bug，我們對於FPGA和Quartus的掌握度也越來越高。從一開始連Quartus建立
project都會卡一整個晚上，然後完全不懂qsys的意義，到最後我們成功完成了一個
完全由硬體設計的 123 木頭人遊戲。在最後final project的部分，我們花了整整一週
瞭解D5M相機該如何接收到影像並存在SDRAM中，再透過VGA顯示到螢幕上，也
花了整整一週暸解該如何把圖片存在BRAM和ROM中，再透過VGA顯示到螢幕
上。看似簡單的一件事，當要脫離電腦，並以不熟悉的硬體裝置實現時，對於FPGA
新手的我們而言都變得格外困難，儘管如此我們還是一一克服，成功完成proposal
提出的所有功能，非常有成就感。



