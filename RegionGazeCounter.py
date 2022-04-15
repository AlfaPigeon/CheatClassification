from itertools import count
from typing import List

class RegionGazeCounter:
    multiplier = 0.995
    threshold = 60
    def __init__(self):
        self.regions:List[Region] = []
    
    def updateAndCountLookedRegionCount(self, newAngle):
        inRegion:List[Region] = []
        for region in self.regions:
            region.count *= self.multiplier
            if region.isInRegion(newAngle):
                inRegion.append(region)
        if len(inRegion) == 0:
            self.regions.append(Region(newAngle))
        else:
            minDist = None
            minRegion = None
            for region in inRegion:
                dist = region.distanceToAngle(newAngle)
                if minDist is None or dist < minDist:
                    minDist = dist
                    minRegion = region
            minRegion.update(newAngle)
        count = 0
        for region in self.regions:
            if region.count > self.threshold:
                count += 1
        if count < 2:
            return 0
        elif count == 3:
            return 0.3
        elif count == 4:
            return 0.7
        else:
            return 1

class Region:
    angleDif = 20
    def __init__(self,center):
        self.center=center
        self.count = 1

    def update(self,newAngle):
        self.center[0] = (self.center[0] * self.count + newAngle[0]) / (self.count+1)
        self.center[1] = (self.center[1] * self.count + newAngle[1]) / (self.count+1)
        self.count = self.count + 1

    def isInRegion(self,point):
        if abs(point[0]-self.center[0]) < self.angleDif and abs(point[1]-self.center[1]) < self.angleDif :
            return True
        else:
            return False
    def distanceToAngle(self,point):
        return (point[0]-self.center[0])*(point[0]-self.center[0])+(point[1]-self.center[1])*(point[1]-self.center[1])
