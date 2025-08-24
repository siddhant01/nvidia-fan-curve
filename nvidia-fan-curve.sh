#!/usr/bin/env bash
GPU=0
SLEEP=5
CURVE="40:29 52:45 60:75 67:88 75:100"
SAFETY_MAX=85   # Force 100% fan if temp >= this (°C)

notify_error() {
    notify-send -u critical "NVIDIA Fan Curve Error" "$1"
    echo "[ERROR] $1" >&2
}

# Enable manual fan control at GPU level
if ! nvidia-settings -a "[gpu:$GPU]/GPUFanControlState=1" >/dev/null 2>&1; then
    notify_error "Failed to enable manual fan control. Check Coolbits and X11 session."
    exit 1
fi

# Set power limit to 330W (needs sudo unless you add a sudoers rule)
if ! sudo nvidia-smi -i $GPU -pl 330 >/dev/null 2>&1; then
    notify_error "Failed to set power limit to 330W"
else
    echo "[INFO] Power limit set to 330W"
fi

# Detect available fan targets (fan:0, fan:1, ...)
FAN_IDS=()
for i in 0 1 2 3; do
    if nvidia-settings -q "[fan:$i]/GPUTargetFanSpeed" >/dev/null 2>&1; then
        FAN_IDS+=("$i")
    fi
done
if [ ${#FAN_IDS[@]} -eq 0 ]; then
    notify_error "No fan targets found via nvidia-settings"
    exit 1
fi
echo "[INFO] Detected fans: ${FAN_IDS[*]}"

set_fan_speed_all() {
    local speed="$1"
    for fid in "${FAN_IDS[@]}"; do
        if ! nvidia-settings -a "[fan:$fid]/GPUTargetFanSpeed=$speed" >/dev/null 2>&1; then
            notify_error "Failed to set fan $fid to $speed%"
        fi
    done
}

echo "[INFO] Fan curve script started"
while true; do
    TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits -i $GPU 2>/dev/null)
    if [[ -z "$TEMP" ]]; then
        notify_error "Failed to read GPU temperature"
        sleep "$SLEEP"
        continue
    fi

    SPEED=0
    for POINT in $CURVE; do
        T=${POINT%%:*}
        F=${POINT##*:}
        if (( TEMP >= T )); then
            SPEED=$F
        fi
    done
    # Safety override
    if (( TEMP >= SAFETY_MAX )); then
        SPEED=100
    fi

    set_fan_speed_all "$SPEED"
    echo "[$(date '+%H:%M:%S')] Temp=${TEMP}°C → Fans=${SPEED}% (fans: ${FAN_IDS[*]})"
    sleep "$SLEEP"
done
