import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import json
from collections import OrderedDict
import math

input = "jsons/codeToName.json"

inMap = OrderedDict()
with open(input, "r") as inFile:
	inMap = json.loads(inFile.read(), object_pairs_hook=OrderedDict)

data = {}
for key in inMap.keys():
	data[len(inMap[key])] = key

# Reorder by ys
orderedData = OrderedDict(sorted(data.items()))

xs = np.array([*orderedData.values()])
ys = np.array([*orderedData.keys()])

fig, ax = plt.subplots()
ax.plot(xs, ys)

ax.plot("US", ys[np.where(xs == "US")[0]], "go")

mean = np.mean(ys)
median = np.median(ys)
std = np.std(ys)

ax.axhline(y=mean, color="r")
ax.axhline(y=mean-std, color="y")
ax.axhline(y=mean+std, color="y")
ax.axhline(y=median, color="g")
print("Mean: %f    +/-1 std: %f, %f    median: %f" % (mean, mean-std, mean+std, median))

aboveIndices = np.where(ys > mean+std)[0]
aboveIsos = [xs[country] for country in aboveIndices]
print("Count above +1 std: %d" % len(aboveIsos))
print("Would loose: " + ", ".join(aboveIsos))
maxLength = math.floor(mean+std)
for aboveIso in aboveIsos:
	aboveName = inMap[aboveIso]
	print("'" + aboveName + "' (" + str(len(aboveName)) + ") => '" + aboveName[:maxLength+1] + "'")

ax.set(xlabel = "index", ylabel = "length")

ax.grid()
plt.xticks(rotation=90)
plt.show()
