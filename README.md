# SPWM FPGA Design

本專案在 FPGA 上實作正弦波脈寬調變（SPWM, Sinusoidal Pulse Width Modulation），並透過 **PLL** 和 **除頻器** 精準產生近似 60Hz 的 SPWM 波形輸出。


## 需求
* 當正弦波到達最高點（sin =+1）時 → 輸出的 PWM 是「完全高電位」 ➜ duty = 100%
* 當正弦波到達最低點（sin = -1）時 → 輸出的 PWM 是「完全低電位」 ➜ duty = 0%
* 其他時候 duty 介於 0～100% 之間 ➜ duty ∝ sin 值（比例關係）

## 規格
* sine wave週期(頻率): 目標1/60秒(60Hz)，5%以內
* PWM脈波寬度時間: 最小可調刻度為 10ns，最小高電位寬度（duty）為 20ns（即2 clock）
（@FPGA 時脈週期10ns）
* 一個sine裡面最多256個PWM脈波週期
* PWM duty比例，可接受外部數位訊號調整(增減duty)
* 提供UART介面設定/讀取上述參數，或者讀取指定狀態
#### 前級HV-Bus 高升壓電路 #### 
* 輸入電壓77~137.5  
* 變頻電流控制5k-200k  Hz  
* 最大功率2 kW  
* 具緩啟動控制
#### 後級inverter輸出 #### 
* 輸出電壓380 VAC三相電源  
* 最大功率1.8 kW  
* 全橋式架構

#### 系統環境

| 項目             | 說明                                      |
|------------------|-------------------------------------------|
| 開發板           | EGO-XZ7(測試)                                   |
| 系統時脈         | 100 MHz（FPGA 輸入主時脈）                |
| 正弦波產生方式   | 使用 256 筆 sine LUT 查表產生             |
| 正弦波資料格式   | `std_logic_vector(7 downto 0)`            |


#### 頻率與公式計算

| 項目                                 | 單位：Hz           | 計算公式                                   | 備註說明                                     |
|--------------------------------------|--------------------|---------------------------------------------|----------------------------------------------|
| 除頻後時脈（1個 PWM 週期）           | **24.4 KHz**       | `1 / (10ns × 4096)`                          | 每個 PWM 週期時間（divide(12) = 2¹² = 4096） |
| SPWM 最慢頻率（256 PWM × 1024）     | **0.0466 Hz**      | `1 / (10ns × 4096 × 256 × 1024)`            | `SIN_UPDATE_PERIOD = 1024`（最慢情況）       |
| SPWM 最快頻率（256 PWM × 1）        | **約 95 Hz**       | `1 / (10ns × 4096 × 256)`                   | `SIN_UPDATE_PERIOD = 1`（最快情況）          |

###### 說明：

- 一個完整正弦週期 = 256 筆 PWM 輸出
- 每筆 PWM 時間 = 4096 個 clock（@100MHz 時脈）＝約 40.96 μs
- 總正弦週期時間 = 256 × 40.96 μs × `SIN_UPDATE_PERIOD`
- 可以透過調整 `SIN_UPDATE_PERIOD` 來改變 SPWM 頻率

## API
| 名稱          | 類型     | 說明                              |
| ----------- | ------ | ------------------------------- |
| `i_clk`     | input  | 系統時脈，來源為 100MHz（經 PLL 處理）       |
| `i_rst`     | input  | 非同步重置信號，**低電位有效**               |
| `o_pwm_out` | output | SPWM 輸出訊號，根據 sine LUT 結果調整 duty |

##  架構

| 模組                   | 說明                                          |
|------------------------|-----------------------------------------------|
| `SPWM_top.vhd`         | 頂層模組，串接 PLL、除頻器、SPWM_main         |
| `SPWM_clk_divider.vhd` | 除頻模組，將 1MHz 時脈除以 4096（divide(12)） |
| `SPWM_main.vhd`        | 核心 SPWM 控制模組，內含 LUT、FSM、PWM 邏輯   |
| `design_1_wrapper.vhd` | Block Design 自動產生，內含 PLL（1MHz）      |
| `clk_wiz_0`            | Vivado Clocking Wizard 產生的 PLL IP          |
| `SPWM_test.xdc`        | 約束檔，設定輸入時脈與 PWM 輸出腳位           |

## 架構圖
<img width="1940" height="753" alt="image" src="https://github.com/user-attachments/assets/4ff90b22-f5e0-4040-a26b-03f770396553" />


## 參數說明

| 參數名稱           | 預設值 | 說明                                                                 |
|--------------------|--------|----------------------------------------------------------------------|
| `SIN_WIDTH`        | 8      | 控制 PWM 的基本頻率位元寬度（影響計數範圍）                           |
| `SIN_TABLE_SIZE`   | 256    | 定義 sin 的採樣點數（將整個 sine wave 切成若干段，越多越平滑）         |
| `SIN_UPDATE_PERIOD`| 1      | 控制經過幾個 PWM 週期後，才更新一次 `sin_index`（對應 LUT 位置）       |
| `DUTY_SCALE`       | 255    | 壓縮整體 duty 範圍，用來微調 PWM 波形變化幅度（0~255 範圍）             |

## 時脈與頻率計算

- **輸入時脈（i_clk）：** 100 MHz
- **PLL 輸出時脈：** 1 MHz（由 `clk_wiz_0` IP 設定）
- **除頻器：** divide(12) → 1 MHz ÷ 4096 ≈ 244 Hz
- **LUT 點數：** 256 筆


##  測試方法

1. 在 Vivado 中完成 Bitstream 產生
2. 上板後以邏輯分析儀或示波器觀察 `o_pwm_out`
3. 預期看到頻率為約 **60Hz 的 SPWM 波形**

##  DEMO 
1. 單一SPWM
![image](https://github.com/user-attachments/assets/02928332-8c63-44dc-98eb-8f0caff01339)

2. 三相SPWM  
    <img width="800" height="632" alt="image" src="https://github.com/user-attachments/assets/a1541ad9-5f5d-40ba-8052-24d83b501f53" />

## SPWM_Utilization Report
<img width="1364" height="475" alt="image" src="https://github.com/user-attachments/assets/a8785633-c5dc-404c-aded-e0823bba0926" />
<img width="936" height="573" alt="image" src="https://github.com/user-attachments/assets/438ff6e3-c8a9-4f0d-a126-7a0ce6c09b0d" />
<img width="1731" height="446" alt="image" src="https://github.com/user-attachments/assets/f923365e-9323-4f21-802d-8180a9dcba64" />




