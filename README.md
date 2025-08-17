
# 🚀 Scalable AXI Verification IP (VIP)

## Project Overview

This project implements a **highly scalable AXI Verification IP (VIP)** in **SystemVerilog**, designed to **thoroughly verify AXI master-slave transactions** across multiple realistic scenarios. The VIP emphasizes **flexibility, correctness, and modularity**, making it suitable for complex verification environments and professional-grade simulations.

It has been **successfully verified on QuestaSim**, handling multiple transactions efficiently. Optional **verbose debugging** prints transaction **data and addresses**, while default execution produces **coverage reports and summaries**, maintaining clarity and efficiency.

## Key Features

* **Burst Types:** Supports **Fixed, Incremental (INCR), Wrap, and Shifting Strobe bursts**.

  * **Shifting Strobe bursts** verify **lane-wise data shifting and alignment**, essential for accurate system-level verification.

* **Transaction Flexibility:** Handles multiple transaction types within a single simulation. The **execution order is determined by the simulator**, allowing the VIP to manage any sequence produced during runtime, demonstrating **robust multi-transaction handling**.

* **Scalability:**

  * Fully **parameterizable port widths**.
  * Burst size is always **≤ port width**, ensuring safe, accurate data transfers without overflow or misalignment.

* **Data Integrity:**

  * Correct handling of **endianness**, guaranteeing accurate storage and retrieval of multi-byte data.

* **Verification Mechanisms:**

  * **Functional AXI slave model** simulating realistic responses.
  * Comprehensive **assertions** for protocol compliance and error detection.
  * Detailed **functional coverage** for burst types, transaction sequences, and scenarios.

* **Verbose Debugging:**

  * Optional mode prints **transaction-level details** (data and addresses).
  * Default mode provides **clean coverage and summary reports** suitable for professional verification workflows.

* **Future Enhancements:** The VIP is designed to support **advanced transaction types** in upcoming versions:

  * **Out-of-order transactions**
  * **Interleaved bursts**
  * **Overlapping bursts**

These additions will extend the VIP to **high-performance verification environments** without compromising its current robustness.

## Test Scenarios

The VIP has been verified across multiple realistic scenarios:

* Mixed transaction sequences comprising Fixed, INCR, and Wrap bursts, demonstrating **robust multi-transaction handling**.
* Fixed, Incremental, and Wrap bursts with **user-defined transaction counts**, verifying configurable transaction behavior.
* Shifting Strobe bursts have been verified to ensure **lane-wise data shifting and correct alignment**.

All scenarios have been **successfully simulated**, confirming the VIP’s **reliability, flexibility, and scalability**.
