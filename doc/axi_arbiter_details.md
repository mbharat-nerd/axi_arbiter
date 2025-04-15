# AXI ARBITER:  Details

Recall that an arbiter resolves access from multiple masters to a single slave.  Now, the master (slave) `AXI` protocol may either be memory-mapped or streaming.  Hence it is vital that our arbiter is parameterized thoroughly, so it can be reused say in a crossbar or NoC.

Hence we will first discuss the interface types in `AXI`.

## Interface Types in AXI Ecosystems

There are two main classes of interfaces in AMBA/AXI based systems:

| Interface Type | Use Case                      | Examples      |
| -------------- | ----------------------------- | ------------- |
| Memory-Mapped  | Addressable registers/memory  | AXI, AXI-Lite |
| Streaming      | Continuous data (no addr)     | AXI-Stream (AXIS) |

With respect to the AXI channel signals, a `*LAST` (`TLAST`, `WLAST`, `RLAST`) occur in either streaming (`AXIS`; `TLAST`) or burst interfaces (`AXI`; `WLAST`, `RLAST`).  `AXI-Lite` does not support bursting, so the `*LAST` signals do not exist in `AXI-Lite`

## High level Overview of the AXI Arbiter

Based on the discussion in the previous section, we can see the following features and modes for the arbiter.

| Feature        | Mode 1        | Mode 2      | Notes                   |
| -------------- | ------------- | ----------  | ----------------------- |
| Protocol       | AXI-Lite      | AXI         | AXI adds bursts, IDs    |
| Interface type | Memory-Mapped | Streaming   | AXIS has no address     |
| Arbitration    | Priority      | Round-Robin | Could extend to dynamic |

To start out in this design, we focused on AXI-Lite MM (Memory-Mapped) priority based interface first.  Hence we will discuss that design in detail, rest of the designs can be understood by examining the code.  A note on the directory structure for the project before we proceed:

1. `doc/` - contains detailed documentation and images
2. `sim/` - testbenches and verification 
3. `src/` - source SystemVerilog HDL
4. `syn/` - Synthesis scripts, primarily AMD-Xilinx based FPGAs

## Design of the `AXI-Lite MM` Priority Based Arbiter

