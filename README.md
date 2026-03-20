# **EVENTS Tools 1.03**  

Event Tools helps you add common **Practice Sections** to your Reaper charts with the click of a button. You can also add text events like **[music_start]**, **[music_end]**, **[end]**, or any Crowd Clapping event too!

**<ins>All buttons create markers or text events at the current play head position</ins>**.

This project is a fork of EVENT Tools (https://github.com/RaiderGG/EVENTS-Tools).
  
<img width="1220" height="875" alt="Event Tools Fork" src="https://github.com/user-attachments/assets/ce4a5699-290f-4b28-bd33-6fa6f1814d63" />

## **Requirements**  
The simplest way to get scripts working in Reaper is to follow the Milohax Reaper setup guide here: https://guides.milohax.org/en/charting/reaper/. This guide includes installing the SWS Extensions and includes the other files that you need.
Otherwise you need to install SWS Extensions, ReaPack, and Realmgui manually. Note: You can install RealmGui via ReaPack.
https://sws-extension.org/
https://reapack.com/

## Adding Practice Section Markers
Practice section buttons are arranged in a logical order. Position the playhead where you want to create a marker and then click a practice section button. A color coded marker is created and the button changes color to match the marker. This gives you a visual map to refer to so that you know which markers you have already placed.

<img width="1212" height="595" alt="EVENT Tools - Track Practice Sections Used" src="https://github.com/user-attachments/assets/66a13120-2f79-4a2d-8eba-0d3c5132b509" />


## Search For Practice Section Markers 

Only commonly used practice sections have a dedicated button. For all other practice sections use the **Search** field to find the practice section that you need. Type a full or partial search and then click the drop down arrow to view the results. Click on the required practice section to create the text event.

<img width="305" height="448" alt="Search Drop Down" src="https://github.com/user-attachments/assets/8668e1a1-538e-4577-b13a-7c6af1368005" />

## Convert Practice Section Markers to EVENTS Track Text Events

When you have created all your practice section markers, click the "Copy Markers to EVENTS Track" button. This will convert your markers to text events in the EVENTS Track. Markers are converted to the proper **[prc_(section)]** format. 

<img width="1291" height="388" alt="EVENT Tools - Create Practice Section Text Events" src="https://github.com/user-attachments/assets/95dd3e87-e153-4fda-a77f-f4a8fd404402" />

## Music events  
Add [music_start], [music_end], and [end]  text events. (EVENTS track only).
  
<img width="1219" height="407" alt="Music Events" src="https://github.com/user-attachments/assets/a0cdb5e0-f950-4590-8991-d6d79c8d18cf" />

## Crowd Clap  
Activate or deactivate the crowd's claps. (EVENTS track only).
  
<img width="1219" height="407" alt="Crowd Clap" src="https://github.com/user-attachments/assets/449a9de0-4121-4351-aa5a-a8cd62740ce7" />

## Crowd intensity  
Change the intensity of the crowd between **mellow**, **normal**, **intense**, or **realtime**. (EVENTS track only).
  
<img width="1219" height="407" alt="Crowd Intensity" src="https://github.com/user-attachments/assets/6e5ed6cd-02fc-49c7-a4b8-98d0170413c9" />

## Undocumented Text Events
Add undocumented crowd events for special situations. These special events turn crowd fists, horns, and lighters on and off. Each state must be turned on and off, so each pair of buttons is color coded with counters. An orange button shows a missing text event. 

<img width="1219" height="407" alt="Undocumented Events" src="https://github.com/user-attachments/assets/a0498570-2512-428b-b936-8c7c5a43eee8" />

## Installation
**Note**: EVENT Tools reqiures a modern version of Reaper to run. 

Download and extract files to your Reaper Scripts folder (C:\Users\<username>\AppData\Roaming\REAPER\Scripts\EventsTools).

**Note**: You need to have hidden items enabled in **File Explorer** to access the AppData folder. In File Explorer click **View** > **Show** > **Hidden Items**. 

<img width="810" height="780" alt="Windows Explorer" src="https://github.com/user-attachments/assets/e48f59e4-1475-4202-8b28-e36c78839dc2" />

In Reaper, click **Actions** > **Show action list**.

In the **Actions** window Click the **New action** button, then click **Load ReaScript**.

<img width="617" height="482" alt="Load ReaScript" src="https://github.com/user-attachments/assets/71760608-df0c-4fe3-8e26-1ed3ca8aad98" />

Browse to C:\Users\<username>\AppData\Roaming\REAPER\Scripts\EventsTools. Select **Events Toola.lua** and then click the **Open** button.

In the **Actions** window, select **Script: Events Tools.lua** from the list. Click the **Add** button. The **Keyboard/MIDI/OSC Input** window will open. Press the **F7** key. Click the **OK** button.

<img width="933" height="437" alt="Assign Shortcut" src="https://github.com/user-attachments/assets/485b7741-db10-4ee5-b98c-93e0c21b19e4" />

Click the **Close** button in the **Actions** window.

Installation is now complete. 

Launch EVENT Tools by pressing the **F7** key.



