# nvidia-fan-curve
Nvidia-fan-curve for custom fan curve for Linux

🌀 NVIDIA Fan Curve Script for RTX 3090 FE

A lightweight bash script to control NVIDIA GPU fans on Linux without needing GreenWithEnvy (GWE) or Flatpak.

It sets a custom fan curve and applies a 330W power limit, keeping your GPU cool and efficient — all running automatically at startup.

✨ Features

✅ Simple bash script — no external GUIs or Flatpak needed

✅ Customizable fan curve with temperature thresholds

✅ Applies a 330W power limit automatically

✅ Supports multiple GPU fans

✅ Runs at startup & shows desktop notifications on errors

✅ Does not write to disk continuously (avoids SSD wear)

⚙️ Requirements

NVIDIA driver installed with Coolbits=4 or higher enabled


🔧 Default Fan Curve

Temperature → Fan Speed

≤39 °C → 0%

40 °C → 29%

52 °C → 45%

60 °C → 75%

67 °C → 88%

75 °C → 100%

You can edit these values inside the script:

CURVE="40:29 52:45 60:75 67:88 75:100"

⚡ Power Limit

The script also applies:

nvidia-smi -pl 330


Adjust if you want a different limit.

❓ FAQ

Q: Will this damage my GPU?
A: No — it only calls NVIDIA’s official APIs (nvidia-smi, nvidia-settings). It doesn’t flash or write firmware.

Q: Why do I need sudo?
A: NVIDIA utilities require elevated privileges to change fan speed and power limits.

Q: I have multiple GPUs. Can I control them?
A: Yes — change GPU=0 to another index in the script.


🤝 Contributing

Feel free to fork, tweak, and submit pull requests.
Issues and feature requests welcome!

📜 License

MIT License – use freely, modify as you like.

🔥 Possible Improvements

Here are 2 small enhancements you might consider before publishing:

Config file support → allow users to set curve + power limit in ~/.config/nvidia-fan-curve.conf instead of editing the script.

Dynamic fan curve preview → print the current curve once at startup for clarity.
