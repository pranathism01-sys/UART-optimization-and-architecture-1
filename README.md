# UART High-Throughput IP Core

**Design and Optimization of a High-Throughput, Low-Latency UART Architecture**  
Bangalore Institute of Technology | Dept. of ECE | Major Project 2026

[![Build](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Formal](https://img.shields.io/badge/formal-TBD-lightgrey)]()
[![PDK](https://img.shields.io/badge/PDK-Sky130-blue)]()
[![License](https://img.shields.io/badge/license-MIT-blue)]()

---

## Overview

A parameterized, synthesizable UART IP core in Verilog targeting baud rates up to **10 Mbps** — a 100× improvement over the 115200 bps baseline — featuring:

| Feature | Specification |
|---------|--------------|
| Baud Rate | 9600 bps – 10 Mbps (runtime configurable) |
| Baud Error | < 0.5% (fractional divisor) |
| Buffering | Hardware FIFO, depth 8 / 16 / 32 / 64 |
| Error Detection | Framing, Parity, Overrun, Noise (majority vote) |
| SoC Interface | APB / Wishbone memory-mapped registers |
| Verification | Constrained-random + SymbiYosys SVA proofs |
| Synthesis Target | Yosys → Sky130 HD PDK |
| Toolchain | 100% open-source |

---

## Repository Structure

```
uart-ip/
├── rtl/                  # Synthesizable Verilog RTL
│   ├── baud_gen.v        # Fractional baud rate generator
│   ├── uart_tx.v         # Transmitter FSM
│   ├── uart_rx.v         # Receiver FSM (16x oversampling)
│   ├── uart_fifo.v       # Parameterized synchronous FIFO
│   └── uart_top.v        # APB/Wishbone register-mapped top-level
├── tb/                   # Testbenches
│   ├── tb_uart_loopback.v   # Self-checking loopback (all baud + parity modes)
│   ├── tb_uart_fifo.v       # FIFO unit tests
│   ├── tb_baud_gen.v        # Baud generator accuracy tests
│   └── tb_uart_top.v        # APB register interface tests
├── syn/                  # Synthesis
│   ├── synth.ys             # Yosys synthesis script (Sky130 PDK)
│   └── sta.tcl              # OpenSTA timing analysis script
├── formal/               # Formal verification (SymbiYosys)
│   ├── uart_tx_formal.sby
│   └── uart_rx_formal.sby
├── scripts/              # Python analysis scripts
│   ├── ber_sweep.py         # BER + throughput characterization
│   └── area_sweep.py        # FIFO depth × oversampling trade-off sweep
├── sim/                  # Simulation outputs (gitignored)
├── docs/                 # Documentation and generated plots
│   └── TOOLCHAIN_SETUP.md
├── Makefile              # Build system
└── README.md
```

---

## Quick Start

### 1. Install Tools

```bash
sudo apt install iverilog gtkwave yosys verilator
pip3 install symbiyosys matplotlib numpy
```

See [docs/TOOLCHAIN_SETUP.md](docs/TOOLCHAIN_SETUP.md) for full instructions.

### 2. Clone and Run

```bash
git clone https://github.com/<your-org>/uart-ip.git
cd uart-ip
make sim          # simulate and run loopback testbench
make wave         # view waveforms in GTKWave
make lint         # lint RTL with Verilator
make synth        # synthesize to Sky130 PDK
make formal       # run SymbiYosys SVA proofs
```

### 3. Override Parameters

```bash
make sim FIFO_DEPTH=32 BAUD_RATE=1000000
make sim FIFO_DEPTH=64 BAUD_RATE=10000000
```

---

## Register Map

| Offset | Name    | Bits  | Description |
|--------|---------|-------|-------------|
| 0x00   | CTRL    | [7:0] | `parity_en`, `parity_odd`, `stop_bits`, `tx_en`, `rx_en` |
| 0x04   | STATUS  | [7:0] | `tx_busy`, `rx_valid`, `framing_err`, `parity_err`, `overrun_err`, `noise_err`, `tx_full`, `rx_empty` |
| 0x08   | DATA    | [7:0] | Write → TX FIFO, Read → RX FIFO |
| 0x0C   | BAUD    |[15:0] | Runtime baud divisor |

---


---

## Expected Outcomes

- ✅ Baud rates up to 10 Mbps (100× over baseline)
- ✅ Zero data loss under CPU load (hardware FIFO)
- ✅ Formal proof: no TX corruption, FSM liveness, FIFO safety
- ✅ Quantified area/timing curves via Yosys + Sky130
- ✅ Drop-in SoC integration via APB/Wishbone

---


## License

MIT License — see [LICENSE](LICENSE)
