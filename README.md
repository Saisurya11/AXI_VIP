

# 🚀 Scalable AXI Verification IP (VIP)

## Project Overview

This project implements a **highly scalable AXI Verification IP (VIP)** in **SystemVerilog**, designed to **thoroughly verify AXI master-slave transactions** across multiple scenarios. The VIP is built with **modularity, flexibility, and precision** in mind, making it suitable for complex verification environments and professional-grade simulations.

It has been **successfully verified on QuestaSim**, handling multiple transactions efficiently. Optional **verbose debugging** allows detailed inspection of **data and addresses**, while default execution focuses on **coverage collection and report summaries**, ensuring both efficiency and clarity.


## Key Features

* **Burst Types:** Supports **Fixed, Incremental (INCR), Wrap, and Shifting Strobe bursts**.

  * **Shifting Strobe bursts** are implemented to **verify lane-wise data shifting**, ensuring correct propagation and alignment across ports, which is crucial for realistic system-level verification.

* **Transaction Flexibility:** Handles multiple transaction types within a single simulation. The **actual order of execution is determined by the simulator**, and the VIP is capable of managing any sequence it produces, demonstrating robust and versatile transaction handling.

* **Scalability:**

  * Fully **parameterizable port widths**.
  * Burst size is always **less than or equal to port width**, ensuring safe and accurate data transfers without overflow or misalignment.

* **Data Integrity:**

  * Correct handling of **endianness** for all transactions, guaranteeing accurate storage and retrieval of multi-byte data.

* **Verification Mechanisms:**

  * **Functional AXI slave model** to simulate realistic responses.
  * Comprehensive **assertions** for protocol compliance and error detection.
  * Detailed **functional coverage** across burst types and transaction sequences.

* **Verbose Debugging:**

  * Optional mode prints **transaction-level details** (data and addresses) for detailed inspection.
  * Default mode produces **clean coverage and summary reports** suitable for professional verification workflows.


## Test Scenarios

The VIP has been exercised across multiple realistic verification scenarios:

* Mixed transaction sequences comprising Fixed, INCR, and Wrap bursts, demonstrating **robust multi-transaction handling**.
* Fixed, Incremental, and Wrap bursts with **user-defined transaction counts**, verifying configurable transaction behavior.
* Shifting Strobe bursts have been verified to ensure **lane-wise data shifting and correct alignment**.

All scenarios have been **successfully simulated**, confirming the VIP’s **robustness, flexibility, and reliability**.


Do you want me to do that next?
