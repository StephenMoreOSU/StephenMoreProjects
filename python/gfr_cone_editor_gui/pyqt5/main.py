from __future__ import print_function
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.patches import Rectangle
from matplotlib.text import Text
from matplotlib.image import AxesImage
import sys
from PyQt5.QtGui import QIcon
import csv
from PyQt5.QtWidgets import*
from PyQt5.uic import loadUi
from matplotlib.backends.backend_qt5agg import (NavigationToolbar2QT as NavigationToolbar)
import numpy as np

# For declaring structs 
from typing import NamedTuple

class ConeStructShort(NamedTuple):
    x: float
    y: float
    prb_exst: float
    prb_blu: bool
    prb_yel: bool
    prb_or: bool
    prb_OR: bool 
    prb_unk: bool
     
class ConeStructLong(NamedTuple):
    x: float
    y: float
    prb_exst: float
    prb_blu: bool
    prb_yel: bool
    prb_or: bool
    prb_OR: bool 
    prb_unk: bool
    cov_xx: float
    cov_xy: float
    cov_yx: float
    cov_yy: float

class MatplotlibWidget(QMainWindow):
    
    coneArr = []
    coneArrnp = np.asarray(coneArr)
    xCoor: float
    yCoor: float
    p_exist: float
    color: str
    cov_xx: float
    cov_xy: float
    cov_yx: float
    cov_yy: float
    selectFlag: bool
    moveFlag: bool
    xCoorMouse: float
    yCoorMouse: float
    csv_num_cols: int
    moveFlag = False
    selectFlag = False
    def __init__(self):
        QMainWindow.__init__(self)
        loadUi("qt_designer.ui",self)
        self.setWindowTitle("GFR Map Editor GUI")
        self.remove_cone.clicked.connect(self.delete_cone)
        self.insert_cone.clicked.connect(self.add_cone)
        self.move_cone.clicked.connect(self.change_cone_location)
        self.clear_editor_text.clicked.connect(self.clear_editor_text_boxes)
        self.addToolBar(NavigationToolbar(self.MplWidget.canvas, self))
        self.actionOpen.triggered.connect(self.open_dialog_box)
        self.actionSave.triggered.connect(self.save_dialog_box)
    def clear_editor_text_boxes(self):
        self.xCoorTextBox.clear()
        self.yCoorTextBox.clear()
        self.p_existText.clear()
        self.colorText.clear()
        self.cov_xxTextBox.clear()
        self.cov_xyTextBox.clear()
        self.cov_yxTextBox.clear()
        self.cov_yyTextBox.clear()
    def detect_csv_format(self,path):
        with open(path, "r") as f:
            csvlines = csv.reader(f, delimiter=',')
            for lineNum, line in enumerate(csvlines):
                self.csv_num_cols = len(line)
                return

    def open_dialog_box(self):
        try:
            filename = QFileDialog.getOpenFileName()
            path = filename[0]
            self.coneArr = []
            if (path):
                self.detect_csv_format(path)
                lineNum = 0
                with open(path, "r") as f:
                    csv_reader = csv.DictReader(f)
                    for line in csv_reader:
                        if(self.csv_num_cols > 8):
                            self.coneArr.append(ConeStructLong(line['x'],line['y'],line['prb_exst'],line['prb_blu'],line['prb_yel'],line['prb_or'],line['prb_OR'],line['prb_unk'], line['cov_xx'], line['cov_xy'], line['cov_yx'], line['cov_yy']))
                        else:
                            self.coneArr.append(ConeStructShort(line['x'],line['y'],line['prb_exst'],line['prb_blu'],line['prb_yel'],line['prb_or'],line['prb_OR'],line['prb_unk']))
                        lineNum += 1
                self.coneArrnp = np.asarray(self.coneArr, dtype = np.float32)
                self.coneArrnp = np.round(self.coneArrnp, decimals=3)
                self.update_graph_from_coneArrnp()
        except:
            pass

    def save_dialog_box(self):
        try:
            filename = QFileDialog.getSaveFileName()
            path = filename[0]
            if (path):
                with open(path,"w", newline='') as csv_file:
                    if(self.csv_num_cols > 8):
                        fieldnames = ['x','y','prb_exst','prb_blu','prb_yel','prb_or','prb_OR','prb_unk','cov_xx','cov_xy','cov_yx','cov_yy']
                    else:
                        fieldnames = ['x','y','prb_exst','prb_blu','prb_yel','prb_or','prb_OR','prb_unk']
                    csv_writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
                    csv_writer.writeheader()
                    for idx in range(self.coneArrnp.shape[0]):
                        if(self.csv_num_cols > 8):
                            csv_writer.writerow({'x': self.coneArrnp[idx,0],'y': self.coneArrnp[idx,1],'prb_exst': self.coneArrnp[idx,2],'prb_blu': int(self.coneArrnp[idx,3]),'prb_yel': int(self.coneArrnp[idx,4]),'prb_or': int(self.coneArrnp[idx,5]),'prb_OR': int(self.coneArrnp[idx,6]),'prb_unk': int(self.coneArrnp[idx,7]),'cov_xx': self.coneArrnp[idx,8],'cov_xy': self.coneArrnp[idx,9],'cov_yx': self.coneArrnp[idx,10],'cov_yy': self.coneArrnp[idx,11] })
                        else:
                            csv_writer.writerow({'x': self.coneArrnp[idx,0],'y': self.coneArrnp[idx,1],'prb_exst': self.coneArrnp[idx,2],'prb_blu': int(self.coneArrnp[idx,3]),'prb_yel': int(self.coneArrnp[idx,4]),'prb_or': int(self.coneArrnp[idx,5]),'prb_OR': int(self.coneArrnp[idx,6]),'prb_unk': int(self.coneArrnp[idx,7])})
        except:
            pass
    def add_cone(self):
        try:
            xCoortext = self.xCoorTextBox.text()
            yCoortext = self.yCoorTextBox.text()
            p_existText = self.p_existText.text()
            colorText = self.colorText.text()
            cov_xxText = self.cov_xxTextBox.text()
            cov_xyText = self.cov_xyTextBox.text()
            cov_yxText = self.cov_yxTextBox.text()
            cov_yyText = self.cov_yyTextBox.text()
            if(self.moveFlag == False):
                xCoor = float(xCoortext)
                yCoor = float(yCoortext)
                if(p_existText):
                    p_exist = float(p_existText)
                else:
                    p_exist = 1
                if(cov_xxText):
                    cov_xx = float(cov_xxText)
                else:
                    cov_xx = 0.2
                if(cov_xyText):
                    cov_xy = float(cov_xyText)
                else:
                    cov_xy = 0.2
                if(cov_yxText):
                    cov_yx = float(cov_yxText)
                else:
                    cov_yx = 0.2
                if(cov_yyText):
                    cov_yy = float(cov_yyText)
                else:
                    cov_yy = 0.2
            else:
                xCoor = self.xCoorMouse
                yCoor = self.yCoorMouse
                p_exist = self.p_exist 
                colorText = self.color 
                if(self.csv_num_cols > 8):
                    cov_xx = round(self.cov_xx,3)
                    cov_xy = round(self.cov_xy,3)
                    cov_yx = round(self.cov_yx,3)
                    cov_yy = round(self.cov_yy,3)
            if(colorText == ''):
                colorText = "unk"
            if(self.csv_num_cols > 8):
                if(colorText == "b" or colorText == "blue" or colorText == "Blue"):
                    tempCone = np.array([xCoor,yCoor,p_exist,1,0,0,0,0,cov_xx,cov_xy,cov_yx,cov_yy])
                    tempCone = np.array([tempCone])
                elif(colorText == "y" or colorText == "yellow" or colorText == "Yellow"):
                    tempCone = np.array([xCoor,yCoor,p_exist,0,1,0,0,0,cov_xx,cov_xy,cov_yx,cov_yy])
                    tempCone = np.array([tempCone])
                elif(colorText == "or" or colorText == "small orange" or colorText == "Small Orange"):
                    tempCone = np.array([xCoor,yCoor,p_exist,0,0,1,0,0,cov_xx,cov_xy,cov_yx,cov_yy])
                    tempCone = np.array([tempCone])
                elif(colorText == "OR" or colorText == "big orange" or colorText == "Big Orange"):
                    tempCone = np.array([xCoor,yCoor,p_exist,0,0,0,1,0,cov_xx,cov_xy,cov_yx,cov_yy])
                    tempCone = np.array([tempCone])
                elif(colorText == "unk" or colorText == "unkown" or colorText == "Unknown"):
                    tempCone = np.array([xCoor,yCoor,p_exist,0,0,0,0,1,cov_xx,cov_xy,cov_yx,cov_yy])
                    tempCone = np.array([tempCone])
            else:
                if(colorText == "b" or colorText == "blue" or colorText == "Blue"):
                    tempCone = np.array([xCoor,yCoor,p_exist,1,0,0,0,0])
                    tempCone = np.array([tempCone])
                elif(colorText == "y" or colorText == "yellow" or colorText == "Yellow"):
                    tempCone = np.array([xCoor,yCoor,p_exist,0,1,0,0,0])
                    tempCone = np.array([tempCone])
                elif(colorText == "or" or colorText == "small orange" or colorText == "Small Orange"):
                    tempCone = np.array([xCoor,yCoor,p_exist,0,0,1,0,0])
                    tempCone = np.array([tempCone])
                elif(colorText == "OR" or colorText == "big orange" or colorText == "Big Orange"):
                    tempCone = np.array([xCoor,yCoor,p_exist,0,0,0,1,0])
                    tempCone = np.array([tempCone])
                elif(colorText == "unk" or colorText == "unkown" or colorText == "Unknown"):
                    tempCone = np.array([xCoor,yCoor,p_exist,0,0,0,0,1])
                    tempCone = np.array([tempCone])
            self.coneArrnp = np.append(self.coneArrnp,tempCone, axis = 0)
            self.coneArrnp = np.round(self.coneArrnp, decimals=3)
            self.update_graph_from_coneArrnp()
        except:
            pass

    def delete_cone(self):
        try:
            if(self.selectFlag == False):
                xCoortext = self.xCoorTextBox.text()
                yCoortext = self.yCoorTextBox.text()
                xCoor = float(xCoortext)
                yCoor = float(yCoortext)
            else:
                xCoor = self.xCoor
                yCoor = self.yCoor
            
            findCone = np.where((self.coneArrnp[:,0] == xCoor) & (self.coneArrnp[:,1] == yCoor) )
            self.coneArrnp = np.delete(self.coneArrnp,findCone[0][0],0);
            self.update_graph_from_coneArrnp()
        except:
            pass

    def change_cone_location(self):
        try:
            if(self.moveFlag == False):
                self.moveFlag = True
                self.delete_cone()
            else:
                maxd = 1.5 #0.05
                d = np.sqrt((self.xCoor - self.xCoorMouse)**2. + (self.yCoor - self.yCoorMouse)**2.)
                if(maxd <= d):
                    self.add_cone()
                    self.moveFlag = False
                else:
                    return
        except:
            pass


    def update_graph_from_coneArrnp(self):
        self.MplWidget.canvas.axes.clear()
        findBlu = np.where(self.coneArrnp[:,3] == 1)
        bluArrx = self.coneArrnp[findBlu[0],0]
        bluArry = self.coneArrnp[findBlu[0],1]
        findYel = np.where(self.coneArrnp[:,4] == 1)
        yelArrx = self.coneArrnp[findYel[0],0]
        yelArry = self.coneArrnp[findYel[0],1]
        findor = np.where(self.coneArrnp[:,5] == 1)
        orArrx = self.coneArrnp[findor[0],0]
        orArry = self.coneArrnp[findor[0],1]
        findOR = np.where(self.coneArrnp[:,6] == 1)
        ORArrx = self.coneArrnp[findOR[0],0]
        ORArry = self.coneArrnp[findOR[0],1]
        findunk = np.where(self.coneArrnp[:,7] == 1)
        unkArrx = self.coneArrnp[findunk[0],0]
        unkArry = self.coneArrnp[findunk[0],1]
        line, = self.MplWidget.canvas.axes.plot(self.coneArrnp[:,0],self.coneArrnp[:,1],'o',color='k', picker=self.line_picker)
        line_unk, = self.MplWidget.canvas.axes.plot(unkArrx,unkArry,'o',color='k')
        line_blu, = self.MplWidget.canvas.axes.plot(bluArrx,bluArry,'o',color='b')
        line_yel, = self.MplWidget.canvas.axes.plot(yelArrx,yelArry,'o',color='y')
        line_or, = self.MplWidget.canvas.axes.plot(orArrx,orArry,'o',color='#FF6347')
        line_OR, = self.MplWidget.canvas.axes.plot(ORArrx,ORArry,'o',color='#FF0000')
        self.MplWidget.canvas.mpl_connect('pick_event', self.onpick2)
        self.MplWidget.canvas.axes.set_title('Cone Map')
        self.MplWidget.canvas.draw()

    def line_picker(self,line, mouseevent):
        """
        find the points within a certain distance from the mouseclick in
        data coords and attach some extra attributes, pickx and picky
        which are the data points that were picked
        """
        if mouseevent.xdata is None:
            return False, dict()
        xdata = line.get_xdata()
        ydata = line.get_ydata()
        maxd = 1.5 #0.05
        d = np.sqrt((xdata - mouseevent.xdata)**2. + (ydata - mouseevent.ydata)**2.)

        ind = np.nonzero(np.less_equal(d, maxd))
        if len(ind):
            pickx = np.take(xdata, ind)
            picky = np.take(ydata, ind)
            props = dict(ind=ind, pickx=pickx, picky=picky)
            return True, props
        else:
            return False, dict()

    def onpick2(self,event):
        """
        Find an if statement which will not cause an error when selecting non existant point
        """
        #if event.mouseevent.xdata:
        self.xCoorMouse = round(event.mouseevent.xdata,3)
        self.yCoorMouse = round(event.mouseevent.ydata,3)
        if(self.moveFlag == True):
            self.change_cone_location()
        self.update_graph_from_coneArrnp()
        try:
            self.MplWidget.canvas.axes.axvline(x=event.pickx[0][0],color = 'k', linestyle = '--')
            self.MplWidget.canvas.axes.axhline(y=event.picky[0][0],color = 'k', linestyle = '--')
            self.MplWidget.canvas.draw()
            self.xCoorTextBoxCurrent.setText(str(event.pickx[0][0]))
            self.yCoorTextBoxCurrent.setText(str(event.picky[0][0]))
            selectedCone = np.where((self.coneArrnp[:,0] == event.pickx[0][0]) & (self.coneArrnp[:,1] == event.picky[0][0]))
            self.p_existTextBoxCurrent.setText(str(self.coneArrnp[selectedCone[0][0],2]))
            if(self.csv_num_cols > 8):
                self.cov_xxTextBoxCurrent.setText(str(self.coneArrnp[selectedCone[0][0], 8]))
                self.cov_xyTextBoxCurrent.setText(str(self.coneArrnp[selectedCone[0][0], 9]))
                self.cov_yxTextBoxCurrent.setText(str(self.coneArrnp[selectedCone[0][0], 10]))
                self.cov_yyTextBoxCurrent.setText(str(self.coneArrnp[selectedCone[0][0], 11]))
                self.cov_xx = round(self.coneArrnp[selectedCone[0][0], 8],3)
                self.cov_xy = round(self.coneArrnp[selectedCone[0][0], 9],3)
                self.cov_yx = round(self.coneArrnp[selectedCone[0][0], 10],3)
                self.cov_yy = round(self.coneArrnp[selectedCone[0][0], 11],3)
            colorArr = self.coneArrnp[selectedCone[0][0],3:]
            findColor = np.where(colorArr == 1)
            if(findColor[0][0] == 0):
                color = "Blue"
            elif(findColor[0][0] == 1):
                color = "Yellow"
            elif(findColor[0][0] == 2):
                color = "Small Orange"
            elif(findColor[0][0] == 3):
                color = "Big Orange"
            elif(findColor[0][0] == 4):
                color = "Unknown"
            self.colorTextBoxCurrent.setText(color)
            self.xCoor = event.pickx[0][0]
            self.yCoor = event.picky[0][0]
            self.p_exist = self.coneArrnp[selectedCone[0][0],2]
            self.color = color
            self.selectFlag = True
        except:
            pass 
app = QApplication([])
window = MatplotlibWidget()
window.show()
app.exec_()