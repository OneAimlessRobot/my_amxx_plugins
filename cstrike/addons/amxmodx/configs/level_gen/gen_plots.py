import pandas as pd
import matplotlib.pyplot as plt

# Load CSV files
levels_data = pd.read_csv("level_levels.csv", header=0)
xpgain_data = pd.read_csv("level_xpgain.csv", header=0)
kills_data = pd.read_csv("level_kills.csv", header=0)
kills_custom_data = pd.read_csv("level_kills_custom.csv", header=0)

# Extracting X and Y values based on your description
levels_x = levels_data.iloc[:, 0]  # X-axis (Level numbers)
levels_y = levels_data.iloc[:, 1]  # Y-axis (XP required)

xpgain_x = xpgain_data.iloc[:, 0]  # X-axis (Level numbers)
xpgain_y = xpgain_data.iloc[:, 1]  # Y-axis (XP given per level)

kills_x = kills_data.iloc[:, 0]  # X-axis (Level numbers)
kills_y = kills_data.iloc[:, 1]  # Y-axis (XP given per level)

kills_custom_x = kills_custom_data.iloc[:, 0]  # X-axis (Level numbers)
kills_custom_y = kills_custom_data.iloc[:, 1]  # Y-axis (XP given per level)

plt.figure(figsize=(14, 6))

# Plotting XP required per level
plt.subplot(1, 3, 1)
plt.plot(levels_x, levels_y, marker='o', color='b')
plt.xlabel(levels_x.name)
plt.ylabel(levels_y.name)

plt.plot(xpgain_x, xpgain_y, marker='o', color='g')
plt.xlabel(xpgain_x.name)
plt.ylabel(xpgain_y.name)
plt.title("LEVELL vs XPGAIN/XPNEEDED")
plt.grid(True)

# Plotting XP required per level
plt.subplot(1, 3, 2)
plt.plot(kills_x, kills_y, marker='o', color='g')
plt.xlabel(kills_x.name)
plt.ylabel(kills_y.name)
plt.title("LEVEL VS KILLS NEEDED")
plt.grid(True)

# Plotting XP required per level
plt.subplot(1, 3, 3)
plt.plot(kills_custom_x, kills_custom_y, marker='o', color='g')
plt.xlabel(kills_custom_x.name)
plt.ylabel(kills_custom_y.name)
plt.title("LEVEL VS KILLS NEEDED 2")
plt.grid(True)

plt.tight_layout()
plt.show()
