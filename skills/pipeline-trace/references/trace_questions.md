# Pipeline Trace — Generic Question Template (Q1-Q10)

Generalized from a video-hardware-to-RTSP trace (Ambarella oryx_v2 SDK,
see `oryx_v2/video流程trace.md` for the original video-specific version).

For each question below: replace the bracketed placeholders with the
concrete terms found during Q0 (Step 1 of the skill) before asking the AI —
e.g. for an audio subsystem, `{INPUT}` might be "mic capture / I2S driver",
`{FINAL_OUTPUT}` might be "RTP audio session" or "AAC file in MP4"; for a
storage subsystem, `{INPUT}` might be "encoded packet from AMActiveMuxer",
`{FINAL_OUTPUT}` might be "MP4/TS segment file on SD card", and `{CONSUMER}`
might be "a recording session" rather than "an RTSP client".

This is a **living template** — per skill Step 4, update this file when a
question's generic wording proves wrong/missing across multiple traces.
Keep subsystem-specific one-offs out of this file (they go in the per-trace
NOTES_*.md instead).

---

### Q1. 輸入端與狀態管理 (Input boundary & lifecycle/state machine)
資料如何進入 `{SUBSYSTEM}`？輸入介面/資料結構是什麼（驅動 ioctl、上游 packet
queue、檔案系統 API...）？有沒有狀態機/生命週期管理（init/start/stop/error）？
進入點的檔案/函式在哪？

**為什麼要問**：建立這個 subsystem 的「起點」，是未來「完全沒資料/沒輸出」時
第一個檢查點。

---

### Q2. 資料的記憶體語意 / zero-copy / 跨 process 限制
資料在 `{SUBSYSTEM}` 內部以什麼形式存在（指標/offset/fd/複製出的新
buffer）？是否有 zero-copy、reference counting？是否支援跨 process 共享
（dma_buf fd、shared memory 等）？哪些路徑支援、哪些不支援、是否因硬體世代
而異？

**為什麼要問**：決定後續任何「零拷貝」或「跨 process」設計是否可行。這題在
video trace 中曾發現「程式碼假設存在但實際 SDK 不支援」的欄位
（見 `NOTES_iav_dma_buf_support.md`）——務必以原始碼為準，不要相信文件或
舊有假設。

---

### Q3. 內部框架/資料流結構 (Internal pipeline framework)
這個 subsystem 在整個 SDK 的 pipeline 框架中如何接入（filter/element/
module）？資料（packet/buffer）在模組之間怎麼傳遞（queue/pin/callback/
共享記憶體）？是 reference counting 還是真的複製？buffer pool 怎麼管理？

**為什麼要問**：理解資料在各模組間流動的「載具」，是後續所有資料流分析的
基礎。

---

### Q4. 多輸出/多消費者的 fan-out
同一份 `{SUBSYSTEM}` 資料，是否會同時送到多個目的地（例如：不同協定、不同
檔案、AI 推論、縮圖）？是各自拿到 reference（zero-copy）還是各自複製一份？
fan-out 的程式碼在哪裡？

**為什麼要問**：了解多功能同時運作時的資源共用與耦合風險，也是新增輸出類型
的切入點。若這個 subsystem 只有單一輸出路徑，這題答案會很短，但仍值得確認
「目前是不是真的只有一個」。

---

### Q5. 最終輸出的封裝/轉換（關鍵 copy/轉換點在哪）
資料在送到 `{FINAL_OUTPUT}`（網路協定 / 檔案格式 / 儲存裝置）前，經過哪些
轉換步驟？哪一步是第一次/唯一一次的 memcpy 或格式轉換（例如：bitstream →
協定封包、raw frame → 容器格式）？這一步在哪個檔案/函式？

**為什麼要問**：找出整條管線中真正的「成本」所在，是性能優化或自訂輸出格式
時的關鍵切入點。

---

### Q6. 多 client/session 分送與起始同步
當有多個 `{CONSUMER}`（client 連線/錄影 session/訂閱者）同時存在時，資料如何
分別送達各自的 queue/buffer？新加入的 `{CONSUMER}` 是否有特殊的起始狀態處理
（例如等待下一個 keyframe/IDR、等待新的 segment 邊界、等待對齊點）？這個邏輯
在哪裡？

**為什麼要問**：避免把「新 consumer 的初始延遲」誤判成 bug，也是新增
consumer 管理功能時的入口。

---

### Q7. 控制面/管理介面 (Control plane)
`{SUBSYSTEM}` 怎麼被外部控制（啟動/停止/設定參數/查詢狀態）？是透過協定
（如 RTSP）、本地 IPC、設定檔、還是 API 呼叫？控制面與資料面之間如何同步
（event/callback/共享變數/鎖）？

**為什麼要問**：了解 session/任務生命週期管理與「控制面/資料面」同步機制，
是新增控制指令或除錯連線/啟動問題的基礎。

---

### Q8. 跨 subsystem 同步 (cross-subsystem sync)
`{SUBSYSTEM}` 是否需要跟其他 subsystem（影像/音訊/多路 stream）同步時間戳記
或順序？PTS/DTS 如何產生與對齊？是否共用同一個 clock source？

**為什麼要問**：A/V 不同步、多路 stream 順序錯亂是常見問題，需要先了解各
subsystem 的相對獨立性與同步點。

---

### Q9. Threading model
`{SUBSYSTEM}` 從輸入到輸出的流程中，總共有哪些執行緒？各自的進入點（entry
function）、觸發時機、生命週期（常駐 / per-consumer 建立）？

**為什麼要問**：建立「執行緒↔功能」對照表，方便用 ps/top/gdb 對應到實際運作
中的程式行為，也是排查 race condition 的基礎。

---

### Q10. Backpressure / 資源不足處理
當下游（consumer 太慢、儲存太慢、buffer pool 用盡）處理不過來時，
`{SUBSYSTEM}` 怎麼處理：丟棄當前資料、阻塞上游、還是其他策略？這個機制會不會
回壓影響到更上游（例如硬體編碼器）？相關的 log/錯誤碼是什麼？

**為什麼要問**：了解系統在過載時的行為邊界，是穩定性與容量規劃的關鍵，也是
「為什麼會掉幀/掉資料/卡頓」這類問題的標準檢查點。
