# UART Peripheral Design

A configurable UART (Universal Asynchronous Receiver-Transmitter) IP core designed with FSM-based protocol control, synthesized using OpenLane with SkyWater 130nm PDK.

##  Project Overview

This project implements a complete UART peripheral with the following features:

- **Configurable baud rate generation** via programmable clock divider
- **FSM-based transmitter and receiver** for robust protocol control
- **Memory-mapped register interface** for easy integration
- **Interrupt support** for received data notification
- **Ultra-low power consumption** (< 0.4 µW)
- **Compact silicon footprint** (< 7,200 µm²)

##  Project Structure

```
.
├── src/
│   ├── uart/
│   │   ├── uart_tx.v          # UART transmitter module
│   │   ├── uart_rx.v          # UART receiver module
│   │   └── baud_gen.v         # Baud rate generator
│   ├── test/
│   │   ├── test.py            # Cocotb testbench
│   │   ├── tb.v               # Verilog testbench wrapper
│   │   └── Makefile           # Test configuration
│   └── test_harness/
│       └── *.sv               # SystemVerilog verification modules
├── peripheral.v               # Top-level UART peripheral wrapper
├── tt_wrapper.v              # TinyTapeout integration wrapper
├── config.json               # OpenLane synthesis configuration
├── synthesize.ys             # Yosys synthesis script
└── UART_Peripheral_PPA_Report.pdf  # Detailed PPA analysis
```

##  Features

### Core Functionality
- **8-bit data transmission/reception**
- **Configurable baud rate** (default: 115200 with 64 MHz clock)
- **Start bit, 8 data bits, 1 stop bit** (standard UART framing)
- **Full-duplex operation**

### Design Highlights
- **FSM-based design** for TX and RX state machines
- **Synchronous design** with single clock domain
- **Active-low reset** for standard integration
- **Busy/valid signaling** for flow control

### Register Map
| Address | Name | Access | Description |
|---------|------|--------|-------------|
| 0x00 | TX_DATA | W | Write byte to transmit |
| 0x00 | TX_STATUS | R | Read transmitter busy status |
| 0x04 | RX_DATA | R | Read received byte |

## 📊 Performance Metrics (PPA)

### Power
- **Total Power:** 0.386 µW
  - Internal: 0.275 µW (71.2%)
  - Switching: 0.109 µW (28.2%)
  - Leakage: 0.0024 µW (0.6%)

### Performance
- **Target Frequency:** 50 MHz
- **Critical Path:** 1.7 ns
- **Timing Slack:** 18.3 ns (excellent margin)
- **No setup/hold violations** ✅

### Area
- **Core Area:** 7,175.63 µm²
- **Die Area:** 10,335.53 µm²
- **Cell Count:** 354 logic cells
- **Utilization:** 42.79%

**Full analysis available in:** [UART_Peripheral_PPA_Report.pdf](./UART_Peripheral_PPA_Report.pdf)

## 🛠️ Synthesis

The design was synthesized using **OpenLane v1.0.2** with the **SkyWater Sky130A PDK**.

### Synthesis Flow
```bash
cd OpenLane
make mount
./flow.tcl -design DP_1
```

### Configuration
- **PDK:** sky130A
- **Standard Cell Library:** sky130_fd_sc_hd
- **Clock Period:** 20 ns (50 MHz)
- **Core Utilization:** 40%
- **Strategy:** AREA optimization

## 🧪 Testing & Verification

Test infrastructure includes:
- Cocotb-based Python testbenches
- Verilog testbench wrappers
- SystemVerilog verification components

### Running Tests
```bash
cd src/test
make
```

## 📋 Module Descriptions

### baud_gen.v
Generates the baud rate tick signal by dividing the system clock. Configurable via `CLKS_PER_BIT` parameter.

**Parameters:**
- `CLKS_PER_BIT` - Clock cycles per bit (default: 555 for 115200 baud @ 64MHz)

### uart_tx.v
Transmitter module implementing a 4-state FSM:
- **IDLE:** Waiting for data
- **START:** Transmitting start bit
- **DATA:** Transmitting 8 data bits
- **STOP:** Transmitting stop bit

### uart_rx.v
Receiver module implementing a 4-state FSM with mid-bit sampling:
- **IDLE:** Waiting for start bit
- **START:** Verifying start bit
- **DATA:** Sampling 8 data bits
- **STOP:** Verifying stop bit

### peripheral.v (tqvp_zul_uart)
Top-level integration module providing:
- Memory-mapped register interface
- Interrupt generation on RX data
- Integration of TX, RX, and baud generator

## 🔧 Configuration & Customization

### Changing Baud Rate
Modify the `CLKS_PER_BIT` parameter in `peripheral.v`:

```verilog
parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
```

**Examples:**
- 115200 baud @ 64MHz: `CLKS_PER_BIT = 555`
- 9600 baud @ 64MHz: `CLKS_PER_BIT = 6667`
- 115200 baud @ 50MHz: `CLKS_PER_BIT = 434`

## 📐 Design Specifications

| Specification | Value |
|--------------|-------|
| Technology | SkyWater 130nm |
| Supply Voltage | 1.8V nominal |
| Max Frequency | 50 MHz |
| Data Width | 8 bits |
| Default Baud Rate | 115200 |
| Interface | Memory-mapped |
| Reset Type | Active-low asynchronous |

## 🎓 Design Methodology

1. **RTL Design** - Verilog HDL modules
2. **Functional Simulation** - Cocotb testbenches
3. **Synthesis** - Yosys via OpenLane
4. **Place & Route** - OpenROAD via OpenLane
5. **Physical Verification** - Magic DRC, LVS checks
6. **Timing Analysis** - OpenSTA

## 📝 Design Quality

✅ **Zero DRC violations**  
✅ **Zero LVS errors**  
✅ **Zero antenna violations**  
✅ **Timing closure achieved**  
✅ **Production-ready layout**

## 🚦 Design Status

- [x] RTL design complete
- [x] Synthesis successful
- [x] Place & route complete
- [x] Physical verification passed
- [x] Timing analysis passed
- [ ] Comprehensive verification suite (in progress)
- [ ] Coverage analysis (planned)

## 📚 Documentation

- [PPA Analysis Report (PDF)](./UART_Peripheral_PPA_Report.pdf) - Detailed power, performance, and area analysis
- [Synthesis Metrics (CSV)](./metrics.csv) - Raw synthesis data from OpenLane

## 🤝 Contributing

This project is part of a digital design portfolio. Suggestions and improvements are welcome!

## 📄 License

Copyright (c) 2025 Suliat Saka (zul)  
SPDX-License-Identifier: Apache-2.0

## 🔗 Related Resources

- [OpenLane Documentation](https://openlane.readthedocs.io/)
- [SkyWater PDK](https://github.com/google/skywater-pdk)
- [Cocotb Documentation](https://docs.cocotb.org/)

## 📧 Contact

**Author:** Suliat Saka (zul)  


---

*Designed and synthesized using open-source EDA tools with the SkyWater 130nm process.*