#!/usr/bin/env python3
"""
ber_sweep.py — BER and throughput measurement across baud rates
Runs Icarus Verilog simulation at each baud rate, parses pass/fail counts,
plots BER vs baud rate and throughput vs baud rate.

Output: docs/ber_plot.pdf
"""

import subprocess
import matplotlib.pyplot as plt
import numpy as np
import os

BAUD_RATES   = [9_600, 115_200, 500_000, 1_000_000, 5_000_000, 10_000_000]
CLK_FREQ     = 50_000_000
FRAMES       = 1000
SIM_BIN      = "sim/uart_sim"
DOCS_DIR     = "docs"

def run_simulation(baud_rate: int) -> dict:
    """Compile and run simulation for a given baud rate, return stats."""
    cmd = [
        "iverilog", "-g2012",
        f"-DBAUD_RATE={baud_rate}",
        f"-DCLK_FREQ={CLK_FREQ}",
        "-I", "rtl",
        "-o", SIM_BIN,
        *[f"rtl/{m}" for m in ["baud_gen.v","uart_tx.v","uart_rx.v",
                                "uart_fifo.v","uart_top.v"]],
        "tb/tb_uart_loopback.v"
    ]
    subprocess.run(cmd, check=True, capture_output=True)

    result = subprocess.run(["vvp", SIM_BIN], capture_output=True, text=True)
    stdout = result.stdout

    # TODO: parse PASS/FAIL counts from simulation stdout
    pass_count = 0
    fail_count = 0
    for line in stdout.splitlines():
        if line.startswith("PASS:"):
            parts = line.split()
            pass_count = int(parts[1])
            fail_count = int(parts[3])

    total  = pass_count + fail_count
    ber    = fail_count / total if total > 0 else 0
    tput   = baud_rate * (1 - ber) / 1e6  # effective Mbps

    return {"baud": baud_rate, "ber": ber, "throughput_mbps": tput,
            "pass": pass_count, "fail": fail_count}


def plot_results(results: list):
    baud_labels = [f"{r['baud']//1000}k" if r['baud'] < 1_000_000
                   else f"{r['baud']//1_000_000}M"
                   for r in results]
    bers   = [r['ber']             for r in results]
    tputs  = [r['throughput_mbps'] for r in results]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle("UART BER and Throughput vs Baud Rate", fontsize=14)

    ax1.semilogy(baud_labels, [max(b, 1e-10) for b in bers], 'ro-', linewidth=2)
    ax1.set_xlabel("Baud Rate")
    ax1.set_ylabel("Bit Error Rate (BER)")
    ax1.set_title("BER vs Baud Rate")
    ax1.grid(True, which='both', alpha=0.4)
    ax1.axhline(y=1e-6, color='g', linestyle='--', label='BER = 1e-6 target')
    ax1.legend()

    ax2.bar(baud_labels, tputs, color='steelblue')
    ax2.set_xlabel("Baud Rate")
    ax2.set_ylabel("Effective Throughput (Mbps)")
    ax2.set_title("Throughput vs Baud Rate")
    ax2.grid(True, axis='y', alpha=0.4)

    os.makedirs(DOCS_DIR, exist_ok=True)
    out_path = f"{DOCS_DIR}/ber_plot.pdf"
    plt.tight_layout()
    plt.savefig(out_path)
    print(f"[BER] Plot saved: {out_path}")
    plt.show()


if __name__ == "__main__":
    print("=== BER Sweep ===")
    results = []
    for br in BAUD_RATES:
        print(f"  Running @ {br} bps ...", end=" ", flush=True)
        try:
            r = run_simulation(br)
            results.append(r)
            print(f"BER={r['ber']:.2e}  Throughput={r['throughput_mbps']:.2f} Mbps")
        except Exception as e:
            print(f"FAILED: {e}")

    if results:
        plot_results(results)
