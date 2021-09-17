Tool Description:

This tool allows users to open cone maps in csv format, edit maps by deleting, inserting, and moving cones, then save the newly edited map into a csv file.

Instructions on how to use pyqt5 map_editor GUI

Commands:

Open - CTRL+O or top left File -> Open
Desc: Opens csv file and plots cone data.

Save - CTRL+S or top left File -> Save
Desc: Saves current map data to new file.

Select_Cone - To select a cone and display its current values click on it, vertical and horizontal dashed lines will show where the selected cone currently is. To deselect click where there is no cone and you should see the lines dissapear.

Insert_Cone - user must enter desired cone values into editor, then click "Insert Cone" button.
Desc: Adds a cone to the map.
Notes: If a user enters no data for "p_exist" then it will be set by default to 1.
If a user enters no data for "color" then it will be set by default to "unk".

Move_Cone - user selects cone by clicking on the desired cone on map, then clicks "Move Cone". This will delete selected cone and place the cone at the next click the user makes on the map.
Note: If you want to copy a cone but not delete it, select desired cone, deselect the cone, then click "Move Cone", then the next click on the map will place a copy of the selected cone.

Delete_Cone - user selects cone on map with mouse click, then clicks "Delete Cone" button to remove it.
Desc: Removes selected cone from map.

Map Control:
The map uses standard matplotlib navigation toolbar seen here: https://matplotlib.org/3.1.1/users/navigation_toolbar.html

