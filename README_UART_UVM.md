# UART UVM Verification Platform

基于 **SystemVerilog / UVM 1.2 / SVA** 搭建的 UART 模块级验证平台，使用 **Synopsys VCS** 完成编译与仿真，并通过 **Verdi + FSDB** 进行波形调试。

项目覆盖 UART 基本收发、定向测试、约束随机测试、Reset 异常场景、功能覆盖率统计及 SystemVerilog Assertion 检查，并通过 Scoreboard 实现 Expected/Actual 自动比对。

## 1. DUT 功能简介

DUT 为 UART Loopback 模块：

```text
uart_rxd
   │
   ▼
 UART RX
   │
   ├── rx_data
   └── rx_valid
        │
        ▼
 UART TX
   │
   ▼
uart_txd
```

主要配置：

- System Clock：50 MHz
- UART Baud Rate：9600
- Data Width：8 bit
- UART Format：1 Start + 8 Data + 1 Stop
- Data Order：LSB First
- Reset：低有效

## 2. 验证环境

```text
                         uart_env
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   Active Agent         Passive Agent       Reset Agent
        │                   │                   │
 ┌──────┼──────┐            │             Sequencer/Driver
 │      │      │            │                   │
Seqr  Driver Monitor      Monitor              Reset
        │      │            │
        │      ▼            │
        │   Reference       │
        │     Model         │
        │      │            │
        │   Expected        │
        │      │            │
        │      └──────┐     │
        │             ▼     ▼
        │          Scoreboard
        │
        ▼
      DUT
```

主要组件：

- Active Agent：产生 UART 输入激励并监控输入侧 transaction
- Passive Agent：监控 DUT UART 输出
- Reference Model：根据输入 transaction 生成 expected transaction
- Scoreboard：自动比较 Expected / Actual
- Functional Coverage：统计数据模式及场景覆盖情况
- Reset Driver：产生正常及传输过程中的 Reset 激励
- SVA Checker：检查 UART 协议及 Reset 关键时序

## 3. 测试点

| Test Point | 验证内容 | 预期结果 |
|---|---|---|
| Basic Loopback | 发送单字节 UART 数据 | TX 回传数据与 RX 输入一致 |
| Directed Test | 测试 `00/FF/55/AA/A5/5A/01/10/08/80` 等典型数据 | Scoreboard 全部 PASS |
| Constrained Random | 随机产生 UART 数据 | Expected 与 Actual 一致 |
| Normal Reset | 空闲状态下触发 Reset | DUT 恢复默认状态，Reset 后可继续通信 |
| Reset During RX | UART 接收过程中触发 Reset | 当前未完成帧被丢弃，恢复后通信正常 |
| Reset During TX | UART 发送过程中触发 Reset | 当前发送被终止，Reset 后恢复正常 |
| Reset Recovery | Reset 释放后重新发送数据 | UART 正常收发，Scoreboard PASS |
| Back-to-Back | 连续无间隔发送 UART Frame | 验证 DUT 连续传输处理能力 |
| Transaction Flush | Reset 时清除未完成 Expected/Actual transaction | Reset 后 Scoreboard 不发生事务错位 |
| Protocol Timing | Start/Stop Bit、Reset、RX-TX 响应等检查 | SVA 无 Assertion Failure |

## 4. 功能覆盖率

UART 数据覆盖模型包含：

- `0x00`
- `0xFF`
- `0x55`
- `0xAA`
- Low Range
- Middle Range
- High Range

约束随机测试结果：

```text
Functional Coverage = 100%
```

Reset 覆盖以下场景：

```text
NORMAL RESET
RESET DURING RX
RESET DURING TX
```

Reset Suite 测试结果：

```text
Reset Functional Coverage = 100%
```

## 5. Assertions

通过 SystemVerilog Assertions 对关键协议及时序行为进行检查，包括：

- Reset 最小保持时间
- Reset 后 UART TX 返回 Idle
- Reset 后 LED 恢复默认值
- Reset 期间输出状态检查
- RX Start Bit 检查
- RX Stop Bit 检查
- TX Start Bit 检查
- TX Stop Bit 检查
- RX 完整帧后的 TX Response 检查
- DUT 输出 X/Z 检查

Assertion 使用独立 checker module，并通过 `bind` 方式挂接 DUT，避免修改 RTL。

## 6. Scoreboard

验证平台使用 Reference Model + Scoreboard 进行 transaction 级自动检查：

```text
Active Monitor
      │
      ▼
Reference Model
      │
   Expected
      │
      ▼
  Scoreboard
      ▲
   Actual
      │
Passive Monitor
```

正常比较：

```text
Expected == Actual  -> PASS
Expected != Actual  -> UVM_ERROR
```

Reset 发生时，Scoreboard 会清理未完成 transaction，避免 Reset 中断帧影响后续比较。

示例结果：

```text
Pass num : 3
Fail num : 0
Flush num: 3

UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
```

## 7. Back-to-Back 场景发现的问题

严格 Back-to-Back 连续发送测试中观察到：

```text
RX 完成
   │
   ▼
rx_valid
   │
   ▼
TX 当前仍处于 busy
   │
   ▼
新的 TX 请求无法缓存
   │
   ▼
部分回传帧丢失
```

通过以下方式完成定位：

- UVM Scoreboard 比较结果
- Monitor Transaction Log
- Verdi FSDB 波形
- UART RX/TX 状态及时序分析

该场景用于验证 DUT 在高连续流量下的边界行为。

## 8. 仿真环境

```text
SystemVerilog
UVM 1.2
SystemVerilog Assertions
Synopsys VCS
Synopsys Verdi
FSDB
Makefile
```

当前使用环境：

```text
VCS   : O-2018.09-1
Verdi : Verdi_O-2018.09-SP2
```

## 9. 编译与运行

编译：

```bash
make clean
make comp
```

Directed Smoke Test：

```bash
make run TEST=uart_smoke_test
```

Constrained Random Test：

```bash
make run TEST=uart_random_test SEED=1
```

Reset Suite：

```bash
make run TEST=uart_reset_suite_test
```

更换随机种子：

```bash
make run TEST=uart_random_test SEED=10
```

## 10. 波形查看

仿真生成：

```text
uart.fsdb
```

使用 Verdi 打开：

```bash
verdi -ssf uart.fsdb -dbdir simv.daidir &
```

建议观察：

```text
clk
reset
uart_rxd
uart_txd
rx_valid
rx_data
tx_busy
led
RX/TX FSM
bit_counter
cycle_counter
```

## 11. 项目目录示例

```text
UART/
├── rtl/
│   ├── uart_rx.sv
│   ├── uart_tx.sv
│   └── impl_top.sv
│
├── lab/
│   ├── uart_interface.sv
│   ├── uart_transaction.sv
│   ├── uart_sequence.sv
│   ├── uart_random_sequence.sv
│   ├── uart_sequencer.sv
│   ├── uart_driver.sv
│   ├── uart_act_monitor.sv
│   ├── uart_pas_monitor.sv
│   ├── uart_act_agent.sv
│   ├── uart_pas_agent.sv
│   ├── uart_refmodule.sv
│   ├── uart_scoreboard.sv
│   ├── uart_coverage.sv
│   ├── uart_reset_transaction.sv
│   ├── uart_reset_sequence.sv
│   ├── uart_reset_driver.sv
│   ├── uart_reset_agent.sv
│   ├── uart_reset_coverage.sv
│   ├── uart_assertion.sv
│   ├── uart_assertion_bind.sv
│   ├── uart_env.sv
│   ├── uart_smoke_test.sv
│   ├── uart_random_test.sv
│   ├── uart_reset_suite_test.sv
│   ├── uart_pkg.sv
│   └── uart_tb.sv
│
└── sim/
    ├── Makefile
    └── filelist.f
```

实际目录与文件名可根据仓库中的代码调整。

## 12. 当前验证结果

已完成：

- UVM 模块级验证环境搭建
- Directed Test
- Constrained Random Test
- Reference Model / Scoreboard 自动比对
- UART Functional Coverage：**100%**
- Reset Functional Coverage：**100%**
- Normal Reset
- Reset During RX
- Reset During TX
- Reset Recovery
- SystemVerilog Assertions
- Verdi 波形调试
- Back-to-Back Corner Case 分析

典型测试结果：

```text
UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
```

## 13. 项目目的

本项目用于实践完整的数字 IC 模块级验证流程：

```text
Verification Plan
        ↓
UVM Testbench
        ↓
Directed / Random Stimulus
        ↓
Monitor / Reference Model
        ↓
Scoreboard
        ↓
Functional Coverage
        ↓
Assertions
        ↓
Waveform Debug
```

通过该项目完成了从 UART DUT 功能分析、UVM 验证平台搭建，到约束随机验证、功能覆盖、异常场景验证、断言检查和波形调试的完整验证流程。
