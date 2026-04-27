# UART Project — Toolchain Setup Guide
**Bangalore Institute of Technology | ECE Dept. | 2026**

This guide installs the full open-source EDA toolchain on **Ubuntu 22.04 / 24.04** (or WSL2 on Windows).

---

## Quick Install (copy-paste the whole block)

```bash
sudo apt update && sudo apt upgrade -y

# Core simulation + synthesis
sudo apt install -y iverilog gtkwave yosys verilator

# Python + plotting
sudo apt install -y python3 python3-pip
pip3 install matplotlib numpy

# SymbiYosys (formal verification)
pip3 install symbiyosys
sudo apt install -y boolector z3

# OpenSTA (static timing analysis)
sudo apt install -y opensta

# LaTeX (for report)
sudo apt install -y texlive-full
```

---

## Step-by-Step (if the quick install fails)

### 1. Icarus Verilog + GTKWave
```bash
sudo apt install iverilog gtkwave
iverilog -V   # should print Icarus Verilog version
```

### 2. Yosys
```bash
sudo apt install yosys
yosys --version
```
If the apt version is too old (< 0.20), build from source:
```bash
git clone https://github.com/YosysHQ/yosys
cd yosys && make -j$(nproc) && sudo make install
```

### 3. Verilator (linting)
```bash
sudo apt install verilator
verilator --version
```

### 4. SymbiYosys (formal verification)
```bash
# Option A — pip (easiest)
pip3 install symbiyosys

# Option B — OSS CAD Suite (recommended, bundles all tools)
# Download from: https://github.com/YosysHQ/oss-cad-suite-build/releases
# Extract and add to PATH:
export PATH="/path/to/oss-cad-suite/bin:$PATH"

# Solvers (required by sby)
sudo apt install boolector z3
sby --version
```

### 5. OpenSTA
```bash
sudo apt install opensta
# OR build from source:
# https://github.com/The-OpenROAD-Project/OpenSTA
```

### 6. Sky130 PDK (liberty file for synthesis)
```bash
# Install via volare (manages PDK versions)
pip3 install volare
volare enable --pdk sky130 latest

# Liberty file will be at:
# ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
# Copy it to your project's syn/ directory:
cp ~/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib syn/
```

---

## Verify Everything Works

```bash
# From the project root:
make check-tools
```

Expected output:
```
  ✓ iverilog
  ✓ gtkwave
  ✓ yosys
  ✓ sby
  ✓ verilator
  ✓ python3
  ✓ opensta
```

---

## Windows (WSL2) Notes

1. Install WSL2: `wsl --install` in PowerShell (Admin)
2. Open Ubuntu terminal and follow all steps above
3. For GTKWave GUI on Windows: install an X server like **VcXsrv** or use **WSLg** (Windows 11)
4. All Makefile targets work identically inside WSL2

---

## macOS Notes

```bash
brew install icarus-verilog gtkwave yosys verilator python3
pip3 install matplotlib numpy symbiyosys
# OpenSTA: build from source (no brew formula)
```

---

## First Smoke Test

After installation, run this to confirm the toolchain end-to-end:

```bash
# From project root
make sim        # should print "ALL TESTS PASSED ✓"
make lint       # should print "Passed."
make check-tools
```

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `iverilog: command not found` | `sudo apt install iverilog` |
| `sby: command not found` | `pip3 install symbiyosys` or use OSS CAD Suite |
| `Cannot find liberty file` | Copy Sky130 .lib to `syn/` (see step 6 above) |
| GTKWave opens but no waveform | Run `make sim` first to generate the VCD file |
| Yosys `WARNING: [...]` | Check `syn/synth.log` — critical warnings must be zero |
