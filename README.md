# **EVENTS Tools**  

Event Tools helps you add common **Practice Sections** to your Reaper charts with the click of a button. You can also add text events like **[music_start]**, **[music_end]**, **[end]**, or any Crowd Clapping event too!

**<ins>All buttons create markers or text events at the current play head position</ins>**.

This project is a fork of EVENT Tools (https://github.com/RaiderGG/EVENTS-Tools).
  
<img width="1220" height="680" alt="EVENT Tools - Main Window" src="https://github.com/user-attachments/assets/f724c968-542e-4dde-bea4-567b01360402" />
  
## **Requirements**  
Event Tools requires **ReaImGui**. You can install it via **ReaPack** (https://reapack.com/).

## Adding Practice Section Markers
Practice section buttons are arranged in a logical order. Position the playhead where you want to create a marker and then click a practice section button. A color coded marker is created and the button changes color to match the marker. This gives you a visual map to refer to so that you know which markers you have already placed.

<img width="1514" height="796" alt="EVENT Tools - Track Practice Sections Used" src="https://github.com/user-attachments/assets/5fa3fa20-1020-44bd-bafd-61ac631342ba" />

## Convert Practice Section Markers to EVENTS Track Text Eevenst

When you have created all your practice section markers, click the "Copy Markers to EVENTS Track" button. This will convert your markers to text events in the EVENTS Track. Markers are converted to the proper **[prc_(section)]** format. 

<img width="1553" height="822" alt="EVENT Tools - Create Practice Section Text Events" src="https://github.com/user-attachments/assets/709910b0-545c-40d4-ad74-66fa4c278fdf" />
  
## Music events  
Add [music_start], [music_end], and [end]  text events. (EVENTS track only).
  
<img width="1221" height="330" alt="Music Events" src="https://github.com/user-attachments/assets/f7ca9c86-cb54-4d5b-bdb4-ed0793025e80" />

## Crowd Clap  
Activate or deactivate the crowd's claps. (EVENTS track only).
  
<img width="1221" height="330" alt="Crowd Clap" src="https://github.com/user-attachments/assets/ac497e16-c2eb-4519-875e-2c227b277e54" />
  
## Crowd intensity  
Change the intensity of the crowd between **mellow**, **normal**, **intense**, or **realtime**. (EVENTS track only).
  
<img width="1221" height="330" alt="Crowd Intensity" src="https://github.com/user-attachments/assets/2ff85b9f-96e8-4bd3-8b03-4cac840a2b26" />

## Installation
**Note**: EVENT Tools reqiures a modern version of Reaper to run. 

Download and extract files to your Reaper Scripts folder (C:\Users\<username>\AppData\Roaming\REAPER\Scripts\EventsTools).

**Note**: You need to have hidden items enabled in **File Explorer** to access the AppData folder. In File Explorer click **View** > **Show** > **Hidden Items**. 

<img width="790" height="569" alt="Windows Explorer" src="https://github.com/user-attachments/assets/f2029a33-8b1c-40ed-b36b-2e6980954177" />

In Reaper, click **Actions** > **Show action list**.

In the **Actions** window Click the **New action** button, then click **Load ReaScript**.

<img width="617" height="482" alt="Load ReaScript" src="https://github.com/user-attachments/assets/71760608-df0c-4fe3-8e26-1ed3ca8aad98" />

Browse to C:\Users\<username>\AppData\Roaming\REAPER\Scripts\EventsTools. Select **Events Toola.lua** and then click the **Open** button.

In the **Actions** window, select **Script: Events Tools.lua** from the list. Click the **Add** button. The **Keyboard/MIDI/OSC Input** window will open. Press the **F7** key. Click the **OK** button.

<img width="933" height="437" alt="Assign Shortcut" src="https://github.com/user-attachments/assets/485b7741-db10-4ee5-b98c-93e0c21b19e4" />

Click the **Close** button in the **Actions** window.

Installation is now complete. 

Launch EVENT Tools by pressing the **F7** key.



